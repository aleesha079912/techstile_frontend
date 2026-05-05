import '../../core/utils/theme.dart';
import 'package:flutter/material.dart';
import '../../core/services/machine_assignment_service.dart';
import '../../../../widgets/drawer.dart';
class MachineAssignmentPage extends StatefulWidget {
  const MachineAssignmentPage({super.key});

  @override
  State<MachineAssignmentPage> createState() => _MachineAssignmentPageState();
}

class _MachineAssignmentPageState extends State<MachineAssignmentPage> {
  final _service = MachineAssignmentService();
  final _lengthCtrl = TextEditingController();
  final _varietyCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  List<dynamic> factories = [], users = [], employees = [], machines = [];
  String? selFactory, selUser, selEmployee, selMachine;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  void _loadAllData() async {
    final data = await _service.getAssignmentFormData();
    setState(() {
      factories = data['factories']!;
      users = data['users']!;
      employees = data['employees']!;
      machines = data['machines']!;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: const OwnerDrawer(), 
      appBar: AppBar(
        title: const Text("Machine Assignment"),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Dropdowns
                    _buildDrop("Select Factory", factories, selFactory, (v) => setState(() => selFactory = v)),
                    _buildDrop("Select User", users, selUser, (v) => setState(() => selUser = v)),
                    _buildDrop("Select Employee", employees, selEmployee, (v) => setState(() => selEmployee = v)),
                    _buildDrop("Select Machine", machines, selMachine, (v) => setState(() => selMachine = v)),

                    const SizedBox(height: 10),

                    // Text Fields
                    _buildTextField(_lengthCtrl, "Enter Length", "Length", TextInputType.number),
                    const SizedBox(height: 15),
                    _buildTextField(_varietyCtrl, "Enter Variety", "Variety", TextInputType.text),

                    const SizedBox(height: 40),

                    // Add Button
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _handleAssignment,
                        child: const Text(
                          "ADD ASSIGNMENT",
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // Common Dropdown Builder
  Widget _buildDrop(String hint, List items, String? value, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        isExpanded: true,
        hint: Text(hint),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        ),
        items: items.map((e) {
          return DropdownMenuItem<String>(
            value: e['id'].toString(),
            child: Text(e['name'] ?? e['machine_id'] ?? "ID: ${e['id']}"),
          );
        }).toList(),
        onChanged: onChanged,
        validator: (v) => v == null ? "Field required" : null,
      ),
    );
  }

  // Common TextField Builder
  Widget _buildTextField(TextEditingController ctrl, String hint, String label, TextInputType type) {
    return TextFormField(
      controller: ctrl,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (v) => v!.isEmpty ? "Enter $label" : null,
    );
  }

  void _handleAssignment() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);

      final body = {
        "factory_id": selFactory,
        "user_id": selUser,
        "employee_id": selEmployee,
        "machine_id": selMachine,
        "total_length": _lengthCtrl.text,
        "variety_type": _varietyCtrl.text,
        // Backend keys agar different hain to yahan change karlein
      };

      final success = await _service.storeProduction(body);

      setState(() => isLoading = false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Machine Assigned Successfully!"), backgroundColor: AppTheme.tertiary),
        );
        _formKey.currentState!.reset();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error storing production!"), backgroundColor: Colors.red),
        );
      }
    }
  }
}