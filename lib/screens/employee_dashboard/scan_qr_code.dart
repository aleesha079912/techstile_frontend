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
  State<ScanqrCodeScreen> createState() =>
      _ScanqrCodeScreenState();
}

class _ScanqrCodeScreenState
    extends State<ScanqrCodeScreen> {
  bool scanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const EmployeeDrawer(),
      backgroundColor: AppTheme.secondary,

      appBar: AppBar(
        title: const Text("Scan Machine"),
        backgroundColor: AppTheme.primary,
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

          const Text(
            "Place QR code inside frame",
          ),

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
                  onDetect: (capture) {
                    if (scanned) return;

                    final barcode =
                        capture.barcodes.first;

                    final code =
                        barcode.rawValue ?? '';

                    if (code.isNotEmpty) {
                      scanned = true;

                      Get.toNamed(
                        AppRoutes.empmachineDetail,
                        arguments: code,
                      );
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
       bottomNavigationBar: EmployeeBottomNav(
          currentIndex: 1,
        ),
    );
  }
}