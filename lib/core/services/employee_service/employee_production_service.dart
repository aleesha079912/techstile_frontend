import 'dart:convert';
import 'package:http/http.dart' as http;
import '../auth_service.dart';

class EmployeeProductionService {
  static const String baseUrl =
      "http://localhost:8000/api/productions";

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

  try {
    final response = await http.post(
      Uri.parse("$baseUrl/add_production"),
      headers: AuthService.authHeaders,
      body: jsonEncode({
        "machine_id": machineId,
        "user_id": userId,
        "factory_id": factoryId,
        "variety_type": varietyType,
        "total_length": totalLength,
        "ready_production": readyProduction,
         "waste_production": wasteProduction,
        "status": 1
      }),
    );

    print(response.statusCode);
    print(response.body);

    return response.statusCode >= 200 &&
           response.statusCode < 300;

  } catch(e){
    print(e);
    return false;
  }
}
}