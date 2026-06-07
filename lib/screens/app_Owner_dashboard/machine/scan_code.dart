import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:techstile_frontend/core/utils/theme.dart';
import 'machine_detail_screen.dart';
import '../../../../../widgets/drawer.dart';

class ScanQrCodeScreen extends StatefulWidget {
  const ScanQrCodeScreen({super.key});

  @override
  State<ScanQrCodeScreen> createState() => _ScanQrCodeScreenState();
}

class _ScanQrCodeScreenState extends State<ScanQrCodeScreen>
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
      controller.start();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller.stop();
    controller.dispose();
    super.dispose();
  }

  // ✅ Back jane ka ek function — sab jagah yahi use karo
  void _goBack() {
    controller.stop();
    controller.dispose();
    Navigator.pop(context);
  }

  void _onDetect(BarcodeCapture capture) {
    if (scanned) return;
    final barcode = capture.barcodes.firstOrNull;
    final machineId = barcode?.rawValue;
    if (machineId == null) return;

    setState(() => scanned = true);
    controller.stop();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MachineDetailsScreen(machineId: machineId),
      ),
    ).then((_) {
      if (mounted) {
        setState(() => scanned = false);
        controller.start();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // ✅ WillPopScope — Android physical back button bhi handle karo
    return WillPopScope(
      onWillPop: () async {
        controller.stop();
        controller.dispose();
        return true;
      },
      child: Scaffold(
        drawer: const OwnerDrawer(),
        body: Stack(
          children: [
            /// Camera
            MobileScanner(
              controller: controller,
              onDetect: _onDetect,
            ),

            /// Dark Overlay
            Container(color: Colors.black.withOpacity(0.45)),

            /// Top Header
            Positioned(
              top: 60,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  /// ✅ Back button — controller.stop() ke saath
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppTheme.primary,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: _goBack, // ✅ yahan fix hai
                    ),
                  ),

                  /// Title
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withOpacity(0.4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: const Text(
                      "SCAN QR CODE",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),

                  /// Flash
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppTheme.primary,
                    child: IconButton(
                      icon: const Icon(Icons.flash_on, color: Colors.white),
                      onPressed: () => controller.toggleTorch(),
                    ),
                  ),
                ],
              ),
            ),

            /// Instructions
            Positioned(
              top: 180,
              left: 20,
              right: 20,
              child: Column(
                children: const [
                  Text(
                    "Align QR Code Within Frame",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Place the machine QR code inside the scanner area for automatic detection.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 15),
                  ),
                ],
              ),
            ),

            /// Scanner Frame
            const Center(
              child: SizedBox(
                width: 320,
                height: 320,
                child: ScannerOverlay(),
              ),
            ),

            /// Bottom Card
            Positioned(
              left: 20,
              right: 20,
              bottom: 70,
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.tertiary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.qr_code_scanner,
                          color: Colors.white),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "SCANNING MACHINE",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            scanned
                                ? "QR Code Detected!"
                                : "Waiting For QR Code...",
                            style: TextStyle(
                              color: scanned
                                  ? AppTheme.tertiary
                                  : Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            /// Loading overlay
            if (scanned)
              Container(
                color: Colors.black54,
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}

class ScannerOverlay extends StatelessWidget {
  const ScannerOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      height: 280,
      child: Stack(
        children: [
          Positioned(top: 0, left: 0, child: _corner(top: true, left: true)),
          Positioned(top: 0, right: 0, child: _corner(top: true, right: true)),
          Positioned(
              bottom: 0, left: 0, child: _corner(bottom: true, left: true)),
          Positioned(
              bottom: 0, right: 0, child: _corner(bottom: true, right: true)),
          Positioned(
            top: 140,
            left: 20,
            right: 20,
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                color: AppTheme.tertiary,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.tertiary.withOpacity(0.8),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _corner({
    bool top = false,
    bool bottom = false,
    bool left = false,
    bool right = false,
  }) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft:
              top && left ? const Radius.circular(18) : Radius.zero,
          topRight:
              top && right ? const Radius.circular(18) : Radius.zero,
          bottomLeft:
              bottom && left ? const Radius.circular(18) : Radius.zero,
          bottomRight:
              bottom && right ? const Radius.circular(18) : Radius.zero,
        ),
        border: Border(
          top: top
              ? BorderSide(color: AppTheme.tertiary, width: 4)
              : BorderSide.none,
          bottom: bottom
              ? BorderSide(color: AppTheme.tertiary, width: 4)
              : BorderSide.none,
          left: left
              ? BorderSide(color: AppTheme.tertiary, width: 4)
              : BorderSide.none,
          right: right
              ? BorderSide(color: AppTheme.tertiary, width: 4)
              : BorderSide.none,
        ),
      ),
    );
  }
}