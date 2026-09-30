import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/utils/theme.dart';
import '../../../../core/services/variety_service.dart';

class VarietiesSheet extends StatefulWidget {
  const VarietiesSheet({super.key});

  @override
  State<VarietiesSheet> createState() => _VarietiesSheetState();
}

class _VarietiesSheetState extends State<VarietiesSheet> {
  final nameCtrl = TextEditingController();
  List<Variety> varieties = [];
  bool loading = true;
  bool adding = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    super.dispose();
  }

  void _error(String msg) {
    Get.snackbar("Error", msg,
        backgroundColor: AppTheme.error, colorText: AppTheme.textSecondary);
  }

  Future<void> _load() async {
    final list = await VarietyService.instance.fetch();
    if (!mounted) return;
    setState(() {
      varieties = list;
      loading = false;
    });
  }

  Future<void> _add() async {
    final name = nameCtrl.text.trim();
    if (name.isEmpty) {
      _error("Enter variety name");
      return;
    }
    final exists =
        varieties.any((v) => v.name.toLowerCase() == name.toLowerCase());
    if (exists) {
      _error("This variety already exists");
      return;
    }

    setState(() => adding = true);
    final error = await VarietyService.instance.add(name);
    if (!mounted) return;
    setState(() => adding = false);

    if (error == null) {
      nameCtrl.clear();
      _load();
    } else {
      _error(error);
    }
  }

  Future<void> _delete(Variety v) async {
    final ok = await VarietyService.instance.delete(v.id);
    if (ok) {
      _load();
    } else {
      _error("Variety not deleted");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.background,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            left: 20,
            right: 20,
            top: 20,
          ),
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
              const SizedBox(height: 16),
              const Text(
                "Varieties",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: nameCtrl,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        hintText: "New variety name",
                        prefixIcon: const Icon(Icons.category_outlined),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 80,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: adding ? null : _add,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        minimumSize: const Size(80, 50),
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: adding
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: AppTheme.secondary))
                          : const Text("Add",
                              style: TextStyle(color: AppTheme.textSecondary)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Flexible(
                child: loading
                    ? const Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator(),
                      )
                    : varieties.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(24),
                            child: Text(
                              "No varieties added yet",
                              style: TextStyle(color: AppTheme.textPrimary),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: varieties.length,
                            itemBuilder: (_, i) {
                              final v = varieties[i];
                              return ListTile(
                                dense: true,
                                leading: const Icon(Icons.label_outline,
                                    color: AppTheme.primary),
                                title: Text(
                                  v.name,
                                  style: const TextStyle(
                                      color: AppTheme.textPrimary),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: AppTheme.error),
                                  onPressed: () => _delete(v),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}