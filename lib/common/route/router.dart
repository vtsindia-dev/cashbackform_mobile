import 'package:cashback_farms/features/auth/screens/registration.dart';
import 'package:cashback_farms/features/gioo_plots/screens/gioo_details.dart';
import 'package:cashback_farms/features/gioo_plots/screens/gioo_plot.dart';
import 'package:cashback_farms/features/material_store/screens/material_store.dart';
import 'package:cashback_farms/features/material_store/screens/my_enquiry_list.dart';
import 'package:cashback_farms/features/syndicate_plot/screens/syndicate_details.dart';
import 'package:get/get.dart';

import '../../features/auth/screens/login.dart';
import '../../features/dashboard/screens/dashboard.dart';
import '../../features/home/screens/home.dart';
import '../../features/material_store/screens/materialstore_details.dart';
import '../../features/plot_market/screens/myplot_list.dart';
import '../../features/plot_market/screens/plot_market.dart';
import '../../features/plot_market/screens/plotmarket_details.dart';
import '../../features/profile/screen/profile.dart';
import '../../features/service/screen/my_service_enquiry.dart';
import '../../features/service/screen/service.dart';
import '../../features/splash/screens/splash.dart';
import '../../features/syndicate_plot/screens/syndicate_plot.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String home = '/home';
  static const String materialStore = '/materialStore';
  static const String service = '/service';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String register = '/register';
  static const String syndicate = '/syndicate';
  static const String gioo = '/gioo';
  static const String plotMarket = '/plotMarket';
  static const String syndicateDetails = '/syndicateDetails';
  static const String giooDetails = '/giooDetails';
  static const String plotMarketDetails = '/plotMarketDetails';
  static const String materialDetails = '/materialDetails';
  static const String myProperty = '/myProperty';
  static const String myServiceList = '/myServiceList';
  static const String myMaterialList = '/myMaterialList';
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
    GetPage(
      name: profile,
      page: () => ProfileForm(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: materialStore,
      page: () => MaterialStore(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: myMaterialList,
      page: () => MyMaterialList(),
      transition: Transition.cupertino,
    ), GetPage(
      name: service,
      page: () => Service(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: syndicate,
      page: () => SyndicatePlot(),
      transition: Transition.cupertino,
    ),   GetPage(
      name: myProperty,
      page: () => MarketPlotsScreen(),
      transition: Transition.cupertino,
    ), GetPage(
      name: myServiceList,
      page: () => MyServicesList(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: gioo,
      page: () => Giooplot(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: plotMarket,
      page: () => PlotMarket(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: register,
      page: () {
        final arguments = Get.arguments;
        final phone = arguments != null ? arguments['phone'] : null;
        return Registration(phone: phone);
      },
      transition: Transition.cupertino,
    ),
    GetPage(
      name: syndicateDetails,
      page: () {
        final arguments = Get.arguments;
        final id = arguments != null ? arguments['id'] : null;
        return SyndicateDetails(id: id);
      },
      transition: Transition.cupertino,
    ),
    GetPage(
      name: giooDetails,
      page: (){
        final arguments = Get.arguments;
        final id = arguments != null ? arguments['id'] : null;
        return GiooDetails(id: id);
      },
      transition: Transition.cupertino,
    ),
    GetPage(
      name: plotMarketDetails,
      page: () {
        final arguments = Get.arguments;
        final id = arguments != null ? arguments['id'] : null;
        return PlotMarketDetails(id: id);
      },
      transition: Transition.cupertino,
    ),
    GetPage(
      name: materialDetails,
      page: () {
        final arguments = Get.arguments;
        final id = arguments != null ? arguments['id'] : null;
        return MarketDetails(id: id);
      },
      transition: Transition.cupertino,
    ),


  ];
  static void toDashboard() => Get.offAllNamed(dashboard);
  static void toLogin() => Get.offAllNamed(login);
  static void toProfile() => Get.toNamed(profile);
  static void toHome() => Get.offAllNamed(home);
  static void toMyServiceList() => Get.offAllNamed(myServiceList);
  static void toMyMaterialList() => Get.offAllNamed(myMaterialList);
  static void togioo() => Get.offAllNamed(gioo);
  static void toMarketPlot() => Get.offAllNamed(plotMarket);
  static void toMyProperty() => Get.offAllNamed(myProperty);
  static void toMarketDetails() => Get.offAllNamed(materialDetails);
  static void toSyndicate() => Get.offAllNamed(syndicate);
  static void toRegister({String? phone}) {
    print("AppRoutes.toRegister called with phone: $phone");
    Get.toNamed(register, arguments: {'phone': phone});
  }
  static void back() => Get.back();
}