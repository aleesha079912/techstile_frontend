import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';

import 'package:techstile_frontend/core/services/auth_service.dart';
import 'package:techstile_frontend/core/utils/theme.dart';

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
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      Get.snackbar("Error", "Email and Password are required");
      return;
    }

    setState(() => _isLoading = true);

    final result = await AuthService.login(
      _emailController.text,
      _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (result['success']) {
      final userName = result['data']['user']['name'];

      box.write('isLoggedIn', true);
      box.write('userName', userName);
      box.write('token', result['data']['token']);

      Get.offAllNamed('/dashboard');
    } else {
      Get.snackbar("Error", result['message']);
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

              /// LOGO
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

              /// TITLE
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

              /// EMAIL
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

              /// PASSWORD
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

              /// LOGIN BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
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
                      ? const CircularProgressIndicator(color: Colors.white)
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
                  style: TextStyle(color: AppTheme.neutral),
                ),
              ),

              const SizedBox(height: 20),

              /// CONTACT SUPPORT
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
                    const Expanded(
                      child: Text("Contact Supervisor"),
                    ),
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
    );
  }
}