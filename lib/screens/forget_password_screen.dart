import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:techstile_frontend/core/services/auth_service.dart';
import 'package:techstile_frontend/core/utils/theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      Get.snackbar("Error", "Please enter your email");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await AuthService.forgotPassword(email);

      setState(() => _isLoading = false);

      if (result['success'] == true) {
        Get.snackbar(
          "Success",
          result['message'] ?? "Password reset link sent to your email",
        );
        Get.back(); // wapas login screen py
      } else {
        Get.snackbar(
          "Failed",
          result['message'] ?? "Could not process request",
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint("FORGOT PASSWORD ERROR: $e");
      Get.snackbar("Error", "Server connection failed");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.primary),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Forgot Password",
              style: TextStyle(
                color: AppTheme.primary,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Enter your registered email. We'll send you a link to reset your password.",
            ),
            const SizedBox(height: 25),

            const Text("Email"),
            const SizedBox(height: 5),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: "Enter Email",
                prefixIcon: const Icon(
                  Icons.email_outlined,
                  color: AppTheme.primary,
                ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const CircularProgressIndicator(color: AppTheme.secondary)
                    : const Text("Submit"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}