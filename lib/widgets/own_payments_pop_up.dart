import 'package:flutter/material.dart';
import 'package:techstile_frontend/core/services/payments_service.dart';

class AddPaymentDialog extends StatefulWidget {
  final int factoryId;
  final VoidCallback onSuccess;

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
  final _employeeIdFocus = FocusNode();

  bool _isSubmitting = false;
  bool _isLoadingEarned = false;
  Map<String, dynamic>? _earnedSummary; // total_earned, total_paid, remaining
  String? _earnedError;

  @override
  void initState() {
    super.initState();
    _employeeIdFocus.addListener(() {
      // fetch as soon as the user leaves the employee field
      if (!_employeeIdFocus.hasFocus) {
        _loadEarnedAmount();
      }
    });
  }

  @override
  void dispose() {
    _employeeIdCtrl.dispose();
    _amountPaidCtrl.dispose();
    _employeeIdFocus.dispose();
    super.dispose();
  }

  Future<void> _loadEarnedAmount() async {
    final text = _employeeIdCtrl.text.trim();
    final id = int.tryParse(text);
    if (id == null) {
      setState(() {
        _earnedSummary = null;
        _earnedError = null;
      });
      return;
    }

    setState(() {
      _isLoadingEarned = true;
      _earnedError = null;
    });

    try {
      final data = await _paymentService.getEarnedAmount(id);
      if (!mounted) return;
      setState(() {
        _earnedSummary = data;
        // pre-fill amount paid with remaining balance, user can still edit it
        final remaining = (data['remaining'] as num?)?.toDouble() ?? 0;
        _amountPaidCtrl.text = remaining > 0 ? remaining.toStringAsFixed(2) : '';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _earnedSummary = null;
        _earnedError = 'Could not load earned amount';
      });
    } finally {
      if (mounted) setState(() => _isLoadingEarned = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      await _paymentService.addPayment(
        employeeId: int.parse(_employeeIdCtrl.text),
        amountPaid: double.parse(_amountPaidCtrl.text),
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
      {TextInputType type = TextInputType.text,
      bool required = true,
      FocusNode? focusNode}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        focusNode: focusNode,
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

  Widget _earnedInfo() {
    if (_isLoadingEarned) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: LinearProgressIndicator(minHeight: 3),
      );
    }
    if (_earnedError != null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(_earnedError!, style: const TextStyle(color: Colors.red, fontSize: 12)),
      );
    }
    if (_earnedSummary == null) return const SizedBox.shrink();

    final earned = (_earnedSummary!['total_earned'] as num?)?.toDouble() ?? 0;
    final paid = (_earnedSummary!['total_paid'] as num?)?.toDouble() ?? 0;
    final remaining = (_earnedSummary!['remaining'] as num?)?.toDouble() ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _summaryRow('Total earned', earned),
          _summaryRow('Already paid', paid),
          _summaryRow('Remaining', remaining, bold: true),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, double value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: bold ? FontWeight.w700 : FontWeight.w400)),
          Text(value.toStringAsFixed(2), style: TextStyle(fontWeight: bold ? FontWeight.w700 : FontWeight.w400)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
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
                  _field('Employee ID', _employeeIdCtrl,
                      type: TextInputType.number, focusNode: _employeeIdFocus),
                  _earnedInfo(),
                  _field('Amount Paid', _amountPaidCtrl, type: TextInputType.number),
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