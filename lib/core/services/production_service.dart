import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
class ProductionService {
  // Base URL (Apne backend IP ke mutabiq change karein)
  static const String baseUrl = "http://localhost:8000/api/productions";

  // 1. Fetch All
  Future<List<dynamic>> fetchProductions() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/all_production"),
      headers: AuthService.authHeaders,
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print("Error: $e");
    }
    return [];
  }

  // 2. Add Production
  Future<bool> addProduction(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/add_production"),
       headers: AuthService.authHeaders,
        body: jsonEncode(data),
      );
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  // 3. Update Production
  Future<bool> updateProduction(int id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/update_production/$id"),
       headers: AuthService.authHeaders,
        body: jsonEncode(data),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // 4. Delete Production
  Future<bool> deleteProduction(int id) async {
    try {
      final response = await http.delete(Uri.parse("$baseUrl/delete_production/$id"),
      headers: AuthService.authHeaders,
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

