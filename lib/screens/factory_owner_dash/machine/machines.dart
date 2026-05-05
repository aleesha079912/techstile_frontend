import 'package:flutter/material.dart';
import '../../../../core/services/machines_service.dart';
import '../../../../core/utils/theme.dart'; 
import '../../../../widgets/bottom_nav_bar.dart';
import '../../../../widgets/drawer.dart'; 

class MachinesScreen extends StatefulWidget {
  const MachinesScreen({super.key});

  @override
  State<MachinesScreen> createState() => _MachinesScreenState();
}

class _MachinesScreenState extends State<MachinesScreen> {
  final service = MachinesService.instance;
  MachinesData? data;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  void load() async {
    setState(() => isLoading = true);
    final res = await service.fetchMachines();
    setState(() {
      data = res;
      isLoading = false;
    });
  }

  // --- 1. CRUD: ADD & UPDATE POPUP ---
  void _showMachineForm(BuildContext context, {Machine? machine}) {
    final idCtrl = TextEditingController(text: machine?.machineId);
    final typeCtrl = TextEditingController(text: machine?.type);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom, 
          left: 20, right: 20, top: 20
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 20),
              Text(machine == null ? "Register New Machine" : "Update Machine Info", 
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primary)),
              const SizedBox(height: 20),
              
              _buildField(idCtrl, "Machine ID (e.g. LM-8402)", Icons.tag),
              _buildField(typeCtrl, "Machine Type (e.g. Rapier)", Icons.settings_outlined),

              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary, 
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                  ),
                  onPressed: () async {
                    if (idCtrl.text.isEmpty || typeCtrl.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
                      return;
                    }

                    bool success;
                    if (machine == null) {
                      success = await service.addMachine(idCtrl.text, typeCtrl.text);
                    } else {
                      success = await service.updateMachine(machine.id, idCtrl.text, typeCtrl.text);
                    }
                    
                    if (mounted && success) {
                      Navigator.pop(context);
                      load(); 
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Something went wrong!")));
                    }
                  },
                  child: Text(machine == null ? "Register Machine" : "Update Machine", style: const TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // --- 2. CRUD: DELETE LOGIC ---
  void _handleDelete(String id) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Machine"),
        content: const Text("Are you sure you want to remove this machine?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Delete", style: TextStyle(color: Colors.red))),
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
      backgroundColor: AppTheme.secondary,
      drawer: const OwnerDrawer(), 
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded, color: Colors.black),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primary,
        onPressed: () => _showMachineForm(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const Align(alignment: Alignment.centerLeft, child: Text("All Machines", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold))),
                const Align(alignment: Alignment.centerLeft, child: Text("Real-time list of loom assets")),
                const SizedBox(height: 16),

                // Stats row (Updated to show total count since status is missing)
                Row(
                  children: [
                    _statCard("Total Assets", data?.machines.length ?? 0, AppTheme.primary),
                    const SizedBox(width: 8),
                    _statCard("Active", data?.machines.length ?? 0, Colors.green),
                  ],
                ),
                const SizedBox(height: 16),

                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async => load(),
                    child: data!.machines.isEmpty 
                      ? const Center(child: Text("No machines found"))
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 80),
                          itemCount: data!.machines.length,
                          itemBuilder: (context, i) => _machineTile(data!.machines[i]),
                        ),
                  ),
                ),
              ],
            ),
          ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 1),
    );
  }

  Widget _statCard(String title, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 6),
            Text("$count", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _machineTile(Machine m) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(m.machineId, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(m.type, style: const TextStyle(color: Colors.grey)),
                Text("Last Update: ${m.time}", style: const TextStyle(fontSize: 10, color: Colors.blueGrey)),
              ],
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () => _showMachineForm(context, machine: m),
                child: const Icon(Icons.edit_outlined, size: 22, color: AppTheme.primary),
              ),
              const SizedBox(width: 15),
              GestureDetector(
                onTap: () => _handleDelete(m.id),
                child: const Icon(Icons.delete_outline, size: 22, color: Colors.redAccent),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String hint, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl, 
        decoration: InputDecoration(
          prefixIcon: Icon(icon, size: 20, color: AppTheme.primary),
          hintText: hint,
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        ),
      ),
    );
  }
}