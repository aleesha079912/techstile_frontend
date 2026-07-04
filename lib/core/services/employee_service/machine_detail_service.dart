import 'dart:convert';
import 'package:http/http.dart' as http;
import '../auth_service.dart';

class EmployeeMachineService {
  final String baseUrl = "http://textstile.sandbox.pk/api";

  Future<Map<String, dynamic>> getMachineDetails(String machineId ) async {
    final response = await http.get(
      Uri.parse(
        "$baseUrl/employee/machine-details/$machineId",
      ),
      headers: AuthService.authHeaders,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception("Machine not found");
  }
}