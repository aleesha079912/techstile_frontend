import 'package:http/http.dart' as http;
import 'dart:convert';

class RoleService {
  final String baseUrl = "http://localhost:8000/api/roles"; // Emulator ke liye localhost IP

  // 1. Fetch Roles
  Future<List<dynamic>> getRoles() async {
    final response = await http.get(Uri.parse('$baseUrl/all'));
    if (response.statusCode == 200) {
      return json.decode(response.body)['data'];
    } else {
      throw Exception('Failed to load roles');
    }
  }

  Future<Map<String, dynamic>> addRole(String name) async {
  var response = await http.post( Uri.parse('$baseUrl/add'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"name": name}),);

  var data = jsonDecode(response.body);

  if (data['status'] == true) {
    return {
      'success': true,
      'message': 'Role added successfully'
    };
  }

  return {
    'success': false,
    'message': data['errors']?['name']?[0] ??
        'Role already exists'
  };
}
  // Role delete karne ke liye
Future<bool> deleteRole(int id) async {
  final response = await http.delete(Uri.parse('$baseUrl/delete/$id'));
  return response.statusCode == 200;
}

// Role update karne ke liye
Future<bool> updateRole(int id, String newName) async {
  final response = await http.put(
    Uri.parse('$baseUrl/update/$id'),
    headers: {"Content-Type": "application/json"},
    body: json.encode({"name": newName}),
  );
  return response.statusCode == 200;
}
// Permissions list fetch karna
Future<List<dynamic>> getAllPermissions() async {
  final response = await http.get(Uri.parse('http://localhost:8000/api/permissions/all'));
  return json.decode(response.body)['data'];
}

// Role ki maujooda permissions lana
Future<List<dynamic>> getRolePermissions(int roleId) async {
  final response = await http.get(Uri.parse('http://localhost:8000/api/role-permissions/$roleId'));
  return json.decode(response.body)['data'];
}

// Permissions update karna
Future<bool> syncPermissions(int roleId, List<int> permIds) async {
  final response = await http.post(
    Uri.parse('http://localhost:8000/api/permissions/sync'),
    headers: {"Content-Type": "application/json"},
    body: json.encode({"role_id": roleId, "permissions": permIds}),
  );
  return response.statusCode == 200;
}
}