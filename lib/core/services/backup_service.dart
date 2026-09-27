import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class BackupService {
 
  static const String baseUrl ="http://techstile.sandbox.pk/api";

  static Future<Map<String, dynamic>> list() async {
    final res = await http
        .get(Uri.parse('$baseUrl/backups'), headers: AuthService.authHeaders)
        .timeout(const Duration(seconds: 30));
    if (res.statusCode != 200) throw Exception('Backups not fetched');
    return jsonDecode(res.body);
  }

  static Future<void> toggle(bool enabled) async {
    final res = await http
        .post(Uri.parse('$baseUrl/backups/toggle'),
            headers: AuthService.authHeaders, body: jsonEncode({'enabled': enabled}))
        .timeout(const Duration(seconds: 60));
    if (res.statusCode != 200) throw Exception('Setting not saved');
  }

  static Future<void> backupNow() async {
    final res = await http
        .post(Uri.parse('$baseUrl/backups'),  headers: AuthService.authHeaders,)
        .timeout(const Duration(seconds: 60));
    if (res.statusCode != 201) throw Exception('Backup failed');
  }

  static Future<String> restore(int id) async {
    final res = await http
        .post(Uri.parse('$baseUrl/backups/$id/restore'),  headers: AuthService.authHeaders,)
        .timeout(const Duration(seconds: 120));
    final body = jsonDecode(res.body);
    if (res.statusCode != 200) {
      throw Exception(body['message'] ?? 'Restore failed');
    }
    return body['message'] ?? 'Restore successful';
  }
}