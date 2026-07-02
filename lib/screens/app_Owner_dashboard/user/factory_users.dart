import 'package:flutter/material.dart';
import 'package:techstile_frontend/core/services/factory_user_services.dart';
import 'package:techstile_frontend/core/utils/theme.dart';
import 'package:techstile_frontend/widgets/bottom_nav_bar.dart';

class FactoryUsersScreen extends StatefulWidget {
  final int factoryId;

  const FactoryUsersScreen({
    super.key,
    required this.factoryId,
  });

  @override
  State<FactoryUsersScreen> createState() => _FactoryUsersScreenState();
}

class _FactoryUsersScreenState extends State<FactoryUsersScreen> {
  final FactoryUsersService _service = FactoryUsersService.instance;

  bool loading = true;
  List users = [];
  List filteredUsers = [];
  dynamic manager;

  int totalUsers = 0;
  int activeUsers = 0;

  final TextEditingController searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final data = await _service.getUsersByFactory(widget.factoryId);

    setState(() {
      manager = data['manager'];
      users = data['data'] ?? [];
      filteredUsers = users;
      totalUsers = data['total_users'] ?? 0;
      activeUsers = data['active_users'] ?? 0;
      loading = false;
    });
  }

  void search(String query) {
    setState(() {
      filteredUsers = users.where((u) {
        final name = (u['name'] ?? '').toLowerCase();
        final email = (u['email'] ?? '').toLowerCase();

        return name.contains(query.toLowerCase()) ||
            email.contains(query.toLowerCase());
      }).toList();
    });
  }

  Widget statBox(String title, String value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: const TextStyle(fontSize: 10, color: AppTheme.neutral),
            ),
          ],
        ),
      ),
    );
  }

  Widget managerCard() {
    if (manager == null) return const SizedBox();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F0FE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFB6D0FF)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundColor: AppTheme.primary,
            child: Icon(Icons.person, color:AppTheme.secondary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Manager",
                  style: TextStyle(fontSize: 11, color: AppTheme.neutral),
                ),
                Text(
                  manager['name'] ?? 'No Manager',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget userCard(dynamic user) {
    String role = 'Unknown';

    if (user['roles'] != null && user['roles'].isNotEmpty) {
      role = user['roles'][0]['name'];
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.secondary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.onsurface.withOpacity(0.05),
            blurRadius: 8,
          )
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 18,
            backgroundColor: AppTheme.primary,
            child: Icon(Icons.person, size: 18, color:AppTheme.secondary),
          ),
          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['name'] ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  user['email'] ?? '',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.neutral,
                  ),
                ),
                Text(
                  role,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.info,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.secondary,

      appBar: AppBar(
        backgroundColor: AppTheme.primary, // same as bottom nav
        title: const Text("TECHSTILE"),
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  /// SEARCH ONLY
                  TextField(
                    controller: searchCtrl,
                    onChanged: search,
                    decoration: InputDecoration(
                      hintText: "Search users...",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: AppTheme.secondary,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// STATS
                  Row(
                    children: [
                      statBox("Total Users", "$totalUsers",
                          AppTheme.primary),
                      statBox("Active Users", "$activeUsers",
                          AppTheme.success),
                    ],
                  ),

                  const SizedBox(height: 10),

                  /// MANAGER
                  managerCard(),

                  /// USERS LIST
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredUsers.length,
                      itemBuilder: (context, index) =>
                          userCard(filteredUsers[index]),
                    ),
                  ),
                ],
              ),
            ),

      bottomNavigationBar: CustomBottomNav(
        currentIndex: 3,
        factoryId: widget.factoryId,
      ),
    );
  }
}