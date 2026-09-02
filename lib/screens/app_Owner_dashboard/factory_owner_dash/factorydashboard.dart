import 'package:flutter/material.dart';
import 'package:techstile_frontend/core/services/factory_dashboard_service.dart';
import 'package:techstile_frontend/core/utils/theme.dart';
import 'package:techstile_frontend/widgets/bottom_nav_bar.dart';
import 'package:get/get.dart';
import 'package:techstile_frontend/routes/routes.dart';


class FactoryDashboard extends StatefulWidget {
  final String factoryId;

  const FactoryDashboard({
    super.key,
    required this.factoryId,
  });

  @override
  State<FactoryDashboard> createState() => _FactoryDashboardState();
}

class _FactoryDashboardState extends State<FactoryDashboard> {
  final _service = FactoryDashboardService();

  bool loading = true;
  bool updatingWeekStart = false;

  Map data = {};
  String? error;

  // ─────────────────────────────────────────────────────────────────────────
  // Common shadow
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

  // Very light primary outline used on all boxes
  static Border get _primaryBorder => Border.all(
        color: AppTheme.primary.withOpacity(0.10),
        width: 1,
      );

  // ─────────────────────────────────────────────────────────────────────────
  // Period options
  // ─────────────────────────────────────────────────────────────────────────

  static const List<Map<String, String>> periodOptions = [
    {
      'key': 'this_week',
      'label': 'This Week',
    },
    {
      'key': 'previous_week',
      'label': 'Previous Week',
    },
    {
      'key': 'this_month',
      'label': 'This Month',
    },
    {
      'key': 'previous_month',
      'label': 'Previous Month',
    },
    {
      'key': 'this_year',
      'label': 'This Year',
    },
    {
      'key': 'previous_year',
      'label': 'Previous Year',
    },
  ];

  String selectedPeriodKey = 'this_week';

  static const List<String> weekDayNames = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];

  String get selectedPeriodLabel => periodOptions
      .firstWhere(
        (p) => p['key'] == selectedPeriodKey,
        orElse: () => periodOptions.first,
      )['label']!;

  int get factoryId => int.parse(widget.factoryId);

  // ─────────────────────────────────────────────────────────────────────────
  // Lifecycle
  // ─────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    load();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Load dashboard
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> load() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final res = await _service.getDashboard(
        widget.factoryId,
        period: selectedPeriodKey,
      );

      if (!mounted) return;

      setState(() {
        data = res;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Period changed
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> onPeriodChanged(String periodKey) async {
    if (periodKey == selectedPeriodKey) return;

    setState(() {
      selectedPeriodKey = periodKey;
    });

    await load();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Back to owner home
  // ─────────────────────────────────────────────────────────────────────────

  void _goBackToOwnerHome() {
    Get.offAllNamed(
      AppRoutes.ownerDashboard,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Week start picker
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _openWeekStartDayPicker() async {
    final current = (data['week_start_day'] as int?) ?? 1;

    int? picked = current;

    final result = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: AppTheme.secondary,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final bottomInset =
                MediaQuery.of(context).viewInsets.bottom;

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: bottomInset,
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Week starts on',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Choose the day your factory week begins. '
                        '"This Week" and "Previous Week" will be calculated from this day.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textPrimary
                              .withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: List.generate(
                          weekDayNames.length,
                          (i) {
                            final selected = picked == i;

                            return ChoiceChip(
                              label: Text(
                                weekDayNames[i],
                              ),
                              selected: selected,
                              selectedColor:
                                  AppTheme.primary,
                              labelStyle: TextStyle(
                                color: selected
                                    ? AppTheme.secondary
                                    : AppTheme.textPrimary,
                                fontWeight:
                                    FontWeight.w600,
                              ),
                              onSelected: (_) {
                                setSheetState(() {
                                  picked = i;
                                });
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(
                              context,
                              picked,
                            );
                          },
                          style:
                              ElevatedButton.styleFrom(
                            backgroundColor:
                                AppTheme.primary,
                            padding:
                                const EdgeInsets.symmetric(
                              vertical: 13,
                            ),
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Save',
                            style: TextStyle(
                              color:
                                  AppTheme.secondary,
                              fontWeight:
                                  FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    if (result == null || result == current) return;

    setState(() {
      updatingWeekStart = true;
    });

    try {
      await _service.updateWeekStartDay(
        widget.factoryId,
        result,
      );

      await load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not update week start day: $e',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          updatingWeekStart = false;
        });
      }
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Today label
  // ─────────────────────────────────────────────────────────────────────────

  String _todayLabel() {
    final dayName =
        data['today_day_name']?.toString();

    final dateStr =
        data['today_date']?.toString();

    if (dayName == null || dateStr == null) {
      return 'Today';
    }

    try {
      final dt = DateTime.parse(dateStr);

      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];

      return 'Today, $dayName ${dt.day} ${months[dt.month - 1]}';
    } catch (_) {
      return 'Today, $dayName';
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,

      appBar: _buildAppBar(),

      body: loading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primary,
              ),
            )
          : error != null
              ? _errorView()
              : RefreshIndicator(
                  color: AppTheme.primary,
                  onRefresh: load,
                  child: SingleChildScrollView(
                    physics:
                        const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      16,
                      16,
                      32,
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        // ─────────────────────────────────────────────
                        // Period header
                        // ─────────────────────────────────────────────

                        Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  _SectionLabel(
                                    text:
                                        selectedPeriodLabel,
                                  ),

                                  if (data['range_label'] !=
                                      null) ...[
                                    const SizedBox(height: 4),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(
                                        left: 12,
                                      ),
                                      child: Text(
                                        data['range_label']
                                            .toString(),
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          color: AppTheme
                                              .primary
                                              .withOpacity(
                                                  0.55),
                                          fontWeight:
                                              FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            _weekStartButton(),

                            const SizedBox(width: 8),

                            _periodFilterDropdown(),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // ─────────────────────────────────────────────
                        // Main stats
                        // ─────────────────────────────────────────────

                        Row(
                          children: [
                            _statCard(
                              icon:
                                  Icons.today_rounded,
                              label: _todayLabel(),
                              value:
                                  "${data['today_units'] ?? 0}",
                              unit: 'yards',
                              color:
                                  AppTheme.success,
                            ),

                            const SizedBox(width: 12),

                            _statCard(
                              icon: Icons
                                  .calendar_month_rounded,
                              label:
                                  selectedPeriodLabel,
                              value:
                                  "${data['period_units'] ?? data['weekly_units'] ?? 0}",
                              unit: 'yards',
                              color:
                                  AppTheme.primary,
                            ),
                          ],
                        ),

                        // ─────────────────────────────────────────────
                        // Today breakdown
                        // ─────────────────────────────────────────────

                        _pipelineBreakdown(
                          title: 'Today',
                          breakdown:
                              data['today_breakdown']
                                  as Map?,
                        ),

                        // ─────────────────────────────────────────────
                        // This week breakdown
                        // ─────────────────────────────────────────────

                        if (selectedPeriodKey ==
                            'this_week')
                          _pipelineBreakdown(
                            title: 'This Week',
                            breakdown:
                                data['period_breakdown']
                                    as Map?,
                          ),

                        const SizedBox(height: 20),

                        // ─────────────────────────────────────────────
                        // Floor Assets
                        // ─────────────────────────────────────────────

                        const _SectionLabel(
                          text: 'Floor Assets',
                        ),

                        const SizedBox(height: 12),

                        Row(
                          children: [
                            _statCard(
                              icon: Icons
                                  .precision_manufacturing_rounded,
                              label:
                                  'Total Machines',
                              value:
                                  "${data['machines_count'] ?? 0}",
                              color:
                                  AppTheme.primary,
                            ),

                            const SizedBox(width: 12),

                            _statCard(
                              icon:
                                  Icons.groups_rounded,
                              label:
                                  'Total Employees',
                              value:
                                  "${data['employees_count'] ?? 0}",
                              color: const Color(
                                0xFF7B61FF,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // ─────────────────────────────────────────────
                        // Varieties
                        // ─────────────────────────────────────────────

                        _SectionLabel(
                          text:
                              'Varieties (${data['total_varieties'] ?? 0})',
                        ),

                        const SizedBox(height: 12),

                        _varietiesList(),
                      ],
                    ),
                  ),
                ),

      bottomNavigationBar: CustomBottomNav(
        currentIndex: 0,
        factoryId: factoryId,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // AppBar
  // ─────────────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    final factory = data['factory'];

    return AppBar(
      backgroundColor: AppTheme.secondary,

      iconTheme: const IconThemeData(
        color: AppTheme.primary,
      ),

      elevation: 0,

      // Manual back button
      automaticallyImplyLeading: false,

      leading: IconButton(
        onPressed: _goBackToOwnerHome,
        tooltip: 'Back to Owner Home',
        icon: const Icon(
          Icons.arrow_back_rounded,
          size: 25,
          color: AppTheme.primary,
        ),
      ),

      titleSpacing: 4,

      title: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'Factory Dashboard',
            style: TextStyle(
              color: AppTheme.primary,
              fontWeight: FontWeight.w800,
              fontSize: 19,
            ),
          ),

          const SizedBox(height: 1),

          Text(
            loading
                ? 'Loading...'
                : (factory?['name'] ?? 'Factory'),
            style: TextStyle(
              color:
                  AppTheme.primary.withOpacity(0.65),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),

      actions: [
        Padding(
          padding: const EdgeInsets.only(
            right: 12,
          ),
          child: Center(
            child: _viewProductionsButton(),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Error view
  // ─────────────────────────────────────────────────────────────────────────

  Widget _errorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: AppTheme.error,
            ),

            const SizedBox(height: 12),

            Text(
              error ?? 'Something went wrong',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color:
                    AppTheme.textSecondary,
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: load,
              child: const Text(
                'Retry',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Productions button
  // ─────────────────────────────────────────────────────────────────────────

  Widget _viewProductionsButton() {
    return ElevatedButton.icon(
      onPressed: () {
        Get.toNamed(
          AppRoutes.ownerProduction,
          arguments: widget.factoryId,
        );
      },

      icon: const Icon(
        Icons.list_alt_rounded,
        size: 18,
      ),

      label: const Text(
        'Productions',
        style: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 13,
        ),
      ),

      style: ElevatedButton.styleFrom(
        backgroundColor:
            AppTheme.primary,

        foregroundColor:
            AppTheme.secondary,

        elevation: 0,

        padding:
            const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 10,
        ),

        minimumSize: const Size(
          0,
          42,
        ),

        tapTargetSize:
            MaterialTapTargetSize.shrinkWrap,

        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(11),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Period filter dropdown
  // ─────────────────────────────────────────────────────────────────────────

  Widget _periodFilterDropdown() {
    return PopupMenuButton<String>(
      initialValue:
          selectedPeriodKey,

      onSelected:
          onPeriodChanged,

      offset: const Offset(
        0,
        40,
      ),

      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(12),
      ),

      color:
          AppTheme.secondary,

      itemBuilder: (context) {
        return periodOptions
            .map(
              (period) {
                final bool isSelected =
                    period['key'] ==
                        selectedPeriodKey;

                return PopupMenuItem<String>(
                  value:
                      period['key'],

                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .spaceBetween,
                    children: [
                      Text(
                        period['label']!,
                        style:
                            TextStyle(
                          color:
                              AppTheme
                                  .textPrimary,
                          fontWeight:
                              isSelected
                                  ? FontWeight
                                      .w800
                                  : FontWeight
                                      .w500,
                          fontSize: 14,
                        ),
                      ),

                      if (isSelected)
                        const Icon(
                          Icons
                              .check_rounded,
                          color:
                              AppTheme
                                  .success,
                          size: 18,
                        ),
                    ],
                  ),
                );
              },
            )
            .toList();
      },

      child: Container(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 9,
        ),

        decoration:
            BoxDecoration(
          color:
              AppTheme.secondary,

          borderRadius:
              BorderRadius.circular(12),

          // Outer shadow
          boxShadow:
              _primaryShadow,

          // Light primary outline
          border:
              _primaryBorder,
        ),

        child: Row(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            const Icon(
              Icons
                  .filter_list_rounded,
              color:
                  AppTheme.primary,
              size: 16,
            ),

            const SizedBox(
              width: 6,
            ),

            Text(
              selectedPeriodLabel,
              style:
                  const TextStyle(
                color:
                    AppTheme.primary,
                fontWeight:
                    FontWeight.w700,
                fontSize: 13,
              ),
            ),

            const SizedBox(
              width: 4,
            ),

            const Icon(
              Icons
                  .keyboard_arrow_down_rounded,
              color:
                  AppTheme.primary,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Week start button
  // ─────────────────────────────────────────────────────────────────────────

  Widget _weekStartButton() {
    return InkWell(
      borderRadius:
          BorderRadius.circular(10),

      onTap: updatingWeekStart
          ? null
          : _openWeekStartDayPicker,

      child: Container(
        width: 36,
        height: 36,

        decoration:
            BoxDecoration(
          color:
              AppTheme.secondary,

          borderRadius:
              BorderRadius.circular(10),

          // Outer shadow
          boxShadow:
              _primaryShadow,

          // Light primary outline
          border:
              _primaryBorder,
        ),

        alignment:
            Alignment.center,

        child: updatingWeekStart
            ? const SizedBox(
                width: 16,
                height: 16,
                child:
                    CircularProgressIndicator(
                  strokeWidth: 2,
                  color:
                      AppTheme.primary,
                ),
              )
            : const Icon(
                Icons.add_rounded,
                color:
                    AppTheme.primary,
                size: 20,
              ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Pipeline breakdown
  // ─────────────────────────────────────────────────────────────────────────

  Widget _pipelineBreakdown({
    required String title,
    Map? breakdown,
  }) {
    if (breakdown == null) {
      return const SizedBox.shrink();
    }

    final added =
        breakdown['employee_added'] ?? 0;

    final mgrOk =
        breakdown['manager_approved'] ?? 0;

    return Padding(
      padding:
          const EdgeInsets.only(
        top: 10,
      ),

      child: Container(
        width: double.infinity,

        padding:
            const EdgeInsets.all(12),

        decoration:
            BoxDecoration(
          color:
              AppTheme.secondary,

          borderRadius:
              BorderRadius.circular(14),

          // Main breakdown outer shadow
          boxShadow:
              _primaryShadow,

          // Light primary outline
          border:
              _primaryBorder,
        ),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            Text(
              '$title breakdown',
              style: TextStyle(
                fontSize: 12,
                fontWeight:
                    FontWeight.w800,
                color: AppTheme
                    .textPrimary
                    .withOpacity(
                  0.78,
                ),
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            Row(
              children: [
                _breakdownChip(
                  'Added',
                  added,
                  AppTheme.neutral,
                ),

                const SizedBox(
                  width: 8,
                ),

                _breakdownChip(
                  'Mgr ✓',
                  mgrOk,
                  AppTheme.info,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Breakdown chip
  // ─────────────────────────────────────────────────────────────────────────

  Widget _breakdownChip(
    String label,
    dynamic value,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding:
            const EdgeInsets.symmetric(
          vertical: 9,
          horizontal: 6,
        ),

        decoration:
            BoxDecoration(
          color:
              color.withOpacity(0.10),

          borderRadius:
              BorderRadius.circular(10),

          // Outer shadow ONLY.
          // No inset/internal shadow.
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary
                  .withOpacity(0.08),
              blurRadius: 8,
              offset:
                  const Offset(0, 3),
            ),
          ],

          // Very light primary outline
          border: Border.all(
            color: AppTheme.primary
                .withOpacity(0.18),
            width: 0.8,
          ),
        ),

        child: Column(
          children: [
            Text(
              '$value',
              style: TextStyle(
                color: color,
                fontWeight:
                    FontWeight.w800,
                fontSize: 14,
              ),
            ),

            const SizedBox(
              height: 2,
            ),

            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight:
                    FontWeight.w600,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Stat card
  // ─────────────────────────────────────────────────────────────────────────

  Widget _statCard({
    required IconData icon,
    required String label,
    required String value,
    String? unit,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding:
            const EdgeInsets.all(16),

        decoration:
            BoxDecoration(
          color:
              AppTheme.secondary,

          borderRadius:
              BorderRadius.circular(18),

          // Outer shadow
          boxShadow:
              _primaryShadow,

          // Light primary outline
          border:
              _primaryBorder,
        ),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            Container(
              padding:
                  const EdgeInsets.all(8),

              decoration:
                  BoxDecoration(
                color:
                    color.withOpacity(
                  0.12,
                ),

                borderRadius:
                    BorderRadius.circular(
                  10,
                ),
              ),

              child: Icon(
                icon,
                color: color,
                size: 18,
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            Text(
              value,
              style:
                  const TextStyle(
                color:
                    AppTheme.textPrimary,
                fontSize: 24,
                fontWeight:
                    FontWeight.w800,
              ),
            ),

            const SizedBox(
              height: 2,
            ),

            Text(
              '$label${unit != null ? ' ($unit)' : ''}',
              style:
                  const TextStyle(
                color:
                    AppTheme.textPrimary,
                fontSize: 11,
                fontWeight:
                    FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Varieties list
  // ─────────────────────────────────────────────────────────────────────────

  Widget _varietiesList() {
    final varieties =
        (data['varieties'] as List?) ?? [];

    // Empty state
    if (varieties.isEmpty) {
      return Container(
        width: double.infinity,

        padding:
            const EdgeInsets.symmetric(
          vertical: 32,
        ),

        decoration:
            BoxDecoration(
          color:
              AppTheme.secondary,

          borderRadius:
              BorderRadius.circular(18),

          // Outer shadow
          boxShadow:
              _primaryShadow,

          // Light primary outline
          border:
              _primaryBorder,
        ),

        child: Column(
          children: [
            const Icon(
              Icons
                  .inventory_2_outlined,
              size: 40,
              color:
                  AppTheme.primary,
            ),

            const SizedBox(
              height: 10,
            ),

            const Text(
              'No varieties produced yet',
              style:
                  TextStyle(
                color:
                    AppTheme.textPrimary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    // Varieties container
    return Container(
      decoration:
          BoxDecoration(
        color:
            AppTheme.secondary,

        borderRadius:
            BorderRadius.circular(18),

        // Outer shadow
        boxShadow:
            _primaryShadow,

        // Light primary outline
        border:
            _primaryBorder,
      ),

      child: Column(
        children: List.generate(
          varieties.length,
          (i) {
            final item =
                varieties[i];

            final isLast =
                i ==
                    varieties.length -
                        1;

            return Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),

                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,

                        decoration:
                            BoxDecoration(
                          color: AppTheme
                              .success
                              .withOpacity(
                            0.12,
                          ),

                          borderRadius:
                              BorderRadius
                                  .circular(
                            10,
                          ),
                        ),

                        child:
                            const Icon(
                          Icons
                              .texture_rounded,
                          color:
                              AppTheme
                                  .success,
                          size: 16,
                        ),
                      ),

                      const SizedBox(
                        width: 12,
                      ),

                      Expanded(
                        child: Text(
                          item[
                                      'variety_type']
                                  ?.toString() ??
                              '',

                          style:
                              const TextStyle(
                            color:
                                AppTheme
                                    .textPrimary,
                            fontSize: 14,
                            fontWeight:
                                FontWeight
                                    .w600,
                          ),
                        ),
                      ),

                      Text(
                        '${item['ready_production'] ?? 0}',

                        style:
                            const TextStyle(
                          color:
                              AppTheme
                                  .success,
                          fontSize: 16,
                          fontWeight:
                              FontWeight
                                  .w800,
                        ),
                      ),
                    ],
                  ),
                ),

                if (!isLast)
                  Divider(
                    height: 1,
                    color:
                        AppTheme.neutral,
                    indent: 16,
                    endIndent: 16,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section label
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel
    extends StatelessWidget {
  final String text;

  const _SectionLabel({
    required this.text,
  });

  @override
  Widget build(
      BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 17,

          decoration:
              BoxDecoration(
            color:
                AppTheme.success,

            borderRadius:
                BorderRadius.circular(
              2,
            ),
          ),
        ),

        const SizedBox(
          width: 8,
        ),

        Text(
          text,
          style:
              const TextStyle(
            color:
                AppTheme.textPrimary,
            fontWeight:
                FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}
