import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:techstile_frontend/core/services/auth_service.dart';
import 'package:techstile_frontend/core/services/manager_service/manager_setting_service.dart';
import 'package:techstile_frontend/core/utils/theme.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final service = ManagerSettingService();

  final emailController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final cnicController = TextEditingController();
  final addressController = TextEditingController();

  bool loading = false;

  @override
  void initState() {
    super.initState();

    final user = AuthService.user ?? {};

    emailController.text = user['email'] ?? '';
    nameController.text = user['name'] ?? '';
    phoneController.text = user['phone_no'] ?? '';
    cnicController.text = user['cnic'] ?? '';
    addressController.text = user['address'] ?? '';
  }

  @override
  void dispose() {
    emailController.dispose();
    nameController.dispose();
    phoneController.dispose();
    cnicController.dispose();
    addressController.dispose();
    super.dispose();
  }

  Future<void> saveProfile() async {
  setState(() {
    loading = true;
  });

  final success = await service.updateProfile(
    name: nameController.text,
    phone: phoneController.text,
    cnic: cnicController.text,
    address: addressController.text,
  );

  if (!mounted) return;

  setState(() {
    loading = false;
  });

  if (success) {
    Get.snackbar(
      "Success",
      "Profile Updated",
     snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.blue, 
        colorText: Colors.white,
    );
    
    // Page se wapas jane ke liye Flutter ka native navigator use karein
    Navigator.of(context).pop();
  } else {
    Get.snackbar(
      "Error",
      "Update Failed",
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red,
      colorText: Colors.white
    );
  }
}

  Widget field({
    required String label,
    required TextEditingController controller,
    bool readOnly = false,
    int lines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        maxLines: lines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppTheme.secondary,
          ),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Edit Profile",
          style: TextStyle(color: AppTheme.secondary),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              field(
                label: "Email",
                controller: emailController,
                readOnly: true,
              ),
              field(
                label: "Name",
                controller: nameController,
              ),
              field(
                label: "Phone",
                controller: phoneController,
              ),
              field(
                label: "CNIC",
                controller: cnicController,
              ),
              field(
                label: "Address",
                controller: addressController,
                lines: 3,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: loading ? null : saveProfile,
                  child: loading
                      ? const CircularProgressIndicator()
                      : const Text(
                          "Update Profile",
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