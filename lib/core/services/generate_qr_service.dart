import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';

class GenerateQrService {

  /// RepaintBoundary widget ko PNG bytes mein convert karta hai
  static Future<Uint8List?> captureQrAsImage(GlobalKey qrKey) async {
    try {
      final boundary =
          qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint("QR Capture error: $e");
      return null;
    }
  }

  /// QR image ko device storage mein save karta hai
  /// [machineDbId] = primary key from DB (e.g. "3")
  static Future<String?> downloadQr(GlobalKey qrKey, String machineDbId) async {
    try {
      final bytes = await captureQrAsImage(qrKey);
      if (bytes == null) return null;

      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/machine_qr_id_$machineDbId.png';
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      debugPrint("QR saved at: $filePath");
      return filePath;
    } catch (e) {
      debugPrint("QR Download error: $e");
      return null;
    }
  }

  /// QR share/print karta hai via system share sheet
  /// [machineDbId] = primary key from DB (e.g. "3")
  static Future<void> printQr(GlobalKey qrKey, String machineDbId) async {
    try {
      final bytes = await captureQrAsImage(qrKey);
      if (bytes == null) return;

      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/machine_qr_id_$machineDbId.png';
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'Machine QR Code (DB ID: $machineDbId)',
        subject: 'Machine QR - ID $machineDbId',
      );
    } catch (e) {
      debugPrint("QR Print/Share error: $e");
    }
  }
}