import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class Variety {
  final int id;
  final String name;
  Variety({required this.id, required this.name});

  factory Variety.fromJson(Map<String, dynamic> j) => Variety(
        id: j['id'] is int ? j['id'] : int.parse(j['id'].toString()),
        name: j['name']?.toString() ?? '',
      );
}

class VarietyService {
  VarietyService._();
  static final instance = VarietyService._();

  static String get _base => "${AuthService.baseUrl}/varieties";

  Future<List<Variety>> fetch() async {
    try {
      final res =
          await http.get(Uri.parse(_base), headers: AuthService.authHeaders);
      debugPrint("VARIETY GET ${res.statusCode}: ${res.body}");
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final list = (body['data'] ?? []) as List;
        return list.map((e) => Variety.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint("VARIETY GET error: $e");
    }
    return [];
  }

  /// Returns null on success, otherwise the error message.
  Future<String?> add(String name) async {
    try {
      final res = await http.post(
        Uri.parse(_base),
        headers: AuthService.authHeaders,
        body: jsonEncode({'name': name}),
      );
      debugPrint("VARIETY POST ${res.statusCode}: ${res.body}");
      if (res.statusCode == 200 || res.statusCode == 201) return null;

      final body = jsonDecode(res.body);
      return body['errors']?['name']?[0] ??
          body['message'] ??
          'Variety not added';
    } catch (e) {
      return e.toString();
    }
  }

  Future<bool> delete(int id) async {
    try {
      final res = await http.delete(
        Uri.parse("$_base/$id"),
        headers: AuthService.authHeaders,
      );
      debugPrint("VARIETY DELETE ${res.statusCode}: ${res.body}");
      return res.statusCode == 200 || res.statusCode == 204;
    } catch (_) {
      return false;
    }
  }
}