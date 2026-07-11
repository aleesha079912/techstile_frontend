import 'dart:convert';
import 'package:http/http.dart' as http;
import '../auth_service.dart';

class ManagerSettingService {

  static const String baseUrl =
      "http://techstile.sandbox.pk/api";

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

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/manager/change-password"),
      headers: AuthService.authHeaders,
      body: jsonEncode({
        "current_password": currentPassword,
        "new_password": newPassword,
      }),
    );

    return response.statusCode == 200;
  }
}
