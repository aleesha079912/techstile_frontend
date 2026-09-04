import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:techstile_frontend/core/services/factory_user_services.dart';
import 'package:techstile_frontend/screens/employee_dashboard/profile.dart';
import 'package:techstile_frontend/screens/man_dashboard/manager_profile.dart';
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
  String? error;

  List users = [];
  List filteredUsers = [];

  dynamic manager;
  String factoryName = 'Factory';

  int totalUsers = 0;
  int activeUsers = 0;

  final TextEditingController searchCtrl = TextEditingController();

  bool showActiveOnly = false;

  // ---------------------------------------------------------------------------
  // Common Shadow
  // ---------------------------------------------------------------------------

  static List<BoxShadow> get _primaryShadow => [
        BoxShadow(
          color: AppTheme.primary.withOpacity(0.14),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
        BoxShadow(
          color: AppTheme.primary.withOpacity(0.06),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ];

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

  // ---------------------------------------------------------------------------
  // LOAD DATA
  // ---------------------------------------------------------------------------

  Future<void> loadData() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final data =
          await _service.getUsersByFactory(widget.factoryId);

      if (!mounted) return;

      final loadedUsers =
          List.from(data['data'] ?? []);

      final loadedManager =
          data['manager'];

      setState(() {
        manager = loadedManager;

        users = loadedUsers;

        totalUsers =
            data['total_users'] ?? loadedUsers.length;

        activeUsers =
            data['active_users'] ??
                loadedUsers.where(
                  (u) => u['is_active'] == true,
                ).length;

        factoryName =
            data['factory']?['name']?.toString() ??
                'Factory';

        loading = false;
      });

      applyFilter();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  // ---------------------------------------------------------------------------
  // SEARCH / FILTER
  // ---------------------------------------------------------------------------

  void applyFilter() {
    final query =
        searchCtrl.text.trim().toLowerCase();

    final result = users.where((u) {
      final name =
          (u['name'] ?? '')
              .toString()
              .toLowerCase();

      final email =
          (u['email'] ?? '')
              .toString()
              .toLowerCase();

      final phone =
          (u['phone_no'] ?? '')
              .toString()
              .toLowerCase();

      final matchesSearch =
          name.contains(query) ||
          email.contains(query) ||
          phone.contains(query);

      final isActive =
          u['is_active'] == true;

      final matchesActive =
          !showActiveOnly || isActive;

      return matchesSearch && matchesActive;
    }).toList();

    if (!mounted) return;

    setState(() {
      filteredUsers = result;
    });
  }

  void search(String query) {
    applyFilter();
  }

  // ---------------------------------------------------------------------------
  // INFO ROW
  // ---------------------------------------------------------------------------

  Widget infoRow(
    IconData icon,
    String text, {
    bool isActive = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 13,
            color: isActive
                ? AppTheme.success
                : AppTheme.primary,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.5,
                color: AppTheme.textneutral,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // STAT BOX
  // ---------------------------------------------------------------------------

  Widget statBox(
    String title,
    String value,
    Color color,
    IconData icon,
    bool selected,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration:
              const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected
                ? color
                : AppTheme.secondary,
            borderRadius:
                BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? color
                  : AppTheme.primary.withOpacity(0.08),
              width: 1.2,
            ),
            boxShadow: _primaryShadow,
          ),
          child: Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: selected
                      ? AppTheme.secondary
                          .withOpacity(0.18)
                      : color.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: selected
                      ? AppTheme.secondary
                      : color,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight:
                            FontWeight.w800,
                        color: selected
                            ? AppTheme.secondary
                            : color,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      overflow:
                          TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight:
                            selected
                                ? FontWeight.w700
                                : FontWeight.w500,
                        color: selected
                            ? AppTheme.secondary
                                .withOpacity(0.9)
                            : AppTheme.textPrimary
                                .withOpacity(0.65),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // MANAGER CARD
  // ---------------------------------------------------------------------------

  Widget managerCard() {
    if (manager == null) {
      return const SizedBox.shrink();
    }

    final managerName =
        manager['name']?.toString() ??
            'Manager';

    final managerEmail =
        manager['email']?.toString() ??
            '--';

    final managerPhone =
        manager['phone_no']?.toString() ??
            '--';

    final managerId =
        manager['id'];

    return InkWell(
      borderRadius:
          BorderRadius.circular(16),
      onTap: managerId == null
          ? null
          : () {
              Get.to(
                () => ManagerProfileScreen(
                  userId: int.parse(
                    managerId.toString(),
                  ),
                ),
              );
            },
      child: Container(
        margin:
            const EdgeInsets.only(bottom: 12),
        padding:
            const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.secondary,
          borderRadius:
              BorderRadius.circular(16),
          border: Border.all(
            color:
                AppTheme.primary.withOpacity(0.10),
            width: 1,
          ),
          boxShadow: _primaryShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color:
                    AppTheme.primary
                        .withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.manage_accounts_rounded,
                color: AppTheme.primary,
                size: 23,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Manager',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppTheme.neutral,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color:
                              AppTheme.primary
                                  .withOpacity(0.08),
                          borderRadius:
                              BorderRadius.circular(
                            20,
                          ),
                        ),
                        child: const Text(
                          'MANAGER',
                          style: TextStyle(
                            color:
                                AppTheme.primary,
                            fontSize: 8,
                            fontWeight:
                                FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 3),

                  Text(
                    managerName,
                    style: const TextStyle(
                      color:
                          AppTheme.primary,
                      fontSize: 15,
                      fontWeight:
                          FontWeight.w800,
                    ),
                    overflow:
                        TextOverflow.ellipsis,
                  ),

                  infoRow(
                    Icons.email_outlined,
                    managerEmail,
                  ),

                  infoRow(
                    Icons.phone_outlined,
                    managerPhone,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 13,
              color: AppTheme.neutral,
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // USER CARD
  // ---------------------------------------------------------------------------

  Widget userCard(dynamic user) {
    String role = 'Unknown';

    if (user['roles'] != null &&
        user['roles'] is List &&
        user['roles'].isNotEmpty) {
      role =
          user['roles'][0]['name']
              ?.toString() ??
              'Unknown';
    }

    final bool isEmployee =
        role.toLowerCase() == 'employee';

    final bool isActive =
        user['is_active'] == true;

    final String name =
        user['name']?.toString() ??
            'User';

    final String email =
        user['email']?.toString() ??
            '--';

    final String phone =
        user['phone_no']?.toString() ??
            '--';

    return InkWell(
      borderRadius:
          BorderRadius.circular(16),
      onTap: !isEmployee ||
              user['id'] == null
          ? null
          : () {
              Get.to(
                () => UserProfileScreen(
                  userId: user['id'],
                  factoryId:
                      widget.factoryId,
                ),
              );
            },
      child: Container(
        margin:
            const EdgeInsets.only(bottom: 10),
        padding:
            const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.success
                  .withOpacity(0.08)
              : AppTheme.secondary,
          borderRadius:
              BorderRadius.circular(16),
          border: Border.all(
            color: isActive
                ? AppTheme.success
                    .withOpacity(0.35)
                : AppTheme.primary
                    .withOpacity(0.08),
            width: 1,
          ),
          boxShadow: _primaryShadow,
        ),
        child: Row(
          children: [
            // Avatar
            Stack(
              children: [
                CircleAvatar(
                  radius: 21,
                  backgroundColor:
                      isActive
                          ? AppTheme.success
                          : AppTheme.primary,
                  child: Text(
                    name.isNotEmpty
                        ? name[0]
                            .toUpperCase()
                        : 'U',
                    style:
                        const TextStyle(
                      color:
                          AppTheme.secondary,
                      fontWeight:
                          FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),

                if (isActive)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 11,
                      height: 11,
                      decoration:
                          BoxDecoration(
                        color:
                            AppTheme.success,
                        shape:
                            BoxShape.circle,
                        border:
                            Border.all(
                          color:
                              AppTheme.secondary,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(width: 12),

            // User information
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
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight:
                                FontWeight.w800,
                            color: isActive
                                ? AppTheme
                                    .success
                                : AppTheme
                                    .primary,
                          ),
                          overflow:
                              TextOverflow
                                  .ellipsis,
                        ),
                      ),

                      if (isActive)
                        Container(
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration:
                              BoxDecoration(
                            color:
                                AppTheme.success,
                            borderRadius:
                                BorderRadius
                                    .circular(
                              20,
                            ),
                          ),
                          child:
                              const Text(
                            'ACTIVE',
                            style: TextStyle(
                              color:
                                  AppTheme
                                      .secondary,
                              fontSize: 8,
                              fontWeight:
                                  FontWeight
                                      .w800,
                            ),
                          ),
                        ),
                    ],
                  ),

                  infoRow(
                    Icons.email_outlined,
                    email,
                    isActive: isActive,
                  ),

                  infoRow(
                    Icons.phone_outlined,
                    phone,
                    isActive: isActive,
                  ),

                  const SizedBox(height: 6),

                  // Role chip
                  Container(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration:
                        BoxDecoration(
                      color: (isActive
                              ? AppTheme
                                  .success
                              : AppTheme
                                  .primary)
                          .withOpacity(0.10),
                      borderRadius:
                          BorderRadius.circular(
                        20,
                      ),
                    ),
                    child: Row(
                      mainAxisSize:
                          MainAxisSize.min,
                      children: [
                        Icon(
                          isEmployee
                              ? Icons
                                  .engineering_outlined
                              : Icons
                                  .badge_outlined,
                          size: 11,
                          color: isActive
                              ? AppTheme
                                  .success
                              : AppTheme
                                  .primary,
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        Text(
                          role,
                          style: TextStyle(
                            fontSize: 10.5,
                            color: isActive
                                ? AppTheme
                                    .success
                                : AppTheme
                                    .primary,
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            if (isEmployee)
              const Padding(
                padding:
                    EdgeInsets.only(left: 8),
                child: Icon(
                  Icons
                      .arrow_forward_ios_rounded,
                  size: 13,
                  color:
                      AppTheme.neutral,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // EMPTY VIEW
  // ---------------------------------------------------------------------------

  Widget emptyUsersWidget() {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(24),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Icon(
              showActiveOnly
                  ? Icons.person_off_outlined
                  : Icons.people_outline_rounded,
              size: 50,
              color: AppTheme.neutral,
            ),

            const SizedBox(height: 10),

            Text(
              showActiveOnly
                  ? 'No active users'
                  : 'No users found',
              style:
                  const TextStyle(
                fontSize: 15,
                fontWeight:
                    FontWeight.w700,
                color:
                    AppTheme.neutral,
              ),
            ),

            if (showActiveOnly) ...[
              const SizedBox(height: 5),
              const Text(
                'Employees who scan a machine will appear here.',
                textAlign:
                    TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color:
                      AppTheme.neutral,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ERROR VIEW
  // ---------------------------------------------------------------------------

  Widget errorView() {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(24),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: AppTheme.error,
            ),

            const SizedBox(height: 12),

            Text(
              error ??
                  'Something went wrong',
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                color:
                    AppTheme.textSecondary,
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: loadData,
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    AppTheme.primary,
                foregroundColor:
                    AppTheme.secondary,
              ),
              child:
                  const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // APP BAR
  // ---------------------------------------------------------------------------

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor:
          AppTheme.secondary,
      elevation: 0,

      titleSpacing: 16,

      title: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'All Users',
            style: TextStyle(
              color: AppTheme.primary,
              fontWeight:
                  FontWeight.w800,
              fontSize: 18,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            loading
                ? 'Loading...'
                : factoryName,
            style: TextStyle(
              color: AppTheme.textPrimary
                  .withOpacity(0.60),
              fontSize: 11.5,
              fontWeight:
                  FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          AppTheme.background,

      appBar: _buildAppBar(),

      body: loading
          ? const Center(
              child:
                  CircularProgressIndicator(
                color:
                    AppTheme.primary,
              ),
            )
          : error != null
              ? errorView()
              : RefreshIndicator(
                  color:
                      AppTheme.primary,
                  onRefresh: loadData,
                  child:
                      SingleChildScrollView(
                    physics:
                        const AlwaysScrollableScrollPhysics(),
                    padding:
                        const EdgeInsets.fromLTRB(
                      16,
                      16,
                      16,
                      32,
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        // ---------------------------------------------------
                        // HEADER
                        // ---------------------------------------------------

                        Row(
                          children: [
                            const Expanded(
                              child:
                                  _SectionLabel(
                                text:
                                    'Factory Users',
                              ),
                            ),

                            Container(
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal: 9,
                                vertical: 5,
                              ),
                              decoration:
                                  BoxDecoration(
                                color:
                                    AppTheme
                                        .primary
                                        .withOpacity(
                                            0.08),
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  20,
                                ),
                              ),
                              child: Text(
                                '$totalUsers Users',
                                style:
                                    const TextStyle(
                                  color:
                                      AppTheme
                                          .primary,
                                  fontSize: 10,
                                  fontWeight:
                                      FontWeight
                                          .w700,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // ---------------------------------------------------
                        // MANAGER
                        // ---------------------------------------------------

                        managerCard(),

                        // ---------------------------------------------------
                        // TOTAL / ACTIVE
                        // ---------------------------------------------------

                        Row(
                          children: [
                            statBox(
                              'Total Users',
                              '$totalUsers',
                              AppTheme.primary,
                              Icons.people_alt_rounded,
                              !showActiveOnly,
                              () {
                                setState(() {
                                  showActiveOnly =
                                      false;
                                });
                                applyFilter();
                              },
                            ),

                            const SizedBox(
                              width: 12,
                            ),

                            statBox(
                              'Active Users',
                              '$activeUsers',
                              AppTheme.success,
                              Icons.bolt_rounded,
                              showActiveOnly,
                              () {
                                setState(() {
                                  showActiveOnly =
                                      true;
                                });
                                applyFilter();
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        // ---------------------------------------------------
                        // SEARCH
                        // ---------------------------------------------------

                        TextField(
                          controller:
                              searchCtrl,
                          onChanged: search,
                          decoration:
                              InputDecoration(
                            hintText:
                                'Search users...',
                            hintStyle:
                                TextStyle(
                              color: AppTheme
                                  .textPrimary
                                  .withOpacity(
                                      0.45),
                              fontSize: 13,
                            ),
                            prefixIcon:
                                const Icon(
                              Icons
                                  .search_rounded,
                              color:
                                  AppTheme
                                      .primary,
                            ),
                            filled: true,
                            fillColor:
                                AppTheme
                                    .secondary,
                            contentPadding:
                                const EdgeInsets
                                    .symmetric(
                              vertical: 14,
                            ),
                            border:
                                OutlineInputBorder(
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                14,
                              ),
                              borderSide:
                                  BorderSide(
                                color: AppTheme
                                    .primary
                                    .withOpacity(
                                        0.08),
                              ),
                            ),
                            enabledBorder:
                                OutlineInputBorder(
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                14,
                              ),
                              borderSide:
                                  BorderSide(
                                color: AppTheme
                                    .primary
                                    .withOpacity(
                                        0.08),
                              ),
                            ),
                            focusedBorder:
                                OutlineInputBorder(
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                14,
                              ),
                              borderSide:
                                  BorderSide(
                                color: AppTheme
                                    .primary
                                    .withOpacity(
                                        0.35),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ---------------------------------------------------
                        // USERS
                        // ---------------------------------------------------

                        if (filteredUsers
                            .isEmpty)
                          SizedBox(
                            height: 260,
                            child:
                                emptyUsersWidget(),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics:
                                const NeverScrollableScrollPhysics(),
                            itemCount:
                                filteredUsers
                                    .length,
                            itemBuilder:
                                (context,
                                    index) {
                              return userCard(
                                filteredUsers[
                                    index],
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),

      bottomNavigationBar:
          CustomBottomNav(
        currentIndex: 3,
        factoryId:
            widget.factoryId,
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// SECTION LABEL
// -----------------------------------------------------------------------------

class _SectionLabel
    extends StatelessWidget {
  final String text;

  const _SectionLabel({
    required this.text,
  });

  @override
  Widget build(
      BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 17,
          decoration:
              BoxDecoration(
            color:
                AppTheme.success,
            borderRadius:
                BorderRadius.circular(
              2,
            ),
          ),
        ),

        const SizedBox(width: 8),

        Text(
          text,
          style:
              const TextStyle(
            color:
                AppTheme.textPrimary,
            fontWeight:
                FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}