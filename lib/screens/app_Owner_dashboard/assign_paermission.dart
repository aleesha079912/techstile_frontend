import 'package:flutter/material.dart';
import 'package:techstile_frontend/core/services/role_service.dart';
import 'package:techstile_frontend/core/utils/theme.dart';
import 'package:techstile_frontend/widgets/factorydrawer.dart';
import 'package:techstile_frontend/widgets/owner_drawer.dart';

class AssignPermissionsScreen extends StatefulWidget {
  const AssignPermissionsScreen({super.key});

  @override
  State<AssignPermissionsScreen> createState() =>
      _AssignPermissionsScreenState();
}

class _AssignPermissionsScreenState extends State<AssignPermissionsScreen> {
  final RoleService _service = RoleService();

  List<dynamic> roles = [];
  List<dynamic> allPermissions = [];
  List<dynamic> filteredPermissions = [];

  List<int> selectedPerms = [];
  int? selectedRoleId;

  final TextEditingController searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    var r = await _service.getRoles();
    var p = await _service.getAllPermissions();

    setState(() {
      roles = r;
      allPermissions = p;
      filteredPermissions = p;
    });
  }

  void _search(String value) {
    setState(() {
      filteredPermissions = allPermissions
          .where((p) =>
              p['name'].toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }

  Future<void> _onRoleChanged(int? id) async {
    setState(() {
      selectedRoleId = id;
      selectedPerms = [];
    });

    if (id != null) {
      var p = await _service.getRolePermissions(id);

      setState(() {
        selectedPerms = List<int>.from(p);
      });
    }
  }

  void _togglePermission(int id) {
    setState(() {
      if (selectedPerms.contains(id)) {
        selectedPerms.remove(id);
      } else {
        selectedPerms.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const OwnerDrawer(),
      backgroundColor: AppTheme.background,

      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        title: const Text("Assign Permissions",
        style: TextStyle(color: AppTheme.secondary)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: AppTheme.secondary,
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: Column(
        children: [
          /// HEADER CARD
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color:AppTheme.secondary,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                /// ROLE DROPDOWN
                DropdownButtonFormField<int>(
                  value: selectedRoleId,
                  decoration: InputDecoration(
                    labelText: "Select Role",
                    prefixIcon: const Icon(Icons.admin_panel_settings),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: roles.map((role) {
                    return DropdownMenuItem<int>(
                      value: role['id'],
                      child: Text(role['name'].toString()),
                    );
                  }).toList(),
                  onChanged: _onRoleChanged,
                ),

                const SizedBox(height: 10),

                /// SEARCH BOX
                TextField(
                  controller: searchCtrl,
                  onChanged: _search,
                  decoration: InputDecoration(
                    hintText: "Search permissions...",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          /// PERMISSIONS LIST (FIXED SCROLL ISSUE)
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: filteredPermissions.length,
              itemBuilder: (context, index) {
                var perm = filteredPermissions[index];

                final isSelected =
                    selectedPerms.contains(perm['id']);

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    onTap: () => _togglePermission(perm['id']),
                    leading: Icon(
                      isSelected
                          ? Icons.check_circle
                          : Icons.circle_outlined,
                      color: isSelected
                          ? AppTheme.success
                          :AppTheme.neutral,
                    ),
                    title: Text(
                      perm['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: isSelected
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.success.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              "Selected",
                              style: TextStyle(
                                  color: AppTheme.success,
                                  fontSize: 12),
                            ),
                          )
                        : null,
                  ),
                );
              },
            ),
          ),

          /// SAVE BUTTON
          SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text(
                  "Save Permissions",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor:AppTheme.secondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  if (selectedRoleId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Select a role"),
                        backgroundColor: AppTheme.error,
                      ),
                    );
                    return;
                  }

                  if (selectedPerms.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Select permissions"),
                        backgroundColor: AppTheme.error,
                      ),
                    );
                    return;
                  }

                  bool success = await _service.syncPermissions(
                    selectedRoleId!,
                    selectedPerms,
                  );

                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Updated Successfully"),
                        backgroundColor: AppTheme.success,
                      ),
                    );
                  }
                },
              ),
            ),
        ],
      ),
    );
  }
}