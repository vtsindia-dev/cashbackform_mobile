import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'common/route/router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() {
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
              title: 'Cashback Farms',
              theme: ThemeData(
                scaffoldBackgroundColor: Colors.white,
                textTheme: GoogleFonts.montserratTextTheme(),
              ),

              initialRoute: AppRoutes.splash,
              getPages: AppRoutes.routes,
              debugShowCheckedModeBanner: false,
            )
    );
  }
}