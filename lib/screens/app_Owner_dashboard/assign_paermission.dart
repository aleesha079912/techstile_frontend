import 'package:flutter/material.dart';
import 'package:techstile_frontend/core/services/role_service.dart';
import 'package:techstile_frontend/core/utils/theme.dart';
import 'package:techstile_frontend/widgets/drawer.dart';

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
  List<int> selectedPerms = [];
  int? selectedRoleId;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: OwnerDrawer(),
      backgroundColor: AppTheme.secondary,

      appBar: AppBar(
        title: const Text(
          "Assign Permissions",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            /// ROLE DROPDOWN
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: DropdownButtonFormField<int>(
                value: selectedRoleId,
                decoration: InputDecoration(
                  labelText: "Select Role",
                  labelStyle: const TextStyle(
                    color: AppTheme.primary,
                  ),
                  prefixIcon: const Icon(
                    Icons.admin_panel_settings,
                    color: AppTheme.primary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: roles.map((role) {
                  return DropdownMenuItem<int>(
                    value: role['id'],
                    child: Text(
                      role['name'].toString().toUpperCase(),
                    ),
                  );
                }).toList(),
                onChanged: _onRoleChanged,
              ),
            ),

            const SizedBox(height: 20),

            /// PERMISSION TITLE
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Permissions",
                style: TextStyle(
                  color: AppTheme.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 10),

            /// PERMISSIONS LIST
            Expanded(
              child: allPermissions.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color:
                                AppTheme.primary.withOpacity(0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListView.builder(
                        itemCount: allPermissions.length,
                        itemBuilder: (context, index) {
                          var perm = allPermissions[index];

                          return CheckboxListTile(
                            activeColor: AppTheme.tertiary,
                            title: Text(
                              perm['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            value:
                                selectedPerms.contains(perm['id']),
                            onChanged: (bool? checked) {
                              setState(() {
                                if (checked == true) {
                                  selectedPerms.add(perm['id']);
                                } else {
                                  selectedPerms.remove(perm['id']);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
            ),

            const SizedBox(height: 20),

            /// SAVE BUTTON
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text(
                  "Save Permissions",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  if (selectedRoleId != null) {
                    bool success =
                        await _service.syncPermissions(
                      selectedRoleId!,
                      selectedPerms,
                    );

                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppTheme.tertiary,
                          content: const Text(
                            "Permissions Updated Successfully!",
                          ),
                        ),
                      );
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}