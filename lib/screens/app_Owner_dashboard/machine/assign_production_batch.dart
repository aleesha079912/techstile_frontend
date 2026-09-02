import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/utils/theme.dart';
import '../../../../core/services/assign_production_batch.dart';

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
  final varietyCtrl     = TextEditingController();
  final totalLengthCtrl = TextEditingController();
  final amountPerMeterCtrl = TextEditingController();
  String? selectDays;
  
   // state variable - class ke top pe declare karein

  final List<String> weekDays = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday",
  ];

  bool loading = false;

  @override
  void dispose() {
    varietyCtrl.dispose();
    totalLengthCtrl.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (varietyCtrl.text.isEmpty || totalLengthCtrl.text.isEmpty) {
      Get.snackbar("Error", "Saare fields fill karo",
          backgroundColor: AppTheme.background, colorText: AppTheme.secondary);
      return;
    }

    setState(() => loading = true);

    final success = await AssignProductionService().assign(
      machineId:   widget.machineId,
      varietyType: varietyCtrl.text.trim(),
      totalLength: double.parse(totalLengthCtrl.text.trim()),
      amountPerMeter:double.parse(amountPerMeterCtrl.text.trim()),
      selectDays:selectDays
    
    );

    setState(() => loading = false);

    if (success) {
      Get.back();
      widget.onSuccess();
      Get.snackbar("Success", "Production assign ho gayi",
          backgroundColor: AppTheme.success, colorText:AppTheme.textSecondary);
    } else {
      print(success);
      Get.snackbar("Error", "Kuch galat hua",
          backgroundColor: AppTheme.error, colorText: AppTheme.textSecondary);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20, right: 20, top: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 50, height: 5,
              decoration: BoxDecoration(
                color: AppTheme.neutral,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 16),

            const Text("Assign Production",
              style: TextStyle(fontSize: 18,
                  fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            const SizedBox(height: 20),

            // Variety Type
            TextField(
              controller: varietyCtrl,
              decoration: InputDecoration(
                labelText: "Variety Type",
                prefixIcon: const Icon(Icons.category_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),

            // Total Length
            TextField(
              controller: totalLengthCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Total Length",
                prefixIcon: const Icon(Icons.straighten),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),

            // Amount per month
            TextField(
              controller: amountPerMeterCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Amount per meter",
                prefixIcon: const Icon(Icons.straighten),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ), 
            const SizedBox(height: 12),
           
           // Select days
            DropdownButtonFormField<String>(
              value: selectDays,
              decoration: InputDecoration(
                labelText: "Select day",
                prefixIcon: const Icon(Icons.calendar_today_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              items: weekDays.map((day) {
                return DropdownMenuItem<String>(
                  value: day,
                  child: Text(day),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectDays = value;
                });
              },
              validator: (value) =>
                value == null ? "Please select a day" : null,
            ),
                      
           
           
           
           
           
           
           
            const SizedBox(height: 24),


            // Submit Button
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
                        style: TextStyle(color:AppTheme.textSecondary, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}