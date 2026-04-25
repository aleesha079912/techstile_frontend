// import 'package:flutter/material.dart';
import 'package:get/get.dart';

// class BottomNavBar extends StatelessWidget {
//   final int currentIndex;

//   const BottomNavBar({super.key, required this.currentIndex});

//   void onTap(int index) {
//     switch (index) {
//       case 0:
//         Get.offAllNamed('/owner-dashboard-screen');
//         break;
//       case 1:
//         Get.offAllNamed('/machines');
//         break;
//       case 2:
//         Get.offAllNamed('/payments');
//         break;
//       case 3:
//         Get.offAllNamed('/users');
//         break;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BottomNavigationBar(
//       currentIndex: currentIndex,
//       onTap: onTap,
//       selectedItemColor: const Color.fromARGB(255, 47, 33, 243),
//       unselectedItemColor: const Color.fromARGB(255, 158, 158, 158),
//       items: const [
//         BottomNavigationBarItem(
//           icon: Icon(Icons.dashboard),
//           label: "Dashboard",
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.precision_manufacturing),
//           label: "Machines",
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.payment),
//           label: "Payments",
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.people),
//           label: "Users",
      
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import '../screens/factory_owner_dash/owner_dashboard.dart';
import '../screens/factory_owner_dash/machine/machines.dart';
import '../screens/factory_owner_dash/payments.dart';
import '../screens/factory_owner_dash/users.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNav({super.key, required this.currentIndex});

  void _onTap(BuildContext context, int index) {
    if (index == currentIndex) return;

    Widget page;

    switch (index) {
      case 0:
        page = const OwnerDashboardScreen();
        break;
      case 1:
        page = const MachinesScreen();
        break;
      case 2:
        page = const PaymentsScreen();
        break;
      case 3:
        page = const UsersScreen();
        break;
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
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
      color: const Color(0xFF0D1B4B), // navy
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            children: List.generate(tabs.length, (i) {
              final selected = i == currentIndex;
              final color = selected
                  ? const Color(0xFF00C8B0) // teal
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