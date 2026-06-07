import 'package:flutter/material.dart';
import 'package:techstile_frontend/core/services/employee_dashboard_service.dart';
import 'package:techstile_frontend/widgets/emp_db_bot_nav_bar.dart';


class EmployeeDashboard extends StatefulWidget {
  const EmployeeDashboard({super.key});

  @override
  State<EmployeeDashboard> createState() => _EmployeeDashboardState();
}

class _EmployeeDashboardState extends State<EmployeeDashboard> {

  final dynamic service = EmployeeDashboardService();

  bool loading = true;

  int today = 0;
  int weekly = 0;
  String machine = "";
  int machineCount = 0;
  int efficiency = 0;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final data = await service.getDashboard(1); // employee id

    setState(() {
      today = data['today_production'] ?? 0;
      weekly = data['weekly_production'] ?? 0;
      machine = data['assigned_machine'] ?? "N/A";
      machineCount = data['machine_count'] ?? 0;
      efficiency = data['efficiency'] ?? 0;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: const Color(0xffF5F7FB),

      appBar: AppBar(
        title: const Text("LOOM CONTROL"),
        backgroundColor: const Color(0xFF0B2C6B),
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())

          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text(
                    "SHIFT SUPERVISOR DASHBOARD",
                    style: TextStyle(color: Colors.grey),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "Floor Overview",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // SCAN BUTTON
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B2C6B),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.qr_code_scanner, color: Colors.white),
                          SizedBox(width: 10),
                          Text("SCAN QR",
                              style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // TODAY PRODUCTION
                  _card("Production Units Today", "$today YARDS", Colors.green),

                  const SizedBox(height: 12),

                  // MACHINE
                  _machineCard(),

                  const SizedBox(height: 12),

                  // EFFICIENCY
                  _efficiencyCard(),
                ],
              ),
            ),

      bottomNavigationBar: EmployeeBottomNav(
        currentIndex: 0,
        onTap: (i) {},
      ),
    );
  }

  Widget _card(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _machineCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Assigned Machine"),
          const SizedBox(height: 8),
          Text(
            machine,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text("Total Machines: $machineCount"),
        ],
      ),
    );
  }

  Widget _efficiencyCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Efficiency"),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: efficiency / 100,
          ),
          const SizedBox(height: 10),
          Text("Current $efficiency%"),
        ],
      ),
    );
  }
}