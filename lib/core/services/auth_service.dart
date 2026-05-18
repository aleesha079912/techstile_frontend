import 'dart:convert';

import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class AuthService {

  static const String baseUrl = "http://localhost:8000/api";

  static final box = GetStorage();

  /// LOGIN
 static Future<Map<String, dynamic>> login(
  String email,
  String password,
) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    // 1. Response decode 
   final data = jsonDecode(response.body);
    print(data);

    if (response.statusCode == 200 && data['data'] != null) {
      final actualData = data['data']; // 'data' wrapper se nikalne ke liye
      final userData = actualData['user'];

      // Storage mein save karein
      box.write('user', userData); 
      box.write('token', actualData['token']);

      // Role nikal kar save karein
      if (userData['roles'] != null && userData['roles'].isNotEmpty) {
        String roleName = userData['roles'][0]['name'].toString();
        box.write('role', roleName);
      }

      return {'success': true, 'data': actualData};
    } else {
      return {'success': false, 'message': data['message'] ?? 'Login failed'};
    }
  } catch (e) {
    print("❌ Error: $e");
    return {
      'success': false,
      'message': e.toString(),
    };
  }
}

  /// LOGOUT
  static void logout() {

    box.remove('token');
    box.remove('user');
    box.remove('role');
  }
}