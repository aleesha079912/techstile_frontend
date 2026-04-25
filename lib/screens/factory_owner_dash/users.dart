import 'package:flutter/material.dart';
import '../../core/services/users_services.dart';
import 'package:get/get.dart';
import '../../../../widgets/bottom_nav_bar.dart';
class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final service = UsersService();
  List<User> users = [];
  User? selected;

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  void loadUsers() async {
    final res = await service.fetchUsers();
    setState(() {
      users = res;
      selected = res.isNotEmpty ? res[0] : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text("LOOMCONTROL"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
              Get.offAllNamed('/owner-dashboard-screen');
          },
        ),
        actions: const [
          Icon(Icons.notifications_none),
          SizedBox(width: 12),
          CircleAvatar(child: Text("JD")),
          SizedBox(width: 12),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Assign Operator",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 6),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Select a qualified technician"),
            ),

            const SizedBox(height: 16),

            /// Search
            TextField(
              decoration: InputDecoration(
                hintText: "Search by name...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 16),

            /// Users List
            Expanded(
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (_, i) {
                  final u = users[i];
                  final isSelected = selected?.id == u.id;

                  return GestureDetector(
                    onTap: () => setState(() => selected = u),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected
                            ? Border.all(color: Colors.blue, width: 2)
                            : null,
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(radius: 22, child: Text(u.name[0])),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  u.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(u.role),
                              ],
                            ),
                          ),
                          Text(
                            u.status,
                            style: TextStyle(
                              color: u.status == "AVAILABLE"
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            /// Selected Card
            if (selected != null)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          child: Text(selected!.name[0]),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              selected!.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text("ID: ${selected!.id}"),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [Text("SHIFT PROGRESS"), Text("65%")],
                    ),

                    const SizedBox(height: 6),
                    const LinearProgressIndicator(value: 0.65),

                    const SizedBox(height: 16),

                    /// Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E3A8A),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () {},
                        child: const Text("Assign to Machine"),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      // bottomNavigationBar: const BottomNavBar(currentIndex: 3),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 3),
    );
  }
}
