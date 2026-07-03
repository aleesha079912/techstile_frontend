import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:techstile_frontend/screens/app_Owner_dashboard/machine/owner_enter_productions.dart';
import 'package:techstile_frontend/core/utils/theme.dart';
import 'package:techstile_frontend/widgets/owner_drawer.dart';
import '../../../../core/services/machines_service.dart';
import '../../../../core/services/machine_details_service.dart';
import 'assign_production_batch.dart';
import 'generate_qrcode.dart';
import 'package:techstile_frontend/widgets/bottom_nav_bar.dart';
// ── Colours ───────────────────────────────────────────────────────────────────


class MachineDetailScreen extends StatefulWidget {
  final Machine machine;
  final VoidCallback onRefresh;
  final String factoryId;

  const MachineDetailScreen({
    super.key,
    required this.machine,
    required this.onRefresh,
    required this.factoryId,
  });

  @override
  State<MachineDetailScreen> createState() => _MachineDetailScreenState();
}

class _MachineDetailScreenState extends State<MachineDetailScreen> {
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

  // ── Actions ───────────────────────────────────────────────────────────────
  void _openAssignProduction() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor:AppTheme.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => AssignProductionDialog(
        machineId: int.parse(widget.machine.id),
        onSuccess: () {
          widget.onRefresh();
          _loadDetail();
        },
      ),
    );
  }

  void _openQr() {
    Get.to(
      () => GenerateQrCodeScreen(
        machineDbId: widget.machine.id,
        machineLabel: widget.machine.machineName,
        factoryId: int.parse(widget.factoryId),
      ),
    );
  }

  void _openEnterProduction() {
    final shifts = List<Map<String, dynamic>>.from(_detail['shifts'] ?? []);
    if (shifts.isEmpty) {
      Get.snackbar(
        "No Employees",
        "Is machine par abhi koi employee assign nahi hai",
      );
      return;
    }
    Get.to(
      () => OwnerEnterProductionScreen(
        machineId: int.parse(widget.machine.id),
        factoryId: int.parse(widget.factoryId),
        shifts: shifts,
      ),
    )?.then((_) => _loadDetail());
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final m = widget.machine;

    return Scaffold(
      drawer: const OwnerDrawer(),
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppTheme.secondary,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          m.machineName,
          style: const TextStyle(
            color: AppTheme.secondary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.success.withOpacity(0.18),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Active',
              style: TextStyle(
                color: AppTheme.success,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),

      body: _detailLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : RefreshIndicator(
              onRefresh: _loadDetail,
              color: AppTheme.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Hero ───────────────────────────────────────────
                    _heroCard(m),
                    const SizedBox(height: 20),

                    // ── Quick Actions ──────────────────────────────────
                    const _SectionLabel(text: 'Quick Actions'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _ActionCard(
                            icon: Icons.add_task_rounded,
                            label: 'Assign\nProduction',
                            color: AppTheme.primary,
                            onTap: _openAssignProduction,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _ActionCard(
                            icon: Icons.qr_code_2_rounded,
                            label: 'Generate\nQR Code',
                            color: AppTheme.info,
                            onTap: _openQr,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _ActionCard(
                            icon: Icons.edit_note_rounded,
                            label: 'Enter\nProduction',
                            color: AppTheme.success,
                            onTap: _openEnterProduction,
                          ),
                        ),
                      ],
                    ),
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
                    // _infoCard(Icons.access_time_rounded, 'Last Update', m.time),
                    // const SizedBox(height: 20),

                    // ── Shift-wise Employees ────────────────────────────
                    const _SectionLabel(text: 'Shift-wise Production'),
                    const SizedBox(height: 12),
                    if ((_detail['shifts'] as List?)?.isEmpty ?? true)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 28),
                        decoration: BoxDecoration(
                          color: AppTheme.secondary,
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
                    const SizedBox(height: 20),

                    // const SizedBox(height: 16),

                    // Stats row
                    // Row(
                    //   children: [
                    //     Expanded(
                    //       child: _statCard(
                    //         'Daily',
                    //         _detail['daily_production']?.toString() ?? '0',
                    //       ),
                    //     ),
                    //     const SizedBox(width: 10),
                    //     Expanded(
                    //       child: _statCard(
                    //         'Weekly',
                    //         _detail['weekly_production']?.toString() ?? '0',
                    //       ),
                    //     ),
                    //     const SizedBox(width: 10),
                    //     Expanded(
                    //       child: _statCard(
                    //         'Yearly',
                    //         _detail['yearly_production']?.toString() ?? '0',
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    // const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: CustomBottomNav(currentIndex: 1, factoryId: int.parse(widget.machine.id),),
    );
  }

  // ── Hero card ─────────────────────────────────────────────────────────────
  Widget _heroCard(Machine m) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primary, AppTheme.info],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.3),
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
              color: AppTheme.secondary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.precision_manufacturing_rounded,
              color: AppTheme.success,
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
                    color:AppTheme.secondary ,
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  m.type,
                  style: TextStyle(
                    color: AppTheme.secondary.withOpacity(0.65),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.circle, color: AppTheme.success, size: 8),
                    const SizedBox(width: 5),
                    Text(
                      'Running',
                      style: TextStyle(
                        color: AppTheme.secondary.withOpacity(0.8),
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
        color: AppTheme.secondary,
        borderRadius: BorderRadius.circular(16),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (isDayShift ? Colors.orange : AppTheme.surface).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isDayShift ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                  color: isDayShift ? Colors.orange : AppTheme.primary,
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
                      color: AppTheme.primary, fontWeight: FontWeight.w700, fontSize: 14),
                ),
              ),
              Text(
                '$start - $end',
                style: TextStyle(color: AppTheme.primary.withOpacity(0.55), fontSize: 11),
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
                style: TextStyle(color: AppTheme.primary.withOpacity(0.6), fontSize: 12)),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.07),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: AppTheme.primary.withOpacity(0.6),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.primary,
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
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color:AppTheme.primary.withOpacity(0.25),
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
              color:AppTheme.secondary.withOpacity(0.7),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color:AppTheme.success,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Action Card ───────────────────────────────────────────────────────────────
class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppTheme.secondary, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.secondary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ],
        ),
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
            color: AppTheme.success,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            color:AppTheme.primary,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}