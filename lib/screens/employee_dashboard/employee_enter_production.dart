import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:techstile_frontend/screens/employee_dashboard/employee_dashboard.dart';

import '../../core/utils/theme.dart';
import '../../core/services/employee_service/employee_production_service.dart';
import '../../core/services/auth_service.dart';

class EnterProductionScreen extends StatefulWidget {
  final String machineId;

  const EnterProductionScreen({
    super.key,
    required this.machineId,
  });

  @override
  State<EnterProductionScreen> createState() =>
      _EnterProductionScreenState();
}

class _EnterProductionScreenState extends State<EnterProductionScreen> {

  final varietyController = TextEditingController();
  final lengthController = TextEditingController();
  final readyController = TextEditingController();
  final wasteController = TextEditingController(); // 🔥 NEW
  final remainingController = TextEditingController(); // 🔥 NEW

  bool loading = false;

  @override
  void initState() {
    super.initState();

    // ✅ auto-fill from previous screen / DB
    final args = Get.arguments;

    if (args is Map) {
      varietyController.text = args['varietyType']?.toString() ?? '';
      lengthController.text = args['totalLength']?.toString() ?? '';

      // 🔥 ADD remaining from backend
      remainingController.text = args['remaining']?.toString() ?? '0';
    }
  }

  @override
  void dispose() {
    varietyController.dispose();
    lengthController.dispose();
    readyController.dispose();
    wasteController.dispose();
    remainingController.dispose();
    super.dispose();
  }

  Future<void> submitProduction() async {

    if (readyController.text.trim().isEmpty) {
      Get.snackbar("Error", "Enter ready production");
      return;
    }

    final remaining = double.tryParse(remainingController.text) ?? 0;
    final ready = double.tryParse(readyController.text) ?? 0;

    if (ready > remaining) {
      Get.snackbar(
        "Error",
        "Maximum $remaining allowed",
        backgroundColor:AppTheme.error,
        colorText:AppTheme.secondary,
      );
      return;
    }

    setState(() => loading = true);

    try {
      final args = Get.arguments;

      final machineId = args is Map
          ? args['machineId']?.toString() ?? widget.machineId
          : widget.machineId;

      // final user = AuthService.user;
      // final userId = user?['id'];

      final result =
          await EmployeeProductionService().submitProductionWithMessage(
        machineId: int.parse(machineId),
      userId: AuthService.userId,
       factoryId: AuthService.factoryId,
        varietyType: varietyController.text,
        totalLength: double.parse(lengthController.text.isEmpty ? '0' : lengthController.text),
        readyProduction: ready,
        wasteProduction: double.parse(wasteController.text.isEmpty ? '0' : wasteController.text), // 🔥 FIX
      );

      if (result['success'] == true) {
        Get.off(() => EmployeeDashboard());

        Get.snackbar(
          "Success",
          "Submitted Successfully",
          backgroundColor: AppTheme.active,
          colorText:AppTheme.background,
        );
      } else {
        Get.snackbar(
          "Error",
          "Production not added",
          backgroundColor:AppTheme.error,
          colorText:AppTheme.secondary ,
        );
      }
    } catch (e) {
      Get.snackbar("Error", "Error: $e");
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,

      appBar: AppBar(
        title: const Text("Enter Production"),
        backgroundColor: AppTheme.primary,
        foregroundColor: AppTheme.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Variety ──
                const Text("Variety Type",
                    style: TextStyle(fontSize: 12, color:  AppTheme.neutral)),
                const SizedBox(height: 6),
                TextField(
                  controller: varietyController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    filled: true,
                  ),
                ),

                const SizedBox(height: 15),

                // ── Total Length ──
                const Text("Total Length",
                    style: TextStyle(fontSize: 12, color:  AppTheme.neutral)),
                const SizedBox(height: 6),
                TextField(
                  controller: lengthController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    filled: true,
                  ),
                ),

                const SizedBox(height: 15),

                // ── Remaining (NEW) ──
                const Text("Remaining",
                    style: TextStyle(fontSize: 12, color:  AppTheme.neutral)),
                const SizedBox(height: 6),
                TextField(
                  controller: remainingController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    filled: true,
                  ),
                ),

                const SizedBox(height: 15),

                // ── Ready ──
                const Text("Ready Production",
                    style: TextStyle(fontSize: 12, color:  AppTheme.neutral )),
                const SizedBox(height: 6),
                TextField(
                  controller: readyController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: "Enter Ready Production",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 15),

                // ── Waste (NEW) ──
                const Text("Waste Production",
                    style: TextStyle(fontSize: 12, color: AppTheme.neutral)),
                const SizedBox(height: 6),
                TextField(
                  controller: wasteController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: "Enter Waste",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 30),

                // ── Submit ──
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: loading ? null : submitProduction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: loading
                        ? const CircularProgressIndicator(color: AppTheme.secondary)
                        : const Text(
                            "Submit Production",
                            style: TextStyle(
                              color: AppTheme.secondary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}