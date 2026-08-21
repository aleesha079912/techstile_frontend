import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:techstile_frontend/core/services/auth_service.dart';

class PaymentService {
  final String baseUrl = "http://localhost:8000/api/payments";

  Future<Map<String, dynamic>> fetchvarietytypePayments(int factoryId) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/view-payments/$factoryId"),
        headers: AuthService.authHeaders,
      );

      debugPrint("Payments Status: ${response.statusCode}");
      debugPrint("Payments Response: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }

      throw Exception(
        "Failed to fetch payments. Status: ${response.statusCode}",
      );
    } catch (e) {
      debugPrint("Fetch Payments Error: $e");
      rethrow;
    }
  }

  Future<void> addPayment({
    required int factoryId,
    required int employeeId,
    required String varietyType,
    required double totalLength,
    String? machineName,
    required double amountPerMeter,
    String? selectDays,
    String? shiftStart,
    String? shiftEnd,
  }) async {
  final body = {
    "factory_id": factoryId,
    "employee_id": employeeId,
    "variety_type": varietyType,
    "total_length": totalLength,
    "machine_name": machineName,
    "amount_per_meter": amountPerMeter,
    "select_days": selectDays,
    "shift_start": shiftStart,
    "shift_end": shiftEnd,
  };

  // apna actual Dio/http POST call yahan lagao, jaise:
  // final response = await dio.post('/payments/add', data: body);
  // if (response.statusCode != 200 && response.statusCode != 201) {
  //   throw Exception('Failed to add payment');
  // }
}
}