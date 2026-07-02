import 'package:flutter/material.dart';
import 'package:techstile_frontend/core/services/manager_service/manager_profile_service.dart';
import 'package:techstile_frontend/widgets/man_drawer.dart';
import 'package:techstile_frontend/core/services/auth_service.dart';
import '../../../core/utils/theme.dart';

class ManagerProfileScreen extends StatefulWidget {
  final int userId;

  const ManagerProfileScreen({super.key, required this.userId});

  @override
  State<ManagerProfileScreen> createState() => _ManagerProfileScreenState();
}

class _ManagerProfileScreenState extends State<ManagerProfileScreen> {
  final service = ManagerProfileService();

  Map<String, dynamic>? profile;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  // ===== LOGIC (UNCHANGED) =====
  Future<void> load() async {
    final res = await service.getProfile(widget.userId);

    setState(() {
      profile = res?['data'];
      loading = false;
    });
  }

  // ===== SIMPLE HELPER WIDGETS (DESIGN ONLY) =====

  // Top gradient profile card (avatar + name + email)
  Widget buildProfileHeader() {
    final name = profile?['name'] ?? '';
    final email = profile?['email'] ?? '';
    final firstLetter = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(15, 15, 15, 12),
      padding: const EdgeInsets.symmetric(vertical: 22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
             AppTheme.primary,
             AppTheme.info,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.35),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: AppTheme.secondary.withOpacity(0.25),
            child: Text(
              firstLetter,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color:  AppTheme.secondary,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            name,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color:  AppTheme.secondary,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            email,
            style: TextStyle(
              fontSize: 12,
              color:  AppTheme.secondary.withOpacity(0.85),
            ),
          ),
        ],
      ),
    );
  }

  // Section title with small blue bar (like "Performance Overview")
  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color:  AppTheme.onsurface,
            ),
          ),
        ],
      ),
    );
  }

  // Colorful stat card for performance overview grid
  Widget statCard(IconData icon, String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppTheme.secondary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:  AppTheme.secondary.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color:  AppTheme.onsurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color:  AppTheme.onsurface,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  AppTheme.secondary, // light grey page background
      drawer: ManagerDrawer(
        userId: AuthService.userId,
        factoryId: AuthService.factoryId,
      ),
      appBar: AppBar(title: const Text("Manager Profile")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top gradient header
                  buildProfileHeader(),

                  // Performance overview section
                  sectionTitle("Performance Overview"),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.3,
                      children: [
                        statCard(
                          Icons.groups,
                          "Total Employees",
                          "${profile?['total_employees'] ?? 0}",
                           AppTheme.info,
                        ),
                        statCard(
                          Icons.analytics,
                          "Total Production",
                          "${profile?['total_production'] ?? 0}",
                           AppTheme.surface,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}