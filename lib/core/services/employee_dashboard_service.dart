import 'dart:convert';
import 'package:http/http.dart' as http;

class EmployeeDashboardService {

  final String baseUrl = "http://localhost:8000/api"; 
  // 👆 Android emulator ke liye localhost fix

  Future<Map<String, dynamic>> getDashboard(int employeeId) async {

    final response = await http.get(
      Uri.parse("$baseUrl/employee/dashboard/$employeeId"),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Dashboard API failed");
    }
  }
}