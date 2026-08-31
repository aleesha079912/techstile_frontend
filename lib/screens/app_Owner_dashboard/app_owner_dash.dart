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
import 'package:techstile_frontend/widgets/owner_drawer.dart';

import 'package:techstile_frontend/core/models/factory_model.dart';
import 'package:techstile_frontend/screens/app_Owner_dashboard/factory_owner_dash/factorydashboard.dart';

class OwnerDashboardScreen extends StatefulWidget {
  final int factoryId;

  const OwnerDashboardScreen({super.key, required this.factoryId});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardState();
}

class _OwnerDashboardState extends State<OwnerDashboardScreen> {
  // Variable that tracks current active tab index (0, 1, 2, 3)
  int _currentIndex = 0;

  // Navigation Target List
  final List<Widget> _pages = [
    const _HomeTab(),
    const ManageUsersScreen(),
    NotificationPage(
      drawer: const OwnerDrawer(),
      title: "Owner Notifications",
    ),
    ManagerSettingsScreen(
      roleLabel: "Owner",
      profilePageBuilder: () =>
          OwnerProfileScreen(userId: AuthService.userId ?? 0),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Inject the FactoryController into memory
    Get.put(FactoryController());
    final theme = Theme.of(context);

    return Scaffold(
      drawer: _currentIndex == 0 ? const OwnerDrawer() : null,
      appBar: _currentIndex == 0
          ? AppBar(
              backgroundColor: AppTheme.primary,
              elevation: theme.appBarTheme.elevation,
              leading: Builder(
                builder: (context) => IconButton(
                  icon: Icon(
                    Icons.menu,
                    color: AppTheme.secondary,
                  ),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              title: Text(
                "Owner Dashboard",
                style: TextStyle(
                  color: AppTheme.secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
      backgroundColor: AppTheme.background,
      // Preserve State
      body: IndexedStack(index: _currentIndex, children: _pages),

      // Conditional UI Rendering
      floatingActionButton: _currentIndex == 0 ? _buildFAB(context) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  // Modular UI / Widget Refactoring
  Widget _buildFAB(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primary, AppTheme.primary.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Get.to(() => const AddFactoryScreen()),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add, color: AppTheme.secondary),
              const SizedBox(width: 6),
              Text(
                "Add Factory",
                style: TextStyle(
                  color: AppTheme.secondary,
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
      onTap: (i) => setState(
        () => _currentIndex = i,
      ),
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppTheme.primary,
      selectedItemColor: AppTheme.secondary,
      unselectedItemColor: AppTheme.neutral,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Home"),
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

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FactoryController>();
    final theme = Theme.of(context);

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildStatsRow(context, controller)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Obx(
                () => Text(
                  "${"${controller.factoryList.length} registered"} ${controller.factoryList.length == 1 ? "factory" : "factories"}",
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ),
          ),

          // Reactive List Handling
          Obx(() {
            if (controller.factoryList.isEmpty) {
              return SliverFillRemaining(child: _buildEmptyState(context));
            }

            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final factory = controller.factoryList[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    child: _FactoryCard(
                      factory: factory,
                      index: index,
                      onDelete: () => controller.deleteFactory(
                        factory.id,
                      ),
                    ),
                  );
                },
                childCount: controller.factoryList.length,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, FactoryController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Obx(
        () => Row(
          children: [
            _StatCard(
              label: "Factories",
              value: "${controller.factoryList.length}",
              icon: Icons.factory,
              color: AppTheme.primary,
            ),
            const SizedBox(width: 10),
            _StatCard(
              label: "Cities",
              value:
                  "${controller.factoryList.map((f) => f.city).toSet().length}",
              icon: Icons.location_city,
              color: AppTheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.factory_outlined,
              size: 40,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text("No factories yet", style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

// Reusable Custom Component
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
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.colorScheme.onPrimary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Reusable List Item Component
class _FactoryCard extends StatelessWidget {
  final FactoryModel factory;
  final int index;
  final VoidCallback onDelete;

  const _FactoryCard({
    required this.factory,
    required this.index,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.onPrimary,
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        onTap: () {
          print("CLICKED FACTORY ID: ${factory.id}");
          Get.to(() => FactoryDashboard(factoryId: factory.id.toString()));
        },
        leading: CircleAvatar(
          backgroundColor: AppTheme.primary.withOpacity(0.1),
          child: Text(
            factory.name.isNotEmpty ? factory.name[0].toUpperCase() : "?",
            style: TextStyle(color: AppTheme.primary),
          ),
        ),
        title: Text(
          factory.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          "${factory.city} • ${factory.address}",
          style: theme.textTheme.bodyMedium,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () {
                Get.to(() => const AddFactoryScreen(), arguments: factory);
              },
              icon: const Icon(Icons.edit_outlined),
              color: AppTheme.success,
            ),
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
              color: AppTheme.error,
            ),
          ],
        ),
      ),
    );
  }
}