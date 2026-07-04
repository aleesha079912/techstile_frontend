import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/services/machines_service.dart';
import '../../../../core/services/machine_details_service.dart';
import 'package:techstile_frontend/widgets/man_bottom_navbar.dart';

// ── Colours ───────────────────────────────────────────────────────────────────
const _navy = Color(0xFF0D1B4B);
const _teal = Color(0xFF00C8B0);
const _bg = Color(0xFFF5F6FA);
const _white = Colors.white;

class MachineDetailsScreen extends StatefulWidget {
  final Machine machine;
  final String factoryId;

  const MachineDetailsScreen({
    super.key,
    required this.machine,
    required this.factoryId,
  });

  @override
  State<MachineDetailsScreen> createState() => _MachineDetailScreenState();
}

class _MachineDetailScreenState extends State<MachineDetailsScreen> {
  // ── Service ───────────────────────────────────────────────────────────────
  final MachineDetailsService _detailSvc = MachineDetailsService();
  bool _detailLoading = true;
  Map<String, dynamic> _detail = {};

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() => _detailLoading = true);
    await _detailSvc.getMachineDetails(widget.machine.id);
    setState(() {
      _detail = Map<String, dynamic>.from(_detailSvc.data);
      _detailLoading = false;
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final m = widget.machine;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _navy,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: _white,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          m.machineName,
          style: const TextStyle(
            color: _white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _teal.withOpacity(0.18),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Active',
              style: TextStyle(
                color: _teal,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),

      body: _detailLoading
          ? const Center(child: CircularProgressIndicator(color: _navy))
          : RefreshIndicator(
              onRefresh: _loadDetail,
              color: _navy,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Hero ───────────────────────────────────────────
                    _heroCard(m),
                    const SizedBox(height: 20),

                    // ── Machine Info ───────────────────────────────────
                    const _SectionLabel(text: 'Machine Info'),
                    const SizedBox(height: 12),
                    _infoCard(Icons.tag_rounded, 'Machine ID', m.id),
                    _infoCard(
                      Icons.precision_manufacturing_outlined,
                      'Machine Type',
                      m.type,
                    ),

                    const SizedBox(height: 20),

                    // ── Shift-wise Employees ────────────────────────────
                    const _SectionLabel(text: 'Shift-wise Production'),
                    const SizedBox(height: 12),
                    if ((_detail['shifts'] as List?)?.isEmpty ?? true)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 28),
                        decoration: BoxDecoration(
                          color: _white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.person_off_outlined,
                                size: 34, color: Colors.grey.shade300),
                            const SizedBox(height: 8),
                            Text('No employee assigned to this machine yet',
                                style: TextStyle(
                                    color: Colors.grey.shade400, fontSize: 13)),
                          ],
                        ),
                      )
                    else
                      ...List<Map<String, dynamic>>.from(_detail['shifts'])
                          .map((s) => _shiftCard(s)),

                    const SizedBox(height: 16),

                    // ── Stats row ───────────────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: _statCard(
                            'Daily',
                            _detail['daily_production']?.toString() ?? '0',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _statCard(
                            'Weekly',
                            _detail['weekly_production']?.toString() ?? '0',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _statCard(
                            'Yearly',
                            _detail['yearly_production']?.toString() ?? '0',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
      // ✅ Fix: factoryId widget.factoryId se aana chahiye, machine.id se nahi
      bottomNavigationBar: ManagerBottomNav(
        currentIndex: 1,
        factoryId: widget.factoryId,
      ),
    );
  }

  // ── Hero card ─────────────────────────────────────────────────────────────
  Widget _heroCard(Machine m) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_navy, Color(0xFF1A3570)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _navy.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: _white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.precision_manufacturing_rounded,
              color: _teal,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  m.machineName,
                  style: const TextStyle(
                    color: _white,
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  m.type,
                  style: TextStyle(
                    color: _white.withOpacity(0.65),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.circle, color: _teal, size: 8),
                    const SizedBox(width: 5),
                    Text(
                      'Running',
                      style: TextStyle(
                        color: _white.withOpacity(0.8),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Shift card (one employee's shift assignment on this machine) ───────────
  Widget _shiftCard(Map<String, dynamic> s) {
    final start = s['shift_start']?.toString() ?? '';
    final end = s['shift_end']?.toString() ?? '';
    final isDayShift = start.startsWith('08');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (isDayShift ? Colors.orange : _navy).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isDayShift ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                  color: isDayShift ? Colors.orange : _navy,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  s['employee_name']?.toString().isNotEmpty == true
                      ? s['employee_name'].toString()
                      : 'Employee #${s['employee_id'] ?? '-'}',
                  style: const TextStyle(
                      color: _navy, fontWeight: FontWeight.w700, fontSize: 14),
                ),
              ),
              Text(
                '$start - $end',
                style: TextStyle(color: _navy.withOpacity(0.55), fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _statCard('Total', '${s['total_length'] ?? 0}')),
              const SizedBox(width: 8),
              Expanded(
                  child: _statCard('Ready', '${s['ready_production'] ?? 0}')),
              const SizedBox(width: 8),
              Expanded(
                  child: _statCard('Remaining', '${s['remaining'] ?? 0}')),
            ],
          ),
          if ((s['variety_type'] ?? '').toString().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Variety: ${s['variety_type']}',
                style: TextStyle(color: _navy.withOpacity(0.6), fontSize: 12)),
          ],
        ],
      ),
    );
  }

  // ── Info card ─────────────────────────────────────────────────────────────
  Widget _infoCard(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _navy.withOpacity(0.07),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: _navy, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: _navy.withOpacity(0.6),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: _navy,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ── Stat card ─────────────────────────────────────────────────────────────
  Widget _statCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: _navy,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: _navy.withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: _white.withOpacity(0.7),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: _teal,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section Label ─────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: _teal,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            color: _navy,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}