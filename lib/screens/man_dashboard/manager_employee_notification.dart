import 'package:flutter/material.dart';

import '../../core/services/manager_service/man_emp_notification_service.dart';
import '../../core/services/auth_service.dart';
import '../../../core/utils/theme.dart';

class NotificationPage extends StatefulWidget {
  final Widget drawer;
  final String title;

  const NotificationPage({
    super.key,
    required this.drawer,
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
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final id = AuthService.userId;
    final result = await service.getNotifications(id);

    setState(() {
      data = result;
      filteredData = result;
      loading = false;
    });
  }

  void applyFilter(String filter) {
    setState(() {
      selectedFilter = filter;

      if (filter == "All") {
        filteredData = data;
      } else if (filter == "Unread") {
        filteredData = data
            .where((e) => e['is_read'].toString() != "true")
            .toList();
      } else {
        filteredData = data;
      }
    });
  }

  void search(String value) {
    setState(() {
      filteredData = data.where((n) {
        final title = (n['title'] ?? '').toString().toLowerCase();
        final id = n['id'].toString();

        return title.contains(value.toLowerCase()) || id.contains(value);
      }).toList();
    });
  }

  void showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Search"),
          content: TextField(
            controller: searchController,
            decoration: const InputDecoration(
              hintText: "Search by name or ID",
            ),
            onChanged: search,
          ),
          actions: [
            TextButton(
              onPressed: () {
                searchController.clear();
                setState(() => filteredData = data);
                Navigator.pop(context);
              },
              child: const Text("Clear"),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    int unreadCount =
        data.where((e) => e['is_read'].toString() != "true").length;

    return Scaffold(
      backgroundColor: AppTheme.background,
      drawer: widget.drawer,

      /// APP BAR
      appBar: AppBar(
        title: Text(widget.title),
        elevation: 0,
        backgroundColor:  AppTheme.primary,
        foregroundColor: AppTheme.secondary,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: showSearchDialog,
          ),
        ],
      ),

      /// BODY
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _topSummaryCard(unreadCount),
                  const SizedBox(height: 16),
                  _filterRow(),
                  const SizedBox(height: 16),

                  /// NOTIFICATIONS
                  ...filteredData.map((n) {
                    final isRead =
                        n['is_read'].toString() == "true";
                    final type = n['type'];

                    return _notificationCard(n, isRead, type);
                  }).toList(),
                ],
              ),
            ),
    );
  }

  /// ================= TOP CARD =================
  Widget _topSummaryCard(int unreadCount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primary, AppTheme.info],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.notifications, color: AppTheme.secondary, size: 40),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "You have",
                style: TextStyle(color: AppTheme.neutral),
              ),
              Text(
                "$unreadCount unread notifications",
                style: const TextStyle(
                  color: AppTheme.secondary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  /// ================= FILTER ROW =================
  Widget _filterRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _Chip(
            text: "All",
            selected: selectedFilter == "All",
            onTap: () => applyFilter("All"),
          ),
          _Chip(
            text: "Unread",
            selected: selectedFilter == "Unread",
            onTap: () => applyFilter("Unread"),
          ),
          _Chip(
            text: "Today",
            selected: selectedFilter == "Today",
            onTap: () => applyFilter("Today"),
          ),
          _Chip(
            text: "This Week",
            selected: selectedFilter == "This Week",
            onTap: () => applyFilter("This Week"),
          ),
        ],
      ),
    );
  }

  /// ================= NOTIFICATION CARD =================
  Widget _notificationCard(dynamic n, bool isRead, String type) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.secondary,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color:  AppTheme.neutral),
        boxShadow: [
          BoxShadow(
            color: AppTheme.onsurface.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: InkWell(
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
                color: type == "approved"
                    ?  AppTheme.success
                    :  AppTheme.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                type == "approved"
                    ? Icons.check
                    : Icons.warning,
                color: type == "approved"
                    ?  AppTheme.success
                    :   AppTheme.surface,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    n['title'] ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(n['message'] ?? ''),

                  if (n['production'] != null) ...[
                    const SizedBox(height: 10),

                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color:  AppTheme.neutral,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Machine ID: ${n['production']?['machine_id'] ?? '-'}",
                          ),
                          Text(
                            "Machine Name: ${n['production']?['machineemploye']?['machine_name'] ?? '-'}",
                          ),
                          Text(
                            "Ready Production: ${n['production']?['ready_production'] ?? '-'}",
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            if (!isRead)
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(
                  Icons.circle,
                  size: 10,
                  color:  AppTheme.info,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// ================= CHIP =================
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ?  AppTheme.primary
              :  AppTheme.neutral,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: selected
                ?  AppTheme.secondary
                :  AppTheme.onsurface,
          ),
        ),
      ),
    );
  }
}