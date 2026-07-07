import 'package:flutter/material.dart';
import '../../../../core/services/machines_service.dart';
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

  List<Machine> filteredMachines = [];
  final TextEditingController searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    load();
  }

  void load() async {
    setState(() => isLoading = true);

    final res = await service.fetchMachines(widget.factoryId);

    setState(() {
      data = res;
      filteredMachines = res?.machines ?? [];
      isLoading = false;
    });
  }

  void searchMachines(String query) {
    final all = data?.machines ?? [];

    setState(() {
      filteredMachines = all.where((m) {
        return m.machineName
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            m.type.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  // --- ADD / UPDATE ---
  void _showMachineForm(BuildContext context, {Machine? machine}) {
    final idCtrl = TextEditingController(text: machine?.machineName);
    final typeCtrl = TextEditingController(text: machine?.type);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor:AppTheme.background,
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
                machine == null
                    ? "Register New Machine"
                    : "Update Machine Info",
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                  ),
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
      if (success) load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: AppTheme.secondary,
        ),
        title: const Text(
          "All Machines",
          style: TextStyle(
            color: AppTheme.secondary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [

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
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      _statCard("Total Assets",
                          data?.totalMachines ?? (data?.machines.length ?? 0), AppTheme.primary),
                      const SizedBox(width: 8),
                      _statCard("Active",
                          data?.activeMachines ?? 0, Colors.green),
                    ],
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => _showMachineForm(context),
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text(
                        "Add Machine",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async => load(),
                      child: filteredMachines.isEmpty
                          ? const Center(child: Text("No machines found"))
                          : ListView.builder(
                              padding: const EdgeInsets.only(bottom: 80),
                              itemCount: filteredMachines.length,
                              itemBuilder: (context, i) =>
                                  _machineTile(filteredMachines[i]),
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

  Widget _statCard(String title, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.secondary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 6),
            Text("$count",
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _machineTile(Machine m) {
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
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    m.machineName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    m.type,
                    style: const TextStyle(color: AppTheme.neutral),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                GestureDetector(
                  onTap: () => _showMachineForm(context, machine: m),
                  child: const Icon(Icons.edit, color: AppTheme.primary),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => _handleDelete(m.id),
                  child: const Icon(Icons.delete, color:AppTheme.error),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
      TextEditingController ctrl, String hint, IconData icon) {
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