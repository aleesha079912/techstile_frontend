// lib/features/manager/pages/manager_productions_page.dart

import 'package:flutter/material.dart';
import '../../../core/services/production_service.dart';
import '../../../core/utils/theme.dart';
import '../../../widgets/man_bottom_navbar.dart';
import 'package:techstile_frontend/widgets/man_drawer.dart';
import 'package:techstile_frontend/core/services/auth_service.dart';

class ManagerProductionsPage extends StatefulWidget {
  final dynamic factoryId;
  const ManagerProductionsPage({super.key, required this.factoryId});

  @override
  State<ManagerProductionsPage> createState() => _ManagerProductionsPageState();
}

class _ManagerProductionsPageState extends State<ManagerProductionsPage>
    with SingleTickerProviderStateMixin {
  final _service = ProductionService();
  late TabController _tab;

  bool loading = true;
  String? error;
  List<Map<String, dynamic>> _all = [];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { loading = true; error = null; });
    try {
      final list = await _service.getManagerProductions(widget.factoryId);
      setState(() { _all = list; loading = false; });
    } catch (e) {
      setState(() { error = e.toString(); loading = false; });
    }
  }

  // status 1 = pending (employee submitted)
  // status 4 = owner approved before manager → show in approved too
  List<Map<String, dynamic>> get _pending  =>
      _all.where((p) => (p['status'] as int? ?? 1) == 1).toList();

  List<Map<String, dynamic>> get _approved =>
      _all.where((p) {
        final s = p['status'] as int? ?? 1;
        return s == 2 || s == 4; // manager approved OR owner approved
      }).toList();

  Future<void> _doAction(dynamic id, String action) async {
    try {
      await _service.managerAction(id, action);
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(action == 'approve' ? 'Production approved ✓' : 'Production rejected'),
        backgroundColor: action == 'approve' ? AppTheme.success : AppTheme.error,
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: ManagerDrawer(
        userId: AuthService.userId,
        factoryId: AuthService.factoryId,
      ),
      backgroundColor: AppTheme.background,
      appBar: AppBar(
  backgroundColor: AppTheme.primary,
  elevation: 0,
  title: const Text(
    'Manager Productions',
    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 17),
  ),
  iconTheme: const IconThemeData(color: Colors.white),
  bottom: TabBar(
    controller: _tab,
    indicatorColor: AppTheme.surface,
    indicatorWeight: 3,
    labelColor: Colors.white,
    unselectedLabelColor: AppTheme.surface,
    labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
    unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
    tabs: [
      Tab(text: 'Pending (${_pending.length})'),
      Tab(text: 'Approved (${_approved.length})'),
    ],
  ),
),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : error != null
              ? _errorView()
              : RefreshIndicator(
                  color: AppTheme.primary,
                  onRefresh: _load,
                  child: TabBarView(
                    controller: _tab,
                    children: [
                      _buildList(_pending,  showActions: true),
                      _buildList(_approved, showActions: false),
                    ],
                  ),
                ),
      bottomNavigationBar: ManagerBottomNav(
        currentIndex: 0,
        factoryId: widget.factoryId,
      ),
    );
  }

  Widget _buildList(List<Map<String, dynamic>> items, {required bool showActions}) {
    if (items.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.inbox_rounded, size: 52, color: AppTheme.neutral),
          const SizedBox(height: 12),
          const Text('No records found',
              style: TextStyle(color: AppTheme.primary, fontSize: 14, fontWeight: FontWeight.w600)),
        ]),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _card(items[i], showActions: showActions),
    );
  }

  Widget _card(Map<String, dynamic> p, {required bool showActions}) {
    final status         = p['status'] as int? ?? 1;
    final isOwnerApproved = status == 4;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.secondary,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppTheme.softShadow,
        border: Border.all(color: AppTheme.primary.withOpacity(0.06)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // ── Top row: variety + employee + status chip ──────
          Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.texture_rounded, color: AppTheme.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                p['variety_type']?.toString() ?? '-',
                style: const TextStyle(
                    color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 15),
              ),
              const SizedBox(height: 2),
              Text(
                'Batch: ${p['batch_id'] ?? '-'}  •  Employee #${p['employee_id'] ?? '-'}',
                style: TextStyle(color: AppTheme.primary.withOpacity(0.55), fontSize: 11),
              ),
            ])),
            const SizedBox(width: 8),
            _statusChip(status, isOwnerApproved),
          ]),

          const SizedBox(height: 14),

          // ── Stats row ─────────────────────────────────────
          Row(children: [
            _infoBox(label: 'Total',   value: '${p['total_length'] ?? 0} yds'),
            const SizedBox(width: 8),
            _infoBox(label: 'Ready',   value: '${p['ready_production'] ?? 0} yds'),
            const SizedBox(width: 8),
            _infoBox(label: 'Waste',   value: '${p['waste_production'] ?? 0}'),
          ]),

          const SizedBox(height: 8),

          Row(children: [
            _infoBox(label: 'Remaining', value: '${p['remaining'] ?? 0}'),
            const SizedBox(width: 8),
            _infoBox(label: 'Shift Start', value: _fmtDate(p['shift_start'])),
            const SizedBox(width: 8),
            _infoBox(label: 'Machine',  value: '#${p['machine_id'] ?? '-'}'),
          ]),

          // ── Owner-approved note ───────────────────────────
          if (isOwnerApproved) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.info.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(children: [
                const Icon(Icons.verified_outlined, size: 15, color: AppTheme.info),
                const SizedBox(width: 6),
                Expanded(
                  child: Text('Owner already approved this production',
                      style: TextStyle(
                          color: AppTheme.info.withOpacity(0.9),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600)),
                ),
              ]),
            ),
          ],

          // ── Action buttons ────────────────────────────────
          if (showActions) ...[
            const SizedBox(height: 14),
            Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _confirmAction(p['id'], 'reject'),
                  icon: const Icon(Icons.close_rounded, size: 16),
                  label: const Text('Reject'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.error,
                    side: const BorderSide(color: AppTheme.error),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _confirmAction(p['id'], 'approve'),
                  icon: const Icon(Icons.check_rounded, size: 16),
                  label: const Text('Approve'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.success,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                  ),
                ),
              ),
            ]),
          ],
        ]),
      ),
    );
  }

  void _confirmAction(dynamic id, String action) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(action == 'approve' ? 'Approve Production?' : 'Reject Production?'),
        content: Text(action == 'approve'
            ? 'This will mark the production as manager-approved.'
            : 'This will reject this production.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () { Navigator.pop(context); _doAction(id, action); },
            style: ElevatedButton.styleFrom(
              backgroundColor: action == 'approve' ? AppTheme.success : AppTheme.error,
            ),
            child: Text(action == 'approve' ? 'Approve' : 'Reject'),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(int status, bool isOwnerApproved) {
    Color bg;
    Color fg;
    String label;

    if (isOwnerApproved) {
      bg = AppTheme.info.withOpacity(0.15);
      fg = AppTheme.info;
      label = 'Owner ✓';
    } else if (status == 2) {
      bg = AppTheme.success.withOpacity(0.15);
      fg = AppTheme.success;
      label = 'Approved';
    } else if (status == 3) {
      bg = AppTheme.error.withOpacity(0.15);
      fg = AppTheme.error;
      label = 'Rejected';
    } else {
      bg = AppTheme.surface.withOpacity(0.15);
      fg = AppTheme.surface;
      label = 'Pending';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }

  Widget _infoBox({required String label, required String value}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.primary.withOpacity(0.06)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: TextStyle(
                  color: AppTheme.primary.withOpacity(0.5),
                  fontSize: 9,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 3),
          Text(value,
              style: const TextStyle(
                  color: AppTheme.textPrimary, fontSize: 12.5, fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }

  Widget _errorView() => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.error_outline_rounded, size: 48, color: AppTheme.error),
      const SizedBox(height: 12),
      Text(error ?? 'Something went wrong',
          style: const TextStyle(color: AppTheme.primary)),
      const SizedBox(height: 16),
      ElevatedButton(onPressed: _load, child: const Text('Retry')),
    ]),
  );

  String _fmtDate(dynamic raw) {
    if (raw == null) return '-';
    try {
      final dt = DateTime.parse(raw.toString());
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) { return raw.toString(); }
  }
}