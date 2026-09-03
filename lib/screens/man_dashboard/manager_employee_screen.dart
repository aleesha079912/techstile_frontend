import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:techstile_frontend/widgets/man_drawer.dart';
import '../../core/services/manager_service/manager_service.dart';
import '../../core/utils/theme.dart';
import '../../widgets/man_bottom_navbar.dart';
import 'package:techstile_frontend/screens/employee_dashboard/profile.dart';
import 'package:techstile_frontend/core/services/auth_service.dart';

class ManagerEmployeesScreen extends StatefulWidget {
  final dynamic factoryId;

  const ManagerEmployeesScreen({
    super.key,
    required this.factoryId,
  });

  @override
  State<ManagerEmployeesScreen> createState() =>
      _ManagerEmployeesScreenState();
}

class _ManagerEmployeesScreenState extends State<ManagerEmployeesScreen> {
  final _service = ManagerDashboardService();

  bool loading = true;
  String? error;
  String? factoryName;
  bool showActiveOnly = false;

  List employees = [];
  List filteredEmployees = [];

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final res = await _service.getEmployees(widget.factoryId);
      final dashboardData = await _service.getDashboard(widget.factoryId);

      setState(() {
        employees = res;
        factoryName = dashboardData['factory']?['name'];
        loading = false;
      });

      applyFilter();
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  void applyFilter() {
    final query = searchController.text.toLowerCase();

    setState(() {
      filteredEmployees = employees.where((emp) {
        final user = emp['user'];
        final name = user?['name']?.toString().toLowerCase() ?? '';
        final matchesSearch = name.contains(query);

        if (showActiveOnly) {
          return matchesSearch && (emp['is_active'] == true);
        } else {
          return matchesSearch;
        }
      }).toList();
    });
  }

  void searchEmployee(String value) {
    applyFilter();
  }

  @override
  Widget build(BuildContext context) {
    int totalEmployeesCount = employees.length;
    int activeEmployeesCount =
        employees.where((e) => e['is_active'] == true).length;

    return Scaffold(
      drawer: ManagerDrawer(
        userId: AuthService.userId,
        factoryId: AuthService.factoryId,
      ),
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.secondary,
        iconTheme: const IconThemeData(color: AppTheme.primary),
        elevation: 0,
        automaticallyImplyLeading: true,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'All Employees',
              style: TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.w800,
                fontSize: 17,
              ),
            ),
            Text(
              loading ? 'Loading...' : (factoryName ?? 'Factory'),
              style: TextStyle(
                color: AppTheme.textPrimary.withOpacity(0.65),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            )
          : error != null
              ? _errorView()
              : employees.isEmpty
                  ? _emptyView()
                  : Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              // Search Bar
                              TextField(
                                controller: searchController,
                                onChanged: searchEmployee,
                                decoration: InputDecoration(
                                  hintText: "Search Employee",
                                  prefixIcon: const Icon(Icons.search),
                                  filled: true,
                                  fillColor: AppTheme.secondary,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Interactive Colored Stat Cards Row
                              Row(
                                children: [
                                  statBox(
                                    "Total Employees",
                                    "$totalEmployeesCount",
                                    AppTheme.primary,
                                    Icons.people_alt_rounded,
                                    !showActiveOnly,
                                    () {
                                      setState(() {
                                        showActiveOnly = false;
                                        applyFilter();
                                      });
                                    },
                                  ),
                                  const SizedBox(width: 12),
                                  statBox(
                                    "Active Employees",
                                    "$activeEmployeesCount",
                                    AppTheme.active,
                                    Icons.bolt_rounded,
                                    showActiveOnly,
                                    () {
                                      setState(() {
                                        showActiveOnly = true;
                                        applyFilter();
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: RefreshIndicator(
                            color: AppTheme.primary,
                            onRefresh: load,
                            child: filteredEmployees.isEmpty
                                ? const Center(
                                    child: Text(
                                      "No matching employees found",
                                      style: TextStyle(
                                          color: AppTheme.textSecondary),
                                    ),
                                  )
                                : ListView.builder(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    itemCount: filteredEmployees.length,
                                    itemBuilder: (_, i) =>
                                        _employeeCard(filteredEmployees[i]),
                                  ),
                          ),
                        ),
                      ],
                    ),
      bottomNavigationBar: ManagerBottomNav(
        currentIndex: 2,
        factoryId: widget.factoryId,
      ),
    );
  }

  // Stat Card Widget (With Active Color Switch)
  Widget statBox(String label, String value, Color activeThemeColor,
      IconData icon, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected ? activeThemeColor : AppTheme.secondary,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? activeThemeColor
                  : AppTheme.neutral.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? activeThemeColor.withOpacity(0.3)
                    : AppTheme.onsurface.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.secondary.withOpacity(0.2)
                      : activeThemeColor.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isSelected
                      ? AppTheme.secondary
                      : activeThemeColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? AppTheme.secondary
                            : activeThemeColor,
                      ),
                    ),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 11,
                        color: isSelected
                            ? AppTheme.secondary.withOpacity(0.9)
                            : AppTheme.textSecondary,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _errorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 48, color: AppTheme.error),
            const SizedBox(height: 12),
            Text(error ?? 'Something went wrong',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 13)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: load, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }

  Widget _emptyView() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.people_outline_rounded,
              size: 48, color: AppTheme.neutral),
          SizedBox(height: 12),
          Text('No employees assigned',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text, bool isActive) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 13,
            color: isActive ? AppTheme.active : AppTheme.primary,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 11.5,
                color: AppTheme.textneutral,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _employeeCard(dynamic e) {
    final user = e['user'];
    final name = user?['name']?.toString() ?? 'Employee';
    final email = user?['email']?.toString() ?? '--';
    final phone = user?['phone_no']?.toString() ?? '--';

    final bool isActive = e['is_active'] == true;

    return InkWell(
      borderRadius: AppTheme.cardRadius,
      onTap: () {
        Get.to(
          () => UserProfileScreen( 
      userId: int.parse(e['id'].toString()),
      factoryId: widget.factoryId,
    ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.active.withOpacity(0.08)
              : AppTheme.secondary,
          borderRadius: AppTheme.cardRadius,
          border: Border.all(
            color: isActive
                ? AppTheme.active.withOpacity(0.4)
                : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: AppTheme.softShadow,
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 19,
              backgroundColor:
                  isActive ? AppTheme.active : AppTheme.primary,
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'E',
                style: const TextStyle(
                  color: AppTheme.secondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isActive
                                ? AppTheme.active
                                : AppTheme.primary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppTheme.active
                              : AppTheme.neutral.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          isActive ? "Active" : "Inactive",
                          style:  TextStyle(
                            color: isActive
                              ? AppTheme.secondary
                              : AppTheme.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  _infoRow(Icons.email_outlined, email, isActive),
                  _infoRow(Icons.phone_outlined, phone, isActive),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios,
              size: 13,
              color: isActive ? AppTheme.active : AppTheme.neutral,
            ),
          ],
        ),
      ),
    );
  }
}