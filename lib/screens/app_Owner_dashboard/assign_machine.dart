import 'package:flutter/material.dart';
import 'package:techstile_frontend/core/services/manage_users_service.dart';
import 'package:techstile_frontend/core/utils/theme.dart';

class AssignMachinePopup extends StatefulWidget {
  final int userId;
  final String role;

  const AssignMachinePopup({
    super.key,
    required this.userId,
    required this.role,
  });

  @override
  State<AssignMachinePopup> createState() => _AssignMachinePopupState();
}

class _AssignMachinePopupState extends State<AssignMachinePopup> {
  final _service = ManageUsersService.instance;

  List factories = [];
  List machines = [];

  int? selectedFactory;
  List<int> selectedMachines = [];

  bool loadingMachines = false;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    _loadFactories();
  }

  Future<void> _loadFactories() async {
    // use dynamic calls to avoid static type errors if service method names differ
    final res = await (_service as dynamic).getFactories(); // assume API
    setState(() {
      factories = res;
    });
  }

  Future<void> _loadMachines(int factoryId) async {
    setState(() {
      loadingMachines = true;
      machines = [];
      selectedMachines = [];
    });

    final res = await (_service as dynamic).getFactoryMachines(factoryId); // filtered API

    setState(() {
      machines = res;
      loadingMachines = false;
    });
  }

  Future<void> _assign() async {
    if (selectedFactory == null || selectedMachines.isEmpty) return;

    setState(() => saving = true);

    bool success = await (_service as dynamic).assignFactoryAndMachines(
      userId: widget.userId,
      factoryId: selectedFactory!,
      machineIds: selectedMachines,
      role: widget.role,
    );

    setState(() => saving = false);

    if (success) {
      Navigator.pop(context, true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Assigned Successfully"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            const Text(
              "Assign Machine & Factory",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            /// FACTORY DROPDOWN
            DropdownButtonFormField<int>(
              value: selectedFactory,
              decoration: const InputDecoration(
                labelText: "Select Factory",
                border: OutlineInputBorder(),
              ),
              items: factories.map<DropdownMenuItem<int>>((f) {
                return DropdownMenuItem<int>(
                  value: f['id'],
                  child: Text(f['name']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedFactory = value;
                });

                if (value != null) {
                  _loadMachines(value);
                }
              },
            ),

            const SizedBox(height: 15),

            /// MACHINES LIST
            loadingMachines
                ? const CircularProgressIndicator()
                : Column(
                    children: machines.map<Widget>((m) {
                      return CheckboxListTile(
                        title: Text(m['name']),
                        value: selectedMachines.contains(m['id']),
                        onChanged: (val) {
                          setState(() {
                            if (val == true) {
                              selectedMachines.add(m['id']);
                            } else {
                              selectedMachines.remove(m['id']);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),

            const SizedBox(height: 15),

            /// BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                ),
                onPressed: saving ? null : _assign,
                child: saving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Assign"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}