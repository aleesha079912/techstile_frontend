import 'package:flutter/foundation.dart';
class Machine {
  final String id;
  final String type;
  final String status;

  Machine({
    required this.id,
    required this.type,
    required this.status,
  });
}

class MachinesData {
  final List<Machine> machines;

  MachinesData({required this.machines});

  int get running =>
      machines.where((m) => m.status == "Running").length;

  int get maintenance =>
      machines.where((m) => m.status == "Maintenance").length;

  int get offline =>
      machines.where((m) => m.status == "Offline").length;
}

class MachinesService {
  Future<MachinesData> fetchMachines() async {
    await Future.delayed(const Duration(milliseconds: 400));

    return MachinesData(
      machines: [
        Machine(id: "LM-8402", type: "Rapier Loom", status: "Running"),
        Machine(id: "LM-8405", type: "Air-Jet", status: "Maintenance"),
        Machine(id: "LM-8412", type: "Jacquard", status: "Running"),
        Machine(id: "LM-8421", type: "Water-Jet", status: "Offline"),
        Machine(id: "LM-8422", type: "Rapier Loom", status: "Running"),
      ],
    );
  }
}


class RegisterMachineService {
  Future<bool> registerMachine(
    String name,
    String type,
    String model,
    DateTime? date,
    String location,
  ) async {
    await Future.delayed(const Duration(seconds: 1));

    debugPrint("Machine Registered:");
    debugPrint("$name | $type | $model | $location");

    return true;
  }
}