import 'package:flutter/material.dart';
import 'package:techstile_frontend/core/services/factory_user_services.dart';
import 'package:techstile_frontend/screens/app_Owner_dashboard/employee/assign_shift.dart';
import 'package:techstile_frontend/widgets/bottom_nav_bar.dart';
import '../../../../core/utils/theme.dart';

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
      manager       = data['manager'];
      users         = data['data'] ?? [];
      filteredUsers = users;
      totalUsers    = data['total_users'] ?? 0;
      activeUsers   = data['active_users'] ?? 0;
      loading       = false;
    });
  }

  void search(String query) {
    setState(() {
      filteredUsers = users.where((u) {
        return (u['name'] ?? '').toLowerCase().contains(query.toLowerCase()) ||
            (u['email'] ?? '').toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  // ── Manager card — sirf Assign Shift button ──────────────────────────────
  Widget managerCard() {
    if (manager == null) return const SizedBox();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F0FE),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFB6D0FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundColor: Color(0xFF1A73E8),
                child: Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Factory Manager",
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    Text(
                      manager['name'] ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ✅ Sirf Assign Shift button — full width
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.schedule, size: 18),
              label: const Text("Assign Shift"),
              onPressed: () {
                // ✅ AssignShiftsScreen khulta hai — wahan + FAB se popup khulta hai
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AssignShiftsScreen(
                      factoryId: widget.factoryId,
                      userId: manager?['id'] ?? 0,
                    ),
                  ),
                );
              },
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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 2),
            Text(title,
                style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget userCard(dynamic user) {
    String role = '';
    if (user['roles'] != null && user['roles'].isNotEmpty) {
      role = user['roles'][0]['name'];
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE3ECFF)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 18,
            backgroundColor: Color(0xFF1A73E8),
            child: Icon(Icons.person, size: 18, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user['name'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(role,
                    style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text("ACTIVE",
                style: TextStyle(fontSize: 10, color: Colors.green)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F6FB),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 235, 237, 241),
        title: const Text("TextileOS"),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  managerCard(),
                  TextField(
                    controller: searchCtrl,
                    onChanged: search,
                    decoration: InputDecoration(
                      hintText: "Search users...",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      statBox("Total Users", "$totalUsers", const Color(0xFF1A73E8)),
                      statBox("Active Users", "$activeUsers", Colors.green),
                    ],
                  ),
                  const SizedBox(height: 10),
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