import 'package:flutter/material.dart';
import '../../core/services/employee_service/profile_service.dart';
import '../../core/utils/theme.dart';

class UserProfileScreen extends StatefulWidget {
  final int userId;
  const UserProfileScreen({
    super.key,
    required this.userId,
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
    print("Profile User ID = ${widget.userId}");
    final response = await service.getProfile(widget.userId);
    print(response);
    setState(() {
      profile = response?['data'];
      loading = false;
    });
  }

    // ===== ACTION HANDLERS =====
  // Hook these up to your real navigation/routes.
  void onViewProductionHistory() {
    // TODO: Navigator.push(context, MaterialPageRoute(builder: (_) => ProductionHistoryScreen(userId: widget.userId)));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Opening Production History...")),
    );
  }
 
  void onViewPaymentHistory() {
    // TODO: Navigator.push(context, MaterialPageRoute(builder: (_) => PaymentHistoryScreen(userId: widget.userId)));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Opening Payment History...")),
    );
  }

  // ===== SIMPLE HELPER WIDGETS (DESIGN ONLY) =====

  // Top gradient profile card (avatar + name + email)
  // Colors fixed to navy -> sky blue (like reference design) + smaller size
  Widget buildProfileHeader() {
    final name = profile?['name'] ?? '';
    final email = profile?['email'] ?? '';
    final firstLetter = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(15, 15, 15, 12),
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primary, // dark navy blue
            AppTheme.info,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.35),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.secondary.withOpacity(0.6),
                width: 2,
              ) 
           ),
          ),
          CircleAvatar(
            radius: 32,
            backgroundColor: AppTheme.background.withOpacity(0.25),
            child: Text(
              firstLetter,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.2,
              color:AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            email,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary.withOpacity(0.85),
            ),
          ),
        ],
      ),
    );
  }




 // Two tappable action buttons shown right under the header card
  // "View Production History" and "View Payment History"
  Widget buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 0, 15, 6),
      child: Row(
        children: [
          Expanded(
            child: actionButton(
              icon: Icons.precision_manufacturing_outlined,
              label: "Production\nHistory",
              onTap: onViewProductionHistory,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: actionButton(
              icon: Icons.receipt_long_outlined,
              label: "Payment\nHistory",
              onTap: onViewPaymentHistory,
            ),
          ),
        ],
      ),
    );
  }
 
  // A single classic-style outlined action button with icon on top and label below
  Widget actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppTheme.secondary,
      borderRadius: BorderRadius.circular(16),
      elevation: 1.5,
      shadowColor: AppTheme.onsurface.withOpacity(0.08),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        splashColor: AppTheme.primary.withOpacity(0.08),
        highlightColor: AppTheme.primary.withOpacity(0.05),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.primary.withOpacity(0.12),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppTheme.primary, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                  color: AppTheme.onsurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
 
  // Row style like "Shift Start / Shift End" boxes shown in the design
  Widget infoRow(IconData icon, String title, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.secondary,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppTheme.onsurface.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.onsurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.onsurface,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
 
  // Section title with small blue bar (like "Performance Overview")
  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
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
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.onsurface,
            ),
          ),
        ],
      ),
    );
  }
 
  // Colorful stat card for performance overview grid
  Widget statCard(IconData icon, String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppTheme.secondary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.onsurface.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.onsurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.onsurface,
            ),
          ),
        ],
      ),
    );
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background, 
      appBar: AppBar(title: const Text("User Profile")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top gradient header
                  buildProfileHeader(),
 
                  // Two tappable action buttons
                  buildActionButtons(),
                  const SizedBox(height: 6),
 
                  // Personal info rows (unchanged)
                  infoRow(Icons.phone, "Phone", profile?['phone_no'] ?? ''),
                  infoRow(Icons.badge, "CNIC", profile?['cnic'] ?? ''),
                  infoRow(Icons.home, "Address", profile?['address'] ?? ''),
                  infoRow(Icons.info, "Details",
                      profile?['employee_details'] ?? ''),
 
                  // Performance overview section (unchanged)
                  sectionTitle("Performance Overview"),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.3,
                      children: [
                        statCard(
                          Icons.precision_manufacturing,
                          "Assigned Machines",
                          "${profile?['total_machines'] ?? 0}",
                          AppTheme.info,
                        ),
                        statCard(
                          Icons.analytics,
                          "Total Production",
                          "${profile?['total_production'] ?? 0}",
                          AppTheme.surface,
                        ),
                        statCard(
                          Icons.check_circle,
                          "Ready Production",
                          "${profile?['total_ready_production'] ?? 0}",
                          AppTheme.success,
                        ),
                        statCard(
                          Icons.fact_check,
                          "Attendance",
                          "${profile?['attendance_count'] ?? 0}",
                          Colors.purple,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}
 