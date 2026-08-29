import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/services/manager_service/manager_setting_service.dart';
import '../core/utils/theme.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = ManagerSettingService();

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();

    setState(() => _isLoading = true);

    try {
      final res = await _service.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      setState(() => _isLoading = false);

      if (res['success'] == true) {
        Get.snackbar(
          "Success",
          res['message'] ?? "Password updated successfully!",
          backgroundColor: AppTheme.success,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          duration: const Duration(seconds: 2),
        );

        // Clear fields and go back to settings
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();

        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) Navigator.pop(context);
        });
      } else {
        Get.snackbar(
          "Error",
          res['message'] ?? "Failed to change password",
          backgroundColor: AppTheme.error,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      Get.snackbar(
        "Error",
        "An unexpected error occurred: $e",
        backgroundColor: AppTheme.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.secondary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Change Password",
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.primary.withOpacity(0.15)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.lock_reset_rounded,
                        color: AppTheme.secondary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Security Update",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            "Enter your current password and choose a new password with at least 6 characters.",
                            style: TextStyle(
                              fontSize: 11.5,
                              color: AppTheme.textPrimary,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Current Password
              _buildPasswordField(
                label: "Current Password",
                hint: "Enter your current password",
                controller: _currentPasswordController,
                obscureText: _obscureCurrent,
                onToggleObscure: () {
                  setState(() => _obscureCurrent = !_obscureCurrent);
                },
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return "Current password is required";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // New Password
              _buildPasswordField(
                label: "New Password",
                hint: "Enter at least 6 characters",
                controller: _newPasswordController,
                obscureText: _obscureNew,
                onToggleObscure: () {
                  setState(() => _obscureNew = !_obscureNew);
                },
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return "New password is required";
                  }
                  if (val.trim().length < 6) {
                    return "Password must be at least 6 characters";
                  }
                  if (val.trim() == _currentPasswordController.text.trim()) {
                    return "New password must be different from current password";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Confirm New Password
              _buildPasswordField(
                label: "Confirm New Password",
                hint: "Re-enter new password",
                controller: _confirmPasswordController,
                obscureText: _obscureConfirm,
                onToggleObscure: () {
                  setState(() => _obscureConfirm = !_obscureConfirm);
                },
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return "Please confirm your new password";
                  }
                  if (val.trim() != _newPasswordController.text.trim()) {
                    return "Passwords do not match";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    disabledBackgroundColor: AppTheme.primary.withOpacity(0.6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: AppTheme.secondary,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          "Update Password",
                          style: TextStyle(
                            color: AppTheme.secondary,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggleObscure,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          validator: validator,
          style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 13,
              color: AppTheme.textPrimary.withOpacity(0.4),
            ),
            filled: true,
            fillColor: AppTheme.secondary,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            prefixIcon: const Icon(
              Icons.lock_outline,
              size: 20,
              color: AppTheme.primary,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                size: 20,
                color: AppTheme.primary.withOpacity(0.6),
              ),
              onPressed: onToggleObscure,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.primary.withOpacity(0.15)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.primary.withOpacity(0.15)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primary, width: 1.8),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.error, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
