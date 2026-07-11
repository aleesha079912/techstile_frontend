import 'dart:convert';
import 'package:http/http.dart' as http;
import '../auth_service.dart';

class EmployeeProductionService {
  static const String baseUrl =
      "http://localhost:8000/api/productions";

 /// Returns a map: { success: bool, message: String }
 Future<Map<String, dynamic>> submitProductionWithMessage({
  required int machineId,
   required int userId,
  required int factoryId,
  required String varietyType,
  required double totalLength,
  required double readyProduction,
  required double wasteProduction,
}) async {

  try {
    final response = await http.post(
      Uri.parse("$baseUrl/add_production"),
      headers: AuthService.authHeaders,
      body: jsonEncode({
        "machine_id": machineId,
        "user_id": userId,
        "factory_id": factoryId,
        // ✅ variety_type/total_length ab backend khud employee ke current batch se
        // nikalta hai (source of truth) — client se bhejna zaroori nahi
        "ready_production": readyProduction,
         "waste_production": wasteProduction,
        "status": 1
      }),
    );

      print(response.statusCode);
      print(response.body);

      final ok = response.statusCode >= 200 && response.statusCode < 300;
      String message = ok ? 'Submitted successfully' : 'Production not added';
      try {
        final body = jsonDecode(response.body);
        if (body is Map && body['message'] != null) {
          message = body['message'].toString();
        }
      } catch (_) {}

      return {'success': ok, 'message': message};
    } catch (e) {
      print(e);
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<bool> submitProduction({
    required int machineId,
    // required int employeeId,
    required int userId,
    required int factoryId,
    required String varietyType,
    required double totalLength,
    required double readyProduction,
    required double wasteProduction,
  }) async {
    final res = await submitProductionWithMessage(
      machineId: machineId,
      userId: userId,
      factoryId: factoryId,
      varietyType: varietyType,
      totalLength: totalLength,
      readyProduction: readyProduction,
      wasteProduction: wasteProduction,
    );
    return res['success'] == true;
  }
}
