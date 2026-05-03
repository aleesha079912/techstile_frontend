import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class Machine {
  final String id;
  final String machineId;
  final String type;
  final String time; // Laravel model ke mutabiq

  Machine({
    required this.id,
    required this.machineId,
    required this.type,
    required this.time,
  });

  factory Machine.fromJson(Map<String, dynamic> json) {
    return Machine(
      id: json['id'].toString(),
      machineId: json['machine_id'] ?? '',
      type: json['machine_type'] ?? '',
      time: json['time'] ?? '',
    );
  }
}

class MachinesData {
  final List<Machine> machines;
  MachinesData({required this.machines});

  // Stats filhal total count dikhayenge kyunke DB mein status field nahi hai
  int get running => machines.length; 
  int get maintenance => 0;
  int get offline => 0;
}

class MachinesService {
  static final MachinesService instance = MachinesService._();
  MachinesService._();

  final String baseUrl = "http://localhost:8000/api/machines";

  // 🔹 1. FETCH ALL (Laravel: machines/all)
  Future<MachinesData> fetchMachines() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/all"));
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final List<dynamic> data = body['data']; // Laravel Controller 'data' key bhej raha hai
        return MachinesData(machines: data.map((m) => Machine.fromJson(m)).toList());
      }
    } catch (e) {
      debugPrint("Fetch Error: $e");
    }
    return MachinesData(machines: []);
  }

  // 🔹 2. CREATE (Laravel: machines/add_machine)
  Future<bool> addMachine(String machineId, String type) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/add_machine"),
        headers: {"Content-Type": "application/json",
        "Accept": "application/json",},
        body: jsonEncode({
          "machine_id": machineId,
          "machine_type": type,
          "time": DateTime.now().toIso8601String().substring(0, 10), // Required in Laravel
        }),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint("Add Error: $e");
      return false;
    }
  }

  // 🔹 3. UPDATE (Laravel: machines/update_machine/{id})
  Future<bool> updateMachine(String id, String machineId, String type) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/update_machine/$id"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "machine_id": machineId,
          "machine_type": type,
          "time": DateTime.now().toIso8601String().substring(0, 10),
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Update Error: $e");
      return false;
    }
  }

  // 🔹 4. DELETE (Laravel: machines/delete_machine/{id})
  Future<bool> deleteMachine(String id) async {
    try {
      final response = await http.delete(Uri.parse("$baseUrl/delete_machine/$id"));
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Delete Error: $e");
      return false;
    }
  }
}