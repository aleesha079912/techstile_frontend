// import 'package:flutter/material.dart';
// import 'package:techstile_frontend/core/services/machine_assignment_service.dart';
// import '../../../../core/utils/theme.dart';

// class AssignMachineScreen extends StatefulWidget {
//   const AssignMachineScreen({super.key});

//   @override
//   State<AssignMachineScreen> createState() => _AssignMachineScreenState();
// }

// class _AssignMachineScreenState extends State<AssignMachineScreen> {
//   final _service = AssignMachineService.instance;

//   List factories = [];
//   List managers = [];
//   List employees = [];
//   List machines = [];

//   int? factoryId;
//   int? managerId;
//   int? employeeId;

//   List<int> selectedMachines = [];

//   bool loading = true;

//   @override
//   void initState() {
//     super.initState();
//     loadAll();
//   }

//   Future<void> loadAll() async {
//     final f = await _service.getFactories();
//     final m = await _service.getManagers();
//     final e = await _service.getEmployees();

//     setState(() {
//       factories = f;
//       managers = m;
//       employees = e;
//       loading = false;
//     });
//   }

//   Future<void> loadMachines(int id) async {
//     final data = await _service.getFactoryMachines(id);

//     setState(() {
//       machines = data;
//       selectedMachines.clear();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Assign Machines")),
//       body: loading
//           ? const Center(child: CircularProgressIndicator())
//           : Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 children: [

//                   // FACTORY
//                   _drop("Factory", factories, factoryId, (v) {
//                     setState(() {
//                       factoryId = v;
//                     });
//                     loadMachines(v!);
//                   }),

//                   // MANAGER
//                   _drop("Manager", managers, managerId, (v) {
//                     setState(() => managerId = v);
//                   }),

//                   // EMPLOYEE
//                   _drop("Employee", employees, employeeId, (v) {
//                     setState(() => employeeId = v);
//                   }),

//                   const SizedBox(height: 10),

//                   // MACHINES
//                   Expanded(
//                     child: ListView(
//                       children: machines.map((m) {
//                         final id = m['id'];

//                         return CheckboxListTile(
//                           title: Text(m['machine_name'] ?? ''),
//                           value: selectedMachines.contains(id),
//                           onChanged: (v) {
//                             setState(() {
//                               if (v == true) {
//                                 selectedMachines.add(id);
//                               } else {
//                                 selectedMachines.remove(id);
//                               }
//                             });
//                           },
//                         );
//                       }).toList(),
//                     ),
//                   ),

//                   ElevatedButton(
//                     onPressed: () async {
//                       await _service.assign(
//                         factoryId: factoryId!,
//                         managerId: managerId!,
//                         employeeId: employeeId!,
//                         machineIds: selectedMachines,
//                       );
//                     },
//                     child: const Text("ASSIGN"),
//                   )
//                 ],
//               ),
//             ),
//     );
//   }

//   Widget _drop(String label, List items, int? value, Function(int?) onChanged) {
//     return DropdownButtonFormField<int>(
//       value: value,
//       decoration: InputDecoration(labelText: label),
//       items: items.map<DropdownMenuItem<int>>((e) {
//         return DropdownMenuItem(
//           value: e['id'],
//           child: Text(e['name'] ?? ''),
//         );
//       }).toList(),
//       onChanged: onChanged,
//     );
//   }
// }