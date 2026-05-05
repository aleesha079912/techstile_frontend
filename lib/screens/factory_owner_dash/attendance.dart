import 'package:flutter/material.dart';
import '../../core/services/attendance_service.dart';
import '../../core/utils/theme.dart';
import '../../../../widgets/drawer.dart';
class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final service = AttendanceService();
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
    data = await service.fetchAttendance();
    loading = false;
    setState(() {});
  }

  // 🔹 Add/Edit Dialog
  void showForm({dynamic item}) {
    final empCtrl = TextEditingController(text: item?['employee_id']?.toString() ?? '');
    final typeCtrl = TextEditingController(text: item?['type'] ?? '');
    final prodCtrl = TextEditingController(text: item?['production_id']?.toString() ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(item == null ? "Add Attendance" : "Update Attendance"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: empCtrl, decoration: const InputDecoration(labelText: "Employee ID")),
            TextField(controller: typeCtrl, decoration: const InputDecoration(labelText: "Type (Present/Absent)")),
            TextField(controller: prodCtrl, decoration: const InputDecoration(labelText: "Production ID")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),

          ElevatedButton(
            onPressed: () async {
              final body = {
                "employee_id": int.parse(empCtrl.text),
                "type": typeCtrl.text,
                "production_id": int.parse(prodCtrl.text),
                "timestamp": DateTime.now().toString(), // ✅ auto time
              };

              bool ok = item == null
                  ? await service.addAttendance(body)
                  : await service.updateAttendance(item['id'], body);

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

  // 🔹 Delete
  void delete(int id) async {
    await service.deleteAttendance(id);
    load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: const OwnerDrawer(), 
      appBar: AppBar(title: const Text("Attendance")),
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
                      "Employee: ${item['employee_id']}",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary),
                    ),
                    subtitle: Text(
                        "Type: ${item['type']} \nTime: ${item['timestamp']}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, color: AppTheme.tertiary),
                          onPressed: () => showForm(item: item),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outlined, color: Colors.red),
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