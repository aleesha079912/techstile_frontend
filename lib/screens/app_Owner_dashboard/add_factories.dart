import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:techstile_frontend/core/services/factory_service.dart'; 

class AddFactoryScreen extends StatefulWidget {
  const AddFactoryScreen({super.key});

  @override
  State<AddFactoryScreen> createState() => _AddFactoryScreenState();
}

class _AddFactoryScreenState extends State<AddFactoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();

  static const _navy = Color(0xFF1E3A8A);
  static const _blue = Color(0xFF2563EB);
  static const _lightBlue = Color(0xFFEFF6FF);
  static const _bgPage = Color(0xFFF0F4FF);
  static const _slate = Color(0xFF64748B);

  @override
  void initState() {
    super.initState();
    // EDIT MODE: Agar edit karne aaye hain toh purana data load karein
    final existing = Get.arguments;
    if (existing != null) {
      _nameController.text = existing.name;
      _addressController.text = existing.address;
      _cityController.text = existing.city;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final controller = Get.find<FactoryController>();
    final existing = Get.arguments;

    final factoryData = {
      "name": _nameController.text.trim(),
      "address": _addressController.text.trim(),
      "city": _cityController.text.trim(),
    };

    bool success = false;
    try {
      if (existing != null) {
        // Edit mode: Laravel ka ID use karein
        success = await controller.updateFactory(existing.id, factoryData);
      } else {
        // Add mode
        success = await controller.addFactory(factoryData);
      }

      if (success) {
        Get.back();
        Get.snackbar(
          "Success", 
          existing != null ? "Factory updated!" : "Factory added!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar("Error", "Something went wrong: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final existing = Get.arguments;
    
    return Scaffold(
      backgroundColor: _bgPage,
      appBar: _buildAppBar(existing != null),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              _buildHeroCard(existing != null),
              const SizedBox(height: 20),
              _buildSectionLabel("Factory Details"),
              const SizedBox(height: 10),
              _buildField(
                controller: _nameController,
                label: "Factory Name",
                hint: "e.g. Al-Kareem Textiles Ltd.",
                icon: Icons.domain_rounded,
                validator: (v) => (v == null || v.trim().isEmpty) ? "Factory name is required" : null,
              ),
              const SizedBox(height: 10),
              _buildField(
                controller: _addressController,
                label: "Address",
                hint: "e.g. 45-B Industrial Zone",
                icon: Icons.location_on_rounded,
                validator: (v) => (v == null || v.trim().isEmpty) ? "Address is required" : null,
              ),
              const SizedBox(height: 10),
              _buildField(
                controller: _cityController,
                label: "City",
                hint: "e.g. Lahore",
                icon: Icons.public_rounded,
                validator: (v) => (v == null || v.trim().isEmpty) ? "City is required" : null,
              ),
              const SizedBox(height: 28),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isEdit) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(72),
      child: Container(
        decoration: const BoxDecoration(
          color: _navy,
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 16, 14),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 4),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEdit ? "Edit Factory" : "Add Factory",
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      isEdit ? "Update existing unit details" : "Register a new production unit",
                      style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard(bool isEdit) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: _navy.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [_navy, _blue]),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(isEdit ? Icons.edit_note_rounded : Icons.factory_rounded, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEdit ? "Update Factory Info" : "New Factory Registration",
                  style: const TextStyle(color: _navy, fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 3),
                Text(
                  isEdit ? "Modify details and save changes to server" : "Fill in the details to add a factory to your network",
                  style: const TextStyle(color: _slate, fontSize: 11.5, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) => Text(
    label.toUpperCase(),
    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _navy, letterSpacing: 0.9),
  );

  Widget _buildField({required TextEditingController controller, required String label, required String hint, required IconData icon, String? Function(String?)? validator}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: _navy.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: const TextStyle(color: _blue, fontSize: 12, fontWeight: FontWeight.w600),
          prefixIcon: Container(
            margin: const EdgeInsets.all(10),
            width: 34, height: 34,
            decoration: BoxDecoration(color: _lightBlue, borderRadius: BorderRadius.circular(9)),
            child: Icon(icon, color: _navy, size: 17),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: _blue, width: 1.5)),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    final controller = Get.find<FactoryController>();
    
    return Obx(() => Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [_navy, _blue]),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: _navy.withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: controller.isLoading.value ? null : _submit,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: controller.isLoading.value 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Column(
                    children: [
                      Text("Save Factory", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                      SizedBox(height: 2),
                      Text("All fields are required", style: TextStyle(color: Colors.white60, fontSize: 10.5)),
                    ],
                  ),
            ),
          ),
        ),
      ),
    ));
  }
}