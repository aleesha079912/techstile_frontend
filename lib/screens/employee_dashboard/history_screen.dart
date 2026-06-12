import 'package:flutter/material.dart';
import 'package:techstile_frontend/core/utils/theme.dart';
import 'package:techstile_frontend/widgets/emp_db_bot_nav_bar.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pendingProductions = [
      {
        'orderId': 'ORD-1001',
        'product': 'Cotton T-Shirt',
        'quantity': '500',
        'status': 'In Progress',
      },
      {
        'orderId': 'ORD-1002',
        'product': 'Denim Jeans',
        'quantity': '300',
        'status': 'Cutting',
      },
    ];

    final completedProductions = [
      {
        'orderId': 'ORD-0998',
        'product': 'Polo Shirt',
        'quantity': '400',
        'completedDate': '10 Jun 2026',
      },
      {
        'orderId': 'ORD-0997',
        'product': 'Track Pants',
        'quantity': '250',
        'completedDate': '08 Jun 2026',
      },
    ];

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Production History',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          bottom: TabBar(
            indicatorColor: AppTheme.tertiary,
            labelColor: Colors.black,
            unselectedLabelColor: AppTheme.neutral,
            tabs: const [
              Tab(text: 'Pending'),
              Tab(text: 'Completed'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Pending Tab
            ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: pendingProductions.length,
              itemBuilder: (context, index) {
                final item = pendingProductions[index];

                return Card(
                  color: AppTheme.secondary,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  margin: const EdgeInsets.only(bottom: 14),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primary,
                      child: const Icon(
                        Icons.factory,
                        color: Colors.black,
                      ),
                    ),
                    title: Text(
                      item['product']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        'Order: ${item['orderId']}\nQty: ${item['quantity']}',
                        style: const TextStyle(
                          color: AppTheme.neutral,
                        ),
                      ),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        item['status']!,
                        style: const TextStyle(
                          color: AppTheme.tertiary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            // Completed Tab
            ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: completedProductions.length,
              itemBuilder: (context, index) {
                final item = completedProductions[index];

                return Card(
                  color: AppTheme.secondary,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  margin: const EdgeInsets.only(bottom: 14),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.tertiary,
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      item['product']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        'Order: ${item['orderId']}\nQty: ${item['quantity']}',
                        style: const TextStyle(
                          color: AppTheme.neutral,
                        ),
                      ),
                    ),
                    trailing: Text(
                      item['completedDate']!,
                      style: const TextStyle(
                        color: AppTheme.tertiary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        bottomNavigationBar: const EmployeeBottomNav(
          currentIndex: 0,
        ),
      ),
    );
  }
}