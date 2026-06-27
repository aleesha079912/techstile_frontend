import 'package:flutter/material.dart';
import '../../../core/utils/theme.dart';
import '../../../core/services/manager_service/manager_employee_detail_service.dart';
import '../../../widgets/man_bottom_navbar.dart';

class ManagerEmployeeDetailScreen extends StatefulWidget {
  final int employeeId;
  final dynamic factoryId;

  const ManagerEmployeeDetailScreen({
    super.key,
    required this.employeeId,
    required this.factoryId,
  });

  @override
  State<ManagerEmployeeDetailScreen> createState() =>
      _ManagerEmployeeDetailScreenState();
}

class _ManagerEmployeeDetailScreenState
    extends State<ManagerEmployeeDetailScreen> {
  final service = ManagerEmployeeDetailService();

  bool loading = true;
  Map<String, dynamic>? employee;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final data = await service.getEmployeeDetail(widget.employeeId);
    setState(() {
      employee = data;
      loading = false;
    });
  }

  // ── Compact stat card — colored icon background ──────────────────────────
  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  // ── Shift info row ────────────────────────────────────────────────────────
  Widget _shiftRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.neutral.withOpacity(0.35),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: AppTheme.primary),
          ),
          const SizedBox(width: 12),
          Text(label,
              style: const TextStyle(
                  fontSize: 13, color: AppTheme.textSecondary)),
          const Spacer(),
          Text(value,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      );
    }

    final name = employee!['name']?.toString() ?? 'Employee';

    return Scaffold(
      backgroundColor: AppTheme.background,

      // ── AppBar with back button ───────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Employee Detail",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Column(
          children: [

            // ── Profile header card (gradient) ──────────────────────────────
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primary, AppTheme.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 38,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: Text(
                      name[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    employee!['email']?.toString() ?? '',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.75),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Shift info card ──────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _shiftRow(
                    Icons.login_rounded,
                    "Shift Start",
                    employee!['shift_start']?.toString() ?? '—',
                  ),
                  const Divider(height: 1),
                  _shiftRow(
                    Icons.logout_rounded,
                    "Shift End",
                    employee!['shift_end']?.toString() ?? '—',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Section label ────────────────────────────────────────────────
            Align(
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppTheme.secondary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Performance Overview',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Stat grid — compact 2x2 ──────────────────────────────────────
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.3,
              children: [
                _statCard(
                  "Production",
                  employee!['total_production'].toString(),
                  Icons.factory_rounded,
                  AppTheme.success,
                ),
                _statCard(
                  "Waste",
                  employee!['total_waste'].toString(),
                  Icons.delete_outline_rounded,
                  AppTheme.error,
                ),
                _statCard(
                  "Machines",
                  employee!['machines_worked'].toString(),
                  Icons.precision_manufacturing_rounded,
                  AppTheme.secondary,
                ),
                _statCard(
                  "Entries",
                  employee!['total_entries'].toString(),
                  Icons.list_alt_rounded,
                  AppTheme.primary,
                ),
              ],
            ),
          ],
        ),
      ),

      bottomNavigationBar: ManagerBottomNav(
        currentIndex: 2,
        factoryId: widget.factoryId,
      ),
    );
  }
}