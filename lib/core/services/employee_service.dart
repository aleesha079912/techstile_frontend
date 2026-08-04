import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class EmployeeService {
  final String baseUrl = "http://localhost:8000/api";

  // 🔹 GET ALL
  Future<List<dynamic>> fetchEmployees() async {
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/employees/all_employee"),
        headers: AuthService.authHeaders,
      );
      if (res.statusCode == 200) return jsonDecode(res.body);
    } catch (e) {
      print("Fetch Error: $e");
    }
    return [];
  }

  Future<List<dynamic>> fetchFactories() async {
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/employees/factories"),
        headers: AuthService.authHeaders,
      );

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (e) {
      print(e);
    }

    return [];
  }

  Future<List<dynamic>> fetchUsers() async {
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/employees/users"),
        headers: AuthService.authHeaders,
      );

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (e) {
      print(e);
    }

    return [];
  }

  // 🔹 ADD
  Future<bool> addEmployee(Map<String, dynamic> data) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/employees/add_employee"),
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
        Uri.parse("$baseUrl/employees/update_employee/$id"),
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
      final res = await http.delete(
        Uri.parse("$baseUrl/employees/delete_employee/$id"),
        headers: AuthService.authHeaders,
      );
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ✅ Fix: sahi route — sirf isi factory ke employees (dropdown ke liye)
  Future<List<dynamic>> fetchEmployeesByFactory(int factoryId) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/employees-by-factory/$factoryId"),
        headers: AuthService.authHeaders,
      );
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body['data'] ?? [];
      }
    } catch (e) {
      print("Fetch by factory error: $e");
    }
    return [];
  }
}
