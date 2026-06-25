import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:techstile_frontend/core/services/auth_service.dart';

class EmployeeProfileService {
  final String baseUrl =
      "http://localhost:8000/api";

  Future<Map<String, dynamic>?> getProfile(
      int userId) async {
    try {
      final response = await http.get(
        Uri.parse(
          "$baseUrl/employee/profile/$userId",
        ),
        headers: AuthService.authHeaders,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print(e);
    }

    return null;
  }
}