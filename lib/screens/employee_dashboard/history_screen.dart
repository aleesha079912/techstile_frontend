import 'package:flutter/material.dart';
import 'package:techstile_frontend/widgets/emp_db_bot_nav_bar.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text('HistoryScreen'),
      bottomNavigationBar: EmployeeBottomNav(currentIndex: 0),
    );
  }
}