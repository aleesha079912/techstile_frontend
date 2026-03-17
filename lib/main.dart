import 'package:flutter/material.dart';
import 'package:frontpageui/routes/app_routes.dart';

void main() {
  runApp(const ServEaseApp());
}

class ServEaseApp extends StatelessWidget {
  const ServEaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ServEase',

      // first screen
      initialRoute: AppRoutes.splash,

      // all routes
      routes: AppRoutes.routes,

      // basic theme
      theme: ThemeData(
        primaryColor: const Color(0xFF5B8DEF),
        scaffoldBackgroundColor: const Color(0xFFF5F6F8),
        fontFamily: 'Roboto',
      ),
    );
  }
}
