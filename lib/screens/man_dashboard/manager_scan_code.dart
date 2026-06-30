import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/utils/theme.dart';
import '../../core/services/machine_details_service.dart';
import '../../routes/routes.dart';
import '../../../../core/services/machines_service.dart';
class ManagerScanQRScreen extends StatefulWidget {
  final int factoryId;

  const ManagerScanQRScreen({
    super.key,
    required this.factoryId,
  });

  @override
  State<ManagerScanQRScreen> createState() => _ManagerScanQRScreenState();
}

class _ManagerScanQRScreenState extends State<ManagerScanQRScreen> {
  final MachineDetailsService machineService =
      Get.put(MachineDetailsService());

  bool scanned = false;

  late MobileScannerController controller;

  @override
  void initState() {
    super.initState();

    controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.unrestricted,
      facing: CameraFacing.back,
      returnImage: false,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (scanned) return;

    final code = capture.barcodes.first.rawValue;

    if (code == null || code.isEmpty) return;

    scanned = true;

    controller.stop();

    try {
     await machineService.getMachineDetails(code);

final machineData = machineService.data;

final machine = Machine(
  id: code,
  machineName: machineData['machine_name']?.toString() ?? "",
  type: machineData['machine_type']?.toString() ?? "",
  time: machineData['updated_at']?.toString() ?? "",
);

Get.toNamed(
  AppRoutes.MachineDetails,
  arguments: {
    "machine": machine,
    "factoryId": widget.factoryId.toString(),
  },
)?.then((_) {
        scanned = false;
        controller.start();
      });
    } catch (e) {
      scanned = false;
      controller.start();

      Get.snackbar(
        "Error",
        e.toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,

      appBar: AppBar(
        title: const Text("Scan Machine"),
        backgroundColor: AppTheme.primary,
      ),

      body: Column(
        children: [
          const SizedBox(height: 20),

          const Text(
            "Scan Machine QR Code",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            "Place QR inside frame",
          ),

          const SizedBox(height: 20),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: MobileScanner(
                  controller: controller,
                  onDetect: _onDetect,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}