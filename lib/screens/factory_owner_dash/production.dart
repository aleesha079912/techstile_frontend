import 'package:flutter/material.dart';
import '../../core/services/production_service.dart';
import '../../core/utils/theme.dart'; 
import '../../../../widgets/drawer.dart';
class ProductionScreen extends StatefulWidget {
  const ProductionScreen({super.key});

  @override
  State<ProductionScreen> createState() => _ProductionScreenState();
}

class _ProductionScreenState extends State<ProductionScreen> {
  final ProductionService _service = ProductionService();
  List<dynamic> _productions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    setState(() => _isLoading = true);
    final data = await _service.fetchProductions();
    setState(() {
      _productions = data;
      _isLoading = false;
    });
  }

  // Add/Edit Dialog
  void _showForm(dynamic item) {
    final isEdit = item != null;
    final varietyTypeController = TextEditingController(text: isEdit ? item['variety_type'] : '');
    final lengthController = TextEditingController(text: isEdit ? item['total_length'].toString() : '');
    final readyController = TextEditingController(text: isEdit ? item['ready_production'].toString() : '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? "Update Production" : "Add Production"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: varietyTypeController, decoration: const InputDecoration(labelText: "Variety Type")),
            TextField(controller: lengthController, decoration: const InputDecoration(labelText: "Total Length"), keyboardType: TextInputType.number),
            TextField(controller: readyController, decoration: const InputDecoration(labelText: "Ready Production"), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final now = DateTime.now();
              final Map<String, dynamic> data = {
                "variety_type": varietyTypeController.text,
                "total_length": lengthController.text,
                "ready_production": readyController.text,
                "machine_id": 1, // Static for now, you can add dropdown
                "employee_id": 1,
                "factory_id": 1,
                "manager_id": 1,

                  "shift_start": "${now.toString().substring(0, 10)} 09:00:00",
  "shift_end": "${now.toString().substring(0, 10)} 18:00:00"
              };

              bool success = isEdit 
                ? await _service.updateProduction(item['id'], data)
                : await _service.addProduction(data);

              if (success) {
                Navigator.pop(context);
                _loadData();
              }
            },
            child: const Text("Save"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: const OwnerDrawer(), 
      appBar: AppBar(title: const Text("Production Management")),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primary,
        onPressed: () => _showForm(null),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _productions.length,
              itemBuilder: (context, index) {
                final item = _productions[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text("${item['variety_type']}", style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary)),
                    subtitle: Text("Length: ${item['total_length']} | Ready: ${item['ready_production']}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(Icons.edit_outlined, color: AppTheme.tertiary), onPressed: () => _showForm(item)),
                        IconButton(
                          icon: const Icon(Icons.delete_outlined, color: Colors.red),
                          onPressed: () async {
                            if (await _service.deleteProduction(item['id'])) _loadData();
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

