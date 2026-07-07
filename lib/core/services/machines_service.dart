import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'auth_service.dart';

class Machine {
  final String id;
  final String machineName; // ✅ field name
  final String type;
  final String time;
  final bool isActive;

  Machine({
    required this.id,
    required this.machineName, // ✅ constructor mein same naam
    required this.type,
    required this.time,
    this.isActive = false,
  });

  factory Machine.fromJson(Map<String, dynamic> json) {
    return Machine(
      id: json['id'].toString(),
      machineName: json['machine_name'] ?? '', // ✅ DB column → dart field
      type: json['machine_type'] ?? '',
      time: json['time'] ?? '',
      isActive: json['is_active'] == true,
    );
  }
}

class MachinesData {
  final List<Machine> machines;
  final int totalMachines;
  final int activeMachines;
  MachinesData({
    required this.machines,
    int? totalMachines,
    int? activeMachines,
  })  : totalMachines = totalMachines ?? machines.length,
        activeMachines =
            activeMachines ?? machines.where((m) => m.isActive).length;

  int get running => machines.length;
  int get maintenance => 0;
  int get offline => 0;
}

class MachinesService {
  static final MachinesService instance = MachinesService._();
  MachinesService._();

  final String baseUrl = "http://techstile.sandbox.pk/api/machines";

  // 🔹 1. FETCH ALL (Laravel: machines/all)
  Future<MachinesData> fetchMachines(int factoryId) async {
    try {
      final response = await http.get(
        Uri.parse(
          "$baseUrl/all/$factoryId",
        ),
       headers: AuthService.authHeaders,
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final List<dynamic> data = body['data'];
        return MachinesData(
          machines: data.map((m) => Machine.fromJson(m)).toList(),
          totalMachines: body['total_machines'],
          activeMachines: body['active_machines'],
        );
      }
    } catch (e) {
      debugPrint("Fetch Error: $e");
    }
    return MachinesData(machines: []);
  }

  // 🔹 2. CREATE (Laravel: machines/add_machine)
  Future<Map<String, Object>?> addMachine(
    String machineId,
    String type,
    int factoryId,
    ) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/add_machine"),
        headers: AuthService.authHeaders,
        body: jsonEncode({
         "machine_name": machineId,
         "machine_type": type,
         "factory_id": factoryId,
         "time": DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        return {
          'success': true,
          'id': decoded['data']['id'].toString(),
        };
      }
      return null;
    } catch (e) {
      debugPrint("Add Error: $e");
      return null;
    }
  }

  // 🔹 3. UPDATE (Laravel: machines/update_machine/{id})
  Future<bool> updateMachine(String id, String machineId, String type, int factoryId) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/update_machine/$id"),
        headers: AuthService.authHeaders,
        body: jsonEncode({
          "machine_name": machineId,
          "machine_type": type,
          "factory_id": factoryId,
          "time": DateTime.now().toIso8601String().substring(0, 10),
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Update Error: $e");
      return false;
    }
  }

  // 🔹 4. DELETE
  Future<bool> deleteMachine(String id) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/delete_machine/$id"),
        headers: AuthService.authHeaders,
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Delete Error: $e");
      return false;
    }
  }
}