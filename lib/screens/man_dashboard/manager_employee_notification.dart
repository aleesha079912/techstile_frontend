import 'package:flutter/material.dart';

import '../../core/services/manager_service/man_emp_notification_service.dart';
import '../../core/services/auth_service.dart';

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
    selectedFilter = filter;

    setState(() {
      if (filter == "All") {
        filteredData = data;
      } else if (filter == "Unread") {
        filteredData = data
            .where((e) => e['is_read'].toString() != "true")
            .toList();
      } else {
        filteredData = data; // Today / Week backend ho to refine hoga
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
          title: const Text("Search Notifications"),
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
      backgroundColor: const Color(0xFFF4F6FB),
      drawer: widget.drawer,

      /// APP BAR
      appBar: AppBar(
        title: Text(widget.title),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
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
          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.notifications, color: Colors.white, size: 40),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("You have",
                  style: TextStyle(color: Colors.white70)),
              Text(
                "$unreadCount unread notifications",
                style: const TextStyle(
                  color: Colors.white,
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

  /// ================= FILTER =================
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

  /// ================= CARD =================
  Widget _notificationCard(dynamic n, bool isRead, String type) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
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
                    ? Colors.green.shade50
                    : Colors.orange.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                type == "approved" ? Icons.check : Icons.warning,
                color: type == "approved"
                    ? Colors.green
                    : Colors.orange,
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
                ],
              ),
            ),

            if (!isRead)
              const Icon(Icons.circle,
                  size: 10, color: Colors.blue),
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
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF4F46E5)
              : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}