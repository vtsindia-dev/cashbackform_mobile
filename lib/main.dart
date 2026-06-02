import 'dart:io';
import 'package:cashback_farms/common/colours.dart';
import 'package:cashback_farms/common/route/router.dart';
import 'package:cashback_farms/network/network_service/no_internet_service.dart';
import 'package:cashback_farms/notifcation/service/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'deeplink/deeplink_service/service.dart';


class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await DeepLinkService().init();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(414, 896),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) => GetMaterialApp(
        title: 'Geofarms',
        theme: ThemeData(
          progressIndicatorTheme: const ProgressIndicatorThemeData(
            color: AppColor.primary,
            linearTrackColor: Colors.grey,
          ),
          colorScheme: const ColorScheme.light(
            primary: AppColor.primary,
          ),
          scaffoldBackgroundColor: Colors.white,
          textTheme: GoogleFonts.poppinsTextTheme(),
        ),
        initialRoute: AppRoutes.splash,
        getPages: AppRoutes.routes,
        debugShowCheckedModeBanner: false,
        initialBinding: BindingsBuilder(() {
          Get.put(NetworkService(), permanent: true);
        }),
        builder: (context, child) {
          LocalNotificationService.initialize(context);
          return SafeArea(
            top: false,
            bottom: true,
            child: child!,
          );
        },
      ),
    );
  }
}
