import 'package:flutter/material.dart';
import '../../core/services/manager_service/manager_service.dart';
import '../../../core/utils/theme.dart';
import '../../../widgets/man_bottom_navbar.dart';

class ManagerPaymentsScreen extends StatefulWidget {
  final dynamic factoryId;
  const ManagerPaymentsScreen({super.key, required this.factoryId});

  @override
  State<ManagerPaymentsScreen> createState() => _ManagerPaymentsScreenState();
}

class _ManagerPaymentsScreenState extends State<ManagerPaymentsScreen> {
  final _service = ManagerDashboardService();

  bool loading = true;
  List productions = [];
  String? error;
  String? factoryName; 

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
      // ✅ Payments list
      final res = await _service.getPayments(widget.factoryId);

      // ✅ Factory name — dashboard API se
      final dashboardData = await _service.getDashboard(widget.factoryId);

      setState(() {
        productions  = res;
        factoryName  = dashboardData['factory']?['name'];
        loading      = false;
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
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Payments',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 17)),
            // ✅ Fix: state se aata hai — Get.arguments se nahi
            Text(
              loading ? 'Loading...' : (factoryName ?? 'Factory'),
              style: TextStyle(
                color: Colors.white.withOpacity(0.65),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : error != null
              ? _errorView()
              : productions.isEmpty
                  ? _emptyView()
                  : RefreshIndicator(
                      color: AppTheme.primary,
                      onRefresh: load,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: productions.length,
                        itemBuilder: (_, i) => _paymentCard(productions[i]),
                      ),
                    ),
      bottomNavigationBar: ManagerBottomNav(
        currentIndex: 3,
        factoryId: widget.factoryId,
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

  Widget _emptyView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.credit_card_outlined, size: 48, color: AppTheme.primary),
          const SizedBox(height: 12),
          const Text('No production records yet',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _paymentCard(dynamic p) {
    final statusMap = {
      1: ('Pending',  AppTheme.primary),
      2: ('Approved', AppTheme.success),
      3: ('Rejected', AppTheme.error),
    };
    final status = statusMap[p['status']] ?? ('Unknown', AppTheme.textSecondary);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.cardRadius,
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  p['employeedetails']?['user']?['name']?.toString() ?? 'Employee',
                  style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 15),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: status.$2.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(status.$1,
                    style: TextStyle(
                        color: status.$2, fontSize: 11, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _miniStat('Variety', p['variety_type']?.toString() ?? '—'),
              _miniStat('Length',  '${p['total_length'] ?? 0}'),
              _miniStat('Ready',   '${p['ready_production'] ?? 0}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
          const SizedBox(height: 2),
          Text(value,
              style: const TextStyle(
                  color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 13)),
        ],
      ),
    );
  }
}