import 'package:flutter/material.dart';
import 'package:techstile_frontend/widgets/owner_drawer.dart';
import '../../core/services/payments_service.dart';
import '../../core/utils/theme.dart'; 
import '../../../../widgets/bottom_nav_bar.dart';
import '../../widgets/factorydrawer.dart'; 

// ── Text styles ───────────────────────────────────────────────────────────────
const _kSora = 'Sora';

TextStyle _ts(double size, FontWeight w, Color c, {double? ls}) =>
    TextStyle(fontFamily: _kSora, fontSize: size, fontWeight: w, color: c, letterSpacing: ls);

// ── Screen ───────────────────────────────────────────────────────────────────
class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key, required this.factoryId});

  final int factoryId;

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  final _svc = PaymentsService.instance;

  @override
  void initState() {
    super.initState();
    _svc.load().then((_) => setState(() {}));
  }

  void _approve(String id) => setState(() => _svc.approve(id));
  void _hold(String id) => setState(() => _svc.hold(id));
  void _approveAll() => setState(() => _svc.approveAll());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, 
      
      // 1. Drawer yahan sahi hai
      // FactoryDrawer requires a userID parameter; pass factoryId as userID to satisfy the requirement
      drawer: FactoryDrawer(factoryId: widget.factoryId, userID: widget.factoryId), // ✅ PASS FACTORY ID HER
      
      appBar: _appBar(context),
      body: _svc.isLoading
          ? Center(child: CircularProgressIndicator(color: colors.primary, strokeWidth: 2))
          : _body(context),
      bottomNavigationBar: CustomBottomNav(currentIndex: 2, factoryId: widget.factoryId),
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────────────────
  PreferredSizeWidget _appBar(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    
    return AppBar(
      backgroundColor:  AppTheme.background, 
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      
      // 2. Yahan Builder add kiya taake Menu icon se drawer khul sake
      leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(Icons.menu_rounded, color: colors.primary), // Menu Icon
          onPressed: () => Scaffold.of(context).openDrawer(), // Drawer open trigger
        ),
      ),
      
      title: Text('TextileOS', 
        style: _ts(17, FontWeight.w700, colors.primary)),
      actions: [
        IconButton(
          icon: Icon(Icons.notifications_none_rounded, color: colors.primary, size: 22),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  // ── Body (No changes needed here) ──────────────────────────────────────────
  Widget _body(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final neutral = AppTheme.secondary;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('FINANCIAL CONTROL', style: _ts(10, FontWeight.w600, neutral, ls: 1.4)),
          const SizedBox(height: 4),
          Text('Payments', style: _ts(34, FontWeight.w800, colors.primary)),
          const SizedBox(height: 6),
          Text(
            'Review and authorize pending worker disbursements for the current production cycle.',
            style: _ts(13, FontWeight.w400, neutral),
          ),
          const SizedBox(height: 18),

          ElevatedButton.icon(
            onPressed: _approveAll,
            icon: const Icon(Icons.check_circle_outline, size: 16, color: AppTheme.secondary),
            label: Text('Approve All', style: _ts(13, FontWeight.w700,  AppTheme.secondary)),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
          ),
          const SizedBox(height: 22),

          ..._svc.workers.map((w) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _WorkerCard(
                  worker: w,
                  onApprove: () => _approve(w.id),
                  onHold: () => _hold(w.id),
                ),
              )),

          if (_svc.cutoffInfo != null) _CutoffCard(info: _svc.cutoffInfo!),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
// ── Worker Card ───────────────────────────────────────────────────────────────
class _WorkerCard extends StatelessWidget {
  final PaymentWorker worker;
  final VoidCallback onApprove;
  final VoidCallback onHold;

  const _WorkerCard({
    required this.worker,
    required this.onApprove,
    required this.onHold,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final neutral = AppTheme.secondary;
    final bool isPriority = worker.status == PaymentStatus.priorityReview;

    return Container(
      decoration: BoxDecoration(
        color: isPriority ? colors.primary.withOpacity(0.9) :  AppTheme.secondary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:  AppTheme.onsurface.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  worker.name,
                  style: _ts(15, FontWeight.w700, isPriority ?  AppTheme.secondary : colors.primary),
                ),
              ),
              _StatusBadge(status: worker.status),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            worker.role,
            style: _ts(11, FontWeight.w400, isPriority ? AppTheme.neutral: neutral),
          ),
          const SizedBox(height: 14),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('AMOUNT DUE',
                      style: _ts(9, FontWeight.w600, isPriority ?  AppTheme.neutral: neutral, ls: 1.2)),
                  const SizedBox(height: 4),
                  Text(
                    worker.formattedAmount,
                    style: _ts(26, FontWeight.w800, isPriority ?  AppTheme.secondary: colors.primary),
                  ),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('PERIOD',
                      style: _ts(9, FontWeight.w600, isPriority ?  AppTheme.neutral: neutral, ls: 1.2)),
                  const SizedBox(height: 4),
                  Text(
                    worker.period,
                    style: _ts(11, FontWeight.w500, isPriority ?  AppTheme.secondary : colors.primary),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (worker.action == PaymentAction.none)
            Row(
              children: [
                Expanded(child: _HoldBtn(onTap: onHold, dark: isPriority)),
                const SizedBox(width: 10),
                Expanded(child: _ApproveBtn(onTap: onApprove, dark: isPriority)),
              ],
            )
          else
            _ActionDone(action: worker.action, isPriority: isPriority),
        ],
      ),
    );
  }
}

// ── Status badge ──────────────────────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final PaymentStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    
    final (label, bg, fg) = switch (status) {
      PaymentStatus.verified => ('VERIFIED', colors.secondary.withOpacity(0.2), colors.secondary),
      PaymentStatus.pending => ('PENDING',  AppTheme.info, AppTheme.secondary),
      PaymentStatus.priorityReview => ('PRIORITY REVIEW',  AppTheme.onsurface,  AppTheme.secondary),
      PaymentStatus.adjustment => ('ADJUSTMENT',  AppTheme.secondary,  AppTheme.surface),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: _ts(9, FontWeight.w700, fg, ls: 0.6)),
    );
  }
}

// ── Buttons ───────────────────────────────────────────────────────────────────
class _HoldBtn extends StatelessWidget {
  final VoidCallback onTap;
  final bool dark;
  const _HoldBtn({required this.onTap, required this.dark});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textColor = dark ?  AppTheme.secondary : colors.primary;

    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(Icons.pause, size: 14, color: textColor),
      label: Text('Hold', style: _ts(12, FontWeight.w700, textColor)),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: dark ?  AppTheme.onsurface: AppTheme.secondary, width: 1.5),
        padding: const EdgeInsets.symmetric(vertical: 11),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class _ApproveBtn extends StatelessWidget {
  final VoidCallback onTap;
  final bool dark;
  const _ApproveBtn({required this.onTap, required this.dark});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.check, size: 14, color: AppTheme.secondary),
      label: Text('Approve', style: _ts(12, FontWeight.w700 ,  AppTheme.secondary)),
      style: ElevatedButton.styleFrom(
        backgroundColor: dark ?  AppTheme.onsurface: colors.primary,
        padding: const EdgeInsets.symmetric(vertical: 11),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
      ),
    );
  }
}

class _ActionDone extends StatelessWidget {
  final PaymentAction action;
  final bool isPriority;
  const _ActionDone({required this.action, required this.isPriority});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isApproved = action == PaymentAction.approved;
    final statusColor = isApproved ? colors.secondary : AppTheme.secondary;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isApproved ? Icons.check_circle_outline : Icons.pause_circle_outline,
            size: 16,
            color: statusColor,
          ),
          const SizedBox(width: 6),
          Text(
            isApproved ? 'Approved' : 'On Hold',
            style: _ts(12, FontWeight.w700, statusColor),
          ),
        ],
      ),
    );
  }
}

// ── Cutoff card ───────────────────────────────────────────────────────────────
class _CutoffCard extends StatelessWidget {
  final CutoffInfo info;
  const _CutoffCard({required this.info});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final neutral = AppTheme.secondary;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color:  AppTheme.secondary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.onsurface.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline_rounded, color: colors.primary, size: 18),
              const SizedBox(width: 8),
              Text('Next Cutoff', style: _ts(15, FontWeight.w700, colors.primary)),
            ],
          ),
          const SizedBox(height: 10),
          RichText(
            text: TextSpan(
              style: _ts(13, FontWeight.w400, neutral),
              children: [
                const TextSpan(text: 'The current cycle ends in '),
                TextSpan(
                  text: '${info.daysLeft} days',
                  style: _ts(13, FontWeight.w700, colors.primary),
                ),
                TextSpan(text: '. All approvals must be completed by ${info.deadline}.'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Compliance Level', style: _ts(12, FontWeight.w500, neutral)),
              Text('${info.complianceLevel}%',
                  style: _ts(12, FontWeight.w700, colors.primary)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: info.complianceLevel / 100,
              minHeight: 5,
              backgroundColor:  AppTheme.background,
              valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
            ),
          ),
        ],
      ),
    );
  }
}