import 'package:flutter/material.dart';
import '../../../../core/utils/theme.dart';
import '../../../../widgets/drawer.dart';
import '../../../../core/services/role_service.dart';

class AssignFactoryScreen extends StatefulWidget {
  final int managerId;

  const AssignFactoryScreen({
    super.key,
    required this.managerId,
  });

  @override
  State<AssignFactoryScreen> createState() => _AssignFactoryScreenState();
}

class _AssignFactoryScreenState extends State<AssignFactoryScreen> {
  final RoleService _service = RoleService();

  List<dynamic> factories = [];
  int? selectedFactoryId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFactories();
  }

  Future<void> _loadFactories() async {
    // TODO: replace with your real API
    var data = await _service.getRoles(); // temporary (replace later)

    setState(() {
      factories = data;
      isLoading = false;
    });
  }

  Future<void> _assignFactory() async {
    if (selectedFactoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a factory"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // TODO: API call later
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Factory Assigned to Manager ID: ${widget.managerId}",
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const OwnerDrawer(),
      backgroundColor: const Color(0xffF5F7FB),

      appBar: AppBar(
        title: const Text("Assign Factory"),
        backgroundColor: AppTheme.primary,
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Select Factory for Manager",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),

                  const SizedBox(height: 15),

                  /// FACTORY LIST
                  Expanded(
                    child: ListView.builder(
                      itemCount: factories.length,
                      itemBuilder: (context, index) {
                        final factory = factories[index];

                        final isSelected =
                            selectedFactoryId == factory['id'];

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedFactoryId = factory['id'];
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.primary.withOpacity(0.1)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? AppTheme.primary
                                    : Colors.grey.shade200,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.factory,
                                  color: AppTheme.primary,
                                ),
                                const SizedBox(width: 10),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        factory['name'] ?? "Factory",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Tap to assign",
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                if (isSelected)
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// ASSIGN BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _assignFactory,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Assign Factory",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}