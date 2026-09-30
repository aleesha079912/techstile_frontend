import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/services/manage_users_service.dart';
import '../../../../core/utils/theme.dart';
import 'package:techstile_frontend/core/utils/password_rules.dart';

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

  List<String> roles = [];
  String? selectedRole;

  // Controllers
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final cnicCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final roleCtrl = TextEditingController();

  // Sirf ye roles register/edit ho sakte hain
  static const _allowedRoles = ['manager', 'employee'];

  // Server side (uniqueness) errors
  String? _emailError;
  String? _phoneError;
  String? _cnicError;

  @override
  void initState() {
    super.initState();
    // Agar Edit mode hai to purana data fill karo
    if (widget.user != null) {
      nameCtrl.text = widget.user!.name;
      emailCtrl.text = widget.user!.email;
      phoneCtrl.text = _formatDigits(widget.user!.phone, const [4, 7]);
      cnicCtrl.text = _formatDigits(widget.user!.cnic, const [5, 7, 1]);
      addressCtrl.text = widget.user!.address;
      roleCtrl.text = widget.user!.role;
    }
    _loadRoles();
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    phoneCtrl.dispose();
    cnicCtrl.dispose();
    addressCtrl.dispose();
    roleCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadRoles() async {
    final result = await _service.fetchRoles();
    if (!mounted) return;

    // Sirf manager aur employee allowed hain
    final filtered = result
        .where((r) => _allowedRoles.contains(r.toLowerCase()))
        .toList();

    setState(() {
      roles = filtered;

      if (widget.user != null) {
        // Agar user ka role allowed list mein nahi (e.g. owner) to dropdown khali rahe
        final match = filtered.where(
          (r) => r.toLowerCase() == widget.user!.role.toLowerCase(),
        );
        selectedRole = match.isNotEmpty ? match.first : null;
      }
    });
  }

  // ---------------------------------------------------------------
  // Normalizers (backend bhi same format mein save karta hai)
  // ---------------------------------------------------------------
  String get _cleanEmail => emailCtrl.text.trim().toLowerCase();

  // Phone: 03XX-XXXXXXX
  String get _cleanPhone => phoneCtrl.text.trim();

  // CNIC: XXXXX-XXXXXXX-X
  String get _cleanCnic => cnicCtrl.text.trim();

  /// Digits ko groups mein baant kar dashes lagata hai (e.g. [5,7,1])
  static String _formatDigits(String input, List<int> groups) {
    final digits = input.replaceAll(RegExp(r'\D'), '');
    final buf = StringBuffer();
    var pos = 0;
    for (final g in groups) {
      if (pos >= digits.length) break;
      if (pos > 0) buf.write('-');
      final end = (pos + g) > digits.length ? digits.length : pos + g;
      buf.write(digits.substring(pos, end));
      pos = end;
    }
    return buf.toString();
  }

  /// 0000000, 1111111, 1234567, 7654321 jaise fake patterns
  static bool _isFakeDigits(String s) {
    if (s.length < 4) return false;
    if (RegExp(r'^(\d)\1+$').hasMatch(s)) return true; // sab same
    return '012345678901234567890'.contains(s) ||
        '987654321098765432109'.contains(s); // sequential
  }

  // ---------------------------------------------------------------
  // Validators
  // ---------------------------------------------------------------
  String? _validateName(String? v) {
    if (v == null || v.trim().isEmpty) return "Required";
    if (v.trim().length < 3) return "Name should be at least 3 characters";
    return null;
  }

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return "Required";
    if (!RegExp(r'^[\w\.\-+]+@[\w\-]+(\.[\w\-]+)+$').hasMatch(v.trim())) {
      return "correct format: user@example.com";
    }
    return _emailError;
  }

  String? _validatePhone(String? v) {
    if (v == null || v.trim().isEmpty) return "Required";
    final p = v.trim();
    if (!p.startsWith('03')) return "Start with 03";
    // 0300-0349 aur 0355 valid network codes
    if (!RegExp(r'^(03[0-4]\d|0355)-\d{7}$').hasMatch(p)) {
      return "correct format: 03XX-XXXXXXX (valid network code)";
    }
    final digits = p.replaceAll('-', '');
    if (_isFakeDigits(digits.substring(4))) {
      return "This phone number is already registered";
    }
    return _phoneError;
  }

  String? _validateCnic(String? v) {
    if (v == null || v.trim().isEmpty) return "Required";
    final c = v.trim();
    if (!RegExp(r'^[1-7]\d{4}-\d{7}-\d$').hasMatch(c)) {
      return "CNIC format: 34101-";
    }
    final digits = c.replaceAll('-', '');
    if (_isFakeDigits(digits) || _isFakeDigits(digits.substring(5, 12))) {
      return "This CNIC is already registered";
    }
    return _cnicError;
  }

  // ---------------------------------------------------------------
  // Save
  // ---------------------------------------------------------------
  Future<void> _handleSave() async {
    // Purane server errors saaf karo, phir format validation
    _emailError = null;
    _phoneError = null;
    _cnicError = null;

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // 1. Uniqueness check (email, phone, cnic)
    final res = await _service.checkUnique(
      email: _cleanEmail,
      phone: _cleanPhone,
      cnic: _cleanCnic,
      excludeUserId: widget.user?.id, // edit mode mein apna record ignore
    );

    if (!mounted) return;

    if (res['emailTaken'] == true ||
        res['phoneTaken'] == true ||
        res['cnicTaken'] == true) {
      setState(() {
        _isLoading = false;
        if (res['emailTaken'] == true) {
          _emailError = "This email is already registered";
        }
        if (res['phoneTaken'] == true) {
          _phoneError = "This phone number is already registered";
        }
        if (res['cnicTaken'] == true) {
          _cnicError = "This CNIC is already registered";
        }
      });

      // Form dobara build hone ke baad errors fields ke neeche dikhao
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _formKey.currentState?.validate();
      });
      return;
    }

    // 2. Save
    bool success;
    if (widget.user == null) {
      // Create Logic
      success = await _service.addUser(
        UserData(
          name: nameCtrl.text.trim(),
          email: _cleanEmail,
          phone: _cleanPhone,
          cnic: _cleanCnic,
          address: addressCtrl.text.trim(),
          role: selectedRole ?? '',
        ),
        passwordCtrl.text,
      );
    } else {
      // Update Logic
      Map<String, dynamic> data = {
        "name": nameCtrl.text.trim(),
        "email": _cleanEmail,
        "phone_no": _cleanPhone,
        "cnic": _cleanCnic,
        "address": addressCtrl.text.trim(),
        "role": selectedRole,
      };
      if (passwordCtrl.text.isNotEmpty) data['password'] = passwordCtrl.text;

      success = await _service.updateUser(widget.user!.id!, data);
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Action Successful!"),
        backgroundColor: Colors.green,
      ));
      Navigator.pop(context, true); // true return karta hai taake list refresh ho
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Error! Check network or unique constraints."),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.user == null ? "Register New User" : "Edit User",
          style: TextStyle(color: AppTheme.secondary),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  children: [
                    _buildField(
                      nameCtrl,
                      "Full Name",
                      Icons.person,
                      validator: _validateName,
                    ),
                    _buildField(
                      emailCtrl,
                      "Email Address",
                      Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                      onChanged: (_) => _emailError = null,
                    ),
                    _buildField(
                      passwordCtrl,
                      "Password",
                      Icons.lock,
                      obscure: true,
                      isRequired: widget.user == null,
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return widget.user == null ? "Required" : null;
                        }
                        return PasswordRules.validate(v);
                      },
                    ),
                    _buildField(
                      phoneCtrl,
                      "Phone Number (0300-1234567)",
                      Icons.phone,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        _DashFormatter(const [4, 7], allow: _phoneAllowed),
                      ],
                      validator: _validatePhone,
                      onChanged: (_) => _phoneError = null,
                    ),
                    _buildField(
                      cnicCtrl,
                      "CNIC (34101-1234567-1)",
                      Icons.credit_card,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        _DashFormatter(const [5, 7, 1], allow: _cnicAllowed),
                      ],
                      validator: _validateCnic,
                      onChanged: (_) => _cnicError = null,
                    ),
                    _buildField(
                      addressCtrl,
                      "Home Address",
                      Icons.home,
                      maxLines: 2,
                    ),
                    DropdownButtonFormField<String>(
                      value: selectedRole,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.work, color: AppTheme.primary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        hintText: "Select Role",
                      ),
                      items: roles.map((role) {
                        return DropdownMenuItem<String>(
                          value: role,
                          child: Text(role),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedRole = value;
                        });
                      },
                      validator: (value) => value == null ? "Select Role" : null,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          padding: const EdgeInsets.all(15),
                        ),
                        onPressed: _handleSave,
                        child: Text(
                          widget.user == null ? "REGISTER" : "UPDATE",
                          style: const TextStyle(color: AppTheme.secondary),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildField(
    TextEditingController ctrl,
    String hint,
    IconData icon, {
    bool obscure = false,
    int maxLines = 1,
    bool isRequired = true,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    ValueChanged<String>? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        obscureText: obscure,
        maxLines: maxLines,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        onChanged: onChanged,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppTheme.primary),
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        validator: validator ??
            (value) => (isRequired && (value == null || value.trim().isEmpty))
                ? "Required"
                : null,
      ),
    );
  }
}


/// Digits ko live dashes ke sath format karta hai.
/// groups [5,7,1] => 34101-1234567-1 | groups [4,7] => 0300-1234567
class _DashFormatter extends TextInputFormatter {
  final List<int> groups;

  final bool Function(String digits)? allow;

  _DashFormatter(this.groups, {this.allow});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final maxLen = groups.fold<int>(0, (a, b) => a + b);
    var digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length > maxLen) digits = digits.substring(0, maxLen);

    if (allow != null && !allow!(digits)) return oldValue;

    final buf = StringBuffer();
    var pos = 0;
    for (final g in groups) {
      if (pos >= digits.length) break;
      if (pos > 0) buf.write('-');
      final end = (pos + g) > digits.length ? digits.length : pos + g;
      buf.write(digits.substring(pos, end));
      pos = end;
    }
    final text = buf.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}


/// Phone: 03 se shuru, network code 0300-0349 ya 0355, aur number 000 se shuru nahi
bool _phoneAllowed(String d) {
  if (d.isNotEmpty && d[0] != '0') return false;
  if (d.length >= 2 && d[1] != '3') return false;
  if (d.length >= 3 && !'01234'.contains(d[2]) && d[2] != '5') return false;
  if (d.length >= 4 && d[2] == '5' && d[3] != '5') return false;
  if (d.length >= 7 && d.substring(4, 7) == '000') return false;
  return true;
}

/// CNIC: pehla digit 1-7 (province code), family number 0000 se shuru nahi
bool _cnicAllowed(String d) {
  if (d.isNotEmpty && !'1234567'.contains(d[0])) return false;
  if (d.length >= 9 && d.substring(5, 9) == '0000') return false;
  return true;
}