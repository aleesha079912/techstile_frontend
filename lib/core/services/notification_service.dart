import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import './auth_service.dart';

class NotificationService {
  static const String baseUrl = "http://localhost:8000/api";

  Future<List> getNotifications(dynamic userId) async {
    if (userId == null) return [];
    try {
      final url = Uri.parse("$baseUrl/notifications/$userId");
      final res = await http.get(url, headers: AuthService.authHeaders);

      debugPrint("NOTIFICATION STATUS => ${res.statusCode}");
      debugPrint("NOTIFICATION BODY => ${res.body}");

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        if (decoded is List) {
          return decoded;
        } else if (decoded is Map && decoded['notifications'] is List) {
          return List.from(decoded['notifications']);
        } else if (decoded is Map && decoded['data'] is List) {
          return List.from(decoded['data']);
        }
      }
      return [];
    } catch (e) {
      debugPrint("getNotifications error: $e");
      return [];
    }
  }

  Future<void> read(dynamic id) async {
    if (id == null) return;
    try {
      final url = Uri.parse("$baseUrl/notifications/read/$id");
      await http.post(url, headers: AuthService.authHeaders);
    } catch (e) {
      debugPrint("read notification error: $e");
    }
  }

  Future<int> getUnreadCount(dynamic userId) async {
    if (userId == null) return 0;
    try {
      final url = Uri.parse("$baseUrl/notifications/unread/$userId");
      final res = await http.get(url, headers: AuthService.authHeaders);
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        if (decoded is Map && decoded['count'] != null) {
          return int.tryParse(decoded['count'].toString()) ?? 0;
        }
      }
      return 0;
    } catch (e) {
      debugPrint("getUnreadCount error: $e");
      return 0;
    }
  }
}

