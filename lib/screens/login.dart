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
  final GetStorage box = GetStorage(); // ✅ FIX 1: GetStorage uncomment kiya

  bool _isLoading = false;
  bool _obscureText = true; // ✅ FIX 2: Password show/hide ke liye

  // ✅ FIX 3: Controllers dispose kiye — memory leak band
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      Get.snackbar(
        "Error",
        "Email and Password required",
      );
      return;
    }

    // ✅ FIX 4: mounted check — widget dispose hone ke baad setState crash nahi karega
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final result = await AuthService.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      // ✅ FIX 4: mounted check yahan bhi
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      if (result['success'] == true) {
        final userData = result['data']['user'];
        final token = result['data']['token'];
        List roles = userData['roles'] ?? [];
        String roleName = "";

        if (roles.isNotEmpty) {
          roleName = roles[0]['name'].toString().toLowerCase().trim();
        }

        debugPrint("SUCCESS => Token: $token, Role: $roleName"); // ✅ FIX 5: print → debugPrint

        // ✅ FIX 1: Token, user, role storage mein save ho raha ab
        box.write('token', token);
        box.write('user', userData);
        box.write('role', roleName);
        box.write('isLoggedIn', true);

        // Role based navigation
        if (roleName == 'owner') {
          Get.offAllNamed(AppRoutes.ownerDashboard);
        } else if (roleName == 'manager'){
  // ✅ factoryId pass karo
  final managerId = userData['id'];
  
  Get.offAllNamed(
    AppRoutes.managerDashboard,
    arguments: managerId, // ya factoryId — backend kya expect karta hai
  );
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
      // ✅ FIX 4: mounted check catch block mein bhi
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      debugPrint("LOGIN ERROR: $e"); // ✅ FIX 5: print → debugPrint
      Get.snackbar("Error", "Server connection failed");
    }
  }

  InputDecoration inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: AppTheme.secondary),
      suffixIcon: suffixIcon, // ✅ FIX 2: suffix icon support add kiya
      filled: true,
      fillColor: AppTheme.background,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.background,
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
                  color: AppTheme.background,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                ),
                Text(
                  "Enter your credentials to manage active looms and production logs.",
                  style: TextStyle(color: AppTheme.primary),
                ),
                const SizedBox(height: 20),
                Text(
                  "Email",
                  style: TextStyle(fontSize: 12, color: AppTheme.primary),
                ),
                const SizedBox(height: 5),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress, // ✅ BONUS: Email keyboard
                  decoration: inputDecoration(
                    hint: "Enter your Email",
                    icon: Icons.email,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  "PIN / PASSWORD",
                  style: TextStyle(fontSize: 12, color: AppTheme.primary),
                ),
                const SizedBox(height: 5),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscureText, // ✅ FIX 2: dynamic value
                  decoration: inputDecoration(
                    hint: "Enter your Password",
                    icon: Icons.lock_outline,
                    // ✅ FIX 2: Show/hide toggle button
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                        color: AppTheme.primary,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: AppTheme.background,
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
                // ✅ FIX 6: "Forgot Password?" ab clickable hai
                Center(
                  child: GestureDetector(
                    onTap: () {
                      // TODO: Forgot password screen pe navigate karo
                      Get.snackbar(
                        "Forgot Password",
                        "Contact your supervisor to reset password.",
                      );
                    },
                    child: Text(
                      "Forgot Password?",
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // ✅ FIX 7: "Contact Supervisor" ab clickable hai
                GestureDetector(
                  onTap: () {
                    // TODO: Supervisor contact screen ya dialog add karo
                    Get.snackbar(
                      "Contact Supervisor",
                      "Please reach out to your floor supervisor.",
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.secondary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.support_agent, color: AppTheme.primary),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text("Contact Supervisor", style: TextStyle(color: AppTheme.background),
                        )),
                        Icon(Icons.arrow_forward_ios,
                            size: 14, color: AppTheme.primary),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    "© 2024 LOOMCONTROL INDUSTRIAL SYSTEMS\nVERSION 4.2.0-ALPHA",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      color: AppTheme.textPrimary,
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