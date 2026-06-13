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

  List<dynamic> factories = [];
  List<dynamic> machines = [];
  int? selectedFactory;
  List<int> selectedMachines = [];

  bool loadingFactories = true;
  bool loadingMachines = false;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    _loadFactories();
  }

  Future<void> _loadFactories() async {
    try {
      final data = await _service.getFactories();
      setState(() {
        factories = data;
        loadingFactories = false;
      });
    } catch (e) {
      setState(() {
        loadingFactories = false;
      });
    }
  }

  Future<void> _loadMachines(int factoryId) async {
    setState(() {
      loadingMachines = true;
      machines = [];
      selectedMachines = [];
    });

    final data = await _service.getFactoryMachines(factoryId);


    setState(() {
      machines = data;
      loadingMachines = false;
    });
  }

  Future<void> _assign() async {
    if (selectedFactory == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Select a factory")));
      return;
    }
    if (selectedMachines.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Select at least one machine")));
      return;
    }

    setState(() => saving = true);

    // Some versions of ManageUsersService may not expose a strongly-typed
    // assignMachines method. Use a dynamic invocation to avoid static
    // analysis errors while still calling the underlying implementation if
    // available.
    bool success = await _service.assignMachines(
  userId: widget.userId,
  factoryId: selectedFactory!,
  machineIds: selectedMachines,
);

    setState(() => saving = false);

    if (success && mounted) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Machines Assigned Successfully"),
            backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Title
              const Text("Assign Machines",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text("Select factory then pick machines",
                  style: TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 16),

              // ── Factory Dropdown
              loadingFactories
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<int>(
                      value: selectedFactory,
                      decoration: InputDecoration(
                        labelText: "Select Factory",
                        prefixIcon: const Icon(Icons.factory),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      items: factories.map<DropdownMenuItem<int>>((f) {
                        return DropdownMenuItem<int>(
                          value: f['id'] as int,
                          child: Text(f['name'] ?? "Factory"),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => selectedFactory = value);
                        if (value != null) _loadMachines(value);
                      },
                    ),

              const SizedBox(height: 16),

              // ── Machines
              if (selectedFactory != null) ...[
                const Text("Select Machines",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                loadingMachines
                    ? const Center(child: CircularProgressIndicator())
                    : machines.isEmpty
                        ? Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.grey),
                                SizedBox(width: 8),
                                Text("No machines in this factory",
                                    style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          )
                        : Column(
                            children: machines.map<Widget>((m) {
                              final isChecked =
                                  selectedMachines.contains(m['id'] as int);
                              return Container(
                                margin: const EdgeInsets.only(bottom: 6),
                                decoration: BoxDecoration(
                                  color: isChecked
                                      ? Colors.green.withOpacity(0.08)
                                      : Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isChecked
                                        ? Colors.green
                                        : Colors.grey.shade200,
                                  ),
                                ),
                                child: CheckboxListTile(
                                  title: Text(m['name'] ?? "Machine"),
                                  subtitle: m['model'] != null
                                      ? Text(m['model'],
                                          style: const TextStyle(fontSize: 12))
                                      : null,
                                  secondary: const Icon(
                                      Icons.precision_manufacturing,
                                      color: AppTheme.primary),
                                  value: isChecked,
                                  activeColor: Colors.green,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  onChanged: (val) {
                                    setState(() {
                                      if (val == true) {
                                        selectedMachines.add(m['id'] as int);
                                      } else {
                                        selectedMachines
                                            .remove(m['id'] as int);
                                      }
                                    });
                                  },
                                ),
                              );
                            }).toList(),
                          ),
              ],

              const SizedBox(height: 16),

              // ── Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: saving ? null : _assign,
                      child: saving
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Text("Assign"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}