import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:techstile_frontend/core/utils/theme.dart';
import 'package:techstile_frontend/core/services/employee_service/employee_dashboard_service.dart';
import 'package:techstile_frontend/core/services/auth_service.dart';
import 'package:techstile_frontend/widgets/emp_db_bot_nav_bar.dart';
import 'package:techstile_frontend/widgets/emp_drawer.dart';
import 'profile.dart';

class EmployeeDashboard extends StatefulWidget {
  const EmployeeDashboard({super.key});

  @override
  State<EmployeeDashboard> createState() => _EmployeeDashboardState();
}

class _EmployeeDashboardState extends State<EmployeeDashboard> {
  final EmployeeDashboardService service = EmployeeDashboardService();

  bool loading = true;
  List machines = [];
  String employeeName = '';
  int totalMachines = 0;
  double totalProduction = 0;
  double totalReadyProduction = 0;
  double dailyApproved = 0;
  double weeklyApproved = 0;

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    try {
      final data = await service.getDashboard();

      setState(() {
        machines = data["machines"] ?? [];
        employeeName = data["employee_name"]?.toString() ?? '';
        totalMachines = data["total_machines"] ?? 0;
        totalProduction = (data["total_production"] ?? 0).toDouble();
        totalReadyProduction = (data["total_ready_production"] ?? 0).toDouble();
        dailyApproved = (data["daily_ready_production"] ?? 0).toDouble();
        weeklyApproved = (data["weekly_ready_production"] ?? 0).toDouble();
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const EmployeeDrawer(),
      backgroundColor: AppTheme.background,
 
      

      appBar: AppBar(
        backgroundColor: AppTheme.primary,
         elevation: 0,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu_rounded, color: AppTheme.secondary),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: const Text("LOOM CONTROL", style: TextStyle(color: AppTheme.secondary),),
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadDashboard,
              child: ListView(
              padding: EdgeInsets.zero,
              children: [
                /// EMPLOYEE CARD (tap -> profile)
                GestureDetector(
                  onTap: () => Get.to(
                    () => UserProfileScreen(userId: AuthService.userId),
                  ),
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.primary, AppTheme.primary.withOpacity(0.8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withOpacity(0.3),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor:  AppTheme.secondary.withOpacity(0.2),
                          child: Text(
                            employeeName.isNotEmpty
                                ? employeeName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                                color:  AppTheme.secondary,
                                fontSize: 22,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                employeeName.isNotEmpty ? employeeName : 'Employee',
                                style: const TextStyle(
                                    color:  AppTheme.secondary,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'View your profile',
                                style: TextStyle(
                                    color:  AppTheme.secondary.withOpacity(0.75), fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios_rounded,
                            color:  AppTheme.secondary.withOpacity(0.8), size: 16),
                      ],
                    ),
                  ),
                ),

                /// TITLE
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Production Overview",
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                /// DAILY / WEEKLY APPROVED PRODUCTION
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _statTile(
                          icon: Icons.today_rounded,
                          label: "Today (Approved)",
                          value: dailyApproved.toStringAsFixed(0),
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _statTile(
                          icon: Icons.calendar_month_rounded,
                          label: "This Week (Approved)",
                          value: weeklyApproved.toStringAsFixed(0),
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                /// 2 BUTTONS IN ONE LINE
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildOverviewButton(
                          icon: Icons.precision_manufacturing,
                          label: "My Machines",
                          value: "$totalMachines",
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Expanded(
                      //   child: _buildOverviewButton(
                      //     icon: Icons.straighten,
                      //     label: "Assigned",
                      //     value: "${totalProduction.toStringAsFixed(0)}",
                      //   ),
                      // ), 
                      // const SizedBox(width: 8),
                      Expanded(
                        child: _buildOverviewButton(
                          icon: Icons.check_circle,
                          label: "Ready (all-time)",
                          value: "${totalReadyProduction.toStringAsFixed(0)}",
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "My Assigned Machines",
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                /// LIST
                if (machines.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      children: [
                        Icon(Icons.precision_manufacturing_outlined,
                            size: 40, color: AppTheme.textSecondary.withOpacity(0.5)),
                        const SizedBox(height: 10),
                        Text(
                          "No machines assigned yet",
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  )
                else
                  ...machines.map((machine) {
                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primary.withOpacity(0.08),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.memory, color: AppTheme.primary),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    (machine["machine_name"] ?? '').toString().isNotEmpty
                                        ? machine["machine_name"].toString()
                                        : "Machine #${machine["machine_id"]}",
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            Row(
                              children: [
                                Icon(Icons.category, color: AppTheme.primary, size: 18),
                                const SizedBox(width: 8),
                                Text(machine["variety_type"] ?? ""),
                              ],
                            ),
                            const SizedBox(height: 12),

                            Text(
                              "Ready Production: ${machine["ready_production"]}",
                            ),

                            const SizedBox(height: 5),

                            Text("Total Length: ${machine["total_length"]}"),

                            const SizedBox(height: 10),

                            LinearProgressIndicator(
                              value: (machine["progress"] ?? 0) / 100,
                              minHeight: 10,
                              color: AppTheme.primary,
                              backgroundColor: AppTheme.primary.withOpacity(
                                0.2,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              "Progress: ${machine["progress"]}%",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                const SizedBox(height: 20),
              ],
              ),
            ),

      bottomNavigationBar: const EmployeeBottomNav(currentIndex: 0),
    );
  }

  /// SMALL STAT TILE (daily / weekly approved)
  Widget _statTile({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:  AppTheme.secondary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: AppTheme.primary.withOpacity(0.06), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 10),
          Text(value,
              style: TextStyle(
                  color: AppTheme.primary, fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }

  /// BUTTON WIDGET
  Widget _buildOverviewButton({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: AppTheme.primary.withOpacity(0.08), blurRadius: 8),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.primary),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: AppTheme.background,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}