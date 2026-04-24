import 'package:flutter/material.dart';

import '../../core/services/payments_service.dart';

// ── Colours ──────────────────────────────────────────────────────────────────
class _C {
  static const bg = Color(0xFFF5F6FA);
  static const navy = Color(0xFF0D1B4B);
  static const navyCard = Color(0xFF1A2F6F);
  static const teal = Color(0xFF00C8B0);
  static const white = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF0D1B4B);
  static const textSub = Color(0xFF8A93A8);
  static const divider = Color(0xFFE8EBF3);
  static const red = Color(0xFFE84545);
  static const orange = Color(0xFFFF8C42);
}

// ── Text styles ───────────────────────────────────────────────────────────────
const _kSora = 'Sora';

TextStyle _ts(double size, FontWeight w, Color c, {double? ls}) =>
    TextStyle(fontFamily: _kSora, fontSize: size, fontWeight: w, color: c, letterSpacing: ls);

// ── Screen ───────────────────────────────────────────────────────────────────
class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

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
    return Scaffold(
      backgroundColor: _C.bg,
      appBar: _appBar(),
      body: _svc.isLoading
          ? const Center(child: CircularProgressIndicator(color: _C.navy, strokeWidth: 2))
          : _body(),
      bottomNavigationBar: _bottomNav(),
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────────────────
  PreferredSizeWidget _appBar() => AppBar(
        backgroundColor: _C.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leadingWidth: 52,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: _C.navy,
            child: const Icon(Icons.person_outline_rounded, color: _C.white, size: 18),
          ),
        ),
        title: Text('TextileOS', style: _ts(17, FontWeight.w700, _C.textPrimary)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: _C.textPrimary, size: 22),
            onPressed: () {},
          ),
        ],
      );

  // ── Body ───────────────────────────────────────────────────────────────────
  Widget _body() => SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text('FINANCIAL CONTROL', style: _ts(10, FontWeight.w600, _C.textSub, ls: 1.4)),
            const SizedBox(height: 4),
            Text('Payments', style: _ts(34, FontWeight.w800, _C.textPrimary)),
            const SizedBox(height: 6),
            Text(
              'Review and authorize pending worker disbursements for the current production cycle.',
              style: _ts(13, FontWeight.w400, _C.textSub),
            ),
            const SizedBox(height: 18),

            // Approve All button
            ElevatedButton.icon(
              onPressed: _approveAll,
              icon: const Icon(Icons.check_circle_outline, size: 16, color: _C.white),
              label: Text('Approve All', style: _ts(13, FontWeight.w700, _C.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _C.navy,
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
            const SizedBox(height: 22),

            // Worker cards
            ..._svc.workers.map((w) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _WorkerCard(
                    worker: w,
                    onApprove: () => _approve(w.id),
                    onHold: () => _hold(w.id),
                  ),
                )),

            // Cutoff info
            if (_svc.cutoffInfo != null) _CutoffCard(info: _svc.cutoffInfo!),
            const SizedBox(height: 20),
          ],
        ),
      );

  // ── Bottom Nav ─────────────────────────────────────────────────────────────
  Widget _bottomNav() {
    const tabs = [
      (Icons.grid_view_rounded, 'DASHBOARD'),
      (Icons.precision_manufacturing_outlined, 'MACHINES'),
      (Icons.credit_card_outlined, 'PAYMENTS'),
      (Icons.group_outlined, 'USERS'),
    ];
    const activeIndex = 2;

    return Container(
      color: _C.navy,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            children: List.generate(tabs.length, (i) {
              final selected = i == activeIndex;
              final color = selected ? _C.teal : const Color(0xFF6A7AA1);
              return Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(tabs[i].$1, size: 20, color: color),
                    const SizedBox(height: 4),
                    Text(tabs[i].$2,
                        style: _ts(9, FontWeight.w500, color, ls: 0.4)),
                  ],
                ),
              );
            }),
          ),
        ),
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

  bool get _isPriority => worker.status == PaymentStatus.priorityReview;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _isPriority ? _C.navyCard : _C.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name + badge row
          Row(
            children: [
              Expanded(
                child: Text(
                  worker.name,
                  style: _ts(15, FontWeight.w700, _isPriority ? _C.white : _C.textPrimary),
                ),
              ),
              _StatusBadge(status: worker.status),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            worker.role,
            style: _ts(11, FontWeight.w400,
                _isPriority ? const Color(0xFF7FAAFF) : _C.textSub),
          ),
          const SizedBox(height: 14),

          // Amount + period row
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('AMOUNT DUE',
                      style: _ts(9, FontWeight.w600,
                          _isPriority ? const Color(0xFF8A99C7) : _C.textSub, ls: 1.2)),
                  const SizedBox(height: 4),
                  Text(
                    worker.formattedAmount,
                    style: _ts(26, FontWeight.w800,
                        _isPriority ? _C.white : _C.textPrimary),
                  ),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('PERIOD',
                      style: _ts(9, FontWeight.w600,
                          _isPriority ? const Color(0xFF8A99C7) : _C.textSub, ls: 1.2)),
                  const SizedBox(height: 4),
                  Text(
                    worker.period,
                    style: _ts(11, FontWeight.w500,
                        _isPriority ? _C.white : _C.textPrimary),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Action buttons
          if (worker.action == PaymentAction.none)
            Row(
              children: [
                Expanded(child: _HoldBtn(onTap: onHold, dark: _isPriority)),
                const SizedBox(width: 10),
                Expanded(child: _ApproveBtn(onTap: onApprove, dark: _isPriority)),
              ],
            )
          else
            _ActionDone(action: worker.action, isPriority: _isPriority),
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
    final (label, bg, fg) = switch (status) {
      PaymentStatus.verified => ('VERIFIED', const Color(0xFFDFFAF6), _C.teal),
      PaymentStatus.pending => ('PENDING', const Color(0xFFEEEFF4), _C.textSub),
      PaymentStatus.priorityReview => ('PRIORITY REVIEW', const Color(0xFF0D1B4B), _C.white),
      PaymentStatus.adjustment => ('ADJUSTMENT', const Color(0xFFFFEEDD), _C.orange),
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
  Widget build(BuildContext context) => OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(Icons.pause, size: 14,
            color: dark ? _C.white : _C.textPrimary),
        label: Text('Hold',
            style: _ts(12, FontWeight.w700, dark ? _C.white : _C.textPrimary)),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: dark ? _C.white.withOpacity(0.3) : _C.divider, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 11),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
}

class _ApproveBtn extends StatelessWidget {
  final VoidCallback onTap;
  final bool dark;
  const _ApproveBtn({required this.onTap, required this.dark});

  @override
  Widget build(BuildContext context) => ElevatedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.check, size: 14, color: _C.white),
        label: Text('Approve', style: _ts(12, FontWeight.w700, _C.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: dark ? _C.navy : _C.navy,
          padding: const EdgeInsets.symmetric(vertical: 11),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 0,
        ),
      );
}

class _ActionDone extends StatelessWidget {
  final PaymentAction action;
  final bool isPriority;
  const _ActionDone({required this.action, required this.isPriority});

  @override
  Widget build(BuildContext context) {
    final isApproved = action == PaymentAction.approved;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: isApproved
            ? _C.teal.withOpacity(0.12)
            : _C.textSub.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isApproved ? Icons.check_circle_outline : Icons.pause_circle_outline,
            size: 16,
            color: isApproved ? _C.teal : _C.textSub,
          ),
          const SizedBox(width: 6),
          Text(
            isApproved ? 'Approved' : 'On Hold',
            style: _ts(12, FontWeight.w700, isApproved ? _C.teal : _C.textSub),
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
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _C.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
              const Icon(Icons.info_outline_rounded, color: _C.navy, size: 18),
              const SizedBox(width: 8),
              Text('Next Cutoff', style: _ts(15, FontWeight.w700, _C.textPrimary)),
            ],
          ),
          const SizedBox(height: 10),
          RichText(
            text: TextSpan(
              style: _ts(13, FontWeight.w400, _C.textSub),
              children: [
                const TextSpan(text: 'The current cycle ends in '),
                TextSpan(
                  text: '${info.daysLeft} days',
                  style: _ts(13, FontWeight.w700, _C.textPrimary),
                ),
                TextSpan(text: '. All approvals must be completed by ${info.deadline}.'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Compliance Level', style: _ts(12, FontWeight.w500, _C.textSub)),
              Text('${info.complianceLevel}%',
                  style: _ts(12, FontWeight.w700, _C.textPrimary)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: info.complianceLevel / 100,
              minHeight: 5,
              backgroundColor: _C.divider,
              valueColor: const AlwaysStoppedAnimation<Color>(_C.navy),
            ),
          ),
        ],
      ),
    );
  }
}
