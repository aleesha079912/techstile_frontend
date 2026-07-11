import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
class AttendanceService {
  // ⚠️ Emulator ke liye
  final String baseUrl = "http://localhost:8000/api/attendence";

  // 🔹 Get All
  Future<List<dynamic>> fetchAttendance() async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/all_attendence"),
      headers: AuthService.authHeaders,
      );
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (e) {
      print("Fetch Error: $e");
    }
    return [];
  }

  // 🔹 Add
  Future<bool> addAttendance(Map<String, dynamic> data) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/add_attendence"),
       headers: AuthService.authHeaders,
        body: jsonEncode(data),
      );
      return res.statusCode == 201;
    } catch (e) {
      print("Add Error: $e");
      return false;
    }
  }

  // 🔹 Update
  Future<bool> updateAttendance(int id, Map<String, dynamic> data) async {
    try {
      final res = await http.put(
        Uri.parse("$baseUrl/update_attendence/$id"),
       headers: AuthService.authHeaders,
        body: jsonEncode(data),
      );
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // 🔹 Delete
  Future<bool> deleteAttendance(int id) async {
    try {
      final res = await http.delete(Uri.parse("$baseUrl/delete_attendence/$id"),
      headers: AuthService.authHeaders,
      );
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}