import 'package:flutter/material.dart';
import 'package:techstile_frontend/core/utils/theme.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<PaymentScreen> {
  // ---- Static data model ----
  final List<_PaymentRecord> _payments = const [
    _PaymentRecord(
      partyName: 'Al-Karam Textile Mills',
      invoiceNo: 'INV-2026-0142',
      description: 'Cotton fabric — 500m roll',
      amount: 285000,
      date: '02 Aug 2026',
      status: PaymentStatus.paid,
      method: 'Bank Transfer',
    ),
    _PaymentRecord(
      partyName: 'Sindh Weaving Co.',
      invoiceNo: 'INV-2026-0141',
      description: 'Yarn supply — 2 tons',
      amount: 412500,
      date: '30 Jul 2026',
      status: PaymentStatus.pending,
      method: 'Cheque',
    ),
    _PaymentRecord(
      partyName: 'Faisalabad Dyeing House',
      invoiceNo: 'INV-2026-0139',
      description: 'Dyeing & finishing services',
      amount: 96000,
      date: '27 Jul 2026',
      status: PaymentStatus.overdue,
      method: 'Cash',
    ),
    _PaymentRecord(
      partyName: 'Metro Garments Buyer',
      invoiceNo: 'INV-2026-0138',
      description: 'Bulk order — shirting fabric',
      amount: 780000,
      date: '24 Jul 2026',
      status: PaymentStatus.paid,
      method: 'Bank Transfer',
    ),
    _PaymentRecord(
      partyName: 'Punjab Thread Suppliers',
      invoiceNo: 'INV-2026-0136',
      description: 'Polyester thread — 300 spools',
      amount: 54000,
      date: '20 Jul 2026',
      status: PaymentStatus.paid,
      method: 'Online',
    ),
    _PaymentRecord(
      partyName: 'City Textile Traders',
      invoiceNo: 'INV-2026-0133',
      description: 'Grey cloth — 1000m',
      amount: 615000,
      date: '15 Jul 2026',
      status: PaymentStatus.pending,
      method: 'Cheque',
    ),
    _PaymentRecord(
      partyName: 'Al-Karam Textile Mills',
      invoiceNo: 'INV-2026-0129',
      description: 'Cotton fabric — 300m roll',
      amount: 171000,
      date: '08 Jul 2026',
      status: PaymentStatus.overdue,
      method: 'Bank Transfer',
    ),
  ];

  double get _totalPaid => _payments
      .where((p) => p.status == PaymentStatus.paid)
      .fold(0, (sum, p) => sum + p.amount);

  double get _totalPending => _payments
      .where((p) => p.status == PaymentStatus.pending)
      .fold(0, (sum, p) => sum + p.amount);

  double get _totalOverdue => _payments
      .where((p) => p.status == PaymentStatus.overdue)
      .fold(0, (sum, p) => sum + p.amount);

  @override
  Widget build(BuildContext context) {
    const primaryColor =  AppTheme.primary; // deep textile-green
    const bgColor =  AppTheme.background;

    return Scaffold(
      backgroundColor:  AppTheme.background,
      appBar: AppBar(
        backgroundColor:  AppTheme.primary,
        foregroundColor:  AppTheme.secondary,
        elevation: 0,
        title: const Text(
          'Payment History',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          // ---- Summary card ----
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
                  'Total Transactions',
                  style: TextStyle(color:  AppTheme.neutral, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  'Rs ${_formatAmount(_totalPaid + _totalPending + _totalOverdue)}',
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
                      label: 'Paid',
                      amount: _totalPaid,
                      color: AppTheme.success,
                    ),
                    const SizedBox(width: 12),
                    _SummaryStat(
                      label: 'Pending',
                      amount: _totalPending,
                      color: const Color(0xFFFFD27F),
                    ),
                    const SizedBox(width: 12),
                    _SummaryStat(
                      label: 'Overdue',
                      amount: _totalOverdue,
                      color: const Color(0xFFFF9B9B),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ---- Filter chips (static/display only) ----
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: const [
                _FilterChipStatic(label: 'All', selected: true),
                SizedBox(width: 8),
                _FilterChipStatic(label: 'Paid'),
                SizedBox(width: 8),
                _FilterChipStatic(label: 'Pending'),
                SizedBox(width: 8),
                _FilterChipStatic(label: 'Overdue'),
              ],
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'Recent Transactions',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),

          // ---- Payment list ----
          ...List.generate(_payments.length, (index) {
            final payment = _payments[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _PaymentTile(record: payment),
            );
          }),
        ],
      ),
    );
  }
}

// ============================================================
// Data model
// ============================================================

enum PaymentStatus { paid, pending, overdue }

class _PaymentRecord {
  final String partyName;
  final String invoiceNo;
  final String description;
  final double amount;
  final String date;
  final PaymentStatus status;
  final String method;

  const _PaymentRecord({
    required this.partyName,
    required this.invoiceNo,
    required this.description,
    required this.amount,
    required this.date,
    required this.status,
    required this.method,
  });
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

({Color bg, Color fg, String label}) _statusStyle(PaymentStatus status) {
  switch (status) {
    case PaymentStatus.paid:
      return (
        bg: const Color(0xFFE3F6E9),
        fg: const Color(0xFF1F8A4C),
        label: 'Paid',
      );
    case PaymentStatus.pending:
      return (
        bg: const Color(0xFFFFF4E0),
        fg: const Color(0xFFC98A1D),
        label: 'Pending',
      );
    case PaymentStatus.overdue:
      return (
        bg: const Color(0xFFFDE7E7),
        fg: const Color(0xFFD64545),
        label: 'Overdue',
      );
  }
}

// ============================================================
// Small presentational widgets
// ============================================================

class _SummaryStat extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;

  const _SummaryStat({
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(color:  AppTheme.neutral, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Rs ${_formatAmount(amount)}',
            style: const TextStyle(
              color:  AppTheme.secondary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChipStatic extends StatelessWidget {
  final String label;
  final bool selected;

  const _FilterChipStatic({required this.label, this.selected = false});

  @override
  Widget build(BuildContext context) {
    const primaryColor =  AppTheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: selected ?  AppTheme.primary:  AppTheme.secondary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected ?  AppTheme.primary :  AppTheme.neutral,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          color: selected ?  AppTheme.secondary :  AppTheme.neutral,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  final _PaymentRecord record;

  const _PaymentTile({required this.record});

  @override
  Widget build(BuildContext context) {
    final style = _statusStyle(record.status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:  AppTheme.secondary,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color:  AppTheme.onsurface.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar circle with initials
              CircleAvatar(
                radius: 20,
                backgroundColor:  AppTheme.primary.withOpacity(0.1),
                child: Text(
                  _initials(record.partyName),
                  style: const TextStyle(
                    color:  AppTheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.partyName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      record.description,
                      style: const TextStyle(
                        color:  AppTheme.neutral,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: style.bg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  style.label,
                  style: TextStyle(
                    color: style.fg,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color:  AppTheme.secondary),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.invoiceNo,
                    style: const TextStyle(
                      color:  AppTheme.neutral,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${record.date}  •  ${record.method}',
                    style: const TextStyle(
                      color:  AppTheme.neutral,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              Text(
                'Rs ${_formatAmount(record.amount)}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }
}