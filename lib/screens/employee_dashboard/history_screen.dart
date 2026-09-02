import 'package:flutter/material.dart';
import 'package:techstile_frontend/core/services/auth_service.dart';
import 'package:techstile_frontend/core/services/employee_service/history_service.dart';
import 'package:techstile_frontend/core/utils/theme.dart';
import 'package:techstile_frontend/widgets/emp_db_bot_nav_bar.dart';
import 'package:techstile_frontend/widgets/emp_drawer.dart';

class HistoryScreen extends StatefulWidget {
  final int? userId;
  final String? userName;

  const HistoryScreen({
    super.key,
    this.userId,
    this.userName,
  });

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
    final targetId = widget.userId ?? AuthService.user?['id'];
    if (targetId == null) return;

    final data = await service.getHistory(int.tryParse(targetId.toString()) ?? 0);

    setState(() {
      pending = data['pending'] ?? [];
      completed = data['completed'] ?? [];
      daily = double.tryParse(data['daily']?.toString() ?? '0') ?? 0;
      weekly = double.tryParse(data['weekly']?.toString() ?? '0') ?? 0;
      monthly = double.tryParse(data['monthly']?.toString() ?? '0') ?? 0;
      loading = false;
    });
  } catch (e) {
    debugPrint(e.toString());
    setState(() => loading = false);
  }
}

  @override
  Widget build(BuildContext context) {
    final bool isEmbedded = widget.userId != null;

    return Scaffold(
      backgroundColor: AppTheme.background,
      drawer: isEmbedded ? null : const EmployeeDrawer(),

      // ── AppBar (matches Factory Dashboard style) ──────────────────────
      appBar: AppBar(
        backgroundColor: AppTheme.secondary,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: AppTheme.primary,
        ),
        titleSpacing: 4,
        leading: isEmbedded
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.primary),
                onPressed: () => Navigator.pop(context),
              )
            : Builder(
                builder: (ctx) => IconButton(
                  icon: const Icon(Icons.menu_rounded, color: AppTheme.primary),
                  onPressed: () => Scaffold.of(ctx).openDrawer(),
                ),
              ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Production History',
              style: TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.w800,
                fontSize: 19,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              widget.userName != null && widget.userName!.isNotEmpty
                  ? "${widget.userName}'s records"
                  : 'All your records',
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
              child: CircularProgressIndicator(color: AppTheme.primary, strokeWidth: 2.5))
          : Column(
              children: [

                // ── Summary strip — small stat cards ─────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: Row(
                    children: [
                      _summaryChip('Daily',   daily,   Icons.today_rounded,        AppTheme.success),
                      const SizedBox(width: 10),
                      _summaryChip('Weekly',  weekly,  Icons.calendar_month_rounded, AppTheme.primary),
                      const SizedBox(width: 10),
                      _summaryChip('Monthly', monthly, Icons.calendar_today_rounded, AppTheme.active),
                    ],
                  ),
                ),

                // ── Tab bar — card styled ─────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.secondary,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: _primaryShadow,
                      border: _primaryBorder,
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: AppTheme.success,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelColor: AppTheme.secondary,
                      unselectedLabelColor: AppTheme.textPrimary.withOpacity(0.6),
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

                //  Tab views 
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

      bottomNavigationBar: isEmbedded ? null : const EmployeeBottomNav(currentIndex: 2),
    );
  }

  // Summary chip — restyled as a Factory-Dashboard-style stat card
  Widget _summaryChip(String label, double value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: AppTheme.secondary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: _primaryShadow,
          border: _primaryBorder,
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, color: color, size: 15),
            ),
            const SizedBox(height: 8),
            Text(
              value.toStringAsFixed(1),
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: AppTheme.textPrimary.withOpacity(0.6),
                fontSize: 11,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // List builder
  Widget _buildList(List data, {required bool isApproved}) {
    if (data.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isApproved ? Icons.check_circle_outline : Icons.pending_outlined,
              size: 64,
              color: AppTheme.neutral,
            ),
            const SizedBox(height: 12),
            Text(
              isApproved ? 'No completed records' : 'No pending records',
              style: TextStyle(color: AppTheme.textneutral, fontSize: 15),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color:AppTheme.primary,
      onRefresh: loadHistory,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        itemCount: data.length,
        itemBuilder: (_, i) => _productionCard(data[i], isApproved: isApproved),
      ),
    );
  }

  // Production card — restyled with Factory Dashboard shadow/border
  Widget _productionCard(dynamic item, {required bool isApproved}) {
    final accent = isApproved ? AppTheme.success : AppTheme.surface;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.secondary,
        borderRadius: BorderRadius.circular(18),
        boxShadow: _primaryShadow,
        border: _primaryBorder,
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
                    color: AppTheme.secondary,
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
                      color:AppTheme.textPrimary,
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

  // Info row 
  Widget _infoRow(IconData icon, String title, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.primary.withOpacity(0.5)),
          const SizedBox(width: 8),
          Text(
            '$title: ',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: AppTheme.textPrimary,
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? '—',
              style: TextStyle(
                fontSize: 13,
                color:AppTheme.textPrimary.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}