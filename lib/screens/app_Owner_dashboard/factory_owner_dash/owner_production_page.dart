// lib/features/owner/pages/owner_productions_page.dart

import 'package:flutter/material.dart';
import '../../../../core/services/production_service.dart';
import '../../../../core/utils/theme.dart';

// ============================================================
// Models
// ============================================================

class ProductionItem {
  final int id;
  final String batchId;
  final String varietyType;
  final int status;
  final double totalLength;
  final double readyProduction;
  final double wasteProduction;
  final double remaining;
  final String? createdAt;
  final String? updatedAt;

  ProductionItem({
    required this.id,
    required this.batchId,
    required this.varietyType,
    required this.status,
    required this.totalLength,
    required this.readyProduction,
    required this.wasteProduction,
    required this.remaining,
    this.createdAt,
    this.updatedAt,
  });

  factory ProductionItem.fromJson(Map<String, dynamic> json) {
    return ProductionItem(
      id: int.tryParse(json['id'].toString()) ?? 0,
      batchId: json['batch_id']?.toString() ?? '-',
      varietyType: json['variety_type']?.toString() ?? '-',
      status: int.tryParse(json['status'].toString()) ?? 1,
      totalLength: double.tryParse(json['total_length'].toString()) ?? 0,
      readyProduction: double.tryParse(json['ready_production'].toString()) ?? 0,
      wasteProduction: double.tryParse(json['waste_production'].toString()) ?? 0,
      remaining: double.tryParse(json['remaining'].toString()) ?? 0,
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }
}

class MachineProductionGroup {
  final int? machineId;
  final String machineName;
  final int pendingCount;
  final int approvedCount;
  final List<ProductionItem> pending;
  final List<ProductionItem> approved;

  MachineProductionGroup({
    required this.machineId,
    required this.machineName,
    required this.pendingCount,
    required this.approvedCount,
    required this.pending,
    required this.approved,
  });

  factory MachineProductionGroup.fromJson(Map<String, dynamic> json) {
    return MachineProductionGroup(
      machineId: json['machine_id'] != null
          ? int.tryParse(json['machine_id'].toString())
          : null,
      machineName: json['machine_name']?.toString() ?? 'Unassigned',
      pendingCount: int.tryParse(json['pending_count'].toString()) ?? 0,
      approvedCount: int.tryParse(json['approved_count'].toString()) ?? 0,
      pending: (json['pending'] as List? ?? [])
          .map((e) => ProductionItem.fromJson(e))
          .toList(),
      approved: (json['approved'] as List? ?? [])
          .map((e) => ProductionItem.fromJson(e))
          .toList(),
    );
  }
}

class EmployeeProductions {
  final int employeeId;
  final String employeeName;
  final int machineCount;
  final int pendingCount;
  final int approvedCount;
  final List<MachineProductionGroup> machines;

  EmployeeProductions({
    required this.employeeId,
    required this.employeeName,
    required this.machineCount,
    required this.pendingCount,
    required this.approvedCount,
    required this.machines,
  });

  factory EmployeeProductions.fromJson(Map<String, dynamic> json) {
    return EmployeeProductions(
      employeeId: int.tryParse(json['employee_id'].toString()) ?? 0,
      employeeName: json['employee_name']?.toString() ?? '-',
      machineCount: int.tryParse(json['machine_count'].toString()) ?? 0,
      pendingCount: int.tryParse(json['pending_count'].toString()) ?? 0,
      approvedCount: int.tryParse(json['approved_count'].toString()) ?? 0,
      machines: (json['machines'] as List? ?? [])
          .map((e) => MachineProductionGroup.fromJson(e))
          .toList(),
    );
  }
}

// ============================================================
// Page
// ============================================================

class OwnerProductionsPage extends StatefulWidget {
  final dynamic factoryId;
  const OwnerProductionsPage({super.key, required this.factoryId});

  @override
  State<OwnerProductionsPage> createState() => _OwnerProductionsPageState();
}

class _OwnerProductionsPageState extends State<OwnerProductionsPage> {
  final _service = ProductionService();

  bool loading = true;
  String? error;
  List<EmployeeProductions> _employees = [];

  // false = Pending view, true = Approved view
  bool _showApproved = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final raw = await _service.getOwnerProductionsGrouped(widget.factoryId);
      final list = (raw['employees'] as List? ?? [])
          .map((e) => EmployeeProductions.fromJson(e as Map<String, dynamic>))
          .toList();
      setState(() {
        _employees = list;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.error),
      );
    }
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
            onPressed: () {
              Navigator.pop(context);
              _doAction(id, action);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: action == 'approve' ? AppTheme.success : AppTheme.error,
            ),
            child: Text(action == 'approve' ? 'Approve' : 'Reject'),
          ),
        ],
      ),
    );
  }

  int get _totalPending => _employees.fold(0, (s, e) => s + e.pendingCount);
  int get _totalApproved => _employees.fold(0, (s, e) => s + e.approvedCount);

  Widget _toggleButton({required bool approved}) {
    final selected = _showApproved == approved;
    return Container(
      decoration: BoxDecoration(
        color: selected ? AppTheme.primary : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppTheme.softShadow,
        border: selected ? null : Border.all(color: AppTheme.primary.withOpacity(0.15)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => setState(() => _showApproved = approved),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                approved ? Icons.verified_rounded : Icons.hourglass_top_rounded,
                color: selected ? AppTheme.secondary : AppTheme.primary,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                approved ? 'Approved (${_totalApproved})' : 'Pending (${_totalPending})',
                style: TextStyle(
                  color: selected ? AppTheme.secondary : AppTheme.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        elevation: 0,
        title: const Text('Owner Productions',
            style: TextStyle(
                color: AppTheme.textSecondary, fontWeight: FontWeight.w800, fontSize: 17)),
        iconTheme: const IconThemeData(color: AppTheme.secondary),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : error != null
              ? _errorView()
              : RefreshIndicator(
                  color: AppTheme.primary,
                  onRefresh: _load,
                  child: _buildEmployeeList(),
                ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _toggleButton(approved: false),
          const SizedBox(height: 12),
          _toggleButton(approved: true),
        ],
      ),
    );
  }

  Widget _buildEmployeeList() {
    // Sirf wo employees dikhao jinke paas is view (pending/approved) mein kam se kam 1 record ho
    final visible = _employees.where((e) {
      return _showApproved ? e.approvedCount > 0 : e.pendingCount > 0;
    }).toList();

    if (visible.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 80),
          Center(
            child: Column(children: [
              Icon(Icons.inbox_rounded, size: 52, color: AppTheme.neutral),
              const SizedBox(height: 12),
              const Text('No records found',
                  style: TextStyle(
                      color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
            ]),
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      itemCount: visible.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _EmployeeProductionTile(
        employee: visible[i],
        showApproved: _showApproved,
        onConfirmAction: _confirmAction,
      ),
    );
  }

  Widget _errorView() => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.error_outline_rounded, size: 48, color: AppTheme.error),
          const SizedBox(height: 12),
          Text(error ?? 'Something went wrong',
              style: const TextStyle(color: AppTheme.textPrimary)),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _load, child: const Text('Retry')),
        ]),
      );
}

// ============================================================
// Employee tile (dropdown: machine_count + pending/approved)
// ============================================================

class _EmployeeProductionTile extends StatelessWidget {
  final EmployeeProductions employee;
  final bool showApproved;
  final void Function(dynamic id, String action) onConfirmAction;

  const _EmployeeProductionTile({
    required this.employee,
    required this.showApproved,
    required this.onConfirmAction,
  });

  @override
  Widget build(BuildContext context) {
    final relevantMachines = employee.machines.where((m) {
      return showApproved ? m.approvedCount > 0 : m.pendingCount > 0;
    }).toList();

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.secondary,
        borderRadius: AppTheme.cardRadius,
        boxShadow: AppTheme.softShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.all(16),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.person_rounded, color: AppTheme.primary, size: 18),
          ),
          title: Text(
            employee.employeeName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                color: AppTheme.textPrimary, fontWeight: FontWeight.w800, fontSize: 14),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              '${employee.machineCount} machine${employee.machineCount == 1 ? '' : 's'} assigned  •  '
              '${showApproved ? employee.approvedCount : employee.pendingCount} '
              '${showApproved ? 'approved' : 'pending'}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: AppTheme.textPrimary.withOpacity(0.55), fontSize: 11),
            ),
          ),
          children: [
            ...relevantMachines.map((m) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _MachineProductionTile(
                    machine: m,
                    showApproved: showApproved,
                    onConfirmAction: onConfirmAction,
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// Machine tile (per machine: pending/approved count + list)
// ============================================================

class _MachineProductionTile extends StatelessWidget {
  final MachineProductionGroup machine;
  final bool showApproved;
  final void Function(dynamic id, String action) onConfirmAction;

  const _MachineProductionTile({
    required this.machine,
    required this.showApproved,
    required this.onConfirmAction,
  });

  @override
  Widget build(BuildContext context) {
    final items = showApproved ? machine.approved : machine.pending;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.primary.withOpacity(0.06)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          title: Text(
            machine.machineName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w700),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: (showApproved ? AppTheme.info : AppTheme.surface).withOpacity(.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${items.length}',
              style: TextStyle(
                color: showApproved ? AppTheme.info : AppTheme.textPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          children: items.isEmpty
              ? [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text('No records',
                        style: TextStyle(color: AppTheme.textPrimary, fontSize: 12)),
                  )
                ]
              : items
                  .map((p) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _ProductionCard(
                          item: p,
                          showActions: !showApproved,
                          onConfirmAction: onConfirmAction,
                        ),
                      ))
                  .toList(),
        ),
      ),
    );
  }
}

// ============================================================
// Single production card (with approve/reject when pending)
// ============================================================

class _ProductionCard extends StatelessWidget {
  final ProductionItem item;
  final bool showActions;
  final void Function(dynamic id, String action) onConfirmAction;

  const _ProductionCard({
    required this.item,
    required this.showActions,
    required this.onConfirmAction,
  });

  Widget _managerNote(int status) {
    String text;
    Color color;
    IconData icon;
    switch (status) {
      case 1:
        text = 'Manager: Not reviewed';
        color = AppTheme.surface;
        icon = Icons.hourglass_empty_rounded;
        break;
      case 2:
        text = 'Manager: Approved';
        color = AppTheme.success;
        icon = Icons.check_circle_outline_rounded;
        break;
      case 3:
        text = 'Manager: Rejected';
        color = AppTheme.error;
        icon = Icons.cancel_outlined;
        break;
      default:
        return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
      ]),
    );
  }

  Widget _infoBox({required String label, required String value}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 7),
        decoration: BoxDecoration(
          color: AppTheme.secondary,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.primary.withOpacity(0.06)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: TextStyle(
                  color: AppTheme.textPrimary.withOpacity(0.5),
                  fontSize: 9,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value,
                maxLines: 1,
                style: const TextStyle(
                    color: AppTheme.textPrimary, fontSize: 12, fontWeight: FontWeight.w700)),
          ),
        ]),
      ),
    );
  }

  String _fmtDateTime(dynamic raw) {
    if (raw == null) return '-';
    try {
      final dt = DateTime.parse(raw.toString()).toLocal();
      final hour = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
      final period = dt.hour >= 12 ? 'PM' : 'AM';
      final minute = dt.minute.toString().padLeft(2, '0');
      final year = dt.year.toString().substring(2);
      return '${dt.day}/${dt.month}/$year $hour:$minute$period';
    } catch (_) {
      return raw.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = showActions ? 'Submitted' : 'Approved';
    final dateValue = showActions ? item.createdAt : item.updatedAt;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.secondary,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.primary.withOpacity(0.06)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.texture_rounded, color: AppTheme.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(item.varietyType,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 14)),
          ),
          Text('Batch: ${item.batchId}',
              style: TextStyle(color: AppTheme.textPrimary.withOpacity(0.55), fontSize: 11)),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          _infoBox(label: 'Total', value: '${item.totalLength} yds'),
          const SizedBox(width: 8),
          _infoBox(label: 'Ready', value: '${item.readyProduction} yds'),
          const SizedBox(width: 8),
          _infoBox(label: 'Waste', value: '${item.wasteProduction}'),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          _infoBox(label: 'Remaining', value: '${item.remaining}'),
          const SizedBox(width: 8),
          _infoBox(label: dateLabel, value: _fmtDateTime(dateValue)),
        ]),
        const SizedBox(height: 8),
        _managerNote(item.status),
        if (showActions) ...[
          const SizedBox(height: 14),
          Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => onConfirmAction(item.id, 'reject'),
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
                onPressed: () => onConfirmAction(item.id, 'approve'),
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
    );
  }
}