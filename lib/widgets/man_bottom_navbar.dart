import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/utils/theme.dart';
import '../routes/routes.dart';

class ManagerBottomNav extends StatelessWidget {
  final int currentIndex;
  final dynamic factoryId;

  const ManagerBottomNav({
    super.key,
    required this.currentIndex,
    required this.factoryId,
  });

  static const _items = [
    (Icons.grid_view_rounded,                'HOME'),
    (Icons.precision_manufacturing_outlined, 'MACHINES'),
    (Icons.people_outline_rounded,           'EMPLOYEES'),
    (Icons.credit_card_outlined,             'PAYMENTS'),
  ];

  void _onTap(int index) {
  if (index == currentIndex) return;

  switch (index) {
    case 0:
      Get.offNamed(AppRoutes.managerDashboard);
      break;

    case 1:
      Get.offNamed(AppRoutes.managerMachines);
      break;

    case 2:
      Get.offNamed(AppRoutes.managerEmployees);
      break;

    case 3:
      Get.offNamed(AppRoutes.managerPayments);
      break;
  }
}

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.primary,
        boxShadow: AppTheme.softShadow,
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(_items.length, (i) {
              final selected = i == currentIndex;
              final color = selected
                  ? AppTheme.secondary
                  : Colors.white.withOpacity(0.5);

              return Expanded(
                child: InkWell(
                  onTap: () => _onTap(i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_items[i].$1, size: 22, color: color),
                      const SizedBox(height: 4),
                      Text(
                        _items[i].$2,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.4,
                          color: color,
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