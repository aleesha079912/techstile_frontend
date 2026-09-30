import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:techstile_frontend/core/utils/theme.dart';
import 'package:techstile_frontend/core/services/factory_service.dart';
import 'package:techstile_frontend/core/services/auth_service.dart';
import 'package:techstile_frontend/screens/app_Owner_dashboard/add_factories.dart';
import 'package:techstile_frontend/screens/app_Owner_dashboard/manage_user.dart';
import 'package:techstile_frontend/screens/app_Owner_dashboard/owner_profile.dart';
import 'package:techstile_frontend/screens/man_dashboard/notification.dart';
import 'package:techstile_frontend/screens/man_dashboard/settings/settings.dart';
import 'package:techstile_frontend/screens/app_Owner_dashboard/machine/scan_code.dart';

import 'package:techstile_frontend/core/models/factory_model.dart';
import 'package:techstile_frontend/screens/app_Owner_dashboard/factory_owner_dash/factorydashboard.dart';
import 'package:techstile_frontend/widgets/desktop_admin_shell.dart';
import 'package:techstile_frontend/widgets/owner_drawer.dart';

class OwnerDashboardScreen extends StatefulWidget {
  final int factoryId;

  const OwnerDashboardScreen({
    super.key,
    required this.factoryId,
  });

  @override
  State<OwnerDashboardScreen> createState() =>
      _OwnerDashboardState();
}

class _OwnerDashboardState extends State<OwnerDashboardScreen> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    _pages = [
      const _HomeTab(),

      const ManageUsersScreen(),

      const NotificationPage(
        title: "Notifications",
      ),

      ManagerSettingsScreen(
        roleLabel: "Owner",
        profilePageBuilder: () => OwnerProfileScreen(
          userId: AuthService.userId ?? 0,
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return DesktopAdminShell(
      currentIndex: _currentIndex,
      onTabSelected: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      floatingActionButton: _currentIndex == 0
          ? _buildFAB(context)
          : null,
      floatingActionButtonLocation:
          FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: _buildBottomNav(context),
      mobileDrawer: const OwnerDrawer(),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
    );
  }

 

  Widget _buildFAB(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primary,
            AppTheme.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Get.to(
            () => const AddFactoryScreen(),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.add,
                color: AppTheme.secondary,
              ),

              const SizedBox(width: 6),

              Text(
                "Add Factory",
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  
  Widget _buildBottomNav(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _currentIndex,

      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },

      type: BottomNavigationBarType.fixed,

      backgroundColor: AppTheme.primary,

      selectedItemColor: AppTheme.secondary,

      unselectedItemColor: AppTheme.neutral,

      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: "Home",
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.people_outlined),
          label: "Users",
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.notifications_outlined),
          label: "Alerts",
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined),
          label: "Settings",
        ),
      ],
    );
  }
}



class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  final TextEditingController searchController =
      TextEditingController();

  String query = "";
  String statusFilter = "All";

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }


  void _openScanner(List<FactoryModel> factories) {
    if (factories.isEmpty) {
      Get.snackbar(
        "No Factories",
        "Add a factory first",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(
              bottom: 12,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),

                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.neutral,
                    borderRadius:
                        BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 16),

                Padding(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Select factory to scan",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                ...factories.map(
                  (factory) {
                    return ListTile(
                      leading: Icon(
                        Icons.factory,
                        color: AppTheme.primary,
                      ),

                      title: Text(
                        factory.name,
                        overflow:
                            TextOverflow.ellipsis,
                      ),

                      onTap: () {
                        Get.back();

                        Get.to(
                          () => ScanQRCodeScreen(
                            factoryId: factory.id,
                          ),
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

 

  List<FactoryModel> _applyFilters(
    List<FactoryModel> factories,
  ) {
      final search = query.trim().toLowerCase();

      return factories.where(
      (factory) {
          return search.isEmpty ||
              factory.name
                  .toLowerCase()
                  .contains(search) ||
              factory.city
                  .toLowerCase()
                  .contains(search) ||
              factory.address
                  .toLowerCase()
                  .contains(search);
        },
      ).toList();
    }

 
  @override
  Widget build(BuildContext context) {
    final controller =
        Get.find<FactoryController>();

    return SafeArea(
      child: Obx(
        () {
          final factories =
              controller.factoryList.toList();

          final filtered =
              _applyFilters(factories);
          final isDesktop = MediaQuery.of(context).size.width >= 850;

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _buildHeader(controller),
              ),

              SliverToBoxAdapter(
                child: _buildStatsRow(controller),
              ),

              SliverToBoxAdapter(
                child: _buildSearchBar(),
              ),

              
              if (filtered.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmptyState(),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    isDesktop ? 20 : 16,
                    isDesktop ? 12 : 2,
                    isDesktop ? 20 : 16,
                    100,
                  ),
                  sliver: isDesktop
                      ? SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 440,
                            mainAxisExtent: 220,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final factory = filtered[index];
                              return _FactoryCard(
                                factory: factory,
                                onDelete: () {
                                  controller.deleteFactory(factory.id);
                                },
                              );
                            },
                            childCount: filtered.length,
                          ),
                        )
                      : SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final factory = filtered[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                child: _FactoryCard(
                                  factory: factory,
                                  onDelete: () {
                                    controller.deleteFactory(factory.id);
                                  },
                                ),
                              );
                            },
                            childCount: filtered.length,
                          ),
                        ),
                ),
            ],
          );
        },
      ),
    );
  }

  

  Widget _buildHeader(
    FactoryController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        20,
        20,
        4,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome back",
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textPrimary
                        .withOpacity(0.55),
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  "My Factories",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          GestureDetector(
            onTap: () {
              _openScanner(
                controller.factoryList.toList(),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius:
                    BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary
                        .withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.qr_code_scanner_rounded,
                color: AppTheme.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

 

  Widget _buildStatsRow(
    FactoryController controller,
  ) {
    final factories =
        controller.factoryList;

    
    final citiesCount =
        factories
            .map(
              (factory) => factory.city,
            )
            .where(
              (city) =>
                  city.trim().isNotEmpty,
            )
            .toSet()
            .length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        4,
      ),
      child: Row(
        children: [
          _StatCard(
            label: "Factories",
            value: "${factories.length}",
            icon: Icons.factory,
            color: AppTheme.primary,
          ),

          const SizedBox(width: 10),

          _StatCard(
            label: "Cities",
            value: "$citiesCount",
            icon: Icons.location_city,
            color: AppTheme.primary,
          ),
        ],
      ),
    );
  }

  
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        0,
      ),
      child: Container(
        decoration: BoxDecoration(
          color:  AppTheme.secondary,
          borderRadius:
              BorderRadius.circular(14),

          border: Border.all(
            color:
                AppTheme.primary.withOpacity(0.28),
            width: 1.2,
          ),

          boxShadow: [
            BoxShadow(
              color:
                  AppTheme.primary.withOpacity(0.07),
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: TextField(
          controller: searchController,

          onChanged: (value) {
            setState(() {
              query = value;
            });
          },

          decoration: InputDecoration(
            hintText: "Search factory or city",

            prefixIcon: Icon(
              Icons.search,
              color: AppTheme.primary,
            ),

            suffixIcon: query.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: AppTheme.primary,
                    ),
                    onPressed: () {
                      searchController.clear();

                      setState(() {
                        query = "";
                      });
                    },
                  )
                : null,

            filled: true,
            fillColor: Colors.transparent,

            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(14),
              borderSide: BorderSide(
                color: AppTheme.primary,
                width: 1.5,
              ),
            ),

            contentPadding:
                const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }

  

  
  Widget _buildEmptyState() {
    final hasSearch =
        query.trim().isNotEmpty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              padding:
                  const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primary
                    .withOpacity(0.08),
                borderRadius:
                    BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.primary
                      .withOpacity(0.2),
                ),
              ),
              child: Icon(
                hasSearch
                    ? Icons.search_off
                    : Icons.factory_outlined,
                size: 40,
                color: AppTheme.primary,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              hasSearch
                  ? "No factories found"
                  : "No factories added yet",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              hasSearch
                  ? "Try another factory name or city."
                  : "Add your first factory to get started.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textPrimary
                    .withOpacity(0.55),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.secondary,

          borderRadius:
              BorderRadius.circular(16),

          border: Border.all(
            color:
                AppTheme.primary.withOpacity(0.35),
            width: 1.2,
          ),

          boxShadow: [
            BoxShadow(
              color:
                  AppTheme.primary.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding:
                  const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: color.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),

            const SizedBox(height: 7),

            Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 2),

            Text(
              label,
              maxLines: 1,
              overflow:
                  TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _FactoryCard extends StatelessWidget {
  final FactoryModel factory;
  final VoidCallback onDelete;

  const _FactoryCard({
    required this.factory,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color:  AppTheme.secondary,

      borderRadius:
          BorderRadius.circular(16),

      child: InkWell(
        borderRadius:
            BorderRadius.circular(16),

        onTap: () {
          Get.to(
            () => FactoryDashboard(
              factoryId:
                  factory.id.toString(),
            ),
          );
        },

        child: Container(
         
          // COMPACT CARD PADDING
    

          padding:
              const EdgeInsets.all(12),

          decoration: BoxDecoration(
            color: Colors.white,

            borderRadius:
                BorderRadius.circular(16),

            

            border: Border.all(
              color:
                  AppTheme.primary.withOpacity(0.28),
              width: 1.1,
            ),

            

            boxShadow: [
              BoxShadow(
                color:
                    AppTheme.primary.withOpacity(0.06),
                blurRadius: 10,
                spreadRadius: 0.5,
                offset: const Offset(0, 3),
              ),
            ],
          ),

          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              
              // FACTORY AVATAR
              

              _buildAvatar(),

              const SizedBox(width: 10),

              
              // FACTORY INFORMATION
            

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                   
                    // NAME + STATUS
                   

                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [
                        Expanded(
                          child: Text(
                            factory.name,

                            maxLines: 1,

                            overflow:
                                TextOverflow.ellipsis,

                            style: TextStyle(
                              fontWeight:
                                  FontWeight.w700,

                              fontSize: 14.5,

                              color:
                                  AppTheme.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    

                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [
                        Icon(
                          Icons
                              .location_on_outlined,

                          size: 15,

                          color: AppTheme.primary
                              .withOpacity(0.7),
                        ),

                        const SizedBox(width: 3),

                        Expanded(
                          child: Text(
                            _locationText(),

                            maxLines: 2,

                            overflow:
                                TextOverflow.ellipsis,

                            style: TextStyle(
                              fontSize: 11.5,

                              height: 1.25,

                              color: AppTheme
                                  .textPrimary
                                  .withOpacity(0.55),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // =================================================
                    // DIVIDER
                  

                    Container(
                      height: 1,
                      color: AppTheme.primary
                          .withOpacity(0.07),
                    ),

                    const SizedBox(height: 7),

                    // =================================================
                    // ACTION BUTTONS
                    // =================================================

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.end,

                      children: [
                        _ActionButton(
                          icon:
                              Icons.edit_outlined,

                          color:
                              AppTheme.info,

                          tooltip: "Edit",

                          onTap: () {
                            Get.to(
                              () =>
                                  const AddFactoryScreen(),
                              arguments: factory,
                            );
                          },
                        ),

                        const SizedBox(width: 6),

                        _ActionButton(
                          icon:
                              Icons.delete_outline,

                          color:
                              AppTheme.error,

                          tooltip: "Delete",

                          onTap: () {
                            _showDeleteDialog(
                              context,
                            );
                          },
                        ),
                      ],
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

  // ==========================================================
  // FACTORY AVATAR
  // ==========================================================

  Widget _buildAvatar() {
    return Stack(
      clipBehavior: Clip.none,

      children: [
        Container(
          width: 46,
          height: 46,

          decoration: BoxDecoration(
            color:
                AppTheme.primary.withOpacity(0.10),

            shape: BoxShape.circle,

            border: Border.all(
              color: AppTheme.primary
                  .withOpacity(0.20),
              width: 1,
            ),
          ),

          child: Center(
            child: Text(
              factory.name.isNotEmpty
                  ? factory.name[0]
                      .toUpperCase()
                  : "?",

              style: TextStyle(
                color: AppTheme.primary,

                fontWeight:
                    FontWeight.w800,

                fontSize: 17,
              ),
            ),
          ),
        ),

        // =================================================
        // ONLINE INDICATOR
        // =================================================

      ],
    );
  }

  // ==========================================================
  // STATUS
  // ==========================================================

 

  // ==========================================================
  // LOCATION
  // ==========================================================

  String _locationText() {
    final city = factory.city.trim();
    final address = factory.address.trim();

    if (city.isEmpty && address.isEmpty) {
      return "No location available";
    }

    if (city.isEmpty) {
      return address;
    }

    if (address.isEmpty) {
      return city;
    }

    return "$city • $address";
  }

  // ==========================================================
  // DELETE DIALOG
  // ==========================================================

  void _showDeleteDialog(
    BuildContext context,
  ) {
    Get.dialog(
      AlertDialog(
        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(18),
        ),

        title: const Text(
          "Delete Factory?",
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),

        content: Text(
          'Are you sure you want to delete "${factory.name}"?',
        ),

        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },

            child: const Text(
              "Cancel",
            ),
          ),

          ElevatedButton(
            style:
                ElevatedButton.styleFrom(
              backgroundColor:
                  AppTheme.error,

              foregroundColor:
                AppTheme.secondary ,

              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(10),
              ),
            ),

            onPressed: () {
              Get.back();

              onDelete();
            },

            child: const Text(
              "Delete",
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ACTION BUTTON
// ============================================================

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,

      child: Material(
        color: color.withOpacity(0.10),

        borderRadius:
            BorderRadius.circular(9),

        child: InkWell(
          borderRadius:
              BorderRadius.circular(9),

          onTap: onTap,

          child: Padding(
            padding:
                const EdgeInsets.all(7),

            child: Icon(
              icon,

              size: 17,

              color: color,
            ),
          ),
        ),
      ),
    );
  }
}