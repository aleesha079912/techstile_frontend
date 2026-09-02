import 'package:flutter/material.dart';
import 'package:techstile_frontend/core/services/payments_service.dart';
import 'package:techstile_frontend/core/utils/theme.dart';
// Reusing the SAME data models used on the employee's own payment view —
// so the numbers shown here are guaranteed to match what the employee sees.
import 'package:techstile_frontend/screens/app_Owner_dashboard/factory_owner_dash/paymentsScreen.dart'
    show EmployeePayment, MachineGroup, ProductionRecord;

/// Read-only "Payment History" for ONE employee — opened from that employee's
/// profile. Deliberately does NOT reuse [PaymentsScreen]: that screen is the
/// full owner Payments console (all employees, Add Payment button, its own
/// bottom nav) and pushing into it from a profile page would drop the viewer
/// into a whole different section of the app. This screen has no bottom nav,
/// no drawer and no management actions — just a look at this one employee's
/// payment/earning history, back button only.
class EmployeePaymentHistoryScreen extends StatefulWidget {
  final int employeeId;
  final int factoryId;
  final String? employeeName;

  const EmployeePaymentHistoryScreen({
    super.key,
    required this.employeeId,
    required this.factoryId,
    this.employeeName,
  });

  @override
  State<EmployeePaymentHistoryScreen> createState() =>
      _EmployeePaymentHistoryScreenState();
}

class _EmployeePaymentHistoryScreenState
    extends State<EmployeePaymentHistoryScreen> {
  final _service = PaymentService();

  bool loading = true;
  String? error;
  EmployeePayment? record;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final raw = await _service.fetchvarietytypePayments(widget.factoryId);
      final List list = raw['data'] as List? ?? [];
      final all = list
          .map((e) => EmployeePayment.fromJson(e as Map<String, dynamic>))
          .toList();

      EmployeePayment? mine;
      for (final e in all) {
        if (e.employeeId == widget.employeeId) {
          mine = e;
          break;
        }
      }

      setState(() {
        record = mine;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Could not load payment history';
        loading = false;
      });
    }
  }

  String _fmt(double v) {
    final str = v.toStringAsFixed(0);
    final buffer = StringBuffer();
    final reversed = str.split('').reversed.toList();
    for (int i = 0; i < reversed.length; i++) {
      buffer.write(reversed[i]);
      final posFromEnd = i + 1;
      if (posFromEnd % 3 == 0 && posFromEnd != reversed.length) buffer.write(',');
    }
    return buffer.toString().split('').reversed.join('');
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.employeeName != null && widget.employeeName!.isNotEmpty
        ? "${widget.employeeName}'s Payments"
        : 'Payment History';

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.secondary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(title,
            style: const TextStyle(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w700,
                fontSize: 17)),
      ),
      // No FAB, no drawer, no bottom nav — pure read-only drill-down.
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (loading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
    }
    if (error != null) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.error_outline_rounded, size: 44, color: AppTheme.error),
          const SizedBox(height: 10),
          Text(error!, style: const TextStyle(color: AppTheme.primary)),
          const SizedBox(height: 14),
          ElevatedButton(onPressed: _load, child: const Text('Retry')),
        ]),
      );
    }
    if (record == null) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.receipt_long_outlined, size: 52, color: AppTheme.neutral),
          const SizedBox(height: 12),
          const Text('No payment records found',
              style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600)),
        ]),
      );
    }

    final r = record!;
    return RefreshIndicator(
      color: AppTheme.primary,
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Summary card — total earned / paid / remaining
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Total Earned',
                    style: TextStyle(color: AppTheme.secondary, fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text('Rs ${_fmt(r.totalEarned)}',
                    style: const TextStyle(color: AppTheme.secondary, fontSize: 26, fontWeight: FontWeight.w800)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _summaryStat('Paid', 'Rs ${_fmt(r.totalPaid)}'),
                    const SizedBox(width: 10),
                    _summaryStat('Remaining', 'Rs ${_fmt(r.remainingAmount)}'),
                    const SizedBox(width: 10),
                    _summaryStat('Length', '${_fmt(r.totalLength)} m'),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          const Text('Machine-wise Production',
              style: TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),

          if (r.machines.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 20),
              child: Center(child: Text('No production recorded yet')),
            )
          else
            ...r.machines.map((m) => _machineCard(m)),
        ],
      ),
    );
  }

  Widget _summaryStat(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: AppTheme.secondary.withOpacity(0.10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.secondary.withOpacity(0.18)),
        ),
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(color: AppTheme.secondary, fontSize: 13, fontWeight: FontWeight.w800)),
            const SizedBox(height: 3),
            Text(label,
                style: TextStyle(color: AppTheme.secondary.withOpacity(0.75), fontSize: 10.5)),
          ],
        ),
      ),
    );
  }

  Widget _machineCard(MachineGroup m) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.secondary,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.precision_manufacturing_outlined, size: 18, color: AppTheme.primary.withOpacity(0.7)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(m.machineName,
                    style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
              ),
              Text('Rs ${_fmt(m.earnedAmount)}',
                  style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.success)),
            ],
          ),
          const Divider(height: 20),
          ...m.productions.map((p) => _productionRow(p)),
        ],
      ),
    );
  }

  Widget _productionRow(ProductionRecord p) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.varietyType.isEmpty ? 'Variety' : p.varietyType,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                Text('${p.readyProduction} m ready • ${p.createdAt ?? ''}',
                    style: TextStyle(fontSize: 11.5, color: AppTheme.textPrimary.withOpacity(0.55))),
              ],
            ),
          ),
          Text('Rs ${_fmt(p.earnedAmount)}',
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppTheme.primary)),
        ],
      ),
    );
  }
}