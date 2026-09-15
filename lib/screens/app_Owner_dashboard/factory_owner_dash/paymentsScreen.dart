import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:techstile_frontend/core/services/auth_service.dart';
import 'package:techstile_frontend/core/services/payments_service.dart';
import 'package:techstile_frontend/core/utils/theme.dart';
import 'package:techstile_frontend/screens/app_Owner_dashboard/factory_owner_dash/addpayment.dart';
import 'package:techstile_frontend/screens/app_Owner_dashboard/factory_owner_dash/viewpayment.dart';
import 'package:techstile_frontend/widgets/bottom_nav_bar.dart';
import 'package:techstile_frontend/widgets/emp_db_bot_nav_bar.dart';
// Old bottom-sheet popup widget is no longer used — replaced by full pages:
// import 'package:techstile_frontend/widgets/own_payments_pop_up.dart';
// NOTE: adjust these two import paths to wherever you actually saved the files.

/// A single payment entry (date + amount), as recorded in the Payments table.
class PaymentEntry {
  final double amountPaid;
  final String? paidDate;

  PaymentEntry({required this.amountPaid, this.paidDate});

  factory PaymentEntry.fromJson(Map<String, dynamic> json) {
    return PaymentEntry(
      amountPaid: double.tryParse(json['amount_paid'].toString()) ?? 0,
      paidDate: json['paid_date']?.toString(),
    );
  }
}

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
  final List<PaymentEntry> paymentHistory;

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
    required this.paymentHistory,
  });

  double get readyProductionTotal => machines
      .expand((m) => m.productions)
      .fold<double>(0, (sum, p) => sum + p.readyProduction);

  double get readyAmount => machines
      .expand((m) => m.productions)
      .fold<double>(
        0,
        (sum, p) => sum + (p.readyProduction * p.amountPerMeter),
      );

  factory EmployeePayment.fromJson(Map<String, dynamic> json) {
    return EmployeePayment(
      employeeId: int.tryParse(json['employee_id'].toString()) ?? 0,
      employeeName: json['employee_name'],
      factoryName: json['factory_name'],
      managerName: json['manager_name'],

      totalExpected: double.tryParse(json['total_expected'].toString()) ?? 0,

      totalAmount: double.tryParse(json['total_amount'].toString()) ?? 0,

      totalEarned: double.tryParse(json['total_earned'].toString()) ?? 0,

      totalPaid: double.tryParse(json['total_paid'].toString()) ?? 0,

      remainingAmount:
          double.tryParse(json['remaining_amount'].toString()) ?? 0,

      totalLength: double.tryParse(json['total_length'].toString()) ?? 0,

      machines: (json['machines'] as List? ?? [])
          .map((e) => MachineGroup.fromJson(e))
          .toList(),

      paymentHistory: (json['payment_history'] as List? ?? [])
          .map((e) => PaymentEntry.fromJson(e as Map<String, dynamic>))
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
    final earn =
        double.tryParse(json['earned_amount'].toString()) ??
        double.tryParse(json['total_amount'].toString()) ??
        0;

    return MachineGroup(
      machineId: json['machine_id'] != null
          ? int.tryParse(json['machine_id'].toString())
          : null,
      machineName: json['machine_name'] ?? 'Unassigned',
      productionCount: int.tryParse(json['production_count'].toString()) ?? 0,
      totalLength: double.tryParse(json['total_length'].toString()) ?? 0,
      readyProduction:
          double.tryParse(json['ready_production'].toString()) ?? 0,
      wasteProduction:
          double.tryParse(json['waste_production'].toString()) ?? 0,
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
    final exp =
        double.tryParse(json['expected_amount'].toString()) ?? (tLen * rate);
    final earn =
        double.tryParse(json['earned_amount'].toString()) ??
        double.tryParse(json['amount'].toString()) ??
        0;

    return ProductionRecord(
      productionId: int.tryParse(json['production_id'].toString()) ?? 0,
      batchId: json['batch_id'] ?? '',
      varietyType: json['variety_type'] ?? '',
      status: int.tryParse(json['status'].toString()) ?? 1,
      totalLength: tLen,
      readyProduction: int.tryParse(json['ready_production'].toString()) ?? 0,
      wasteProduction:
          double.tryParse(json['waste_production'].toString()) ?? 0,
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
  final int? initialEmployeeId;

  const PaymentsScreen({
    super.key,
    required this.factoryId,
    this.initialEmployeeId,
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
  String? _factoryName;

  @override
  void initState() {
    super.initState();
    _fetchPayments();
    _loadFactoryName();
  }

  Future<void> _loadFactoryName() async {
    try {
      final response = await http.get(
        Uri.parse(
          "http://localhost:8000/api/factories/editfactory/${widget.factoryId}",
        ),
        headers: AuthService.authHeaders,
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (mounted) {
          setState(() => _factoryName = body['data']?['name']);
        }
      }
    } catch (_) {}
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

  // ==========================================================
  // NAVIGATION: Add Payment
  // Replaces the old _showAddPaymentDialog bottom sheet. Pushes
  // AddPaymentPage and refreshes the employee list if a payment
  // was actually saved (AddPaymentPage pops with `true`).
  // ==========================================================
  Future<void> _openAddPaymentPage(BuildContext context) async {
    if (_employees.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Employees list is still loading, please wait a moment and try again.'),
        ),
      );
      return;
    }

    final added = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddPaymentPage(
          factoryId: widget.factoryId,
          employees: _employees,
        ),
      ),
    );

    if (added == true) {
      _fetchPayments();
    }
  }

  // ==========================================================
  // NAVIGATION: View Payments
  // Replaces the old _showViewPaymentsDialog bottom sheet. Edits/
  // deletes now happen inside ViewPaymentsPage itself, so we just
  // refresh the employee-wise summary here once the user comes back,
  // since a payment there may have changed the totals shown here.
  // ==========================================================
  Future<void> _openViewPaymentsPage(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ViewPaymentsPage(factoryId: widget.factoryId),
      ),
    );

    _fetchPayments();
  }

  Widget _buildFPB(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppTheme.softShadow,
      ),
      clipBehavior: Clip.antiAlias, // keep ripple inside rounded corners
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _openAddPaymentPage(context),
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
      clipBehavior: Clip.antiAlias,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _openViewPaymentsPage(context),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.visibility_outlined,
                  color: AppTheme.primary,
                  size: 20,
                ),
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
      final raw = await _paymentService.fetchvarietytypePayments(
        widget.factoryId,
      );
      final List list = raw['data'] as List? ?? [];
      final data = list
          .map((e) => EmployeePayment.fromJson(e as Map<String, dynamic>))
          .toList();

      if (widget.initialEmployeeId != null) {
        data.sort((a, b) {
          if (a.employeeId == widget.initialEmployeeId) return -1;
          if (b.employeeId == widget.initialEmployeeId) return 1;
          return 0;
        });
      }

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

  // Remaining payable across all employees — this drives the summary card now.
  double get _grandTotalRemaining =>
      _employees.fold(0, (sum, e) => sum + e.remainingAmount);

  // Already-paid total across all employees, straight from the backend
  // (Payment table SUM), not a frontend calculation.
  double get _grandTotalPaid =>
      _employees.fold(0, (sum, e) => sum + e.totalPaid);

  // Total number of machine entries across all employees.
  int get _grandTotalMachines =>
      _employees.fold(0, (sum, e) => sum + e.machines.length);

  @override
  Widget build(BuildContext context) {
    final box = GetStorage();
    final userData = box.read('user');
    final String role = (box.read('role') ?? '')
        .toString()
        .toLowerCase()
        .trim();
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.secondary,
        iconTheme: const IconThemeData(color: AppTheme.primary),
        automaticallyImplyLeading: false,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: AppTheme.primary,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Employee Payments',
              style: TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.w800,
                fontSize: 17,
              ),
            ),
            if (_factoryName != null && _factoryName!.isNotEmpty)
              Text(
                _factoryName!,
                style: TextStyle(
                  color: AppTheme.primary.withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
          ],
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

      bottomNavigationBar: role == 'employee'
          ? const EmployeeBottomNav(currentIndex: 3)
          : CustomBottomNav(currentIndex: 2, factoryId: widget.factoryId),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primary),
      );
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
              color: AppTheme.secondary,
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
                        color: AppTheme.primary.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.payments_rounded,
                        color: AppTheme.primary,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Remaining Payment (All Employees)',
                        style: TextStyle(
                          color: AppTheme.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Rs ${formatAmount(_grandTotalRemaining)}',
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    _SummaryStat(
                      label: 'Total Machines',
                      value: '$_grandTotalMachines',
                    ),
                    const SizedBox(width: 8),
                    _SummaryStat(
                      label: 'Paid',
                      value: 'Rs ${formatAmount(_grandTotalPaid)}',
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
                  color: AppTheme.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_employees.length}',
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
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
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 28),
        Icon(Icons.inbox_rounded, size: 52, color: AppTheme.neutral),
        const SizedBox(height: 12),
        const Text(
          'No employee payments found',
          style: TextStyle(
            color: AppTheme.primary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );

  Widget _errorView() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.error_outline_rounded,
          size: 48,
          color: AppTheme.error,
        ),
        const SizedBox(height: 12),
        Text(
          _error ?? 'Something went wrong',
          style: const TextStyle(color: AppTheme.primary),
        ),
        const SizedBox(height: 16),
        ElevatedButton(onPressed: _fetchPayments, child: const Text('Retry')),
      ],
    ),
  );
}

// ============================================================
// Helpers
// ============================================================

/// Formats a raw backend datetime string (e.g. "2026-09-10 14:35:00") into
/// "10/9/26 2:35PM", same style used on the Owner Productions page.
String formatDateTime(dynamic raw) {
  if (raw == null) return '-';
  try {
    final dt = DateTime.parse(raw.toString()).toLocal();
    final hour = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final minute = dt.minute.toString().padLeft(2, '0');
    final year = dt.year.toString().substring(2);
    return '${dt.day}/${dt.month}/$year $hour:$minute$period';
  } catch (_) {
    return raw.toString();
  }
}

String formatAmount(double value) {
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
          color: AppTheme.info,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.primary.withOpacity(0.10)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: AppTheme.secondary,
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

/// Expandable card for a single employee: header shows name + remaining
/// amount, plus factory/manager context, and expands to a list of every
/// machine that contributed to that total, plus payment history.
class _EmployeePaymentTile extends StatelessWidget {
  final EmployeePayment record;
  Widget _employeeAmountStat(String label, double amount, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.10)),
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
              'Rs ${formatAmount(amount)}',
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
    final displayName =
        (record.employeeName == null || record.employeeName!.isEmpty)
        ? 'Employee #${record.employeeId}'
        : record.employeeName!;

    // Build the subtitle line dynamically so it still looks clean when
    // factory_name / manager_name are null.
    final subtitleParts = <String>[
      '${record.machines.length} machine${record.machines.length == 1 ? '' : 's'}',
      '${formatAmount(record.totalLength)} m',
    ];
    if (record.factoryName != null && record.factoryName!.isNotEmpty) {
      subtitleParts.add(record.factoryName!);
    }

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.secondary,
        borderRadius: AppTheme.cardRadius,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.12),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
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
            child: const Icon(
              Icons.person_rounded,
              color: AppTheme.primary,
              size: 18,
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Remaining payment badge, right next to the employee name.
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color:
                      (record.remainingAmount > 0
                              ? AppTheme.error
                              : AppTheme.success)
                          .withOpacity(0.10),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Rs ${formatAmount(record.remainingAmount)}',
                  style: TextStyle(
                    color: record.remainingAmount > 0
                        ? AppTheme.error
                        : AppTheme.success,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
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
          children: [
            // Date-wise payment history — every amount that was paid, and
            // the date it was paid on.
            if (record.paymentHistory.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.only(bottom: 6),
                child: Text(
                  'Payment History',
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.primary.withOpacity(0.06)),
                ),
                child: Column(
                  children: record.paymentHistory
                      .map(
                        (p) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                formatDateTime(p.paidDate),
                                style: TextStyle(
                                  color: AppTheme.primary.withOpacity(0.6),
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                'Rs ${formatAmount(p.amountPaid)}',
                                style: const TextStyle(
                                  color: AppTheme.success,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 10),
            ],
            if (record.machines.isEmpty)
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  'No machine records',
                  style: TextStyle(color: AppTheme.textPrimary, fontSize: 12),
                ),
              )
            else
              ...record.machines.map(
                (m) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _MachineGroupTile(machine: m),
                ),
              ),
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
              color: AppTheme.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '${machine.productionCount} batch${machine.productionCount == 1 ? '' : 'es'} • ${formatAmount(machine.totalLength)} m',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppTheme.primary.withOpacity(0.55),
                fontSize: 11,
              ),
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
                    'Rs ${formatAmount(machine.earnedAmount)}',
                    maxLines: 1,
                    style: const TextStyle(
                      color: AppTheme.success,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
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
                  'Rs ${formatAmount(machine.expectedAmount)}',
                  AppTheme.primary,
                ),
                const SizedBox(width: 6),
                _machineStatBox(
                  'Earned Amount',
                  'Rs ${formatAmount(machine.earnedAmount)}',
                  AppTheme.success,
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Row 2: Ready, Waste, Remaining meters
            Row(
              children: [
                _machineMiniStat(
                  'Ready',
                  '${formatAmount(machine.readyProduction)} m',
                ),
                const SizedBox(width: 6),
                _machineMiniStat(
                  'Waste',
                  '${formatAmount(machine.wasteProduction)} m',
                ),
                const SizedBox(width: 6),
                _machineMiniStat(
                  'Remaining',
                  '${formatAmount(machine.remainingProduction)} m',
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (machine.productions.isEmpty)
              const Text(
                'No production records',
                style: TextStyle(color: AppTheme.textPrimary, fontSize: 12),
              )
            else
              ...machine.productions.map(
                (p) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _ProductionRow(record: p),
                ),
              ),
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
          Text(
            label,
            style: TextStyle(
              color: AppTheme.primary.withOpacity(0.5),
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
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
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
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
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
                style: TextStyle(
                  color: AppTheme.primary.withOpacity(0.55),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),
              _detailRow('Variety', record.varietyType),
              _detailRow('Machine', record.machineName ?? '—'),
              _detailRow(
                'Total Length',
                '${formatAmount(record.totalLength)} m',
              ),
              _detailRow('Ready Production', '${record.readyProduction} m'),
              _detailRow(
                'Waste Production',
                '${formatAmount(record.wasteProduction)} m',
              ),
              _detailRow(
                'Remaining Production',
                '${formatAmount(record.remainingProduction)} m',
              ),
              _detailRow(
                'Rate / meter',
                'Rs ${record.amountPerMeter.toStringAsFixed(2)}',
              ),
              _detailRow(
                'Expected Amount',
                'Rs ${formatAmount(record.expectedAmount)}',
              ),
              _detailRow(
                'Earned Amount',
                'Rs ${formatAmount(record.earnedAmount)}',
              ),
              if (record.selectDays != null && record.selectDays != 'null')
                _detailRow('Day', record.selectDays!),
              if (record.shiftStart != null)
                _detailRow(
                  'Shift',
                  '${record.shiftStart} - ${record.shiftEnd}',
                ),
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
            child: Text(
              label,
              style: TextStyle(
                color: AppTheme.primary.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
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
                      color: AppTheme.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
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
                      'Rs ${formatAmount(record.earnedAmount)}',
                      style: TextStyle(
                        color: record.status == 4
                            ? AppTheme.success
                            : AppTheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _miniStat('Length', '${formatAmount(record.totalLength)} m'),
                const SizedBox(width: 6),
                _miniStat(
                  'Rate/m',
                  'Rs ${record.amountPerMeter.toStringAsFixed(2)}',
                ),
                const SizedBox(width: 6),
                _miniStat('Ready', '${record.readyProduction} m'),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                _miniStat(
                  'Expected',
                  'Rs ${formatAmount(record.expectedAmount)}',
                ),
                const SizedBox(width: 6),
                _miniStat(
                  'Waste',
                  '${formatAmount(record.wasteProduction)} m',
                ),
                const SizedBox(width: 6),
                _miniStat(
                  'Remaining',
                  '${formatAmount(record.remainingProduction)} m',
                ),
              ],
            ),
            if (record.selectDays != null &&
                record.selectDays!.isNotEmpty &&
                record.selectDays != 'null') ...[
              const SizedBox(height: 6),
              Text(
                'Days: ${record.selectDays}',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppTheme.primary.withOpacity(0.5),
                  fontSize: 10,
                ),
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
          Text(
            label,
            style: TextStyle(
              color: AppTheme.primary.withOpacity(0.5),
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
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}