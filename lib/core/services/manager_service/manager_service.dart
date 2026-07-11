import '../auth_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:techstile_frontend/core/services/machines_service.dart';

class ManagerDashboardService {
  final String baseUrl = "http://techstile.sandbox.pk/api/manager";

  Future<Map<String, dynamic>> getDashboard(dynamic factoryId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/dashboard/$factoryId"),
      headers: AuthService.authHeaders,
    );

    return jsonDecode(response.body);
  }

  Future<List<Machine>> getMachines(dynamic factoryId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/machines/$factoryId"),
      headers: AuthService.authHeaders,
    );
    if (response.statusCode == 200) {
      final List rawList = jsonDecode(response.body)['machines'] ?? [];
      return rawList.map((json) => Machine.fromJson(json)).toList();
    }
    throw Exception("Could not load machines");
  }

  Future<List<dynamic>> getEmployees(dynamic factoryId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/employees/$factoryId"),
      headers: AuthService.authHeaders,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['employees'] ?? [];
    }
    throw Exception("Could not load employees");
  }

  Future<List<dynamic>> getPayments(dynamic factoryId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/payments/$factoryId"),
      headers: AuthService.authHeaders,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['productions'] ?? [];
    }
    throw Exception("Could not load payments");
  }
}
