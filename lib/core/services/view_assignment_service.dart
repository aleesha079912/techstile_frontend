import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
class ProductionService {
  static const String baseUrl = "http://localhost:8000/api/productions";

  Future<List<dynamic>> getProductions() async {
    final response = await http.get(
      Uri.parse("$baseUrl/all_production"),
      headers: AuthService.authHeaders,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return [];
    }
  }
}