import 'package:flutter/material.dart';
import 'package:techstile_frontend/core/utils/theme.dart';
import 'package:techstile_frontend/core/services/employee_service/employee_dashboard_service.dart';
import 'package:techstile_frontend/widgets/emp_db_bot_nav_bar.dart';
import 'package:techstile_frontend/widgets/emp_drawer.dart';

class EmployeeDashboard extends StatefulWidget {
  const EmployeeDashboard({super.key});

  @override
  State<EmployeeDashboard> createState() => _EmployeeDashboardState();
}

class _EmployeeDashboardState extends State<EmployeeDashboard> {
  final EmployeeDashboardService service = EmployeeDashboardService();

  bool loading = true;
  List machines = [];
  int totalMachines = 0;
  double totalProduction = 0;
  double totalReadyProduction = 0;

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
        totalMachines = data["total_machines"] ?? 0;
        totalProduction = (data["total_production"] ?? 0).toDouble();
        totalReadyProduction =
            (data["total_ready_production"] ?? 0).toDouble();
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
        title: const Text("LOOM CONTROL", style: TextStyle(color: AppTheme.neutral),),
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                /// TITLE
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Production Overview",
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                /// 3 BUTTONS IN ONE LINE
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildOverviewButton(
                          icon: Icons.precision_manufacturing,
                          label: "Machines",
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
                          label: "Ready",
                          value: "${totalReadyProduction.toStringAsFixed(0)}",
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 7),

                /// LIST
                Expanded(
                  child: ListView.builder(
                    itemCount: machines.length,
                    itemBuilder: (context, index) {
                      final machine = machines[index];

                      return Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primary.withOpacity(0.08),
                              blurRadius: 10,
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.memory, color: AppTheme.primary),
                                const SizedBox(width: 8),
                                Text(
                                  "Machine ID: ${machine["machine_id"]}",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            Row(
                              children: [
                                Icon(Icons.person, color: AppTheme.primary),
                                const SizedBox(width: 8),
                                Text(machine["employee_name"] ?? ""),
                              ],
                            ),
                            const SizedBox(height: 8),

                            Row(
                              children: [
                                Icon(Icons.category,
                                    color: AppTheme.primary),
                                const SizedBox(width: 8),
                                Text(machine["variety_type"] ?? ""),
                              ],
                            ),
                            const SizedBox(height: 12),

                            Text(
                              "Ready Production: ${machine["ready_production"]}",
                            ),

                            const SizedBox(height: 5),

                            Text(
                              "Total Length: ${machine["total_length"]}",
                            ),

                            const SizedBox(height: 10),

                            LinearProgressIndicator(
                              value: (machine["progress"] ?? 0) / 100,
                              minHeight: 10,
                              color: AppTheme.primary,
                              backgroundColor:
                                  AppTheme.primary.withOpacity(0.2),
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
                    },
                  ),
                ),
              ],
            ),

      bottomNavigationBar: const EmployeeBottomNav(currentIndex: 0),
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
        color: AppTheme.secondary,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.08),
            blurRadius: 8,
          )
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.primary),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: AppTheme.background,
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