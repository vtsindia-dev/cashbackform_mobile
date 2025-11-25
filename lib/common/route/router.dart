import 'package:get/get.dart';

import '../../features/auth/screens/login.dart';
import '../../features/dashboard/screens/dashboard.dart';
import '../../features/home/screens/home.dart';
import '../../features/splash/screens/splash.dart';


class AppRoutes {
  // Route names
  static const String splash = '/';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String home = '/home';
  static const String profile = '/menu';
  static const String settings = '/settings';

  // Route generator
  static List<GetPage> routes = [
    GetPage(
      name: splash,
      page: () => SplashScreen(),
      transition: Transition.fade,
    ),
    GetPage(
      name: login,
      page: () => Login(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: dashboard,
      page: () => Dashboard(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: home,
      page: () => Home(),
      transition: Transition.cupertino,
    ),

  ];

  // Navigation methods
  static void toDashboard() => Get.offAllNamed(dashboard);
  static void toLogin() => Get.offAllNamed(login);
  static void toProfile() => Get.toNamed(profile);
  static void toHome() => Get.offAllNamed(home);

  // Go back
  static void back() => Get.back();
}