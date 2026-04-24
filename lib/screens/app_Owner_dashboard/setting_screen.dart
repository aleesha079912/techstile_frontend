import 'package:flutter/material.dart';
import 'package:get/get.dart';

const _navy   = Color(0xFF1E3A8A);
const _blue   = Color(0xFF2563EB);
const _bgPage = Color(0xFFF0F4FF);
const _white  = Colors.white;
const _slate  = Color(0xFF64748B);

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = true;
  bool _emailAlerts   = false;
  bool _darkMode      = false;
  bool _autoBackup    = true;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        children: [
          _buildProfileCard(),
          const SizedBox(height: 20),
          _buildSection(
            title: "Account",
            items: [
              _SettingsTile(
                icon: Icons.person_rounded,
                iconColor: _navy,
                label: "Edit Profile",
                onTap: () => _showSnack("Edit Profile"),
              ),
              _SettingsTile(
                icon: Icons.lock_rounded,
                iconColor: const Color(0xFF7C3AED),
                label: "Change Password",
                onTap: () => _showSnack("Change Password"),
              ),
              _SettingsTile(
                icon: Icons.verified_user_rounded,
                iconColor: const Color(0xFF059669),
                label: "Verification Status",
                trailing: _verifiedBadge(),
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            title: "Preferences",
            items: [
              _SettingsTile(
                icon: Icons.notifications_rounded,
                iconColor: const Color(0xFFD97706),
                label: "Push Notifications",
                trailing: _toggle(_notifications,
                    (v) => setState(() => _notifications = v)),
                onTap: () {},
              ),
              _SettingsTile(
                icon: Icons.email_rounded,
                iconColor: const Color(0xFF0891B2),
                label: "Email Alerts",
                trailing: _toggle(
                    _emailAlerts, (v) => setState(() => _emailAlerts = v)),
                onTap: () {},
              ),
              _SettingsTile(
                icon: Icons.dark_mode_rounded,
                iconColor: const Color(0xFF6366F1),
                label: "Dark Mode",
                trailing: _toggle(
                    _darkMode, (v) => setState(() => _darkMode = v)),
                onTap: () {},
              ),
              _SettingsTile(
                icon: Icons.cloud_upload_rounded,
                iconColor: const Color(0xFF059669),
                label: "Auto Backup",
                trailing: _toggle(
                    _autoBackup, (v) => setState(() => _autoBackup = v)),
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            title: "Support",
            items: [
              _SettingsTile(
                icon: Icons.help_rounded,
                iconColor: _blue,
                label: "Help & FAQ",
                onTap: () => _showSnack("Help & FAQ"),
              ),
              _SettingsTile(
                icon: Icons.feedback_rounded,
                iconColor: const Color(0xFFD97706),
                label: "Send Feedback",
                onTap: () => _showSnack("Send Feedback"),
              ),
              _SettingsTile(
                icon: Icons.privacy_tip_rounded,
                iconColor: _slate,
                label: "Privacy Policy",
                onTap: () => _showSnack("Privacy Policy"),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildLogoutButton(),
          const SizedBox(height: 12),
          const Center(
            child: Text(
              "TechStile v1.0.0",
              style: TextStyle(
                fontSize: 11,
                color: _slate,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnack(String label) {
    Get.snackbar(
      label,
      "Coming soon",
      backgroundColor: _white,
      colorText: _navy,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 14,
      duration: const Duration(seconds: 2),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_navy, Color(0xFF1D4ED8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _navy.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: _white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    "AK",
                    style: TextStyle(
                      color: _white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: const Color(0xFF059669),
                    shape: BoxShape.circle,
                    border: Border.all(color: _white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Abdul Kareem",
                  style: TextStyle(
                    color: _white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  "owner@techstile.pk",
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "Factory Owner",
                    style: TextStyle(
                      color: _white,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _showSnack("Edit Profile"),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.edit_rounded, color: _white, size: 17),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<_SettingsTile> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: _navy,
              letterSpacing: 0.9,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: _white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: _navy.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: List.generate(items.length, (i) {
              final isLast = i == items.length - 1;
              return Column(
                children: [
                  items[i],
                  if (!isLast)
                    Divider(
                      height: 1,
                      indent: 56,
                      endIndent: 16,
                      color: const Color(0xFFF1F5F9),
                    ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _verifiedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFD1FAE5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        "Verified",
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Color(0xFF065F46),
        ),
      ),
    );
  }

  Widget _toggle(bool value, ValueChanged<bool> onChanged) {
    return Transform.scale(
      scale: 0.85,
      child: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: _navy,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  Widget _buildLogoutButton() {
    return GestureDetector(
      onTap: () => _confirmLogout(),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: const Color(0xFFFEE2E2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFFCA5A5),
            width: 1,
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded,
                color: Color(0xFFDC2626), size: 18),
            SizedBox(width: 8),
            Text(
              "Log Out",
              style: TextStyle(
                color: Color(0xFFDC2626),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          "Log Out?",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
          ),
        ),
        content: const Text(
          "Are you sure you want to log out of your account?",
          style: TextStyle(color: _slate, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancel",
                style: TextStyle(color: _slate)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                "Logged Out",
                "See you next time!",
                backgroundColor: _white,
                colorText: _navy,
                snackPosition: SnackPosition.BOTTOM,
                margin: const EdgeInsets.all(16),
                borderRadius: 14,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: _white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text("Log Out"),
          ),
        ],
      ),
    );
  }
}

// ─── Settings Tile ───────────────────────────────────────────
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final Widget? trailing;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, color: iconColor, size: 17),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              trailing ??
                  Icon(
                    Icons.chevron_right_rounded,
                    color: _slate.withOpacity(0.4),
                    size: 20,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}