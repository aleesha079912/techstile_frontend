import 'package:flutter/material.dart';
import 'package:get/get.dart';

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

class _EnterProductionScreenState
    extends State<EnterProductionScreen> {

  final varietyController = TextEditingController();
  final lengthController   = TextEditingController();
  final readyController    = TextEditingController();

  bool loading = false;

  @override
  void initState() {
    super.initState();

    // ✅ Machine detail screen se auto-fill
    final args = Get.arguments;
    if (args is Map) {
      varietyController.text = args['varietyType']?.toString() ?? '';
      lengthController.text  = args['totalLength']?.toString()  ?? '';
    }
  }

  @override
  void dispose() {
    varietyController.dispose();
    lengthController.dispose();
    readyController.dispose();
    super.dispose();
  }

  Future<void> submitProduction() async {
    // Validation
    if (readyController.text.trim().isEmpty) {
      Get.snackbar("Error", "Enter the ready production quantity");
      return;
    }
     final args      = Get.arguments;
     final remaining = double.tryParse(
      args?['remaining']?.toString() ?? '0') ?? 0;
     final ready     = double.tryParse(readyController.text) ?? 0;

  if (ready > remaining) {
    Get.snackbar(
      "Error",
      "Maximum $remaining enter kar sakte ho",
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
    return;
  }
  setState(() => loading = true);

    try {
      final args       = Get.arguments;
      final machineId  = args is Map
          ? args['machineId']?.toString() ?? widget.machineId
          : widget.machineId;

      final user       = AuthService.user;
      final employeeId = user?['id'];

      final bool success =
          await EmployeeProductionService().submitProduction(
        machineId:       int.parse(machineId),
        employeeId:      employeeId,
        factoryId:       1,
        varietyType:     varietyController.text,
        totalLength:     double.parse(lengthController.text.isEmpty ? '0' : lengthController.text),
        readyProduction: double.parse(readyController.text),
      );

      if (success) {
        Get.back();
        Get.snackbar(
          "Success",
          "Submitted Successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          "Error",
          "production is not added",
          backgroundColor: Colors.red,
          colorText: Colors.white,
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
      backgroundColor: AppTheme.secondary,

      appBar: AppBar(
        title: const Text("Enter Production"),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
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

                // ── Variety Type — readOnly ──────────────────
                const Text(
                  "Variety Type",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: varietyController,
                  readOnly: true, // ✅ auto-filled — edit nahi hoga
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    suffixIcon: const Icon(Icons.lock_outline, size: 18),
                  ),
                ),

                const SizedBox(height: 15),

                // ── Total Length — readOnly ──────────────────
                const Text(
                  "Total Length",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: lengthController,
                  readOnly: true, // ✅ auto-filled — edit nahi hoga
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    suffixIcon: const Icon(Icons.lock_outline, size: 18),
                  ),
                ),

                const SizedBox(height: 15),

                // ── Ready Production — editable ──────────────
                const Text(
                  "Ready Production",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: readyController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: "Enter Ready Production Quantity",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 30),

                // ── Submit Button ────────────────────────────
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
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Submit Production",
                            style: TextStyle(
                              color: Colors.white,
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