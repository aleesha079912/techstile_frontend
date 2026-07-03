import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/utils/theme.dart';
import '../manager_profile.dart';
import '../../employee_dashboard/profile.dart';

class ManagerSettingsScreen extends StatefulWidget {
  /// Role badge shown on the profile card. Defaults to "Manager".
  final String roleLabel;

  /// Where the profile card / "Edit Profile" tile navigates to.
  /// Defaults to the Manager profile screen.
  final Widget Function()? profilePageBuilder;

  const ManagerSettingsScreen({
    super.key,
    this.roleLabel = "Manager",
    this.profilePageBuilder,
  });

  @override
  State<ManagerSettingsScreen> createState() =>
      _ManagerSettingsScreenState();
}

class _ManagerSettingsScreenState
    extends State<ManagerSettingsScreen> {
  bool autoBackup = true;

  @override
  Widget build(BuildContext context) {
    final user = AuthService.user ?? {};

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // ================= PROFILE CARD =================

          GestureDetector(
            onTap: () {
              Get.to(
                widget.profilePageBuilder ??
                    () => ManagerProfileScreen(
                          userId: AuthService.userId,
                        ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [

                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white,
                    child: Text(
                      (user['name'] ?? 'M')
                          .toString()
                          .substring(0, 1)
                          .toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                        fontSize: 22,
                      ),
                    ),
                  ),

                  const SizedBox(width: 15),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          user['name'] ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 3),

                        Text(
                          user['email'] ?? '',
                          style: const TextStyle(
                            color: Colors.white70,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius:
                                BorderRadius.circular(20),
                          ),
                          child: Text(
                            widget.roleLabel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 25),

          // ================= ACCOUNT =================

          _sectionTitle("ACCOUNT"),

          _tile(
            icon: Icons.person_outline,
            title: "Edit Profile",
            onTap: () {
              Get.toNamed('/edit-profile');
            },
          ),

          _tile(
            icon: Icons.lock_outline,
            title: "Reset Password",
            onTap: () {
              Get.toNamed('/change-password');
            },
          ),

          const SizedBox(height: 20),

          // ================= PREFERENCES =================

          _sectionTitle("PREFERENCES"),

          SwitchListTile(
            value: autoBackup,
            activeColor: AppTheme.primary,
            title: const Text("Auto Backup"),
            secondary: const Icon(
              Icons.backup_outlined,
            ),
            onChanged: (v) {
              setState(() {
                autoBackup = v;
              });
            },
          ),

          const SizedBox(height: 20),

          // ================= SUPPORT =================

          _sectionTitle("SUPPORT"),

          _tile(
            icon: Icons.help_outline,
            title: "Help & FAQ",
            onTap: () {
              Get.toNamed('/help-faq');
            },
          ),

          _tile(
            icon: Icons.privacy_tip_outlined,
            title: "Privacy Policy",
            onTap: () {
              _showPrivacyDialog();
            },
          ),

          _tile(
            icon: Icons.info_outline,
            title: "About App",
            onTap: () {
              _showAboutDialog();
            },
          ),

          const SizedBox(height: 20),

          // ================= SECURITY =================

          _sectionTitle("SECURITY"),

          _tile(
            icon: Icons.logout,
            title: "Logout",
            textColor: Colors.red,
            onTap: _logout,
          ),

          const SizedBox(height: 30),

          const Center(
            child: Text(
              "TechStile v1.0.0",
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 4,
        bottom: 8,
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _tile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color textColor = Colors.black,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0.5,
      child: ListTile(
        leading: Icon(icon),
        title: Text(
          title,
          style: TextStyle(
            color: textColor,
          ),
        ),
        trailing:
            const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  void _showPrivacyDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text("Privacy Policy"),
        content: const Text(
          "TechStile keeps your production and factory data secure. Data is only accessible to authorized users.",
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text("About App"),
        content: const Text(
          "TechStile Production Management System\n\nVersion 1.0\n\nManage employees, machines and production efficiently.",
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _logout() {
    Get.defaultDialog(
      title: "Logout",
      middleText:
          "Are you sure you want to logout?",
      textCancel: "Cancel",
      textConfirm: "Logout",
      confirmTextColor: Colors.white,
      onConfirm: () {
        AuthService.logout();

        Get.offAllNamed('/login');
      },
    );
  }
}