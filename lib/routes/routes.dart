import 'package:get/get.dart';
import 'package:techstile_frontend/screens/employee_dashboard/employee_enter_production.dart';
import 'package:techstile_frontend/screens/employee_dashboard/history_screen.dart';
import 'package:techstile_frontend/screens/employee_dashboard/machine_detail_screen.dart';
import 'package:techstile_frontend/screens/employee_dashboard/profile.dart';
import 'package:techstile_frontend/core/services/auth_service.dart';
import 'package:techstile_frontend/screens/factory_owner_dash/owner_production_page.dart';
import 'package:techstile_frontend/screens/man_dashboard/manager_emloyee_detail_screen.dart';





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
// import 'package:techstile_frontend/screens/factory_owner_dash/payments.dart';
// import '../screens/factory_owner_dash/factory_dashboard.dart';
// import 'package:techstile_frontend/screens/factory_owner_dash/user/users.dart';
import 'package:techstile_frontend/screens/man_dashboard/manager_scan_code.dart';
import 'package:techstile_frontend/screens/man_dashboard/manager_dashboard.dart';

import 'package:techstile_frontend/screens/man_dashboard/manager_machines_screen.dart';
import 'package:techstile_frontend/screens/man_dashboard/manager_employee_screen.dart';
import 'package:techstile_frontend/screens/man_dashboard/manager_payments_screen.dart';

import 'package:techstile_frontend/screens/man_dashboard/machine_detail_screen.dart';
import 'package:techstile_frontend/screens/employee_dashboard/employee_dashboard.dart';

import 'package:techstile_frontend/core/services/factory_service.dart';
import 'package:techstile_frontend/screens/man_dashboard/manager_production_page.dart';
import 'package:techstile_frontend/screens/man_dashboard/manager_profile.dart';
import 'package:techstile_frontend/screens/app_Owner_dashboard/machine/generate_qrcode.dart';
import 'package:techstile_frontend/screens/app_Owner_dashboard/machine/scan_code.dart';
import 'package:techstile_frontend/screens/man_dashboard/settings/editprofile.dart';
import 'package:techstile_frontend/screens/man_dashboard/settings/help_faq.dart';
import 'package:techstile_frontend/screens/man_dashboard/settings/manager_settings_screen.dart';
import 'package:techstile_frontend/screens/man_dashboard/settings/about_app.dart';
import 'package:techstile_frontend/screens/man_dashboard/manager_employee_notification.dart';
import 'package:techstile_frontend/widgets/man_drawer.dart';
import 'package:techstile_frontend/widgets/emp_drawer.dart';
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
  static const managerProfile = "/manager-profile";
static const managerScanMachine = "/manager-scan-machine";
static const String managersettings =
    '/manager-settings';

 static const editProfile = "/edit-profile";
  static const  chnagePassword = "/change-password";
  static const  helpFaq = "/help-faq";
  static const  aboutApp = '/about-app';
static const managerNotifications = "/manager-notifications";
static const employeeNotifications = "/employee-notifications";
 // owner dashboard
  static const addFactory = '/add-factory';
  static const scanMachine = "/scan-machine";
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
 static const ownerProduction = '/owner-production';
 static const managerProduction = '/manager-production';
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
// MANAGER DASHBOARD
GetPage(
  name: AppRoutes.managerDashboard,
  page: () => ManagerDashboard(
    factoryId: AuthService.factoryId,
  ),
),

// MANAGER MACHINES
GetPage(
  name: AppRoutes.managerMachines,
  page: () => ManagerMachinesScreen(
    factoryId: AuthService.factoryId,
  ),
),

// MANAGER EMPLOYEES
GetPage(
  name: AppRoutes.managerEmployees,
  page: () => ManagerEmployeesScreen(
    factoryId: AuthService.factoryId,
  ),
),

// MANAGER PAYMENTS
GetPage(
  name: AppRoutes.managerPayments,
  page: () => ManagerPaymentsScreen(
    factoryId: AuthService.factoryId,
  ),
),

// MANAGER PRODUCTIONS
GetPage(
  name: AppRoutes.managerProduction,
  page: () => ManagerProductionsPage(
    factoryId: AuthService.factoryId,
  ),
),

// MACHINE DETAILS
GetPage(
  name: AppRoutes.MachineDetails,
  page: () {
    final args = Get.arguments as Map;

    return MachineDetailsScreen(
      machine: args['machine'],
      factoryId: args['factoryId'],
    );
  },
),

// MANAGER EMPLOYEE DETAILS
GetPage(
  name: AppRoutes.managerEmployeeDetail,
  page: () {
    final args = Get.arguments as Map;

    return ManagerEmployeeDetailScreen(
      employeeId: args['employeeId'],
      factoryId: AuthService.factoryId,
    );
  },
),

// MANAGER PROFILE
GetPage(
  name: AppRoutes.managerProfile,
  page: () => ManagerProfileScreen(
    userId: AuthService.userId,
  ),
),
// MANAGER SCAN 
GetPage(
  name: AppRoutes.managerScanMachine,
  page: () => ManagerScanQRScreen(
    factoryId: AuthService.factoryId,
  ),
),
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

//MANAGER SIDE SETTINGS
GetPage(
  name: '/edit-profile',
  page: () => const EditProfileScreen(),
),
GetPage(
  name: AppRoutes.managersettings,
  page: () => const ManagerSettingsScreen(),
),
// GetPage(
//   name: AppRoutes.managerNotifications,
//   page: () => ManagerPaymentsScreen(
//     factoryId: AuthService.factoryId,
//   ),
// ),
GetPage(
  name: AppRoutes.managerNotifications,
  page: () => NotificationPage(
    drawer: ManagerDrawer(
      userId: AuthService.userId,
      factoryId: AuthService.factoryId,
    ),
    title: "Manager Notifications",
  ),
),

GetPage(
  name: AppRoutes.employeeNotifications,
  page: () => NotificationPage(
    drawer: EmployeeDrawer(userId: AuthService.userId),
    title: "Employee Notifications",
  ),
),

GetPage(
  name: '/help-faq',
  page: () => const HelpFaqScreen(),
),
GetPage(
  name: '/about-app',
  page: () => const AboutAppScreen(),
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
      name: machines,
      page: () => const MachinesScreen(factoryId: 0),
    ),

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
  page: () => MachineDetailScreen(
    machineId: Get.arguments,
  ),
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

    print("Arguments = ${Get.arguments}");

    final args = Get.arguments;

    final userId = args is Map
        ? args['userId']
        : null;

    print("User ID = $userId");

    return UserProfileScreen(
      userId: userId ?? 0,
    );
  },
),
 GetPage(
  name: '/owner-production',
  page: () => OwnerProductionsPage(
    factoryId: Get.arguments,
  ),
),
    GetPage(name: AppRoutes.history, page: () => const HistoryScreen()),
  ];

  

}

