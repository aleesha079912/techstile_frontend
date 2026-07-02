import 'package:flutter/material.dart';
import '../../core/services/manager_service/manager_service.dart';
import '../../../core/utils/theme.dart';
import '../../../widgets/man_bottom_navbar.dart';
import 'package:get/get.dart';
import 'package:techstile_frontend/widgets/man_drawer.dart';
import 'package:techstile_frontend/core/services/auth_service.dart';
import 'package:techstile_frontend/routes/routes.dart';
class ManagerDashboard extends StatefulWidget {

  final dynamic factoryId;
  // final dynamic userId;

  const ManagerDashboard({
    super.key,
    required this.factoryId,
    // this.userId,
  });

  @override
  State<ManagerDashboard> createState() => _ManagerDashboardState();
}

class _ManagerDashboardState extends State<ManagerDashboard> {
  final _service = ManagerDashboardService();

  bool loading = true;
  Map data = {};
  String? error;

  @override
  void initState() {
    super.initState();
      print("Arguments = ${Get.arguments}");
print("Factory from Storage = ${AuthService.factoryId}");
print("Stored User ID = ${AuthService.userId}");

  load();
   
  }
  

 Future<void> load() async {
   final res = await _service.getDashboard(widget.factoryId); 
  setState(() {
    loading = true;
    error = null;
  });

  try {
    final id = int.tryParse(widget.factoryId.toString());

    if (id == null || id == 0) {
      throw Exception("Invalid factoryId");
    }

    final res = await _service.getDashboard(id);

    setState(() {
      data = res;
      loading = false;
    });
  } catch (e) {
    setState(() {
      error = e.toString();
      loading = false;
    });
  }
}

  @override
  Widget build(BuildContext context) {
  final factoryId = AuthService.factoryId;
  // final userId = widget.userId;
    return Scaffold(
   drawer: ManagerDrawer(
    // userId: userId,
    factoryId: factoryId,
  ),
      backgroundColor: AppTheme.background,
      appBar: _buildAppBar(),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : error != null
              ? _errorView()
              : RefreshIndicator(
                  color: AppTheme.primary,
                  onRefresh: load,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _heroCard(),
                        const SizedBox(height: 14),

                        // ✅ Button hero card se BAHAR — apni jagah pe
                        _viewProductionsButton(),

                        const SizedBox(height: 20),

                        const _SectionLabel(text: 'This Week'),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _statCard(
                              icon:  Icons.today_rounded,
                              label: 'Today',
                              value: "${data['today_units'] ?? 0}",
                              unit:  'yards',
                            ),
                            const SizedBox(width: 12),
                            _statCard(
                              icon:  Icons.calendar_month_rounded,
                              label: 'Weekly',
                              value: "${data['weekly_units'] ?? 0}",
                              unit:  'yards',
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        const _SectionLabel(text: 'Floor Assets'),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _statCard(
                              icon:  Icons.precision_manufacturing_rounded,
                              label: 'Machines',
                              value: "${data['machines_count'] ?? 0}",
                              unit:  'active',
                            ),
                            const SizedBox(width: 12),
                            _statCard(
                              icon:  Icons.groups_rounded,
                              label: 'Employees',
                              value: "${data['employees_count'] ?? 0}",
                              unit:  'on duty',
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        _SectionLabel(
                          text: 'Varieties (${data['total_varieties'] ?? 0})',
                        ),
                        const SizedBox(height: 12),
                        _varietiesList(),
                      ],
                    ),
                  ),
                ),
     bottomNavigationBar: ManagerBottomNav(
 currentIndex:0,
 factoryId: widget.factoryId,
),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final factory = data['factory'];

    return AppBar(
      backgroundColor: AppTheme.primary,
      elevation: 0,
      automaticallyImplyLeading: true,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Manager Dashboard',
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w800, fontSize: 17)),
          Text(
            loading ? 'Loading...' : (factory?['name'] ?? 'Factory'),
            style: TextStyle(
                color: Colors.white.withOpacity(0.65), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _errorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: AppTheme.error),
            const SizedBox(height: 12),
            Text(error ?? 'Something went wrong',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: load, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }

  // ── Hero card — sirf factory info, button alag hai ────────────────────────
  Widget _heroCard() {
    final factory = data['factory'];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: AppTheme.cardRadius,
        boxShadow: AppTheme.softShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.factory_rounded,
                color: AppTheme.secondary, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(factory?['name'] ?? 'Factory',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined,
                        color: Colors.white.withOpacity(0.6), size: 14),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${factory?['address'] ?? ''}, ${factory?['city'] ?? ''}',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.65), fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── ✅ View Productions button — full width, alag container, mobile-friendly ──
  Widget _viewProductionsButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          Get.toNamed(
  AppRoutes.managerProduction,
  arguments: {
    'factoryId': widget.factoryId,
  },
);
        },
        icon: const Icon(Icons.list_alt_rounded, size: 19),
        label: const Text(
          'View Productions',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.secondary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget _statCard({
    required IconData icon,
    required String label,
    required String value,
    required String unit,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppTheme.cardRadius,
          boxShadow: AppTheme.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.secondary.withOpacity(0.4),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppTheme.primary, size: 18),
            ),
            const SizedBox(height: 12),
            Text(value,
                style: const TextStyle(
                    color: AppTheme.textPrimary, fontSize: 24, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text('$label · $unit',
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _varietiesList() {
    final varieties = (data['varieties'] as List?) ?? [];

    if (varieties.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32),
        decoration: BoxDecoration(color: Colors.white, borderRadius: AppTheme.cardRadius),
        child: Column(
          children: [
            const Icon(Icons.inventory_2_outlined, size: 40, color: AppTheme.secondary),
            const SizedBox(height: 10),
            const Text('No varieties produced yet',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.cardRadius,
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        children: List.generate(varieties.length, (i) {
          final item   = varieties[i];
          final isLast = i == varieties.length - 1;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppTheme.secondary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.texture_rounded,
                          color: AppTheme.secondary, size: 16),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(item['variety_type']?.toString() ?? '',
                          style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600)),
                    ),
                    Text('${item['ready_production'] ?? 0}',
                        style: const TextStyle(
                            color: AppTheme.success,
                            fontSize: 16,
                            fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
              if (!isLast)
                Divider(height: 1, color: Colors.grey.shade100, indent: 16, endIndent: 16),
            ],
          );
        }),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4, height: 16,
          decoration: BoxDecoration(
              color: AppTheme.secondary, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 8),
        Text(text,
            style: const TextStyle(
                color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 15)),
      ],
    );
  }
}