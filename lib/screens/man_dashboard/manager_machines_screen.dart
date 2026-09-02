import 'package:flutter/material.dart';
import '../../core/services/manager_service/manager_service.dart';
import '../../core/utils/theme.dart';
import '../../widgets/man_bottom_navbar.dart';
import 'package:get/get.dart';
import 'machine_detail_screen.dart';
import 'package:techstile_frontend/widgets/man_drawer.dart';
import 'package:techstile_frontend/core/services/auth_service.dart';

class ManagerMachinesScreen extends StatefulWidget {
  final dynamic factoryId;

  const ManagerMachinesScreen({
    super.key,
    required this.factoryId,
  });

  @override
  State<ManagerMachinesScreen> createState() =>
      _ManagerMachinesScreenState();
}

class _ManagerMachinesScreenState extends State<ManagerMachinesScreen> {
  final _service = ManagerDashboardService();

  bool loading = true;

  List machines = [];
  List filteredMachines = [];
  String? factoryName;

  String? error;
  bool showActiveOnly = false;

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
      final res = await _service.getMachines(widget.factoryId);
      final dashboardData = await _service.getDashboard(widget.factoryId);

      setState(() {
        machines = res;
        factoryName = dashboardData['factory']?['name'];
        loading = false;
      });

      applyFilters();
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  void applyFilters() {
    final query = searchController.text.toLowerCase();

    setState(() {
      filteredMachines = machines.where((machine) {
        final machineName = machine.machineName.toString().toLowerCase();
        final machineType = machine.type.toString().toLowerCase();

        final matchesSearch =
            machineName.contains(query) || machineType.contains(query);

        if (showActiveOnly) {
          return matchesSearch && (machine.isActive == true);
        } else {
          return matchesSearch;
        }
      }).toList();
    });
  }

  void searchMachines(String value) {
    applyFilters();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int totalCount = machines.length;
    int activeCount = machines.where((m) => m.isActive == true).length;

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
              'All Machines',
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
              child: CircularProgressIndicator(
                color: AppTheme.primary,
              ),
            )
          : error != null
              ? _errorView()
              : Column(
                  children: [
                    /// SEARCH BAR
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        controller: searchController,
                        onChanged: searchMachines,
                        decoration: InputDecoration(
                          hintText: "Search by machine name or type",
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: AppTheme.secondary,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),

                    /// TOTAL / ACTIVE CLICKABLE BOXES
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: _statBox(
                              "Total Machines",
                              "$totalCount",
                              AppTheme.textPrimary,
                              Icons.precision_manufacturing_rounded,
                              !showActiveOnly,
                              () {
                                setState(() {
                                  showActiveOnly = false;
                                  applyFilters();
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _statBox(
                              "Active",
                              "$activeCount",
                              AppTheme.active,
                              Icons.bolt_rounded,
                              showActiveOnly,
                              () {
                                setState(() {
                                  showActiveOnly = true;
                                  applyFilters();
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    /// MACHINE LIST
                    Expanded(
                      child: RefreshIndicator(
                        color: AppTheme.primary,
                        onRefresh: load,
                        child: filteredMachines.isEmpty
                            ? _emptyView()
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                itemCount: filteredMachines.length,
                                itemBuilder: (_, i) =>
                                    _machineCard(filteredMachines[i]),
                              ),
                      ),
                    ),
                  ],
                ),
      bottomNavigationBar: ManagerBottomNav(
        currentIndex: 1,
        factoryId: widget.factoryId,
      ),
    );
  }

  Widget _statBox(
    String label,
    String value,
    Color activeThemeColor,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? activeThemeColor : AppTheme.secondary,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? activeThemeColor : AppTheme.neutral.withOpacity(0.3),
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
                color: isSelected ?  AppTheme.secondary : activeThemeColor,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      color: isSelected ?  AppTheme.textSecondary : activeThemeColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      color: isSelected
                          ?  AppTheme.secondary.withOpacity(0.9)
                          : AppTheme.textSecondary,
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ],
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
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: AppTheme.error,
            ),
            const SizedBox(height: 12),
            Text(
              error ?? 'Something went wrong',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: load,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyView() {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(
              Icons.precision_manufacturing_outlined,
              size: 48,
              color: AppTheme.neutral,
            ),
            SizedBox(height: 12),
            Text(
              'No machines found',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _machineCard(dynamic m) {
    final bool isActive = m.isActive == true;

    return InkWell(
      borderRadius: AppTheme.cardRadius,
      onTap: () {
        Get.to(
          () => MachineDetailsScreen(
            machine: m,
            factoryId: widget.factoryId.toString(),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
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
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isActive
                    ? AppTheme.active
                    : AppTheme.primary,
                   shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.precision_manufacturing_rounded,
                color: AppTheme.secondary,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    m.machineName,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    m.type,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: isActive
                    ? AppTheme.active.withOpacity(0.2)
                    : AppTheme.neutral.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isActive ? "Active" : "Inactive",
                style: TextStyle(
                  color: isActive ? AppTheme.success : AppTheme.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 5),
            const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: AppTheme.neutral,
            ),
          ],
        ),
      ),
    );
  }
}