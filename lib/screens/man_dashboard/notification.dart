import 'package:flutter/material.dart';

import '../../core/services/notification_service.dart';
import '../../core/services/auth_service.dart';
import '../../../core/utils/theme.dart';

class NotificationPage extends StatefulWidget {
  final Widget? drawer;
  final String title;

  const NotificationPage({
    super.key,
    this.drawer,
    this.title = "Notifications",
  });

  @override
  State<NotificationPage> createState() => _State();
}

class _State extends State<NotificationPage> {
  final service = NotificationService();

  List data = [];
  List filteredData = [];

  bool loading = true;

  String selectedFilter = "All";
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final id = AuthService.userId;
      if (id == null) {
        if (mounted) {
          setState(() {
            data = [];
            filteredData = [];
            loading = false;
          });
        }
        return;
      }
      final result = await service.getNotifications(id);

      if (mounted) {
        setState(() {
          data = result;
          loading = false;
        });
        applyFilters();
      }
    } catch (e) {
      debugPrint("Notification load error: $e");
      if (mounted) {
        setState(() {
          data = [];
          filteredData = [];
          loading = false;
        });
      }
    }
  }

  bool _isUnread(dynamic n) {
    return n['is_read'].toString() != "true" && n['is_read'] != true && n['is_read'] != 1;
  }

  DateTime? _parseDate(dynamic n) {
    final raw = n['created_at'];
    if (raw == null) return null;
    return DateTime.tryParse(raw.toString());
  }

  void applyFilters() {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final startOfWeek = startOfToday.subtract(Duration(days: now.weekday - 1));

    setState(() {
      filteredData = data.where((n) {
        final title = (n['title'] ?? '').toString().toLowerCase();
        final message = (n['message'] ?? '').toString().toLowerCase();
        final matchesQuery = searchQuery.isEmpty ||
            title.contains(searchQuery.toLowerCase()) ||
            message.contains(searchQuery.toLowerCase());

        if (!matchesQuery) return false;

        if (selectedFilter == "Unread") {
          return _isUnread(n);
        }

        if (selectedFilter == "Today") {
          final date = _parseDate(n);
          return date != null && !date.isBefore(startOfToday);
        }

        if (selectedFilter == "This Week") {
          final date = _parseDate(n);
          return date != null && !date.isBefore(startOfWeek);
        }

        return true;
      }).toList();
    });
  }

  void selectFilter(String filter) {
    selectedFilter = filter;
    applyFilters();
  }

  String _timeAgo(dynamic n) {
    final date = _parseDate(n);
    if (date == null) return '';
    final diff = DateTime.now().difference(date);

    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = data.where(_isUnread).length;

    return Scaffold(
      backgroundColor: AppTheme.background,
      drawer: widget.drawer,
      appBar: AppBar(
        title: Text(widget.title),
        elevation: 0,
        backgroundColor: AppTheme.primary,
        foregroundColor: AppTheme.secondary,
        leading: widget.drawer != null
            ? Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              )
            : null,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _topSummaryCard(unreadCount),
                  const SizedBox(height: 18),
                  _searchBar(),
                  const SizedBox(height: 14),
                  _filterRow(),
                  const SizedBox(height: 16),
                  if (filteredData.isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 60),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withOpacity(0.06),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.notifications_off_outlined,
                              size: 40,
                              color: AppTheme.primary.withOpacity(0.4),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            "No notifications found",
                            style: TextStyle(
                              color: AppTheme.textPrimary.withOpacity(0.55),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ...filteredData.map((n) {
                      final isRead = !_isUnread(n);
                      final type = n['type']?.toString() ?? '';
                      return _notificationCard(n, isRead, type);
                    }),
                ],
              ),
            ),
    );
  }

  Widget _topSummaryCard(int unreadCount) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primary, AppTheme.primary.withOpacity(0.75)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  unreadCount == 0 ? "You're all caught up" : "You have",
                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12.5),
                ),
                const SizedBox(height: 2),
                Text(
                  unreadCount == 0 ? "No new notifications" : "$unreadCount unread notifications",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchBar() {
    return TextField(
      onChanged: (v) {
        searchQuery = v;
        applyFilters();
      },
      decoration: InputDecoration(
        hintText: "Search notifications",
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppTheme.neutral.withOpacity(0.4)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppTheme.neutral.withOpacity(0.4)),
        ),
      ),
    );
  }

  Widget _filterRow() {
    final options = ["All", "Unread", "Today", "This Week"];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: options.map((option) {
          return _Chip(
            text: option,
            selected: selectedFilter == option,
            onTap: () => selectFilter(option),
          );
        }).toList(),
      ),
    );
  }

  Widget _notificationCard(dynamic n, bool isRead, String type) {
    final isApproved = type == "approved";
    final isRejected = type == "rejected";

    final accentColor = isApproved
        ? AppTheme.success
        : (isRejected ? AppTheme.error : AppTheme.primary);

    final icon = isApproved
        ? Icons.check_circle_outline
        : (isRejected ? Icons.cancel_outlined : Icons.notifications_active_outlined);

    final production = n['production'];
    final machineName = production?['machineemploye']?['machine_name'];
    final readyProduction = production?['ready_production'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isRead ? null : Border.all(color: accentColor.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          await service.read(n['id']);
          load();
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: accentColor, size: 20),
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
                          n['title'] ?? '',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                      ),
                      if (!isRead)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(left: 6),
                          decoration: const BoxDecoration(
                            color: AppTheme.info,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    n['message'] ?? '',
                    style: TextStyle(color: AppTheme.textPrimary.withOpacity(0.7), fontSize: 13),
                  ),
                  if (machineName != null || readyProduction != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.background,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          if (machineName != null) ...[
                            Icon(Icons.precision_manufacturing_outlined,
                                size: 15, color: AppTheme.primary.withOpacity(0.6)),
                            const SizedBox(width: 6),
                            Text(
                              machineName.toString(),
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ],
                          if (machineName != null && readyProduction != null)
                            const SizedBox(width: 14),
                          if (readyProduction != null) ...[
                            Icon(Icons.check_circle_outline,
                                size: 15, color: AppTheme.primary.withOpacity(0.6)),
                            const SizedBox(width: 6),
                            Text(
                              "$readyProduction m",
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    _timeAgo(n),
                    style: TextStyle(fontSize: 11, color: AppTheme.textPrimary.withOpacity(0.4)),
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

class _Chip extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback? onTap;

  const _Chip({
    required this.text,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppTheme.primary : AppTheme.neutral.withOpacity(0.4),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: selected ? AppTheme.secondary : AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 12.5,
          ),
        ),
      ),
    );
  }
}
