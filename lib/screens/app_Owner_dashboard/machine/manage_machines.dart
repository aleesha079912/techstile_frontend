import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../../core/services/machines_service.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/utils/theme.dart';
import '../../../../widgets/bottom_nav_bar.dart';
import 'package:get/get.dart';
import 'machine_detail.dart';

class MachinesScreen extends StatefulWidget {
  final int factoryId;

  const MachinesScreen({
    super.key,
    required this.factoryId,
  });

  @override
  State<MachinesScreen> createState() => _MachinesScreenState();
}

class _MachinesScreenState extends State<MachinesScreen> {
  final service = MachinesService.instance;

  MachinesData? data;
  bool isLoading = true;
  String factoryName = "";

  List<Machine> filteredMachines = [];

  final TextEditingController searchCtrl = TextEditingController();

  bool showOnlyActive = false;

  @override
  void initState() {
    super.initState();
    load();
    loadFactoryName();
  }

  Future<void> loadFactoryName() async {
    try {
      final response = await http.get(
        Uri.parse("http://localhost:8000/api/factories/editfactory/${widget.factoryId}"),
        headers: AuthService.authHeaders,
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (mounted) {
          setState(() => factoryName = body['data']?['name'] ?? "");
        }
      }
    } catch (_) {}
  }

  void load() async {
    setState(() {
      isLoading = true;
    });

    final res = await service.fetchMachines(widget.factoryId);

    if (!mounted) return;

    final allMachines = res?.machines ?? [];

    setState(() {
      data = res;

      if (showOnlyActive) {
        filteredMachines = allMachines.where((m) => m.isActive).toList();
      } else {
        filteredMachines = allMachines;
      }

      isLoading = false;
    });
  }

  void searchMachines(String query) {
    final allMachines = data?.machines ?? [];

    final searchText = query.toLowerCase();

    setState(() {
      filteredMachines = allMachines.where((m) {
        final nameMatch = m.machineName.toLowerCase().contains(searchText);
        final typeMatch = m.type.toLowerCase().contains(searchText);
        final activeMatch = !showOnlyActive || m.isActive;

        return (nameMatch || typeMatch) && activeMatch;
      }).toList();
    });
  }

  void _showMachineForm(BuildContext context, {Machine? machine}) {
    final idCtrl = TextEditingController(text: machine?.machineName);
    final typeCtrl = TextEditingController(text: machine?.type);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: AppTheme.neutral,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                machine == null ? "Register New Machine" : "Update Machine Info",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: 20),
              _buildField(idCtrl, "Machine Name", Icons.abc),
              _buildField(typeCtrl, "Machine Type", Icons.category),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
                  onPressed: () async {
                    if (machine == null) {
                      final result = await service.addMachine(
                        idCtrl.text,
                        typeCtrl.text,
                        widget.factoryId,
                      );

                      if (!mounted) return;

                      if (result != null && result['success'] == true) {
                        Get.back();
                        load();
                      }
                    } else {
                      bool success = await service.updateMachine(
                        machine.id,
                        idCtrl.text,
                        typeCtrl.text,
                        widget.factoryId,
                      );

                      if (success) {
                        Get.back();
                        load();
                      }
                    }
                  },
                  child: Text(
                    machine == null ? "Register Machine" : "Update Machine",
                    style: const TextStyle(color: AppTheme.secondary),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  void _handleDelete(String id) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Machine"),
        content: const Text("Are you sure?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      bool success = await service.deleteMachine(id);

      if (success) {
        load();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppTheme.secondary,
        elevation: 0,
        titleSpacing: 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "All Machines",
              style: TextStyle(
                color: AppTheme.primary,
                fontSize: 21,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (factoryName.isNotEmpty)
              Text(
                factoryName,
                style: TextStyle(
                  color: AppTheme.primary.withOpacity(0.55),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () => _showMachineForm(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, color: Colors.white, size: 20),
                    SizedBox(width: 6),
                    Text(
                      "Add Machine",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() => showOnlyActive = false);
                            searchMachines(searchCtrl.text);
                          },
                          child: _statCard(
                            "Total Machines",
                            data?.totalMachines ?? (data?.machines.length ?? 0),
                            AppTheme.info,
                            isSelected: !showOnlyActive,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() => showOnlyActive = true);
                            searchMachines(searchCtrl.text);
                          },
                          child: _statCard(
                            "Active",
                            data?.activeMachines ?? 0,
                            AppTheme.success,
                            isSelected: showOnlyActive,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: searchCtrl,
                    onChanged: searchMachines,
                    decoration: InputDecoration(
                      hintText: "Search machines...",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: AppTheme.secondary,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppTheme.primary.withOpacity(0.12)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppTheme.primary.withOpacity(0.12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        load();
                      },
                      child: filteredMachines.isEmpty
                          ? const Center(child: Text("No machines found"))
                          : ListView.builder(
                              padding: const EdgeInsets.only(bottom: 80),
                              itemCount: filteredMachines.length,
                              itemBuilder: (context, i) {
                                return _machineTile(filteredMachines[i]);
                              },
                            ),
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 1,
        factoryId: widget.factoryId,
      ),
    );
  }

  Widget _statCard(String title, int count, Color color, {bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.secondary,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? color : AppTheme.primary.withOpacity(0.08),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 6),
          Text(
            "$count",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Widget _machineTile(Machine m) {
    final bool isActive = m.isActive;

    return InkWell(
      onTap: () {
        Get.to(
          () => MachineDetailScreen(
            machine: m,
            factoryId: widget.factoryId.toString(),
            onRefresh: load,
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.secondary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? AppTheme.success : AppTheme.primary.withOpacity(0.12),
            width: isActive ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.1),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isActive ? AppTheme.success.withOpacity(0.16) : AppTheme.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.precision_manufacturing,
                color: isActive ? AppTheme.success : AppTheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    m.machineName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isActive ? AppTheme.success : AppTheme.primary,
                    ),
                  ),
                  Text(m.type, style: const TextStyle(color: AppTheme.neutral)),
                ],
              ),
            ),
            if (isActive)
              Container(
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: AppTheme.success,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "ACTIVE",
                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            GestureDetector(
              onTap: () => _showMachineForm(context, machine: m),
              child: const Icon(Icons.edit, color: AppTheme.primary),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () => _handleDelete(m.id),
              child: const Icon(Icons.delete, color: AppTheme.error),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String hint, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppTheme.primary),
          hintText: hint,
          filled: true,
          fillColor: AppTheme.neutral,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}