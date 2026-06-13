import 'dart:convert';
import 'package:http/http.dart' as http;
import '../auth_service.dart';

class EmployeeProductionService {
  static const String baseUrl =
      "http://localhost:8000/api/productions";

  Future<bool> submitProduction({
    required int machineId,
    required int employeeId,
    required int factoryId,
    required String varietyType,
    required double totalLength,
    required double readyProduction,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/add_production"),
        headers: AuthService.authHeaders,
        body: jsonEncode({
          "machine_id": machineId,
          "employee_id": employeeId,
          "factory_id": factoryId,
          "variety_type": varietyType,
          "total_length": totalLength,
          "ready_production": readyProduction,
            "status": 1
        }),
      );

      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}