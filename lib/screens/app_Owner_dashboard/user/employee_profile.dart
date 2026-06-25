import 'package:flutter/material.dart';
import 'package:techstile_frontend/core/services/employee_profile_service.dart';

class EmployeeProfileScreen extends StatefulWidget {
  final int userId;

  const EmployeeProfileScreen({super.key, required this.userId});

  @override
  State<EmployeeProfileScreen> createState() => _EmployeeProfileScreenState();
}

class _EmployeeProfileScreenState extends State<EmployeeProfileScreen> {
  final service = EmployeeProfileService();

  Map<String, dynamic>? profile;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final res = await service.getProfile(widget.userId);

    setState(() {
      profile = res?['data'];
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Employee Profile")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const CircleAvatar(radius: 40, child: Icon(Icons.person)),

                  const SizedBox(height: 10),

                  Text(profile?['name'] ?? '',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

                  Text(profile?['email'] ?? ''),

                  const SizedBox(height: 20),

                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          title: const Text("Total Production"),
                          subtitle: Text("${profile?['total_production'] ?? 0}"),
                        ),
                        ListTile(
                          title: const Text("Ready Production"),
                          subtitle: Text("${profile?['total_ready_production'] ?? 0}"),
                        ),
                        ListTile(
                          title: const Text("Attendance"),
                          subtitle: Text("${profile?['attendance_count'] ?? 0}"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}