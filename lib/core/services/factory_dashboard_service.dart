import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class FactoryDashboardService {
  final String baseUrl = "http://localhost:8000/api/factories";

  Future<Map<String, dynamic>> getDashboard(String factoryId, {String? period}) async {
    final query = (period != null && period.isNotEmpty) ? "?period=${Uri.encodeComponent(period)}" : "";
    final response = await http.get(
      Uri.parse("$baseUrl/dashboard/$factoryId$query"),
      headers: AuthService.authHeaders,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception("Could not load factory dashboard");
  }

  // 0 = Sunday ... 6 = Saturday
  Future<Map<String, dynamic>> updateWeekStartDay(
      String factoryId, int weekStartDay) async {
    final response = await http.put(
      Uri.parse("$baseUrl/week-start-day/$factoryId"),
      headers: {
        ...AuthService.authHeaders,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'week_start_day': weekStartDay}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception("Could not update week start day");
  }
}
