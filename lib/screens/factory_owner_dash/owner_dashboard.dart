import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../core/services/owner_dashboard_service.dart';

// ---------------------------------------------------------------------------
// Colour tokens (matches the navy / white / teal palette in the mockup)
// ---------------------------------------------------------------------------
class _C {
  static const bg = Color(0xFFF5F6FA);
  static const navy = Color(0xFF0D1B4B);
  static const navyMid = Color(0xFF1A2F6F);
  static const teal = Color(0xFF00C8B0);
  static const white = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF0D1B4B);
  static const textSecondary = Color(0xFF8A93A8);
  static const textHint = Color(0xFFB0B8CC);
  static const errorRed = Color(0xFFE84545);
  static const cardBg = Color(0xFFFFFFFF);
  static const divider = Color(0xFFE8EBF3);
}

// ---------------------------------------------------------------------------
// Text styles
// ---------------------------------------------------------------------------
class _T {
  static const appBarTitle = TextStyle(
    fontFamily: 'Sora',
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: _C.textPrimary,
    letterSpacing: 0.2,
  );

  static const label = TextStyle(
    fontFamily: 'Sora',
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: _C.textSecondary,
    letterSpacing: 1.4,
  );

  static const heroNum = TextStyle(
    fontFamily: 'Sora',
    fontSize: 42,
    fontWeight: FontWeight.w800,
    color: _C.textPrimary,
    height: 1.1,
  );

  static const heroSub = TextStyle(
    fontFamily: 'Sora',
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: _C.textPrimary,
    height: 1.5,
  );

  static const cardNum = TextStyle(
    fontFamily: 'Sora',
    fontSize: 30,
    fontWeight: FontWeight.w700,
    color: _C.textPrimary,
  );

  static const cardLabel = TextStyle(
    fontFamily: 'Sora',
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: _C.textSecondary,
  );

  static const badgePositive = TextStyle(
    fontFamily: 'Sora',
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: _C.teal,
  );

  static const revenuePipelineNum = TextStyle(
    fontFamily: 'Sora',
    fontSize: 34,
    fontWeight: FontWeight.w800,
    color: _C.white,
    height: 1.1,
  );

  static const revenuePipelineBadge = TextStyle(
    fontFamily: 'Sora',
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: _C.teal,
  );

  static const sectionTitle = TextStyle(
    fontFamily: 'Sora',
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: _C.textPrimary,
  );

  static const sectionSubtitle = TextStyle(
    fontFamily: 'Sora',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: _C.textSecondary,
  );

  static const chartTitle = TextStyle(
    fontFamily: 'Sora',
    fontSize: 19,
    fontWeight: FontWeight.w800,
    color: _C.textPrimary,
  );

  static const chartSubtitle = TextStyle(
    fontFamily: 'Sora',
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: _C.textSecondary,
  );

  static const wasteTitle = TextStyle(
    fontFamily: 'Sora',
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: _C.textPrimary,
  );

  static const wasteSub = TextStyle(
    fontFamily: 'Sora',
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: _C.textSecondary,
    height: 1.4,
  );

  static const wasteDelta = TextStyle(
    fontFamily: 'Sora',
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: _C.teal,
  );

  static const spotlightLabel = TextStyle(
    fontFamily: 'Sora',
    fontSize: 9,
    fontWeight: FontWeight.w600,
    color: _C.teal,
    letterSpacing: 1.6,
  );

  static const spotlightTitle = TextStyle(
    fontFamily: 'Sora',
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: _C.white,
    height: 1.2,
  );

  static const spotlightDesc = TextStyle(
    fontFamily: 'Sora',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: Color(0xCCFFFFFF),
    height: 1.5,
  );

  static const navLabel = TextStyle(
    fontFamily: 'Sora',
    fontSize: 10,
    fontWeight: FontWeight.w500,
  );

  static const maintenanceBtn = TextStyle(
    fontFamily: 'Sora',
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: _C.textPrimary,
    letterSpacing: 1.2,
  );
}

// ---------------------------------------------------------------------------
// Owner Dashboard Screen
// ---------------------------------------------------------------------------
class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen>
    with TickerProviderStateMixin {
  final _service = OwnerDashboardService();
  OwnerDashboardSnapshot? _snapshot;
  bool _loading = true;
  int _navIndex = 0;

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);

    _service.snapshotStream.listen((snap) {
      if (!mounted) return;
      setState(() {
        _snapshot = snap;
        _loading = false;
      });
      _fadeCtrl.forward(from: 0);
    });
    _service.init();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _service.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      appBar: _buildAppBar(),
      body: _loading ? _buildLoader() : _buildBody(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ---------------------------------------------------------------------------
  // AppBar
  // ---------------------------------------------------------------------------

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _C.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leadingWidth: 52,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: CircleAvatar(
          radius: 18,
          backgroundColor: _C.navy,
          child: const Icon(
            Icons.person_outline_rounded,
            color: _C.white,
            size: 18,
          ),
        ),
      ),
      title: const Text('TextileOS', style: _T.appBarTitle),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.notifications_none_rounded,
            color: _C.textPrimary,
            size: 22,
          ),
          onPressed: () {},
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Loader
  // ---------------------------------------------------------------------------

  Widget _buildLoader() {
    return const Center(
      child: CircularProgressIndicator(color: _C.navy, strokeWidth: 2.5),
    );
  }

  // ---------------------------------------------------------------------------
  // Body
  // ---------------------------------------------------------------------------

  Widget _buildBody() {
    final snap = _snapshot!;
    return FadeTransition(
      opacity: _fadeAnim,
      child: RefreshIndicator(
        color: _C.navy,
        onRefresh: _service.refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FactoryHealthCard(data: snap.factoryHealth),
              const SizedBox(height: 14),
              _MonthlyProductionCard(data: snap.monthlyProduction),
              const SizedBox(height: 14),
              _RevenuePipelineCard(data: snap.revenuePipeline),
              const SizedBox(height: 14),
              _FinancialFluxCard(bars: snap.financialFlux),
              const SizedBox(height: 14),
              _ActiveLoomsCard(
                data: snap.activeLooms,
                onViewLog: _service.onViewMaintenanceLogTapped,
              ),
              const SizedBox(height: 14),
              _WasteMinimizationCard(metrics: snap.wasteMetrics),
              const SizedBox(height: 14),
              _ProjectSpotlightCard(spotlight: snap.projectSpotlight),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Bottom Nav
  // ---------------------------------------------------------------------------

  Widget _buildBottomNav() {
    const items = [
      _NavItem(icon: Icons.grid_view_rounded, label: 'DASHBOARD'),
      _NavItem(icon: Icons.precision_manufacturing_outlined, label: 'MACHINES'),
      _NavItem(icon: Icons.credit_card_outlined, label: 'PAYMENTS'),
      _NavItem(icon: Icons.group_outlined, label: 'USERS'),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: _C.navy,
        borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            children: List.generate(items.length, (i) {
              final selected = i == _navIndex;
              return Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() => _navIndex = i);
                    _service.onNavTabSelected(i);
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        items[i].icon,
                        size: 20,
                        color: selected ? _C.teal : const Color(0xFF6A7AA1),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        items[i].label,
                        style: _T.navLabel.copyWith(
                          color: selected ? _C.teal : const Color(0xFF6A7AA1),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Card: Factory Health Index
// ---------------------------------------------------------------------------

class _FactoryHealthCard extends StatelessWidget {
  final FactoryHealthData data;
  const _FactoryHealthCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('FACTORY HEALTH INDEX', style: _T.label),
          const SizedBox(height: 6),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: data.healthIndex.toStringAsFixed(1),
                  style: _T.heroNum,
                ),
                TextSpan(text: '%', style: _T.heroNum.copyWith(fontSize: 26)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(data.insight, style: _T.heroSub),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Card: Monthly Production
// ---------------------------------------------------------------------------

class _MonthlyProductionCard extends StatelessWidget {
  final MonthlyProductionData data;
  const _MonthlyProductionCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return _BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('MONTHLY PRODUCTION', style: _T.label),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(data.formattedValue, style: _T.cardNum),
              const Spacer(),
              Row(
                children: [
                  const Icon(
                    Icons.trending_up_rounded,
                    color: _C.teal,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${data.growthPercent.toStringAsFixed(0)}%',
                    style: _T.badgePositive,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(data.unit, style: _T.cardLabel),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Card: Revenue Pipeline
// ---------------------------------------------------------------------------

class _RevenuePipelineCard extends StatelessWidget {
  final RevenuePipelineData data;
  const _RevenuePipelineCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _C.navy,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'REVENUE PIPELINE',
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFF8A99C7),
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(data.formattedAmount, style: _T.revenuePipelineNum),
              const Spacer(),
              Text(
                '+${data.growthPercent.toStringAsFixed(0)}%',
                style: _T.revenuePipelineBadge,
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: data.progressRatio,
              minHeight: 5,
              backgroundColor: const Color(0xFF1A2F6F),
              valueColor: const AlwaysStoppedAnimation<Color>(_C.teal),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Card: Financial Flux bar chart
// ---------------------------------------------------------------------------

class _FinancialFluxCard extends StatelessWidget {
  final List<FinancialFluxBar> bars;
  const _FinancialFluxCard({required this.bars});

  @override
  Widget build(BuildContext context) {
    return _BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Financial Flux', style: _T.chartTitle),
                    SizedBox(height: 2),
                    Text(
                      'Operating margin\ncomparison (Q3)',
                      style: _T.chartSubtitle,
                    ),
                  ],
                ),
              ),
              _LegendDot(color: _C.navy, label: 'GROSS'),
              const SizedBox(width: 10),
              _LegendDot(color: _C.textHint, label: 'COST'),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(height: 130, child: _BarChart(bars: bars)),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Sora',
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: _C.textSecondary,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}

class _BarChart extends StatelessWidget {
  final List<FinancialFluxBar> bars;
  const _BarChart({required this.bars});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: bars.map((bar) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Bar group
                SizedBox(
                  height: 110,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _SingleBar(ratio: bar.gross, color: _C.navy),
                      const SizedBox(width: 0),
                      _SingleBar(ratio: bar.cost, color: _C.textHint),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  bar.month,
                  style: const TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: _C.textSecondary,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _SingleBar extends StatelessWidget {
  final double ratio;
  final Color color;
  const _SingleBar({required this.ratio, required this.color});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        heightFactor: ratio.clamp(0.05, 1.0),
        child: Container(
          width: 50,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Card: Active Looms
// ---------------------------------------------------------------------------

class _ActiveLoomsCard extends StatelessWidget {
  final ActiveLoomsData data;
  final VoidCallback onViewLog;
  const _ActiveLoomsCard({required this.data, required this.onViewLog});

  @override
  Widget build(BuildContext context) {
    return _BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Active Looms', style: _T.sectionTitle),
          const SizedBox(height: 2),
          Text(
            '${data.active} of ${data.total} running',
            style: _T.sectionSubtitle,
          ),
          const SizedBox(height: 24),
          Center(
            child: SizedBox(
              width: 120,
              height: 120,
              child: CustomPaint(
                painter: _DonutPainter(ratio: data.utilizationRatio),
                child: Center(
                  child: Text(
                    '${data.utilizationPercent}%',
                    style: const TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: _C.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Text('Maintenance due', style: _T.cardLabel),
              const Spacer(),
              Text(
                '${data.maintenanceDue} Machines',
                style: const TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _C.errorRed,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          GestureDetector(
 onTap: () {
  // Get.offAll(() => const MachinesScreen());
},
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: _C.divider, width: 1.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text('VIEW MAINTENANCE LOG', style: _T.maintenanceBtn),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final double ratio;
  const _DonutPainter({required this.ratio});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = math.min(cx, cy) - 8;
    const strokeWidth = 12.0;

    final trackPaint = Paint()
      ..color = const Color(0xFFE8EBF3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = _C.teal
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    const startAngle = -math.pi / 2;
    const fullSweep = 2 * math.pi;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: radius),
      startAngle,
      fullSweep,
      false,
      trackPaint,
    );

    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: radius),
      startAngle,
      fullSweep * ratio,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_DonutPainter old) => old.ratio != ratio;
}

// ---------------------------------------------------------------------------
// Card: Waste Minimization
// ---------------------------------------------------------------------------

class _WasteMinimizationCard extends StatelessWidget {
  final List<WasteMetric> metrics;
  const _WasteMinimizationCard({required this.metrics});

  @override
  Widget build(BuildContext context) {
    return _BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Waste Minimization', style: _T.sectionTitle),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _C.bg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: _C.textSecondary,
                  size: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...metrics.map((m) => _WasteMetricRow(metric: m)),
        ],
      ),
    );
  }
}

class _WasteMetricRow extends StatelessWidget {
  final WasteMetric metric;
  const _WasteMetricRow({required this.metric});

  @override
  Widget build(BuildContext context) {
    final isEnergy = metric.icon == 'energy';
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _C.bg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isEnergy ? Icons.bolt_rounded : Icons.water_drop_outlined,
              color: _C.textPrimary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(metric.title, style: _T.wasteTitle),
                const SizedBox(height: 2),
                Text(metric.subtitle, style: _T.wasteSub),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(metric.delta, style: _T.wasteDelta),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Card: Project Spotlight
// ---------------------------------------------------------------------------

class _ProjectSpotlightCard extends StatelessWidget {
  final ProjectSpotlight spotlight;
  const _ProjectSpotlightCard({required this.spotlight});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _C.navyMid,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(spotlight.label, style: _T.spotlightLabel),
          const SizedBox(height: 10),
          Text(spotlight.title, style: _T.spotlightTitle),
          const SizedBox(height: 8),
          Text(spotlight.description, style: _T.spotlightDesc),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared base card
// ---------------------------------------------------------------------------

class _BaseCard extends StatelessWidget {
  final Widget child;
  const _BaseCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _C.cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: child,
    );
  }
}

// ---------------------------------------------------------------------------
// Helper data class for bottom nav
// ---------------------------------------------------------------------------

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}
