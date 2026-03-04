import 'package:cashback_farms/features/auth/screens/registration.dart';
import 'package:cashback_farms/features/gioo_plots/screens/gioo_details.dart';
import 'package:cashback_farms/features/gioo_plots/screens/gioo_plot.dart';
import 'package:cashback_farms/features/material_store/screens/material_store.dart';
import 'package:cashback_farms/features/material_store/screens/my_enquiry_list.dart';
import 'package:cashback_farms/features/syndicate_plot/screens/syndicate_details.dart';
import 'package:get/get.dart';

import '../../features/auth/screens/login.dart';
import '../../features/dashboard/screens/dashboard.dart';
import '../../features/gioo_plots/screens/owned_plots.dart';
import '../../features/home/screens/home.dart';
import '../../features/material_store/screens/materialstore_details.dart';
import '../../features/material_store/screens/vendor_list.dart';
import '../../features/menu/content_screens/contactus.dart';
import '../../features/plot_market/screens/myplot_list.dart' hide MyPlotsScreen;
import '../../features/plot_market/screens/myplotmarket_enqiry.dart';
import '../../features/plot_market/screens/plot_market.dart';
import '../../features/plot_market/screens/plotmarket_details.dart';
import '../../features/profile/screen/profile.dart';
import '../../features/rental_yeild/view/rental_yeild_details.dart';
import '../../features/rental_yeild/view/rental_yield_plots.dart';
import '../../features/rental_yeild/view/rentalyeild_enquiry.dart';
import '../../features/residential_plots/view/add_residential.dart';
import '../../features/residential_plots/view/my_enquiry.dart';
import '../../features/residential_plots/view/my_residential_plots.dart';
import '../../features/residential_plots/view/residential_details.dart';
import '../../features/residential_plots/view/residential_plots.dart';
import '../../features/service/screen/my_service_enquiry.dart';
import '../../features/service/screen/service.dart';
import '../../features/splash/screens/splash.dart';
import '../../features/syndicate_plot/screens/owned_syndicate_plot.dart';
import '../../features/syndicate_plot/screens/syndicate_plot.dart';
import '../../features/transaction/screen/transaction.dart';

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
  static const String residentialList = '/residentialList';
  static const String residentialDetails = '/residentialDetails';
  static const String gioo = '/gioo';
  static const String plotMarket = '/plotMarket';
  static const String syndicateDetails = '/syndicateDetails';
  static const String giooDetails = '/giooDetails';
  static const String plotMarketDetails = '/plotMarketDetails';
  static const String vendorDetailScreen = '/VendorDetailScreen';
  static const String myProperty = '/myProperty';
  static const String myServiceList = '/myServiceList';
  static const String myMaterialList = '/myMaterialList';
  static const String ownedplotlist = '/ownedplotlist';
  static const String ownedSyndicatePlotList = '/ownedSyndicatePlotList';
  static const String addResidential = '/addResidential';
  static const String myResidential = '/myResidential';
  static const String myResidentialEnquiry = '/myResidentialEnquiry';
  static const String rentalYieldList = '/rentalYieldList';
  static const String contactus = '/contactus';
  static const String rentalDetails = '/rentalDetails';
  static const String rentalEnquiry = '/rentalEnquiry';
  static const String plotMarketEnquiry = '/plotMarketEnquiry';
  static const String transactionDeatils = '/transactionDeatils';
  static const String vendorList = '/VendorListScreen';
  static List<GetPage> routes = [
    GetPage(
      name: splash,
      page: () => SplashScreen(),
      transition: Transition.fade,
    ),
    GetPage(
      name: myResidentialEnquiry,
      page: () => PlotEnquiryScreen(),
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
    ),
    GetPage(
      name: ownedplotlist,
      page: () => GiooBuyingListWidget(),
      transition: Transition.cupertino,
    ), GetPage(
      name: ownedSyndicatePlotList,
      page: () => SyndicateBuyingListWidget(),
      transition: Transition.cupertino,
    ), GetPage(
      name: service,
      page: () => Service(),
      transition: Transition.cupertino,
    ),

    GetPage(
      name: transactionDeatils,
      page: () => TransactionScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: syndicate,
      page: () => SyndicatePlot(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: rentalEnquiry,
      page: () => RentalEnquiryScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: plotMarketEnquiry,
      page: () => MarketPlotEnquiryScreen(),
      transition: Transition.cupertino,
    ),   GetPage(
      name: plotMarketEnquiry,
      page: () => MarketPlotEnquiryScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: residentialList,
      page: () => ResidentialPropertiesScreen(),
      transition: Transition.cupertino,
    ),  GetPage(
      name: myResidential,
      page: () => MyPlotsScreen(),
      transition: Transition.cupertino,
    ),   GetPage(
      name: myProperty,
      page: () => MyPlotsMArkScreen(),
      transition: Transition.cupertino,
    ), GetPage(
      name: myServiceList,
      page: () => MyServicesList(),
      transition: Transition.cupertino,
    ), GetPage(
      name: rentalYieldList,
      page: () => RentalYieldScreen(),
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
        final title = arguments != null ? arguments['title'] : null;
        return SyndicateDetails(id: id ,title: title,);
      },
      transition: Transition.cupertino,
    ),
    GetPage(
      name: vendorList,
      page: () {
        final arguments = Get.arguments;
        final id = arguments != null ? arguments['materialId'] : null;
        final title = arguments != null ? arguments['materialName'] : null;
        return VendorListScreen(materialId: id, materialName:title);
      },
      transition: Transition.cupertino,
    ),
    GetPage(
      name: addResidential,
      page: () {
        final arguments = Get.arguments;
        final id = arguments != null ? arguments['id'] : null;
        return AddEditPropertyScreen(propertyId: id);
      },
      transition: Transition.cupertino,
    ),
    GetPage(
      name: giooDetails,
      page: (){
        final arguments = Get.arguments;
        final id = arguments != null ? arguments['id'] : null;
        final title = arguments != null ? arguments['title'] : null;

        return GiooDetails(id: id,title: title,);
      },
      transition: Transition.cupertino,
    ),
    GetPage(
      name: rentalDetails,
      page: () {
        final arguments = Get.arguments;
        final id = arguments != null ? arguments['id'] : null;
        final title = arguments != null ? arguments['title'] : null;

        return RentalPropertyDetailsScreen(
          id: id,
          title: title,
        );
      },
      transition: Transition.cupertino,
    ),
    GetPage(
      name: residentialDetails,
      page: (){
        final arguments = Get.arguments;
        final id = arguments != null ? arguments['id'] : null;
        final title = arguments != null ? arguments['title'] : null;

        return ResidentialPlotDetailsScreen(propertyId: id,propertyTitle: title,);
      },
      transition: Transition.cupertino,
    ),
    GetPage(
      name: plotMarketDetails,
      page: () {
        final arguments = Get.arguments;
        final id = arguments != null ? arguments['id'] : null;
        final title = arguments != null ? arguments['title'] : null;
        return PlotMarketDetails(id: id , title: title);
      },
      transition: Transition.cupertino,
    ),
    GetPage(
      name: vendorDetailScreen,
      page: () {
        final arguments = Get.arguments;
        final id = arguments != null ? arguments['vendorId'] : null;
        final title = arguments != null ? arguments['vendorName'] : null;
        return VendorDetailScreen(vendorId: id, vendorName: title,);
      },
      transition: Transition.cupertino,
    ),
    GetPage(
      name: contactus,
      page: () => ContactUsScreen(),
      transition: Transition.cupertino,
    ),


  ];
  static void toDashboard() => Get.offAllNamed(dashboard);
  static void toOwnedGioPlotList() => Get.offAllNamed(ownedplotlist);
  static void toOwnedSyndicatePlotList() => Get.offAllNamed(ownedSyndicatePlotList);
  static void toLogin() => Get.offAllNamed(login);
  static void toResidentialList() => Get.offAllNamed(residentialList);
  static void toResidentialDetails() => Get.offAllNamed(residentialDetails);
  static void toProfile() => Get.toNamed(profile);
  static void toHome() => Get.offAllNamed(home);
  static void toMyServiceList() => Get.offAllNamed(myServiceList);
  static void addResidentialPlot() => Get.offAllNamed(addResidential);
  static void toMyMaterialList() => Get.offAllNamed(myMaterialList);
  static void toMyResidenialEnquiry() => Get.offAllNamed(myResidentialEnquiry);
  static void togioo() => Get.offAllNamed(gioo);
  static void toResidential() => Get.offAllNamed(myResidential);
  static void toMarketPlot() => Get.offAllNamed(plotMarket);
  static void toMyProperty() => Get.offAllNamed(myProperty);
  static void toMarketDetails() => Get.offAllNamed(vendorDetailScreen);
  static void toSyndicate() => Get.offAllNamed(syndicate);
  static void toRentalYield() => Get.offAllNamed(rentalYieldList);
  static void toRentalYieldDetails() => Get.offAllNamed(rentalDetails);
  static void toContactUs() => Get.offAllNamed(contactus);
  static void toTransactionDetails() => Get.offAllNamed(transactionDeatils);
  static void toRentalEnquiry() => Get.offAllNamed(rentalEnquiry);
  static void toPlotMarketEnquiry() => Get.offAllNamed(plotMarketEnquiry);
  static void toRegister({String? phone}) {
    print("AppRoutes.toRegister called with phone: $phone");
    Get.toNamed(register, arguments: {'phone': phone});
  }
  static void back() => Get.back();
}