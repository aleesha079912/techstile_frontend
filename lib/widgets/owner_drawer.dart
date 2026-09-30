import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:techstile_frontend/core/utils/theme.dart';
import 'package:techstile_frontend/screens/app_Owner_dashboard/machine/scan_code.dart';
import 'package:techstile_frontend/screens/app_Owner_dashboard/employee/attendance.dart';
import 'package:techstile_frontend/screens/app_Owner_dashboard/app_owner_dash.dart';
import 'package:techstile_frontend/screens/app_Owner_dashboard/machine/machine_assignment.dart';
import 'package:techstile_frontend/screens/app_Owner_dashboard/role_management.dart';
import 'package:techstile_frontend/screens/app_Owner_dashboard/assign_permission.dart';
import 'package:techstile_frontend/routes/routes.dart';

class OwnerDrawer extends StatelessWidget {
  final bool isPermanent;
  final int? selectedIndex;
  final ValueChanged<int>? onTabSelected;

  const OwnerDrawer({
    super.key,
    this.isPermanent = false,
    this.selectedIndex,
    this.onTabSelected,
  });

  int get factoryId => 0;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // BRAND HEADER 
        Container(
          padding: EdgeInsets.fromLTRB(20, isPermanent ? 28 : 36, 20, 20),
          decoration: const BoxDecoration(
            color: AppTheme.primary,
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppTheme.secondary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.precision_manufacturing_rounded,
                  color: AppTheme.secondary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "TechStile",
                      style: TextStyle(
                        color:  AppTheme.textSecondary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                    Text(
                      "Owner Admin Portal",
                      style: TextStyle(
                        color:  AppTheme.textneutral,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // NAVIGATION LIST
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            children: [
              // Main Navigation (Present on Desktop Permanent Sidebar)
              if (isPermanent) ...[
                _sectionLabel("MAIN NAVIGATION"),
                _item(
                  context,
                  Icons.dashboard_rounded,
                  "Factories & Home",
                  () => _navigateTab(0),
                  isSelected: selectedIndex == 0,
                ),
                _item(
                  context,
                  Icons.people_alt_rounded,
                  "User Management",
                  () => _navigateTab(1),
                  isSelected: selectedIndex == 1,
                ),
                _item(
                  context,
                  Icons.notifications_active_rounded,
                  "System Alerts",
                  () => _navigateTab(2),
                  isSelected: selectedIndex == 2,
                ),
                _item(
                  context,
                  Icons.settings_rounded,
                  "Settings & Profile",
                  () => _navigateTab(3),
                  isSelected: selectedIndex == 3,
                ),
                const SizedBox(height: 8),
              ] else ...[
                _item(
                  context,
                  Icons.dashboard_rounded,
                  "Home",
                  () => Get.to(() => const OwnerDashboardScreen(factoryId: 0)),
                ),
              ],

              // Management Operations Section
              _sectionLabel("MANAGEMENT"),

              // User Management Submenu (Roles & Permissions)
              ExpansionTile(
                leading: const Icon(Icons.security_rounded, color: AppTheme.primary, size: 22),
                title: const Text(
                  "Roles & Permissions",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13.5,
                    color: AppTheme.textPrimary,
                  ),
                ),
                childrenPadding: const EdgeInsets.only(left: 12),
                shape: const Border(),
                children: [
                  _item(
                    context,
                    Icons.admin_panel_settings_outlined,
                    "Manage Roles",
                    () => Get.to(() => RoleManagementScreen()),
                  ),
                  _item(
                    context,
                    Icons.vpn_key_outlined,
                    "Assign Permissions",
                    () => Get.to(() => const AssignPermissionsScreen()),
                  ),
                ],
              ),

              _item(
                context,
                Icons.factory_outlined,
                "Machine Assignment",
                () => Get.to(() => const MachineAssignmentPage()),
              ),
              _item(
                context,
                Icons.qr_code_scanner_rounded,
                "Scan Machine",
                () => Get.toNamed(AppRoutes.scanMachine),
              ),
              _item(
                context,
                Icons.access_time_filled_rounded,
                "Manage Attendance",
                () => Get.to(() => const AttendanceScreen()),
              ),
              _item(
                context,
                Icons.qr_code_rounded,
                "Generate QR Codes",
                () => Get.to(() => ScanQRCodeScreen(factoryId: factoryId)),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Divider(height: 1),
              ),

              // System & Logout
              _item(
                context,
                Icons.logout_rounded,
                "Logout",
                () => Get.offAllNamed("/login"),
                iconColor: AppTheme.error,
                textColor: AppTheme.error,
              ),
            ],
          ),
        ),
      ],
    );

    // If permanent desktop sidebar, return a styled Container instead of full modal Drawer
    if (isPermanent) {
      return Container(
        color: AppTheme.secondary,
        child: content,
      );
    }

    return Drawer(
      backgroundColor: AppTheme.background,
      child: content,
    );
  }

  void _navigateTab(int index) {
    if (onTabSelected != null) {
      onTabSelected!(index);
    } else {
      Get.offAll(() => const OwnerDashboardScreen(factoryId: 0));
    }
  }

  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 12, bottom: 6),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color:  AppTheme.textneutral,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _item(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTapAction, {
    bool isSelected = false,
    Color? iconColor,
    Color? textColor,
  }) {
    final activeColor = iconColor ?? AppTheme.primary;
    final textActiveColor = textColor ?? (isSelected ? AppTheme.primary : AppTheme.primary);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: isSelected ? AppTheme.primary.withOpacity(0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: ListTile(
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
          leading: Icon(
            icon,
            color: isSelected ? AppTheme.primary : activeColor.withOpacity(0.85),
            size: 21,
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 13.5,
              color: textActiveColor,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          trailing: isSelected
              ? Container(
                  width: 6,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                )
              : null,
          onTap: () {
            if (!isPermanent) {
              Get.back(); // Close modal drawer on mobile
            }
            onTapAction();
          },
        ),
      ),
    );
  }
}