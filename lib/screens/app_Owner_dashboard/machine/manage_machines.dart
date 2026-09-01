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

  final TextEditingController searchCtrl =
      TextEditingController();

  // false = show all machines
  // true = show only active machines
  bool showOnlyActive = false;

  @override
  void initState() {
    super.initState();
    load();
  }


  // LOAD MACHINES


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
        // Only active machines
        filteredMachines =
            allMachines.where((m) => m.isActive).toList();
      } else {
        // All machines
        filteredMachines = allMachines;
      }

      isLoading = false;
    });
  }


  // SEARCH MACHINES


  void searchMachines(String query) {
    final allMachines = data?.machines ?? [];

    final searchText = query.toLowerCase();

    setState(() {
      filteredMachines = allMachines.where((m) {
        // Search by machine name
        final nameMatch = m.machineName
            .toLowerCase()
            .contains(searchText);

        // Search by machine type
        final typeMatch = m.type
            .toLowerCase()
            .contains(searchText);

        // Active filter
        final activeMatch =
            !showOnlyActive || m.isActive;

        return (nameMatch || typeMatch) && activeMatch;
      }).toList();
    });
  }


  // ADD / UPDATE MACHINE


  void _showMachineForm(
    BuildContext context, {
    Machine? machine,
  }) {
    final idCtrl =
        TextEditingController(text: machine?.machineName);

    final typeCtrl =
        TextEditingController(text: machine?.type);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
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

              _buildField(
                idCtrl,
                "Machine Name",
                Icons.abc,
              ),

              _buildField(
                typeCtrl,
                "Machine Type",
                Icons.category,
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                  ),
                  onPressed: () async {
                  
                    // ADD MACHINE
                  

                    if (machine == null) {
                      final result =
                          await service.addMachine(
                        idCtrl.text,
                        typeCtrl.text,
                        widget.factoryId,
                      );

                      if (!mounted) return;

                      if (result != null &&
                          result['success'] == true) {
                        Get.back();
                        load();
                      }
                    }

                  
                    // UPDATE MACHINE
                  

                    else {
                      bool success =
                          await service.updateMachine(
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
                    machine == null
                        ? "Register Machine"
                        : "Update Machine",
                    style: const TextStyle(
                      color: AppTheme.secondary,
                    ),
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


  // DELETE MACHINE


  void _handleDelete(String id) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Machine"),
        content: const Text(
          "Are you sure?",
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),

          TextButton(
            onPressed: () =>
                Navigator.pop(ctx, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      bool success =
          await service.deleteMachine(id);

      if (success) {
        load();
      }
    }
  }


  // BUILD SCREEN


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
         automaticallyImplyLeading: false,
        backgroundColor: AppTheme.primary,
        elevation: 0,
        title: const Text(
          "All Machines",
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 16,
              ),

              child: Column(
                children: [
                  const SizedBox(height: 16),

             
                  // SEARCH
              

                  TextField(
                    controller: searchCtrl,
                    onChanged: searchMachines,

                    decoration: InputDecoration(
                      hintText:
                          "Search machines...",

                      prefixIcon:
                          const Icon(Icons.search),

                      filled: true,

                      fillColor:
                          AppTheme.secondary,

                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(
                          12,
                        ),
                        borderSide:
                            BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

             
                  // TOTAL And ACTIVE CARDS
             

                  Row(
                    children: [
                    
                      // TOTAL ASSETS
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              showOnlyActive =
                                  false;
                            });

                            searchMachines(
                              searchCtrl.text,
                            );
                          },

                          child: _statCard(
                            "Total Machines",
                            data?.totalMachines ??
                                (data?.machines.length ??
                                    0),
                            AppTheme.primary,
                            isSelected:
                                !showOnlyActive,
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                    
                      // ACTIVE
                    

                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              showOnlyActive =
                                  true;
                            });

                            searchMachines(
                              searchCtrl.text,
                            );
                          },

                          child: _statCard(
                            "Active",
                            data?.activeMachines ??
                                0,
                            Colors.green,
                            isSelected:
                                showOnlyActive,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

               
                  // ADD MACHINE BUTTON
               

                  SizedBox(
                    width: double.infinity,

                    child: ElevatedButton.icon(
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            AppTheme.primary,

                        padding:
                            const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                      ),

                      onPressed: () =>
                          _showMachineForm(context),

                      icon: const Icon(
                        Icons.add,
                        color: Colors.white,
                      ),

                      label: const Text(
                        "Add Machine",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

               
                  // MACHINE LIST
               

                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        load();
                      },

                      child:
                          filteredMachines.isEmpty
                              ? const Center(
                                  child: Text(
                                    "No machines found",
                                  ),
                                )
                              : ListView.builder(
                                  padding:
                                      const EdgeInsets.only(
                                    bottom: 80,
                                  ),

                                  itemCount:
                                      filteredMachines
                                          .length,

                                  itemBuilder:
                                      (context, i) {
                                    return _machineTile(
                                      filteredMachines[i],
                                    );
                                  },
                                ),
                    ),
                  ),
                ],
              ),
            ),

      // BOTTOM NAVIGATION
    

      bottomNavigationBar:
          CustomBottomNav(
        currentIndex: 1,
        factoryId: widget.factoryId,
      ),
    );
  }


  // STAT CARD


  Widget _statCard(
    String title,
    int count,
    Color color, {
    bool isSelected = false,
  }) {
    return Container(
      padding:
          const EdgeInsets.all(12),

      decoration: BoxDecoration(
        color: AppTheme.secondary,

        borderRadius:
            BorderRadius.circular(12),

        border: Border.all(
          color: isSelected
              ? color
              : Colors.transparent,

          width: 2,
        ),
      ),

      child: Column(
        children: [
          Text(
            title,
            style:
                const TextStyle(
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            "$count",

            style: TextStyle(
              fontSize: 22,
              fontWeight:
                  FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }


  // MACHINE TILE


  Widget _machineTile(Machine m) {
    // Backend se is_active aa raha hai
    final bool isActive = m.isActive;

    return InkWell(
      onTap: () {
        Get.to(
          () => MachineDetailScreen(
            machine: m,
            factoryId:
                widget.factoryId.toString(),
            onRefresh: load,
          ),
        );
      },

      borderRadius:
          BorderRadius.circular(12),

      child: Container(
        margin:
            const EdgeInsets.only(
          bottom: 10,
        ),

        padding:
            const EdgeInsets.all(14),

        decoration: BoxDecoration(
       
          // ACTIVE = GREEN
          // INACTIVE = NORMAL
       

          color: isActive
              ? Colors.green.shade100
              : AppTheme.secondary,

          borderRadius:
              BorderRadius.circular(12),

          border: Border.all(
            color: isActive
                ?  AppTheme.success
                : Colors.transparent,

            width: 1.5,
          ),
        ),

        child: Row(
          children: [
       
            // MACHINE ICON
       

            Container(
              padding:
                  const EdgeInsets.all(8),

              decoration: BoxDecoration(
                color: isActive
                    ?AppTheme.success
                    : AppTheme.primary,

                shape: BoxShape.circle,
              ),

              child: const Icon(
                Icons.precision_manufacturing,
                 color: AppTheme.secondary,
                size: 20,
              ),
            ),

            const SizedBox(width: 12),

       
            // MACHINE NAME + TYPE
       

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Text(
                    m.machineName,

                    style: TextStyle(
                      fontWeight:
                          FontWeight.bold,

                      fontSize: 16,

                      color: isActive
                          ? AppTheme.success
                          : AppTheme.primary,
                    ),
                  ),

                  Text(
                    m.type,

                    style:
                        const TextStyle(
                      color:
                          AppTheme.neutral,
                    ),
                  ),

               
                  // ACTIVE MESSAGE
               

                  if (isActive)
                    const Padding(
                      padding:
                          EdgeInsets.only(
                        top: 4,
                      ),
                    ),
                ],
              ),
            ),
       

            if (isActive)
              Container(
                margin:
                    const EdgeInsets.only(
                  right: 10,
                ),

                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 5,
                ),

                decoration:
                    BoxDecoration(
                   color: AppTheme.success,

                  borderRadius:
                      BorderRadius.circular(
                    20,
                  ),
                ),

                child: const Text(
                  "ACTIVE",

                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),

       
            // EDIT BUTTON
       

            GestureDetector(
              onTap: () =>
                  _showMachineForm(
                context,
                machine: m,
              ),

              child: const Icon(
                Icons.edit,
                color:
                    AppTheme.primary,
              ),
            ),

            const SizedBox(width: 10),

       
            // DELETE BUTTON
       

            GestureDetector(
              onTap: () =>
                  _handleDelete(m.id),

              child: const Icon(
                Icons.delete,
                color:
                    AppTheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }


  // TEXT FIELD


  Widget _buildField(
    TextEditingController ctrl,
    String hint,
    IconData icon,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 12,
      ),

      child: TextField(
        controller: ctrl,

        decoration:
            InputDecoration(
          prefixIcon: Icon(
            icon,
            color:
                AppTheme.primary,
          ),

          hintText: hint,

          filled: true,

          fillColor:
              AppTheme.neutral,

          border:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
              10,
            ),

            borderSide:
                BorderSide.none,
          ),
        ),
      ),
    );
  }
}