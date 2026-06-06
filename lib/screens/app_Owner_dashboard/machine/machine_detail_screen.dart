import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:techstile_frontend/core/services/machine_details_service.dart';
import '../../../../../widgets/drawer.dart';
class MachineDetailsScreen extends StatefulWidget {

  final String machineId;

  const MachineDetailsScreen({
    super.key,
    required this.machineId,
  });

  @override
  State<MachineDetailsScreen> createState() =>
      _MachineDetailsScreenState();
}

class _MachineDetailsScreenState
    extends State<MachineDetailsScreen> {

  final controller =
      Get.put(MachineDetailsService());

  @override
  void initState() {
    super.initState();

    controller.getMachineDetails(
      widget.machineId,
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
drawer: const OwnerDrawer(),
      appBar: AppBar(
        title: const Text(
          "Machine Details",
        ),
      ),

      body: Obx(() {

        if (controller.loading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final data =
            controller.data;

        return SingleChildScrollView(
          padding:
              const EdgeInsets.all(16),

          child: Card(
            elevation: 5,
            shape:
                RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(15),
            ),

            child: Padding(
              padding:
                  const EdgeInsets.all(20),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  infoTile(
                    "Machine ID",
                    data['machine']
                            ['machine_id']
                        .toString(),
                  ),

                  infoTile(
                    "Employee",
                    data['employee_name']
                            ?.toString() ??
                        "-",
                  ),

                  infoTile(
                    "Factory",
                    data['factory_name']
                            ?.toString() ??
                        "-",
                  ),

                  infoTile(
                    "Variety",
                    data['variety']
                            ?.toString() ??
                        "-",
                  ),

                  infoTile(
                    "Ready Production",
                    data['ready_production']
                            ?.toString() ??
                        "-",
                  ),

                  infoTile(
                    "Assign Date",
                    data['assign_date']
                            ?.toString() ??
                        "-",
                  ),

                  infoTile(
                    "Status",
                    data['machine_status']
                            ?.toString() ??
                        "-",
                  ),

                  infoTile(
                    "Total Production",
                    data['total_production']
                            ?.toString() ??
                        "-",
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget infoTile(
      String title,
      String value) {

    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 10,
      ),

      child: Row(
        children: [

          Expanded(
            flex: 2,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),

          Expanded(
            flex: 3,
            child: Text(value),
          ),
        ],
      ),
    );
  }
}