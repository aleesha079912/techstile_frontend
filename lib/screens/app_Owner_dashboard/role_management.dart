import 'package:flutter/material.dart';
import 'package:techstile_frontend/core/services/role_service.dart';
import 'package:techstile_frontend/widgets/drawer.dart';

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
      backgroundColor: const Color(0xffF5F7FB),

      appBar: AppBar(
  title: const Text("Role Management"),
  centerTitle: true,
  elevation: 0,

  leading: IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () {
      Navigator.pop(context);
    },
  ),
),

      body: SafeArea(
        child: Column(
          children: [

            /// HEADER CARD
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                "Manage system roles (Owner only)",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ),

            /// ADD ROLE CARD
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text(
                    "+ Add New Role",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// TEXT FIELD
                  TextField(
                    controller: _roleController,
                    decoration: InputDecoration(
                      hintText: "Enter role name",
                      prefixIcon: const Icon(Icons.badge_outlined),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
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
                      child: const Text("Save Role"),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            /// ROLE LIST TITLE
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "All Roles",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            /// ROLE LIST
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: roles.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                        )
                      ],
                    ),
                    child: Row(
                      children: [

                        const Icon(Icons.verified_user,
                            color: Colors.blue),

                        const SizedBox(width: 10),

                        /// ROLE INFO
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                roles[index]['name'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Created: ${roles[index]['created_at']}",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),

                        /// ACTIONS
                        IconButton(
                          icon: const Icon(Icons.edit_outlined,
                              color: Colors.green),
                          onPressed: () => _showEditDialog(roles[index]),
                        ),

                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.red),
                          onPressed: () =>
                              _confirmDelete(roles[index]['id']),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- EDIT DIALOG ----------------
  _showEditDialog(dynamic role) {
    TextEditingController editController =
        TextEditingController(text: role['name']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text("Edit Role"),
        content: TextField(
          controller: editController,
          decoration: const InputDecoration(
            hintText: "New Role Name",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
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

  // ---------------- DELETE ----------------
  _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text("Delete Role?"),
        content: const Text("Are you sure you want to remove this role?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () async {
              bool success = await _roleService.deleteRole(id);
              if (success) {
                Navigator.pop(context);
                _loadRoles();
              }
            },
            child: const Text(
              "Yes, Delete",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}