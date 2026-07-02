import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/utils/theme.dart';
import '../manager_profile.dart';

class ManagerSettingsScreen extends StatefulWidget {
  const ManagerSettingsScreen({super.key});

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
        foregroundColor:  AppTheme.secondary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // ================= PROFILE CARD =================

          GestureDetector(
            onTap: () {
              Get.to(
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
                    backgroundColor:  AppTheme.secondary,
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
                            color: AppTheme.secondary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 3),

                        Text(
                          user['email'] ?? '',
                          style: const TextStyle(
                            color:  AppTheme.neutral,
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
                            color:  AppTheme.neutral,
                            borderRadius:
                                BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "Manager",
                            style: TextStyle(
                              color: AppTheme.secondary,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Icon(
                    Icons.arrow_forward_ios,
                    color:  AppTheme.secondary,
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
            textColor:  AppTheme.error,
            onTap: _logout,
          ),

          const SizedBox(height: 30),

          const Center(
            child: Text(
              "TechStile v1.0.0",
              style: TextStyle(
                color:  AppTheme.neutral,
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
          color:  AppTheme.neutral,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _tile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color textColor =  AppTheme.onsurface,
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
      confirmTextColor:  AppTheme.secondary,
      onConfirm: () {
        AuthService.logout();

        Get.offAllNamed('/login');
      },
    );
  }
}