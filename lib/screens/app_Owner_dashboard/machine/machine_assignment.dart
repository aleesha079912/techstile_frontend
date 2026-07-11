import 'package:flutter/material.dart';
import 'package:techstile_frontend/core/services/machine_assignment_service.dart';

class MachineAssignmentPage extends StatefulWidget {
  const MachineAssignmentPage({super.key});

  @override
  State<MachineAssignmentPage> createState() => _MachineAssignmentPageState();
}

class _MachineAssignmentPageState extends State<MachineAssignmentPage> {
  final _service = AssignMachineService.instance;

  final _formKey = GlobalKey<FormState>();

  List<dynamic> factories = [];
  List<dynamic> managers = [];
  List<dynamic> employees = [];
  List<dynamic> machines = [];

  int? selFactory;
  int? selManager;
  int? selEmployee;
  int? selectedMachine;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  void _loadAllData() async {
    final data = await _service.getAssignmentFormData();

    setState(() {
      factories = data['factories'] ?? [];
      managers = data['managers'] ?? [];
      employees = data['employees'] ?? [];
      isLoading = false;
    });
  }

  void _loadMachines(int factoryId) async {
    final data = await _service.getFactoryMachines(factoryId);

    setState(() {
      machines = data;
      selectedMachine = null;
    });
  }

  // ✅ NEW: filter employees by factory shift
  Future<void> _loadEmployeesByFactory(int factoryId) async {
    final data = await _service.getEmployeesByFactory(factoryId);

    setState(() {
      employees = data;
      selEmployee = null;
    });
  }

  Future<void> _handleAssignment() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedMachine == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a machine")),
      );
      return;
    }

    final success = await _service.assign(
      employeeId: selEmployee!,
      managerId: selManager!,
      factoryId: selFactory!,
      machineIds: [selectedMachine!],
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Machine Assigned Successfully"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Assignment Failed"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Machine Assignment"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildDrop(
                      "Select Factory",
                      factories,
                      selFactory,
                      (v) {
                        setState(() {
                          selFactory = v;
                        });

                        _loadMachines(v!);

                        // ✅ NEW: load filtered employees
                        _loadEmployeesByFactory(v);
                      },
                    ),

                    _buildDrop(
                      "Select Manager",
                      managers,
                      selManager,
                      (v) => setState(() => selManager = v),
                    ),

                    // 🔥 UPDATED ONLY DISPLAY TEXT
                    _buildDrop(
                      "Select Employee",
                      employees,
                      selEmployee,
                      (v) => setState(() => selEmployee = v),
                    ),

                    const SizedBox(height: 10),

                    DropdownButtonFormField<int>(
                      value: selectedMachine,
                      decoration: const InputDecoration(
                        labelText: "Select Machine",
                        border: OutlineInputBorder(),
                      ),
                      items: machines.map((machine) {
                        return DropdownMenuItem<int>(
                          value: machine['id'],
                          child: Text(
                            machine['machine_name'] ?? 'Machine',
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedMachine = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return "Please Select Machine";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 15),

                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.blue.shade100),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blueGrey, size: 18),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Variety & Total Length is set separately from the machine's page using \"Assign Production Batch\".",
                              style: TextStyle(fontSize: 12, color: Colors.blueGrey),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: _handleAssignment,
                      child: const Text("Assign"),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildDrop(
    String label,
    List items,
    int? value,
    Function(int?) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: DropdownButtonFormField<int>(
        value: value,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),

        // 🔥 UPDATED: show name + shift start time
        items: items.map((e) {
          return DropdownMenuItem<int>(
            value: e['id'],
            child: Text(
              "${e['name'] ?? 'Unknown'}"
              "${e['shift_starttime'] != null ? ' (Shift: ${e['shift_starttime']})' : ''}",
            ),
          );
        }).toList(),

        onChanged: onChanged,
      ),
    );
  }
}