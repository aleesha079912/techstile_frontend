import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:techstile_frontend/core/services/auth_service.dart';

class AssignProductionService {
  final String baseUrl = "http://localhost:8000/api";

  Future<bool> assign({
    required int machineId,
    required String varietyType,
    required double totalLength,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/assign-production"),
      headers: AuthService.authHeaders,
      body: jsonEncode({
        'machine_id': machineId,
        'variety_type': varietyType,
        'total_length': totalLength,
      }),
    );

    return response.statusCode == 200 ||
    response.statusCode == 201;
  }
}