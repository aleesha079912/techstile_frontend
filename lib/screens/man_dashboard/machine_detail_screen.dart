import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:techstile_frontend/core/utils/theme.dart';
import '../../../../core/services/machines_service.dart';
import '../../../../core/services/machine_details_service.dart';
import '../../../../core/services/manager_service/manager_service.dart';
import 'package:techstile_frontend/widgets/man_bottom_navbar.dart';

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
  // Services
  final MachineDetailsService _detailSvc = MachineDetailsService();
  final ManagerDashboardService _managerSvc = ManagerDashboardService();

  bool _detailLoading = true;
  Map<String, dynamic> _detail = {};
  String? factoryName;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() => _detailLoading = true);

    await _detailSvc.getMachineDetails(widget.machine.id);

    Map<String, dynamic>? dashboardData;
    try {
      dashboardData = await _managerSvc.getDashboard(widget.factoryId);
    } catch (_) {
      dashboardData = null;
    }

    setState(() {
      _detail = Map<String, dynamic>.from(_detailSvc.data);
      factoryName = dashboardData?['factory']?['name'];
      _detailLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.machine;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.secondary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
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
                fontWeight: FontWeight.w800,
                fontSize: 17,
              ),
            ),
            Text(
              _detailLoading ? 'Loading...' : (factoryName ?? 'Factory'),
              style: TextStyle(
                color: AppTheme.primary.withOpacity(0.65),
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.active.withOpacity(0.18),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Active',
              style: TextStyle(
                color: AppTheme.primary,
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
                    const _SectionLabel(text: 'Machine Info'),
                    const SizedBox(height: 12),
                    _infoCard(Icons.tag_rounded, 'Machine ID', m.id),
                    _infoCard(
                      Icons.precision_manufacturing_outlined,
                      'Machine Type',
                      m.type,
                    ),

                    const SizedBox(height: 20),

                    // Shift-wise Employees
                    const _SectionLabel(text: 'Shift-wise Production'),
                    const SizedBox(height: 12),
                    if ((_detail['shifts'] as List?)?.isEmpty ?? true)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 28),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppTheme.primary.withOpacity(0.12),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.person_off_outlined,
                                size: 34, color: AppTheme.primary.withOpacity(0.5)),
                            const SizedBox(height: 8),
                            Text('No employee assigned to this machine yet',
                                style: TextStyle(
                                    color: AppTheme.primary.withOpacity(0.7),
                                    fontSize: 13)),
                          ],
                        ),
                      )
                    else
                      ...List<Map<String, dynamic>>.from(_detail['shifts'])
                          .map((s) => _shiftCard(s)),

                    const SizedBox(height: 16),

                    // Stats row
                    const _SectionLabel(text: 'Production Overview'),
                    const SizedBox(height: 12),
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
      bottomNavigationBar: ManagerBottomNav(
        currentIndex: 1,
        factoryId: widget.factoryId,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primary.withOpacity(0.12),
          width: 1,
        ),
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
                  color: (isDayShift ? AppTheme.surface : AppTheme.primary)
                      .withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isDayShift ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                  color: isDayShift ? AppTheme.surface : AppTheme.primary,
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
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14),
                ),
              ),
              Text(
                '$start - $end',
                style: TextStyle(
                    color: AppTheme.primary.withOpacity(0.55),
                    fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _statCard('Total', '${s['total_length'] ?? 0}')),
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
                style:
                    TextStyle(color: AppTheme.primary.withOpacity(0.6), fontSize: 12)),
          ],
        ],
      ),
    );
  }

  Widget _infoCard(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppTheme.primary.withOpacity(0.12),
          width: 1,
        ),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppTheme.primary.withOpacity(0.12),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.08),
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

// Section Label
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
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}