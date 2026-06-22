import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:techstile_frontend/screens/app_Owner_dashboard/app_owner_dash.dart';
import 'package:techstile_frontend/screens/app_Owner_dashboard/employee/employees.dart';
import 'package:techstile_frontend/screens/app_Owner_dashboard/user/factory_users.dart';
import 'package:techstile_frontend/screens/app_Owner_dashboard/machine/manage_machines.dart';
import 'package:techstile_frontend/screens/factory_owner_dash/factorydashboard.dart';

class FactoryDrawer extends StatelessWidget {
  final int factoryId; // ✅ ADD THIS

  const FactoryDrawer({super.key, required this.factoryId});
  
  int get userId => userId; // ✅ ADD THIS

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 90,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 25),
            decoration: BoxDecoration(color: colors.primary),
            child: const Text(
              "Management Panel",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _item(
                  context,
                  Icons.dashboard_rounded,
                  "Home",
                  () => Get.to(() => OwnerDashboardScreen(factoryId: factoryId)),
                ),

                _item(
                  context,
                  Icons.badge_outlined,
                  "Factory Dashboard",
                  () => Get.to(() => FactoryDashboard(factoryId: factoryId.toString())),
                ),

                _item(
                  context,
                  Icons.people_outline,
                  "Manage Users",
                  () => Get.to(() => FactoryUsersScreen(factoryId: factoryId)),
                ),

                _item(
                  context,
                  Icons.precision_manufacturing_outlined,
                  "Manage Machines",
                  () => Get.to(() => MachinesScreen(factoryId: factoryId)),
                ),

                _item(
                  context,
                  Icons.badge_outlined,
                  "Manage Employees",
                  () => Get.to(() => EmployeeScreen(factoryId: factoryId, userId: userId)),
                ),

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
      title: Text(title),
      onTap: () {
        Get.back();
        onTapAction();
      },
    );
  }
}