import 'package:flutter/material.dart';
import 'package:techstile_frontend/core/services/manage_users_service.dart';
import '../../../../core/utils/theme.dart';

class AssignFactoryPopup extends StatefulWidget {
  final int userId;

  const AssignFactoryPopup({super.key, required this.userId});

  @override
  State<AssignFactoryPopup> createState() => _AssignFactoryPopupState();
}

class _AssignFactoryPopupState extends State<AssignFactoryPopup> {
  final _service = ManageUsersService.instance;
  List<dynamic> factories = [];
  int? selectedFactoryId;
  bool isLoading = true;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    _loadFactories();
  }

  Future<void> _loadFactories() async {
    // Use the service method that returns all factories. The ManageUsersService
    // defines getFactories().
    final data = await _service.getFactories();
    setState(() {
      factories = data;
      isLoading = false;
    });
  }

  Future<void> _assign() async {
    if (selectedFactoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a factory"),
            backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => saving = true);

    bool success = await _service.assignFactoryToUser(
      userId: widget.userId,
      factoryId: selectedFactoryId!,
    );

    setState(() => saving = false);

    if (success && mounted) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Factory Assigned Successfully"),
            backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Title
            const Text("Assign Factory",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text("Select a factory to assign to this manager",
                style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 16),

            // ── Factory list
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : factories.isEmpty
                    ? const Text("No factories found",
                        style: TextStyle(color: Colors.grey))
                    : SizedBox(
                        height: 260,
                        child: ListView.builder(
                          itemCount: factories.length,
                          itemBuilder: (context, index) {
                            final factory = factories[index];
                            final isSelected =
                                selectedFactoryId == factory['id'];

                            return GestureDetector(
                              onTap: () => setState(
                                  () => selectedFactoryId = factory['id']),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppTheme.primary.withOpacity(0.08)
                                      : Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppTheme.primary
                                        : Colors.grey.shade200,
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.factory,
                                        color: isSelected
                                            ? AppTheme.primary
                                            : Colors.grey),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        factory['name'] ?? "Factory",
                                        style: TextStyle(
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          color: isSelected
                                              ? AppTheme.primary
                                              : Colors.black,
                                        ),
                                      ),
                                    ),
                                    if (isSelected)
                                      const Icon(Icons.check_circle,
                                          color: Colors.green, size: 20),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

            const SizedBox(height: 12),

            // ── Assign button
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: saving ? null : _assign,
                    child: saving
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Text("Assign"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}