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

      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        title: const Text("LOOM CONTROL"),
      ),

      backgroundColor: AppTheme.secondary,

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                /// TOP CARD
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        AppTheme.primary,
                        AppTheme.primary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "Production Overview",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStat(
                            icon: Icons.precision_manufacturing,
                            value: "$totalMachines",
                            label: "Machines",
                          ),
                          _buildStat(
                            icon: Icons.straighten,
                            value: totalProduction.toStringAsFixed(0),
                            label: "Assigned",
                          ),
                          _buildStat(
                            icon: Icons.check_circle,
                            value: totalReadyProduction.toStringAsFixed(0),
                            label: "Ready",
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                /// LIST
                Expanded(
                  child: ListView.builder(
                    itemCount: machines.length,
                    itemBuilder: (context, index) {
                      final machine = machines[index];

                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
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
                            /// MACHINE ID
                            Row(
                              children: [
                                Icon(Icons.memory,
                                    color: AppTheme.primary),
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

                            /// TYPE
                            Row(
                              children: [
                                Icon(Icons.precision_manufacturing,
                                    color: AppTheme.primary),
                                const SizedBox(width: 8),
                                Text(machine["machine_type"] ?? ""),
                              ],
                            ),

                            const SizedBox(height: 8),

                            /// EMPLOYEE
                            Row(
                              children: [
                                Icon(Icons.person,
                                    color: AppTheme.primary),
                                const SizedBox(width: 8),
                                Text(machine["employee_name"] ?? ""),
                              ],
                            ),

                            const SizedBox(height: 8),

                            /// VARIETY
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
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.neutral,
                              ),
                            ),

                            const SizedBox(height: 5),

                            Text(
                              "Total Length: ${machine["total_length"]}",
                              style: TextStyle(color: AppTheme.neutral),
                            ),

                            const SizedBox(height: 15),

                            /// PROGRESS
                            LinearProgressIndicator(
                              value: (machine["progress"] ?? 0).toDouble() / 100,
                              minHeight: 10,
                              color: AppTheme.primary,
                              backgroundColor:
                                  AppTheme.primary.withOpacity(0.2),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              "Progress : ${machine["progress"]} %",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primary,
                              ),
                            ),

                            const SizedBox(height: 10),

                            /// STATUS
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                machine["machine_status"] ?? "",
                                style: TextStyle(
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
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

      bottomNavigationBar:
          const EmployeeBottomNav(currentIndex: 0),
    );
  }

  Widget _buildStat({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(label, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }
}