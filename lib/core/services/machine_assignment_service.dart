import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class AssignMachineService {
  static final AssignMachineService instance = AssignMachineService._();
  AssignMachineService._();

  final String baseUrl = "http://localhost:8000/api";

  Map<String, String> get _headers => {
        "Content-Type": "application/json",
        "Accept": "application/json",
        ...AuthService.authHeaders,
      };

  Future<Map<String, List<dynamic>>> getAssignmentFormData() async {
  final factories = await getFactories();
  final managers = await getManagers();
  final employees = await getEmployees();

  return {
    "factories": factories,
    "managers": managers,
    "employees": employees,
  };
}
  
  
  // FACTORIES
  Future<List<dynamic>> getFactories() async {
    final res = await http.get(Uri.parse('$baseUrl/factories/allfactories'),
        headers: _headers);

    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      return body['data'] ?? [];
    }
    return [];
  }

  // MANAGERS
  Future<List<dynamic>> getManagers() async {
    final res = await http.get(Uri.parse('$baseUrl/users/managers'),
        headers: _headers);

    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      return body['data'] ?? [];
    }
    return [];
  }

  // EMPLOYEES
  Future<List<dynamic>> getEmployees() async {
    final res = await http.get(Uri.parse('$baseUrl/users/employees'),
        headers: _headers);

    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      return body['data'] ?? [];
    }
    return [];
  }

  // MACHINES BY FACTORY
  Future<List<dynamic>> getFactoryMachines(int factoryId) async {
    final res = await http.get(
        Uri.parse('$baseUrl/machines/all/$factoryId'),
        headers: _headers);

    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      return body['data'] ?? [];
    }
    return [];
  }

  Future<List<dynamic>> getEmployeesByFactory(int factoryId) async {
  final res = await http.get(
    Uri.parse('$baseUrl/employees-with-shift/$factoryId'),
    headers: _headers,
  );

  if (res.statusCode == 200) {
    final body = jsonDecode(res.body);
    return body['data'] ?? [];
  }
  return [];
}

  // ASSIGN API
 Future<bool> assign({
  required int employeeId,
  required int managerId,
  required int factoryId,
  required List<int> machineIds,
}) async {
  final res = await http.post(
    Uri.parse('$baseUrl/assign-machines'),
    headers: _headers,
    body: jsonEncode({
  "employee_id": employeeId,
  "manager_id": managerId,
  "factory_id": factoryId,
  "machine_ids": machineIds,
}),
  );

  print(res.body);

  return res.statusCode == 200 ||
      res.statusCode == 201;
}
}