import 'package:flutter/material.dart';
import 'package:techstile_frontend/screens/app_Owner_dashboard/assign_paermission.dart';
import 'package:techstile_frontend/screens/app_Owner_dashboard/role_management.dart';
import '../../../../core/services/manage_users_service.dart';
import '../../../../core/utils/theme.dart';
import 'package:techstile_frontend/screens/app_Owner_dashboard/user/register_user_rolebased.dart';

// NEW SCREENS

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
    _refresh();
  }

  void _refresh() {
    setState(() {
      _usersFuture = _service.fetchUsers();
    });
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

      body: Column(
        children: [

          /// HEADER SECTION (like design)
          Container(
            width: double.infinity,
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
                  "ADMINISTRATIVE CONSOLE",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),

                const SizedBox(height: 6),

                const Text(
                  "Users",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                  ),
                ),

                const SizedBox(height: 10),

                /// SEARCH BAR
                TextField(
                  controller: searchCtrl,
                  decoration: InputDecoration(
                    hintText: "Search by name, email or ID",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                /// FILTER CHIPS
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _chip("All"),
                      _chip("Admins"),
                      _chip("Managers"),
                      _chip("Workers"),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                /// ACTION BUTTONS ROW
                Row(
                  children: [
                    Expanded(child: _actionBtn("Add New User", Icons.add, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegisterUserRoleBased(),
                        ),
                      );
                    })),

                    const SizedBox(width: 8),

                    Expanded(child: _actionBtn("Manage Roles", Icons.security, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RoleManagementScreen(),
                        ),
                      );
                    })),

                    const SizedBox(width: 8),

                    Expanded(child: _actionBtn("Permissions", Icons.lock, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AssignPermissionsScreen(),
                        ),
                      );
                    })),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          /// USERS LIST
          Expanded(
            child: FutureBuilder<List<UserData>>(
              future: _usersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No Users Found"));
                }

                final users = snapshot.data!;

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];

                    return _modernCard(user, () async {
                      bool success = await _service.deleteUser(user.id!);
                      if (success) _refresh();
                    }, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              RegisterUserRoleBased(user: user),
                        ),
                      ).then((value) {
                        if (value == true) _refresh();
                      });
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// CHIP
  Widget _chip(String label) {
    final isSelected = selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => selectedFilter = label),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : Colors.grey.shade200,
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
 Widget _actionBtn(String text, IconData icon, VoidCallback onTap) {
  return ElevatedButton.icon(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppTheme.primary,

      // ✅ THIS IS THE FIX
      foregroundColor: Colors.white,

      padding: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    onPressed: onTap,
    icon: Icon(icon, size: 18),
    label: Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        color: Colors.white, // extra safety
      ),
    ),
  );
}

  /// USER CARD (NEW DESIGN)
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
          backgroundColor: AppTheme.primary.withOpacity(0.1),
          child: const Icon(
            Icons.person,
            color: AppTheme.primary,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                user.email,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                user.role,
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              onEdit();
            }

            if (value == 'delete') {
              onDelete();
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 10),
                  Text("Edit"),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                  SizedBox(width: 10),
                  Text(
                    "Delete",
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
}