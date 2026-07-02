import 'package:flutter/material.dart';
import 'package:techstile_frontend/core/services/auth_service.dart';
import 'package:techstile_frontend/core/services/employee_service/history_service.dart';
import 'package:techstile_frontend/widgets/emp_db_bot_nav_bar.dart';
import 'package:techstile_frontend/widgets/emp_drawer.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  final HistoryService service = HistoryService();
  late TabController _tabController;

  bool loading = true;
  List pending = [];
  List completed = [];
  double daily = 0;
  double weekly = 0;
  double monthly = 0;

  // ── Colours ────────────────────────────────────────────────────────────────
  static const _navy    = Color(0xFF0D1B4B);
  static const _teal    = Color(0xFF00C8B0);
  static const _bg      = Color(0xFFF5F6FA);
  static const _white   = Colors.white;
  static const _orange  = Color(0xFFFF8C42);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    loadHistory();
    
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

 Future<void> loadHistory() async {
  try {
    final user = AuthService.user;
    if (user == null) return;

    final data = await service.getHistory(user['id']);

    setState(() {
      pending = data['pending'] ?? [];
      completed = data['completed'] ?? [];
      daily = double.parse(data['daily'].toString());
      weekly = double.parse(data['weekly'].toString());
      monthly = double.parse(data['monthly'].toString());
      loading = false;
    });
  } catch (e) {
    debugPrint(e.toString());
    setState(() => loading = false);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      drawer: const EmployeeDrawer(),

      // ── AppBar ──────────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: _navy,
        elevation: 0,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu_rounded, color: _white),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: const Text(
          'Production History',
          style: TextStyle(
            color: _white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),

      body: loading
          ? const Center(
              child: CircularProgressIndicator(color: _navy, strokeWidth: 2.5))
          : Column(
              children: [
                // ── Summary strip ──────────────────────────────────────────
                Container(
                  color: _navy,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  child: Row(
                    children: [
                      _summaryChip('Daily',   daily),
                      const SizedBox(width: 8),
                      _summaryChip('Weekly',  weekly),
                      const SizedBox(width: 8),
                      _summaryChip('Monthly', monthly),
                    ],
                  ),
                ),

                // ── Tab bar — outside appBar, below summary ────────────────
                Container(
                  color: _navy,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: _white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: _teal,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelColor: _white,
                      unselectedLabelColor: _white.withOpacity(0.6),
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                      tabs: const [
                        Tab(text: '⏳  Pending'),
                        Tab(text: '✅  Completed'),
                      ],
                    ),
                  ),
                ),

                // ── Tab views ─────────────────────────────────────────────
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildList(pending,   isApproved: false),
                      _buildList(completed, isApproved: true),
                    ],
                  ),
                ),
              ],
            ),

      bottomNavigationBar: const EmployeeBottomNav(currentIndex: 2),
    );
  }

  // ── Summary chip ──────────────────────────────────────────────────────────
  Widget _summaryChip(String label, double value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: _white.withOpacity(0.10),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _white.withOpacity(0.18)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: _white.withOpacity(0.7),
                fontSize: 11,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value.toStringAsFixed(1),
              style: const TextStyle(
                color: _teal,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── List builder ──────────────────────────────────────────────────────────
  Widget _buildList(List data, {required bool isApproved}) {
    if (data.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isApproved ? Icons.check_circle_outline : Icons.pending_outlined,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 12),
            Text(
              isApproved ? 'No completed records' : 'No pending records',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 15),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: _navy,
      onRefresh: loadHistory,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        itemCount: data.length,
        itemBuilder: (_, i) => _productionCard(data[i], isApproved: isApproved),
      ),
    );
  }

  // ── Production card ───────────────────────────────────────────────────────
  Widget _productionCard(dynamic item, {required bool isApproved}) {
    final accent = isApproved ? _teal : _orange;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: _navy.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isApproved ? Icons.check_rounded : Icons.schedule_rounded,
                    color: _white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Machine ID: ${item['machine_id']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: _navy,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isApproved ? 'Approved' : 'Pending',
                    style: TextStyle(
                      color: accent,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _infoRow(Icons.category_outlined,     'Variety',          item['variety_type']),
                _infoRow(Icons.straighten_rounded,    'Total Length',     item['total_length']),
                _infoRow(Icons.check_circle_outline,  'Ready Production', item['ready_production']),
                if (isApproved)
                  _infoRow(Icons.done_all_rounded, 'Status', 'Approved ✅'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Info row ──────────────────────────────────────────────────────────────
  Widget _infoRow(IconData icon, String title, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: _navy.withOpacity(0.5)),
          const SizedBox(width: 8),
          Text(
            '$title: ',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: _navy,
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? '—',
              style: TextStyle(
                fontSize: 13,
                color: _navy.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}