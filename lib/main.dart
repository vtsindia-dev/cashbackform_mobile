import  'package:cashback_farms/common/colours.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'common/route/router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'deeplink/deeplink_service/service.dart';
import 'firebase_option.dart';
import 'network/network_service/no_internet_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'notifcation/service/notification_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("🔔 Background message received: ${message.messageId}");
  print("   Title: ${message.notification?.title}");
  print("   Body: ${message.notification?.body}");
  print("   Data: ${message.data}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // ─── FIREBASE INIT ──────────────────────────────────────────────────────────
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Register background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Request notification permission (iOS + Android 13+)
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  // For iOS — show notification in foreground
  await FirebaseMessaging.instance
      .setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  await DeepLinkService().init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(414, 896),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) => GetMaterialApp(
        title: 'Geo Rental Farms',
        theme: ThemeData(
          progressIndicatorTheme: const ProgressIndicatorThemeData(
            color: AppColor.primary,
            linearTrackColor: Colors.grey,
          ),
          colorScheme: const ColorScheme.light(
            primary: AppColor.primary,
          ),
          scaffoldBackgroundColor: Colors.white,
          textTheme: GoogleFonts.montserratTextTheme(),
        ),
        initialRoute: AppRoutes.splash,
        getPages: AppRoutes.routes,
        debugShowCheckedModeBanner: false,
        initialBinding: BindingsBuilder(() {
          Get.put(NetworkService(), permanent: true);
          Get.put(NotificationService(), permanent: true); // ADD THIS
        }),
        builder: (context, child) {
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