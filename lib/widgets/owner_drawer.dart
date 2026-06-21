import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:techstile_frontend/screens/factory_owner_dash/pending_productions.dart';
import 'package:techstile_frontend/screens/app_Owner_dashboard/user/manage_users.dart';
import 'package:techstile_frontend/screens/app_Owner_dashboard/employee/attendance.dart';
import 'package:techstile_frontend/screens/app_Owner_dashboard/employee/employees.dart';
import 'package:techstile_frontend/screens/app_Owner_dashboard/app_owner_dash.dart';
import 'package:techstile_frontend/screens/app_Owner_dashboard/machine/machine_assignment.dart';
import 'package:techstile_frontend/screens/app_Owner_dashboard/role_management.dart';
import 'package:techstile_frontend/screens/app_Owner_dashboard/assign_paermission.dart';
class OwnerDrawer extends StatelessWidget {
  const OwnerDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // HEADER 
          Container(
            height: 90,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 25),
            decoration: BoxDecoration(color: colors.primary),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Management Panel",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // LIST ITEMS
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                 _item(
                  context,
                  Icons.dashboard_rounded,
                  "Home",
                  () => Get.to(() => OwnerDashboardScreen(factoryId: 0)),
                ),
                // _item(
                //   context,
                //   Icons.badge_outlined,
                //   "Factory Dashboard",
                //     () => Get.to(() => FactoryDashboardScreen(factoryId: FactoryDrawer().factoryId)),
                // ),
                //sub menu for user management
                      ExpansionTile(
                        leading: Icon(Icons.security_rounded, color: colors.primary),
                        title: const Text(
                          "User Management",
                          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                        ),
                        childrenPadding: const EdgeInsets.only(left: 20), // Sub-menu offset
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
                            () => Get.to(() => AssignPermissionsScreen()),
                          ),
                        ],
                      ),
                _item(
                  context,
                  Icons.people_outline,
                  "Manage Users",
                  () => Get.to(() => const ManageUsersScreen()),
                ),
                _item(
                  context,
                  Icons.factory_outlined,
                  "Machine Assignment",
                 () => Get.to(() => const MachineAssignmentPage()),
                ),
                // _item(
                //   context,
                //   Icons.factory_outlined,
                //   "View Assignment",
                //  () => Get.to(() => const ViewAssignments()),
                // ),
                _item(
                  context,
                  Icons.badge_outlined,
                  "Manage Employees",
                    () => Get.to(() => const EmployeeScreen()),
                ),
                _item(
                  context,
                  Icons.access_time_rounded,
                  "Manage Attendance",
                  () => Get.to(() => const AttendanceScreen()),
                ),
                _item(
                  context,
                  Icons.badge_outlined,
                  "Manage production",
                    () => Get.to(() => const PendingProductionScreen()),
                ),
                //  _item(
                //   context,
                //   Icons.qr_code_scanner,
                //   "Scan QR Code",
                //     () => Get.to(() => const ScanQRCodeScreen()),
                // ),
                const Divider(),
                _item(
                  context,
                  Icons.logout_rounded,
                  "Logout",
                  () => Get.toNamed("/login"),
                ),
              ],
              
            ),
          ),
        ],
      ),
    );
  }

  Widget _item(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTapAction,
  ) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
      ),
      onTap: () {
        Get.back(); // close Drawer 
        onTapAction();
      },
    );
  }
}