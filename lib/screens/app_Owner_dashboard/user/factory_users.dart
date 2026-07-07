import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:techstile_frontend/core/services/factory_user_services.dart';
import 'package:techstile_frontend/screens/employee_dashboard/profile.dart';
import 'package:techstile_frontend/screens/man_dashboard/manager_profile.dart';
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

  Widget infoRow(IconData icon, String text) {
  return Padding(
    padding: const EdgeInsets.only(top: 4),
    child: Row(
      children: [
        Icon(icon, size: 13, color:  AppTheme.primary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11.5,
              color:  AppTheme.neutral,
            ),
          ),
        ),
      ],
    ),
  );
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

    return GestureDetector(
      onTap: () {
        final id = manager['id'];
        if (id == null) return;
        Get.to(() => ManagerProfileScreen(userId: int.parse(id.toString())));
      },
      child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.secondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.info),
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
          const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.neutral),
        ],
      ),
      ),
    );
  }

  Widget userCard(dynamic user) {
    String role = "Unknown";

    if (user['roles'] != null && user['roles'].isNotEmpty) {
      role = user['roles'][0]['name'];
    }

    final bool isEmployee = role.toLowerCase() == "employee";
    final bool isActive = user['is_active'] == true;

    final String name = user['name'] ?? "User";
    final String email = user['email'] ?? "--";
    final String phone = user['phone_no'] ?? "--";
    final String shiftStart = user['shift_starttime'] ?? "--";
    final String shiftEnd = user['shift_endtime'] ?? "--";

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: !isEmployee || user['id'] == null
        ? null
        : () {
            Get.to(
              () => UserProfileScreen(
                userId: user['id'],
              ),
            );
          },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color:  AppTheme.secondary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color:  AppTheme.onsurface.withOpacity(.05),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 19,
                  backgroundColor:  AppTheme.primary.withOpacity(.15),
                  child: Text(
                    name[0].toUpperCase(),
                    style: const TextStyle(
                      color: AppTheme.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (isActive)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppTheme.success,
                        shape: BoxShape.circle,
                        border: Border.all(color:  AppTheme.secondary, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),

                  Text(
                    "ID: ${user['employee_id'] ?? '--'}",
                    style: const TextStyle(
                      fontSize: 10.5,
                      color:  AppTheme.neutral,
                    ),
                  ),

                  infoRow(Icons.email_outlined, email),
                  infoRow(Icons.phone_outlined, phone),
                  infoRow(
                    Icons.access_time_rounded,
                    "$shiftStart - $shiftEnd",
                  ),

                  const SizedBox(height: 3),

                  Text(
                    role,
                    style: const TextStyle(
                      fontSize: 11,
                      color:  AppTheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            if (isEmployee)
              const Icon(
                Icons.arrow_forward_ios,
                size: 13,
                color:  AppTheme.neutral,
              ),
          ],
        ),
      ),
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,

      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        iconTheme: const IconThemeData(
          color: AppTheme.secondary,
        ),
        title: const Text(
          "TECHSTILE",
          style: TextStyle(color: AppTheme.secondary),
        ),
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