import 'package:flutter/material.dart';
import '../../../../core/services/manage_users_service.dart';
import '../../../../core/utils/theme.dart';

class UserProfileScreen extends StatefulWidget {
  final int userId;

  const UserProfileScreen({super.key, required this.userId});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _service = ManageUsersService.instance;

  UserData? user;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final users = await _service.fetchUsers();

    user = users.firstWhere((e) => e.id == widget.userId);

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F6FA),

      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        title: const Text("Profile Details"),
      ),

      body: loading
    ? const Center(child: CircularProgressIndicator())
    : SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _topHeader(),
              _infoCard(),

              if (user!.role.toLowerCase() == "manager")
                _managerSection(),

              if (user!.role.toLowerCase() == "employee")
                _employeeSection(),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- HEADER ----------------
  Widget _topHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 45,
            backgroundColor: AppTheme.primary.withOpacity(0.1),
            child: const Icon(Icons.person, size: 40, color: AppTheme.primary),
          ),

          const SizedBox(height: 10),

          Text(
            user!.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          _roleBadge(user!.role),

          const SizedBox(height: 10),

          Text(user!.email,
              style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _roleBadge(String role) {
    Color color;

    switch (role.toLowerCase()) {
      case "manager":
        color = Colors.blue;
        break;
      case "employee":
        color = Colors.green;
        break;
      default:
        color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        role.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  // ---------------- INFO ----------------
  Widget _infoCard() {
  return Container(
    margin: const EdgeInsets.all(12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
        )
      ],
    ),
    child: Column(
      children: [
        _tile(Icons.phone, "Phone", user!.phone),
        _tile(Icons.credit_card, "CNIC", user!.cnic),
        _tile(Icons.location_on, "Address", user!.address),
        _tile(Icons.info, "Details", user!.details),
      ],
    ),
  );
}

  Widget _tile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(value,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String a, String b) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(a,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(b)),
        ],
      ),
    );
  }

  // ---------------- MANAGER ----------------
  Widget _managerSection() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Factory Assignment",
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold)),

          const SizedBox(height: 10),

          const Text("No factory assigned yet"),

          const SizedBox(height: 15),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              icon: const Icon(Icons.factory),
              label: const Text("Assign Factory"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AssignFactoryScreen(userId: user!.id!),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- EMPLOYEE ----------------
  Widget _employeeSection() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Machine Assignment",
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold)),

          const SizedBox(height: 10),

          const Text("No machines assigned yet"),

          const SizedBox(height: 15),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              icon: const Icon(Icons.precision_manufacturing),
              label: const Text("Assign Machines"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        AssignMachineScreen(userId: user!.id!),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------- PLACEHOLDERS ----------------

class AssignFactoryScreen extends StatelessWidget {
  final int userId;

  const AssignFactoryScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Assign Factory")),
      body: const Center(
        child: Text("Factory Assignment Form (Coming Soon)"),
      ),
    );
  }
}

class AssignMachineScreen extends StatelessWidget {
  final int userId;

  const AssignMachineScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Assign Machines")),
      body: const Center(
        child: Text("Machine Assignment Form (Coming Soon)"),
      ),
    );
  }
}
