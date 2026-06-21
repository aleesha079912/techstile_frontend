import 'package:flutter/material.dart';
import 'package:techstile_frontend/core/services/machine_assignment_service.dart';
import 'package:techstile_frontend/widgets/owner_drawer.dart';

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

  Future<void> _handleAssignment() async {
  if (!_formKey.currentState!.validate()) return;

  if (selectedMachine == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Please select a machine"),
      ),
    );
    return;
  }

  final success = await _service.assign(
    userId: selEmployee!,
    managerId: selManager!,
    factoryId: selFactory!,
    machineIds: [selectedMachine!], // single machine
  );

  if (!mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        success ? "Assignment Successful" : "Failed",
      ),
      backgroundColor: success ? Colors.green : Colors.red,
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const OwnerDrawer(),
      appBar: AppBar(title: const Text("Machine Assignment")),
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
                      },
                    ),

                    _buildDrop(
                      "Select Manager",
                      managers,
                      selManager,
                      (v) => setState(() => selManager = v),
                    ),

                    _buildDrop(
                      "Select Employee",
                      employees,
                      selEmployee,
                      (v) => setState(() => selEmployee = v),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      "Select Machines",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),

                   Column(
                    children: machines.map((m) {
                      int id = m['id'];
                      return RadioListTile<int>(
                        value: id,
                        groupValue: selectedMachine,
                        title: Text(
                           m['machine_name'] ?? 'Machine',
                           ),
                           onChanged: (value) {
                            setState(() {
                              selectedMachine = value;
                            });
                         },
                      );
                    }).toList(),
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
        items: items.map((e) {
          return DropdownMenuItem<int>(
            value: e['id'],
            child: Text(e['name'] ?? 'Unknown'),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}