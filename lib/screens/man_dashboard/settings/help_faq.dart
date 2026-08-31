import 'package:flutter/material.dart';
import 'package:techstile_frontend/core/utils/theme.dart';

class HelpFaqScreen extends StatelessWidget {
  const HelpFaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Help & FAQ",
        style: TextStyle(
          color: AppTheme.secondary
        ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [

          ExpansionTile(
            title: Text(
              "How do I approve production?",
            ),
            children: [
              Padding(
                padding: EdgeInsets.all(15),
                child: Text(
                  "Open Production Requests and click Approve.",
                ),
              ),
            ],
          ),

          ExpansionTile(
            title: Text(
              "How do I assign machines?",
            ),
            children: [
              Padding(
                padding: EdgeInsets.all(15),
                child: Text(
                  "Open Assign machine and assign machine.",
                ),
              ),
            ],
          ),

          ExpansionTile(
            title: Text(
              "How do I reset password?",
            ),
            children: [
              Padding(
                padding: EdgeInsets.all(15),
                child: Text(
                  "Open Settings → Reset Password.",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}