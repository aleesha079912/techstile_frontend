import 'dart:convert';
import 'package:http/http.dart' as http;

class MachineAssignmentService {
  // 127.0.0.1 browser ke liye theek hai, Emulator ke liye 10.0.2.2 use karein
  static const String baseUrl = "http://127.0.0.1:8000/api";

  Future<Map<String, List<dynamic>>> getAssignmentFormData() async {
    try {
      final responses = await Future.wait([
        http.get(Uri.parse("$baseUrl/factories/allfactories")),
        http.get(Uri.parse("$baseUrl/users/all")),
        http.get(Uri.parse("$baseUrl/employees/all_employee")),
        http.get(Uri.parse("$baseUrl/machines/all")),
      ]);

      return {
        "factories": _extractData(responses[0]),
        "users": _extractData(responses[1]),
        "employees": _extractData(responses[2]),
        "machines": _extractData(responses[3]),
      };
    } catch (e) {
      print("Fetch Error: $e");
      return {"factories": [], "users": [], "employees": [], "machines": []};
    }
  }

  // Flexible extraction logic
  List<dynamic> _extractData(http.Response res) {
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      // Agar response { "data": [...] } format mein hai
      if (body is Map && body.containsKey('data')) {
        return body['data'];
      } 
      // Agar direct list [...] format mein hai
      if (body is List) {
        return body;
      }
    }
    print("API Error (${res.statusCode}) on: ${res.request?.url}");
    return [];
  }

  Future<bool> storeProduction(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/productions/add_production"), // Corrected Store Route
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}