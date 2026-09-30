import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/utils/theme.dart';
import '../../../core/services/employee_service/employee_production_service.dart';

class OwnerEnterProductionScreen extends StatefulWidget {
  final int machineId;
  final int factoryId;

  final String? batchId;
  final String varietyType;
  final double totalLength;
  final double remaining;

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

  final _decimalFormatter =
      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'));

  @override
  void dispose() {
    readyController.dispose();
    wasteController.dispose();
    super.dispose();
  }

  void _error(String msg) {
    Get.snackbar(
      "Error",
      msg,
      backgroundColor: AppTheme.error,
      colorText: AppTheme.textSecondary,
    );
  }

  Future<void> _submit() async {
    if (_selectedShift == null) {
      _error("First select the employee");
      return;
    }
    if (readyController.text.trim().isEmpty) {
      _error("Enter ready production");
      return;
    }

    final ready = double.tryParse(readyController.text.trim());
    final waste = double.tryParse(
      wasteController.text.trim().isEmpty ? '0' : wasteController.text.trim(),
    );

    // Invalid number check
    if (ready == null || waste == null) {
      _error("Please enter a valid number");
      return;
    }

    // Ready 0 ya us se kam nahi ho sakti
    if (ready <= 0) {
      _error("Ready production must be greater than 0");
      return;
    }

    // Waste 0 ho sakti hai, negative nahi
    if (waste < 0) {
      _error("Waste cannot be less than 0");
      return;
    }

    // Ready remaining se zyada nahi ho sakti
    if (ready > widget.remaining) {
      _error(
          "Ready production cannot be more than remaining (${widget.remaining})");
      return;
    }

    // Waste remaining se zyada nahi ho sakti
    if (waste > widget.remaining) {
      _error("Waste cannot be more than remaining (${widget.remaining})");
      return;
    }

    // Dono ka total bhi remaining se zyada nahi ho sakta
    if (ready + waste > widget.remaining) {
      _error(
          "Ready + Waste (${ready + waste}) cannot be more than remaining (${widget.remaining})");
      return;
    }

    final userId = _selectedShift?['user_id'];
    if (userId == null) {
      _error("There is no user record of this employee");
      return;
    }

    setState(() => loading = true);
    try {
      final result =
          await EmployeeProductionService().submitProductionWithMessage(
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
          "Production submitted and show in approved production page.",
          backgroundColor: AppTheme.success,
          colorText: AppTheme.textSecondary,
        );
      } else {
        _error(result['message']?.toString() ?? "Production not added");
      }
    } catch (e) {
      _error("Error: $e");
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Widget _readonlyField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 12, color: AppTheme.textneutral)),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: AppTheme.secondary,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.neutral),
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
        foregroundColor: AppTheme.secondary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Shared batch info
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
                    style:
                        TextStyle(fontSize: 12, color: AppTheme.textneutral)),
                const SizedBox(height: 6),
                DropdownButtonFormField<Map<String, dynamic>>(
                  value: _selectedShift,
                  isExpanded: true,
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
                    style:
                        TextStyle(fontSize: 12, color: AppTheme.textneutral)),
                const SizedBox(height: 6),
                TextField(
                  controller: readyController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [_decimalFormatter],
                  decoration: const InputDecoration(
                    hintText: "Enter Ready Production",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 15),
                const Text("Waste Production",
                    style:
                        TextStyle(fontSize: 12, color: AppTheme.textneutral)),
                const SizedBox(height: 6),
                TextField(
                  controller: wasteController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [_decimalFormatter],
                  decoration: const InputDecoration(
                    hintText: "Enter Waste (optional)",
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
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: loading
                        ? const CircularProgressIndicator(
                            color: AppTheme.secondary)
                        : const Text(
                            "Submit Production",
                            style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
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