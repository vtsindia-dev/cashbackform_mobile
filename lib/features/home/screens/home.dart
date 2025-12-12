import 'package:cashback_farms/common/widget/carousel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/widget/loader.dart';
import '../../Properties/widget/property_card.dart';
import '../../drawer/screen/drawer.dart';
import '../../service/widget/service_card.dart';
import '../controller/homecontroller.dart';
import '../widget/featured_product.dart';
import '../widget/featured_syndicate_plot.dart';
import '../widget/features_plot_properties.dart';
import '../widget/home_appbar.dart';
import '../widget/main_property.dart';
import '../widget/material_category.dart';
import '../widget/searchbar.dart';
import '../widget/sub_title.dart';
import '../widget/top_professional_service.dart';

class Home extends StatefulWidget {
  Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  final HomeController controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      drawer: const CustomDrawer(),
      appBar: HomeAppBar(controller: controller, scaffoldKey: scaffoldKey),
      body: Obx(() {
        if (controller.isLoadingLocation.value || controller.isLoadingFeaturedData.value) {
          return const Center(child: GifLoader(message: "Loading...", size: 100));
        }

        return RefreshIndicator(
          onRefresh: () async {
            await controller.refreshAllData();
          },
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Home_SearchBar(),
                  const SizedBox(height: 20),

                  // Banners Carousel
                  Obx(() {
                    return CarouselWidget(
                      images: controller.featuredBanners.isNotEmpty
                          ? controller.featuredBanners
                          .map((banner) => banner.image)
                          .where((image) => image.isNotEmpty)
                          .toList()
                          : [
                        'assets/images/banner1.png',
                        'assets/images/banner2.png',
                      ],
                      height: 130,
                      autoPlayDuration: Duration(seconds: 3),
                      borderRadius: 20,
                    );
                  }),

                  const SizedBox(height: 10),
                  PropertyMain(),
                  const SizedBox(height: 20),

                  // Market Properties Section
                  Column(
                    children: [
                      SubtitleWidget(
                        title: "Features Plot Market",
                        highlightWord: "Plot",
                        onViewAllTap: () {
                          print("View All clicked");
                        },
                      ),
                      const SizedBox(height: 10),
                      FeaturesPlotProperties(),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Services Section
                  Column(
                    children: [
                      SubtitleWidget(
                        title: "Top Professional Services",
                        highlightWord: "Professional",
                        onViewAllTap: () {
                          print("View All clicked");
                        },
                      ),
                      const SizedBox(height: 10),
                      TopProfessionalService(),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // GIOO Plots Section
                  Column(
                    children: [
                      SubtitleWidget(
                        title: "Features GIOO Plot",
                        highlightWord: "GIOO",
                        onViewAllTap: () {
                          print("View All clicked");
                        },
                      ),
                      const SizedBox(height: 10),
                      FeaturesGiooPlots(),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Syndicate Properties Section
                  Column(
                    children: [
                      SubtitleWidget(
                        title: "Features Syndicate Plot ",
                        highlightWord: "Syndicate",
                        onViewAllTap: () {
                          print("View All clicked");
                        },
                      ),
                      const SizedBox(height: 10),
                      FeaturesSyndicateProperties(),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Materials Section
                  Column(
                    children: [
                      SubtitleWidget(
                        title: "Material Store",
                        highlightWord: "Material",
                        onViewAllTap: () {
                          print("View All clicked");
                        },
                      ),
                      const SizedBox(height: 10),
                      MaterialCategory(),
                    ],
                  ),

                  const SizedBox(height: 15),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}