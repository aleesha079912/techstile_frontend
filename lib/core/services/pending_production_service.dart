import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class OwnerProductionService {
  static const String baseUrl = "http://localhost:8000/api/productions";

  Future<List<dynamic>>
getPendingProductions() async {

  final response = await http.get(
    Uri.parse(
      "$baseUrl/pending",
    ),
    headers:
        AuthService.authHeaders,
  );

  return jsonDecode(response.body);
}

 Future<bool> approveProduction(
    int id) async {

  final response = await http.put(
    Uri.parse(
      "$baseUrl/approve/$id",
    ),
    headers:
        AuthService.authHeaders,
  );

  return response.statusCode == 200;
}

 Future<bool> rejectProduction(
    int id) async {

  final response = await http.put(
    Uri.parse(
      "$baseUrl/reject/$id",
    ),
    headers:
        AuthService.authHeaders,
  );

  return response.statusCode == 200;
}

}


