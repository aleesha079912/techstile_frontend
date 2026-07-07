import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/services/manager_service/man_emp_notification_service.dart';
import '../routes/routes.dart';
import '../../core/services/auth_service.dart';

class ManagerDrawer extends StatefulWidget {
  final dynamic userId;
  final dynamic factoryId;

  const ManagerDrawer({super.key, this.userId, this.factoryId});

  @override
  State<ManagerDrawer> createState() => _ManagerDrawerState();
}

class _ManagerDrawerState extends State<ManagerDrawer> {
  final NotificationService notificationService = NotificationService();

  int unread = 0;

  @override
  void initState() {
    super.initState();

    getUnread();
  }

  void getUnread() async {
    final count = await notificationService.getUnreadCount(AuthService.userId);

    if (mounted) {
      setState(() {
        unread = count;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Drawer(
      backgroundColor: Colors.white,

      child: Column(
        children: [
          Container(
            height: 90,

            width: double.infinity,

            padding: const EdgeInsets.all(20),

            decoration: BoxDecoration(color: colors.primary),

            child: const Align(
              alignment: Alignment.bottomLeft,

              child: Text(
                "Manager Panel",

                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,

              children: [
                // _item(context, Icons.dashboard, "Dashboard", () {
                //   Get.back();

                //   Get.offNamed(AppRoutes.managerDashboard);
                // }),

                _item(
                  context,
                  Icons.production_quantity_limits,
                  "View Production",
                  () {
                    Get.back();

                    Get.offNamed(AppRoutes.managerProduction);
                  },
                ),

                _item(context, Icons.person, "Profile", () {
                  Get.back();

                  Get.toNamed(AppRoutes.managerProfile);
                }),

                _item(context, Icons.settings, "Settings", () {
                  Get.back();

                  Get.toNamed(AppRoutes.managersettings);
                }),

                // ⭐ Notifications with count
               ListTile(

                      leading: Badge(
                        isLabelVisible: unread > 0,
                        label: Text(
                          unread.toString(),
                        ),
                        child: Icon(
                          Icons.notifications,
                          color: colors.primary,
                        ),
                      ),

                      title: const Text("Notifications"),

                      onTap: () async {

                      Get.back();

                      await Get.toNamed(
                        AppRoutes.managerNotifications
                      );

                      getUnread();

                      },

                      ),

                _item(context, Icons.qr_code_scanner, "Scan Machine", () {
                  Get.back();

                  Get.toNamed(AppRoutes.managerScanMachine);
                }),

                const Divider(),

                _item(context, Icons.logout, "Logout", () {
                  Get.offAllNamed(AppRoutes.login);
                }),
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

        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),

      onTap: onTap,
    );
  }
}
