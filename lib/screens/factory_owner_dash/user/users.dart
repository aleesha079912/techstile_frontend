import 'package:flutter/material.dart';
import '../../../core/services/users_services.dart';
import '../../../core/utils/theme.dart'; // Ensure path is correct
import '../../../../widgets/bottom_nav_bar.dart';
import '../../../../widgets/drawer.dart'; // Import your drawer

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

  // Text style helper for consistency
  TextStyle _sora(double size, FontWeight w, Color c) =>
      TextStyle(fontSize: size, fontWeight: w, color: c, fontFamily: 'Sora');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, // From AppTheme (0xFFF3F4F6)
      drawer: const OwnerDrawer(), // Added Drawer
      appBar: AppBar(
        title: Text("TextileOS", style: _sora(18, FontWeight.w700, Colors.white)),
        centerTitle: false,
        actions: const [
          Icon(Icons.notifications_none),
          SizedBox(width: 12),
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.white24,
            child: Text("JD", style: TextStyle(fontSize: 12, color: Colors.white)),
          ),
          SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Assign Operator",
              style: _sora(26, FontWeight.w800, colors.primary),
            ),
            const SizedBox(height: 4),
            Text(
              "Select a qualified technician for the unit",
              style: _sora(14, FontWeight.w400, AppTheme.neutral),
            ),
            const SizedBox(height: 20),

            /// Search Bar
            TextField(
              decoration: InputDecoration(
                hintText: "Search by name...",
                hintStyle: TextStyle(color: AppTheme.neutral.withOpacity(0.6)),
                prefixIcon: Icon(Icons.search, color: colors.primary),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

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
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? colors.primary : Colors.transparent,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: colors.primary.withOpacity(0.1),
                            child: Text(u.name[0], style: TextStyle(color: colors.primary)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(u.name, style: _sora(15, FontWeight.w700, colors.primary)),
                                Text(u.role, style: _sora(12, FontWeight.w400, AppTheme.neutral)),
                              ],
                            ),
                          ),
                          _buildStatusBadge(u.status, colors),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            /// Selected User Action Card
            if (selected != null) _buildSelectedCard(colors),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 3),
    );
  }

  Widget _buildStatusBadge(String status, ColorScheme colors) {
    bool isAvailable = status == "AVAILABLE";
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isAvailable ? colors.secondary.withOpacity(0.1) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: _sora(10, FontWeight.w700, isAvailable ? colors.secondary : Colors.grey),
      ),
    );
  }

  Widget _buildSelectedCard(ColorScheme colors) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, -5))
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: colors.primary,
                child: Text(selected!.name[0], style: const TextStyle(color: Colors.white)),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(selected!.name, style: _sora(16, FontWeight.w700, colors.primary)),
                  Text("ID: ${selected!.id}", style: _sora(12, FontWeight.w400, AppTheme.neutral)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("SHIFT PROGRESS", style: _sora(11, FontWeight.w700, AppTheme.neutral)),
              Text("65%", style: _sora(11, FontWeight.w700, colors.primary)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: 0.65,
              minHeight: 8,
              backgroundColor: colors.primary.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              onPressed: () {},
              child: const Text("Confirm Assignment", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}