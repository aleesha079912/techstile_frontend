import 'dart:async';

class FactoryHealthData {
  final double healthIndex;
  final String insight;

  const FactoryHealthData({
    required this.healthIndex,
    required this.insight,
  });
}

class MonthlyProductionData {
  final double value;
  final double growth;

  const MonthlyProductionData({
    required this.value,
    required this.growth,
  });
}

class RevenuePipelineData {
  final double amount;
  final double progress;
  final double growth;

  const RevenuePipelineData({
    required this.amount,
    required this.progress,
    required this.growth,
  });
}

class OwnerDashboardSnapshot {
  final FactoryHealthData health;
  final MonthlyProductionData production;
  final RevenuePipelineData revenue;

  const OwnerDashboardSnapshot({
    required this.health,
    required this.production,
    required this.revenue,
  });
}

class OwnerDashboardService {
  OwnerDashboardService._internal();
  static final OwnerDashboardService instance =
      OwnerDashboardService._internal();

  final StreamController<OwnerDashboardSnapshot> _controller =
      StreamController.broadcast();

  Stream<OwnerDashboardSnapshot> get stream => _controller.stream;

  final Map<int, OwnerDashboardSnapshot> _cache = {};

  OwnerDashboardSnapshot? getSnapshot(int factoryId) {
    return _cache[factoryId];
  }

  Future<void> init(int factoryId) async {
    await refresh(factoryId);
  }

  Future<void> refresh(int factoryId) async {
    final snapshot = OwnerDashboardSnapshot(
      health: FactoryHealthData(
        healthIndex: 80 + factoryId.toDouble(),
        insight: "Factory $factoryId running normally",
      ),
      production: MonthlyProductionData(
        value: 120 + factoryId.toDouble(),
        growth: 10 + factoryId.toDouble(),
      ),
      revenue: RevenuePipelineData(
        amount: 2 + factoryId.toDouble(),
        progress: 0.5,
        growth: 12 + factoryId.toDouble(),
      ),
    );

    _cache[factoryId] = snapshot;
    _controller.add(snapshot);
  }
}