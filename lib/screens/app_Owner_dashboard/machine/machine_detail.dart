import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:techstile_frontend/core/utils/theme.dart';
import 'package:techstile_frontend/core/services/auth_service.dart';
import 'package:techstile_frontend/screens/app_Owner_dashboard/machine/owner_enter_productions.dart';

import '../../../../core/services/machines_service.dart';
import '../../../../core/services/machine_details_service.dart';
import 'assign_production_batch.dart';
import 'generate_qrcode.dart';
import 'package:techstile_frontend/widgets/bottom_nav_bar.dart';

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
  final MachineDetailsService _detailSvc = MachineDetailsService();
  bool _detailLoading = true;
  Map<String, dynamic> _detail = {};
  String factoryName = "";

  @override
  void initState() {
    super.initState();
    _loadDetail();
    _loadFactoryName();
  }

  Future<void> _loadDetail() async {
    setState(() => _detailLoading = true);
    await _detailSvc.getMachineDetails(widget.machine.id);
    setState(() {
      _detail = Map<String, dynamic>.from(_detailSvc.data);
      _detailLoading = false;
    });
  }

  Future<void> _loadFactoryName() async {
    try {
      final response = await http.get(
        Uri.parse("http://localhost:8000/api/factories/editfactory/${widget.factoryId}"),
        headers: AuthService.authHeaders,
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (mounted) {
          setState(() => factoryName = body['data']?['name'] ?? "");
        }
      }
    } catch (_) {}
  }

  void _openAssignProduction() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.secondary,
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
        "Machine is not assign to any employee",
      );
      return;
    }
    if (_detail['batch_id'] == null) {
      Get.snackbar(
        "No Batch",
        "First \"Assign Production\" to assign batch",
      );
      return;
    }
    Get.to(
      () => OwnerEnterProductionScreen(
        machineId: int.parse(widget.machine.id),
        factoryId: int.parse(widget.factoryId),
        batchId: _detail['batch_id']?.toString(),
        varietyType: _detail['variety_type']?.toString() ?? '',
        totalLength: double.tryParse('${_detail['total_length'] ?? 0}') ?? 0,
        remaining: double.tryParse('${_detail['remaining'] ?? 0}') ?? 0,
        shifts: shifts,
      ),
    )?.then((_) => _loadDetail());
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.machine;

    return Scaffold(
      backgroundColor: AppTheme.secondary,
      appBar: AppBar(
        backgroundColor: AppTheme.secondary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppTheme.primary,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              m.machineName,
              style: const TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            if (factoryName.isNotEmpty)
              Text(
                factoryName,
                style: TextStyle(
                  color: AppTheme.primary.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
          ],
        ),
      ),
      body: _detailLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : RefreshIndicator(
              onRefresh: _loadDetail,
              color: AppTheme.textPrimary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _heroCard(m),
                    const SizedBox(height: 20),

                    const _SectionLabel(text: 'Quick Actions'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _ActionCard(
                            icon: Icons.add_task_rounded,
                            label: 'Assign\nProduction',
                            color: AppTheme.textPrimary,
                            onTap: _openAssignProduction,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _ActionCard(
                            icon: Icons.edit_note_rounded,
                            label: 'Enter\nProduction',
                            color: AppTheme.info,
                            onTap: _openEnterProduction,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    const _SectionLabel(text: 'Machine Info'),
                    const SizedBox(height: 12),
                    _infoCard(Icons.tag_rounded, 'Machine ID', m.id),
                    _infoCard(
                      Icons.precision_manufacturing_outlined,
                      'Machine Type',
                      m.type,
                    ),
                    const _SectionLabel(text: 'Current Batch'),
                    const SizedBox(height: 12),
                    if (_detail['batch_id'] == null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        decoration: BoxDecoration(
                          color: AppTheme.secondary,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.inventory_2_outlined,
                                size: 32, color: AppTheme.neutral),
                            const SizedBox(height: 8),
                            Text('No production batch assigned yet',
                                style: TextStyle(
                                    color: AppTheme.textneutral, fontSize: 13)),
                          ],
                        ),
                      )
                    else ...[
                      _infoCard(
                        Icons.category_outlined,
                        'Variety Type',
                        _detail['variety_type']?.toString() ?? '\u2014',
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: _statCard('Total Length',
                                '${_detail['total_length'] ?? 0}'),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _statCard('Ready (both shifts)',
                                '${_detail['ready_production'] ?? 0}'),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _statCard('Remaining',
                                '${_detail['remaining'] ?? 0}'),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 20),

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
                                size: 34, color: AppTheme.neutral),
                            const SizedBox(height: 8),
                            Text('No employee assigned to this machine yet',
                                style: TextStyle(
                                    color: AppTheme.textneutral, fontSize: 13)),
                          ],
                        ),
                      )
                    else
                      ...List<Map<String, dynamic>>.from(_detail['shifts'])
                          .map((s) => _shiftCard(s)),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: CustomBottomNav(currentIndex: 1, factoryId: int.parse(widget.machine.id)),
    );
  }

  Widget _heroCard(Machine m) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.textPrimary, Color(0xFF1A3570)],
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
              color: AppTheme.info,
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
                    color: AppTheme.secondary,
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
              ],
            ),
          ),
        ],
      ),
    );
  }

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
                  color: (isDayShift ? Colors.orange : AppTheme.primary).withOpacity(0.12),
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
                  child: _lightStatCard('Ready (own)', '${s['ready_production'] ?? 0}')),
              const SizedBox(width: 8),
              Expanded(
                  child: _lightStatCard('Waste (own)', '${s['waste_production'] ?? 0}')),
            ],
          ),
        ],
      ),
    );
  }

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

  Widget _statCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.25),
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
              color: AppTheme.secondary.withOpacity(0.7),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.neutral,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _lightStatCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.secondary,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.primary.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppTheme.primary.withOpacity(0.6),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.primary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

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
            color: AppTheme.neutral,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            color: AppTheme.primary,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}