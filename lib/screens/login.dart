import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';

import 'package:techstile_frontend/core/services/auth_service.dart';
import 'package:techstile_frontend/core/utils/theme.dart';
import 'package:techstile_frontend/routes/routes.dart'; 

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  final GetStorage box = GetStorage();

  Future<void> _login() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      Get.snackbar(
        "Error",
        "Email and Password required",
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await AuthService.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      setState(() {
        _isLoading = false;
      });

      if (result['success'] == true) {
        // 1. Extract data of user, token, and roles 
        final userData = result['data']['user'];
        final token = result['data']['token'];
        // 2. Extract roles from user array
        List roles = userData['roles'] ?? [];
        // variable to store the role name (assuming one role per user for simplicity)
        String roleName = "";

        if (roles.isNotEmpty) {
          // get roles name and convert to lowercase for easier comparison
          roleName = roles[0]['name'].toString().toLowerCase().trim();
        }

        print("SUCCESS => Token: $token, Role: $roleName");

        // 3. SAVE DATA TO STORAGE
        box.write('token', token);
        box.write('user', userData);
        box.write('role', roleName);
        box.write('isLoggedIn', true);

        // 4. ROLE BASED NAVIGATION
        if (roleName == 'owner') {
          Get.offAllNamed(AppRoutes.ownerDashboard); 
        } else if (roleName == 'manager') {
          Get.offAllNamed(AppRoutes.managerDashboard);
        } else if (roleName == 'employee') {
          Get.offAllNamed(AppRoutes.employeeDashboard);
        } else {
          Get.snackbar(
            "Invalid Role",
            "This Account is not linked with any role.",
          );
        }
      } else {
        Get.snackbar(
          "Login Failed",
          result['message'] ?? "Check your credentials",
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print("LOGIN ERROR: $e");// print error to console for debugging
      Get.snackbar("Error", "Server connection failed");
    }
  }

  InputDecoration inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: AppTheme.neutral),
      filled: true,
      fillColor: AppTheme.secondary,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.secondary,
      body: Center(
        child: SingleChildScrollView( // Added for keyboard overflow protection
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.bar_chart, color: AppTheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      "LOOMCONTROL",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  "Access",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                  ),
                ),
                Container(
                  width: 40,
                  height: 3,
                  color: AppTheme.tertiary,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                ),
                Text(
                  "Enter your credentials to manage active looms and production logs.",
                  style: TextStyle(color: AppTheme.neutral),
                ),
                const SizedBox(height: 20),
                Text(
                  "Email",
                  style: TextStyle(fontSize: 12, color: AppTheme.neutral),
                ),
                const SizedBox(height: 5),
                TextField(
                  controller: _emailController,
                  decoration: inputDecoration(
                    hint: "Enter your Email",
                    icon: Icons.email,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  "PIN / PASSWORD",
                  style: TextStyle(fontSize: 12, color: AppTheme.neutral),
                ),
                const SizedBox(height: 5),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: inputDecoration(
                    hint: "Enter your Password",
                    icon: Icons.lock_outline,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,// make button full width
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,// disable button when true, otherwise call _login function
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Text(
                            "Begin Shift  →",
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    "Forgot Password?",
                    style: TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.secondary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.support_agent, color: AppTheme.tertiary),
                      const SizedBox(width: 10),
                      const Expanded(child: Text("Contact Supervisor")),
                      Icon(Icons.arrow_forward_ios,
                          size: 14, color: AppTheme.neutral),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    "© 2024 LOOMCONTROL INDUSTRIAL SYSTEMS\nVERSION 4.2.0-ALPHA",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      color: AppTheme.neutral,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}