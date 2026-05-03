import 'package:get/get.dart';
import 'package:techstile_frontend/screens/app_Owner_dashboard/add_factories.dart';
import 'package:techstile_frontend/screens/app_Owner_dashboard/calculator_screen.dart';
import 'package:techstile_frontend/screens/app_Owner_dashboard/app_owner_dash.dart';
import 'package:techstile_frontend/screens/app_Owner_dashboard/notification_screen.dart';
import 'package:techstile_frontend/screens/app_Owner_dashboard/setting_screen.dart';
import 'package:techstile_frontend/screens/factory_owner_dash/machine/machines.dart';
import 'package:techstile_frontend/screens/factory_owner_dash/owner_dashboard.dart';
import 'package:techstile_frontend/screens/factory_owner_dash/payments.dart';
import 'package:techstile_frontend/screens/factory_owner_dash/user/manage_users.dart';
import 'package:techstile_frontend/screens/factory_owner_dash/user/users.dart';
import 'package:techstile_frontend/screens/signup.dart';
import 'package:techstile_frontend/screens/splash.dart';
import 'package:techstile_frontend/screens/login.dart';
import 'package:techstile_frontend/core/services/factory_service.dart';

class AppRoutes {
  static const splash = "/";
  static const login = "/login";
  static const signup = "/signup";
  static const dashboard = "/dashboard";
  static const addFactory = '/add-factory';
  static const calculator = '/calculator';
  static const notifications = '/notifications';
  static const settings = '/settings';
  static const machines = '/machines';
  static const users = '/users';
  static const payments = '/payments';
  static const ownerdashboardscreen = '/owner-dashboard-screen';
  static const manageusers = '/manage_users';
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
    GetPage(name: machines, page: () => const MachinesScreen()),
    GetPage(name: users, page: () => const UsersScreen()),
    GetPage(name: payments, page: () => const PaymentsScreen()),
    GetPage(name: ownerdashboardscreen, page: () => const OwnerDashboardScreen()),
    GetPage(
  name: addFactory,
  page: () => const AddFactoryScreen(),
  binding: BindingsBuilder(() {
    Get.lazyPut<FactoryController>(() => FactoryController(), fenix: true);
  }),
  transition: Transition.rightToLeftWithFade,
),
    GetPage(
  name: manageusers,
  page: () => const ManageUsersScreen(),
),
  ];
}
