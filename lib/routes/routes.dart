import 'package:get/get.dart';
import 'package:techstile_frontend/screens/employee_dashboard/employee_enter_production.dart';
import 'package:techstile_frontend/screens/employee_dashboard/history_screen.dart';
import 'package:techstile_frontend/screens/employee_dashboard/machine_detail_screen.dart';
import 'package:techstile_frontend/screens/employee_dashboard/profile.dart';
import 'package:techstile_frontend/screens/man_dashboard/manager_emloyee_deatil_screen.dart';
// import 'package:techstile_frontend/screens/factory_owner_dash/factory_dashboard.dart';

import 'package:techstile_frontend/screens/splash.dart';
import 'package:techstile_frontend/screens/login.dart';
import 'package:techstile_frontend/screens/signup.dart';

import 'package:techstile_frontend/screens/app_Owner_dashboard/app_owner_dash.dart';
import 'package:techstile_frontend/screens/app_Owner_dashboard/add_factories.dart';
import 'package:techstile_frontend/screens/app_Owner_dashboard/manage_user.dart';
import 'package:techstile_frontend/screens/app_Owner_dashboard/notification_screen.dart';
import 'package:techstile_frontend/screens/app_Owner_dashboard/setting_screen.dart';

import 'package:techstile_frontend/screens/app_Owner_dashboard/machine/manage_machines.dart';
import 'package:techstile_frontend/screens/factory_owner_dash/payments.dart';
// import '../screens/factory_owner_dash/factory_dashboard.dart';
// import 'package:techstile_frontend/screens/factory_owner_dash/user/users.dart';

import 'package:techstile_frontend/screens/man_dashboard/manager_dashboard.dart';

import 'package:techstile_frontend/screens/man_dashboard/manager_machines_screen.dart';
import 'package:techstile_frontend/screens/man_dashboard/manager_employee_screen.dart';
import 'package:techstile_frontend/screens/man_dashboard/manager_payments_screen.dart';
import 'package:techstile_frontend/screens/man_dashboard/machine_detail_screen.dart';
import 'package:techstile_frontend/screens/employee_dashboard/employee_dashboard.dart';

import 'package:techstile_frontend/core/services/factory_service.dart';
import 'package:techstile_frontend/screens/app_Owner_dashboard/machine/generate_qrcode.dart';

class AppRoutes {
  static const splash = "/";
  static const login = "/login";
  static const signup = "/signup";

  static const ownerDashboard = "/owner-dashboard";
  static const String managerDashboard = "/manager-dashboard";
  static const employeeDashboard = "/employee-dashboard";

  //manager routes
  static const managerMachines = "/manager-machines";
  static const managerEmployees = "/manager-employees";
  static const managerPayments = "/manager-payments";
  static const MachineDetails = '/machine_details';
  static const managerEmployeeDetail = '/manager-employee-detail';
  // owner dashboard
  static const addFactory = '/add-factory';
  static const calculator = '/calculator';
  static const notifications = '/notifications';
  static const settings = '/settings';
  static const machines = '/machines';
  static const users = '/users';
  static const payments = '/payments';
  static const manageusers = '/manage_users';
  static const generateQRCode = '/generate_qr_code';
  static const machineDetail = '/machine-detail';
  //  static const String factoryDashboard = "/factoryDashboard";
  //employee dashboard routes
  static const empDashboard = '/employee-dashboard';
  static const empmachineDetail = '/machine-detail';
  static const enterProduction = '/enter-production';
  static const profile = '/profile';
  static const history = '/history';

  static List<GetPage> routes = [
    GetPage(name: splash, page: () => SplashScreen()),

    GetPage(name: login, page: () => LoginScreen()),

    GetPage(name: signup, page: () => SignupScreen()),

    /// OWNER DASHBOARD
    GetPage(
      name: ownerDashboard,
      page: () => const OwnerDashboardScreen(factoryId: 0),
      binding: BindingsBuilder(() {
        Get.lazyPut<FactoryController>(() => FactoryController(), fenix: true);
      }),
      transition: Transition.fadeIn,
    ),

    // ── MANAGER DASHBOARD (Tab 1) ───────────────────────────────────────────
    GetPage(
      name: managerDashboard,
      page: () {
        final factoryId = Get.arguments;
        return ManagerDashboard(factoryId: factoryId);
      },
    ),

    // ── MANAGER MACHINES (Tab 2) ────────────────────────────────────────────
    GetPage(
      name: AppRoutes.managerMachines,
      page: () {
        final factoryId = Get.arguments;
        return ManagerMachinesScreen(factoryId: factoryId);
      },
    ),

    // ── MANAGER EMPLOYEES (Tab 3) ───────────────────────────────────────────
    GetPage(
      name: AppRoutes.managerEmployees,
      page: () {
        final factoryId = Get.arguments;
        return ManagerEmployeesScreen(factoryId: factoryId);
      },
    ),

    // ── MANAGER PAYMENTS (Tab 4) ────────────────────────────────────────────
    GetPage(
      name: AppRoutes.managerPayments,
      page: () {
        final factoryId = Get.arguments;
        return ManagerPaymentsScreen(factoryId: factoryId);
      },
    ),
    // --Manager Details 
    
GetPage(
  name: AppRoutes.MachineDetails,
  page: () {

    final data = Get.arguments as Map;

    return MachineDetailsScreen(
      machine: data['machine'],
      factoryId: data['factoryId'],
    );

  },
),

 GetPage(
      name: AppRoutes.managerEmployeeDetail,
      page: () => ManagerEmployeeDetailScreen(
        employeeId: Get.arguments,
      ),
    ),
    /// EMPLOYEE DASHBOARD
    GetPage(
      name: employeeDashboard,
      page: () => EmployeeDashboard(),
      transition: Transition.fadeIn,
    ),

    GetPage(
      name: addFactory,
      page: () => const AddFactoryScreen(),
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
    GetPage(name: machines, page: () => const MachinesScreen(factoryId: 0)),
    GetPage(
      name: payments,
      page: () {
        final args = Get.arguments;
        final factoryId = args is int
            ? args
            : int.tryParse(args?.toString() ?? '') ?? 0;
        return PaymentsScreen(factoryId: factoryId);
      },
    ),

    GetPage(
      name: machines,
      page: () => const MachinesScreen(factoryId: 0),
    ),

    // GetPage(
    //   name: users,
    //   page: () => const UsersScreen(),
    // ),

    // GetPage(
    //   name: payments,
    //   page: () {
    //     final args = Get.arguments;
    //     final factoryId = args is int
    //         ? args
    //         : int.tryParse(args?.toString() ?? '') ?? 0;
    //     return PaymentsScreen(factoryId: factoryId);
    //   },
    // ),

    GetPage(name: manageusers, page: () => const ManageUsersScreen()),

    GetPage(
      name: generateQRCode,
      page: () {
        final args = Get.arguments;
        final factoryId = args is int
            ? args
            : int.tryParse(
                    args is Map ? args['factoryId']?.toString() ?? '' : '',
                  ) ??
                  0;
        return GenerateQrCodeScreen(
          machineDbId: args is String ? args : (args?['machineDbId'] ?? ''),
          machineLabel: args is String ? args : (args?['machineLabel'] ?? ''),
          factoryId: factoryId,
        );
      },
    ),

    GetPage(
      name: AppRoutes.empmachineDetail,
      page: () => MachineDetailScreen(machineId: Get.arguments),
    ),

    //employee dashboard side routes
    GetPage(name: empDashboard, page: () => const EmployeeDashboard()),
    GetPage(
      name: AppRoutes.enterProduction,
      page: () {
        final args = Get.arguments;
        // ✅ Map se machineId nikalo
        final machineId = args is Map
            ? args['machineId']?.toString() ?? ''
            : args?.toString() ?? '';

        return EnterProductionScreen(machineId: machineId);
      },
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () {
        final args = Get.arguments;
        final userId = args is Map
            ? int.tryParse(args['userId']?.toString() ?? '') ?? 0
            : int.tryParse(args?.toString() ?? '') ?? 0;
        return UserProfileScreen(userId: userId);
      },
    ),
    GetPage(name: AppRoutes.history, page: () => const HistoryScreen()),
  ];
}
