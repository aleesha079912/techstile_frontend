class PasswordRules {
  static String? validate(String? v) {
    final p = v ?? '';
    if (p.isEmpty) return 'Password is required';
    if (p.length < 8) return 'At least 8 characters';
    if (!RegExp(r'[a-z]').hasMatch(p)) return 'Add a lowercase letter';
    if (!RegExp(r'[A-Z]').hasMatch(p)) return 'Add an uppercase letter';
    if (!RegExp(r'\d').hasMatch(p)) return 'Add a number';
    if (!RegExp(r'[^A-Za-z0-9]').hasMatch(p)) return 'Add a symbol (e.g. @ # !)';
    return null;
  }
}