import 'package:flutter/material.dart';
import '../../core/services/employee_service/profile_service.dart';
import '../../core/utils/theme.dart';
import '../app_Owner_dashboard/employee/employee_payment_history_screen.dart';
import '../employee_dashboard/history_screen.dart';


class UserProfileScreen extends StatefulWidget {
  final int userId;
  final dynamic factoryId;

  const UserProfileScreen({
    super.key,
    required this.userId,
    this.factoryId,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final service = EmployeeProfileService();
  Map<String, dynamic>? profile;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    setState(() => loading = true);
    final response = await service.getProfile(widget.userId);
    setState(() {
      profile = response?['data'];
      loading = false;
    });
  }

  // ================= ACTION HANDLERS =================
  void onViewProductionHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HistoryScreen(
          userId: widget.userId,
          userName: profile?['name'],
        ),
      ),
    );
  }

  void onViewPaymentHistory() {
    final rawFactoryId = widget.factoryId ?? profile?['factory_id'];
    final factoryId = int.tryParse(rawFactoryId?.toString() ?? '') ?? 0;
    final employeeId = int.tryParse(profile?['employee_id']?.toString() ?? '');

    if (factoryId > 0 && employeeId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EmployeePaymentHistoryScreen(
            employeeId: employeeId,
            factoryId: factoryId,
            employeeName: profile?['name'],
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No factory assigned to this employee")),
      );
    }
  }

  // HERO PROFILE CARD 
  Widget _buildHeroHeader() {
    final name = profile?['name']?.toString() ?? 'Production Worker';
    final email = profile?['email']?.toString() ?? '—';
    final firstLetter = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : 'E';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primary, AppTheme.info],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar with ring border
          Container(
            padding: const EdgeInsets.all(3.5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.7), width: 2),
            ),
            child: CircleAvatar(
              radius: 36,
              backgroundColor: Colors.white.withOpacity(0.2),
              child: Text(
                firstLetter,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            email,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              color: Colors.white.withOpacity(0.85),
            ),
          ),
          const SizedBox(height: 10),
          // Badge chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.engineering_outlined, color: Color(0xFF64B5F6), size: 14),
                SizedBox(width: 5),
                Text(
                  "Production Staff",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // QUICK ACTION BUTTONS 
  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Row(
        children: [
          Expanded(
            child: _actionButton(
              icon: Icons.precision_manufacturing_outlined,
              label: "Production History",
              onTap: onViewProductionHistory,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _actionButton(
              icon: Icons.receipt_long_outlined,
              label: "Payment History",
              onTap: onViewPaymentHistory,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 1,
      shadowColor: AppTheme.primary.withOpacity(0.08),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.primary.withOpacity(0.08)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppTheme.primary, size: 20),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //SECTION TITLE 
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // OVERVIEW STATS 
  Widget _buildOverviewStats() {
    final totalMachines = "${profile?['total_machines'] ?? 0}";
    final totalProduction = "${profile?['total_production'] ?? 0} m";
    final totalReady = "${profile?['total_ready_production'] ?? 0} m";
    final attendance = "${profile?['attendance_count'] ?? 0} Days";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.35,
        children: [
          _statCard(
            Icons.precision_manufacturing_rounded,
            "Assigned Machines",
            totalMachines,
            AppTheme.info,
          ),
          _statCard(
            Icons.analytics_rounded,
            "Target Output",
            totalProduction,
            AppTheme.primary,
          ),
          _statCard(
            Icons.check_circle_rounded,
            "Ready Output",
            totalReady,
            AppTheme.success,
          ),
          _statCard(
            Icons.event_available_rounded,
            "Attendance",
            attendance,
            const Color(0xFF8B5CF6),
          ),
        ],
      ),
    );
  }

  Widget _statCard(IconData icon, String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: AppTheme.onsurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  // EMPLOYMENT & PERSONAL INFO
  Widget _buildDetailsCard() {
    final employeeId = profile?['employee_id']?.toString() ?? '';
    final factoryName = profile?['factory_name']?.toString() ?? '';
    final managerName = profile?['manager_name']?.toString() ?? '';
    final shiftStart = profile?['shift_starttime']?.toString() ?? '';
    final shiftEnd = profile?['shift_endtime']?.toString() ?? '';
    final shiftText = (shiftStart.isNotEmpty || shiftEnd.isNotEmpty)
        ? "$shiftStart  -  $shiftEnd"
        : '';
    final phone = profile?['phone_no']?.toString() ?? '';
    final cnic = profile?['cnic']?.toString() ?? '';
    final address = profile?['address']?.toString() ?? '';
    final details = profile?['employee_details']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppTheme.primary.withOpacity(0.06)),
      ),
      child: Column(
        children: [
          if (employeeId.isNotEmpty) ...[
            _infoRow(Icons.badge_outlined, "Employee ID", "#$employeeId"),
            const Divider(height: 14, thickness: 0.6),
          ],
          if (factoryName.isNotEmpty) ...[
            _infoRow(Icons.factory_outlined, "Factory / Plant", factoryName),
            const Divider(height: 14, thickness: 0.6),
          ],
          if (managerName.isNotEmpty) ...[
            _infoRow(Icons.supervisor_account_outlined, "Reporting Manager", managerName),
            const Divider(height: 14, thickness: 0.6),
          ],
          if (shiftText.isNotEmpty) ...[
            _infoRow(Icons.schedule_outlined, "Shift Timings", shiftText),
            const Divider(height: 14, thickness: 0.6),
          ],
          _infoRow(Icons.phone_outlined, "Phone Number", phone),
          const Divider(height: 14, thickness: 0.6),
          _infoRow(Icons.credit_card_outlined, "CNIC Number", cnic),
          const Divider(height: 14, thickness: 0.6),
          _infoRow(Icons.location_on_outlined, "Residential Address", address),
          if (details.isNotEmpty) ...[
            const Divider(height: 14, thickness: 0.6),
            _infoRow(Icons.notes_outlined, "Additional Details", details),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.07),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppTheme.primary, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.onsurface.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  value.isNotEmpty ? value : '—',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // MAIN BUILD 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.secondary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Employee Profile",
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppTheme.secondary),
            onPressed: loadProfile,
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : RefreshIndicator(
              color: AppTheme.primary,
              onRefresh: loadProfile,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeroHeader(),
                    _buildQuickActions(),
                    _sectionTitle("Performance Overview"),
                    _buildOverviewStats(),
                    _sectionTitle("Personal & Employment Details"),
                    _buildDetailsCard(),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
    );
  }
}