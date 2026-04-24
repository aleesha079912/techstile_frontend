import 'package:flutter/material.dart';

const _navy   = Color(0xFF1E3A8A);
const _blue   = Color(0xFF2563EB);
const _bgPage = Color(0xFFF0F4FF);
const _white  = Colors.white;
const _slate  = Color(0xFF64748B);

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Fabric Cost fields
  final _metersCtrl    = TextEditingController();
  final _priceCtrl     = TextEditingController();
  final _wasteCtrl     = TextEditingController(text: "5");
  double? _fabricTotal;

  // Labor Cost fields
  final _workersCtrl   = TextEditingController();
  final _wagesCtrl     = TextEditingController();
  final _daysCtrl      = TextEditingController();
  double? _laborTotal;

  // Profit Margin fields
  final _costCtrl      = TextEditingController();
  final _marginCtrl    = TextEditingController(text: "20");
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
    _metersCtrl.dispose(); _priceCtrl.dispose(); _wasteCtrl.dispose();
    _workersCtrl.dispose(); _wagesCtrl.dispose(); _daysCtrl.dispose();
    _costCtrl.dispose(); _marginCtrl.dispose();
    super.dispose();
  }

  void _calcFabric() {
    final m  = double.tryParse(_metersCtrl.text) ?? 0;
    final p  = double.tryParse(_priceCtrl.text) ?? 0;
    final w  = double.tryParse(_wasteCtrl.text) ?? 0;
    setState(() {
      _fabricTotal = m * p * (1 + w / 100);
    });
  }

  void _calcLabor() {
    final workers = double.tryParse(_workersCtrl.text) ?? 0;
    final wages   = double.tryParse(_wagesCtrl.text) ?? 0;
    final days    = double.tryParse(_daysCtrl.text) ?? 0;
    setState(() {
      _laborTotal = workers * wages * days;
    });
  }

  void _calcProfit() {
    final cost   = double.tryParse(_costCtrl.text) ?? 0;
    final margin = double.tryParse(_marginCtrl.text) ?? 0;
    setState(() {
      _sellingPrice = cost / (1 - margin / 100);
      _profit       = (_sellingPrice ?? 0) - cost;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_navy, Color(0xFF1D4ED8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _navy.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.calculate_rounded, color: _white, size: 24),
          ),
          const SizedBox(width: 14),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Cost Calculator",
                style: TextStyle(
                  color: _white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 3),
              Text(
                "Fabric · Labor · Profit Margin",
                style: TextStyle(
                  color: Colors.white60,
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
        color: _white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: _navy.withOpacity(0.06), blurRadius: 8),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: _navy,
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: _white,
        unselectedLabelColor: _slate,
        labelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        tabs: const [
          Tab(text: "Fabric"),
          Tab(text: "Labor"),
          Tab(text: "Profit"),
        ],
      ),
    );
  }

  Widget _buildFabricTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _CalcCard(
            title: "Fabric Cost",
            icon: Icons.bolt_rounded,
            iconColor: const Color(0xFF0891B2),
            fields: [
              _CalcField(
                ctrl: _metersCtrl,
                label: "Fabric Meters",
                hint: "e.g. 500",
                suffix: "m",
              ),
              _CalcField(
                ctrl: _priceCtrl,
                label: "Price per Meter",
                hint: "e.g. 150",
                suffix: "PKR",
              ),
              _CalcField(
                ctrl: _wasteCtrl,
                label: "Waste %",
                hint: "e.g. 5",
                suffix: "%",
              ),
            ],
            onCalc: _calcFabric,
            result: _fabricTotal != null
                ? "Total Cost: PKR ${_fabricTotal!.toStringAsFixed(2)}"
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildLaborTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _CalcCard(
            title: "Labor Cost",
            icon: Icons.people_rounded,
            iconColor: const Color(0xFF7C3AED),
            fields: [
              _CalcField(
                ctrl: _workersCtrl,
                label: "Number of Workers",
                hint: "e.g. 20",
                suffix: "ppl",
              ),
              _CalcField(
                ctrl: _wagesCtrl,
                label: "Daily Wage",
                hint: "e.g. 800",
                suffix: "PKR",
              ),
              _CalcField(
                ctrl: _daysCtrl,
                label: "Working Days",
                hint: "e.g. 26",
                suffix: "days",
              ),
            ],
            onCalc: _calcLabor,
            result: _laborTotal != null
                ? "Total Labor: PKR ${_laborTotal!.toStringAsFixed(2)}"
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildProfitTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _CalcCard(
            title: "Profit Margin",
            icon: Icons.trending_up_rounded,
            iconColor: const Color(0xFF059669),
            fields: [
              _CalcField(
                ctrl: _costCtrl,
                label: "Total Cost",
                hint: "e.g. 75000",
                suffix: "PKR",
              ),
              _CalcField(
                ctrl: _marginCtrl,
                label: "Desired Margin",
                hint: "e.g. 20",
                suffix: "%",
              ),
            ],
            onCalc: _calcProfit,
            result: _sellingPrice != null
                ? "Selling Price: PKR ${_sellingPrice!.toStringAsFixed(2)}\nProfit: PKR ${_profit!.toStringAsFixed(2)}"
                : null,
          ),
        ],
      ),
    );
  }
}

// ─── Calc Card ───────────────────────────────────────────────
class _CalcCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final List<_CalcField> fields;
  final VoidCallback onCalc;
  final String? result;

  const _CalcCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.fields,
    required this.onCalc,
    this.result,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _navy.withOpacity(0.07),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...fields.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: f,
              )),
          const SizedBox(height: 4),
          SizedBox(
            width: double.infinity,
            child: _GradientButton(
              label: "Calculate",
              onTap: onCalc,
            ),
          ),
          if (result != null) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFBFDBFE),
                  width: 1,
                ),
              ),
              child: Text(
                result!,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _navy,
                  height: 1.6,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Calc Field ──────────────────────────────────────────────
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
    return TextField(
      controller: ctrl,
      keyboardType: TextInputType.number,
      style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixText: suffix,
        labelStyle: const TextStyle(
          color: _blue,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        suffixStyle: const TextStyle(
          color: _slate,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        filled: true,
        fillColor: const Color(0xFFF8FAFF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _blue, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}

// ─── Gradient Button ─────────────────────────────────────────
class _GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _GradientButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [_navy, _blue]),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 13),
            child: Center(
              child: Text(
                label,
                style: const TextStyle(
                  color: _white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}