import 'package:flutter/material.dart';
import 'package:techstile_frontend/core/services/auth_service.dart';
import 'package:techstile_frontend/core/services/payments_service.dart';
import 'package:techstile_frontend/core/utils/theme.dart';
import 'package:techstile_frontend/widgets/bottom_nav_bar.dart';
import 'package:techstile_frontend/widgets/own_payments_pop_up.dart';

// ============================================================
// Models (employee-wise payments API response)
// ============================================================
//
// {
//   "data": [
//     {
//       "employee_id": 15,
//       "employee_name": "Ali",
//       "factory_name": "Ansari Textile",
//       "manager_name": null,
//       "total_amount": 1810400,
//       "total_length": 24970,
//       "machines": [
//         {
//           "machine_id": 2, "machine_name": "MC-02", "production_count": 3,
//           "total_length": 900, "ready_production": 0, "waste_production": 0,
//           "remaining_production": 900, "total_amount": 90000,
//           "productions": [
//             { "production_id": 137, "batch_id": "BATCH-14-...", "variety_type": "cotton",
//               "total_length": 300, "ready_production": 0, "waste_production": 0,
//               "remaining_production": 300, "amount_per_meter": 100,
//               "amount": 30000, "select_days": "Friday", "shift_start": "08:00:00",
//               "shift_end": "20:00:00", "created_at": "..." },
//             ...
//           ]
//         },
//         ...
//       ]
//     },
//     ...
//   ]
// }

class EmployeePayment {
  final int employeeId;
  final String? employeeName;
  final String? factoryName;
  final String? managerName;
  final double totalExpected;
  final double totalAmount;
  final double totalLength;
  final List<MachineGroup> machines;
  final double totalEarned;
  final double totalPaid;
  final double remainingAmount;

  EmployeePayment({
    required this.employeeId,
    required this.employeeName,
    this.factoryName,
    this.managerName,
    required this.totalExpected,
    required this.totalAmount,
    required this.totalLength,
    required this.machines,
    required this.totalEarned,
    required this.totalPaid,
    required this.remainingAmount,
  });

  double get readyProductionTotal => machines
      .expand((m) => m.productions)
      .fold<double>(0, (sum, p) => sum + p.readyProduction);

  double get readyAmount => machines
      .expand((m) => m.productions)
      .fold<double>(0, (sum, p) => sum + (p.readyProduction * p.amountPerMeter));

  factory EmployeePayment.fromJson(Map<String, dynamic> json) {
    return EmployeePayment(
      employeeId: int.tryParse(json['employee_id'].toString()) ?? 0,
      employeeName: json['employee_name'],
      factoryName: json['factory_name'],
      managerName: json['manager_name'],

      totalExpected:
          double.tryParse(json['total_expected'].toString()) ?? 0,

      totalAmount:
          double.tryParse(json['total_amount'].toString()) ?? 0,

      totalEarned:
          double.tryParse(json['total_earned'].toString()) ?? 0,

      totalPaid:
          double.tryParse(json['total_paid'].toString()) ?? 0,

      remainingAmount:
          double.tryParse(json['remaining_amount'].toString()) ?? 0,

      totalLength:
          double.tryParse(json['total_length'].toString()) ?? 0,

      machines: (json['machines'] as List? ?? [])
          .map((e) => MachineGroup.fromJson(e))
          .toList(),
    );
  }
}

class MachineGroup {
  final int? machineId;
  final String machineName;
  final int productionCount;
  final double totalLength;
  final double readyProduction;
  final double wasteProduction;
  final double remainingProduction;
  final double expectedAmount;
  final double earnedAmount;
  final double totalAmount;
  final List<ProductionRecord> productions;

  MachineGroup({
    required this.machineId,
    required this.machineName,
    required this.productionCount,
    required this.totalLength,
    required this.readyProduction,
    required this.wasteProduction,
    required this.remainingProduction,
    required this.expectedAmount,
    required this.earnedAmount,
    required this.totalAmount,
    required this.productions,
  });

  factory MachineGroup.fromJson(Map<String, dynamic> json) {
    final exp = double.tryParse(json['expected_amount'].toString()) ?? 0;
    final earn = double.tryParse(json['earned_amount'].toString()) ??
        double.tryParse(json['total_amount'].toString()) ??
        0;

    return MachineGroup(
      machineId: json['machine_id'] != null
          ? int.tryParse(json['machine_id'].toString())
          : null,
      machineName: json['machine_name'] ?? 'Unassigned',
      productionCount: int.tryParse(json['production_count'].toString()) ?? 0,
      totalLength: double.tryParse(json['total_length'].toString()) ?? 0,
      readyProduction: double.tryParse(json['ready_production'].toString()) ?? 0,
      wasteProduction: double.tryParse(json['waste_production'].toString()) ?? 0,
      remainingProduction:
          double.tryParse(json['remaining_production'].toString()) ?? 0,
      expectedAmount: exp,
      earnedAmount: earn,
      totalAmount: earn,
      productions: (json['productions'] as List? ?? [])
          .map((e) => ProductionRecord.fromJson(e))
          .toList(),
    );
  }
}

class ProductionRecord {
  final int productionId;
  final String batchId;
  final String varietyType;
  final int status;
  final double totalLength;
  final int readyProduction;
  final double wasteProduction;
  final double remainingProduction;
  final String? machineName;
  final double amountPerMeter;
  final double expectedAmount;
  final double earnedAmount;
  final double amount;
  final String? selectDays;
  final String? shiftStart;
  final String? shiftEnd;
  final String? createdAt;

  ProductionRecord({
    required this.productionId,
    required this.batchId,
    required this.varietyType,
    required this.status,
    required this.totalLength,
    required this.readyProduction,
    required this.wasteProduction,
    required this.remainingProduction,
    this.machineName,
    required this.amountPerMeter,
    required this.expectedAmount,
    required this.earnedAmount,
    required this.amount,
    this.selectDays,
    this.shiftStart,
    this.shiftEnd,
    this.createdAt,
  });

  factory ProductionRecord.fromJson(Map<String, dynamic> json) {
    final tLen = double.tryParse(json['total_length'].toString()) ?? 0;
    final rate = double.tryParse(json['amount_per_meter'].toString()) ?? 0;
    final exp = double.tryParse(json['expected_amount'].toString()) ?? (tLen * rate);
    final earn = double.tryParse(json['earned_amount'].toString()) ??
        double.tryParse(json['amount'].toString()) ??
        0;

    return ProductionRecord(
      productionId: int.tryParse(json['production_id'].toString()) ?? 0,
      batchId: json['batch_id'] ?? '',
      varietyType: json['variety_type'] ?? '',
      status: int.tryParse(json['status'].toString()) ?? 1,
      totalLength: tLen,
      readyProduction: int.tryParse(json['ready_production'].toString()) ?? 0,
      wasteProduction: double.tryParse(json['waste_production'].toString()) ?? 0,
      remainingProduction:
          double.tryParse(json['remaining_production'].toString()) ?? 0,
      machineName: json['machine_name'],
      amountPerMeter: rate,
      expectedAmount: exp,
      earnedAmount: earn,
      amount: earn,
      selectDays: json['select_days'],
      shiftStart: json['shift_start'],
      shiftEnd: json['shift_end'],
      createdAt: json['created_at'],
    );
  }
}

class PaymentsScreen extends StatefulWidget {
  final int factoryId;

  const PaymentsScreen({
    super.key,
    required this.factoryId,
  });

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class Employee {
  final int id;
  final String name;
  final double totalProduction;
  final double readyProduction;
  final double amountToBePaid;

  Employee({
    required this.id,
    required this.name,
    required this.totalProduction,
    required this.readyProduction,
    required this.amountToBePaid,
  });
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  final PaymentService _paymentService = PaymentService();
  bool get _canManagePayments {
    final role = AuthService.role.toLowerCase().trim();

    return role != 'employee' && role != 'manager';
  }



  List<EmployeePayment> _employees = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchPayments();
  }

  Widget _paymentInfoRow(
    String title,
    String value, {
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.grey.shade700,
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

  void _showAddPaymentDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final amountToPayCtrl = TextEditingController();

    EmployeePayment? selectedEmployee;

    bool isLoadingSummary = false;
    Map<String, dynamic>? earnedSummary; 
    String? summaryError;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            Future<void> loadSummary(EmployeePayment employee) async {
              setSheetState(() {
                isLoadingSummary = true;
                summaryError = null;
                earnedSummary = null;
              });

              try {
                final data =
                    await _paymentService.getEarnedAmount(employee.employeeId);
                setSheetState(() {
                  earnedSummary = data;
                  final remaining = (data['remaining'] as num?)?.toDouble() ?? 0;
                  amountToPayCtrl.text =
                      remaining > 0 ? remaining.toStringAsFixed(0) : '';
                });
              } catch (e) {
                setSheetState(() {
                  summaryError = 'Could not load earned amount';
                });
              } finally {
                setSheetState(() {
                  isLoadingSummary = false;
                });
              }
            }

            final remainingAmount =
                (earnedSummary?['remaining'] as num?)?.toDouble() ?? 0.0;

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Add Payment',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ==================================================
                      // EMPLOYEE SELECT
                      // ==================================================
                      DropdownButtonFormField<EmployeePayment>(
                        value: selectedEmployee,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Select Employee',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        items: _employees.map((employee) {
                          final name = employee.employeeName?.trim().isNotEmpty == true
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
                          setSheetState(() {
                            selectedEmployee = employee;
                            earnedSummary = null;
                            summaryError = null;
                            amountToPayCtrl.clear();
                          });
                          if (employee != null) {
                            loadSummary(employee);
                          }
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select an employee';
                          }
                          return null;
                        },
                      ),

                      // ==================================================
                      // EARNED SUMMARY (✅ replaces production select)
                      // ==================================================
                      if (selectedEmployee != null) ...[
                        const SizedBox(height: 20),

                        if (isLoadingSummary)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: LinearProgressIndicator(minHeight: 3),
                          )
                        else if (summaryError != null)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.red.withOpacity(0.3)),
                            ),
                            child: Text(
                              summaryError!,
                              style: const TextStyle(fontSize: 12, color: Colors.red),
                            ),
                          )
                        else if (earnedSummary != null) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.background,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: AppTheme.primary.withOpacity(0.08),
                              ),
                            ),
                            child: Column(
                              children: [
                                _paymentInfoRow(
                                  'Employee',
                                  selectedEmployee!.employeeName ??
                                      'Employee #${selectedEmployee!.employeeId}',
                                ),
                                const SizedBox(height: 12),
                                _paymentInfoRow(
                                  'Total Earned',
                                  'Rs ${_formatAmount(((earnedSummary!['total_earned'] as num?)?.toDouble() ?? 0))}',
                                ),
                                const SizedBox(height: 12),
                                _paymentInfoRow(
                                  'Already Paid',
                                  'Rs ${_formatAmount(((earnedSummary!['total_paid'] as num?)?.toDouble() ?? 0))}',
                                ),
                                const Divider(height: 24),
                                _paymentInfoRow(
                                  'Remaining (Payable)',
                                  'Rs ${_formatAmount(remainingAmount)}',
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
                            controller: amountToPayCtrl,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
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

                              if (amount == null) {
                                return 'Please enter a valid amount';
                              }

                              if (amount <= 0) {
                                return 'Amount must be greater than 0';
                              }

                              if (amount > remainingAmount) {
                                return 'Amount cannot exceed Rs ${_formatAmount(remainingAmount)}';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 20),

                          // ==================================================
                          // SAVE
                          // ==================================================
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () async {
                                if (!formKey.currentState!.validate()) {
                                  return;
                                }

                                final employee = selectedEmployee!;

                                final amount = double.parse(
                                  amountToPayCtrl.text.trim().replaceAll(',', ''),
                                );

                                debugPrint('Employee ID: ${employee.employeeId}');
                                debugPrint('Amount Paying Now: $amount');

                                // ✅ Loading indicator
                                showDialog(
                                  context: sheetContext,
                                  barrierDismissible: false,
                                  builder: (_) => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );

                                try {
                                  await _paymentService.addPayment(
                                    employeeId: employee.employeeId,
                                    amountPaid: amount,
                                  );

                                  Navigator.pop(sheetContext); // loading band
                                  Navigator.pop(sheetContext); // bottom sheet band

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Payment saved successfully'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );

                                  _fetchPayments(); // list refresh
                                } catch (e) {
                                  Navigator.pop(sheetContext); // loading band

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Failed to save payment: $e'),
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
            );
          },
        );
      },
    );
  }

  
  Widget _buildFPB(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppTheme.softShadow,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          _showAddPaymentDialog(context);
        },
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_rounded, color: AppTheme.secondary, size: 20),
              SizedBox(width: 6),
              Text(
                "Add Payments",
                style: TextStyle(
                  color: AppTheme.secondary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

    Widget _buildViewPaymentsButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppTheme.softShadow,
        border: Border.all(color: AppTheme.primary.withOpacity(0.15)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          _showViewPaymentsDialog(context);
        },
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.visibility_outlined, color: AppTheme.primary, size: 20),
              SizedBox(width: 6),
              Text(
                "View Payments",
                style: TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  void _confirmDeletePayment(
    BuildContext context,
    BuildContext sheetContext,
    int paymentId,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Payment'),
          content: const Text('Are you sure you want to delete this payment record?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext); // confirm dialog band

                try {
                  await _paymentService.deletePayment(paymentId);

                  Navigator.pop(sheetContext); // payment history sheet band

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Payment deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );

                  _fetchPayments(); // main list refresh
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete payment: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Delete', style: TextStyle(color: AppTheme.error)),
            ),
          ],
        );
      },
    );
  }

    void _showEditPaymentDialog(
    BuildContext context,
    BuildContext sheetContext,
    Map<String, dynamic> payment,
  ) {
    final paymentId = int.tryParse(payment['id'].toString()) ?? 0;
    final currentAmount =
        double.tryParse(payment['amount_paid'].toString()) ?? 0;

    final editFormKey = GlobalKey<FormState>();
    final editAmountCtrl =
        TextEditingController(text: currentAmount.toStringAsFixed(0));

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
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                    final amount = double.tryParse(value.trim().replaceAll(',', ''));
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
                        builder: (_) => const Center(child: CircularProgressIndicator()),
                      );

                      try {
                        await _paymentService.updatePayment(
                          paymentId: paymentId,
                          amountPaid: newAmount,
                        );

                        Navigator.pop(editSheetContext); // loading band
                        Navigator.pop(editSheetContext); // edit sheet band
                        Navigator.pop(sheetContext); // payment history sheet band

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Payment updated successfully'),
                            backgroundColor: Colors.green,
                          ),
                        );

                        _fetchPayments(); // main list refresh
                      } catch (e) {
                        Navigator.pop(editSheetContext); // loading band

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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      'Update Payment',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
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



  void _showViewPaymentsDialog(BuildContext context) {
     showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (sheetContext) {
        return FutureBuilder<Map<String, dynamic>>(
          future: _paymentService.fetchAllPayments(widget.factoryId), // ✅ service mein add karna hoga
          builder: (context, snapshot) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
              ),
              child: SizedBox(
                height: MediaQuery.of(sheetContext).size.height * 0.7,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Payment History',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Builder(
                        builder: (_) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(color: AppTheme.primary),
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

                          return ListView.separated(
                            itemCount: list.length,
                            separatorBuilder: (_, __) => const Divider(height: 20),
                            itemBuilder: (context, index) {
                              final payment = list[index] as Map<String, dynamic>;

                              final employeeName = payment['employee']?['user']?['name'] ??
                              'Employee #${payment['employee_id']}';
                              final amountPaid =
                              double.tryParse(payment['amount_paid'].toString()) ?? 0;
                              final createdAt = payment['created_at']?.toString() ?? '';
                              final batchId =
                              payment['production']?['batch_id']?.toString();

                              final paymentId = int.tryParse(payment['id'].toString()) ?? 0;

                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Container(
                                  padding: const EdgeInsets.all(9),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.receipt_long_rounded,
                                      color: AppTheme.primary, size: 18),
                                ),
                                title: Text(
                                  employeeName,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700, fontSize: 14),
                                ),
                                subtitle: Text(
                                  batchId != null
                                      ? 'Batch: $batchId  •  $createdAt'
                                      : createdAt,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: AppTheme.primary.withOpacity(0.55),
                                      fontSize: 11),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          'Rs ${_formatAmount(amountPaid)}',
                                          style: const TextStyle(
                                              color: AppTheme.success,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w800),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    InkWell(
                                      borderRadius: BorderRadius.circular(20),
                                      onTap: () => _showEditPaymentDialog(
                                        context,
                                        sheetContext,
                                        payment,
                                      ),
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
                                      onTap: () => _confirmDeletePayment(
                                        context,
                                        sheetContext,
                                        paymentId,
                                      ),
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
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
  Future<void> _fetchPayments() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // PaymentService just needs to hit the employee-wise endpoint and
      // return the decoded JSON body (e.g. Dio's `response.data` or
      // `jsonDecode(response.body)`), a Map like: { "data": [ {...}, ... ] }.
      // All parsing into EmployeePayment happens right here, so no separate
      // model file is required.
      final raw = await _paymentService.fetchvarietytypePayments(widget.factoryId);
      final List list = raw['data'] as List? ?? [];
      final data = list
          .map((e) => EmployeePayment.fromJson(e as Map<String, dynamic>))
          .toList();

      setState(() {
        _employees = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        // _error = 'Failed to load payments: $e';
        _error = 'you are allowed to see your own factory';
        _isLoading = false;
      });
    }
  }

  // Grand totals across all employees.
  double get _grandTotalAmount =>
      _employees.fold(0, (sum, e) => sum + e.totalAmount);

  double get _grandTotalLength =>
      _employees.fold(0, (sum, e) => sum + e.totalLength);

  double get _overallRatePerMeter =>
      _grandTotalLength == 0 ? 0 : _grandTotalAmount / _grandTotalLength;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        automaticallyImplyLeading: false,
        elevation: 0,
        title: const Text(
          'Employee Payments',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 17),
        ),
      
      ),
      body: _buildBody(),
      floatingActionButton: _canManagePayments
    ? Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildViewPaymentsButton(context),
          const SizedBox(height: 12),
          _buildFPB(context),
        ],
      )
      : null,

       bottomNavigationBar: CustomBottomNav(    
        currentIndex: 2,
        factoryId: widget.factoryId,
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
    }

    if (_error != null) {
      return _errorView();
    }

    return RefreshIndicator(
      color: AppTheme.primary,
      onRefresh: _fetchPayments,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          // ---- Overall summary card ----
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: AppTheme.cardRadius,
              boxShadow: AppTheme.softShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: AppTheme.secondary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.payments_rounded,
                          color: AppTheme.secondary, size: 18),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Total Payment (All Employees)',
                        style: TextStyle(color: AppTheme.secondary, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Rs ${_formatAmount(_grandTotalAmount)}',
                  style: const TextStyle(
                    color: AppTheme.secondary,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    _SummaryStat(
                      label: 'Total Length',
                      value: '${_formatAmount(_grandTotalLength)} m',
                    ),
                    const SizedBox(width: 8),
                    _SummaryStat(
                      label: 'Avg Rate / m',
                      value: 'Rs ${_overallRatePerMeter.toStringAsFixed(1)}',
                    ),
                    const SizedBox(width: 8),
                    _SummaryStat(
                      label: 'Employees',
                      value: '${_employees.length}',
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              const Text(
                'Employee Wise Calculation',
                style: TextStyle(
                    color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_employees.length}',
                  style: const TextStyle(
                      color: AppTheme.primary, fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (_employees.isEmpty)
            _emptyView()
          else
          ...List.generate(_employees.length, (index) {
            final employee = _employees[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _EmployeePaymentTile(record: employee),
            );
          }),
        ],
      ),
    );
  }

  Widget _emptyView() => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const SizedBox(height: 28),
      Icon(Icons.inbox_rounded, size: 52, color: AppTheme.neutral),
      const SizedBox(height: 12),
      const Text('No employee payments found',
          style: TextStyle(color: AppTheme.primary, fontSize: 14, fontWeight: FontWeight.w600)),
    ]),
  );

  Widget _errorView() => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.error_outline_rounded, size: 48, color: AppTheme.error),
      const SizedBox(height: 12),
      Text(_error ?? 'Something went wrong',
          style: const TextStyle(color: AppTheme.primary)),
      const SizedBox(height: 16),
      ElevatedButton(onPressed: _fetchPayments, child: const Text('Retry')),
    ]),
  );
}

// ============================================================
// Helpers
// ============================================================

String _formatAmount(double value) {
  final str = value.toStringAsFixed(0);
  final buffer = StringBuffer();
  final reversed = str.split('').reversed.toList();
  for (int i = 0; i < reversed.length; i++) {
    buffer.write(reversed[i]);
    final posFromEnd = i + 1;
    if (posFromEnd % 3 == 0 && posFromEnd != reversed.length) {
      buffer.write(',');
    }
  }
  return buffer.toString().split('').reversed.join('');
}
// Small presentational widget

class _SummaryStat extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 7),
        decoration: BoxDecoration(
          color: AppTheme.secondary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.secondary.withOpacity(0.10)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(color: AppTheme.secondary, fontSize: 9, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                maxLines: 1,
                style: const TextStyle(
                  color: AppTheme.secondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Expandable card for a single employee: header shows name + total earned,
/// plus factory/manager context, and expands to a list of every machine
/// that contributed to that total.
///
/// FIX: previously this had BOTH a boxed Earned/Paid/Remaining row inside
/// `subtitle` AND a duplicate unwrapped three-line `trailing` column. The
/// `trailing` slot of a ListTile/ExpansionTile is laid out at its intrinsic
/// width (it is NOT wrapped in an Expanded like `subtitle` is), so three
/// long unbounded strings like "Remaining: Rs 1,810,400" forced the row
/// wider than the screen on smaller devices -> RenderFlex overflow
/// (the black/yellow striped error). The duplicate trailing column has been
/// removed and long text in title/subtitle is now clamped with
/// `overflow: TextOverflow.ellipsis` so the tile can never overflow again.
class _EmployeePaymentTile extends StatelessWidget {
  final EmployeePayment record;
  Widget _employeeAmountStat(
  String label,
  double amount,
  Color color,
) {
  return Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 7,
      vertical: 6,
    ),
    decoration: BoxDecoration(
      color: color.withOpacity(0.06),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: color.withOpacity(0.10),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: color.withOpacity(0.65),
            fontSize: 9,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            'Rs ${_formatAmount(amount)}',
            maxLines: 1,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    ),
  );
}


  const _EmployeePaymentTile({required this.record});

  @override
  Widget build(BuildContext context) {
    final displayName = (record.employeeName == null || record.employeeName!.isEmpty)
        ? 'Employee #${record.employeeId}'
        : record.employeeName!;

    // Build the subtitle line dynamically so it still looks clean when
    // factory_name / manager_name are null.
    final subtitleParts = <String>[
      '${record.machines.length} machine${record.machines.length == 1 ? '' : 's'}',
      '${_formatAmount(record.totalLength)} m',
    ];
    if (record.factoryName != null && record.factoryName!.isNotEmpty) {
      subtitleParts.add(record.factoryName!);
    }

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.secondary,
        borderRadius: AppTheme.cardRadius,
        boxShadow: AppTheme.softShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        // Kill the default divider ExpansionTile draws.
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.all(16),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.person_rounded, color: AppTheme.primary, size: 18),
          ),
          title: Text(
            displayName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 14),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subtitleParts.join(' • '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppTheme.primary.withOpacity(0.55),
                    fontSize: 11,
                  ),
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(
                      child: _employeeAmountStat(
                        'Earned',
                        record.totalEarned,
                        AppTheme.primary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _employeeAmountStat(
                        'Paid',
                        record.totalPaid,
                        AppTheme.success,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _employeeAmountStat(
                        'Remaining',
                        record.remainingAmount,
                        record.remainingAmount > 0
                            ? AppTheme.error
                            : AppTheme.success,
                      ),
                    ),
                  ],
                ),

                if (record.managerName != null &&
                    record.managerName!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Manager: ${record.managerName}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppTheme.primary.withOpacity(0.45),
                        fontSize: 10.5,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Duplicate Earned/Paid/Remaining trailing column removed — it was
          // unbounded and caused the overflow. The stat boxes in `subtitle`
          // already surface this info without needing to expand the tile.
          // If you want a compact indicator here, keep it width-bounded, e.g.:
          // trailing: const Icon(Icons.expand_more_rounded, color: AppTheme.primary),
          children: [
            if (record.machines.isEmpty)
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text('No machine records',
                    style: TextStyle(color: AppTheme.textPrimary, fontSize: 12)),
              )
            else
              ...record.machines.map((m) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _MachineGroupTile(machine: m),
              )),
          ],
        ),
      ),
    );
  }
} 

/// One machine's aggregated totals for this employee. Expands to show
/// the individual production rows that make up the total.
class _MachineGroupTile extends StatelessWidget {
  final MachineGroup machine;

  const _MachineGroupTile({required this.machine});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.primary.withOpacity(0.06)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          title: Text(
            machine.machineName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w700),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '${machine.productionCount} batch${machine.productionCount == 1 ? '' : 'es'} • ${_formatAmount(machine.totalLength)} m',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: AppTheme.primary.withOpacity(0.55), fontSize: 11),
            ),
          ),
          trailing: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 110),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Earned',
                  style: TextStyle(
                    color: AppTheme.primary.withOpacity(0.5),
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Rs ${_formatAmount(machine.earnedAmount)}',
                    maxLines: 1,
                    style: const TextStyle(
                        color: AppTheme.success, fontSize: 12, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
          children: [
            // Row 1: Expected vs Earned Amount
            Row(
              children: [
                _machineStatBox(
                  'Expected Amount',
                  'Rs ${_formatAmount(machine.expectedAmount)}',
                  AppTheme.primary,
                ),
                const SizedBox(width: 6),
                _machineStatBox(
                  'Earned Amount',
                  'Rs ${_formatAmount(machine.earnedAmount)}',
                  AppTheme.success,
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Row 2: Ready, Waste, Remaining meters
            Row(
              children: [
                _machineMiniStat('Ready', '${_formatAmount(machine.readyProduction)} m'),
                const SizedBox(width: 6),
                _machineMiniStat('Waste', '${_formatAmount(machine.wasteProduction)} m'),
                const SizedBox(width: 6),
                _machineMiniStat('Remaining', '${_formatAmount(machine.remainingProduction)} m'),
              ],
            ),
            const SizedBox(height: 10),
            if (machine.productions.isEmpty)
              const Text('No production records',
                  style: TextStyle(color: AppTheme.textPrimary, fontSize: 12))
            else
              ...machine.productions.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _ProductionRow(record: p),
              )),
          ],
        ),
      ),
    );
  }

  Widget _machineStatBox(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.12)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: color.withOpacity(0.7),
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                maxLines: 1,
                style: TextStyle(
                  color: color,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _machineMiniStat(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  color: AppTheme.primary.withOpacity(0.5), fontSize: 9, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value,
                maxLines: 1,
                style: const TextStyle(
                    color: AppTheme.textPrimary, fontSize: 11, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

/// A single production entry. Tappable — opens a bottom sheet with the full
/// detail (machine, remaining production, shift, timestamps, etc).
class _ProductionRow extends StatelessWidget {
  final ProductionRecord record;

  const _ProductionRow({required this.record});

  String get _statusLabel {
    switch (record.status) {
      case 4:
        return 'Approved';
      case 5:
        return 'Rejected';
      case 2:
        return 'Mgr Approved';
      case 3:
        return 'Mgr Rejected';
      default:
        return 'Pending';
    }
  }

  Color get _statusColor {
    switch (record.status) {
      case 4:
        return AppTheme.success;
      case 5:
      case 3:
        return AppTheme.error;
      default:
        return const Color(0xFFF59E0B);
    }
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.secondary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Production #${record.productionId}',
                    style: const TextStyle(
                        color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _statusLabel,
                      style: TextStyle(
                        color: _statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                record.batchId.isEmpty ? 'No batch' : record.batchId,
                style: TextStyle(color: AppTheme.primary.withOpacity(0.55), fontSize: 12),
              ),
              const SizedBox(height: 16),
              _detailRow('Variety', record.varietyType),
              _detailRow('Machine', record.machineName ?? '—'),
              _detailRow('Total Length', '${_formatAmount(record.totalLength)} m'),
              _detailRow('Ready Production', '${record.readyProduction} m'),
              _detailRow('Waste Production', '${_formatAmount(record.wasteProduction)} m'),
              _detailRow('Remaining Production', '${_formatAmount(record.remainingProduction)} m'),
              _detailRow('Rate / meter', 'Rs ${record.amountPerMeter.toStringAsFixed(2)}'),
              _detailRow('Expected Amount', 'Rs ${_formatAmount(record.expectedAmount)}'),
              _detailRow('Earned Amount', 'Rs ${_formatAmount(record.earnedAmount)}'),
              if (record.selectDays != null && record.selectDays != 'null')
                _detailRow('Day', record.selectDays!),
              if (record.shiftStart != null)
                _detailRow('Shift', '${record.shiftStart} - ${record.shiftEnd}'),
              if (record.createdAt != null)
                _detailRow('Created', record.createdAt!),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: TextStyle(color: AppTheme.primary.withOpacity(0.6), fontSize: 12)),
          ),
          Flexible(
            child: Text(value,
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: AppTheme.textPrimary, fontSize: 12, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showDetail(context),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.primary.withOpacity(0.06)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${record.varietyType} • ${record.batchId}',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: AppTheme.textPrimary, fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _statusLabel,
                    style: TextStyle(
                      color: _statusColor,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Rs ${_formatAmount(record.earnedAmount)}',
                      style: TextStyle(
                          color: record.status == 4 ? AppTheme.success : AppTheme.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _miniStat('Length', '${_formatAmount(record.totalLength)} m'),
                const SizedBox(width: 6),
                _miniStat('Rate/m', 'Rs ${record.amountPerMeter.toStringAsFixed(2)}'),
                const SizedBox(width: 6),
                _miniStat('Ready', '${record.readyProduction} m'),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                _miniStat('Expected', 'Rs ${_formatAmount(record.expectedAmount)}'),
                const SizedBox(width: 6),
                _miniStat('Waste', '${_formatAmount(record.wasteProduction)} m'),
                const SizedBox(width: 6),
                _miniStat('Remaining', '${_formatAmount(record.remainingProduction)} m'),
              ],
            ),
            if (record.selectDays != null && record.selectDays!.isNotEmpty && record.selectDays != 'null') ...[
              const SizedBox(height: 6),
              Text(
                'Days: ${record.selectDays}',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: AppTheme.primary.withOpacity(0.5), fontSize: 10),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _miniStat(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  color: AppTheme.primary.withOpacity(0.5), fontSize: 9, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value,
                maxLines: 1,
                style: const TextStyle(
                    color: AppTheme.textPrimary, fontSize: 11, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}