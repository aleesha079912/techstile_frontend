import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/utils/theme.dart';
import '../../core/services/employee_service/employee_production_service.dart';
import '../../core/services/auth_service.dart';

class EnterProductionScreen extends StatefulWidget {
  final String machineId;

  const EnterProductionScreen({
    super.key,
    required this.machineId,
  });

  @override
  State<EnterProductionScreen> createState() =>
      _EnterProductionScreenState();
}

class _EnterProductionScreenState
    extends State<EnterProductionScreen> {

  final varietyController =
      TextEditingController();

  final lengthController =
      TextEditingController();

  final readyController =
      TextEditingController();

  bool loading = false;

  Future<void> submitProduction() async {

    final user = AuthService.user;
    final employeeId = user?['id'];

    bool success =
        await EmployeeProductionService()
            .submitProduction(
      machineId:
          int.parse(widget.machineId),

      employeeId:
          employeeId,

      factoryId: 1,

      varietyType:
          varietyController.text,

      totalLength:
          double.parse(
        lengthController.text,
      ),

      readyProduction:
          double.parse(
        readyController.text,
      ),
    );

    if (success) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Production Submitted",
          ),
        ),
      );
    }
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppTheme.secondary,

      appBar: AppBar(
        title: const Text(
          "Enter Production",
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Card(
          elevation: 4,

          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(20),
          ),

          child: Padding(
            padding:
                const EdgeInsets.all(20),

            child: Column(
              children: [

                TextField(
                  controller:
                      varietyController,

                  decoration:
                      const InputDecoration(
                    labelText:
                        "Variety Type",
                    border:
                        OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 15),

                TextField(
                  controller:
                      lengthController,

                  keyboardType:
                      TextInputType.number,

                  decoration:
                      const InputDecoration(
                    labelText:
                        "Total Length",
                    border:
                        OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 15),

                TextField(
                  controller:
                      readyController,

                  keyboardType:
                      TextInputType.number,

                  decoration:
                      const InputDecoration(
                    labelText:
                        "Ready Production",
                    border:
                        OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 55,

                  child: ElevatedButton(

                    onPressed:
                        loading
                            ? null
                            : submitProduction,

                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          AppTheme.primary,
                    ),

                    child:
                        loading
                            ? const CircularProgressIndicator(
                                color:
                                    Colors.white,
                              )
                            : const Text(
                                "Submit Production",
                                style:
                                    TextStyle(
                                  color:
                                      Colors.white,
                                  fontSize:
                                      16,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}