import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = "http://localhost:8000/api";
  static final box = GetStorage();

  // ── Getters ────────────────────────────────────────────────────────────────

  static String get token => box.read('token') ?? '';
  static bool get isLoggedIn => token.isNotEmpty;
  static Map? get user => box.read('user');
  static String get role => box.read('role') ?? '';

  /// Every authenticated API call mein yahi headers use karo
  static Map<String, String> get authHeaders => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',  // ✅ yahi missing tha
      };

  // ── LOGIN ──────────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final actualData = data['data'];
        final userData = actualData['user'];

        box.write('token', actualData['token']);
        box.write('user', userData);
        box.write('role', userData['role'] ?? '');

        return {'success': true, 'data': actualData};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Login failed'
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // ── LOGOUT ─────────────────────────────────────────────────────────────────

  static void logout() {
    box.remove('token');
    box.remove('user');
    box.remove('role');
  }
}