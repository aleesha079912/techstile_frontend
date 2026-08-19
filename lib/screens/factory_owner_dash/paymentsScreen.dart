import 'package:flutter/material.dart';
import 'package:techstile_frontend/core/services/payments_service.dart';
import 'package:techstile_frontend/core/utils/theme.dart';

class PaymentsScreen extends StatefulWidget {
  final int factoryId;

  const PaymentsScreen({
    super.key,
    required this.factoryId,
  });

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  final PaymentService _paymentService = PaymentService();

  List<varietytypePayment> _varietytype = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchPayments();
  }

  Widget _buildFPB(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
             AppTheme.primary,
             AppTheme.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => (){},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add, color:AppTheme.secondary ),
              const SizedBox(width: 6),
              Text(
                "Add Payments",
                style: TextStyle(
                  color:AppTheme.secondary,
                  fontWeight: FontWeight.w600,
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
      final data = await _paymentService.fetchvarietytypePayments(widget.factoryId);

      setState(() {
        _varietytype = data.varietytype;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load payments: $e';
        _isLoading = false;
      });
    }
  }

  // Everything below is derived automatically from the 3 fields the API
  // gives us per varietytype (variety_type, total_length, amount_per_meter).
  double get _grandTotalAmount =>
      _varietytype.fold(0, (sum, b) => sum + b.totalAmount);

  double get _grandTotalLength =>
      _varietytype.fold(0, (sum, b) => sum + b.totalLength);

  double get _overallRatePerMeter =>
      _grandTotalLength == 0 ? 0 : _grandTotalAmount / _grandTotalLength;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        foregroundColor: AppTheme.secondary,
        elevation: 0,
        title: const Text(
          'Variety Payments',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: false,
      ),
      body: _buildBody(),
      floatingActionButton: _buildFPB(context),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _fetchPayments,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchPayments,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          // ---- Overall summary card ----
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Payment (All Varieties)',
                  style: TextStyle(color: AppTheme.neutral, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  'Rs ${_formatAmount(_grandTotalAmount)}',
                  style: const TextStyle(
                    color: AppTheme.secondary,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    _SummaryStat(
                      label: 'Total Length',
                      value: '${_formatAmount(_grandTotalLength)} m',
                    ),
                    const SizedBox(width: 12),
                    _SummaryStat(
                      label: 'Avg Rate / m',
                      value: 'Rs ${_overallRatePerMeter.toStringAsFixed(1)}',
                    ),
                    const SizedBox(width: 12),
                    _SummaryStat(
                      label: 'Varieties',
                      value: '${_varietytype.length}',
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'Variety Wise Calculation',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),

          if (_varietytype.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: Text('No payment variety found')),
            )
          else
            ...List.generate(_varietytype.length, (index) {
              final varietytype = _varietytype[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _varietytypePaymentTile(record: varietytype),
              );
            }),
        ],
      ),
    );
  }
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppTheme.neutral, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.secondary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _varietytypePaymentTile extends StatelessWidget {
 
   final varietytypePayment record;

  const _varietytypePaymentTile({required this.record});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.secondary,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppTheme.onsurface.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---- Header: varietytype ----
          Text(
            'Variety #${record.varietytype}',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          if (record.employeeName != null && record.employeeName!.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              'By ${record.employeeName}',
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.neutral,
              ),
            ),
          ],

          const SizedBox(height: 14),
          const Divider(height: 1, color: AppTheme.background),
          const SizedBox(height: 14),

          // ---- Calculation row ----
          // total_length + amount_per_meter come straight from the API,
          // Total Amount is always: total_length * amount_per_meter
          Row(
            children: [
              Expanded(
                child: _CalcPoint(
                  label: 'Total Length',
                  value: '${_formatAmount(record.totalLength)} m',
                ),
              ),
              Expanded(
                child: _CalcPoint(
                  label: 'Amount / Meter',
                  value: 'Rs ${record.amountPerMeter.toStringAsFixed(2)}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _CalcPoint(
            label: 'Total Amount',
            value: 'Rs ${_formatAmount(record.totalAmount)}',
          ),
        ],
      ),
    );
  }
}

class _CalcPoint extends StatelessWidget {
  final String label;
  final String value;

  const _CalcPoint({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppTheme.neutral, fontSize: 11),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppTheme.primary,
          ),
        ),
      ],
    );
  }
}