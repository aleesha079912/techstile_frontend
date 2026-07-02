// lib/features/owner/pages/owner_productions_page.dart

import 'package:flutter/material.dart';
import '../../../core/services/production_service.dart';
import '../../../core/utils/theme.dart';
// import 'package:techstile_frontend/widgets/bottom_nav_bar.dart';
class OwnerProductionsPage extends StatefulWidget {
  final dynamic factoryId;
  const OwnerProductionsPage({super.key, required this.factoryId});

  @override
  State<OwnerProductionsPage> createState() => _OwnerProductionsPageState();
}

class _OwnerProductionsPageState extends State<OwnerProductionsPage>
    with SingleTickerProviderStateMixin {
  final _service = ProductionService();
  late TabController _tab;

  bool loading = true;
  String? error;
  List<Map<String, dynamic>> _all = [];

  @override
void initState() {
  super.initState();

  print("Received Factory ID = ${widget.factoryId}");

  _tab = TabController(length: 2, vsync: this);
  _load();
}

  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  Future<void> _load() async {
    setState(() { loading = true; error = null; });
    try {
      final list = await _service.getOwnerProductions(widget.factoryId);
      setState(() { _all = list; loading = false; });
    } catch (e) {
      setState(() { error = e.toString(); loading = false; });
    }
  }

  // Owner pending = everything NOT yet owner-approved/rejected (status 1,2,3)
  List<Map<String, dynamic>> get _pending =>
      _all.where((p) {
        final s = p['status'] as int? ?? 1;
        return s != 4 && s != 5;
      }).toList();

  List<Map<String, dynamic>> get _approved =>
      _all.where((p) => (p['status'] as int? ?? 1) == 4).toList();

  Future<void> _doAction(dynamic id, String action) async {
    try {
      await _service.ownerAction(id, action);
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(action == 'approve' ? 'Approved ✓' : 'Rejected'),
        backgroundColor: action == 'approve' ? AppTheme.success : AppTheme.error,
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.error));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        elevation: 0,
        title: const Text('Owner Productions',
            style: TextStyle(color:  AppTheme.secondary, fontWeight: FontWeight.w800, fontSize: 17)),
        iconTheme: const IconThemeData(color:  AppTheme.secondary),
        bottom: TabBar(
          controller: _tab,
          indicatorColor: AppTheme.secondary,
          indicatorWeight: 3,
          labelColor:  AppTheme.secondary,
          unselectedLabelColor:  AppTheme.neutral,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
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
              //  bottomNavigationBar: CustomBottomNav(currentIndex: 0, factoryId: widget.factoryId),
    );
  }

  Widget _buildList(List<Map<String, dynamic>> items, {required bool showActions}) {
    if (items.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.inbox_rounded, size: 52, color:  AppTheme.neutral),
          const SizedBox(height: 12),
          const Text('No records found',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
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
    final status = p['status'] as int? ?? 1;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.secondary,
        borderRadius: AppTheme.cardRadius,
        boxShadow: AppTheme.softShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // ── Header ────────────────────────────────────────
          Row(children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: AppTheme.secondary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.texture_rounded, color: AppTheme.secondary, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                p['variety_type']?.toString() ?? '-',   // ← direct column
                style: const TextStyle(
                    color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 14),
              ),
              Text(
                'Batch: ${p['batch_id'] ?? '-'}  •  Emp #${p['employee_id'] ?? '-'}',
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
              ),
            ])),
            _statusChip(status),
          ]),

          const SizedBox(height: 12),

          // ── Stats ─────────────────────────────────────────
          Row(children: [
            _infoBox(label: 'Total',   value: '${p['total_length'] ?? 0} yds'),
            const SizedBox(width: 8),
            _infoBox(label: 'Ready',   value: '${p['ready_production'] ?? 0} yds'),
            const SizedBox(width: 8),
            _infoBox(label: 'Waste',   value: '${p['waste_production'] ?? 0}'),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            _infoBox(label: 'Remaining',   value: '${p['remaining'] ?? 0}'),
            const SizedBox(width: 8),
            _infoBox(label: 'Machine',     value: '#${p['machine_id'] ?? '-'}'),
            const SizedBox(width: 8),
            _infoBox(label: 'Date',        value: _fmtDate(p['created_at'])),
          ]),

          // ── Manager status note ───────────────────────────
          const SizedBox(height: 8),
          _managerNote(status),

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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
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
                    foregroundColor: AppTheme.secondary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ]),
          ],
        ]),
      ),
    );
  }

  Widget _managerNote(int status) {
    String text; Color color; IconData icon;
    switch (status) {
      case 1: text = 'Manager: Not reviewed'; color = AppTheme.surface;
              icon = Icons.hourglass_empty_rounded; break;
      case 2: text = 'Manager: Approved';     color = AppTheme.success;
              icon = Icons.check_circle_outline_rounded; break;
      case 3: text = 'Manager: Rejected';     color = AppTheme.error;
              icon = Icons.cancel_outlined; break;
      default: return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500)),
      ]),
    );
  }

  void _confirmAction(dynamic id, String action) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(action == 'approve' ? 'Approve Production?' : 'Reject Production?'),
        content: const Text('This action will update the production status.'),
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

  Widget _statusChip(int status) {
    Color bg; Color fg; String label;
    switch (status) {
      case 2: bg = AppTheme.success.withOpacity(.12); fg = AppTheme.success;       label = 'Mgr ✓'; break;
      case 3: bg = AppTheme.error.withOpacity(.12);   fg = AppTheme.error;         label = 'Mgr ✗'; break;
      case 4: bg = Colors.blue.shade50;               fg = AppTheme.info;   label = 'Approved'; break;
      case 5: bg = AppTheme.error.withOpacity(.12);   fg = AppTheme.error;         label = 'Rejected'; break;
      default: bg = Colors.orange.shade50;            fg = AppTheme.surface; label = 'Pending';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }

  Widget _infoBox({required String label, required String value}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        decoration: BoxDecoration(
          color: AppTheme.neutral.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 9)),
          const SizedBox(height: 2),
          Text(value,
              style: const TextStyle(
                  color: AppTheme.textPrimary, fontSize: 12, fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }

  Widget _errorView() => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.error_outline_rounded, size: 48, color: AppTheme.error),
      const SizedBox(height: 12),
      Text(error ?? 'Something went wrong',
          style: const TextStyle(color: AppTheme.textSecondary)),
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