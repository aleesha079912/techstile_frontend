import 'package:flutter/material.dart';
import '../../core/utils/theme.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _metersCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _wasteCtrl = TextEditingController(text: "5");

  final _workersCtrl = TextEditingController();
  final _wagesCtrl = TextEditingController();
  final _daysCtrl = TextEditingController();

  final _costCtrl = TextEditingController();
  final _marginCtrl = TextEditingController(text: "20");

  double? _fabricTotal;
  double? _laborTotal;
  double? _sellingPrice;
  double? _profit;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _metersCtrl.dispose();
    _priceCtrl.dispose();
    _wasteCtrl.dispose();
    _workersCtrl.dispose();
    _wagesCtrl.dispose();
    _daysCtrl.dispose();
    _costCtrl.dispose();
    _marginCtrl.dispose();
    super.dispose();
  }

  void _calcFabric() {
    final m = double.tryParse(_metersCtrl.text) ?? 0;
    final p = double.tryParse(_priceCtrl.text) ?? 0;
    final w = double.tryParse(_wasteCtrl.text) ?? 0;

    setState(() {
      _fabricTotal = m * p * (1 + w / 100);
    });
  }

  void _calcLabor() {
    final workers = double.tryParse(_workersCtrl.text) ?? 0;
    final wages = double.tryParse(_wagesCtrl.text) ?? 0;
    final days = double.tryParse(_daysCtrl.text) ?? 0;

    setState(() {
      _laborTotal = workers * wages * days;
    });
  }

  void _calcProfit() {
    final cost = double.tryParse(_costCtrl.text) ?? 0;
    final margin = double.tryParse(_marginCtrl.text) ?? 0;

    setState(() {
      _sellingPrice = cost / (1 - margin / 100);
      _profit = (_sellingPrice ?? 0) - cost;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.secondary,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildFabricTab(),
                  _buildLaborTab(),
                  _buildProfitTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.calculate_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Cost Calculator",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 3),
              Text(
                "Fabric · Labor · Profit Margin",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppTheme.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppTheme.neutral,
        tabs: const [
          Tab(text: "Fabric"),
          Tab(text: "Labor"),
          Tab(text: "Profit"),
        ],
      ),
    );
  }

  Widget _buildFabricTab() {
    return _CalcCard(
      title: "Fabric Cost",
      onCalc: _calcFabric,
      result: _fabricTotal != null
          ? "Total Cost: PKR ${_fabricTotal!.toStringAsFixed(2)}"
          : null,
      fields: [
        _CalcField(ctrl: _metersCtrl, label: "Fabric Meters", hint: "500", suffix: "m"),
        _CalcField(ctrl: _priceCtrl, label: "Price per Meter", hint: "150", suffix: "PKR"),
        _CalcField(ctrl: _wasteCtrl, label: "Waste %", hint: "5", suffix: "%"),
      ],
    );
  }

  Widget _buildLaborTab() {
    return _CalcCard(
      title: "Labor Cost",
      onCalc: _calcLabor,
      result: _laborTotal != null
          ? "Total Labor: PKR ${_laborTotal!.toStringAsFixed(2)}"
          : null,
      fields: [
        _CalcField(ctrl: _workersCtrl, label: "Workers", hint: "20", suffix: "ppl"),
        _CalcField(ctrl: _wagesCtrl, label: "Daily Wage", hint: "800", suffix: "PKR"),
        _CalcField(ctrl: _daysCtrl, label: "Days", hint: "26", suffix: "days"),
      ],
    );
  }

  Widget _buildProfitTab() {
    return _CalcCard(
      title: "Profit Margin",
      onCalc: _calcProfit,
      result: _sellingPrice != null
          ? "Selling Price: PKR ${_sellingPrice!.toStringAsFixed(2)}\nProfit: PKR ${_profit!.toStringAsFixed(2)}"
          : null,
      fields: [
        _CalcField(ctrl: _costCtrl, label: "Total Cost", hint: "75000", suffix: "PKR"),
        _CalcField(ctrl: _marginCtrl, label: "Margin", hint: "20", suffix: "%"),
      ],
    );
  }
}

class _CalcCard extends StatelessWidget {
  final String title;
  final List<Widget> fields;
  final VoidCallback onCalc;
  final String? result;

  const _CalcCard({
    required this.title,
    required this.fields,
    required this.onCalc,
    this.result,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            ...fields,
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onCalc,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text("Calculate"),
              ),
            ),
            if (result != null) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.secondary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  result!,
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}

class _CalcField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final String hint;
  final String suffix;

  const _CalcField({
    required this.ctrl,
    required this.label,
    required this.hint,
    required this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          suffixText: suffix,
          filled: true,
          fillColor: AppTheme.secondary,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}