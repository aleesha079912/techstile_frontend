import 'package:flutter/material.dart';
import '../../../../core/services/manage_users_service.dart';
import '../../../../core/utils/theme.dart';

class RegisterUserRoleBased extends StatefulWidget {
  final UserData? user; // Null matlab Add, Not Null matlab Edit
  const RegisterUserRoleBased({super.key, this.user});

  @override
  State<RegisterUserRoleBased> createState() => _RegisterUserRoleBasedState();
}

class _RegisterUserRoleBasedState extends State<RegisterUserRoleBased> {
  final _service = ManageUsersService.instance;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controllers
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final cnicCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final roleCtrl = TextEditingController();
  final detailsCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Agar Edit mode hai to purana data fill karo
    if (widget.user != null) {
      nameCtrl.text = widget.user!.name;
      emailCtrl.text = widget.user!.email;
      phoneCtrl.text = widget.user!.phone;
      cnicCtrl.text = widget.user!.cnic;
      addressCtrl.text = widget.user!.address;
      roleCtrl.text = widget.user!.role;
      detailsCtrl.text = widget.user!.details;
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    bool success;
    if (widget.user == null) {
      // Create Logic
      success = await _service.addUser(
        UserData(
          name: nameCtrl.text,
          email: emailCtrl.text,
          phone: phoneCtrl.text,
          cnic: cnicCtrl.text,
          address: addressCtrl.text,
          role: roleCtrl.text,
          details: detailsCtrl.text,
        ),
        passwordCtrl.text,
      );
    } else {
      // Update Logic
      Map<String, dynamic> data = {
        "name": nameCtrl.text,
        "email": emailCtrl.text,
        "phone_no": phoneCtrl.text,
        "cnic": cnicCtrl.text,
        "address": addressCtrl.text,
        "role": roleCtrl.text,
        "employee_details": detailsCtrl.text,
      };
      if (passwordCtrl.text.isNotEmpty) data['password'] = passwordCtrl.text;
      
      success = await _service.updateUser(widget.user!.id!, data);
    }

    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Action Successful!"), backgroundColor: Colors.green));
      Navigator.pop(context, true); // true return karta hai taake list refresh ho
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error! Check network or unique constraints."), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.user == null ? "Register New User" : "Edit User")),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildField(nameCtrl, "Full Name", Icons.person),
                  _buildField(emailCtrl, "Email Address", Icons.email),
                  _buildField(passwordCtrl, "Password", Icons.lock, obscure: true, isRequired: widget.user == null),
                  _buildField(phoneCtrl, "Phone Number", Icons.phone),
                  _buildField(cnicCtrl, "CNIC Number", Icons.credit_card),
                  _buildField(addressCtrl, "Home Address", Icons.home),
                  _buildField(roleCtrl, "Role", Icons.work),
                  _buildField(detailsCtrl, "Notes", Icons.description, maxLines: 3),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, padding: const EdgeInsets.all(15)),
                      onPressed: _handleSave,
                      child: Text(widget.user == null ? "REGISTER" : "UPDATE", style: const TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String hint, IconData icon, {bool obscure = false, int maxLines = 1, bool isRequired = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        obscureText: obscure,
        maxLines: maxLines,
        decoration: InputDecoration(prefixIcon: Icon(icon, color: AppTheme.primary), hintText: hint, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
        validator: (value) => (isRequired && value!.isEmpty) ? "Required" : null,
      ),
    );
  }
}