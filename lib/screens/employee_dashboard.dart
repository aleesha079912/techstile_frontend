import 'package:flutter/material.dart';

class EmployeeDashboard extends StatelessWidget {
  const EmployeeDashboard({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Employee Dashboard"), backgroundColor: Colors.green),
      body: Center(child: Text("Welcome, Employee! Yahan aap production perform kar sakte hain.")),
    );
  }
}