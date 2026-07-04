import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:techstile_frontend/core/utils/theme.dart';
import 'package:techstile_frontend/widgets/bottom_nav_bar.dart';
import 'package:get/get.dart';
import 'package:techstile_frontend/routes/routes.dart';
import 'package:techstile_frontend/core/services/machine_details_service.dart';
import 'package:techstile_frontend/screens/app_Owner_dashboard/machine/machine_detail.dart';
import 'package:techstile_frontend/core/services/machines_service.dart';
class ScanQRCodeScreen extends StatefulWidget {
  const ScanQRCodeScreen({super.key, required this.factoryId});

  final int factoryId;

  @override
  State<ScanQRCodeScreen> createState() => _ScanQRCodeScreenState();
}

class _ScanQRCodeScreenState extends State<ScanQRCodeScreen>
    with WidgetsBindingObserver {
  bool scanned = false;
  late MobileScannerController controller;
final MachineDetailsService machineService =
    Get.put(MachineDetailsService());
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      controller.stop();
    } else if (state == AppLifecycleState.resumed) {
      if (!scanned) controller.start();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller.stop();
    controller.dispose();
    super.dispose();
  }

 void _goBack() {
  controller.stop();
  Get.offAllNamed(AppRoutes.ownerDashboard);
}

 Future<void> _onDetect(BarcodeCapture capture) async {

  if (scanned) return;


  final code =
      capture.barcodes.firstOrNull?.rawValue ?? "";


  if(code.isEmpty) return;


  setState(() {
    scanned = true;
  });


  controller.stop();



  // QR se machine id mili
  await machineService.getMachineDetails(code);

final data = machineService.data;
if(data.isEmpty){
  Get.snackbar(
    "Error",
    "Machine not found",
  );

  setState(() {
    scanned=false;
  });

  controller.start();
  return;
}

final machine = Machine(
id: code,
  machineName: data['machine_name']?.toString() ?? "",
  type: data['machine_type']?.toString() ?? "",
  time: data['updated_at']?.toString() ?? "",
);


Get.to(
  ()=> MachineDetailScreen(
    machine: machine,
    onRefresh: (){
      machineService.getMachineDetails(code);
    }, factoryId: widget.factoryId.toString(),
    ),
  )?.then((_){

    if(mounted){

      setState(() {
        scanned=false;
      });

      controller.start();

    }

  });


}

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        controller.stop();
        return true;
      },
      child: Scaffold(
        drawer: const Drawer(),
        backgroundColor: AppTheme.background,

        appBar: AppBar(
          title: const Text("Scan Machine"),
          backgroundColor: AppTheme.primary,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _goBack, // ✅ camera stop + back
          ),
        ),

        body: Column(
          children: [
            const SizedBox(height: 30),
            const Text(
              "Scan Machine QR",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            const Text("Place QR code inside frame"),
            const SizedBox(height: 25),
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: MobileScanner(
                    controller: controller, // ✅ controller pass karo
                    onDetect: _onDetect,
                  ),
                ),
              ),
            ),
          ],
        ),

        bottomNavigationBar:  CustomBottomNav(currentIndex: 1, factoryId: widget.factoryId),
      ),
    );
  }
}