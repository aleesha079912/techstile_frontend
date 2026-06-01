import 'package:flutter/material.dart';
import '../../core/services/employee_service.dart';
import '../../core/utils/theme.dart';
import '../../../../widgets/drawer.dart';
class EmployeeScreen extends StatefulWidget {
  const EmployeeScreen({super.key});

  @override
  State<EmployeeScreen> createState() => _EmployeeScreenState();
}

class _EmployeeScreenState extends State<EmployeeScreen> {
  final service = EmployeeService();
  List data = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  void load() async {
    loading = true;
    setState(() {});
    data = await service.fetchEmployees();
    loading = false;
    setState(() {});
  }

  // 🔹 ADD / EDIT FORM
  void showForm({dynamic item}) {
    final empIdCtrl = TextEditingController(text: item?['employee_id'] ?? '');
    final startCtrl = TextEditingController(text: item?['shift_starttime'] ?? '');
    final endCtrl = TextEditingController(text: item?['shift_endtime'] ?? '');
    final userCtrl = TextEditingController(text: item?['user_id']?.toString() ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(item == null ? "Add Employee" : "Update Employee"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: empIdCtrl, decoration: const InputDecoration(labelText: "Employee ID")),
              TextField(controller: startCtrl, decoration: const InputDecoration(labelText: "Shift Start (09:00)")),
              TextField(controller: endCtrl, decoration: const InputDecoration(labelText: "Shift End (18:00)")),
              TextField(controller: userCtrl, decoration: const InputDecoration(labelText: "User ID")),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),

          ElevatedButton(
            onPressed: () async {
              final body = {
                "employee_id": empIdCtrl.text,
                "shift_starttime": startCtrl.text,
                "shift_endtime": endCtrl.text,
                "user_id": int.parse(userCtrl.text),
                "timestamp": DateTime.now().toString(),
              };

              bool ok = item == null
                  ? await service.addEmployee(body)
                  : await service.updateEmployee(item['id'], body);

              if (ok) {
                Navigator.pop(context);
                load();
              }
            },
            child: const Text("Save"),
          )
        ],
      ),
    );
  }

  // 🔹 DELETE
  void delete(int id) async {
    await service.deleteEmployee(id);
    load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const OwnerDrawer(), 
      appBar: AppBar(title: const Text("Employees")),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primary,
        onPressed: () => showForm(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, i) {
                final item = data[i];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(
                      "Emp: ${item['employee_id']}",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary),
                    ),
                    subtitle: Text(
                      "Shift: ${item['shift_starttime']} - ${item['shift_endtime']}",
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, color: AppTheme.tertiary),
                          onPressed: () => showForm(item: item),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => delete(item['id']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}