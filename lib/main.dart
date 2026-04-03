import 'package:cashback_farms/common/colours.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'common/route/router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'deeplink/deeplink_service/service.dart';
import 'network/network_service/no_internet_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

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


// CashBack IOS serverfile -----------------------(iOS Universal Links)
//
//
// {
// "applinks": {
// "apps": [],
// "details": [
// {
// "appID": "TEAMID.com.yourcompany.cashback_farms",
// "paths": [
// "/plot-marketplace/details/*",
// "/gioo-plots/details/*",
// "/syndicate-plots/details/*",
// "/rental-yield-plots/details/*",
// "/residential-property/details/*"
// ]
// }
// ]
// }
// }
//
//
//
//
// CashBack Android serverfile -----------------------(Android App Links)
//
// [{
// "relation": ["delegate_permission/common.handle_all_urls"],
// "target": {
// "namespace": "android_app",
// "package_name": "com.yourcompany.cashback_farms",
// "sha256_cert_fingerprints": [
// "YOUR_SHA256_FINGERPRINT_HERE"
// ]
// }
// }]