import 'package:flutter/material.dart';

import 'package:techstile_frontend/core/utils/theme.dart';
import 'package:techstile_frontend/core/services/employee_service/employee_dashboard_service.dart';

import 'package:techstile_frontend/widgets/emp_db_bot_nav_bar.dart';
import 'package:techstile_frontend/widgets/emp_drawer.dart';


class EmployeeDashboard extends StatefulWidget {
  const EmployeeDashboard({super.key});

  @override
  State<EmployeeDashboard> createState() => _EmployeeDashboardState();
}

class _EmployeeDashboardState extends State<EmployeeDashboard> {
  final EmployeeDashboardService service = EmployeeDashboardService();

  bool loading = true;
  List machines = [];
  String employeeName = '';
  int totalMachines = 0;
  double totalProduction = 0;
  double totalReadyProduction = 0;
  double dailyApproved = 0;
  double weeklyApproved = 0;

  // ─────────────────────────────────────────────────────────────────────────
  // Common shadow / border (matches Factory Dashboard styling)
  // ─────────────────────────────────────────────────────────────────────────

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

  static Border get _primaryBorder => Border.all(
        color: AppTheme.primary.withOpacity(0.10),
        width: 1,
      );

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    try {
      final data = await service.getDashboard();

      setState(() {
        machines = data["machines"] ?? [];
        employeeName = data["employee_name"]?.toString() ?? '';
        totalMachines = data["total_machines"] ?? 0;
        totalProduction = (data["total_production"] ?? 0).toDouble();
        totalReadyProduction = (data["total_ready_production"] ?? 0).toDouble();
        dailyApproved = (data["daily_ready_production"] ?? 0).toDouble();
        weeklyApproved = (data["weekly_ready_production"] ?? 0).toDouble();
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const EmployeeDrawer(),
      backgroundColor: AppTheme.background,

      appBar: AppBar(
        backgroundColor: AppTheme.secondary,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: AppTheme.primary,
        ),
        titleSpacing: 4,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Employee Dashboard",
              style: TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.w800,
                fontSize: 19,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              loading ? 'Loading...' : (employeeName.isNotEmpty ? employeeName : 'Employee'),
              style: TextStyle(
                color: AppTheme.primary.withOpacity(0.65),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),

      body: loading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primary,
              ),
            )
          : RefreshIndicator(
              color: AppTheme.primary,
              onRefresh: loadDashboard,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ─────────────────────────────────────────────
                    // Overview — 4 small stat cards, 2 per row
                    // (sized like the Factory Dashboard's compact cards)
                    // ─────────────────────────────────────────────

                    const _SectionLabel(text: 'Overview'),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        _compactStatCard(
                          icon: Icons.precision_manufacturing_rounded,
                          label: "My Machines",
                          value: "$totalMachines",
                          color: AppTheme.primary,
                        ),
                        const SizedBox(width: 10),
                        _compactStatCard(
                          icon: Icons.check_circle_rounded,
                          label: "Ready (all-time)",
                          value: totalReadyProduction.toStringAsFixed(0),
                          color: AppTheme.success,
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        _compactStatCard(
                          icon: Icons.today_rounded,
                          label: "Today (Approved)",
                          value: dailyApproved.toStringAsFixed(0),
                          color: AppTheme.success,
                        ),
                        const SizedBox(width: 10),
                        _compactStatCard(
                          icon: Icons.calendar_month_rounded,
                          label: "This Week (Approved)",
                          value: weeklyApproved.toStringAsFixed(0),
                          color: AppTheme.primary,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ─────────────────────────────────────────────
                    // Assigned machines
                    // ─────────────────────────────────────────────

                    _SectionLabel(text: 'My Assigned Machines (${machines.length})'),

                    const SizedBox(height: 12),

                    if (machines.isEmpty)
                      _emptyMachinesView()
                    else
                      ...machines.map((machine) => _machineCard(machine)),
                  ],
                ),
              ),
            ),

      bottomNavigationBar: const EmployeeBottomNav(currentIndex: 0),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Empty state
  // ─────────────────────────────────────────────────────────────────────────

  Widget _emptyMachinesView() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: AppTheme.secondary,
        borderRadius: BorderRadius.circular(18),
        boxShadow: _primaryShadow,
        border: _primaryBorder,
      ),
      child: Column(
        children: [
          Icon(
            Icons.precision_manufacturing_outlined,
            size: 40,
            color: AppTheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 10),
          const Text(
            "No machines assigned yet",
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Machine card
  // ─────────────────────────────────────────────────────────────────────────

  Widget _machineCard(dynamic machine) {
    final progress = (machine["progress"] ?? 0);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.secondary,
        borderRadius: BorderRadius.circular(18),
        boxShadow: _primaryShadow,
        border: _primaryBorder,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.memory_rounded,
                  color: AppTheme.primary,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  (machine["machine_name"] ?? '').toString().isNotEmpty
                      ? machine["machine_name"].toString()
                      : "Machine #${machine["machine_id"]}",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              _infoChip(
                icon: Icons.category_rounded,
                label: (machine["variety_type"] ?? "").toString(),
                color: AppTheme.info,
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              _breakdownChip(
                'Ready Production',
                machine["ready_production"] ?? 0,
                AppTheme.success,
              ),
              const SizedBox(width: 8),
              _breakdownChip(
                'Total Length',
                machine["total_length"] ?? 0,
                AppTheme.neutral,
              ),
            ],
          ),

          const SizedBox(height: 14),

          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (progress ?? 0) / 100,
              minHeight: 10,
              color: AppTheme.primary,
              backgroundColor: AppTheme.primary.withOpacity(0.15),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            "Progress: $progress%",
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Small info chip (pill)
  // ─────────────────────────────────────────────────────────────────────────

  Widget _infoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppTheme.primary.withOpacity(0.18),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Breakdown chip (matches Factory Dashboard style)
  // ─────────────────────────────────────────────────────────────────────────

  Widget _breakdownChip(
    String label,
    dynamic value,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(
            color: AppTheme.primary.withOpacity(0.18),
            width: 0.8,
          ),
        ),
        child: Column(
          children: [
            Text(
              '$value',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Compact stat card — small size, matching the Factory Dashboard's
  // "Total Machines / Total Employees" style cards (smaller padding,
  // smaller icon box, smaller text than the main stat cards).
  // ─────────────────────────────────────────────────────────────────────────

  Widget _compactStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.secondary,
          borderRadius: BorderRadius.circular(14),
          boxShadow: _primaryShadow,
          border: _primaryBorder,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, color: color, size: 15),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section label (matches Factory Dashboard style)
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 17,
          decoration: BoxDecoration(
            color: AppTheme.success,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}