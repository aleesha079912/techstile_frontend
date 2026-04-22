import 'dart:async';

/// Model: Factory Health Index
class FactoryHealthData {
  final double healthIndex;
  final double weeklyChange;
  final String insight;

  const FactoryHealthData({
    required this.healthIndex,
    required this.weeklyChange,
    required this.insight,
  });
}

/// Model: Monthly Production
class MonthlyProductionData {
  final double value; // in thousands
  final String unit;
  final double growthPercent;

  const MonthlyProductionData({
    required this.value,
    required this.unit,
    required this.growthPercent,
  });

  String get formattedValue => '${value.toStringAsFixed(1)}k';
}

/// Model: Revenue Pipeline
class RevenuePipelineData {
  final double amountMillions;
  final double growthPercent;
  final double progressRatio; // 0.0 – 1.0

  const RevenuePipelineData({
    required this.amountMillions,
    required this.growthPercent,
    required this.progressRatio,
  });

  String get formattedAmount => '\$${amountMillions.toStringAsFixed(1)}M';
}

/// Model: Single bar in the Financial Flux chart
class FinancialFluxBar {
  final String month;
  final double gross; // normalised 0–1
  final double cost; // normalised 0–1

  const FinancialFluxBar({
    required this.month,
    required this.gross,
    required this.cost,
  });
}

/// Model: Active Looms
class ActiveLoomsData {
  final int active;
  final int total;
  final int maintenanceDue;

  const ActiveLoomsData({
    required this.active,
    required this.total,
    required this.maintenanceDue,
  });

  double get utilizationRatio => total > 0 ? active / total : 0.0;
  int get utilizationPercent => (utilizationRatio * 100).round();
}

/// Model: Single waste-minimization metric
class WasteMetric {
  final String icon; // asset path or icon key
  final String title;
  final String subtitle;
  final String delta; // e.g. '+1.2 kg', '-8% kWh'
  final bool isPositive;

  const WasteMetric({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.delta,
    required this.isPositive,
  });
}

/// Model: Project Spotlight card
class ProjectSpotlight {
  final String label;
  final String title;
  final String description;

  const ProjectSpotlight({
    required this.label,
    required this.title,
    required this.description,
  });
}

/// Aggregated dashboard snapshot
class OwnerDashboardSnapshot {
  final FactoryHealthData factoryHealth;
  final MonthlyProductionData monthlyProduction;
  final RevenuePipelineData revenuePipeline;
  final List<FinancialFluxBar> financialFlux;
  final ActiveLoomsData activeLooms;
  final List<WasteMetric> wasteMetrics;
  final ProjectSpotlight projectSpotlight;

  const OwnerDashboardSnapshot({
    required this.factoryHealth,
    required this.monthlyProduction,
    required this.revenuePipeline,
    required this.financialFlux,
    required this.activeLooms,
    required this.wasteMetrics,
    required this.projectSpotlight,
  });
}

/// Service: provides dashboard data and handles refresh / polling logic.
///
/// In a real app, replace the `_fetch*` methods with actual API calls.
/// The service exposes a [Stream] so the UI can reactively rebuild on
/// every refresh without coupling itself to the data-fetching strategy.
class OwnerDashboardService {
  // ---------------------------------------------------------------------------
  // Singleton / lifecycle
  // ---------------------------------------------------------------------------

  OwnerDashboardService._internal();
  static final OwnerDashboardService instance = OwnerDashboardService._internal();
  factory OwnerDashboardService() => instance;

  // ---------------------------------------------------------------------------
  // Internal state
  // ---------------------------------------------------------------------------

  OwnerDashboardSnapshot? _cachedSnapshot;
  bool _isLoading = false;
  String? _errorMessage;

  final _snapshotController =
      StreamController<OwnerDashboardSnapshot>.broadcast();
  Timer? _pollingTimer;

  // ---------------------------------------------------------------------------
  // Public surface
  // ---------------------------------------------------------------------------

  /// Live stream of dashboard snapshots.
  Stream<OwnerDashboardSnapshot> get snapshotStream => _snapshotController.stream;

  /// Last successfully loaded snapshot (may be null before first load).
  OwnerDashboardSnapshot? get cachedSnapshot => _cachedSnapshot;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Initialise the service: performs first fetch and starts auto-refresh.
  Future<void> init({Duration pollingInterval = const Duration(minutes: 5)}) async {
    await refresh();
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(pollingInterval, (_) => refresh());
  }

  /// Manually trigger a data refresh.
  Future<void> refresh() async {
    if (_isLoading) return;
    _isLoading = true;
    _errorMessage = null;

    try {
      final snapshot = await _buildSnapshot();
      _cachedSnapshot = snapshot;
      _snapshotController.add(snapshot);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
    }
  }

  /// Dispose timers and stream controllers when the screen is removed.
  void dispose() {
    _pollingTimer?.cancel();
    _snapshotController.close();
  }

  // ---------------------------------------------------------------------------
  // Data assembly
  // ---------------------------------------------------------------------------

  Future<OwnerDashboardSnapshot> _buildSnapshot() async {
    // Simulate network latency; replace with real parallel API calls.
    await Future.delayed(const Duration(milliseconds: 600));

    return OwnerDashboardSnapshot(
      factoryHealth: _fetchFactoryHealth(),
      monthlyProduction: _fetchMonthlyProduction(),
      revenuePipeline: _fetchRevenuePipeline(),
      financialFlux: _fetchFinancialFlux(),
      activeLooms: _fetchActiveLooms(),
      wasteMetrics: _fetchWasteMetrics(),
      projectSpotlight: _fetchProjectSpotlight(),
    );
  }

  // ---------------------------------------------------------------------------
  // Individual data providers (swap for real API calls)
  // ---------------------------------------------------------------------------

  FactoryHealthData _fetchFactoryHealth() {
    return const FactoryHealthData(
      healthIndex: 94.2,
      weeklyChange: 2.4,
      insight:
          'Overall equipment effectiveness is up by 2.4% this week, '
          'driven by high-speed loom optimization in sector B.',
    );
  }

  MonthlyProductionData _fetchMonthlyProduction() {
    return const MonthlyProductionData(
      value: 124.8,
      unit: 'Yards of premium weave',
      growthPercent: 12,
    );
  }

  RevenuePipelineData _fetchRevenuePipeline() {
    return const RevenuePipelineData(
      amountMillions: 2.4,
      growthPercent: 18,
      progressRatio: 0.65,
    );
  }

  List<FinancialFluxBar> _fetchFinancialFlux() {
    return const [
      FinancialFluxBar(month: 'JUL', gross: 0.55, cost: 0.35),
      FinancialFluxBar(month: 'AUG', gross: 0.65, cost: 0.42),
      FinancialFluxBar(month: 'SEP', gross: 0.90, cost: 0.60),
      FinancialFluxBar(month: 'OCT', gross: 0.70, cost: 0.48),
    ];
  }

  ActiveLoomsData _fetchActiveLooms() {
    return const ActiveLoomsData(
      active: 18,
      total: 22,
      maintenanceDue: 4,
    );
  }

  List<WasteMetric> _fetchWasteMetrics() {
    return const [
      WasteMetric(
        icon: 'fiber',
        title: 'Fiber Recovery',
        subtitle: 'Reclaiming 12% more raw silk than last quarter',
        delta: '+1.2 kg',
        isPositive: true,
      ),
      WasteMetric(
        icon: 'energy',
        title: 'Energy Consumption',
        subtitle: 'Off-peak run hours optimized',
        delta: '-8% kWh',
        isPositive: true,
      ),
    ];
  }

  ProjectSpotlight _fetchProjectSpotlight() {
    return const ProjectSpotlight(
      label: 'PROJECT SPOTLIGHT',
      title: 'Midnight Silk\nBatch #402',
      description:
          '98% Quality Score. Ready for dispatch to Milan workshop.',
    );
  }

  // ---------------------------------------------------------------------------
  // Action handlers
  // ---------------------------------------------------------------------------

  /// Navigate to / open the maintenance log screen.
  /// Wire this to your router in the UI layer.
  void onViewMaintenanceLogTapped() {
    // TODO: router.push('/maintenance-log');
  }

  /// Triggered when a bottom-nav tab is selected.
  void onNavTabSelected(int index) {
    // 0 = Dashboard, 1 = Machines, 2 = Payments, 3 = Users
    // TODO: handle navigation via your router/state-management solution.
  }
}