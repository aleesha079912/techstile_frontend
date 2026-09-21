import 'package:flutter/material.dart';
import 'package:techstile_frontend/core/services/payments_service.dart';
import 'package:techstile_frontend/core/utils/theme.dart';
import 'package:techstile_frontend/screens/app_Owner_dashboard/factory_owner_dash/paymentsScreen.dart';

class ViewPaymentsPage extends StatefulWidget {
  final int factoryId;

  const ViewPaymentsPage({
    super.key,
    required this.factoryId,
  });

  @override
  State<ViewPaymentsPage> createState() => _ViewPaymentsPageState();
}

class _ViewPaymentsPageState extends State<ViewPaymentsPage> {
  final PaymentService _paymentService = PaymentService();
  late Future<Map<String, dynamic>> _paymentsFuture;

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  void _loadPayments() {
    setState(() {
      _paymentsFuture = _paymentService.fetchAllPayments(widget.factoryId);
    });
  }

  // ==========================================================
  // EDIT PAYMENT
  // No more `sheetContext` — this page owns its own context now,
  // and there's no outer bottom sheet to pop when we're done.
  // ==========================================================
  void _showEditPaymentDialog(
    BuildContext context,
    Map<String, dynamic> payment,
  ) {
    final paymentId = int.tryParse(payment['id'].toString()) ?? 0;
    final currentAmount =
        double.tryParse(payment['amount_paid'].toString()) ?? 0;

    final editFormKey = GlobalKey<FormState>();
    final editAmountCtrl = TextEditingController(
      text: currentAmount.toStringAsFixed(0),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (editSheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(editSheetContext).viewInsets.bottom + 20,
          ),
          child: Form(
            key: editFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Edit Payment',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: editAmountCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Amount Paid',
                    hintText: 'Enter amount',
                    prefixText: 'Rs. ',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.payments_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter amount';
                    }
                    final amount = double.tryParse(
                      value.trim().replaceAll(',', ''),
                    );
                    if (amount == null) {
                      return 'Please enter a valid amount';
                    }
                    if (amount <= 0) {
                      return 'Amount must be greater than 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (!editFormKey.currentState!.validate()) {
                        return;
                      }

                      final newAmount = double.parse(
                        editAmountCtrl.text.trim().replaceAll(',', ''),
                      );

                      showDialog(
                        context: editSheetContext,
                        barrierDismissible: false,
                        builder: (_) =>
                            const Center(child: CircularProgressIndicator()),
                      );

                      try {
                        await _paymentService.updatePayment(
                          paymentId: paymentId,
                          amountPaid: newAmount,
                        );

                        Navigator.pop(editSheetContext); // loading dialog
                        Navigator.pop(editSheetContext); // edit sheet

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Payment updated successfully'),
                            backgroundColor: Colors.green,
                          ),
                        );

                        _loadPayments(); // refresh this page's list
                      } catch (e) {
                        Navigator.pop(editSheetContext); // loading dialog

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to update payment: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Update Payment',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==========================================================
  // DELETE PAYMENT
  // Moved over from PaymentsScreen since this page now owns the list.
  // ==========================================================
  void _confirmDeletePayment(BuildContext context, int paymentId) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Payment'),
          content: const Text(
            'Are you sure you want to delete this payment record?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext); // confirm dialog

                try {
                  await _paymentService.deletePayment(paymentId);

                  if (!mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Payment deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );

                  _loadPayments(); // refresh this page's list
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete payment: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: AppTheme.error),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment History'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: FutureBuilder<Map<String, dynamic>>(
            future: _paymentsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.primary,
                  ),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Failed to load payments: ${snapshot.error}',
                    style: const TextStyle(color: AppTheme.error),
                  ),
                );
              }

              final List list = snapshot.data?['data'] as List? ?? [];

              if (list.isEmpty) {
                return const Center(
                  child: Text(
                    'No payments recorded yet',
                    style: TextStyle(color: AppTheme.primary),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async => _loadPayments(),
                child: ListView.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const Divider(height: 20),
                  itemBuilder: (context, index) {
                    final payment = list[index] as Map<String, dynamic>;

                    final employeeName =
                        payment['employee']?['user']?['name'] ??
                            'Employee #${payment['employee_id']}';
                    final amountPaid =
                        double.tryParse(payment['amount_paid'].toString()) ??
                            0;
                    final createdAt = payment['created_at']?.toString() ?? '';
                    final batchId =
                        payment['production']?['batch_id']?.toString();

                    final paymentId =
                        int.tryParse(payment['id'].toString()) ?? 0;

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.receipt_long_rounded,
                          color: AppTheme.primary,
                          size: 18,
                        ),
                      ),
                      title: Text(
                        employeeName,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        batchId != null
                            ? 'Batch: $batchId  •  $createdAt'
                            : createdAt,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppTheme.primary.withOpacity(0.55),
                          fontSize: 11,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'Rs ${formatAmount(amountPaid)}',
                                style: const TextStyle(
                                  color: AppTheme.success,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () =>
                                _showEditPaymentDialog(context, payment),
                            child: const Padding(
                              padding: EdgeInsets.all(6),
                              child: Icon(
                                Icons.edit_outlined,
                                color: AppTheme.primary,
                                size: 20,
                              ),
                            ),
                          ),
                          InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () =>
                                _confirmDeletePayment(context, paymentId),
                            child: const Padding(
                              padding: EdgeInsets.all(6),
                              child: Icon(
                                Icons.delete_outline_rounded,
                                color: AppTheme.error,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}