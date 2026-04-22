import 'package:get/get.dart';
import 'package:techstile_frontend/screens/dashboard/add_factories.dart';
import 'package:techstile_frontend/screens/dashboard/calculator_screen.dart';
import 'package:techstile_frontend/screens/dashboard/my_factories.dart';
import 'package:techstile_frontend/screens/dashboard/notification_screen.dart';
import 'package:techstile_frontend/screens/dashboard/setting_screen.dart';
import 'package:techstile_frontend/screens/signup.dart';
import 'package:techstile_frontend/screens/splash.dart';
import 'package:techstile_frontend/screens/login.dart';

import 'package:techstile_frontend/screens/signup.dart';
import 'package:techstile_frontend/screens/add_factories.dart';

class AppRoutes {

  static const splash = "/";
  static const login = "/login";
  static const signup = "/signup";
  static const dashboard = "/dashboard";
  static const addFactory   = '/add-factory';
  static const calculator   = '/calculator';
  static const notifications = '/notifications';
  static const settings     = '/settings';

  static List<GetPage> routes = [
    GetPage(name: splash, page: () => SplashScreen()),
    GetPage(name: login, page: () => LoginScreen()),
    GetPage(name: signup, page: () => SignupScreen()),
    GetPage(
      name: dashboard,
      page: () => const OwnerDashboard(),
      binding: BindingsBuilder(() {
        Get.put(FactoryController());
      }),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: addFactory,
      page: () => const AddFactoryScreen(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: calculator,
      page: () => const CalculatorScreen(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: notifications,
      page: () => const NotificationScreen(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: settings,
      page: () => const SettingsScreen(),
      transition: Transition.rightToLeftWithFade,
    ),
  ];
}