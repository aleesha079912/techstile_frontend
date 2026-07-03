import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:get/get.dart';
import '../../../../../widgets/emp_db_bot_nav_bar.dart';
import '../../core/utils/theme.dart';
import '../../routes/routes.dart';
import '../../widgets/emp_drawer.dart';

class ScanqrCodeScreen extends StatefulWidget {
  const ScanqrCodeScreen({super.key});

  @override
  State<ScanqrCodeScreen> createState() => _ScanqrCodeScreenState();
}

class _ScanqrCodeScreenState extends State<ScanqrCodeScreen>
    with WidgetsBindingObserver {
  bool scanned = false;
  late MobileScannerController controller;

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

  void _onDetect(BarcodeCapture capture) {
    if (scanned) return;
    final code = capture.barcodes.firstOrNull?.rawValue ?? '';
    if (code.isEmpty) return;

    setState(() => scanned = true);
    controller.stop();

    Get.toNamed(
      AppRoutes.empmachineDetail,
      arguments: code,
    )?.then((_) {
      if (mounted) {
        setState(() => scanned = false);
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
        drawer: const EmployeeDrawer(),
        backgroundColor: AppTheme.secondary,
      
        appBar: AppBar(
          backgroundColor: AppTheme.primary,
          title: Text("Scan Machine QR", style: TextStyle(color: AppTheme.secondary),),
          elevation: 0,
          iconTheme: IconThemeData(color: AppTheme.secondary),
          leading: Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu_rounded, color: AppTheme.secondary),
              onPressed: () => Scaffold.of(ctx).openDrawer(),
            ),
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

        bottomNavigationBar: EmployeeBottomNav(currentIndex: 1),
      ),
    );
  }
}