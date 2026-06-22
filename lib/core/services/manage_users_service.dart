import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class UserData {
  final int? id;
  final String name, email, phone, cnic, address, role, details, pic;

  UserData({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.cnic,
    required this.address,
    required this.role,
    required this.details,
    this.pic = "",
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    String extractedRole = '';

    if (json['role'] != null && json['role'].toString().isNotEmpty) {
      extractedRole = json['role'].toString();
    } else if (json['roles'] != null &&
        json['roles'] is List &&
        (json['roles'] as List).isNotEmpty) {
      final firstRole = json['roles'][0];

      if (firstRole is Map && firstRole.containsKey('name')) {
        extractedRole = firstRole['name'] ?? '';
      }
    }

    return UserData(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone_no'] ?? '',
      cnic: json['cnic'] ?? '',
      address: json['address'] ?? '',
      role: extractedRole,
      details: json['employee_details'] ?? '',
      pic: json['pic'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "email": email,
      "phone_no": phone,
      "cnic": cnic,
      "address": address,
      "role": role,
      "employee_details": details,
      "pic": pic,
    };
  }
}

class ManageUsersService {
  static final ManageUsersService instance = ManageUsersService._();
  ManageUsersService._();

  final String baseUrl = "http://localhost:8000/api";

  Map<String, String> get _headers => {
        "Content-Type": "application/json",
        "Accept": "application/json",
        ...AuthService.authHeaders,
      };

  // ───────────────────────── USERS ─────────────────────────

  Future<List<UserData>> fetchUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/all'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        final List data =
            decoded is List ? decoded : decoded['data'] ?? [];

        return data.map((e) => UserData.fromJson(e)).toList();
      }

      return [];
    } catch (e) {
      print("fetchUsers error: $e");
      return [];
    }
  }

  Future<bool> addUser(UserData user, String password) async {
    try {
      final data = user.toJson();
      data['password'] = password;

      final response = await http.post(
        Uri.parse('$baseUrl/users/add'),
        headers: _headers,
        body: jsonEncode(data),
      );

      return response.statusCode == 200 ||
          response.statusCode == 201;
    } catch (e) {
      print("addUser error: $e");
      return false;
    }
  }

  Future<bool> updateUser(int id, Map<String, dynamic> data) async {
  try {
    final response = await http.put(
      Uri.parse('$baseUrl/users/update/$id'),
      headers: _headers,
      body: jsonEncode(data),
    );

    return response.statusCode == 200;
  } catch (e) {
    print("updateUser error: $e");
    return false;
  }
}

  Future<bool> deleteUser(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/users/delete/$id'),
        headers: _headers,
      );

      return response.statusCode == 200;
    } catch (e) {
      print("deleteUser error: $e");
      return false;
    }
  }

  // ───────────────────────── ROLES ─────────────────────────

Future<List<String>> fetchRoles() async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/users/all'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      final List users =
          decoded is List ? decoded : decoded['data'] ?? [];

      final Set<String> roles = {};

      for (final user in users) {
        if (user['roles'] != null &&
            user['roles'] is List &&
            (user['roles'] as List).isNotEmpty) {
          roles.add(user['roles'][0]['name'].toString());
        }
      }

      return roles.toList();
    }

    return [];
  } catch (e) {
    print("fetchRoles error: $e");
    return [];
  }
}

  // ───────────────────────── FACTORIES ─────────────────────────

  Future<List<dynamic>> getFactories() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/factories/allfactories'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        if (body is Map && body['data'] != null) {
          return body['data'];
        }
        if (body is List) return body;
      }

      return [];
    } catch (e) {
      print("getFactories error: $e");
      return [];
    }
  }

  // ───────────────────────── MACHINES ─────────────────────────

  Future<List<dynamic>> getFactoryMachines(int factoryId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/machines/all/$factoryId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        if (body is Map && body['data'] != null) {
          return body['data'];
        }
        if (body is List) return body;
      }

      return [];
    } catch (e) {
      print("getFactoryMachines error: $e");
      return [];
    }
  }

  // ───────────────────────── ASSIGN MACHINES ─────────────────────────

  Future<bool> assignMachines({
    required int userId,
    required int factoryId,
    required List<int> machineIds,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/assign-machines'),
        headers: _headers,
        body: jsonEncode({
          "user_id": userId,
          "factory_id": factoryId,
          "machine_ids": machineIds,
        }),
      );

      print("assignMachines: ${response.body}");

      return response.statusCode == 200 ||
          response.statusCode == 201;
    } catch (e) {
      print("assignMachines error: $e");
      return false;
    }
  }
}