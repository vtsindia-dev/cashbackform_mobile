import 'package:cashback_farms/common/colours.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'common/route/router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown]
  );
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(414, 896),
      minTextAdapt: true,
      splitScreenMode: true,
        builder: (_, child) =>
            GetMaterialApp(
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
              builder: (context, child) {
                return SafeArea(
                  top: false,
                  bottom: true,
                  child: child!,
                );
              },
            )
    );
  }
}