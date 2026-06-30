import 'package:flutter/material.dart';
import 'package:techstile_frontend/core/services/manager_service/manager_profile_service.dart';
import 'package:techstile_frontend/widgets/man_drawer.dart';
import 'package:techstile_frontend/core/services/auth_service.dart';
class ManagerProfileScreen extends StatefulWidget {
  final int userId;

  const ManagerProfileScreen({super.key, required this.userId});

  @override
  State<ManagerProfileScreen> createState() => _ManagerProfileScreenState();
}

class _ManagerProfileScreenState extends State<ManagerProfileScreen> {
  final service = ManagerProfileService();

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
       drawer: ManagerDrawer(
  userId: AuthService.userId,
  factoryId: AuthService.factoryId,
),
      appBar: AppBar(title: const Text("Manager Profile")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const CircleAvatar(radius: 40, child: Icon(Icons.admin_panel_settings)),

                  const SizedBox(height: 10),

                  Text(profile?['name'] ?? '',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

                  Text(profile?['email'] ?? ''),

                  const SizedBox(height: 20),

                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          title: const Text("Total Employees"),
                          subtitle: Text("${profile?['total_employees'] ?? 0}"),
                        ),
                        ListTile(
                          title: const Text("Total Production"),
                          subtitle: Text("${profile?['total_production'] ?? 0}"),
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