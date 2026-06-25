import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/services/manager_service/manager_service.dart';
import '../../core/utils/theme.dart';
import '../../widgets/man_bottom_navbar.dart';
import 'manager_emloyee_deatil_screen.dart';

class ManagerEmployeesScreen extends StatefulWidget {
  final dynamic factoryId;

  const ManagerEmployeesScreen({
    super.key,
    required this.factoryId,
  });

  @override
  State<ManagerEmployeesScreen> createState() =>
      _ManagerEmployeesScreenState();
}

class _ManagerEmployeesScreenState
    extends State<ManagerEmployeesScreen> {
  final _service = ManagerDashboardService();

  bool loading = true;
  String? error;

  List employees = [];
  List filteredEmployees = [];

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
      final res =
          await _service.getEmployees(widget.factoryId);

      setState(() {
        employees = res;
        filteredEmployees = res;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  void searchEmployee(String value) {
    setState(() {
      filteredEmployees = employees.where((emp) {
        final name =
            emp['user']?['name']
                    ?.toString()
                    .toLowerCase() ??
                '';

        return name.contains(
          value.toLowerCase(),
        );
      }).toList();
    });
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
          'Employees',
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
              : employees.isEmpty
                  ? _emptyView()
                  : Column(
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.all(16),
                          child: TextField(
                            controller:
                                searchController,
                            onChanged:
                                searchEmployee,
                            decoration:
                                InputDecoration(
                              hintText:
                                  "Search Employee",
                              prefixIcon:
                                  const Icon(
                                Icons.search,
                              ),
                              filled: true,
                              fillColor:
                                  Colors.white,
                              border:
                                  OutlineInputBorder(
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                            12),
                              ),
                            ),
                          ),
                        ),

                        Expanded(
                          child:
                              RefreshIndicator(
                            color:
                                AppTheme.primary,
                            onRefresh: load,
                            child:
                                ListView.builder(
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal: 16,
                              ),
                              itemCount:
                                  filteredEmployees
                                      .length,
                              itemBuilder:
                                  (_, i) =>
                                      _employeeCard(
                                filteredEmployees[
                                    i],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

      bottomNavigationBar: ManagerBottomNav(
        currentIndex: 2,
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
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.people_outline_rounded,
            size: 48,
            color: AppTheme.neutral,
          ),
          SizedBox(height: 12),
          Text(
            'No employees assigned',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _employeeCard(dynamic e) {
    final name =
        e['user']?['name']?.toString() ??
            'Employee';

    return InkWell(
      onTap: () {
        Get.to(
          () => ManagerEmployeeDetailScreen(
            employeeId: int.parse(
              e['id'].toString(),
            ),
          ),
        );
      },
      child: Container(
        margin:
            const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppTheme.cardRadius,
          boxShadow: AppTheme.softShadow,
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor:
                  AppTheme.secondary
                      .withOpacity(0.15),
              child: Text(
                name.isNotEmpty
                    ? name[0]
                        .toUpperCase()
                    : '?',
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Text(
                    name,
                    style:
                        const TextStyle(
                      color: AppTheme
                          .textPrimary,
                      fontWeight:
                          FontWeight
                              .w700,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(
                      height: 2),

                  Text(
                    'Shift: ${e['shift_starttime'] ?? '--'} - ${e['shift_endtime'] ?? '--'}',
                    style:
                        const TextStyle(
                      color: AppTheme
                          .textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppTheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}