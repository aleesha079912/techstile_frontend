import 'package:flutter/material.dart';
import 'package:techstile_frontend/widgets/emp_drawer.dart';

import '../../core/services/employee_service/machine_detail_service.dart';
import '../../core/utils/theme.dart';
import 'package:get/get.dart';
import '../../routes/routes.dart';

class MachineDetailScreen extends StatefulWidget {
  final String machineId;

  const MachineDetailScreen({
    super.key,
    required this.machineId,
  });

  @override
  State<MachineDetailScreen> createState() =>
      _MachineDetailScreenState();
}

class _MachineDetailScreenState
    extends State<MachineDetailScreen> {
  final service = EmployeeMachineService();

  bool loading = true;
  Map<String, dynamic>? machine;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final data = await service.getMachineDetails(
        widget.machineId,
      );

      setState(() {
        machine = data;
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
    }
  }

  Widget infoCard(
    String title,
    String value,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppTheme.primary,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.primary,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget statCard(
    String title,
    String value,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const EmployeeDrawer(),
      backgroundColor: AppTheme.secondary,

      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        title: const Text(
          "Machine Details",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),

      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  infoCard(
                    "Machine ID",
                    "${machine?["machine_id"] ?? ""}",
                    Icons.qr_code,
                  ),

                  infoCard(
                    "Machine Type",
                    machine?["machine_type"] ?? "",
                    Icons.precision_manufacturing,
                  ),

                  infoCard(
                    "Employee Name",
                    machine?["employee_name"] ?? "",
                    Icons.person,
                  ),

                  infoCard(
                    "Employee ID",
                    "${machine?["employee_id"] ?? ""}",
                    Icons.badge,
                  ),

                  infoCard(
                    "Status",
                    machine?["status"] ?? "",
                    Icons.power_settings_new,
                  ),

                  infoCard(
                    "Variety",
                    machine?["variety_type"] ?? "",
                    Icons.category,
                  ),

                  infoCard(
                    "Shift Start",
                    machine?["shift_start"] ?? "",
                    Icons.login,
                  ),

                  infoCard(
                    "Shift End",
                    machine?["shift_end"] ?? "",
                    Icons.logout,
                  ),

                  infoCard(
                    "Assigned Length",
                    "${machine?["total_length"] ?? 0}",
                    Icons.straighten,
                  ),

                  infoCard(
                    "Ready Production",
                    "${machine?["ready_production"] ?? 0}",
                    Icons.check_circle,
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: statCard(
                          "Daily",
                          (machine?['daily_production'] ?? 0)
                              .toString(),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: statCard(
                          "Weekly",
                          (machine?['weekly_production'] ?? 0)
                              .toString(),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  statCard(
                    "Yearly Production",
                    (machine?['yearly_production'] ?? 0)
                        .toString(),
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            AppTheme.primary,
                        foregroundColor:
                            Colors.white,
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Get.toNamed(
                          AppRoutes.enterProduction,
                          arguments: widget.machineId,
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text(
                        "Enter Production",
                        style: TextStyle(
                          fontWeight:
                              FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}