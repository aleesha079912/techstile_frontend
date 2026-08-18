import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:techstile_frontend/core/services/auth_service.dart';

class PaymentService {
  final String baseUrl = "http://localhost:8000/api/payments";

  // 🔹 FETCH ALL BATCH PAYMENTS (Laravel: payments/view-payments/{factoryId})
  //
  // Backend now reads straight from the `production` table, grouped by
  // batch_id, and only ever sends 3 fields per batch:
  //   batch_id, total_length, amount_per_meter
  //
  // total_amount is NEVER read from the API - it is always computed here
  // on the client as total_length * amount_per_meter (see BatchPayment.totalAmount).
  Future<PaymentsData> fetchBatchPayments(int factoryId) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/view-payments/$factoryId"),
        headers: AuthService.authHeaders,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final List<dynamic> data = body['data'] ?? [];

        final batches = data.map((b) => BatchPayment.fromJson(b)).toList();

        return PaymentsData(
          batches: batches,
          totalAmount: batches.fold(0.0, (sum, b) => sum + b.totalAmount),
          totalLength: batches.fold(0.0, (sum, b) => sum + b.totalLength),
        );
      }
    } catch (e) {
      debugPrint("Fetch Payments Error: $e");
    }
    return PaymentsData(batches: []);
  }
}

// ============================================================
// Models
// ============================================================

class PaymentsData {
  final List<BatchPayment> batches;
  final double totalAmount;
  final double totalLength;

  PaymentsData({
    required this.batches,
    this.totalAmount = 0,
    this.totalLength = 0,
  });
}

class BatchPayment {
  final String batchId;
  final double totalLength;
  final double amountPerMeter;

  BatchPayment({
    required this.batchId,
    required this.totalLength,
    required this.amountPerMeter,
  });

  factory BatchPayment.fromJson(Map<String, dynamic> json) {
    return BatchPayment(
      batchId: json['batch_id'].toString(),
      totalLength: (json['total_length'] as num?)?.toDouble() ?? 0,
      amountPerMeter: (json['amount_per_meter'] as num?)?.toDouble() ?? 0,
    );
  }

  /// total_amount = total_length * amount_per_meter (always computed, never fetched)
  double get totalAmount => totalLength * amountPerMeter;
}