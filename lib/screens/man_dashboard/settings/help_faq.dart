import 'package:flutter/material.dart';

class HelpFaqScreen extends StatelessWidget {
  const HelpFaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Help & FAQ"),
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
                  "Open Employee Management and assign machine.",
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