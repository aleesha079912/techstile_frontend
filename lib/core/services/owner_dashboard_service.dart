import 'dart:async';
import 'package:get/get.dart';

// --- Models ---
class FactoryHealthData {
  final double healthIndex;
  final String insight;
  const FactoryHealthData({required this.healthIndex, required this.insight});
}

class MonthlyProductionData {
  final double value;
  final double growth;
  const MonthlyProductionData({required this.value, required this.growth});
}

class RevenuePipelineData {
  final double amount;
  final double progress;
  final double growth;
  const RevenuePipelineData({required this.amount, required this.progress, required this.growth});
}

class OwnerDashboardSnapshot {
  final FactoryHealthData health;
  final MonthlyProductionData production;
  final RevenuePipelineData revenue;
  const OwnerDashboardSnapshot({required this.health, required this.production, required this.revenue});
}

// --- Service ---
class OwnerDashboardService {
  OwnerDashboardService._internal();
  static final OwnerDashboardService instance = OwnerDashboardService._internal();
  factory OwnerDashboardService() => instance;

  OwnerDashboardSnapshot? _cachedSnapshot;
  final _snapshotController = StreamController<OwnerDashboardSnapshot>.broadcast();

  Stream<OwnerDashboardSnapshot> get snapshotStream => _snapshotController.stream;
  OwnerDashboardSnapshot? get cachedSnapshot => _cachedSnapshot;

  Future<void> init() async {
    await refresh();
  }

  Future<void> refresh() async {
    // Late loading fix: No unnecessary delays
    final snapshot = OwnerDashboardSnapshot(
      health: const FactoryHealthData(healthIndex: 94.2, insight: "Overall equipment effectiveness is up by 2.4% this week."),
      production: const MonthlyProductionData(value: 124.8, growth: 12),
      revenue: const RevenuePipelineData(amount: 2.4, progress: 0.65, growth: 18),
    );
    _cachedSnapshot = snapshot;
    _snapshotController.add(snapshot);
  }

  void onNavTabSelected(int index) {
    if (index == 1) Get.toNamed('/machines');
    if (index == 2) Get.toNamed('/payments');
    if (index == 3) Get.toNamed('/users');
  }

  void dispose() {
    _snapshotController.close();
  }
}