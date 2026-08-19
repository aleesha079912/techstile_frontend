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

  List<BatchPayment> _batches = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchPayments();
  }

  Future<void> _fetchPayments() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _paymentService.fetchBatchPayments(widget.factoryId);

      setState(() {
        _batches = data.batches;
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
  double get _grandTotalAmount =>
      _batches.fold(0, (sum, b) => sum + b.totalAmount);

  double get _grandTotalLength =>
      _batches.fold(0, (sum, b) => sum + b.totalLength);

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
          'Batch Payments',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: false,
      ),
      body: _buildBody(),
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
                  'Total Payment (All Batches)',
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
                      label: 'Batches',
                      value: '${_batches.length}',
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'Batch Wise Calculation',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),

          if (_batches.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: Text('No payment batches found')),
            )
          else
            ...List.generate(_batches.length, (index) {
              final batch = _batches[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _BatchPaymentTile(record: batch),
              );
            }),
        ],
      ),
    );
  }
}
// Helper

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

class _BatchPaymentTile extends StatelessWidget {
  final BatchPayment record;

  const _BatchPaymentTile({required this.record});

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
          // ---- Header: batch id ----
          Text(
            'Batch #${record.batchId}',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 14),
          const Divider(height: 1, color: AppTheme.background),
          const SizedBox(height: 14),

          // Calculation row
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