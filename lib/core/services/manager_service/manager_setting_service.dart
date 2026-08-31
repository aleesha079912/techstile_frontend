import 'dart:convert';
import 'package:http/http.dart' as http;
import '../auth_service.dart';

class ManagerSettingService {
  static const String baseUrl = "http://localhost:8000/api";

  Future<bool> updateProfile({
    required String name,
    required String phone,
    required String cnic,
    required String address,
  }) async {
    final response = await http.put(
      Uri.parse("$baseUrl/manager/profile/${AuthService.userId}"),
      headers: AuthService.authHeaders,
      body: jsonEncode({
        "name": name,
        "phone_no": phone,
        "cnic": cnic,
        "address": address,
      }),
    );

    return response.statusCode == 200;
  }

  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/change-password"),
        headers: AuthService.authHeaders,
        body: jsonEncode({
          "current_password": currentPassword,
          "new_password": newPassword,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Password changed successfully',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to change password',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
}
