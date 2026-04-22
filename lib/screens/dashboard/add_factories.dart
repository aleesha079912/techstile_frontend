import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:techstile_frontend/screens/dashboard/my_factories.dart';

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
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Get.find<FactoryController>().addFactory({
      "name": _nameController.text.trim(),
      "address": _addressController.text.trim(),
      "city": _cityController.text.trim(),
    });
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgPage,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              _buildHeroCard(),
              const SizedBox(height: 20),
              _buildSectionLabel("Factory Details"),
              const SizedBox(height: 10),
              _buildField(
                controller: _nameController,
                label: "Factory Name",
                hint: "e.g. Al-Kareem Textiles Ltd.",
                icon: Icons.domain_rounded,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? "Factory name is required" : null,
              ),
              const SizedBox(height: 10),
              _buildField(
                controller: _addressController,
                label: "Address",
                hint: "e.g. 45-B Industrial Zone",
                icon: Icons.location_on_rounded,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? "Address is required" : null,
              ),
              const SizedBox(height: 10),
              _buildField(
                controller: _cityController,
                label: "City",
                hint: "e.g. Lahore",
                icon: Icons.public_rounded,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? "City is required" : null,
              ),
              const SizedBox(height: 28),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
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
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 18),
                ),
                const SizedBox(width: 4),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Add Factory",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                    Text(
                      "Register a new production unit",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 11,
                      ),
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

  Widget _buildHeroCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _navy.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_navy, _blue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.factory_rounded, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "New Factory Registration",
                  style: TextStyle(
                    color: _navy,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  "Fill in the details to add a factory to your network",
                  style: TextStyle(color: _slate, fontSize: 11.5, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: _navy,
        letterSpacing: 0.9,
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _navy.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF1E293B),
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: const TextStyle(
            color: _blue,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 13,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(10),
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: _lightBlue,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: _navy, size: 17),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: _blue, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_navy, _blue],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: _navy.withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: _submit,
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                Text(
                  "Save Factory",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  "All fields are required",
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 10.5,
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