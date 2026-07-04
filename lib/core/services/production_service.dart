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

  // ── Manager: fetch all productions for factory ────────────
  Future<List<Map<String, dynamic>>> getManagerProductions(dynamic factoryId) async {
    if (factoryId == null || AuthService.token.isEmpty) {
      throw ProductionAuthException();
    }
    final res = await http.get(
      Uri.parse('$_base/manager/productions/$factoryId'),
      headers: AuthService.authHeaders,   // ← auth headers
    );
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      return List<Map<String, dynamic>>.from(body['productions'] ?? []);
    }
    if (res.statusCode == 401) {
      throw ProductionAuthException();
    }
    throw Exception('Failed to load productions (${res.statusCode})');
  }

  // ── Manager: approve or reject ────────────────────────────
  Future<void> managerAction(dynamic productionId, String action) async {
    final res = await http.post(
      Uri.parse('$_base/manager/productions/$productionId/action'),
      headers: AuthService.authHeaders,
      body: jsonEncode({'action': action}),
    );
    if (res.statusCode != 200) throw Exception('Action failed');
  }

  // ── Owner: fetch all productions for factory ──────────────
  Future<List<Map<String, dynamic>>> getOwnerProductions(dynamic factoryId) async {
    if (factoryId == null || AuthService.token.isEmpty) {
      throw ProductionAuthException();
    }
    final res = await http.get(
      Uri.parse('$_base/owner/productions/$factoryId'),
      headers: AuthService.authHeaders,
    );
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      return List<Map<String, dynamic>>.from(body['productions'] ?? []);
    }
    if (res.statusCode == 401) {
      throw ProductionAuthException();
    }
    throw Exception('Failed to load productions (${res.statusCode})');
  }

  // ── Owner: approve or reject ──────────────────────────────
  Future<void> ownerAction(dynamic productionId, String action) async {
    final res = await http.post(
      Uri.parse('$_base/owner/productions/$productionId/action'),
      headers: AuthService.authHeaders,
      body: jsonEncode({'action': action}),
    );
    if (res.statusCode != 200) throw Exception('Action failed');
  }
}

// ── Status constants ──────────────────────────────────────────
class ProductionStatus {
  static const int pending         = 1; // employee submitted
  static const int managerApproved = 2;
  static const int managerRejected = 3;
  static const int ownerApproved   = 4;
  static const int ownerRejected   = 5;
}