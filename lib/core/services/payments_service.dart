import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:techstile_frontend/core/services/auth_service.dart';

class PaymentService {
  final String baseUrl = "http://localhost:8000/api/payments";

  Future<Map<String, dynamic>> fetchvarietytypePayments(int factoryId) async {
    try {
      print("TOKEN: ${AuthService.token}");
print("HEADERS: ${AuthService.authHeaders}");
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

  Future<Map<String, dynamic>> addPayment({
    required int employeeId,
    
    required double amountPaid,
    // required int productionId, 
  }) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          ...AuthService.authHeaders,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "employee_id": employeeId,
          "amount_paid": amountPaid,
          // "production_id": productionId, // ✅ NEW
        }),
      );

      debugPrint("Add Payment Status: ${response.statusCode}");
      debugPrint("Add Payment Response: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }

      throw Exception(
        "Failed to save payment. Status: ${response.statusCode}, Body: ${response.body}",
      );
    } catch (e) {
      debugPrint("Add Payment Error: $e");
      rethrow;
    }
  }
  Future<Map<String, dynamic>> fetchAllPayments(int factoryId) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl?factory_id=$factoryId"),
        headers: AuthService.authHeaders,
      );

      debugPrint("Fetch All Payments Status: ${response.statusCode}");
      debugPrint("Fetch All Payments Response: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }

      throw Exception(
        "Failed to fetch payments. Status: ${response.statusCode}",
      );
    } catch (e) {
      debugPrint("Fetch All Payments Error: $e");
      rethrow;
    }
  }
   
  Future<Map<String, dynamic>> getEarnedAmount(int employeeId) async {
    try {
      final response = await http.get(
        Uri.parse("http://localhost:8000/api/employees/$employeeId/earned-amount"),
        headers: AuthService.authHeaders,
      );

      debugPrint("Earned Amount Status: ${response.statusCode}");
      debugPrint("Earned Amount Response: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }

      throw Exception("Failed to fetch earned amount. Status: ${response.statusCode}");
    } catch (e) {
      debugPrint("Get Earned Amount Error: $e");
      rethrow;
    }
  }

  Future<void> deletePayment(int paymentId) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/$paymentId"),
        headers: AuthService.authHeaders,
      );

      debugPrint("Delete Payment Status: ${response.statusCode}");
      debugPrint("Delete Payment Response: ${response.body}");

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(
          "Failed to delete payment. Status: ${response.statusCode}",
        );
      }
    } catch (e) {
      debugPrint("Delete Payment Error: $e");
      rethrow;
    }
  }
  Future<Map<String, dynamic>> updatePayment({
    required int paymentId,
    required double amountPaid,
  }) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/$paymentId"),
        headers: {
          ...AuthService.authHeaders,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "amount_paid": amountPaid,
        }),
      );

      debugPrint("Update Payment Status: ${response.statusCode}");
      debugPrint("Update Payment Response: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }

      throw Exception(
        "Failed to update payment. Status: ${response.statusCode}, Body: ${response.body}",
      );
    } catch (e) {
      debugPrint("Update Payment Error: $e");
      rethrow;
    }
  }





}  