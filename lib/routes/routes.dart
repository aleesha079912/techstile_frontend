import 'package:get/get.dart';
import 'package:techstile_frontend/screens/splash.dart';
import 'package:techstile_frontend/screens/login.dart';
import 'package:techstile_frontend/screens/signup.dart';
import 'package:techstile_frontend/screens/dashboard.dart';

class AppRoutes {

  static const splash = "/";
  static const login = "/login";
  static const signup = "/signup";
  static const dashboard = "/dashboard";

  static List<GetPage> routes = [
    GetPage(name: splash, page: () => SplashScreen()),
    GetPage(name: login, page: () => LoginScreen()),
    GetPage(name: signup, page: () => SignupScreen()),
    GetPage(name: dashboard, page: () => const DashboardScreen()),
  ];
}