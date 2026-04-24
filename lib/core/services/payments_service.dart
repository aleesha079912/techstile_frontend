enum PaymentStatus { verified, pending, priorityReview, adjustment }

enum PaymentAction { approved, onHold, none }

class PaymentWorker {
  final String id;
  final String name;
  final String role;
  final double amountDue;
  final String period;
  final PaymentStatus status;
  PaymentAction action;

  PaymentWorker({
    required this.id,
    required this.name,
    required this.role,
    required this.amountDue,
    required this.period,
    required this.status,
    this.action = PaymentAction.none,
  });

  String get formattedAmount =>
      '\$${amountDue.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+\.)'), (m) => '${m[1]},')}';
}

class CutoffInfo {
  final int daysLeft;
  final String deadline;
  final double complianceLevel;

  const CutoffInfo({
    required this.daysLeft,
    required this.deadline,
    required this.complianceLevel,
  });
}

class PaymentsService {
  PaymentsService._();
  static final PaymentsService instance = PaymentsService._();
  factory PaymentsService() => instance;

  // ── State ──────────────────────────────────────────────────────────────────

  List<PaymentWorker> _workers = [];
  CutoffInfo? cutoffInfo;
  bool isLoading = false;

  List<PaymentWorker> get workers => List.unmodifiable(_workers);

  // ── Load ───────────────────────────────────────────────────────────────────

  Future<void> load() async {
    isLoading = true;
    await Future.delayed(const Duration(milliseconds: 400));

    _workers = [
      PaymentWorker(
        id: '1',
        name: 'Elena Rodriguez',
        role: 'Master Weaver • Shift A',
        amountDue: 1240.50,
        period: 'Oct 01 - Oct 14',
        status: PaymentStatus.verified,
      ),
      PaymentWorker(
        id: '2',
        name: 'Marcus Thorne',
        role: 'Maintenance Lead • All Shifts',
        amountDue: 2890.00,
        period: 'Oct 01 - Oct 14',
        status: PaymentStatus.pending,
      ),
      PaymentWorker(
        id: '3',
        name: 'Sarah Jenkins',
        role: 'Quality Control Specialist',
        amountDue: 1950.25,
        period: 'Oct 01 - Oct 14',
        status: PaymentStatus.priorityReview,
      ),
      PaymentWorker(
        id: '4',
        name: 'David Chen',
        role: 'Logistics Coordinator',
        amountDue: 1150.00,
        period: 'Oct 01 - Oct 14',
        status: PaymentStatus.verified,
      ),
      PaymentWorker(
        id: '5',
        name: 'Amara Okafor',
        role: 'Machine Operator • Shift B',
        amountDue: 980.75,
        period: 'Oct 01 - Oct 14',
        status: PaymentStatus.adjustment,
      ),
    ];

    cutoffInfo = const CutoffInfo(
      daysLeft: 3,
      deadline: 'Friday, 6:00 PM EST',
      complianceLevel: 98.2,
    );

    isLoading = false;
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  void approve(String id) {
    final w = _workers.firstWhere((w) => w.id == id);
    w.action = PaymentAction.approved;
  }

  void hold(String id) {
    final w = _workers.firstWhere((w) => w.id == id);
    w.action = PaymentAction.onHold;
  }

  void approveAll() {
    for (final w in _workers) {
      w.action = PaymentAction.approved;
    }
  }

  int get pendingCount =>
      _workers.where((w) => w.action == PaymentAction.none).length;
}