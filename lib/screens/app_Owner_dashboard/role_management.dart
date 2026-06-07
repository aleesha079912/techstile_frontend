import 'package:flutter/material.dart';
import 'package:techstile_frontend/core/services/role_service.dart';
import 'package:techstile_frontend/widgets/drawer.dart';
import 'package:techstile_frontend/widgets/bottom_nav_bar.dart';

class RoleManagementScreen extends StatefulWidget {
  @override
  _RoleManagementScreenState createState() => _RoleManagementScreenState();
}

class _RoleManagementScreenState extends State<RoleManagementScreen> {
  final TextEditingController _roleController = TextEditingController();
  final RoleService _roleService = RoleService();
  List<dynamic> roles = [];

  @override
  void initState() {
    super.initState();
    _loadRoles();
  }

  _loadRoles() async {
    var data = await _roleService.getRoles();
    setState(() {
      roles = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: OwnerDrawer(),
      appBar: AppBar(title: const Text("Role Management")),
      body: Row(
        children: [
          //  ADD ROLE FORM
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("+ Add Role",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _roleController,
                    decoration: const InputDecoration(
                        labelText: "Role Name", border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                        onPressed: () async {
                        var result =
                            await _roleService.addRole(_roleController.text);

                        if (result['success']) {
                          _roleController.clear();
                          _loadRoles();

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Role added successfully"),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(result['message']),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                    child: const Text("Save"),
                  )
                ],
              ),
            ),
          ),

          //  LIST VIEW EDIT/DELETE
          Expanded(
            flex: 2,
            child: ListView.builder(
              itemCount: roles.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.verified_user, color: Colors.blue),
                  title: Text(roles[index]['name']),
                  subtitle: Text("Created: ${roles[index]['created_at']}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // EDIT BUTTON
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: Color.fromARGB(255, 96, 139, 107)),
                        onPressed: () => _showEditDialog(roles[index]),
                      ),
                      // DELETE BUTTON
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        onPressed: () => _confirmDelete(roles[index]['id']),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  _showEditDialog(dynamic role) {
    TextEditingController editController =
        TextEditingController(text: role['name']);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Role"),
        content: TextField(
            controller: editController,
            decoration: const InputDecoration(hintText: "New Role Name")),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              bool success = await _roleService.updateRole(
                  role['id'], editController.text);
              if (success) {
                Navigator.pop(context);
                _loadRoles();
              }
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Role?"),
        content: const Text("Are you sure you want to remove this role?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text("No")),
          TextButton(
            onPressed: () async {
              bool success = await _roleService.deleteRole(id);
              if (success) {
                Navigator.pop(context);
                _loadRoles();
              }
            },
            child:
                const Text("Yes, Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}