import 'package:cashback_farms/common/widget/carousel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/widget/loader.dart';
import '../../Properties/widget/property_card.dart';
import '../../drawer/screen/drawer.dart';
import '../../service/widget/service_card.dart';
import '../controller/homecontroller.dart';
import '../widget/featured_product.dart';
import '../widget/features_plot_properties.dart';
import '../widget/home_appbar.dart';
import '../widget/searchbar.dart';
import '../widget/sub_title.dart';
import '../widget/top_professional_service.dart';

class Home extends StatelessWidget {
  Home({super.key});
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      init: HomeController(),
      builder: (controller) {
        return Scaffold(
          key: scaffoldKey,
          drawer: const CustomDrawer(),
          appBar: HomeAppBar(controller: controller, scaffoldKey: scaffoldKey),
          body: controller.isLoading
              ? const Center(child: GifLoader(message: "Loading...", size: 100))
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child:
                    Column(
                        children: [
                          Home_SearchBar(),
                          const SizedBox(height: 20),
                          CarouselWidget(
                            images: [
                              "https://picsum.photos/600/300",
                              "https://picsum.photos/600/301",
                              "https://picsum.photos/600/302",
                            ],
                            height: 130,
                            autoPlayDuration: Duration(seconds: 3),
                            borderRadius: 20,
                          ),
                          const SizedBox(height: 20),
                          SubtitleWidget( title: "Features Plot Properties", highlightWord: "Plot", onViewAllTap: () {print("View All clicked");},),
                          const SizedBox(height: 10),
                          FeaturesPlotProperties(),
                          const SizedBox(height: 20),
                          SubtitleWidget( title: "Top Professional Services", highlightWord: "Professional", onViewAllTap: () {print("View All clicked");},),
                          const SizedBox(height: 10),
                          TopProfessionalService(),
                          const SizedBox(height: 20),
                          SubtitleWidget( title: "Features GIOO Plot Properties", highlightWord: "GIOO", onViewAllTap: () {print("View All clicked");},),
                          const SizedBox(height: 10),
                          FeaturesProduct(),
                          const SizedBox(height: 1000),










                        ]),
                  ),
                ),
        );
      },
    );
  }
}
