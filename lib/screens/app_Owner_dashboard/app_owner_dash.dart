import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:techstile_frontend/core/utils/theme.dart';
import 'package:techstile_frontend/screens/app_Owner_dashboard/add_factories.dart';
import 'package:techstile_frontend/screens/app_Owner_dashboard/calculator_screen.dart';
import 'package:techstile_frontend/screens/app_Owner_dashboard/notification_screen.dart';
import 'package:techstile_frontend/screens/app_Owner_dashboard/setting_screen.dart';
import 'package:techstile_frontend/screens/factory_owner_dash/owner_dashboard.dart';

const _blue = Color(0xFF2563EB);
const _skyBlue = Color(0xFFEFF6FF);
const _white = Colors.white;

class FactoryController extends GetxController {
  var factories = <Map<String, String>>[].obs;

  void addFactory(Map<String, String> data) => factories.add(data);

  void removeFactory(int index) => factories.removeAt(index);
}

class OwnerDashboard extends StatefulWidget {
  const OwnerDashboard({super.key});

  @override
  State<OwnerDashboard> createState() => _OwnerDashboardState();
}

class _OwnerDashboardState extends State<OwnerDashboard> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    _HomeTab(),
    CalculatorScreen(),
    NotificationScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    Get.put(FactoryController());

    return Scaffold(
      backgroundColor: AppTheme.secondary,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      floatingActionButton:
          _currentIndex == 0 ? _buildFAB() : null,
      floatingActionButtonLocation:
          FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildFAB() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primary, _blue],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Get.to(() => const AddFactoryScreen()),
        child: const Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add, color: Colors.white),
              SizedBox(width: 6),
              Text(
                "Add Factory",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (i) => setState(() => _currentIndex = i),
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: AppTheme.primary,
      unselectedItemColor: AppTheme.neutral,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calculate_outlined),
          label: "Calculator",
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

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader()),
          SliverToBoxAdapter(child: _buildStatsRow(controller)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Obx(() => Text(
                    "${controller.factories.length} registered",
                    style: TextStyle(color: AppTheme.neutral),
                  )),
            ),
          ),
          Obx(() {
            if (controller.factories.isEmpty) {
              return SliverFillRemaining(
                child: _buildEmptyState(),
              );
            }

            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  child: _FactoryCard(
                    factory: controller.factories[index],
                    index: index,
                    onDelete: () =>
                        controller.removeFactory(index),
                  ),
                ),
                childCount: controller.factories.length,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primary, _blue],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Row(
        children: [
          Expanded(
            child: Text(
              "Owner Dashboard",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          CircleAvatar(
            backgroundColor: Colors.white24,
            child: Icon(Icons.person, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(FactoryController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Obx(() => Row(
            children: [
              _StatCard(
                label: "Factories",
                value: "${controller.factories.length}",
                icon: Icons.factory,
                color: AppTheme.primary,
              ),
              const SizedBox(width: 10),
              _StatCard(
                label: "Cities",
                value:
                    "${controller.factories.map((f) => f['city']).toSet().length}",
                icon: Icons.location_city,
                color: AppTheme.tertiary,
              ),
            ],
          )),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _skyBlue,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.factory_outlined,
              size: 40,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          const Text("No factories yet"),
        ],
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
          color: Colors.white,
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
            Text(label),
          ],
        ),
      ),
    );
  }
}

class _FactoryCard extends StatelessWidget {
  final Map<String, String> factory;
  final int index;
  final VoidCallback onDelete;

  const _FactoryCard({
    required this.factory,
    required this.index,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        onTap: () => Get.off(() => const OwnerDashboardScreen()),
        leading: CircleAvatar(
          backgroundColor: AppTheme.primary.withOpacity(0.1),
          child: Text(
            factory['name']![0].toUpperCase(),
            style: TextStyle(color: AppTheme.primary),
          ),
        ),
        title: Text(factory['name'] ?? ''),
        subtitle: Text(
          "${factory['city']} • ${factory['address']}",
          style: TextStyle(color: AppTheme.neutral),
        ),
        trailing: IconButton(
          onPressed: onDelete,
          icon: const Icon(Icons.delete_outline),
          color: Colors.red,
        ),
      ),
    );
  }
}