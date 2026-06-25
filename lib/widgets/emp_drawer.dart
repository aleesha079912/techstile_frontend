import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:techstile_frontend/screens/employee_dashboard/employee_dashboard.dart';
import 'package:techstile_frontend/screens/employee_dashboard/profile.dart';
// import 'package:techstile_frontend/screens/app_Owner_dashboard/machine/scan_code.dart';
import 'package:techstile_frontend/screens/employee_dashboard/scan_qr_code.dart';
import 'package:techstile_frontend/screens/employee_dashboard/history_screen.dart';
// import 'package:techstile_frontend/screens/employee/payment_screen.dart';

class EmployeeDrawer extends StatelessWidget {
  final dynamic userId;

  const EmployeeDrawer({super.key, this.userId});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // HEADER
          Container(
            height: 80,
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colors.primary,
            ),
            child: const Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                "Employee Panel",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // MENU
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [

                _item(
                  context,
                  Icons.dashboard,
                  "Dashboard",
                  () => Get.off(() => const EmployeeDashboard()),
                ),

                

                _item(
                  context,
                  Icons.qr_code_scanner,
                  "Scan QR",
                  () => Get.off(() => const ScanqrCodeScreen()),
                ),

                _item(
                  context,
                  Icons.history,
                  "Profile",
                  () => Get.off(() => UserProfileScreen(userId: userId)),
                ),

                _item(
                  context,
                  Icons.payment,
                  "History Screen",
                  () => Get.off(() => const HistoryScreen()),
                ),

                const Divider(),

                _item(
                  context,
                  Icons.logout,
                  "Logout",
                  () {
                    // optional: clear storage
                    // GetStorage().erase();

                    Get.offAllNamed("/login");
                  },
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
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
      onTap: () {
        Get.back(); // close drawer
        onTap();
      },
    );
  }
}