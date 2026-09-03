import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class FactoryUsersService {
  static final FactoryUsersService instance =
      FactoryUsersService._();

  FactoryUsersService._();

  final String baseUrl =
      "http://techstile.sandbox.pk/api";

  Future<Map<String, dynamic>> getUsersByFactory(
      int factoryId) async {
    final response = await http.get(
      Uri.parse(
        "$baseUrl/factory-users/$factoryId",
      ),
      headers: AuthService.authHeaders,
    );

    if (response.statusCode != 200) {
      throw Exception(
        "Failed to load factory users",
      );
    }

    final data = jsonDecode(response.body);

    return {
      "manager": data["manager"],

      "data": data["data"] ?? [],

      "total_users":
          data["total_users"] ?? 0,

      "active_users":
          data["active_users"] ?? 0,
    };
  }
}