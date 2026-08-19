import 'package:flutter/material.dart';
import 'package:techstile_frontend/core/services/owner_profile_service.dart';
import 'package:techstile_frontend/core/utils/theme.dart';
import 'package:techstile_frontend/widgets/owner_drawer.dart';

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
    final res = await service.getProfile(widget.userId);
    setState(() {
      profile = res?['data'];
      loading = false;
    });
  }

  Widget _header() {
    final name = profile?['name'] ?? '';
    final email = profile?['email'] ?? '';
    final firstLetter = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(15, 15, 15, 12),
      padding: const EdgeInsets.symmetric(vertical: 26),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primary,  AppTheme.info],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.35),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.secondary, width: 2),
            ),
            child: CircleAvatar(
              radius: 34,
              backgroundColor:  AppTheme.background.withOpacity(0.2),
              child: Text(
                firstLetter,
                style: const TextStyle(
                    fontSize: 28, fontWeight: FontWeight.bold, color:  AppTheme.secondary),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(name,
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color:  AppTheme.secondary)),
          const SizedBox(height: 3),
          Text(email, style: TextStyle(fontSize: 12, color:  AppTheme.secondary.withOpacity(0.85))),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              "Owner",
              style: TextStyle(color:  AppTheme.secondary, fontSize: 11, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
                color: AppTheme.primary, borderRadius: BorderRadius.circular(4)),
          ),
          const SizedBox(width: 8),
          Text(title,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
        ],
      ),
    );
  }

  Widget _statCard(IconData icon, String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color:  AppTheme.secondary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color:  AppTheme.onsurface.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color:  AppTheme.onsurface)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 12, color:  AppTheme.onsurface)),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color:  AppTheme.secondary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color:  AppTheme.onsurface.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: AppTheme.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color:  AppTheme.onsurface)),
                Text(value.isNotEmpty ? value : '—',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.onsurface)),
              ],
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
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        iconTheme: const IconThemeData(color: AppTheme.secondary),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.secondary),
          onPressed: () {
            Navigator.pop(context); // or Get.back()
          },
        ),
        title: const Text(
          "Owner Profile",
          style: TextStyle(color: AppTheme.secondary),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: load,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _header(),

                    _sectionTitle("Basic Information"),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Column(
                        children: [
                          _infoRow(Icons.phone_outlined, "Phone",
                              profile?['phone_no']?.toString() ?? ''),
                          _infoRow(Icons.location_on_outlined, "Address",
                              profile?['address']?.toString() ?? ''),
                        ],
                      ),
                    ),

                    _sectionTitle("Business Overview"),
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
                          _statCard(Icons.factory_rounded, "Total Factories",
                              "${profile?['total_factories'] ?? 0}", AppTheme.primary),
                          _statCard(Icons.precision_manufacturing_rounded, "Total Machines",
                              "${profile?['total_machines'] ?? 0}",  AppTheme.primary),
                          _statCard(Icons.groups_rounded, "Total Employees",
                              "${profile?['total_employees'] ?? 0}",  AppTheme.surface),
                          _statCard(Icons.supervisor_account_rounded, "Total Managers",
                              "${profile?['total_managers'] ?? 0}", AppTheme.success),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }
}