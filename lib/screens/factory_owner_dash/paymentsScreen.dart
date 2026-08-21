import 'package:flutter/material.dart';
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
//       "productions": [
//         { "production_id": 137, "batch_id": "BATCH-14-...", "variety_type": "cotton",
//           "total_length": 300, "ready_production": 0, "waste_production": 0,
//           "remaining_production": 300, "machine_name": "MC-02", "amount_per_meter": 100,
//           "amount": 30000, "select_days": "Friday", "shift_start": "08:00:00",
//           "shift_end": "20:00:00", "created_at": "..." },
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
  final double totalAmount;
  final double totalLength;
  final List<ProductionRecord> productions;

  EmployeePayment({
    required this.employeeId,
    required this.employeeName,
    this.factoryName,
    this.managerName,
    required this.totalAmount,
    required this.totalLength,
    required this.productions,
  });

  factory EmployeePayment.fromJson(Map<String, dynamic> json) {
    return EmployeePayment(
      employeeId: int.tryParse(json['employee_id'].toString()) ?? 0,
      employeeName: json['employee_name'],
      factoryName: json['factory_name'],
      managerName: json['manager_name'],
      totalAmount: double.tryParse(json['total_amount'].toString()) ?? 0,
      totalLength: double.tryParse(json['total_length'].toString()) ?? 0,
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
  final double totalLength;
  final int readyProduction;
  final double wasteProduction;
  final double remainingProduction;
  final String? machineName;
  final double amountPerMeter;
  final double amount;
  final String? selectDays;
  final String? shiftStart;
  final String? shiftEnd;
  final String? createdAt;

  ProductionRecord({
    required this.productionId,
    required this.batchId,
    required this.varietyType,
    required this.totalLength,
    required this.readyProduction,
    required this.wasteProduction,
    required this.remainingProduction,
    this.machineName,
    required this.amountPerMeter,
    required this.amount,
    this.selectDays,
    this.shiftStart,
    this.shiftEnd,
    this.createdAt,
  });

  factory ProductionRecord.fromJson(Map<String, dynamic> json) {
    return ProductionRecord(
      productionId: int.tryParse(json['production_id'].toString()) ?? 0,
      batchId: json['batch_id'] ?? '',
      varietyType: json['variety_type'] ?? '',
      totalLength: double.tryParse(json['total_length'].toString()) ?? 0,
      readyProduction: int.tryParse(json['ready_production'].toString()) ?? 0,
      wasteProduction: double.tryParse(json['waste_production'].toString()) ?? 0,
      remainingProduction:
          double.tryParse(json['remaining_production'].toString()) ?? 0,
      machineName: json['machine_name'],
      amountPerMeter: double.tryParse(json['amount_per_meter'].toString()) ?? 0,
      amount: double.tryParse(json['amount'].toString()) ?? 0,
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
            // Calculate ready production from production records.
            final readyProduction = selectedEmployee?.productions.fold<double>(
                  0,
                  (sum, production) => sum + production.readyProduction,
                ) ??
                0;

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

                            // Don't force the user to pay the entire amount.
                            // Start with the maximum payable amount as a suggestion.
                            if (employee != null) {
                              amountToPayCtrl.text =
                                  employee.totalAmount.toStringAsFixed(0);
                            } else {
                              amountToPayCtrl.clear();
                            }
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select an employee';
                          }
                          return null;
                        },
                      ),

                      // ==================================================
                      // EMPLOYEE INFORMATION
                      // ==================================================
                      if (selectedEmployee != null) ...[
                        const SizedBox(height: 20),

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
                                'Total Production',
                                '${_formatAmount(selectedEmployee!.totalLength)} m',
                              ),

                              const SizedBox(height: 12),

                              _paymentInfoRow(
                                'Ready Production',
                                '${_formatAmount(readyProduction)} m',
                              ),

                              const Divider(height: 24),

                              _paymentInfoRow(
                                'Total Amount',
                                'Rs ${_formatAmount(selectedEmployee!.totalAmount)}',
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

                            final amount = double.tryParse(
                              value.trim().replaceAll(',', ''),
                            );

                            if (amount == null) {
                              return 'Please enter a valid amount';
                            }

                            if (amount <= 0) {
                              return 'Amount must be greater than 0';
                            }

                            if (selectedEmployee != null &&
                                amount > selectedEmployee!.totalAmount) {
                              return 'Amount cannot exceed Rs ${_formatAmount(selectedEmployee!.totalAmount)}';
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
                            onPressed: () {
                              if (!formKey.currentState!.validate()) {
                                return;
                              }

                              final employee = selectedEmployee!;

                              final amount = double.parse(
                                amountToPayCtrl.text
                                    .trim()
                                    .replaceAll(',', ''),
                              );

                              debugPrint(
                                'Employee ID: ${employee.employeeId}',
                              );

                              debugPrint(
                                'Employee Name: ${employee.employeeName}',
                              );

                              debugPrint(
                                'Total Production: ${employee.totalLength}',
                              );

                              debugPrint(
                                'Ready Production: $readyProduction',
                              );

                              debugPrint(
                                'Total Payable: ${employee.totalAmount}',
                              );

                              debugPrint(
                                'Amount Paying Now: $amount',
                              );

                              // TODO:
                              // Call your payment API here.
                              //
                              // Example:
                              // await _paymentService.createPayment(
                              //   employeeId: employee.employeeId,
                              //   amount: amount,
                              // );

                              Navigator.pop(sheetContext);
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
        // onTap: () {
        //   debugPrint('FAB tapped');
        //   showDialog(
        //     context: context,
        //     builder: (_) => AlertDialog(
        //       title: Text('Test'),
        //       content: Text('Dialog works'),
        //     ),
        //   );
        // },
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
        _error = 'Failed to load payments: $e';
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
        elevation: 0,
        title: const Text(
          'Employee Payments',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 17),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _buildBody(),
      floatingActionButton: _buildFPB(context),
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
                        style: TextStyle(color: AppTheme.surface, fontSize: 12, fontWeight: FontWeight.w600),
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

// ============================================================
// Small presentational widgets
// ============================================================

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
              style: TextStyle(color: AppTheme.surface.withOpacity(0.85), fontSize: 9, fontWeight: FontWeight.w600),
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
/// plus factory/manager context, and expands to a list of every production
/// row that makes up that total.
class _EmployeePaymentTile extends StatelessWidget {
  final EmployeePayment record;

  const _EmployeePaymentTile({required this.record});

  @override
  Widget build(BuildContext context) {
    final displayName = (record.employeeName == null || record.employeeName!.isEmpty)
        ? 'Employee #${record.employeeId}'
        : record.employeeName!;

    // Build the subtitle line dynamically so it still looks clean when
    // factory_name / manager_name are null.
    final subtitleParts = <String>[
      '${record.productions.length} production${record.productions.length == 1 ? '' : 's'}',
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
            style: const TextStyle(
                color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 14),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subtitleParts.join(' • '),
                  style: TextStyle(color: AppTheme.primary.withOpacity(0.55), fontSize: 11),
                ),
                if (record.managerName != null && record.managerName!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      'Manager: ${record.managerName}',
                      style: TextStyle(color: AppTheme.primary.withOpacity(0.45), fontSize: 10.5),
                    ),
                  ),
              ],
            ),
          ),
          trailing: Text(
            'Rs ${_formatAmount(record.totalAmount)}',
            style: const TextStyle(
                color: AppTheme.success, fontSize: 13, fontWeight: FontWeight.w800),
          ),
          children: [
            if (record.productions.isEmpty)
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text('No production records',
                    style: TextStyle(color: AppTheme.textPrimary, fontSize: 12)),
              )
            else
              ...record.productions.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ProductionRow(record: p),
              )),
          ],
        ),
      ),
    );
  }
}

/// A single production entry. Tappable — opens a bottom sheet with the full
/// detail (machine, remaining production, shift, timestamps, etc).
class _ProductionRow extends StatelessWidget {
  final ProductionRecord record;

  const _ProductionRow({required this.record});

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
              Text(
                'Production #${record.productionId}',
                style: const TextStyle(
                    color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w800),
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
              _detailRow('Amount', 'Rs ${_formatAmount(record.amount)}'),
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
          Text(value,
              style: const TextStyle(
                  color: AppTheme.textPrimary, fontSize: 12, fontWeight: FontWeight.w700)),
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
                Text(
                  'Rs ${_formatAmount(record.amount)}',
                  style: const TextStyle(
                      color: AppTheme.success, fontSize: 12, fontWeight: FontWeight.w800),
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
                _miniStat('Remaining', '${_formatAmount(record.remainingProduction)} m'),
                const SizedBox(width: 6),
                _miniStat('Waste', '${_formatAmount(record.wasteProduction)} m'),
                const SizedBox(width: 6),
                _miniStat('Machine', record.machineName ?? '—'),
              ],
            ),
            if (record.selectDays != null && record.selectDays!.isNotEmpty && record.selectDays != 'null') ...[
              const SizedBox(height: 6),
              Text(
                'Days: ${record.selectDays}',
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