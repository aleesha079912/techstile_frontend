import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/services/manager_service/manager_service.dart';
import '../../../core/utils/theme.dart';
import '../../../widgets/man_bottom_navbar.dart';
import 'package:techstile_frontend/widgets/man_drawer.dart';
import 'package:techstile_frontend/core/services/auth_service.dart';
import 'package:techstile_frontend/routes/routes.dart';

class ManagerDashboard extends StatefulWidget {
  final dynamic factoryId;

  const ManagerDashboard({
    super.key,
    required this.factoryId,
  });

  @override
  State<ManagerDashboard> createState() => _ManagerDashboardState();
}

class _ManagerDashboardState extends State<ManagerDashboard> {
  final _service = ManagerDashboardService();

  bool loading = true;
  Map data = {};
  String? error;

  // ─────────────────────────────────────────────────────────────────────────
  // Common shadow - same style as Factory Dashboard
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

  // Same light border as Factory Dashboard
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

  // ─────────────────────────────────────────────────────────────────────────
  // Week days
  // ─────────────────────────────────────────────────────────────────────────

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

  // ─────────────────────────────────────────────────────────────────────────
  // Lifecycle
  // ─────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();

    print("Arguments = ${Get.arguments}");
    print("Factory from Storage = ${AuthService.factoryId}");
    print("Stored User ID = ${AuthService.userId}");

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
      final id = int.tryParse(widget.factoryId.toString());

      if (id == null || id == 0) {
        throw Exception("Invalid factoryId");
      }

      final res = await _service.getDashboard(
        id,
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
  // Week start day info
  // ─────────────────────────────────────────────────────────────────────────

  void _showWeekStartDayInfo() {
    final current = (data['week_start_day'] as int?) ?? 1;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.secondary,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
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
                    'This is set by the factory owner. '
                    '"This Week" and "Previous Week" are calculated from this day.',
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          AppTheme.textPrimary.withOpacity(0.6),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(
                      weekDayNames.length,
                      (i) {
                        final isOwnerSelected =
                            current == i;

                        return ChoiceChip(
                          label: Text(
                            weekDayNames[i],
                          ),
                          selected:
                              isOwnerSelected,
                          selectedColor:
                              AppTheme.primary,
                          labelStyle: TextStyle(
                            color: isOwnerSelected
                                ? AppTheme.secondary
                                : AppTheme.textPrimary,
                            fontWeight:
                                FontWeight.w600,
                          ),
                          onSelected: null,
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () =>
                          Navigator.pop(context),
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            AppTheme.primary,
                        foregroundColor:
                            AppTheme.secondary,
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
                        'Close',
                        style: TextStyle(
                          color: AppTheme.secondary,
                          fontWeight: FontWeight.w700,
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
    final factoryId = AuthService.factoryId;

    return Scaffold(
      drawer: ManagerDrawer(
        factoryId: factoryId,
      ),
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
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
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
                            // ─────────────────────────────────────
                            // Responsive Period Header
                            // ─────────────────────────────────────

                            _buildPeriodHeader(
                              constraints.maxWidth,
                            ),

                            const SizedBox(height: 12),

                            // ─────────────────────────────────────
                            // Main Stats
                            // ─────────────────────────────────────

                            Row(
                              children: [
                                _statCard(
                                  icon:
                                      Icons.today_rounded,
                                  label:
                                      _todayLabel(),
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

                            // ─────────────────────────────────────
                            // Today Breakdown
                            // ─────────────────────────────────────

                            _pipelineBreakdown(
                              title: 'Today',
                              breakdown:
                                  data['today_breakdown']
                                      as Map?,
                            ),

                            // ─────────────────────────────────────
                            // This Week Breakdown
                            // ─────────────────────────────────────

                            if (selectedPeriodKey ==
                                'this_week')
                              _pipelineBreakdown(
                                title: 'This Week',
                                breakdown:
                                    data['period_breakdown']
                                        as Map?,
                              ),

                            const SizedBox(height: 20),

                            // ─────────────────────────────────────
                            // Floor Assets
                            // ─────────────────────────────────────

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

                            // ─────────────────────────────────────
                            // Varieties
                            // ─────────────────────────────────────

                            _SectionLabel(
                              text:
                                  'Varieties (${data['total_varieties'] ?? 0})',
                            ),

                            const SizedBox(height: 12),

                            _varietiesList(),
                          ],
                        ),
                      );
                    },
                  ),
                ),

      bottomNavigationBar: ManagerBottomNav(
        currentIndex: 0,
        factoryId: widget.factoryId,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Responsive Period Header
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildPeriodHeader(double width) {
    final bool isSmallScreen = width < 500;

    final periodInfo = Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _SectionLabel(
          text: selectedPeriodLabel,
        ),

        if (data['range_label'] != null) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(
              left: 12,
            ),
            child: Text(
              data['range_label'].toString(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.5,
                color: AppTheme.primary
                    .withOpacity(0.55),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );

    final controls = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _weekStartButton(),

        const SizedBox(width: 8),

        _periodFilterDropdown(),
      ],
    );

    // On mobile the controls go below the title.
    // This prevents Row overflow on 360/400px screens.
    if (isSmallScreen) {
      return Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          periodInfo,

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.end,
              children: [
                controls,
              ],
            ),
          ),
        ],
      );
    }

    // Tablet / desktop
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Expanded(
          child: periodInfo,
        ),
        controls,
      ],
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

      automaticallyImplyLeading: true,

      titleSpacing: 4,

      title: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'Manager Dashboard',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppTheme.primary,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),

          const SizedBox(height: 1),

          Text(
            loading
                ? 'Loading...'
                : (factory?['name'] ?? 'Factory'),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
            right: 10,
          ),
          child: Center(
            child: _viewProductionsButton(),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Error View
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
                color: AppTheme.textSecondary,
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
  // Productions Button
  // ─────────────────────────────────────────────────────────────────────────

  Widget _viewProductionsButton() {
    return ElevatedButton.icon(
      onPressed: () {
        Get.toNamed(
          AppRoutes.managerProduction,
          arguments: {
            'factoryId': widget.factoryId,
          },
        );
      },

      icon: const Icon(
        Icons.list_alt_rounded,
        size: 17,
      ),

      label: const Text(
        'Productions',
        style: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),

      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primary,
        foregroundColor: AppTheme.secondary,
        elevation: 0,

        padding:
            const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 9,
        ),

        minimumSize: const Size(
          0,
          40,
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
  // Period Filter Dropdown
  // ─────────────────────────────────────────────────────────────────────────

  Widget _periodFilterDropdown() {
    return PopupMenuButton<String>(
      initialValue:
          selectedPeriodKey,

      onSelected:
          onPeriodChanged,

      offset:
          const Offset(0, 40),

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
                              AppTheme.textPrimary,
                          fontWeight:
                              isSelected
                                  ? FontWeight.w800
                                  : FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),

                      if (isSelected)
                        const Icon(
                          Icons
                              .check_rounded,
                          color:
                              AppTheme.success,
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

          boxShadow:
              _primaryShadow,

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
  // Week Start Button
  // ─────────────────────────────────────────────────────────────────────────

  Widget _weekStartButton() {
    return InkWell(
      borderRadius:
          BorderRadius.circular(10),

      onTap:
          _showWeekStartDayInfo,

      child: Container(
        width: 36,
        height: 36,

        decoration:
            BoxDecoration(
          color:
              AppTheme.secondary,

          borderRadius:
              BorderRadius.circular(10),

          boxShadow:
              _primaryShadow,

          border:
              _primaryBorder,
        ),

        alignment:
            Alignment.center,

        child: const Icon(
          Icons.add_rounded,
          color:
              AppTheme.primary,
          size: 20,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Pipeline Breakdown
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

          boxShadow:
              _primaryShadow,

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
                    .withOpacity(0.78),
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

                const SizedBox(
                  width: 8,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Breakdown Chip
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

          boxShadow: [
            BoxShadow(
              color: AppTheme.primary
                  .withOpacity(0.08),
              blurRadius: 8,
              offset:
                  const Offset(0, 3),
            ),
          ],

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
              maxLines: 1,
              overflow:
                  TextOverflow.ellipsis,
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
  // Stat Card
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

          boxShadow:
              _primaryShadow,

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
                    color.withOpacity(0.12),

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
              maxLines: 1,
              overflow:
                  TextOverflow.ellipsis,
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
              maxLines: 2,
              overflow:
                  TextOverflow.ellipsis,
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
  // Varieties List
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

          boxShadow:
              _primaryShadow,

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

        boxShadow:
            _primaryShadow,

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
                          maxLines: 1,
                          overflow:
                              TextOverflow
                                  .ellipsis,
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

                      const SizedBox(
                        width: 10,
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
// Section Label
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel({
    required this.text,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
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

        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow:
                TextOverflow.ellipsis,
            style:
                const TextStyle(
              color:
                  AppTheme.textPrimary,
              fontWeight:
                  FontWeight.w700,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }
}