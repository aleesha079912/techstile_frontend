import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/utils/theme.dart';
import '../manager_profile.dart';

class ManagerSettingsScreen extends StatefulWidget {
  final String roleLabel;

  /// Where the profile card
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

  // ✅ Common primary-tinted shadow reused across all cards on this page
  static List<BoxShadow> get _primaryShadow => [
        BoxShadow(
          color: AppTheme.primary.withOpacity(0.14),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
        BoxShadow(
          color: AppTheme.primary.withOpacity(0.06),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final user = AuthService.user ?? {};

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(
            color: AppTheme.primary,
            fontWeight: FontWeight.w800,
            fontSize: 24,
          ),
        ),
        backgroundColor: AppTheme.secondary,
        iconTheme: const IconThemeData(color: AppTheme.primary),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // PROFILE CARD

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
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppTheme.primary, AppTheme.primary.withOpacity(0.78)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.28),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [

                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppTheme.secondary.withOpacity(0.18),
                    child: Text(
                      (user['name'] ?? 'M')
                          .toString()
                          .substring(0, 1)
                          .toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.secondary,
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
                            color: AppTheme.textSecondary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 3),

                        Text(
                          user['email'] ?? '',
                          style: TextStyle(
                            color: AppTheme.textSecondary.withOpacity(0.8),
                            fontSize: 12.5,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.secondary.withOpacity(0.18),
                            borderRadius:
                                BorderRadius.circular(20),
                          ),
                          child: Text(
                            widget.roleLabel.isNotEmpty
                                ? widget.roleLabel
                                : (AuthService.role.isNotEmpty
                                    ? AuthService.role.capitalizeFirst!
                                    : 'Manager'),
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Icon(Icons.chevron_right_rounded,
                      color: AppTheme.secondary.withOpacity(0.6)),
                ],
              ),
            ),
          ),

          const SizedBox(height: 25),

          // ACCOUNT

          _sectionTitle("ACCOUNT"),

          _tile(
            icon: Icons.person_outline,
            iconColor: AppTheme.primary,
            title: "Edit Profile",
            onTap: () {
              Get.toNamed('/edit-profile');
            },
          ),

          _tile(
            icon: Icons.lock_outline,
            iconColor: AppTheme.primary,
            title: "Reset Password",
            onTap: () {
              Get.toNamed('/change-password');
            },
          ),

          const SizedBox(height: 20),

          //PREFERENCES

          _sectionTitle("PREFERENCES"),

          Container(
            decoration: BoxDecoration(
              color: AppTheme.secondary,
              borderRadius: BorderRadius.circular(16),
              boxShadow: _primaryShadow,
            ),
            child: SwitchListTile(
              value: autoBackup,
              activeColor: AppTheme.primary,
              title: const Text(
                "Backup",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              secondary: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(Icons.backup_outlined,
                    color: AppTheme.primary, size: 18),
              ),
              onChanged: (v) {
                setState(() {
                  autoBackup = v;
                });
              },
            ),
          ),

          const SizedBox(height: 20),

          // SUPPORT

          _sectionTitle("SUPPORT"),

          _tile(
            icon: Icons.help_outline,
            iconColor: AppTheme.info,
            title: "Help & FAQ",
            onTap: () {
              Get.toNamed('/help-faq');
            },
          ),

          _tile(
            icon: Icons.privacy_tip_outlined,
            iconColor: AppTheme.info,
            title: "Privacy Policy",
            onTap: () {
              _showPrivacyDialog();
            },
          ),

          _tile(
            icon: Icons.info_outline,
            iconColor: AppTheme.info,
            title: "About App",
            onTap: () {
              _showAboutDialog();
            },
          ),

          const SizedBox(height: 20),

          // SECURITY

          _sectionTitle("SECURITY"),

          _tile(
            icon: Icons.logout,
            iconColor: AppTheme.error,
            title: "Logout",
            textColor: AppTheme.error,
            showChevron: false,
            onTap: _logout,
          ),

          const SizedBox(height: 26),

          Center(
            child: Text(
              "TechStile v1.0.0",
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.textPrimary.withOpacity(0.35),
                fontWeight: FontWeight.w500,
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
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppTheme.textPrimary.withOpacity(0.45),
          letterSpacing: 0.9,
        ),
      ),
    );
  }

  Widget _tile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color iconColor = AppTheme.primary,
    Color textColor = AppTheme.textPrimary,
    bool showChevron = true,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppTheme.secondary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: _primaryShadow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(icon, color: iconColor, size: 18),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ),
                if (showChevron)
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppTheme.primary.withOpacity(0.30),
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
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
      textCancel: "No",
      textConfirm: "Yes",
      confirmTextColor: AppTheme.secondary,
      cancelTextColor: AppTheme.primary,
      buttonColor: AppTheme.primary,

      onConfirm: () {
        AuthService.logout();

        Get.offAllNamed('/login');
      },
    );
  }
}