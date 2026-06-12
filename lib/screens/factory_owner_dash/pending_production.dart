import 'package:flutter/material.dart';
import '../../core/services/pending_production_service.dart';
import '../../core/utils/theme.dart';
import 'package:techstile_frontend/widgets/drawer.dart';
class PendingProductionScreen
    extends StatefulWidget {
  const PendingProductionScreen({
    super.key
  });

  @override
  State<PendingProductionScreen>
      createState() =>
          _PendingProductionScreenState();
}

class _PendingProductionScreenState
    extends State<
        PendingProductionScreen> {
  final service =
      OwnerProductionService();

  List productions = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadProductions();
  }

  Future<void> loadProductions() async {
    final data =
        await service
            .getPendingProductions();

    setState(() {
      productions = data;
      loading = false;
    });
  }

  Future<void> approve(
      int id) async {
    bool success =
        await service
            .approveProduction(id);

    if (success) {
      loadProductions();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content:
              Text("Approved"),
        ),
      );
    }
  }

  Future<void> reject(
      int id) async {
    bool success =
        await service
            .rejectProduction(id);

    if (success) {
      loadProductions();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content:
              Text("Rejected"),
        ),
      );
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      drawer: const OwnerDrawer(),
      backgroundColor:
          AppTheme.secondary,

      appBar: AppBar(
        title: const Text(
          "Pending Production",
        ),
      ),

      body: loading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : productions.isEmpty
              ? const Center(
                  child: Text(
                    "No Pending Production",
                  ),
                )
              : ListView.builder(
                  padding:
                      const EdgeInsets
                          .all(15),

                  itemCount:
                      productions.length,

                  itemBuilder:
                      (_, index) {
                    final item =
                        productions[
                            index];

                    return Card(
                      elevation: 4,

                      margin:
                          const EdgeInsets
                              .only(
                        bottom: 15,
                      ),

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          15,
                        ),
                      ),

                      child:
                          Padding(
                        padding:
                            const EdgeInsets
                                .all(
                          15,
                        ),

                        child:
                            Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                          children: [

                            Text(
                              "Machine ID : ${item['machine_id']}",
                              style:
                                  TextStyle(
                                color:
                                    AppTheme.primary,
                                fontSize:
                                    18,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            const SizedBox(
                              height:
                                  10,
                            ),

                            Text(
                              "Employee ID : ${item['employee_id']}",
                            ),

                            Text(
                              "Employee Name : ${item['employee']?['user']?['name'] ?? 'N/A'}",
                            ),

                            Text(
                              "Variety : ${item['variety_type']}",
                            ),

                            Text(
                              "Ready Production : ${item['ready_production']}",
                            ),

                            Text(
                              "Total Length : ${item['total_length']}",
                            ),

                            const SizedBox(
                              height:
                                  15,
                            ),

                            Row(
                              children: [

                                Expanded(
                                  child:
                                      ElevatedButton(
                                    onPressed:
                                        () =>
                                            approve(
                                      item['id'],
                                    ),

                                    style:
                                        ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Colors.green,
                                    ),

                                    child:
                                        const Text(
                                      "Approve",
                                      style:
                                          TextStyle(
                                        color:
                                            Colors.white,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(
                                  width:
                                      10,
                                ),

                                Expanded(
                                  child:
                                      ElevatedButton(
                                    onPressed:
                                        () =>
                                            reject(
                                      item['id'],
                                    ),

                                    style:
                                        ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Colors.red,
                                    ),

                                    child:
                                        const Text(
                                      "Reject",
                                      style:
                                          TextStyle(
                                        color:
                                            Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}