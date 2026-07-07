import 'package:flutter/material.dart';
import 'package:techstile_frontend/core/utils/theme.dart';


class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  int _filterIndex = 0;

  final List<_Notif> _notifications = [
    _Notif(
      title: "Factory Added Successfully",
      body: "Al-Kareem Textiles Ltd. has been registered to your account.",
      time: "2 min ago",
      type: NotifType.success,
      isRead: false,
    ),
    _Notif(
      title: "Low Stock Alert",
      body: "Fabric inventory at Lahore unit is below minimum threshold.",
      time: "1 hr ago",
      type: NotifType.warning,
      isRead: false,
    ),
    _Notif(
      title: "New Order Received",
      body: "Order #TXT-4821 has been placed for 200 meters of denim fabric.",
      time: "3 hr ago",
      type: NotifType.info,
      isRead: true,
    ),
    _Notif(
      title: "Payment Overdue",
      body: "Invoice #INV-209 is 5 days overdue. Please follow up with the buyer.",
      time: "Yesterday",
      type: NotifType.error,
      isRead: false,
    ),
    _Notif(
      title: "Monthly Report Ready",
      body: "Your production summary for April 2026 is now available.",
      time: "2 days ago",
      type: NotifType.info,
      isRead: true,
    ),
    _Notif(
      title: "Worker Attendance Updated",
      body: "Attendance for 24 workers has been recorded for today.",
      time: "3 days ago",
      type: NotifType.success,
      isRead: true,
    ),
    _Notif(
      title: "Machinery Maintenance Due",
      body: "Loom #3 at Faisalabad unit is due for scheduled maintenance.",
      time: "4 days ago",
      type: NotifType.warning,
      isRead: true,
    ),
  ];

  List<_Notif> get _filtered {
    if (_filterIndex == 0) return _notifications;
    if (_filterIndex == 1) return _notifications.where((n) => !n.isRead).toList();
    return _notifications.where((n) => n.isRead).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _buildHeader(),
          _buildFilterRow(),
          Expanded(
            child: _filtered.isEmpty
                ? _buildEmpty()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 80),
                    itemCount: _filtered.length,
                    itemBuilder: (context, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _NotifCard(
                        notif: _filtered[i],
                        onTap: () {
                          setState(() => _filtered[i].isRead = true);
                        },
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final unread = _notifications.where((n) => !n.isRead).length;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primary, AppTheme.info],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color:AppTheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.secondary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
                Icons.notifications_rounded, color:AppTheme.secondary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Notifications",
                  style: TextStyle(
                    color: AppTheme.secondary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  unread > 0
                      ? "$unread unread alerts"
                      : "All caught up",
                  style: const TextStyle(
                    color: AppTheme.neutral,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
          if (unread > 0)
            GestureDetector(
              onTap: () => setState(() {
                for (final n in _notifications) {
                  n.isRead = true;
                }
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color:AppTheme.secondary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  "Mark all read",
                  style: TextStyle(
                    color: AppTheme.secondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
    const labels = ["All", "Unread", "Read"];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Row(
        children: List.generate(labels.length, (i) {
          final active = _filterIndex == i;
          return GestureDetector(
            onTap: () => setState(() => _filterIndex = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: active ? AppTheme.primary :AppTheme.secondary,
                borderRadius: BorderRadius.circular(20),
                boxShadow: active
                    ? [
                        BoxShadow(
                          color: AppTheme.primary.withOpacity(0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        )
                      ]
                    : [],
              ),
              child: Text(
                labels[i],
                style: TextStyle(
                  color: active ? AppTheme.secondary : AppTheme.neutral,
                  fontWeight:
                      active ? FontWeight.w600 : FontWeight.w400,
                  fontSize: 13,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppTheme.secondary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
                Icons.notifications_off_outlined, color:AppTheme.primary, size: 34),
          ),
          const SizedBox(height: 14),
          const Text(
            "No notifications",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppTheme.neutral,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            "You're all caught up!",
            style: TextStyle(fontSize: 13, color:AppTheme.neutral),
          ),
        ],
      ),
    );
  }
}

// ─── Models ──────────────────────────────────────────────────
enum NotifType { success, warning, error, info }

class _Notif {
  final String title;
  final String body;
  final String time;
  final NotifType type;
  bool isRead;

  _Notif({
    required this.title,
    required this.body,
    required this.time,
    required this.type,
    required this.isRead,
  });
}

// ─── Notif Card ──────────────────────────────────────────────
class _NotifCard extends StatelessWidget {
  final _Notif notif;
  final VoidCallback onTap;

  const _NotifCard({required this.notif, required this.onTap});

  static const _configs = {
    NotifType.success: (
      color: AppTheme.success,
      bg: Color(0xFFD1FAE5),
      icon: Icons.check_circle_rounded,
    ),
    NotifType.warning: (
      color:AppTheme.surface,
      bg: Color(0xFFFEF3C7),
      icon: Icons.warning_rounded,
    ),
    NotifType.error: (
      color:  AppTheme.error,
      bg: Color(0xFFFEE2E2),
      icon: Icons.error_rounded,
    ),
    NotifType.info: (
      color:AppTheme.info,
      bg: AppTheme.background,
      icon: Icons.info_rounded,
    ),
  };

  @override
  Widget build(BuildContext context) {
    final cfg = _configs[notif.type]!;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: AppTheme.secondary,
          borderRadius: BorderRadius.circular(16),
          border: notif.isRead
              ? null
              : Border.all(
                  color: cfg.color.withOpacity(0.3),
                  width: 1,
                ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: cfg.bg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(cfg.icon, color: cfg.color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notif.title,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: notif.isRead
                                ? FontWeight.w500
                                : FontWeight.w700,
                            color:  AppTheme.info,
                          ),
                        ),
                      ),
                      if (!notif.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(left: 8, top: 4),
                          decoration: BoxDecoration(
                            color: cfg.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notif.body,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.neutral,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notif.time,
                    style: TextStyle(
                      fontSize: 10.5,
                      color: AppTheme.neutral.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}