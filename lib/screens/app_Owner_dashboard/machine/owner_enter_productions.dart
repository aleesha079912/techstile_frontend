import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/theme.dart';
import '../../../core/services/employee_service/employee_production_service.dart';

/// Owner-side production entry.
/// Owner khud production "karta" nahi — is liye yahan employee select
/// karna zaroori hai taake pata rahe ye production kis employee/shift ki hai.
///
/// ✅ Variety/Total Length/Remaining ab SHARED (machine ke current batch) hain —
/// dono shift-employees ke liye same. Sirf "Ready Production" har employee ki
/// apni hoti hai.
class OwnerEnterProductionScreen extends StatefulWidget {
  final int machineId;
  final int factoryId;

  /// Shared batch info (machine-wide), MachineController::details se.
  final String? batchId;
  final String varietyType;
  final double totalLength;
  final double remaining;

  /// Employees currently assigned to this machine's shifts.
  /// Each item: {employee_id, user_id, employee_name, shift_start, shift_end}
  final List<Map<String, dynamic>> shifts;

  const OwnerEnterProductionScreen({
    super.key,
    required this.machineId,
    required this.factoryId,
    required this.batchId,
    required this.varietyType,
    required this.totalLength,
    required this.remaining,
    required this.shifts,
  });

  @override
  State<OwnerEnterProductionScreen> createState() =>
      _OwnerEnterProductionScreenState();
}

class _OwnerEnterProductionScreenState
    extends State<OwnerEnterProductionScreen> {
  Map<String, dynamic>? _selectedShift;

  final readyController = TextEditingController();
  final wasteController = TextEditingController();

  bool loading = false;

  Future<void> _submit() async {
    if (_selectedShift == null) {
      Get.snackbar("Error", "Pehle employee select karein");
      return;
    }
    if (readyController.text.trim().isEmpty) {
      Get.snackbar("Error", "Ready production enter karein");
      return;
    }

    final ready = double.tryParse(readyController.text) ?? 0;
    final waste = double.tryParse(
          wasteController.text.isEmpty ? '0' : wasteController.text,
        ) ??
        0;

    if (ready + waste > widget.remaining) {
      Get.snackbar(
        "Error",
        "Maximum ${widget.remaining} allowed (ready + waste) — ye remaining dono shifts mila kar hai",
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
      final result = await EmployeeProductionService().submitProductionWithMessage(
        machineId: widget.machineId,
        userId: userId is int ? userId : int.parse(userId.toString()),
        factoryId: widget.factoryId,
        varietyType: widget.varietyType,
        totalLength: widget.totalLength,
        readyProduction: ready,
        wasteProduction: waste,
      );

      if (result['success'] == true) {
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
          result['message']?.toString() ?? "Production not added",
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

  Widget _readonlyField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Text(value, style: const TextStyle(fontSize: 15)),
        ),
      ],
    );
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
                // ── Shared batch info (read-only, machine-wide) ──
                _readonlyField("Variety Type", widget.varietyType),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: _readonlyField(
                          "Total Length", "${widget.totalLength}"),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _readonlyField(
                          "Remaining (shared)", "${widget.remaining}"),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
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
                  onChanged: (v) => setState(() => _selectedShift = v),
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