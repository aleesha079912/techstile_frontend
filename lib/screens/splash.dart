import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:techstile_frontend/routes/routes.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();

    Timer(Duration(seconds: 10), () {
      Get.offAllNamed(AppRoutes.login); 
      
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              Image.asset(
                'assets/images/logo.png',
                width: 250,
                height: 250,
              ),

              SizedBox(height: 10),

              Text(
                "Textile Management System",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 20),

              Text(
                "Manage your workflow smarter, streamline every process, and watch your productivity soar.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}