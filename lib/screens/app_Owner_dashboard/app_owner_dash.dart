import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:techstile_frontend/core/utils/theme.dart';
import 'package:techstile_frontend/core/services/factory_service.dart';
import 'package:techstile_frontend/screens/app_Owner_dashboard/add_factories.dart';
import 'package:techstile_frontend/screens/app_Owner_dashboard/manage_user.dart';
import 'package:techstile_frontend/screens/app_Owner_dashboard/notification_screen.dart';
import 'package:techstile_frontend/screens/app_Owner_dashboard/setting_screen.dart';
import 'package:techstile_frontend/screens/factory_owner_dash/factory_dashboard.dart';
import 'package:techstile_frontend/core/models/factory_model.dart';
import 'package:techstile_frontend/screens/factory_owner_dash/factorydashboard.dart';
import '../../widgets/factorydrawer.dart';

class OwnerDashboardScreen extends StatefulWidget {
  final int factoryId;

  const OwnerDashboardScreen({
    super.key,
    required this.factoryId,
  });

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardState();
}
class _OwnerDashboardState extends State<OwnerDashboardScreen> {
  //  variable that tracks current active tab index (0, 1, 2, 3)
  int _currentIndex = 0;
  //  Navigation Target List
  final List<Widget> _pages = const [
    _HomeTab(),
    ManageUsersScreen(),
    NotificationScreen(),
    SettingsScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    // inject the FactoryController into memory so that it can be accessed from any child widget of this dashboard without needing to pass it down the widget tree.
    Get.put(FactoryController());
    final theme = Theme.of(context);
    return Scaffold(
      drawer: FactoryDrawer(factoryId: widget.factoryId, userID: widget.factoryId),
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: theme.appBarTheme.elevation,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: theme.appBarTheme.foregroundColor),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          "Owner Dashboard",
          style: TextStyle(
            color: theme.appBarTheme.foregroundColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      // CONCEPT: Preserve State (IndexedStack)
      // `IndexedStack` ka faida yeh hai ke jab aap tabs badalte hain (e.g., Home se Calculator par gaye),
      // toh purani screen ka data/scroll position khoti nahi hai, balkay background mein save rehti hai.
      body: IndexedStack(index: _currentIndex, children: _pages),

      // Conditional UI Rendering
      floatingActionButton: _currentIndex == 0 ? _buildFAB(context) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  // CONCEPT: Modular UI / Widget Refactoring
  Widget _buildFAB(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withOpacity(0.8),
          ],
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
              Icon(Icons.add, color: theme.colorScheme.onPrimary),
              const SizedBox(width: 6),
              Text(
                "Add Factory",
                style: TextStyle(
                  color: theme.colorScheme.onPrimary,
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
    final theme = Theme.of(context);

    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (i) => setState(
        () => _currentIndex = i,
      ), // when Tab change reload (rebuild) the UI with new index.
      type: BottomNavigationBarType.fixed,
      backgroundColor: theme
          .colorScheme
          .onPrimary,
      selectedItemColor: theme.colorScheme.primary, 
      unselectedItemColor: AppTheme.neutral,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Home"),
        BottomNavigationBarItem(
          icon: Icon(Icons.people_outline),
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

                // when the length of the factory list is changed, this text will auto refresh.
                () => Text(
                  "${"${controller.factoryList.length} registered"} ${controller.factoryList.length == 1 ? "factory" : "factories"}",
                  style: theme.textTheme.bodyMedium,
                  ),
              ),
            ),
          ),

          // Reactive List Handling
          Obx(() {
            // Empty State Pattern
            if (controller.factoryList.isEmpty) {
              return SliverFillRemaining(child: _buildEmptyState(context));
            }

            // its only render these items that show on screen and when user scrolls it will render the next items and so on, this is more efficient than ListView.builder in case of large lists.
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
                      ), // Controller method call.
                    ),
                  );
                },
                childCount:
                    controller.factoryList.length, // List total items count.
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, FactoryController controller) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Obx(
        () => Row(
          children: [
            _StatCard(
              label: "Factories",
              value: "${controller.factoryList.length}",
              icon: Icons.factory,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 10),
            _StatCard(
              label: "Cities",
              // Data Manipulation (Mapping & Sets)
              // `map((f) => f.city).toSet().length` mean  count only unique cities 
              value:
                  "${controller.factoryList.map((f) => f.city).toSet().length}",
              icon: Icons.location_city,
              color: theme
                  .colorScheme
                  .secondary, 
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
             color: theme.colorScheme.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.factory_outlined,
              size: 40,
              color: theme.colorScheme.primary,
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

//Reusable List Item Component 
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

          Get.to(
            () => FactoryDashboard(
              factoryId: factory.id.toString(),
            ),
          );
        },
        leading: CircleAvatar(

          backgroundColor:
          theme.colorScheme.primary.withOpacity(0.1),

          child: Text(

            factory.name.isNotEmpty
                ? factory.name[0].toUpperCase()
                : "?",

            style: TextStyle(
              color: theme.colorScheme.primary,
            ),

          ),

        ),


        title: Text(
          factory.name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
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

                Get.to(
                  () => const AddFactoryScreen(),
                  arguments: factory,
                );

              },

              icon: const Icon(Icons.edit_outlined),

              color: theme.colorScheme.secondary,

            ),



            IconButton(

              onPressed: onDelete,

              icon: const Icon(Icons.delete_outline),

              color: Colors.red,

            ),


          ],

        ),

      ),

    );

  }
}

