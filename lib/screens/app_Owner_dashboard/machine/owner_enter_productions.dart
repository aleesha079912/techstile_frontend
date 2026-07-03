import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/theme.dart';
import '../../../core/services/employee_service/employee_production_service.dart';
import '../../../core/services/auth_service.dart';

/// Owner-side production entry.
/// Owner khud production "karta" nahi — is liye yahan employee select
/// karna zaroori hai taake pata rahe ye production kis employee/shift ki hai.
class OwnerEnterProductionScreen extends StatefulWidget {
  final int machineId;
  final int factoryId;

  /// Shift assignments for this machine — from MachineController::details 'shifts' array.
  /// Each item: {employee_id, user_id, employee_name, shift_start, shift_end,
  ///             variety_type, total_length, remaining, ...}
  final List<Map<String, dynamic>> shifts;

  const OwnerEnterProductionScreen({
    super.key,
    required this.machineId,
    required this.factoryId,
    required this.shifts,
  });

  @override
  State<OwnerEnterProductionScreen> createState() =>
      _OwnerEnterProductionScreenState();
}

class _OwnerEnterProductionScreenState
    extends State<OwnerEnterProductionScreen> {
  Map<String, dynamic>? _selectedShift;

  final varietyController = TextEditingController();
  final lengthController = TextEditingController();
  final remainingController = TextEditingController();
  final readyController = TextEditingController();
  final wasteController = TextEditingController();

  bool loading = false;

  void _onShiftSelected(Map<String, dynamic>? shift) {
    setState(() {
      _selectedShift = shift;
      varietyController.text = shift?['variety_type']?.toString() ?? '';
      lengthController.text = shift?['total_length']?.toString() ?? '';
      remainingController.text = shift?['remaining']?.toString() ?? '0';
      readyController.clear();
      wasteController.clear();
    });
  }

  Future<void> _submit() async {
    if (_selectedShift == null) {
      Get.snackbar("Error", "Pehle employee select karein");
      return;
    }
    if (readyController.text.trim().isEmpty) {
      Get.snackbar("Error", "Ready production enter karein");
      return;
    }

    final remaining = double.tryParse(remainingController.text) ?? 0;
    final ready = double.tryParse(readyController.text) ?? 0;
    final waste = double.tryParse(
          wasteController.text.isEmpty ? '0' : wasteController.text,
        ) ??
        0;

    if (ready + waste > remaining) {
      Get.snackbar(
        "Error",
        "Maximum $remaining allowed (ready + waste)",
        backgroundColor: AppTheme.error,
        colorText: Colors.white,
      );
      return;
    }

    final userId = _selectedShift?['user_id'];
    if (userId == null) {
      Get.snackbar("Error", "Is employee ka user record nahi mila");
      return;
    }

    setState(() => loading = true);
    try {
      final success = await EmployeeProductionService().submitProduction(
        machineId: widget.machineId,
        userId: userId is int ? userId : int.parse(userId.toString()),
        factoryId: widget.factoryId,
        varietyType: varietyController.text,
        totalLength:
            double.tryParse(lengthController.text.isEmpty ? '0' : lengthController.text) ?? 0,
        readyProduction: ready,
        wasteProduction: waste,
      );

      if (success) {
        Get.back(result: true);
        Get.snackbar(
          "Success",
          "Production submitted for approval",
          backgroundColor: AppTheme.success,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          "Error",
          "Production not added",
          backgroundColor: AppTheme.error,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar("Error", "Error: $e");
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text("Enter Production"),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Employee (Shift)",
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 6),
                DropdownButtonFormField<Map<String, dynamic>>(
                  value: _selectedShift,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    filled: true,
                  ),
                  hint: const Text("Select employee"),
                  items: widget.shifts.map((s) {
                    final label =
                        "${s['employee_name'] ?? 'Employee #${s['employee_id']}'}  (${s['shift_start'] ?? ''}-${s['shift_end'] ?? ''})";
                    return DropdownMenuItem(value: s, child: Text(label));
                  }).toList(),
                  onChanged: _onShiftSelected,
                ),

                const SizedBox(height: 15),
                const Text("Variety Type",
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 6),
                TextField(
                  controller: varietyController,
                  readOnly: true,
                  decoration:
                      const InputDecoration(border: OutlineInputBorder(), filled: true),
                ),

                const SizedBox(height: 15),
                const Text("Total Length",
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 6),
                TextField(
                  controller: lengthController,
                  readOnly: true,
                  decoration:
                      const InputDecoration(border: OutlineInputBorder(), filled: true),
                ),

                const SizedBox(height: 15),
                const Text("Remaining",
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 6),
                TextField(
                  controller: remainingController,
                  readOnly: true,
                  decoration:
                      const InputDecoration(border: OutlineInputBorder(), filled: true),
                ),

                const SizedBox(height: 15),
                const Text("Ready Production",
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
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
                const Text("Waste Production",
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
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
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: loading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Submit Production",
                            style: TextStyle(
                                color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
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