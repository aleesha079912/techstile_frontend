import 'package:http/http.dart' as http;
import 'dart:convert';
import 'auth_service.dart';
class RoleService {
  final String baseUrl = "http://textstile.sandbox.pk/api/roles"; // Emulator ke liye localhost IP

  // 1. Fetch Roles
  Future<List<dynamic>> getRoles() async {
    final response = await http.get(Uri.parse('$baseUrl/all'),
    headers: AuthService.authHeaders,);
    if (response.statusCode == 200) {
      return json.decode(response.body)['data'];
    } else {
      throw Exception('Failed to load roles');
    }
  }

  Future<Map<String, dynamic>> addRole(String name) async {
  var response = await http.post( Uri.parse('$baseUrl/add'),
     headers: AuthService.authHeaders,
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
  final response = await http.delete(Uri.parse('$baseUrl/delete/$id'),
   headers: AuthService.authHeaders,
  );
  return response.statusCode == 200;
}

// Role update karne ke liye
Future<bool> updateRole(int id, String newName) async {
  final response = await http.put(
    Uri.parse('$baseUrl/update/$id'),
   headers: AuthService.authHeaders,
    body: json.encode({"name": newName}),
  );
  return response.statusCode == 200;
}
// Permissions list fetch karna
Future<List<dynamic>> getAllPermissions() async {
  final response = await http.get(Uri.parse('http://textstile.sandbox.pk/api/permissions/all'),
  headers: AuthService.authHeaders,);
  return json.decode(response.body)['data'];
}

// Role ki maujooda permissions lana
Future<List<dynamic>> getRolePermissions(int roleId) async {
  final response = await http.get(Uri.parse('http://textstile.sandbox.pk/api/role-permissions/$roleId'),
  headers: AuthService.authHeaders,);
  return json.decode(response.body)['data'];
}

// Permissions update karna
Future<bool> syncPermissions(int roleId, List<int> permIds) async {
  final response = await http.post(
    Uri.parse('http://textstile.sandbox.pk/api/permissions/sync'),
  headers: AuthService.authHeaders,
    body: json.encode({"role_id": roleId, "permissions": permIds}),
  );
  return response.statusCode == 200;
}
}