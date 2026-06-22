import 'package:flutter/material.dart';
import 'package:techstile_frontend/widgets/emp_drawer.dart';
import '../../core/services/employee_service/attendance_service.dart';
import '../../core/services/employee_service/machine_detail_service.dart';
import '../../core/utils/theme.dart';
import 'package:get/get.dart';
import '../../routes/routes.dart';
 
 final attendanceService = AttendanceService();
 bool alreadyMarkedToday = false;
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

  // ✅ Yahan add karo — class level pe
  bool canAdd = false;
  double remaining = 0;

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
        machine   = data;
        canAdd    = data['can_add_production'] ?? false;
        remaining = (data['remaining'] ?? 0).toDouble();
        loading   = false;
        alreadyMarkedToday = data['already_marked_today'] ?? false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
    }
  }

  Widget infoCard(String title, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primary),
          const SizedBox(width: 15),
          Expanded(
            child: Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, color: AppTheme.primary)),
          ),
          Text(value,
              style: const TextStyle(
                  color: AppTheme.primary, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget statCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Text(title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 15)),
          const SizedBox(height: 10),
          Text(value,
              style: const TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 20)),
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
        title: const Text("Machine Details",
            style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  infoCard("Machine ID",
                      "${machine?["machine_id"] ?? ""}", Icons.qr_code),
                  infoCard("Machine Type",
                      machine?["machine_type"] ?? "", Icons.precision_manufacturing),
                  infoCard("Employee Name",
                      machine?["employee_name"] ?? "", Icons.person),
                  infoCard("Employee ID",
                      "${machine?["employee_id"] ?? ""}", Icons.badge),
                  infoCard("Status",
                      machine?["status"] ?? "", Icons.power_settings_new),
                  infoCard("Variety",
                      machine?["variety_type"] ?? "", Icons.category),
                  infoCard("Shift Start",
                      machine?["shift_start"] ?? "", Icons.login),
                  infoCard("Shift End",
                      machine?["shift_end"] ?? "", Icons.logout),
                  infoCard("Assigned Length",
                      "${machine?["total_length"] ?? 0}", Icons.straighten),
                  infoCard("Ready Production",
                      "${machine?["ready_production"] ?? 0}", Icons.check_circle),
                  infoCard("Remaining",
                      "$remaining", Icons.hourglass_bottom), // ✅ remaining show

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: statCard("Daily",
                            (machine?['daily_production'] ?? 0).toString()),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: statCard("Weekly",
                            (machine?['weekly_production'] ?? 0).toString()),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  statCard("Yearly Production",
                      (machine?['yearly_production'] ?? 0).toString()),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            canAdd ? AppTheme.primary : Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                     onPressed: canAdd
                              ? () async {
                                  await Get.toNamed(
                                    AppRoutes.enterProduction,
                                    arguments: {
                                      'machineId':   widget.machineId,
                                      'varietyType': machine?['variety_type'] ?? '',
                                      'totalLength': machine?['total_length']?.toString() ?? '',
                                      'remaining':   remaining.toString(),
                                    },
                                  );
                                  // after fresh prduction is enter fresh load
                                  loadData();
                                }
                          : () {
                              Get.snackbar(
                                "Complete",
                                "The Production is Completed of this Machine",
                                backgroundColor: Colors.orange,
                                colorText: Colors.white,
                              );
                            },
                      icon: Icon(canAdd ? Icons.add : Icons.lock),
                      label: Text(
                        canAdd
                            ? "Enter Production (Remaining: $remaining)"
                            : "Production Complete",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height:20),
                  SizedBox(
                    width: double.infinity,
                    height:55,
                child: ElevatedButton.icon(

                   onPressed: alreadyMarkedToday
                      ? () {
                          Get.snackbar(
                            "Already Marked",
                            "Already Marked",
                            backgroundColor: Colors.orange,
                            colorText: Colors.white,
                          );
                        }
                      : () async{ final success =
                      await attendanceService.markAttendance(

                        employeeId:
                        machine?['employee_id'],

                        machineId:
                        int.parse(widget.machineId),

                      );


                      if(success){

                        Get.snackbar(
                        "Success",
                        "Attendance Marked",
                        backgroundColor: Colors.green,
                        colorText: Colors.white
                        );
                        loadData();

                      }
                      else{

                        Get.snackbar(
                        "Error",
                        "Attendance Failed",
                        backgroundColor: Colors.red,
                        colorText: Colors.white
                        );

                      }


                    },


                    icon:const Icon(Icons.fingerprint),

                    label: Text(
                        alreadyMarkedToday
                        ? "Attendance Already Marked"
                        : "Mark Attendance",
                    style:TextStyle(
                    fontSize:16,
                    fontWeight:FontWeight.bold
                    ),
                    ),


                    style:ElevatedButton.styleFrom(
                    backgroundColor:Colors.green,
                    foregroundColor:Colors.white,
                    shape:RoundedRectangleBorder(
                    borderRadius:BorderRadius.circular(12)
                    )
                    ),

                    ),

                    ),
                ],
              ),
            ),
    );
  }
}