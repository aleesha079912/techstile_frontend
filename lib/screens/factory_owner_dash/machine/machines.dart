
import 'package:flutter/material.dart';
import '../../../../core/services/machines_service.dart';
import '../../../../core/utils/theme.dart'; // 👈 import your theme
// import '../../../../widgets/bottom_nav_bar.dart';
class MachinesScreen extends StatefulWidget {
  const MachinesScreen({super.key});

  @override
  State<MachinesScreen> createState() => _MachinesScreenState();
}

class _MachinesScreenState extends State<MachinesScreen> {
  final service = MachinesService();
  MachinesData? data;

  @override
  void initState() {
    super.initState();
    load();
  }

  void load() async {
    final res = await service.fetchMachines();
    setState(() => data = res);
  }

  @override
  Widget build(BuildContext context) {
    if (data == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.secondary, // ✅ from theme
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primary, // ✅ from theme
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "All Machines",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Real-time status of loom operations"),
              ),

              const SizedBox(height: 16),

              /// Search
              TextField(
                decoration: InputDecoration(
                  hintText: "Search assets...",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// Stats
              Row(
                children: [
                  _statCard("Running", data!.running, Colors.green),
                  const SizedBox(width: 8),
                  _statCard("Maintenance", data!.maintenance, Colors.blue),
                  const SizedBox(width: 8),
                  _statCard("Offline", data!.offline, Colors.red),
                ],
              ),

              const SizedBox(height: 16),

              /// List
              Expanded(
                child: ListView.builder(
                  itemCount: data!.machines.length,
                  itemBuilder: (context, i) {
                    final m = data!.machines[i];
                    return _machineTile(m);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard(String title, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 6),
            Text(
              "$count",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _machineTile(Machine m) {
    Color color;
    if (m.status == "Running") {
      color = Colors.green;
    } else if (m.status == "Maintenance") {
      color = Colors.blue;
    } else {
      color = Colors.red;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  m.id,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  m.type,
                  style: TextStyle(color: AppTheme.neutral), // ✅ theme color
                ),
              ],
            ),
          ),
          Row(
            children: [
              CircleAvatar(radius: 4, backgroundColor: color),
              const SizedBox(width: 6),
              Text(m.status),
            ],
          )
        ],
      ),
    );
  }
} 



