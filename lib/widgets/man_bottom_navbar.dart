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
    (Icons.people_outline_rounded,           'PAYMENTS'),
    (Icons.credit_card_outlined,             'EMPLOYEES'),
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
          Get.offNamed(AppRoutes.managerPayments);
        break;

      case 3:
      
         Get.offNamed(AppRoutes.managerEmployees);
        break;
    }
  }
// swipe detection
  void _onSwipe(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity.abs() < 150) return; 

    if (velocity < 0) {
      // left swipe
      final next = currentIndex + 1;
      if (next < _items.length) _onTap(next);
    } else {
      // right swipe
      final prev = currentIndex - 1;
      if (prev >= 0) _onTap(prev);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragEnd: _onSwipe,
      child: Container(
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
                    : AppTheme.secondary.withOpacity(0.5);

                return Expanded(
                  child: InkWell(
                    onTap: () => _onTap(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOut,
                      decoration: BoxDecoration(
                        color: selected
                            ? AppTheme.secondary.withOpacity(0.08)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
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
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}