import 'package:flutter/material.dart';
import 'package:techstile_frontend/core/services/factory_user_services.dart';
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

  List<dynamic> employees = [];

  @override
  void initState() {
    super.initState();
    load();
    loadEmployees();
  }

  Future<void> load() async {
    setState(() => loading = true);

    data = await service.fetchEmployeesByFactory(
      widget.factoryId,
      widget.userId,
    );

    setState(() => loading = false);
  }

  Future<void> loadEmployees() async {
    try {
      final data = await FactoryUsersService.instance
          .getUsersByFactory(widget.factoryId);

      final users = data['data'] ?? [];

      setState(() {
        employees = users.where((user) {
          if (user['roles'] == null) return false;

          return user['roles'].any((role) =>
              role['name']
                  .toString()
                  .toLowerCase() ==
              'employee');
        }).toList();
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
    final startCtrl =
        TextEditingController(text: item?['shift_starttime'] ?? '');

    final endCtrl =
        TextEditingController(text: item?['shift_endtime'] ?? '');

    dynamic selectedEmployee;

    if (item != null) {
  try {
    selectedEmployee = employees.firstWhere(
      (e) =>
          e['id'].toString() ==
          item['employee_id'].toString(),
    );
  } catch (_) {}
}

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                item == null
                    ? "Add Employee"
                    : "Update Employee",
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<dynamic>(
                      value: selectedEmployee,
                      decoration: const InputDecoration(
                        labelText: "Select Employee",
                        border: OutlineInputBorder(),
                      ),
                      items: employees.map((emp) {
                        return DropdownMenuItem<dynamic>(
                          value: emp,
                          child: Text(emp['name']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedEmployee = value;
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
                    final body = {
                      "employee_id": selectedEmployee['id'],
                      "shift_starttime": startCtrl.text,
                      "shift_endtime": endCtrl.text,
                      "timestamp":
                          DateTime.now().toIso8601String(),
                    };

                    bool ok;

                    if (selectedEmployee == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please select employee"),
                        ),
                      );
                      return;
                    }

                    if (item == null) {
                      ok = await service.addEmployee(body);
                    } else {
                      ok = await service.updateEmployee(
                        item['id'],
                        body,
                      );
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
      appBar: AppBar(
        title: const Text("Assign Shifts"),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primary,
        onPressed: () => showForm(),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, i) {
                final item = data[i];

                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(
                      item['employee_name'] ??
                          "Employee ${item['employee_id']}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                    ),
                    subtitle: Text(
                      "Shift: ${item['shift_starttime']} - ${item['shift_endtime']}",
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.edit_outlined,
                            color: AppTheme.primary,
                          ),
                          onPressed: () =>
                              showForm(item: item),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          onPressed: () =>
                              delete(item['id']),
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