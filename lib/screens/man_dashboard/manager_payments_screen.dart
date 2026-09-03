import 'package:flutter/material.dart';
import '../../core/services/manager_service/manager_service.dart';
import '../../../core/utils/theme.dart';
import '../../../widgets/man_bottom_navbar.dart';

// ============================================================
// Models
// ------------------------------------------------------------
// Same shape as the owner-side models (PaymentsScreen). Duplicated
// here so this screen stays self-contained and doesn't depend on
// the owner screen's UI file. If you later move these into a shared
// models file, just delete this block and import that instead.
// ============================================================

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

// ============================================================
// Grouping helper
// ------------------------------------------------------------
// ManagerDashboardService.getPayments() returns a FLAT list of production
// records (one row per production, not grouped by employee/machine like
// the owner-side endpoint does). We group it client-side here into the
// same EmployeePayment -> MachineGroup -> ProductionRecord shape the UI
// below expects.
//
// Field names are guessed defensively with fallbacks based on what the
// original _paymentCard() used (employeedetails.user.name, variety_type,
// total_length, ready_production, status). If amounts/grouping look wrong,
// share one sample record from the getPayments response and these getters
// can be tightened up.
// ============================================================

dynamic _pick(Map<String, dynamic> json, List<String> keys) {
  for (final k in keys) {
    if (json.containsKey(k) && json[k] != null) return json[k];
  }
  return null;
}

List<EmployeePayment> _groupProductionsByEmployee(List raw) {
  // employeeId -> machineId -> list of production maps
  final Map<int, Map<String, dynamic>> employeeMeta = {};
  final Map<int, Map<int, Map<String, dynamic>>> employeeMachineMeta = {};
  final Map<int, Map<int, List<ProductionRecord>>> buckets = {};

  for (final item in raw) {
    final p = item as Map<String, dynamic>;

    final employeeDetails = p['employeedetails'] ?? p['employee'];
    final employeeId = int.tryParse(
          (_pick(p, ['employee_id']) ?? employeeDetails?['id'])
                  ?.toString() ??
              '',
        ) ??
        0;
    final employeeName = employeeDetails?['user']?['name'] ??
        p['employee_name'] ??
        'Employee #$employeeId';

    final machineObj = p['machine'] ?? p['machinedetails'];
    final machineId = int.tryParse(
      (_pick(p, ['machine_id']) ?? machineObj?['id'])?.toString() ?? '',
    );
    final machineName =
        machineObj?['name'] ?? p['machine_name'] ?? 'Unassigned';

    final tLen = double.tryParse(_pick(p, ['total_length'])?.toString() ?? '') ?? 0;
    final rate =
        double.tryParse(_pick(p, ['amount_per_meter'])?.toString() ?? '') ?? 0;
    final exp = double.tryParse(_pick(p, ['expected_amount'])?.toString() ?? '') ??
        (tLen * rate);
    final earn = double.tryParse(
          _pick(p, ['earned_amount', 'amount'])?.toString() ?? '',
        ) ??
        0;

    final record = ProductionRecord(
      productionId:
          int.tryParse(_pick(p, ['production_id', 'id'])?.toString() ?? '') ?? 0,
      batchId: p['batch_id']?.toString() ?? '',
      varietyType: p['variety_type']?.toString() ?? '',
      status: int.tryParse(p['status']?.toString() ?? '') ?? 1,
      totalLength: tLen,
      readyProduction:
          int.tryParse(p['ready_production']?.toString() ?? '') ?? 0,
      wasteProduction:
          double.tryParse(p['waste_production']?.toString() ?? '') ?? 0,
      remainingProduction:
          double.tryParse(p['remaining_production']?.toString() ?? '') ?? 0,
      machineName: machineName,
      amountPerMeter: rate,
      expectedAmount: exp,
      earnedAmount: earn,
      amount: earn,
      selectDays: p['select_days']?.toString(),
      shiftStart: p['shift_start']?.toString(),
      shiftEnd: p['shift_end']?.toString(),
      createdAt: p['created_at']?.toString(),
    );

    employeeMeta[employeeId] = {
      'name': employeeName,
      'factory_name': p['factory_name'],
      'manager_name': p['manager_name'],
    };

    final machineKey = machineId ?? -1;
    employeeMachineMeta.putIfAbsent(employeeId, () => {});
    employeeMachineMeta[employeeId]![machineKey] = {
      'machine_id': machineId,
      'machine_name': machineName,
    };

    buckets.putIfAbsent(employeeId, () => {});
    buckets[employeeId]!.putIfAbsent(machineKey, () => []);
    buckets[employeeId]![machineKey]!.add(record);
  }

  final List<EmployeePayment> result = [];

  buckets.forEach((employeeId, machineBuckets) {
    final machines = <MachineGroup>[];
    double empExpected = 0, empEarned = 0, empLength = 0;

    machineBuckets.forEach((machineId, records) {
      final meta = employeeMachineMeta[employeeId]![machineId]!;
      double mExpected = 0, mEarned = 0, mLength = 0, mReady = 0, mWaste = 0, mRemaining = 0;

      for (final r in records) {
        mExpected += r.expectedAmount;
        mEarned += r.earnedAmount;
        mLength += r.totalLength;
        mReady += r.readyProduction;
        mWaste += r.wasteProduction;
        mRemaining += r.remainingProduction;
      }

      machines.add(MachineGroup(
        machineId: meta['machine_id'],
        machineName: meta['machine_name'],
        productionCount: records.length,
        totalLength: mLength,
        readyProduction: mReady,
        wasteProduction: mWaste,
        remainingProduction: mRemaining,
        expectedAmount: mExpected,
        earnedAmount: mEarned,
        totalAmount: mEarned,
        productions: records,
      ));

      empExpected += mExpected;
      empEarned += mEarned;
      empLength += mLength;
    });

    final meta = employeeMeta[employeeId]!;

    result.add(EmployeePayment(
      employeeId: employeeId,
      employeeName: meta['name'],
      factoryName: meta['factory_name'],
      managerName: meta['manager_name'],
      totalExpected: empExpected,
      totalAmount: empEarned,
      totalLength: empLength,
      machines: machines,
      totalEarned: empEarned,
      // Manager's getPayments() doesn't return actual paid-amount data
      // (that lives in the payments table, which is an owner-only action
      // anyway). Showing 0 paid / full remaining until that data is
      // exposed to the manager endpoint, if ever needed.
      totalPaid: 0,
      remainingAmount: empEarned,
    ));
  });

  return result;
}

// ============================================================
// Screen
// ============================================================

class ManagerPaymentsScreen extends StatefulWidget {
  final dynamic factoryId;
  const ManagerPaymentsScreen({super.key, required this.factoryId});

  @override
  State<ManagerPaymentsScreen> createState() => _ManagerPaymentsScreenState();
}

class _ManagerPaymentsScreenState extends State<ManagerPaymentsScreen> {
  final _service = ManagerDashboardService();

  bool loading = true;
  List<EmployeePayment> _employees = [];
  String? error;
  String? factoryName;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      // Manager-scoped endpoint (backend already restricts this to the
      // logged-in manager's own factory). Returns a flat production list,
      // which we group into employee -> machine -> production below.
      final res = await _service.getPayments(widget.factoryId);
      final data = _groupProductionsByEmployee(res);

      // Factory name still comes from the manager dashboard API, same as
      // before.
      final dashboardData = await _service.getDashboard(widget.factoryId);

      setState(() {
        _employees = data;
        factoryName = dashboardData['factory']?['name'];
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

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
        iconTheme: const IconThemeData(color: AppTheme.secondary),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payments',
              style: TextStyle(
                  color: AppTheme.secondary,
                  fontWeight: FontWeight.w700,
                  fontSize: 17),
            ),
            Text(
              loading ? 'Loading...' : (factoryName ?? 'Factory'),
              style: TextStyle(
                color: AppTheme.secondary.withOpacity(0.65),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      // Manager is view-only: no FAB, no add/edit/delete affordances.
      body: _buildBody(),
      bottomNavigationBar: ManagerBottomNav(
        currentIndex: 3,
        factoryId: widget.factoryId,
      ),
    );
  }

  Widget _buildBody() {
    if (loading) {
      return const Center(
          child: CircularProgressIndicator(color: AppTheme.primary));
    }

    if (error != null) {
      return _errorView();
    }

    return RefreshIndicator(
      color: AppTheme.primary,
      onRefresh: load,
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
                      child: const Icon(Icons.payments_rounded,
                          color: AppTheme.primary, size: 18),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Total Payment (All Employees)',
                        style: TextStyle(
                            color: AppTheme.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Rs ${_formatAmount(_grandTotalAmount)}',
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
                    color: AppTheme.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_employees.length}',
                  style: const TextStyle(
                      color: AppTheme.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700),
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
              style: TextStyle(
                  color: AppTheme.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
        ]),
      );

  Widget _errorView() => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded,
                  size: 48, color: AppTheme.error),
              const SizedBox(height: 12),
              Text(error ?? 'Something went wrong',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 13)),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: load, child: const Text('Retry')),
            ],
          ),
        ),
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
          color: AppTheme.primary,
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
                  fontWeight: FontWeight.w600),
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

/// Expandable card for a single employee: header shows name + earned/paid/
/// remaining, expands to a list of every machine assigned to that employee
/// (view-only — no edit/delete, manager cannot approve payments here).
class _EmployeePaymentTile extends StatelessWidget {
  final EmployeePayment record;

  const _EmployeePaymentTile({required this.record});

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

  @override
  Widget build(BuildContext context) {
    final displayName =
        (record.employeeName == null || record.employeeName!.isEmpty)
            ? 'Employee #${record.employeeId}'
            : record.employeeName!;

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
            child: const Icon(Icons.person_rounded,
                color: AppTheme.primary, size: 18),
          ),
          title: Text(
            displayName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.w800,
                fontSize: 14),
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
                          'Earned', record.totalEarned, AppTheme.primary),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _employeeAmountStat(
                          'Paid', record.totalPaid, AppTheme.success),
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
            if (record.machines.isEmpty)
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text('No machine records',
                    style: TextStyle(
                        color: AppTheme.textPrimary, fontSize: 12)),
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

/// One machine's aggregated totals for this employee. Expands to show the
/// individual production rows that make up the total. View-only.
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
          tilePadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          title: Text(
            machine.machineName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w700),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '${machine.productionCount} batch${machine.productionCount == 1 ? '' : 'es'} • ${_formatAmount(machine.totalLength)} m',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: AppTheme.primary.withOpacity(0.55), fontSize: 11),
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
                        color: AppTheme.success,
                        fontSize: 12,
                        fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
          children: [
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
            Row(
              children: [
                _machineMiniStat(
                    'Ready', '${_formatAmount(machine.readyProduction)} m'),
                const SizedBox(width: 6),
                _machineMiniStat(
                    'Waste', '${_formatAmount(machine.wasteProduction)} m'),
                const SizedBox(width: 6),
                _machineMiniStat('Remaining',
                    '${_formatAmount(machine.remainingProduction)} m'),
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
                  color: AppTheme.primary.withOpacity(0.5),
                  fontSize: 9,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value,
                maxLines: 1,
                style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

/// A single production entry. Tappable — opens a bottom sheet with the full
/// detail (view-only, same as owner side minus any action buttons).
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
                        fontWeight: FontWeight.w800),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
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
                    color: AppTheme.primary.withOpacity(0.55), fontSize: 12),
              ),
              const SizedBox(height: 16),
              _detailRow('Variety', record.varietyType),
              _detailRow('Machine', record.machineName ?? '—'),
              _detailRow(
                  'Total Length', '${_formatAmount(record.totalLength)} m'),
              _detailRow('Ready Production', '${record.readyProduction} m'),
              _detailRow('Waste Production',
                  '${_formatAmount(record.wasteProduction)} m'),
              _detailRow('Remaining Production',
                  '${_formatAmount(record.remainingProduction)} m'),
              _detailRow(
                  'Rate / meter', 'Rs ${record.amountPerMeter.toStringAsFixed(2)}'),
              _detailRow('Expected Amount',
                  'Rs ${_formatAmount(record.expectedAmount)}'),
              _detailRow(
                  'Earned Amount', 'Rs ${_formatAmount(record.earnedAmount)}'),
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
                style: TextStyle(
                    color: AppTheme.primary.withOpacity(0.6), fontSize: 12)),
          ),
          Flexible(
            child: Text(value,
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700)),
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
                        fontWeight: FontWeight.w700),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                          color: record.status == 4
                              ? AppTheme.success
                              : AppTheme.primary,
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
                _miniStat(
                    'Rate/m', 'Rs ${record.amountPerMeter.toStringAsFixed(2)}'),
                const SizedBox(width: 6),
                _miniStat('Ready', '${record.readyProduction} m'),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                _miniStat(
                    'Expected', 'Rs ${_formatAmount(record.expectedAmount)}'),
                const SizedBox(width: 6),
                _miniStat(
                    'Waste', '${_formatAmount(record.wasteProduction)} m'),
                const SizedBox(width: 6),
                _miniStat('Remaining',
                    '${_formatAmount(record.remainingProduction)} m'),
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
                    color: AppTheme.primary.withOpacity(0.5), fontSize: 10),
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
                  color: AppTheme.primary.withOpacity(0.5),
                  fontSize: 9,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value,
                maxLines: 1,
                style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}