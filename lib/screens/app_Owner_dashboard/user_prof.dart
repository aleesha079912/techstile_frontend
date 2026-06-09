import 'package:flutter/material.dart';
import 'package:techstile_frontend/screens/app_Owner_dashboard/assign_factory.dart';
import 'package:techstile_frontend/screens/app_Owner_dashboard/assign_machine.dart';
import '../../../../core/utils/theme.dart';

class UserProfileScreen extends StatefulWidget {
  final int userId;
  final String name;
  final String email;
  final String phone;
  final String cnic;
  final String address;
  final String role;

  const UserProfileScreen({
    super.key,
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.cnic,
    required this.address,
    required this.role,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {

  late String normalizedRole;

  @override
  void initState() {
    super.initState();

    // 🔥 Normalize role safely
    normalizedRole = widget.role.trim().toLowerCase();

    debugPrint("========= USER PROFILE DEBUG =========");
    debugPrint("User ID: ${widget.userId}");
    debugPrint("Raw Role: '${widget.role}'");
    debugPrint("Normalized Role: '$normalizedRole'");
    debugPrint("======================================");
  }

  bool get isManager => normalizedRole.contains('manager');
  bool get isWorker =>
      normalizedRole.contains('worker') ||
      normalizedRole.contains('employee');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F6FA),
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        title: const Text("User Profile"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _header(),
            _infoCard(),
            const SizedBox(height: 10),

            // ✅ ROLE BASED SECTION
            if (isManager)
              _managerAssignSection()
            else if (isWorker)
              _workerAssignSection()
            else
              _noRoleSection(),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ───────────── HEADER ─────────────

  Widget _header() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 45,
            backgroundColor: AppTheme.primary.withOpacity(0.1),
            child: const Icon(Icons.person,
                size: 40, color: AppTheme.primary),
          ),
          const SizedBox(height: 10),
          Text(
            widget.name,
            style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          _roleBadge(widget.role),
          const SizedBox(height: 8),
          Text(widget.email,
              style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _roleBadge(String role) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        role.isEmpty ? "NO ROLE" : role.toUpperCase(),
        style: const TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold),
      ),
    );
  }

  // ───────────── INFO CARD ─────────────

  Widget _infoCard() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          _tile(Icons.phone, "Phone", widget.phone),
          _tile(Icons.credit_card, "CNIC", widget.cnic),
          _tile(Icons.location_on, "Address", widget.address),
        ],
      ),
    );
  }

  Widget _tile(IconData icon, String label, String value) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primary),
          const SizedBox(width: 10),
          Text("$label: ",
              style: const TextStyle(
                  fontWeight: FontWeight.bold)),
          Expanded(
              child: Text(value,
                  style:
                      const TextStyle(color: Colors.grey))),
        ],
      ),
    );
  }

  // ───────────── MANAGER SECTION ─────────────

  Widget _managerAssignSection() {
    return _assignmentSection(
      title: "Factory Assignment",
      emptyTitle: "No Factory Assigned",
      subtitle: "Tap below to assign a factory",
      icon: Icons.factory,
      buttonText: "Assign Factory",
      buttonColor: Colors.blue,
      onPressed: _showAssignFactoryPopup,
    );
  }

  // ───────────── WORKER SECTION ─────────────

  Widget _workerAssignSection() {
    return _assignmentSection(
      title: "Machine Assignment",
      emptyTitle: "No Machines Assigned",
      subtitle: "Tap below to assign machines",
      icon: Icons.precision_manufacturing,
      buttonText: "Assign Machines",
      buttonColor: Colors.green,
      onPressed: _showAssignMachinePopup,
    );
  }

  // ───────────── UNKNOWN ROLE SECTION ─────────────

  Widget _noRoleSection() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Text(
        "This user has no valid role assigned.",
        style: TextStyle(
            color: Colors.orange,
            fontWeight: FontWeight.w500),
      ),
    );
  }

  // ───────────── COMMON ASSIGNMENT UI ─────────────

  Widget _assignmentSection({
    required String title,
    required String emptyTitle,
    required String subtitle,
    required IconData icon,
    required String buttonText,
    required Color buttonColor,
    required VoidCallback onPressed,
  }) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _assignmentBox(
              title: emptyTitle,
              subtitle: subtitle,
              icon: icon),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.add),
              label: Text(buttonText),
              onPressed: onPressed,
            ),
          ),
        ],
      ),
    );
  }

  Widget _assignmentBox({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold)),
                Text(subtitle,
                    style:
                        const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ───────────── POPUPS ─────────────

  void _showAssignFactoryPopup() {
    showDialog(
      context: context,
      builder: (_) =>
          AssignFactoryPopup(userId: widget.userId),
    );
  }

  void _showAssignMachinePopup() {
    showDialog(
      context: context,
      builder: (_) => AssignMachinePopup(
        userId: widget.userId,
        role: widget.role,
      ),
    );
  }
}