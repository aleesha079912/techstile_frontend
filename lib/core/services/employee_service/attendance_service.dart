import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:techstile_frontend/core/services/auth_service.dart';

class AttendanceService {


final String baseUrl =
    "http://textstile.sandbox.pk/api/attendence";

Future<bool> markAttendance({
  required int employeeId,
  required int machineId,
}) async {

  final response = await http.post(
    Uri.parse("$baseUrl/mark_attendance"),
    headers: AuthService.authHeaders,
    body: jsonEncode({
      "employee_id": employeeId,
      "machine_id": machineId,
    }),
  );

  print(response.statusCode);
  print(response.body);

  return response.statusCode == 201;
}

}