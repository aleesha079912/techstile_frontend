import 'package:flutter/material.dart';
import '../../core/services/manager_service/manager_service.dart';
import '../../../core/utils/theme.dart';
import '../../../widgets/man_bottom_navbar.dart';

class ManagerDashboard extends StatefulWidget {
  final dynamic factoryId;
  const ManagerDashboard({super.key, required this.factoryId});

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
    load();
  }

  Future<void> load() async {
    setState(() {
      loading = true;
      error   = null;
    });
    try {
      final res = await _service.getDashboard(widget.factoryId);
      setState(() {
        data    = res;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error   = e.toString();
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        currentIndex: 0,
        factoryId: widget.factoryId,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.primary,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('TechStile',
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w800, fontSize: 17)),
          Text(
            data['factory']?['name'] ?? 'Loading…',
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
                color: AppTheme.neutral.withOpacity(0.4),
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
            const Icon(Icons.inventory_2_outlined, size: 40, color: AppTheme.neutral),
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