import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:techstile_frontend/core/services/factory_user_services.dart';
import 'package:techstile_frontend/screens/app_Owner_dashboard/employee/employee_profile.dart';
import 'package:techstile_frontend/screens/app_Owner_dashboard/user/factorymanager_profile.dart';
import 'package:techstile_frontend/core/utils/theme.dart';
import 'package:techstile_frontend/widgets/bottom_nav_bar.dart';

class FactoryUsersScreen extends StatefulWidget {
  final int factoryId;

  const FactoryUsersScreen({
    super.key,
    required this.factoryId,
  });

  @override
  State<FactoryUsersScreen> createState() => _FactoryUsersScreenState();
}

class _FactoryUsersScreenState extends State<FactoryUsersScreen> {
  final FactoryUsersService _service = FactoryUsersService.instance;

  bool loading = true;

  List users = [];
  List filteredUsers = [];

  dynamic manager;

  int totalUsers = 0;
  int activeUsers = 0;

  final TextEditingController searchCtrl = TextEditingController();
  bool showActiveOnly = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }

  Future<void> loadData() async {
    try {
      final data =
          await _service.getUsersByFactory(widget.factoryId);

      if (!mounted) return;

      setState(() {
        manager = data['manager'];

        users = List.from(data['data'] ?? []);

        totalUsers = data['total_users'] ?? users.length;

        activeUsers = data['active_users'] ??
            users.where((u) => u['is_active'] == true).length;

        loading = false;

        applyFilter();
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      Get.snackbar(
        "Error",
        "Unable to load factory users",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void applyFilter() {
    final query = searchCtrl.text.trim().toLowerCase();

    setState(() {
      filteredUsers = users.where((u) {
        final name =
            (u['name'] ?? '').toString().toLowerCase();

        final email =
            (u['email'] ?? '').toString().toLowerCase();

        final bool isActive = u['is_active'] == true;

        final matchesSearch =
            name.contains(query) ||
            email.contains(query);

        final matchesActive =
            !showActiveOnly || isActive;

        return matchesSearch && matchesActive;
      }).toList();
    });
  }

  void search(String query) {
    applyFilter();
  }

  Widget infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 13,
            color: AppTheme.primary,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11.5,
                color: AppTheme.neutral,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget statBox(
    String title,
    String value,
    Color color,
    bool selected,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: selected
                ? color.withOpacity(0.22)
                : color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected
                  ? color
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Text(
                value,
                style: TextStyle(
                  color: AppTheme.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  // color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontSize: 10,
                  // color: AppTheme.neutral,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget managerCard() {
    if (manager == null) {
      return const SizedBox();
    }

    return GestureDetector(
      onTap: () {
        final id = manager['id'];

        if (id == null) return;

        Get.to(
          () => ManagerProfileScreen(
            userId: int.parse(id.toString()),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.secondary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.info,
          ),
        ),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 20,
              backgroundColor: AppTheme.primary,
              child: Icon(
                Icons.person,
                color: AppTheme.secondary,
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Manager",
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.neutral,
                    ),
                  ),
                  Text(
                    manager['name'] ?? 'No Manager',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: AppTheme.neutral,
            ),
          ],
        ),
      ),
    );
  }

  Widget userCard(dynamic user) {
    String role = "Unknown";

    if (user['roles'] != null &&
        user['roles'].isNotEmpty) {
      role = user['roles'][0]['name'];
    }

    final bool isEmployee =
        role.toLowerCase() == "employee";
// perform action is active true when employee scan machine
    final bool isActive =
        user['is_active'] == true;

    final String name =
        user['name'] ?? "User";

    final String email =
        user['email'] ?? "--";

    final String phone =
        user['phone_no'] ?? "--";

    final String shiftStart =
        user['shift_starttime'] ?? "--";

    final String shiftEnd =
        user['shift_endtime'] ?? "--";

    return InkWell(
      borderRadius: BorderRadius.circular(12),

      onTap: !isEmployee || user['id'] == null
          ? null
          : () {
              Get.to(
                () => UserProfileScreen(
                  userId: user['id'],
                ),
              );
            },

      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),

        decoration: BoxDecoration(
          
           // ACTIVE EMPLOYEE = FULL CARD GREEN
           
           // Normal employee = normal card
           
          color: isActive
              ? AppTheme.success.withOpacity(0.16)
              : AppTheme.secondary,

          borderRadius: BorderRadius.circular(12),

          border: Border.all(
            color: isActive
                ? AppTheme.success
                : Colors.transparent,
            width: isActive ? 1.5 : 0,
          ),

          boxShadow: [
            BoxShadow(
              color: AppTheme.onsurface.withOpacity(.05),
              blurRadius: 8,
            ),
          ],
        ),

        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 19,

                  backgroundColor: isActive
                      ? AppTheme.success
                      : AppTheme.primary.withOpacity(.15),

                  child: Text(
                    name.isNotEmpty
                        ? name[0].toUpperCase()
                        : "U",

                    style: TextStyle(
                      color: isActive
                          ? AppTheme.secondary
                          : AppTheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                
                 // Green dot for active employee
                 
                if (isActive)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppTheme.success,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.secondary,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),

                      
                       // ACTIVE label
                       
                      if (isActive)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.success,
                            borderRadius:
                                BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "ACTIVE",
                            style: TextStyle(
                              color: AppTheme.secondary,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),

                  infoRow(
                    Icons.email_outlined,
                    email,
                  ),

                  infoRow(
                    Icons.phone_outlined,
                    phone,
                  ),

                  const SizedBox(height: 3),

                  Text(
                    role,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            if (isEmployee)
              const Icon(
                Icons.arrow_forward_ios,
                size: 13,
                color: AppTheme.neutral,
              ),
          ],
        ),
      ),
    );
  }

  Widget emptyUsersWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            showActiveOnly
                ? Icons.person_off_outlined
                : Icons.people_outline,
            size: 50,
            color: AppTheme.neutral,
          ),

          const SizedBox(height: 10),

          Text(
            showActiveOnly
                ? "No active employees"
                : "No users found",
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppTheme.neutral,
            ),
          ),

          if (showActiveOnly)
            const Padding(
              padding: EdgeInsets.only(top: 5),
              child: Text(
                "Employees who scan a machine will appear here.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.neutral,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,

      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppTheme.primary,
elevation: 0,
        

        title: const Text(
          "All Employees",
          style: TextStyle(
            color: AppTheme.secondary,
          ),
        ),
      ),

      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(14),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  const SizedBox(height: 10),

                  /// SEARCH
                  TextField(
                    controller: searchCtrl,
                    onChanged: search,

                    decoration: InputDecoration(
                      hintText: "Search Employees...",
                      prefixIcon:
                          const Icon(Icons.search),

                      filled: true,
                      fillColor: AppTheme.secondary,

                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// STATS / FILTER
                  Row(
                    children: [
                      statBox(
                        "Total Users",
                        "$totalUsers",
                        AppTheme.primary,

                        !showActiveOnly,

                        () {
                          setState(() {
                            showActiveOnly = false;
                            applyFilter();
                          });
                        },
                      ),

                      statBox(
                        "Active Users",
                      
                        "$activeUsers",
                        AppTheme.primary,

                        showActiveOnly,

                        () {
                          setState(() {
                            showActiveOnly = true;
                            applyFilter();
                          });
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  /// MANAGER
                  managerCard(),

                  /// USERS
                  Expanded(
                    child: filteredUsers.isEmpty
                        ? emptyUsersWidget()
                        : ListView.builder(
                            itemCount:
                                filteredUsers.length,

                            itemBuilder:
                                (context, index) {
                              return userCard(
                                filteredUsers[index],
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),

      bottomNavigationBar: CustomBottomNav(
        currentIndex: 3,
        factoryId: widget.factoryId,
      ),
    );
  }
}