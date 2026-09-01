import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:techstile_frontend/core/services/owner_profile_service.dart';
import 'package:techstile_frontend/core/utils/theme.dart';
import 'package:techstile_frontend/routes/routes.dart';

class OwnerProfileScreen extends StatefulWidget {
  final int userId;
  const OwnerProfileScreen({super.key, required this.userId});

  @override
  State<OwnerProfileScreen> createState() => _OwnerProfileScreenState();
}

class _OwnerProfileScreenState extends State<OwnerProfileScreen> {
  final service = OwnerProfileService();
  Map<String, dynamic>? profile;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() => loading = true);
    final res = await service.getProfile(widget.userId);
    setState(() {
      profile = res?['data'];
      loading = false;
    });
  }

  // ================= 1. HERO PROFILE CARD =================
  Widget _buildHeroHeader() {
    final name = profile?['name']?.toString() ?? 'Factory Owner';
    final email = profile?['email']?.toString() ?? '—';
    final firstLetter = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : 'O';

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
                Icon(Icons.verified_user_rounded, color: Colors.amber, size: 14),
                SizedBox(width: 5),
                Text(
                  "Factory Owner",
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

  // ================= 2. QUICK ACTION BUTTONS =================
  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Row(
        children: [
          Expanded(
            child: _actionButton(
              icon: Icons.factory_outlined,
              label: "Factories",
              onTap: () => Get.toNamed(AppRoutes.ownerDashboard),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _actionButton(
              icon: Icons.people_outline_rounded,
              label: "Manage Users",
              onTap: () => Get.toNamed(AppRoutes.manageusers),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _actionButton(
              icon: Icons.payments_outlined,
              label: "Payments",
              onTap: () => Get.toNamed(AppRoutes.payments),
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
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
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
                  fontSize: 11.5,
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

  // ================= 3. SECTION TITLE =================
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

  // ================= 4. OVERVIEW STATS (2x2 GRID) =================
  Widget _buildOverviewStats() {
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
            Icons.factory_rounded,
            "Total Factories",
            "${profile?['total_factories'] ?? 0}",
            AppTheme.primary,
          ),
          _statCard(
            Icons.precision_manufacturing_rounded,
            "Total Machines",
            "${profile?['total_machines'] ?? 0}",
            AppTheme.info,
          ),
          _statCard(
            Icons.groups_rounded,
            "Total Employees",
            "${profile?['total_employees'] ?? 0}",
            AppTheme.surface,
          ),
          _statCard(
            Icons.supervisor_account_rounded,
            "Total Managers",
            "${profile?['total_managers'] ?? 0}",
            AppTheme.success,
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
                fontSize: 18,
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

  // ================= 5. PERSONAL & BUSINESS INFO =================
  Widget _buildDetailsCard() {
    final phone = profile?['phone_no']?.toString() ?? '';
    final cnic = profile?['cnic']?.toString() ?? '';
    final address = profile?['address']?.toString() ?? '';

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
          _infoRow(Icons.phone_outlined, "Phone Number", phone),
          const Divider(height: 14, thickness: 0.6),
          _infoRow(Icons.badge_outlined, "CNIC Number", cnic),
          const Divider(height: 14, thickness: 0.6),
          _infoRow(Icons.location_on_outlined, "Address / Head Office", address),
          const Divider(height: 14, thickness: 0.6),
          _infoRow(Icons.shield_outlined, "Role & Permissions", "Full Owner & Admin Privileges"),
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

  // ================= MAIN BUILD =================
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
          "Owner Profile",
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppTheme.secondary),
            onPressed: load,
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : RefreshIndicator(
              color: AppTheme.primary,
              onRefresh: load,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeroHeader(),
                    _buildQuickActions(),
                    _sectionTitle("Overview Statistics"),
                    _buildOverviewStats(),
                    _sectionTitle("Account Details"),
                    _buildDetailsCard(),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
    );
  }
}