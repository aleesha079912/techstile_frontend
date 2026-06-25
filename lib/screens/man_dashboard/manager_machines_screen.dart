import 'package:flutter/material.dart';
import '../../core/services/manager_service/manager_service.dart';
import '../../core/utils/theme.dart';
import '../../widgets/man_bottom_navbar.dart';
import 'package:get/get.dart';
import 'machine_detail_screen.dart';

class ManagerMachinesScreen extends StatefulWidget {
  final dynamic factoryId;

  const ManagerMachinesScreen({
    super.key,
    required this.factoryId,
  });

  @override
  State<ManagerMachinesScreen> createState() =>
      _ManagerMachinesScreenState();
}

class _ManagerMachinesScreenState
    extends State<ManagerMachinesScreen> {
  final _service = ManagerDashboardService();

  bool loading = true;

  List machines = [];
  List filteredMachines = [];

  String? error;

  final TextEditingController searchController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final res = await _service.getMachines(widget.factoryId);

      setState(() {
        machines = res;
        filteredMachines = res;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  void searchMachines(String value) {
    setState(() {
      filteredMachines = machines.where((machine) {
        final machineName =
            machine.machineName.toString().toLowerCase();

        final machineType =
            machine.type.toString().toLowerCase();

        return machineName.contains(value.toLowerCase()) ||
            machineType.contains(value.toLowerCase());
      }).toList();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,

      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Machines',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      body: loading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primary,
              ),
            )
          : error != null
              ? _errorView()
              : filteredMachines.isEmpty
                  ? _emptyView()
                  : Column(
                      children: [

                        /// SEARCH BAR
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: TextField(
                            controller: searchController,
                            onChanged: searchMachines,
                            decoration: InputDecoration(
                              hintText:
                                  "Search by machine name or type",
                              prefixIcon:
                                  const Icon(Icons.search),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),

                        /// MACHINE LIST
                        Expanded(
                          child: RefreshIndicator(
                            color: AppTheme.primary,
                            onRefresh: load,
                            child: ListView.builder(
                              padding:
                                  const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              itemCount:
                                  filteredMachines.length,
                              itemBuilder: (_, i) =>
                                  _machineCard(
                                      filteredMachines[i]),
                            ),
                          ),
                        ),
                      ],
                    ),

      bottomNavigationBar: ManagerBottomNav(
        currentIndex: 1,
        factoryId: widget.factoryId,
      ),
    );
  }

  Widget _errorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: AppTheme.error,
            ),

            const SizedBox(height: 12),

            Text(
              error ?? 'Something went wrong',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: load,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.precision_manufacturing_outlined,
            size: 48,
            color: AppTheme.neutral,
          ),

          const SizedBox(height: 12),

          const Text(
            'No machines found',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _machineCard(dynamic m) {
    return InkWell(
      borderRadius: AppTheme.cardRadius,

      onTap: () {
        Get.to(
          () => MachineDetailsScreen(
            machine: m,
            factoryId: widget.factoryId.toString(),
          ),
        );
      },

      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppTheme.cardRadius,
          boxShadow: AppTheme.softShadow,
        ),

        child: Row(
          children: [

            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color:
                    AppTheme.neutral.withOpacity(0.4),
                borderRadius:
                    BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.precision_manufacturing_rounded,
                color: AppTheme.primary,
                size: 24,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  Text(
                    m.machineName,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    m.type,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color:
                    AppTheme.success.withOpacity(0.12),
                borderRadius:
                    BorderRadius.circular(20),
              ),
              child: Text(
                m.id.toString(),
                style: const TextStyle(
                  color: AppTheme.success,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            const SizedBox(width: 5),

            const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: AppTheme.neutral,
            ),
          ],
        ),
      ),
    );
  }
}