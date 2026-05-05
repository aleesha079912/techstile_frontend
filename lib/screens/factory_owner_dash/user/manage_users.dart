import 'package:flutter/material.dart';
import '../../../../core/services/manage_users_service.dart';
import '../../../../core/utils/theme.dart'; 
import '../../../../widgets/drawer.dart';
import 'package:techstile_frontend/screens/factory_owner_dash/user/register_user_rolebased.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  final _service = ManageUsersService.instance;
  late Future<List<UserData>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  // API se fresh data mangwane ke liye
  void _refresh() {
    setState(() {
      _usersFuture = _service.fetchUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const OwnerDrawer(),
      appBar: AppBar(
        title: const Text("Manage Users", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primary,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RegisterUserRoleBased()),
          ).then((value) {
            if (value == true) _refresh(); // Agar user add hua to list refresh karo
          });
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: FutureBuilder<List<UserData>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          final users = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async => _refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return _UserCard(
                  user: user, 
                  onDelete: () async {
                    bool success = await _service.deleteUser(user.id!);
                    if (success) _refresh();
                  },
                  onEdit: () {
                    // Edit ke liye wahi register page use hoga user data ke sath
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegisterUserRoleBased(user: user)),
                    ).then((value) {
                      if (value == true) _refresh();
                    });
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80, color: AppTheme.neutral.withOpacity(0.4)),
          const SizedBox(height: 16),
          Text("No employees found in database", style: TextStyle(color: AppTheme.neutral, fontSize: 16)),
        ],
      ),
    );
  }
}

// User Card Widget with Edit/Delete Actions
class _UserCard extends StatelessWidget {
  final UserData user;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  
  const _UserCard({required this.user, required this.onDelete, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 25, 
                backgroundImage: user.pic.isNotEmpty ? NetworkImage(user.pic) : null,
                child: user.pic.isEmpty ? const Icon(Icons.person) : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primary)),
                    Text("${user.role} • ID: ${user.id}", style: const TextStyle(fontSize: 12, color: AppTheme.neutral)),
                  ],
                ),
              ),
              IconButton(onPressed: onEdit, icon: const Icon(Icons.edit_outlined, color: AppTheme.primary)),
              IconButton(onPressed: onDelete, icon: const Icon(Icons.delete_outline, color: Colors.redAccent)),
            ],
          ),
          const Divider(),
          _infoTile(Icons.email_outlined, user.email),
          _infoTile(Icons.phone_android, user.phone),
          _infoTile(Icons.badge_outlined, "CNIC: ${user.cnic}"),
          _infoTile(Icons.location_on_outlined, user.address),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(children: [Icon(icon, size: 14, color: AppTheme.tertiary), const SizedBox(width: 8), Text(text, style: const TextStyle(fontSize: 12))]),
  );
}