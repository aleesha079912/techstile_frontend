import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:techstile_frontend/screens/employee_dashboard/history_screen.dart';

import '../screens/employee_dashboard/employee_dashboard.dart';
import '../screens/employee_dashboard/scan_qr_code.dart';
// import '../screens/payments/payment_screen.dart';

class EmployeeBottomNav extends StatelessWidget {
  final int currentIndex;

  const EmployeeBottomNav({
    super.key,
    required this.currentIndex,
  });

  void _changeTab(int index) {
    if (index == currentIndex) return;

    switch (index) {
      case 0:
        Get.off(() => const EmployeeDashboard());
        break;

      case 1:
        Get.off(() => const ScanqrCodeScreen());
        break;

      case 2:
        Get.off(() => const HistoryScreen());
        break;

      case 3:
        // Get.off(() => const PaymentScreen());
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.dashboard, "Home"),
      (Icons.qr_code_scanner, "Scan"),
      (Icons.history, "History"),
      (Icons.payment, "Payments"),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0D1B4B), // from your theme
      ),
      child: SafeArea(
        child: SizedBox(
          height: 65,
          child: Row(
            children: List.generate(items.length, (index) {
              final isActive = index == currentIndex;

              final color = isActive
                  ? const Color(0xFF00C8B0)
                  : const Color(0xFF8FA3C8);

              return Expanded(
                child: InkWell(
                  onTap: () => _changeTab(index),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(items[index].$1, color: color, size: 22),
                      const SizedBox(height: 4),
                      Text(
                        items[index].$2,
                        style: TextStyle(
                          fontSize: 10,
                          color: color,
                          fontWeight: FontWeight.w500,
                        ),
                      )
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