import 'package:flutter/material.dart';
import '../../core/services/owner_dashboard_service.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/drawer.dart'; 

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  final _service = OwnerDashboardService.instance;
  OwnerDashboardSnapshot? _snapshot;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    if (_service.cachedSnapshot != null) {
      _snapshot = _service.cachedSnapshot;
      _loading = false;
    }
    _service.snapshotStream.listen((snap) {
      if (mounted) {
        setState(() {
          _snapshot = snap;
          _loading = false;
        });
      }
    });
    _service.init();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: const OwnerDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        // centerTitle false karne se text left par aa jayega
        centerTitle: false,
        leadingWidth: 48, // Icon aur Text ke darmiyan behtar alignment ke liye
        leading: Builder(
          builder: (context) => IconButton(
            padding: const EdgeInsets.only(left: 12),
            icon: Icon(Icons.menu_rounded, color: colorScheme.primary),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          'TextileOS',
          style: TextStyle(
            color: colorScheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            fontFamily: 'Sora', // Agar Sora font use kar rahe hain
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: colorScheme.primary,
              child: const Icon(
                Icons.person_outline_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),

      body: _loading
          ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
          : RefreshIndicator(
              onRefresh: _service.refresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHealthIndex(_snapshot!.health, colorScheme),
                    const SizedBox(height: 25),
                    _buildProductionCard(_snapshot!.production, colorScheme),
                    const SizedBox(height: 15),
                    _buildRevenueCard(_snapshot!.revenue, colorScheme),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 0),
    );
  }

  // --- WIDGETS (Same as before) ---
  Widget _buildHealthIndex(FactoryHealthData data, ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'FACTORY HEALTH INDEX',
          style: TextStyle(
            color: colors.onSurface.withValues(alpha: 0.5),
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${data.healthIndex}%',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w900,
            color: colors.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          data.insight,
          style: const TextStyle(
            fontSize: 14,
            height: 1.5,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildProductionCard(MonthlyProductionData data, ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MONTHLY PRODUCTION',
            style: TextStyle(
              fontSize: 10,
              color: colors.onSurface.withValues(alpha: 0.5),
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${data.value}k',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Icon(Icons.trending_up, color: colors.secondary, size: 18),
                  Text(
                    ' ${data.growth}%',
                    style: TextStyle(
                      color: colors.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Text(
            'Yards of premium weave',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueCard(RevenuePipelineData data, ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'REVENUE PIPELINE',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '\$${data.amount}M',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '+${data.growth}%',
                style: TextStyle(
                  color: colors.secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: data.progress,
              backgroundColor: Colors.white10,
              color: colors.secondary,
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
