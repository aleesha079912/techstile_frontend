import 'dart:convert';
import 'package:http/http.dart' as http;
import '../auth_service.dart';

class EmployeeDashboardService {
  final String baseUrl = "http://localhost:8000/api";

  Future<Map<String, dynamic>> getDashboard() async {
  // ✅ Storage se user id nikalo
  final user = AuthService.box.read('user');
  final userId = user?['id'];
  
  print("👤 User ID: $userId");
  print("🔑 Token: ${AuthService.token}");

  final response = await http.get(
    Uri.parse("$baseUrl/employee/dashboard/$userId"), // ✅ id add karo
    headers: AuthService.authHeaders,
  );

  print("📡 Status: ${response.statusCode}");
  print("📦 Body: ${response.body}");

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception("Failed: ${response.body}");
  }
}
  }
