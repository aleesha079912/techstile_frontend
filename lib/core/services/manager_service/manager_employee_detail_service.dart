import 'dart:convert';
import 'package:http/http.dart' as http;
import '../auth_service.dart';

class ManagerEmployeeDetailService {
  final String baseUrl = "http://techstile.sandbox.pk/api";

  Future<Map<String, dynamic>> getEmployeeDetail(
      int employeeId) async {

    final response = await http.get(
      Uri.parse(
          "$baseUrl/manager/employee-details/$employeeId"),
      headers: AuthService.authHeaders,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception("Failed to load employee");
  }
}