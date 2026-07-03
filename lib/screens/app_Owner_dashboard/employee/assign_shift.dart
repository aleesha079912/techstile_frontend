import 'package:flutter/material.dart';
import 'package:techstile_frontend/widgets/bottom_nav_bar.dart';
import '../../../core/services/employee_service.dart';
import '../../../core/utils/theme.dart';

class AssignShiftsScreen extends StatefulWidget {
  final int? factoryId;

  const AssignShiftsScreen({super.key, this.factoryId});

  @override
  State<AssignShiftsScreen> createState() => _AssignShiftsScreenState();
}

class _AssignShiftsScreenState extends State<AssignShiftsScreen> {
  final service = EmployeeService();

  List data = [];
  bool loading = true;

  // ✅ Sirf isi factory ke employees (dropdown ke liye)
  List factories = [];
  List employees = [];

  @override
  void initState() {
    super.initState();
    load();
    loadDropdowns();
  }

  Future<void> loadDropdowns() async {
    factories = await service.fetchFactories();
    employees = await service.fetchUsers();

    setState(() {});
  }

  Future<void> load() async {
  setState(() => loading = true);

  data = await service.fetchEmployees();

  setState(() => loading = false);
}

  Future<void> _pickTime(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      final hour = picked.hour.toString().padLeft(2, '0');
      final minute = picked.minute.toString().padLeft(2, '0');
      controller.text = "$hour:$minute";
    }
  }

  // ───────────────── ADD / EDIT ─────────────────

  void showForm({dynamic item}) {
  final startCtrl = TextEditingController(text: item?['shift_starttime'] ?? '');
  final endCtrl   = TextEditingController(text: item?['shift_endtime'] ?? '');

  // ✅ Fix: Map ki jagah sirf id store karo
  int? selectedFactory = item?['factory_id'];
  int? selectedEmployeeId = item?['user_id'];;

  if (item != null) {
    selectedEmployeeId = item['user_id'];
  }

  showDialog(
    context: context,
    builder: (_) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(item == null ? "Add Employee" : "Update Employee"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int>(
                    value: selectedFactory,
                    decoration: const InputDecoration(
                      labelText: "Select Factory",
                      border: OutlineInputBorder(),
                    ),
                    items: factories.map((factory) {
                      return DropdownMenuItem<int>(
                        value: factory['id'],
                        child: Text(factory['name']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedFactory = value;
                      });
                    },
                  ),

                  const SizedBox(height: 15),
                  DropdownButtonFormField<int>(
                    value: selectedEmployeeId,
                    decoration: const InputDecoration(
                      labelText: "Select Employee",
                      border: OutlineInputBorder(),
                    ),
                    items: employees.map((user) {
                      return DropdownMenuItem<int>(
                        value: user['id'],
                        child: Text(user['name']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedEmployeeId = value;
                      });
                    },
                  ),

                  const SizedBox(height: 15),
                  TextField(
                    controller: startCtrl,
                    readOnly: true,
                    onTap: () => _pickTime(context, startCtrl),
                    decoration: const InputDecoration(
                      labelText: "Shift Start Time",
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.access_time),
                    ),
                  ),

                  const SizedBox(height: 15),

                  TextField(
                    controller: endCtrl,
                    readOnly: true,
                    onTap: () => _pickTime(context, endCtrl),
                    decoration: const InputDecoration(
                      labelText: "Shift End Time",
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.access_time),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () async {
                  // ✅ Fix: employees list se user_id dhundo
                  if (selectedFactory == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please select factory")),
                    );
                    return;
                  }

                  if (selectedEmployeeId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please select employee")),
                    );
                    return;
                  }

                  final body = {
                    "factory_id": selectedFactory,
                    "user_id": selectedEmployeeId,
                    "shift_starttime": startCtrl.text,
                    "shift_endtime": endCtrl.text,
                  };

                  print("Body: $body"); // debug

                  bool ok;
                  if (item == null) {
                    ok = await service.addEmployee(body);
                  } else {
                    ok = await service.updateEmployee(item['id'], body);
                  }

                  if (ok) {
                    Navigator.pop(context);
                    load();
                  }
                },
                child: const Text("Save"),
              ),
            ],
          );
        },
      );
    },
  );
}

  // ───────────────── DELETE ─────────────────

  Future<void> delete(int id) async {
    await service.deleteEmployee(id);
    load();
  }

  // ───────────────── UI ─────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppTheme.secondary,
            size: 18,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "TECHSTILE",
          style: TextStyle(
            color: AppTheme.secondary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : data.isEmpty
              ? const Center(child: Text("No shifts assigned yet"))
              : ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, i) {
                    final item = data[i];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        title: Text(
                         item['user']?['name'] ?? "Employee ${item['id']}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary,
                          ),
                        ),
                        subtitle: Text(
                          "Shift: ${item['shift_starttime'] ?? '--'} - ${item['shift_endtime'] ?? '--'}",
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, color: AppTheme.primary),
                              onPressed: () => showForm(item: item),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: AppTheme.error),
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