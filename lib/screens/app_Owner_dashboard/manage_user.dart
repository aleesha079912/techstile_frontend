import 'package:flutter/material.dart';
import 'package:techstile_frontend/screens/app_Owner_dashboard/assign_paermission.dart';
import 'package:techstile_frontend/screens/app_Owner_dashboard/machine/machine_assignment.dart';
import 'package:techstile_frontend/screens/app_Owner_dashboard/role_management.dart';
import '../../../../core/services/manage_users_service.dart';
import '../../../../core/utils/theme.dart';
import 'package:techstile_frontend/screens/app_Owner_dashboard/user/register_user_rolebased.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  final _service = ManageUsersService.instance;
  late Future<List<UserData>> _usersFuture;

  String selectedFilter = "All";
  final searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();

    searchCtrl.addListener(() {
      setState(() {});
    });

    _refresh();
  }

  void _refresh() {
    setState(() {
      _usersFuture = _service.fetchUsers();
    });
  }

  /// FILTER + SEARCH
  List<UserData> _applyFilters(List<UserData> users) {
    final query = searchCtrl.text.toLowerCase().trim();

    List<UserData> filtered = users;

    if (selectedFilter != "All") {
      filtered = filtered.where((user) {
        final role = user.role.toLowerCase();

        if (selectedFilter == "Owner") return role == "owner";
        if (selectedFilter == "Managers") return role == "manager";
        if (selectedFilter == "Employees") return role == "employee";

        return true;
      }).toList();
    }

    if (query.isNotEmpty) {
      filtered = filtered.where((user) {
        return user.name.toLowerCase().contains(query) ||
            user.email.toLowerCase().contains(query) ||
            user.role.toLowerCase().contains(query) ||
            (user.id?.toString().contains(query) ?? false);
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),

      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        title: const Text("TextileOS"),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.notifications_none),
          )
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primary,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const RegisterUserRoleBased(),
            ),
          ).then((value) {
            if (value == true) _refresh();
          });
        },
        child: const Icon(Icons.person_add, color: Colors.white),
      ),

      /// ✅ FIX: SafeArea ADDED
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 8), // ✅ FIX visibility
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Users",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// SEARCH
                  SizedBox(
                    height: 42,
                    child: TextField(
                      controller: searchCtrl,
                      onChanged: (_) => setState(() {}),
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: "Search user...",
                        prefixIcon: const Icon(Icons.search, size: 18),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// BUTTONS
                  Row(
                    children: [
                      Expanded(
                        child: _actionBtn("Assign Machines",
                            Icons.factory_outlined, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const MachineAssignmentPage(),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: _actionBtn("Manage Roles",
                            Icons.security, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  RoleManagementScreen(),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: _actionBtn("Permissions", Icons.lock,
                            () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const AssignPermissionsScreen(),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  /// FILTERS
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _chip("All"),
                        _chip("Owner"),
                        _chip("Managers"),
                        _chip("Employees"),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            /// LIST
            Expanded(
              child: FutureBuilder<List<UserData>>(
                future: _usersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData ||
                      snapshot.data!.isEmpty) {
                    return const Center(
                        child: Text("No Users Found"));
                  }

                  final users = _applyFilters(snapshot.data!);

                  return ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];

                      return _modernCard(
                        user,
                        () async {
                          bool success =
                              await _service.deleteUser(user.id!);
                          if (success) _refresh();
                        },
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  RegisterUserRoleBased(user: user),
                            ),
                          ).then((value) {
                            if (value == true) _refresh();
                          });
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// CHIP
  Widget _chip(String label) {
    final isSelected = selectedFilter == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = label;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary
              : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  /// BUTTON
  Widget _actionBtn(
      String text, IconData icon, VoidCallback onTap) {
    return SizedBox(
      height: 36,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 1,
        ),
        onPressed: onTap,
        icon: Icon(icon, size: 16),
        label: Text(
          text,
          style: const TextStyle(fontSize: 10),
        ),
      ),
    );
  }

  /// CARD
  Widget _modernCard(
    UserData user,
    VoidCallback onDelete,
    VoidCallback onEdit,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          )
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor:
                AppTheme.primary.withOpacity(0.1),
            child: const Icon(Icons.person,
                color: AppTheme.primary),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(user.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold)),
                Text(user.email,
                    style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey)),
                Text(user.role,
                    style: const TextStyle(
                        color: AppTheme.primary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}