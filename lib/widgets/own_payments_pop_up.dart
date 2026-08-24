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
  final _amountPaidCtrl = TextEditingController();
  final _productionIdCtrl = TextEditingController();
  
  bool _isSubmitting = false;

  @override
  void dispose() {
    _employeeIdCtrl.dispose();
    _amountPaidCtrl.dispose();
    _productionIdCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      
      await _paymentService.addPayment(
        
        employeeId: int.parse(_employeeIdCtrl.text), 
        // userId: int.parse(_),
        amountPaid: double.parse(_amountPaidCtrl.text) ,
        productionId: int.parse(_productionIdCtrl.text),
       
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
                  _field('Amount Paid',_amountPaidCtrl , type: TextInputType.number),
                  _field(' Production ID', _productionIdCtrl, required: false),
                 
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