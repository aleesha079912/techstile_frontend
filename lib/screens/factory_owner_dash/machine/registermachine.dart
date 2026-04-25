import 'package:flutter/material.dart';
import 'package:techstile_frontend/core/services/machines_service.dart';
import '../../../core/utils/theme.dart';
import 'generate_qrcode.dart';
import '../../../../widgets/bottom_nav_bar.dart';

class RegisterMachineScreen extends StatefulWidget {
  const RegisterMachineScreen({super.key});

  @override
  State<RegisterMachineScreen> createState() => _RegisterMachineScreenState();
}

class _RegisterMachineScreenState extends State<RegisterMachineScreen> {
  final service = RegisterMachineService();

  final nameCtrl = TextEditingController();
  final modelCtrl = TextEditingController();
  final locationCtrl = TextEditingController();

  String machineType = "Rapier";
  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.secondary,
      appBar: AppBar(
        title: const Text("TextileOS"),
        backgroundColor: Color(0xFF1E3A8A), // AppTheme.primary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("SYSTEM CONFIGURATION", style: TextStyle(fontSize: 12)),

            const SizedBox(height: 8),

            const Text(
              "Register Machine",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            const Text("Integrate a new weaving unit into the system."),

            const SizedBox(height: 20),

            /// FORM CARD
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _input(
                    "Machine Name",
                    nameCtrl,
                    hint: "e.g. Master Loom Alpha-1",
                  ),

                  _dropdown(),

                  _input("Model Number", modelCtrl, hint: "TX-9000-MOD"),

                  _datePicker(),

                  _input(
                    "Floor Location",
                    locationCtrl,
                    hint: "Bay 4, Sector G",
                  ),

                  const SizedBox(height: 16),

                  /// INFO BOX
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.secondary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.settings, color: Colors.blue),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "System Validation: Machine will be assigned a unique ID.",
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.secondary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () async {
                        await service.registerMachine(
                          nameCtrl.text,
                          machineType,
                          modelCtrl.text,
                          selectedDate,
                          locationCtrl.text,
                        );

                        if (!context.mounted) return;

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                GenerateQrCodeScreen(data: nameCtrl.text),
                          ),
                        );
                      },
                      child: const Text("Register Machine"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // bottomNavigationBar: const BottomNavBar(currentIndex: 1),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 1),
    );
  }

  /// TEXT INPUT
  Widget _input(String label, TextEditingController ctrl, {String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: AppTheme.secondary,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  /// DROPDOWN
  Widget _dropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Machine Type"),
        const SizedBox(height: 6),
        DropdownButtonFormField(
          initialValue: machineType,
          items: [
            "Rapier",
            "Air Jet",
            "Water Jet",
          ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (val) {
            setState(() => machineType = val.toString());
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: AppTheme.secondary,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  /// DATE PICKER
  Widget _datePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Installation Date"),
        const SizedBox(height: 6),
        TextField(
          readOnly: true,
          decoration: InputDecoration(
            hintText: selectedDate == null
                ? "mm/dd/yyyy"
                : selectedDate.toString().split(" ")[0],
            suffixIcon: const Icon(Icons.calendar_today),
            filled: true,
            fillColor: AppTheme.secondary,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
              initialDate: DateTime.now(),
            );
            if (picked != null) {
              setState(() => selectedDate = picked);
            }
          },
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
