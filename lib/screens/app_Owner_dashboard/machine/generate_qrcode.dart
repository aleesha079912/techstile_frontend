import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:techstile_frontend/core/services/generate_qr_service.dart';
import 'package:techstile_frontend/core/utils/theme.dart';
import 'package:techstile_frontend/widgets/bottom_nav_bar.dart';
import 'package:techstile_frontend/widgets/owner_drawer.dart';

class GenerateQrCodeScreen extends StatefulWidget {
  final String machineDbId;   // primary id from DB 
  final String machineLabel;  // display label 
  final int factoryId;        // factory identifier for navigation

  const GenerateQrCodeScreen({
    super.key,
    required this.machineDbId,
    required this.machineLabel,
    required this.factoryId,
  });

  @override
  State<GenerateQrCodeScreen> createState() => _GenerateQrCodeScreenState();
}

class _GenerateQrCodeScreenState extends State<GenerateQrCodeScreen> {
  final GlobalKey _qrKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const OwnerDrawer(),
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor:AppTheme.background,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Machine QR Code",
          style: TextStyle(
            color:AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          children: [
            // Header Info Card 
            Container(
             child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.info.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    
                  ),
                  const SizedBox(width: 14),
                 
                ],
              ),
            ),

            const SizedBox(height: 28),

            //  QR Code Card 
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppTheme.secondary,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color:AppTheme.onsurface.withOpacity(0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    "Scan to Identify Machine",
                    style: TextStyle(
                      fontSize: 14,
                      color:AppTheme.primary,
                       fontWeight: FontWeight.bold,
                      
                    ),
                  ),
                  const SizedBox(height: 20),

                  // QR wrapped in RepaintBoundary for capture
                  RepaintBoundary(
                    key: _qrKey,
                    child: Container(
                      color:AppTheme.secondary,
                      padding: const EdgeInsets.all(12),
                      child: QrImageView(
                        //  Primary DB ID stored in QR
                        data: widget.machineDbId,
                        version: QrVersions.auto,
                        size: 220,
                        eyeStyle: const QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: AppTheme.onsurface
                        ),
                        dataModuleStyle: const QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Machine label below QR
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.info.withOpacity(0.28),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.machineLabel,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color:AppTheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
            //Info Note 
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 172, 226, 220),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primary),
              ),
              child: Row(
                children: [
                  Icon(Icons.info,
                      color: AppTheme.primary, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Scanning this QR will load complete machine data using Machine ID: ${widget.machineDbId}",
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
       bottomNavigationBar: CustomBottomNav(currentIndex: 1, factoryId: widget.factoryId),
    );
  }
}

