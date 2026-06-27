import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import '../screens/factory_owner_dash/factorydashboard.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../screens/app_Owner_dashboard/machine/manage_machines.dart';
import '../screens/factory_owner_dash/payments.dart';
import '../screens/app_Owner_dashboard/user/factory_users.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final int factoryId; // ✅ ADD THIS

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.factoryId,
  });

  void _onTap(BuildContext context, int index) {
  if (index == currentIndex) return;

  switch (index) {
    case 0:
      // FactoryDashboard expects a String for factoryId, convert here
      Get.offAll(() => FactoryDashboard(factoryId: factoryId.toString()));
      break;

    case 1:
      // MachinesScreen expects an int factoryId
      Get.to(() => MachinesScreen(factoryId: factoryId));
      break;

    case 2:
      // Navigate to PaymentsScreen (constructor call)
      Get.to(() => PaymentsScreen(factoryId: factoryId));
      break;

    case 3:
      Get.to(() => FactoryUsersScreen(factoryId: factoryId));
      break;
  }
}

  @override
  Widget build(BuildContext context) {
    const tabs = [
      (Icons.grid_view_rounded, 'DASHBOARD'),
      (Icons.precision_manufacturing_outlined, 'MACHINES'),
      (Icons.credit_card_outlined, 'PAYMENTS'),
      (Icons.group_outlined, 'USERS'),
    ];

    return Container(
      color: const Color(0xFF0D1B4B),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            children: List.generate(tabs.length, (i) {
              final selected = i == currentIndex;
              final color = selected
                  ? const Color(0xFF00C8B0)
                  : const Color(0xFF6A7AA1);

              return Expanded(
                child: InkWell(
                  onTap: () => _onTap(context, i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(tabs[i].$1, size: 20, color: color),
                      const SizedBox(height: 4),
                      Text(
                        tabs[i].$2,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                          color: color,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}