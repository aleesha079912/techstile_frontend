import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class GenerateQrCodeScreen extends StatelessWidget {
  final String machineId;

  const GenerateQrCodeScreen({
    super.key,
    required this.machineId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Machine QR"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            QrImageView(
              data: machineId,
              version: QrVersions.auto,
              size: 250,
            ),

            const SizedBox(height: 20),

            Text(
              machineId,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}