import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../core/utils/theme.dart';
import '../../../../core/services/assign_production_batch.dart';
import '../../../../core/services/variety_service.dart';

class AssignProductionDialog extends StatefulWidget {
  final int machineId;
  final VoidCallback onSuccess;

  const AssignProductionDialog({
    super.key,
    required this.machineId,
    required this.onSuccess,
  });

  @override
  State<AssignProductionDialog> createState() => _AssignProductionDialogState();
}

class _AssignProductionDialogState extends State<AssignProductionDialog> {
  final totalLengthCtrl = TextEditingController();
  final amountPerMeterCtrl = TextEditingController();
  final alertThresholdCtrl = TextEditingController();

  List<Variety> varieties = [];
  String? selectedVariety;
  bool varietiesLoading = true;
  bool loading = false;

  final _decimalFormatter =
      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'));

  @override
  void initState() {
    super.initState();
    _loadVarieties();
  }

  Future<void> _loadVarieties() async {
    final list = await VarietyService.instance.fetch();
    if (!mounted) return;
    setState(() {
      varieties = list;
      varietiesLoading = false;
    });
  }

  @override
  void dispose() {
    totalLengthCtrl.dispose();
    amountPerMeterCtrl.dispose();
    alertThresholdCtrl.dispose();
    super.dispose();
  }

  void _error(String msg) {
    Get.snackbar("Error", msg,
        backgroundColor: AppTheme.error, colorText: AppTheme.textSecondary);
  }

  Future<void> submit() async {
    // Variety
    if (selectedVariety == null) {
      _error("Please select a variety");
      return;
    }

    // Total length (must be greater than 0)
    final totalLength = double.tryParse(totalLengthCtrl.text.trim());
    if (totalLength == null) {
      _error("Enter a valid total length");
      return;
    }
    if (totalLength <= 0) {
      _error("Total length must be greater than 0");
      return;
    }

    // Amount per meter (must be greater than 0)
    final amountPerMeter = double.tryParse(amountPerMeterCtrl.text.trim());
    if (amountPerMeter == null) {
      _error("Enter a valid amount per meter");
      return;
    }
    if (amountPerMeter <= 0) {
      _error("Amount per meter must be greater than 0");
      return;
    }

    // Alert threshold (optional)
    double? alertThreshold;
    final alertText = alertThresholdCtrl.text.trim();
    if (alertText.isNotEmpty) {
      alertThreshold = double.tryParse(alertText);
      if (alertThreshold == null) {
        _error("Enter a valid alert value");
        return;
      }
      if (alertThreshold < 0) {
        _error("Alert value cannot be less than 0");
        return;
      }
      if (alertThreshold > totalLength) {
        _error("Alert value cannot be more than total length ($totalLength)");
        return;
      }
    }

    setState(() => loading = true);

    final success = await AssignProductionService().assign(
      machineId: widget.machineId,
      varietyType: selectedVariety!,
      totalLength: totalLength,
      amountPerMeter: amountPerMeter,
      alertThreshold: alertThreshold,
    );

    if (!mounted) return;
    setState(() => loading = false);

    if (success) {
      Get.back();
      widget.onSuccess();
      Get.snackbar("Success", "Production is assigned",
          backgroundColor: AppTheme.success, colorText: AppTheme.textSecondary);
    } else {
      _error("There is something wrong");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: AppTheme.neutral,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 16),
            const Text("Assign Production",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary)),
            const SizedBox(height: 20),

            // Variety select field
            varietiesLoading
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: CircularProgressIndicator(),
                  )
                : DropdownButtonFormField<String>(
                    value: selectedVariety,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: "Variety Type",
                      prefixIcon: const Icon(Icons.category_outlined),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    hint: Text(varieties.isEmpty
                        ? "No varieties. Add from Machines page"
                        : "Select variety"),
                    items: varieties
                        .map((v) => DropdownMenuItem(
                              value: v.name,
                              child: Text(v.name),
                            ))
                        .toList(),
                    onChanged: varieties.isEmpty
                        ? null
                        : (v) => setState(() => selectedVariety = v),
                  ),
            const SizedBox(height: 12),

            TextField(
              controller: totalLengthCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [_decimalFormatter],
              decoration: InputDecoration(
                labelText: "Total Length",
                prefixIcon: const Icon(Icons.straighten),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: amountPerMeterCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [_decimalFormatter],
              decoration: InputDecoration(
                labelText: "Amount per meter",
                prefixIcon: const Icon(Icons.payments_outlined),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: alertThresholdCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [_decimalFormatter],
              decoration: InputDecoration(
                labelText: "Alert when remaining reaches (meters)",
                hintText: "e.g. 100",
                prefixIcon: const Icon(Icons.notifications_active_outlined),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  "Optional leave blank if you don't want an alert for this batch",
                  style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.textPrimary.withOpacity(0.5)),
                ),
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: loading ? null : submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: loading
                    ? const CircularProgressIndicator(color: AppTheme.secondary)
                    : const Text("Assign Production",
                        style: TextStyle(
                            color: AppTheme.textSecondary, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}