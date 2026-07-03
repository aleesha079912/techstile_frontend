import 'package:flutter/material.dart';
import 'package:techstile_frontend/core/services/factory_dashboard_service.dart';
import 'package:techstile_frontend/core/utils/theme.dart';
import 'package:techstile_frontend/widgets/bottom_nav_bar.dart';
// import 'package:techstile_frontend/screens/factory_owner_dash/owner_production_page.dart'; // ← add this import
import 'package:get/get.dart';
import 'package:techstile_frontend/routes/routes.dart';


class FactoryDashboard extends StatefulWidget {
  final String factoryId;
  const FactoryDashboard({super.key, required this.factoryId});

  @override
  State<FactoryDashboard> createState() => _FactoryDashboardState();
}

class _FactoryDashboardState extends State<FactoryDashboard> {
  final _service = FactoryDashboardService();

  bool loading = true;
  Map data = {};

  int get factoryId => int.parse(widget.factoryId);

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() => loading = true);
    try {
      final res = await _service.getDashboard(widget.factoryId);
      setState(() {
        data    = res;
        loading = false;
      });
    } catch (_) {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: _buildAppBar(),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primary, strokeWidth: 2.5))
          : RefreshIndicator(
              color: AppTheme.primary,
              onRefresh: load,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _heroCard(),          // ← production button is inside here
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
                          color:AppTheme.success,
                        ),
                        const SizedBox(width: 12),
                        _statCard(
                          icon:  Icons.calendar_month_rounded,
                          label: 'Weekly',
                          value: "${data['weekly_units'] ?? 0}",
                          unit:  'yards',
                          color: AppTheme.surface,
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
                          color:AppTheme.primary,
                        ),
                        const SizedBox(width: 12),
                        _statCard(
                          icon:  Icons.groups_rounded,
                          label: 'Employees',
                          value: "${data['employees_count'] ?? 0}",
                          unit:  'on duty',
                          color: const Color(0xFF7B61FF),
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
      bottomNavigationBar: CustomBottomNav(currentIndex: 0, factoryId: factoryId),
    );
  }

  // ── AppBar ──────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.primary,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color:AppTheme.secondary, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('TechStile',
              style: TextStyle(
                  color:AppTheme.secondary, fontWeight: FontWeight.w800, fontSize: 17)),
          Text(
            data['factory']?['name'] ?? 'Loading…',
            style: TextStyle(
                color: AppTheme.secondary.withOpacity(0.65),
                fontSize: 12,
                fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }

  // ── Hero card — factory info + Productions button ───────────────────────────
  Widget _heroCard() {
    final factory = data['factory'];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primary, AppTheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: AppTheme.primary.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Factory info row (same as before) ───────────
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppTheme.secondary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.factory_rounded, color:AppTheme.success, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      factory?['name'] ?? 'Factory',
                      style: const TextStyle(
                          color: AppTheme.secondary, fontWeight: FontWeight.w800, fontSize: 18),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined,
                            color: AppTheme.secondary.withOpacity(0.6), size: 14),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${factory?['address'] ?? ''}, ${factory?['city'] ?? ''}',
                            style: TextStyle(
                                color: AppTheme.secondary.withOpacity(0.65), fontSize: 12),
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

          // ── Productions button ───────────────────────────
         const SizedBox(height: 16),

SizedBox(
  width: double.infinity,
  child: ElevatedButton.icon(
 onPressed: () {

  print("Sending Factory ID = ${widget.factoryId}");

  Get.toNamed(
    AppRoutes.ownerProduction,
    arguments: widget.factoryId,
  );
},
    icon: const Icon(Icons.list_alt_rounded),
    label: const Text(
      'View Productions',
      style: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 14,
      ),
    ),
    style: ElevatedButton.styleFrom(
      backgroundColor: AppTheme.success,
      foregroundColor: AppTheme.primary,
      elevation: 0,
      padding: const EdgeInsets.symmetric(vertical: 13),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),
),
        ],
      ),
    );
  }

  // ── Stat card ───────────────────────────────────────────────────────────────
  Widget _statCard({
    required IconData icon,
    required String label,
    required String value,
    required String unit,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.secondary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: AppTheme.onsurface.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 3)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 12),
            Text(value,
                style: const TextStyle(
                    color:AppTheme.primary, fontSize: 24, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text('$label · $unit',
                style: TextStyle(
                    color:AppTheme.primary.withOpacity(0.5),
                    fontSize: 11,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  // ── Varieties list ──────────────────────────────────────────────────────────
  Widget _varietiesList() {
    final varieties = (data['varieties'] as List?) ?? [];

    if (varieties.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32),
        decoration: BoxDecoration(
            color:AppTheme.secondary, borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            Icon(Icons.inventory_2_outlined, size: 40, color: AppTheme.neutral),
            const SizedBox(height: 10),
            Text('No varieties produced yet',
                style: TextStyle(color: AppTheme.neutral, fontSize: 13)),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.secondary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: AppTheme.onsurface.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3)),
        ],
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
                        color:AppTheme.success.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.texture_rounded,
                          color:AppTheme.success, size: 16),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item['variety_type']?.toString() ?? '',
                        style: const TextStyle(
                            color: AppTheme.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    Text(
                      '${item['ready_production'] ?? 0}',
                      style: const TextStyle(
                          color: AppTheme.success,
                          fontSize: 16,
                          fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Divider(
                    height: 1,
                    color: AppTheme.neutral,
                    indent: 16,
                    endIndent: 16),
            ],
          );
        }),
      ),
    );
  }
}

// ── Section label ────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
              color: AppTheme.success, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 8),
        Text(text,
            style: const TextStyle(
                color:AppTheme.primary, fontWeight: FontWeight.w700, fontSize: 15)),
      ],
    );
  }
}