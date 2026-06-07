import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';
class GenerateQrService {
  /// QR widget ko image bytes mein convert karo
  static Future<Uint8List?> captureQrAsImage(GlobalKey qrKey) async {
    try {
      final boundary =
          qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      print("Capture error: $e");
      return null;
    }
  }

  /// QR image ko device storage mein save karo
  static Future<String?> downloadQr(GlobalKey qrKey, String machineId) async {
    try {
      final bytes = await captureQrAsImage(qrKey);
      if (bytes == null) return null;

      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/qr_machine_$machineId.png';
      final file = File(filePath);
      await file.writeAsBytes(bytes);
      return filePath;
    } catch (e) {
      print("Download error: $e");
      return null;
    }
  }

  /// QR share/print ke liye
  static Future<void> printQr(GlobalKey qrKey, String machineId) async {
    try {
      final bytes = await captureQrAsImage(qrKey);
      if (bytes == null) return;

      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/qr_machine_$machineId.png';
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      // Share sheet open hoga — user wahan se print kar sakta hai
      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'Machine QR Code: $machineId',
        subject: 'Machine QR - $machineId',
      );
    } catch (e) {
      print("Print error: $e");
    }
  }
}