import 'package:flutter/material.dart';
import 'package:techstile_frontend/core/services/payments_service.dart';
class AddPaymentDialog extends StatefulWidget {
  final int factoryId;
  final VoidCallback onSuccess; // list refresh karne ke liye

  const AddPaymentDialog({
    super.key,
    required this.factoryId,
    required this.onSuccess,
  });

  @override
  State<AddPaymentDialog> createState() => _AddPaymentDialogState();
}

class _AddPaymentDialogState extends State<AddPaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final PaymentService _paymentService = PaymentService();

  final _employeeIdCtrl = TextEditingController();
  final _varietyCtrl = TextEditingController();
  final _totalLengthCtrl = TextEditingController();
  final _machineNameCtrl = TextEditingController();
  final _amountPerMeterCtrl = TextEditingController();
  final _selectDaysCtrl = TextEditingController();
  final _shiftStartCtrl = TextEditingController();
  final _shiftEndCtrl = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _employeeIdCtrl.dispose();
    _varietyCtrl.dispose();
    _totalLengthCtrl.dispose();
    _machineNameCtrl.dispose();
    _amountPerMeterCtrl.dispose();
    _selectDaysCtrl.dispose();
    _shiftStartCtrl.dispose();
    _shiftEndCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      
      await _paymentService.addPayment(
        factoryId: widget.factoryId,
        employeeId: int.parse(_employeeIdCtrl.text),
        varietyType: _varietyCtrl.text,
        totalLength: double.parse(_totalLengthCtrl.text),
        machineName: _machineNameCtrl.text,
        amountPerMeter: double.parse(_amountPerMeterCtrl.text),
        selectDays: _selectDaysCtrl.text,
        shiftStart: _shiftStartCtrl.text,
        shiftEnd: _shiftEndCtrl.text,
      );

      if (mounted) {
        Navigator.of(context).pop();
        widget.onSuccess(); 
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment added successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Widget _field(String label, TextEditingController ctrl,
      {TextInputType type = TextInputType.text, bool required = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          isDense: true,
        ),
        validator: required
            ? (v) => (v == null || v.trim().isEmpty) ? '$label required' : null
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(                              // 👈 NAYA
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add Payment',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 16),
                  _field('Employee ID', _employeeIdCtrl, type: TextInputType.number),
                  _field('Variety Type', _varietyCtrl),
                  _field('Total Length (m)', _totalLengthCtrl, type: TextInputType.number),
                  _field('Machine Name', _machineNameCtrl, required: false),
                  _field('Amount / Meter', _amountPerMeterCtrl, type: TextInputType.number),
                  _field('Select Days', _selectDaysCtrl, required: false),
                  _field('Shift Start (HH:mm)', _shiftStartCtrl, required: false),
                  _field('Shift End (HH:mm)', _shiftEndCtrl, required: false),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _isSubmitting ? null : _submit,
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Save'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}