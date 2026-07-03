
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:techstile_frontend/widgets/man_drawer.dart';
import '../../core/services/manager_service/manager_service.dart';
import '../../core/utils/theme.dart';
import '../../widgets/man_bottom_navbar.dart';
import 'manager_emloyee_detail_screen.dart';
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

class _ManagerEmployeesScreenState
    extends State<ManagerEmployeesScreen> {
  final _service = ManagerDashboardService();

  bool loading = true;
  String? error;
  String? factoryName;

  List employees = [];
  List filteredEmployees = [];

  final TextEditingController searchController =
      TextEditingController();

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
        employees          = res;
        filteredEmployees  = res;
        factoryName        = dashboardData['factory']?['name'];
        loading            = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  void searchEmployee(String value) {
    setState(() {
      filteredEmployees = employees.where((emp) {
        final name =
            emp['user']?['name']
                    ?.toString()
                    .toLowerCase() ??
                '';
        return name.contains(value.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: ManagerDrawer(
  userId: AuthService.userId,
  factoryId: AuthService.factoryId,
),
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        iconTheme: IconThemeData(color: AppTheme.secondary),
        elevation: 0,
        automaticallyImplyLeading: true,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'All Employees',
              style: TextStyle(
                color:  AppTheme.secondary,
                fontWeight: FontWeight.w800,
                fontSize: 17,
              ),
            ),
            Text(
              loading ? 'Loading...' : (factoryName ?? 'Factory'),
              style: TextStyle(
                color: AppTheme.secondary.withOpacity(0.65),
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
                          child: TextField(
                            controller: searchController,
                            onChanged: searchEmployee,
                            decoration: InputDecoration(
                              hintText: "Search Employee",
                              prefixIcon: const Icon(Icons.search),
                              filled: true,
                              fillColor: AppTheme.secondary,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: RefreshIndicator(
                            color: AppTheme.primary,
                            onRefresh: load,
                            child: ListView.builder(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
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
          Icon(Icons.people_outline_rounded, size: 48, color: AppTheme.neutral),
          SizedBox(height: 12),
          Text('No employees assigned',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
        ],
      ),
    );
  }

  // ── Compact info row — chota icon + chota text ──────────────────────────
  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(icon, size: 13, color: AppTheme.primary),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 11.5, color:  AppTheme.neutral),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ── ✅ Compact employee card — size kam kiya ──────────────────────────────
  Widget _employeeCard(dynamic e) {
    final user = e['user'];
    final name = user?['name']?.toString() ?? 'Employee';
    final email = user?['email']?.toString() ?? '--';
    final phone = user?['phone_no']?.toString() ?? '--';

    return InkWell(
      borderRadius: AppTheme.cardRadius,
      onTap: () {
        Get.to(
          () => ManagerEmployeeDetailScreen(
            employeeId: int.parse(e['id'].toString()),
            factoryId: widget.factoryId,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),       // ✅ kam margin
        padding: const EdgeInsets.all(12),                // ✅ kam padding
        decoration: BoxDecoration(
          color:  AppTheme.secondary,
          borderRadius: AppTheme.cardRadius,
          boxShadow: AppTheme.softShadow,
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 19,                                  // ✅ chota avatar (pehle 25)
              backgroundColor: AppTheme.secondary.withOpacity(.2),
              child: Text(
                name[0].toUpperCase(),
                style: const TextStyle(
                  color: AppTheme.primary,
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
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 14,                          // ✅ chota (pehle 17)
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    "ID: ${e['id']}",
                    style: const TextStyle(fontSize: 10.5, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  _infoRow(Icons.email_outlined, email),
                  _infoRow(Icons.phone_outlined, phone),
                  _infoRow(
                    Icons.access_time_rounded,
                    "${e['shift_starttime'] ?? '--'} - ${e['shift_endtime'] ?? '--'}",
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 13, color: AppTheme.neutral),
          ],
        ),
      ),
    );
  }
}
