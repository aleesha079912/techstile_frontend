import 'package:flutter/material.dart';
import 'package:techstile_frontend/core/services/payments_service.dart';
import 'package:techstile_frontend/core/utils/theme.dart';
import 'package:techstile_frontend/screens/app_Owner_dashboard/factory_owner_dash/paymentsScreen.dart';
// ^ EmployeePayment model aur formatAmount() helper yahan se aa rahe hain

class AddPaymentPage extends StatefulWidget {
  final int factoryId;
  final List<EmployeePayment> employees;

  const AddPaymentPage({
    super.key,
    required this.factoryId,
    required this.employees,
  });

  @override
  State<AddPaymentPage> createState() => _AddPaymentPageState();
}

class _AddPaymentPageState extends State<AddPaymentPage> {
  final _formKey = GlobalKey<FormState>();
  final PaymentService _paymentService = PaymentService();

  final _amountToPayCtrl = TextEditingController();

  EmployeePayment? _selectedEmployee;

  bool _isLoadingSummary = false;
  bool _isSubmitting = false;
  Map<String, dynamic>? _earnedSummary;
  String? _summaryError;

  @override
  void dispose() {
    _amountToPayCtrl.dispose();
    super.dispose();
  }

  double get _remainingAmount =>
      (_earnedSummary?['remaining'] as num?)?.toDouble() ?? 0.0;

  Future<void> _loadSummary(EmployeePayment employee) async {
    setState(() {
      _isLoadingSummary = true;
      _summaryError = null;
      _earnedSummary = null;
    });

    try {
      final data = await _paymentService.getEarnedAmount(employee.employeeId);
      if (!mounted) return;
      setState(() {
        _earnedSummary = data;
        final remaining = (data['remaining'] as num?)?.toDouble() ?? 0;
        _amountToPayCtrl.text =
            remaining > 0 ? remaining.toStringAsFixed(0) : '';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _summaryError = 'Could not load earned amount');
    } finally {
      if (mounted) setState(() => _isLoadingSummary = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final employee = _selectedEmployee!;
    final amount =
        double.parse(_amountToPayCtrl.text.trim().replaceAll(',', ''));

    setState(() => _isSubmitting = true);

    try {
      await _paymentService.addPayment(
        employeeId: employee.employeeId,
        amountPaid: amount,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save payment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Widget _paymentInfoRow(String title, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppTheme.textneutral,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Payment')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ==================================================
                // EMPLOYEE SELECT
                // ==================================================
                DropdownButtonFormField<EmployeePayment>(
                  value: _selectedEmployee,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Select Employee',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  items: widget.employees.map((employee) {
                    final name =
                        employee.employeeName?.trim().isNotEmpty == true
                            ? employee.employeeName!
                            : 'Employee #${employee.employeeId}';
                    return DropdownMenuItem<EmployeePayment>(
                      value: employee,
                      child: Text(
                        '$name (${employee.employeeId})',
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (employee) {
                    setState(() {
                      _selectedEmployee = employee;
                      _earnedSummary = null;
                      _summaryError = null;
                      _amountToPayCtrl.clear();
                    });
                    if (employee != null) _loadSummary(employee);
                  },
                  validator: (value) =>
                      value == null ? 'Please select an employee' : null,
                ),

                if (_selectedEmployee != null) ...[
                  const SizedBox(height: 20),

                  // ==================================================
                  // EARNED SUMMARY
                  // ==================================================
                  if (_isLoadingSummary)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: LinearProgressIndicator(minHeight: 3),
                    )
                  else if (_summaryError != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.error.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Text(
                        _summaryError!,
                        style: const TextStyle(fontSize: 12, color: Colors.red),
                      ),
                    )
                  else if (_earnedSummary != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.secondary,
                        borderRadius: BorderRadius.circular(14),
                        border:
                            Border.all(color: AppTheme.primary.withOpacity(0.08)),
                      ),
                      child: Column(
                        children: [
                          _paymentInfoRow(
                            'Employee',
                            _selectedEmployee!.employeeName ??
                                'Employee #${_selectedEmployee!.employeeId}',
                          ),
                          const SizedBox(height: 12),
                          _paymentInfoRow(
                            'Total Earned',
                            'Rs ${formatAmount(((_earnedSummary!['total_earned'] as num?)?.toDouble() ?? 0))}',
                          ),
                          const SizedBox(height: 12),
                          _paymentInfoRow(
                            'Already Paid',
                            'Rs ${formatAmount(((_earnedSummary!['total_paid'] as num?)?.toDouble() ?? 0))}',
                          ),
                          const Divider(height: 24),
                          _paymentInfoRow(
                            'Remaining (Payable)',
                            'Rs ${formatAmount(_remainingAmount)}',
                            isBold: true,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ==================================================
                    // AMOUNT TO PAY
                    // ==================================================
                    TextFormField(
                      controller: _amountToPayCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Amount to Pay',
                        hintText: 'Enter amount',
                        prefixText: 'Rs. ',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.payments_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter amount';
                        }
                        final amount =
                            double.tryParse(value.trim().replaceAll(',', ''));
                        if (amount == null) return 'Please enter a valid amount';
                        if (amount <= 0) return 'Amount must be greater than 0';
                        if (amount > _remainingAmount) {
                          return 'Amount cannot exceed Rs ${formatAmount(_remainingAmount)}';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    // ==================================================
                    // SAVE
                    // ==================================================
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: AppTheme.secondary,
                          shape:
                              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Save Payment',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}