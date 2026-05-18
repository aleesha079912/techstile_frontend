// Manager Dashboard ka sample
import 'package:flutter/material.dart';

class ManagerDashboard extends StatelessWidget {
  const ManagerDashboard({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Manager Dashboard"), backgroundColor: Colors.blueGrey),
      body: Center(child: Text("Welcome, Manager! Yahan aap production verify kar sakte hain.")),
    );
  }
}