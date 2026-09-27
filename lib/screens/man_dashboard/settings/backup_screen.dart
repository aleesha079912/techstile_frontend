import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/backup_service.dart';
import '../../../core/utils/theme.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  List<dynamic> backups = [];
  bool loading = true;
  bool working = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  String _err(Object e) => e.toString().replaceFirst('Exception: ', '');

  Future<void> _load() async {
    try {
      final data = await BackupService.list();
      if (!mounted) return;
      setState(() {
        backups = data['backups'] ?? [];
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      Get.snackbar('Error', _err(e));
    }
  }

  Future<void> _backupNow() async {
    setState(() => working = true);
    try {
      await BackupService.backupNow();
      Get.snackbar('Done', 'Backup is created');
      await _load();
    } catch (e) {
      Get.snackbar('Error', _err(e));
    }
    if (mounted) setState(() => working = false);
  }

  void _confirmRestore(Map b) {
    Get.defaultDialog(
      title: 'Restore Backup',
      middleText:
          'This backup data replace with new data that is currently in database.\n(Before Restore safety backup is automatically creadted.)',
      textCancel: 'No',
      textConfirm: 'Restore',
      confirmTextColor: AppTheme.secondary,
      cancelTextColor: AppTheme.primary,
      buttonColor: AppTheme.primary,
      onConfirm: () {
        Get.back();
        _restore(b['id']);
      },
    );
  }

  Future<void> _restore(int id) async {
    setState(() => working = true);
    try {
      final msg = await BackupService.restore(id);
      Get.snackbar('Done', msg);
      await _load();
    } catch (e) {
      Get.snackbar('Error', _err(e));
    }
    if (mounted) setState(() => working = false);
  }

  String _date(String? iso) {
    if (iso == null) return '';
    final d = DateTime.parse(iso).toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}-${two(d.month)}-${d.year}  ${two(d.hour)}:${two(d.minute)}';
  }

  Color _statusColor(String s) {
    if (s == 'completed') return Colors.green;
    if (s == 'failed') return AppTheme.error;
    return Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          'Backups',
          style: TextStyle(
              color: AppTheme.primary,
              fontWeight: FontWeight.w800,
              fontSize: 24),
        ),
        backgroundColor: AppTheme.secondary,
        iconTheme: const IconThemeData(color: AppTheme.primary),
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: working ? null : _backupNow,
                icon: working
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.backup_outlined),
                label: Text(working ? 'Please wait' : 'Backup Now'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: AppTheme.secondary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _load,
                    child: backups.isEmpty
                        ? ListView(children: const [
                            SizedBox(height: 120),
                            Center(child: Text('No Backup')),
                          ])
                        : ListView.builder(
                            padding:
                                const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            itemCount: backups.length,
                            itemBuilder: (_, i) => _backupCard(backups[i]),
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _backupCard(Map b) {
    final status = (b['status'] ?? '').toString();
    final size = ((b['size'] ?? 0) / 1024).toStringAsFixed(1);
    final by = b['creator']?['name'] ?? 'Auto';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.secondary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.14),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_date(b['created_at']),
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppTheme.textPrimary)),
                const SizedBox(height: 4),
                Text('${b['type']}  •  $size KB  •  $by',
                    style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textPrimary.withOpacity(0.6))),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _statusColor(status).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(status,
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _statusColor(status))),
                ),
              ],
            ),
          ),
          if (status == 'completed')
            TextButton(
              onPressed: working ? null : () => _confirmRestore(b),
              child: const Text('Restore'),
            ),
        ],
      ),
    );
  }
}