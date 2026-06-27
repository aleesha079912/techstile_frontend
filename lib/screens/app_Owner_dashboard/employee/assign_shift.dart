import 'package:flutter/material.dart';
import 'package:techstile_frontend/widgets/bottom_nav_bar.dart';
import 'package:techstile_frontend/widgets/factorydrawer.dart';
import '../../../core/services/employee_service.dart';
import '../../../core/utils/theme.dart';

class AssignShiftsScreen extends StatefulWidget {
  final int factoryId;
  final int userId;

  const AssignShiftsScreen({
    super.key,
    required this.factoryId,
    required this.userId,
  });

  @override
  State<AssignShiftsScreen> createState() => _AssignShiftsScreenState();
}

class _AssignShiftsScreenState extends State<AssignShiftsScreen> {
  final service = EmployeeService();

  List data = [];
  bool loading = true;

  // ✅ Sirf isi factory ke employees (dropdown ke liye)
  List<dynamic> employees = [];

  @override
  void initState() {
    super.initState();
    load();
    loadEmployees();
  }

  Future<void> load() async {
    setState(() => loading = true);

    // ✅ Fix: sahi method call — sirf factoryId chahiye
    data = await service.fetchEmployeesByFactory(widget.factoryId);

    setState(() => loading = false);
  }

  // ✅ Fix: ab EmployeeService se hi data aata hai — koi crash nahi
  Future<void> loadEmployees() async {
    try {
      final list = await service.fetchEmployeesByFactory(widget.factoryId);
      setState(() {
        employees = list;
      });
    } catch (e) {
      print("Employee Load Error: $e");
    }
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
  int? selectedEmployeeId;

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
                  // ✅ Fix: value int id hai ab
                  DropdownButtonFormField<int>(
                    value: selectedEmployeeId,
                    decoration: const InputDecoration(
                      labelText: "Select Employee",
                      border: OutlineInputBorder(),
                    ),
                    items: employees.map((emp) {
                      return DropdownMenuItem<int>(
                        value: emp['id'] as int,          // ← employee table id
                        child: Text(emp['name'] ?? 'Unnamed'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedEmployeeId = value;       // ← sirf id store
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
                  if (selectedEmployeeId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please select employee")),
                    );
                    return;
                  }

                  // ✅ Fix: employees list se user_id dhundo
                  final selectedEmp = employees.firstWhere(
                    (e) => e['id'] == selectedEmployeeId,
                  );

                  final body = {
                    "factory_id":      widget.factoryId,
                    "user_id":         selectedEmp['user_id'],  // ← sahi user_id
                    "shift_starttime": startCtrl.text,
                    "shift_endtime":   endCtrl.text,
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
      drawer: FactoryDrawer(factoryId: widget.factoryId, userID: widget.userId),
      appBar: AppBar(title: const Text("Assign Shifts")),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primary,
        onPressed: () => showForm(),
        child: const Icon(Icons.add, color: Colors.white),
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
                          item['name'] ?? "Employee ${item['id']}",
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
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () => delete(item['id']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 3,
        factoryId: widget.factoryId,
      ),
    );
  }
}