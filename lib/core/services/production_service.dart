// lib/core/services/production_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart'; // ← AuthService import

class ProductionAuthException implements Exception {
  final String message;
  ProductionAuthException([this.message = 'Session expired. Please login again.']);
  @override
  String toString() => message;
}

class ProductionService {
  static const String _base = AuthService.baseUrl;

  // Manager fetch all productions for factory 
 Future<Map<String, dynamic>> getManagerProductions(
  dynamic factoryId, {
  String? period,
}) async {
  if (factoryId == null || AuthService.token.isEmpty) {
    throw ProductionAuthException();
  }

  final uri = Uri.parse('$_base/manager/productions/$factoryId').replace(
    queryParameters: period != null ? {'period': period} : null,
  );

  final res = await http.get(uri, headers: AuthService.authHeaders);

  if (res.statusCode == 200) {
    return jsonDecode(res.body) as Map<String, dynamic>;
  }
  if (res.statusCode == 401) {
    throw ProductionAuthException();
  }
  throw Exception('Failed to load productions (${res.statusCode})');
}

  //Manager: approve or reject
  Future<void> managerAction(dynamic productionId, String action) async {
    final res = await http.post(
      Uri.parse('$_base/manager/productions/$productionId/action'),
      headers: AuthService.authHeaders,
      body: jsonEncode({'action': action}),
    );
    if (res.statusCode != 200) throw Exception('Action failed');
  }

  //  Owner fetch all productions for factory
Future<Map<String, dynamic>> getOwnerProductionsGrouped(
  dynamic factoryId, {
  String? period,
}) async {
  final uri = Uri.parse('$_base/owner/productions/$factoryId').replace(
    queryParameters: period != null ? {'period': period} : null,
  );

  final response = await http.get(uri, headers: AuthService.authHeaders);
  if (response.statusCode == 200) {
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
  throw Exception('Failed to load productions (${response.statusCode})');
}
 
  // Owner approve or reject
  Future<void> ownerAction(dynamic productionId, String action) async {
    final res = await http.post(
      Uri.parse('$_base/owner/productions/$productionId/action'),
      headers: AuthService.authHeaders,
      body: jsonEncode({'action': action}),
    );
    if (res.statusCode != 200) throw Exception('Action failed');
  }
}

// Status constants 
class ProductionStatus {
  static const int pending         = 1; 
  static const int managerApproved = 2;
  static const int managerRejected = 3;
  static const int ownerApproved   = 4;
  static const int ownerRejected   = 5;
}