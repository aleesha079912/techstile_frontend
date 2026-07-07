import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class FactoryDashboardService {
  final String baseUrl = "http://techstile.sandbox.pk/api/factories";

  Future<Map<String, dynamic>> getDashboard(String factoryId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/dashboard/$factoryId"),
      headers: AuthService.authHeaders,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception("Could not load factory dashboard");
  }
}