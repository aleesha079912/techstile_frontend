import 'dart:convert';
import 'package:http/http.dart' as http;
import '../auth_service.dart';

class EmployeeProfileService {
  static const String baseUrl =
      "http://techstile.sandbox.pk/api";

  Future<Map<String, dynamic>?> getProfile(int userId) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/employee/profile/$userId"),
        headers: AuthService.authHeaders,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return null;
    } catch (e) {
      return null;
    }
  }
}
