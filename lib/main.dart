import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:techstile_frontend/routes/routes.dart';
import '../../../core/utils/theme.dart';
void main() {
  runApp(const TECHstile());
}

class TECHstile extends StatelessWidget {
  const TECHstile({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TECHstile',
      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.routes,
       theme: AppTheme.lightTheme,
    );
  }
}
