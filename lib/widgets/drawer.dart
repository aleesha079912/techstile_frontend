import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:techstile_frontend/screens/factory_owner_dash/user/manage_users.dart';
import 'package:techstile_frontend/screens/factory_owner_dash/machine/machines.dart';
import 'package:techstile_frontend/screens/factory_owner_dash/owner_dashboard.dart';
class OwnerDrawer extends StatelessWidget {
  const OwnerDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // Theme colors uthana
    final colors = Theme.of(context).colorScheme;

    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // HEADER (Blue Area)
          Container(
            height: 120,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 25),
            decoration: BoxDecoration(color: colors.primary),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Factory Owner",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Management Panel",
                  style: TextStyle(color: Colors.white70, fontSize: 13),
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
                  () => Get.to(() => const OwnerDashboardScreen()),
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
                  "Manage Production",
                  () => Get.toNamed("/production"),
                ),
                _item(
                  context,
                  Icons.precision_manufacturing_outlined,
                  "Manage Machines",
                  () => Get.to(() => const MachinesScreen()),
                ),
                _item(
                  context,
                  Icons.access_time_rounded,
                  "Manage Attendance",
                  () => Get.toNamed("/attendance"),
                ),
                _item(
                  context,
                  Icons.badge_outlined,
                  "Manage Employees",
                  () => Get.toNamed("/employee"),
                ),
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
        Get.back(); // Drawer band karein
        onTapAction();
      },
    );
  }
}
