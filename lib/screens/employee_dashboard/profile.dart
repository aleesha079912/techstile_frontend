import 'package:flutter/material.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/employee_service/profile_service.dart';
import '../../core/utils/theme.dart';
import 'package:techstile_frontend/widgets/emp_drawer.dart';
class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() =>
      _UserProfileScreenState();
}

class _UserProfileScreenState
    extends State<UserProfileScreen> {
  final service =
      EmployeeProfileService();

  Map<String, dynamic>? profile;

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

 Future<void> loadProfile() async {
  final user = AuthService.user;

  if (user == null) {
    print("User is null");
    return;
  }

  final response = await service.getProfile(user['id']);
  print(response);

  setState(() {
   profile = response?['data'];
    loading = false;
  });
}

  Widget tile(
    IconData icon,
    String title,
    String value,
  ) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppTheme.primary,
      ),
      title: Text(title),
      subtitle: Text(value),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const EmployeeDrawer(),
      backgroundColor:
          AppTheme.secondary,

      appBar: AppBar(
        title: const Text(
          "My Profile",
        ),
      ),

      body: loading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),

                  CircleAvatar(
                    radius: 50,
                    backgroundColor:
                        AppTheme.primary,
                    child: const Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  Text(
                    profile?['name'] ?? '',
                    style:
                        const TextStyle(
                      fontSize: 22,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  Text(
                    profile?['email'] ??
                        '',
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  Card(
                    margin:
                        const EdgeInsets
                            .all(15),
                    child: Column(
                      children: [
                        tile(
                          Icons.phone,
                          "Phone",
                          profile?['phone_no'] ??
                              '',
                        ),
                        tile(
                          Icons.badge,
                          "CNIC",
                          profile?['cnic'] ??
                              '',
                        ),
                        tile(
                          Icons.home,
                          "Address",
                          profile?['address'] ??
                              '',
                        ),
                        tile(
                          Icons.info,
                          "Details",
                          profile?['employee_details'] ??
                              '',
                        ),
                      ],
                    ),
                  ),

                  Card(
                    margin:
                        const EdgeInsets
                            .all(15),
                    child: Column(
                      children: [
                        tile(
                          Icons
                              .precision_manufacturing,
                          "Assigned Machines",
                          "${profile?['total_machines'] ?? 0}",
                        ),
                        tile(
                          Icons.analytics,
                          "Total Production",
                           "${profile?['total_production'] ?? 0}",
                        ),
                        tile(
                          Icons.check_circle,
                          "Ready Production",
                            "${profile?['total_ready_production'] ?? 0}",
                        ),
                        tile(
                          Icons.fact_check,
                          "Attendance",
                          "${profile?['attendance_count'] ?? 0}",
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