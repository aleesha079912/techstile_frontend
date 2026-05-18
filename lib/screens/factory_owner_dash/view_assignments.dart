import 'package:flutter/material.dart';
import '../../core/services/view_assignment_service.dart';
import 'package:techstile_frontend/widgets/drawer.dart';

class ViewAssignments extends StatefulWidget {
  const ViewAssignments({super.key});

  @override
  State<ViewAssignments> createState() => _ViewAssignmentsState();
}

class _ViewAssignmentsState extends State<ViewAssignments> {
  final ProductionService _service = ProductionService();
  List data = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    final result = await _service.getProductions();
    setState(() {
      data = result;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const OwnerDrawer(),
      appBar: AppBar(title: const Text("View Assignments")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
               // Columns Section
columns: const [
  DataColumn(label: Text("Factory")),
  DataColumn(label: Text("User")),
  DataColumn(label: Text("Employee")),
  DataColumn(label: Text("Machine ID")),
  DataColumn(label: Text("Variety")),
],

// Rows Section (data.map) map loop to convert each item in data list to a DataRow
rows: data.map((item) {
  return DataRow(cells: [
    // 1. Factory Name
    DataCell(Text(item['factory'] != null ? item['factory']['name'].toString() : "N/A")),

    // 2. User Name (Employee ke linked User table se)
    DataCell(Text(
      (item['employee'] != null && item['employee']['user'] != null)
          ? item['employee']['user']['name'].toString()
          : "N/A",
    )),

    // 3. Employee Name (Formatted as "Emp-<employee_id>")
    DataCell(Text("Emp-${item['employee_id']}")),

    // 4. Machine ID / Type
    DataCell(Text(item['machine'] != null ? item['machine']['machine_id'].toString() : "N/A")),

    // 5. Variety
    DataCell(Text(item['variety_type']?.toString() ?? "N/A")),
  ]);
}).toList(),
              ),
            ),
    );
  }
}


