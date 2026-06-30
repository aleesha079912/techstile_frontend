import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:techstile_frontend/core/services/auth_service.dart';
import 'package:techstile_frontend/core/services/manager_service/manager_setting_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState
    extends State<EditProfileScreen> {

  final service = ManagerSettingService();

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final cnicController = TextEditingController();
  final addressController = TextEditingController();

  bool loading = false;

  @override
  void initState() {
    super.initState();

    final user = AuthService.user ?? {};

    nameController.text = user['name'] ?? '';
    phoneController.text = user['phone_no'] ?? '';
    cnicController.text = user['cnic'] ?? '';
    addressController.text = user['address'] ?? '';
  }

  Future<void> saveProfile() async {
    setState(() {
      loading = true;
    });

    final success =
        await service.updateProfile(
      name: nameController.text,
      phone: phoneController.text,
      cnic: cnicController.text,
      address: addressController.text,
    );

    setState(() {
      loading = false;
    });

    if (success) {
      Get.snackbar(
        "Success",
        "Profile Updated",
      );
    } else {
      Get.snackbar(
        "Error",
        "Update Failed",
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
            borderRadius:
                BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final user = AuthService.user as Map<String, dynamic>? ?? {};

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            field(
              label: "Email",
              controller: TextEditingController(
                text: user['email'] ?? '',
              ),
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
                onPressed:
                    loading ? null : saveProfile,
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
    );
  }
}