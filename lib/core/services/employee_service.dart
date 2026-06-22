import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
class EmployeeService {
  // ⚠️ Flutter Web → localhost
  // ⚠️ Emulator → 10.0.2.2
  final String baseUrl = "http://localhost:8000/api/employees";

  // 🔹 GET ALL
  Future<List<dynamic>> fetchEmployees() async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/all_employee"),
      headers: AuthService.authHeaders,
      );
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (e) {
      print("Fetch Error: $e");
    }
    return [];
  }

  // 🔹 ADD
  Future<bool> addEmployee(Map<String, dynamic> data) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/add_employee"),
        headers: AuthService.authHeaders,
        body: jsonEncode(data),
      );
      return res.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  // 🔹 UPDATE
  Future<bool> updateEmployee(int id, Map<String, dynamic> data) async {
    try {
      final res = await http.put(
        Uri.parse("$baseUrl/update_employee/$id"),
        headers: AuthService.authHeaders,
        body: jsonEncode(data),
      );
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // 🔹 DELETE
  Future<bool> deleteEmployee(int id) async {
    try {
      final res = await http.delete(Uri.parse("$baseUrl/delete_employee/$id"),
      headers: AuthService.authHeaders,
      );
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<List<dynamic>> fetchEmployeesByFactory(int factoryId, int userId) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/employees?factory_id=$factoryId&user_id=$userId"),
        headers: AuthService.authHeaders,
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print("Fetch by factory error: $e");
    }
    return [];
  }
}