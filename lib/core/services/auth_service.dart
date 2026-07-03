import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = "http://textstile.sandbox.pk/api";
  static final box = GetStorage();

  // ── Getters ────────────────────────────────────────────────────────────────

  static String get token => box.read('token') ?? '';
  static bool get isLoggedIn => token.isNotEmpty;
  static Map? get user => box.read('user');
  static String get role => box.read('role') ?? '';

  // ✅ Reload-safe factoryId/userId — GetStorage se persist hote hain
  static dynamic get factoryId => box.read('factoryId');
  static dynamic get userId => box.read('userId');

  /// Every authenticated API call mein yahi headers use karo
  static Map<String, String> get authHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
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

        // ✅ Yahin save karo — agar backend response mein factoryId aata hai
        // Agar 'factory_id' ya 'factoryId' key se aata hai to wahi use karo
        if (userData['factory_id'] != null) {
          box.write('factoryId', userData['factory_id']);
        }
        box.write('userId', userData['id']);

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

  // ✅ Manual save — agar factoryId login response mein nahi aata,
  // balki ek alag API call se milta hai (jaisa manager ke case mein hota hai)
 static Future<void> saveFactoryInfo(
  dynamic factoryId,
  dynamic userId,
) async {
  print("Saving Factory ID = $factoryId");

  await box.write('factoryId', factoryId);
  await box.write('userId', userId);

  print("Stored Factory ID = ${box.read('factoryId')}");
}

  // ── LOGOUT ─────────────────────────────────────────────────────────────────

  static void logout() {
    box.remove('token');
    box.remove('user');
    box.remove('role');
    box.remove('factoryId'); // ✅ logout pe clear karo
    box.remove('userId');
  }
}