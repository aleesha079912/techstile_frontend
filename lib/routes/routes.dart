import 'package:flutter/material.dart';
import 'package:frontpageui/screens/splash_screen.dart';
import 'package:frontpageui/screens/login_screen.dart';
import 'package:frontpageui/screens/signup_screen.dart';
import 'package:frontpageui/screens/dashboard_screen.dart';

class AppRoutes {

  static const splash = "/";
  static const login = "/login";
  static const signup = "/signup";
  static const dashboard = "/dashboard";

  static Map<String, WidgetBuilder> routes = {
    splash: (context) => SplashScreen(),
    login: (context) => LoginScreen(),
    signup: (context) => SignupScreen(),
    dashboard: (context) => DashboardScreen(),
  };
}