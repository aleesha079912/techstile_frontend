import 'dart:convert';
import 'package:http/http.dart' as http;
import '../auth_service.dart';

class EmployeeDashboardService {
  final String baseUrl = "http://techstile.sandbox.pk/api";

  Future<Map<String, dynamic>> getDashboard() async {
    final user = AuthService.box.read('user');
    final userId = user?['id'];

    final response = await http.get(
      Uri.parse("$baseUrl/employee/dashboard/$userId"),
      headers: AuthService.authHeaders,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed: ${response.body}");
    }
  }
}
