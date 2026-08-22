import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:techstile_frontend/core/services/auth_service.dart';

class PaymentService {
  final String baseUrl = "http://localhost:8000/api/payments";

  // FETCH ALL BATCH PAYMENTS 
  Future<PaymentsData> fetchvarietytypePayments(int factoryId) async {
    try {
      print("TOKEN: ${AuthService.token}");
print("HEADERS: ${AuthService.authHeaders}");
      final response = await http.get(
        Uri.parse("$baseUrl/view-payments/$factoryId"),
        headers: AuthService.authHeaders,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final List<dynamic> data = body['data'] ?? [];

        final varietytype = data.map((b) => varietytypePayment.fromJson(b)).toList();

        return PaymentsData(
          varietytype: varietytype,
          totalAmount: varietytype.fold(0.0, (sum, b) => sum + b.totalAmount),
          totalLength: varietytype.fold(0.0, (sum, b) => sum + b.totalLength),
        );
      }
    } catch (e) {
      debugPrint("Fetch Payments Error: $e");
    }
    return PaymentsData(varietytype: []);
  }
}

// Models

class PaymentsData {
  final List<varietytypePayment> varietytype;
  final double totalAmount;
  final double totalLength;

  PaymentsData({
    required this.varietytype,
    this.totalAmount = 0,
    this.totalLength = 0,
  });
}

class varietytypePayment {
  final String varietytype;      // <- backend: variety_type
  final double totalLength;      // <- backend: total_length
  final double amountPerMeter;   // <- backend: amount_per_meter
  final String? selectDays;      // <- backend: select_days
  final String? employeeName;    // <- backend: employee_name

  varietytypePayment({
    required this.varietytype,
    required this.totalLength,
    required this.amountPerMeter,
    this.selectDays,
    this.employeeName,
  });

  factory varietytypePayment.fromJson(Map<String, dynamic> json) {
    return varietytypePayment(
      varietytype: json['variety_type'].toString(),
      totalLength: (json['total_length'] as num?)?.toDouble() ?? 0,
      amountPerMeter: (json['amount_per_meter'] as num?)?.toDouble() ?? 0,
      selectDays: json['select_days']?.toString(),
      employeeName: json['employee_name']?.toString(),
    );
  }

  /// total_amount = total_length * amount_per_meter (always computed, never fetched)
  double get totalAmount => totalLength * amountPerMeter;
}