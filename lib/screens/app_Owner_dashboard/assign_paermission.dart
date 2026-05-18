import 'package:flutter/material.dart';
import 'package:techstile_frontend/core/services/role_service.dart';
import 'package:techstile_frontend/widgets/drawer.dart';

class AssignPermissionsScreen extends StatefulWidget {
  @override
  _AssignPermissionsScreenState createState() => _AssignPermissionsScreenState();
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

  _loadData() async {
    var r = await _service.getRoles();
    var p = await _service.getAllPermissions();
    setState(() { roles = r; allPermissions = p; });
  }

  _onRoleChanged(int? id) async {
    setState(() { selectedRoleId = id; selectedPerms = []; });
    if (id != null) {
      var p = await _service.getRolePermissions(id);
      setState(() { selectedPerms = List<int>.from(p); });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: OwnerDrawer(),
      appBar: AppBar(title: Text("Assign Permissions")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // 1. Dropdown to select Role
            DropdownButtonFormField<int>(
              value: selectedRoleId,
              decoration: InputDecoration(labelText: "Select Role", border: OutlineInputBorder()),
              items: roles.map((role) => DropdownMenuItem<int>(
                value: role['id'], child: Text(role['name'].toString().toUpperCase()))
              ).toList(),
              onChanged: _onRoleChanged,
            ),
            SizedBox(height: 20),
            
            // 2. Checkbox List for Permissions
            Expanded(
              child: allPermissions.isEmpty 
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: allPermissions.length,
                    itemBuilder: (context, index) {
                      var perm = allPermissions[index];
                      return CheckboxListTile(
                        title: Text(perm['name']),
                        value: selectedPerms.contains(perm['id']),
                        onChanged: (bool? checked) {
                          setState(() {
                            checked! ? selectedPerms.add(perm['id']) : selectedPerms.remove(perm['id']);
                          });
                        },
                      );
                    },
                  ),
            ),
            
            // 3. Save Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
              onPressed: () async {
                if(selectedRoleId != null) {
                  bool success = await _service.syncPermissions(selectedRoleId!, selectedPerms);
                  if(success) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Updated Successfully!")));
                }
              },
              child: Text("Save Permissions"),
            )
          ],
        ),
      ),
    );
  }
}