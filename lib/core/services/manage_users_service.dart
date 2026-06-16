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

    // 🔥 SAFE ROLE EXTRACTION
    if (json['role'] != null && json['role'].toString().isNotEmpty) {
      extractedRole = json['role'].toString();
    } 
    else if (json['roles'] != null &&
        json['roles'] is List &&
        (json['roles'] as List).isNotEmpty) {

      final firstRole = json['roles'][0];

      if (firstRole is Map && firstRole.containsKey('name')) {
        extractedRole = firstRole['name'] ?? '';
      }
    }

    print("USER PARSED → ${json['name']} | ROLE: $extractedRole");

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

  // 🔥 CHANGE THIS IF USING EMULATOR
  final String baseUrl = "http://localhost:8000/api";

  Map<String, String> get _headers => {
        "Content-Type": "application/json",
        "Accept": "application/json",
        ...AuthService.authHeaders,
      };

  // ──────────────────────────────────────────
  // USERS
  // ──────────────────────────────────────────

  Future<List<UserData>> fetchUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/all'),
        headers: _headers,
      );

      print("FETCH USERS STATUS: ${response.statusCode}");
      print("FETCH USERS BODY: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        // 🔥 HANDLE BOTH RESPONSE TYPES
        final List data = decoded is List
            ? decoded
            : decoded['data'] ?? [];

        return data
            .map<UserData>((json) => UserData.fromJson(json))
            .toList();
      } else {
        print("FAILED TO FETCH USERS");
        return [];
      }
    } catch (e) {
      print("FETCH USERS ERROR: $e");
      return [];
    }
  }

  Future<bool> addUser(UserData user, String password) async {
    try {
      Map<String, dynamic> data = user.toJson();
      data['password'] = password;

      final response = await http.post(
        Uri.parse('$baseUrl/users/add'),
        headers: _headers,
        body: jsonEncode(data),
      );

      print("ADD USER RESPONSE: ${response.body}");

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print("ADD USER ERROR: $e");
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

      print("UPDATE USER RESPONSE: ${response.body}");

      return response.statusCode == 200;
    } catch (e) {
      print("UPDATE USER ERROR: $e");
      return false;
    }
  }

  Future<bool> deleteUser(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/users/delete/$id'),
        headers: _headers,
      );

      print("DELETE USER RESPONSE: ${response.body}");

      return response.statusCode == 200;
    } catch (e) {
      print("DELETE USER ERROR: $e");
      return false;
    }
  }

  // ──────────────────────────────────────────
  // FACTORIES
  // ──────────────────────────────────────────

  Future<List<dynamic>> getFactories() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/factories/allfactories'),
        headers: _headers,
      );

      print("FACTORIES RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return decoded['data'] ?? [];
      }
      return [];
    } catch (e) {
      print("FACTORY ERROR: $e");
      return [];
    }
  }

  Future<bool> assignFactoryToUser({
    required int userId,
    required int factoryId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/assign-factory'),
        headers: _headers,
        body: jsonEncode({
          'user_id': userId,
          'factory_id': factoryId,
        }),
      );

      print("ASSIGN FACTORY RESPONSE: ${response.body}");

      if (response.statusCode != 200) return false;

      return jsonDecode(response.body)['success'] == true;
    } catch (e) {
      print("ASSIGN FACTORY ERROR: $e");
      return false;
    }
  }

  // ──────────────────────────────────────────
  // MACHINES
  // ──────────────────────────────────────────

  Future<List<dynamic>> getFactoryMachines(int factoryId) async {
    try {
      final uri = Uri.parse('$baseUrl/machines/all')
          .replace(queryParameters: {
        'factory_id': factoryId.toString(),
      });

      final response = await http.get(uri, headers: _headers);

      print("MACHINES RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return decoded['data'] ?? [];
      }

      return [];
    } catch (e) {
      print("MACHINES ERROR: $e");
      return [];
    }
  }

  Future<bool> assignMachines({
    required int userId,
    required int factoryId,
    required List<int> machineIds,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/assign-machines'),
        headers: _headers,
        body: jsonEncode({
          'user_id': userId,
          'factory_id': factoryId,
          'machine_ids': machineIds,
        }),
      );

      print("ASSIGN MACHINES RESPONSE: ${response.body}");

      if (response.statusCode != 200) return false;

      return jsonDecode(response.body)['success'] == true;
    } catch (e) {
      print("ASSIGN MACHINES ERROR: $e");
      return false;
    }
  }
}