import 'package:flutter/material.dart';

class EmployeeBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const EmployeeBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.dashboard, "Dashboard"),
      (Icons.qr_code_scanner, "Scan"),
      (Icons.history, "History"),
      (Icons.payment, "Payments"),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0D1B4B),
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
                  onTap: () => onTap(index),
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