import 'package:flutter/material.dart';
import 'package:techstile_frontend/widgets/emp_drawer.dart';
import '../../core/services/employee_service/attendance_service.dart';
import '../../core/services/employee_service/machine_detail_service.dart';
import '../../core/utils/theme.dart';
import 'package:get/get.dart';
import '../../routes/routes.dart';

final attendanceService = AttendanceService();
bool alreadyMarkedToday = false;

class MachineDetailScreen extends StatefulWidget {
  final String machineId;
  const MachineDetailScreen({
    super.key,
    required this.machineId,
  });

  @override
  State<MachineDetailScreen> createState() =>
      _MachineDetailScreenState();
}

class _MachineDetailScreenState
    extends State<MachineDetailScreen> {
  final service = EmployeeMachineService();

  bool loading = true;
  Map<String, dynamic>? machine;

  // ✅ Yahan add karo — class level pe
  bool canAdd = false;
  double remaining = 0;

  // ─────────────────────────────────────────────────────────────────────────
  // Common shadow / border (matches Factory Dashboard styling)
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

  static Border get _primaryBorder => Border.all(
        color: AppTheme.primary.withOpacity(0.10),
        width: 1,
      );

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final data = await service.getMachineDetails(
        widget.machineId,
      );

      setState(() {
        machine   = data;
        canAdd    = data['can_add_production'] ?? false;
        remaining = (data['remaining'] ?? 0).toDouble();
        loading   = false;
        alreadyMarkedToday = data['already_marked_today'] ?? false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Equal, symmetric action card (replaces the old full-width buttons for
  // Enter Production / Mark Attendance)
  // ─────────────────────────────────────────────────────────────────────────

  Widget _actionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required VoidCallback? onTap,
  }) {
    return Expanded(
      child: AspectRatio(
        aspectRatio: 1,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.secondary,
                borderRadius: BorderRadius.circular(18),
                boxShadow: _primaryShadow,
                border: _primaryBorder,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: accentColor, size: 28),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppTheme.textPrimary.withOpacity(0.6),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Shared full-width action-button style (kept for Scan Next Machine)
  // ─────────────────────────────────────────────────────────────────────────

  Widget _actionButton({
    required String label,
    required IconData icon,
    required Color backgroundColor,
    required Color foregroundColor,
    required VoidCallback? onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.secondary,
        borderRadius: BorderRadius.circular(18),
        boxShadow: _primaryShadow,
        border: _primaryBorder,
      ),
      child: SizedBox(
        width: double.infinity,
        height: 58,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          onPressed: onPressed,
          icon: Icon(icon, size: 22),
          label: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const EmployeeDrawer(),
      backgroundColor: AppTheme.background,

      appBar: AppBar(
        backgroundColor: AppTheme.secondary,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: AppTheme.primary,
        ),
        titleSpacing: 4,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.primary),
          onPressed: () => Get.back(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Machine Details",
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
                  : "Machine #${machine?["machine_id"] ?? widget.machineId}",
              style: TextStyle(
                color: AppTheme.primary.withOpacity(0.65),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),

      body: loading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primary,
              ),
            )
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [

                    const _SectionLabel(text: 'Actions'),

                    const SizedBox(height: 16),

                    // ─────────────────────────────────────────
                    // Enter Production + Mark Attendance
                    // — equal-size, symmetric cards side by side
                    // ─────────────────────────────────────────

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _actionCard(
                          title: "Enter Production",
                          subtitle: canAdd
                              ? "Remaining: $remaining"
                              : "Production Complete",
                          icon: canAdd ? Icons.add : Icons.lock,
                          accentColor:
                              canAdd ? AppTheme.primary : AppTheme.active,
                          onTap: canAdd
                              ? () async {
                                  await Get.toNamed(
                                    AppRoutes.enterProduction,
                                    arguments: {
                                      'machineId': widget.machineId,
                                      'varietyType':
                                          machine?['variety_type'] ?? '',
                                      'totalLength': machine?['total_length']
                                              ?.toString() ??
                                          '',
                                      'remaining': remaining.toString(),
                                    },
                                  );
                                  // after fresh prduction is enter fresh load
                                  loadData();
                                }
                              : () {
                                  Get.snackbar(
                                    "Complete",
                                    "The Production is Completed of this Machine",
                                    backgroundColor: AppTheme.surface,
                                    colorText: AppTheme.textSecondary,
                                  );
                                },
                        ),

                        const SizedBox(width: 16),

                        _actionCard(
                          title: "Mark Attendance",
                          subtitle: alreadyMarkedToday
                              ? "Already Marked"
                              : "Tap to mark",
                          icon: Icons.fingerprint,
                          accentColor: AppTheme.active,
                          onTap: alreadyMarkedToday
                              ? () {
                                  Get.snackbar(
                                    "Already Marked",
                                    "Already Marked",
                                    backgroundColor: AppTheme.surface,
                                    colorText: AppTheme.textSecondary,
                                  );
                                }
                              : () async {
                                  final success =
                                      await attendanceService.markAttendance(
                                    employeeId: machine?['employee_id'],
                                    machineId: int.parse(widget.machineId),
                                  );

                                  if (success) {
                                    Get.snackbar(
                                      "Success",
                                      "Attendance Marked",
                                      backgroundColor: AppTheme.success,
                                      colorText: AppTheme.textSecondary,
                                    );
                                    loadData();
                                  } else {
                                    Get.snackbar(
                                      "Error",
                                      "Attendance Failed",
                                      backgroundColor: AppTheme.error,
                                      colorText: AppTheme.textPrimary,
                                    );
                                  }
                                },
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // ─────────────────────────────────────────
                    // Scan Next Machine
                    // (no existing logic for this — wire up your
                    // scanner route/handler here)
                    // ─────────────────────────────────────────

                    _actionButton(
                      label: "Scan Next Machine",
                      icon: Icons.qr_code_scanner,
                      backgroundColor: AppTheme.secondary,
                      foregroundColor: AppTheme.primary,
                      onPressed: () {
                        // TODO: hook up your scan-next-machine logic/route here
                        Get.back();
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section label (matches Factory Dashboard style)
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 17,
          decoration: BoxDecoration(
            color: AppTheme.success,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}