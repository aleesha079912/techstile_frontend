import 'package:flutter/material.dart';
import '../../../core/utils/theme.dart';
import '../../../core/services/manager_service/manager_employee_detail_service.dart';

class ManagerEmployeeDetailScreen extends StatefulWidget {

  final int employeeId;

  const ManagerEmployeeDetailScreen({
    super.key,
    required this.employeeId,
  });

  @override
  State<ManagerEmployeeDetailScreen> createState() =>
      _ManagerEmployeeDetailScreenState();
}

class _ManagerEmployeeDetailScreenState
    extends State<ManagerEmployeeDetailScreen> {

  final service = ManagerEmployeeDetailService();

  bool loading = true;
  Map<String, dynamic>? employee;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final data =
        await service.getEmployeeDetail(widget.employeeId);

    setState(() {
      employee = data;
      loading = false;
    });
  }

  Widget statCard(
      String title,
      String value,
      IconData icon,
      ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            color: Colors.black12,
          )
        ],
      ),
      child: Column(
        children: [
          Icon(icon,
              color: AppTheme.primary,
              size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(title),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    if (loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,

      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        title: const Text(
          "Employee Detail",
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            CircleAvatar(
              radius: 45,
              backgroundColor:
              AppTheme.primary,
              child: Text(
                employee!['name'][0]
                    .toUpperCase(),
                style: const TextStyle(
                  fontSize: 32,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 12),

            Text(
              employee!['name'] ?? '',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            Text(
              employee!['email'] ?? '',
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 24),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                BorderRadius.circular(18),
              ),

              child: Column(
                children: [

                  ListTile(
                    leading: const Icon(Icons.access_time),
                    title: const Text("Shift Start"),
                    trailing: Text(
                      employee!['shift_start']
                          .toString(),
                    ),
                  ),

                  ListTile(
                    leading: const Icon(Icons.timer_off),
                    title: const Text("Shift End"),
                    trailing: Text(
                      employee!['shift_end']
                          .toString(),
                    ),
                  ),

                ],
              ),
            ),

            const SizedBox(height: 20),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics:
              const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,

              children: [

                statCard(
                  "Production",
                  employee!['total_production']
                      .toString(),
                  Icons.factory,
                ),

                statCard(
                  "Waste",
                  employee!['total_waste']
                      .toString(),
                  Icons.delete_outline,
                ),

                statCard(
                  "Machines",
                  employee!['machines_worked']
                      .toString(),
                  Icons.precision_manufacturing,
                ),

                statCard(
                  "Entries",
                  employee!['total_entries']
                      .toString(),
                  Icons.list_alt,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}