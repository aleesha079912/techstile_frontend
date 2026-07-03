import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:techstile_frontend/core/services/auth_service.dart';
import 'package:techstile_frontend/core/utils/theme.dart';
import 'package:techstile_frontend/routes/routes.dart';
import 'package:techstile_frontend/core/services/manager_service/manager_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final GetStorage box = GetStorage();

  bool _isLoading = false;
  bool _obscureText = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      Get.snackbar("Error", "Email and Password required");
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    if (mounted) setState(() => _isLoading = true);

    try {
      final result = await AuthService.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      if (mounted) setState(() => _isLoading = false);

      if (result['success'] == true) {
        final userData = result['data']['user'];
        final token = result['data']['token'];

        List roles = userData['roles'] ?? [];
        String roleName = roles.isNotEmpty
            ? roles[0]['name'].toString().toLowerCase().trim()
            : "";

        if (roles.isNotEmpty) {
          roleName = roles[0]['name'].toString().toLowerCase().trim();
        }

        debugPrint("SUCCESS => Token: $token, Role: $roleName");

        box.write('token', token);
        box.write('user', userData);
        box.write('role', roleName);
        box.write('isLoggedIn', true);

        // ✅ Role based navigation — fixed syntax
     if (roleName == 'owner') {

  Get.offAllNamed(
    AppRoutes.ownerDashboard,
  );

} else if (roleName == 'manager') {

  final managerId = userData['id'];

  try {

    final factoryId = userData['factory_id'];

    await AuthService.saveFactoryInfo(
      factoryId,
      managerId,
    );

    Get.offAllNamed(
      AppRoutes.managerDashboard,
      arguments: {
        'factoryId': factoryId,
      },
    );

  } catch (e) {

    Get.snackbar(
      "Error",
      "Could not load manager dashboard",
    );

  }

} else if (roleName == 'employee') {
    final empUserId = userData['id'];

    try {
      final factoryId = userData['factory_id'];

      await AuthService.saveFactoryInfo(factoryId, empUserId);

      Get.offAllNamed(AppRoutes.employeeDashboard);
    } catch (e) {
      Get.snackbar("Error", "Could not load employee dashboard");
    }

  } else {

  Get.snackbar(
    "Invalid Role",
    "This Account is not linked with any role.",
  );

}
        if (roleName == 'owner') {
          Get.offAllNamed(AppRoutes.ownerDashboard);
        } else if (roleName == 'manager') {
          Get.offAllNamed(AppRoutes.managerDashboard,
              arguments: userData['id']);
        } else if (roleName == 'employee') {
          Get.offAllNamed(AppRoutes.employeeDashboard);
        } else {
          Get.snackbar("Invalid Role", "This Account is not linked with any role.");
        }
      } else {
        Get.snackbar("Login Failed", result['message'] ?? "Check credentials");
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      debugPrint("LOGIN ERROR: $e");
      if (mounted) setState(() => _isLoading = false);
      Get.snackbar("Error", "Server connection failed");
    }
  }

  Future<void> openWhatsApp() async {
    const phone = "923216427668"; // 🔴 apna number
    final Uri url = Uri.parse("https://wa.me/$phone");

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      Get.snackbar("Error", "WhatsApp open nahi ho saka");
    }
  }

  InputDecoration inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon, required Icon prefixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: AppTheme.secondary),
      suffixIcon: suffixIcon,
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ================= HEADER =================
                Row(
                  children: [
                    Icon(Icons.bar_chart, color: AppTheme.primary),
                    const SizedBox(width: 8),
                    const Text(
                      "TECHstile",
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.bold),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                const Text(
                  "Access",
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontSize: 28, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                const Text(
                  "Enter your credentials to manage active looms and production logs.",
                ),

                const SizedBox(height: 25),

                // ================= EMAIL =================
                const Text("Email"),
                const SizedBox(height: 5),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: "Enter Email",
                    prefixIcon: const Icon(
                      Icons.email_outlined,
                      color: AppTheme.primary,
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // ================= PASSWORD =================
                const Text("Password"),
                const SizedBox(height: 5),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscureText,
                  decoration: InputDecoration(
                    hintText: "Enter Password",
                    prefixIcon: Icon(Icons.password, color: AppTheme.primary,),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() => _obscureText = !_obscureText);
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ================= LOGIN BUTTON =================
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: AppTheme.secondary)
                        : const Text("Begin Shift →"),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: GestureDetector(
                    onTap: () {
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
                const SizedBox(height: 30),

                // ================= CONTACT SUPERVISOR =================
                GestureDetector(
                  onTap: openWhatsApp,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.support_agent,
                            color:  AppTheme.secondary),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            "System Help Contact Supervisor",
                            style: TextStyle(
                                color: AppTheme.secondary),
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios,
                            size: 14, color:  AppTheme.secondary),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ================= FOOTER =================
                const Center(
                  child: Text(
                    "© 2024 LOOMCONTROL\nVERSION 4.2.0-ALPHA",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 10),
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