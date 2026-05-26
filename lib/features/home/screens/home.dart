import 'package:cashback_farms/common/route/router.dart';
import 'package:cashback_farms/common/widget/carousel.dart';
import 'package:cashback_farms/features/home/widget/featured_gio_rental_yield_plots.dart';
import 'package:cashback_farms/features/home/widget/features_flats_villas_properties.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../common/widget/loader.dart';
import '../../drawer/screen/drawer.dart';
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
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  final HomeController controller = Get.put(HomeController());

  void _launchURL(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar(
          'Error',
          'Cannot open link',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Invalid URL',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      drawer: const CustomDrawer(),
      appBar: HomeAppBar(controller: controller, scaffoldKey: scaffoldKey),
      body: Obx(() {
        if (controller.isLoadingLocation.value ||
            controller.isLoadingFeaturedData.value) {
          return const Center(
            child: GifLoader(message: "Loading...", size: 100),
          );
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
                  HomeSearchBar(),
                  const SizedBox(height: 20),
                  Obx(() {
                    final banners = controller.featuredBanners;
                    final List<String> images = banners.isNotEmpty
                        ? banners
                              .map((banner) => banner.image)
                              .where((image) => image.isNotEmpty)
                              .toList()
                        : [];
                    final List<String> redirectUrls = banners.isNotEmpty
                        ? banners
                              .map((banner) => banner.redirectUrl)
                              .where((url) => url != null && url.isNotEmpty)
                              .cast<String>()
                              .toList()
                        : [];
                    return CarouselWidget(
                      images: images,
                      redirectUrls: redirectUrls.isNotEmpty
                          ? redirectUrls
                          : null,
                      height: 160,
                      autoPlayDuration: const Duration(seconds: 3),
                      borderRadius: 15,
                      onTap: (url) {
                        if (url.isNotEmpty) {
                          if (url.contains('residential-property')) {
                            // Get.toNamed(AppRoutes.residentialDetails);
                          } else if (url.contains('plot-marketplace')) {
                            // Get.toNamed(AppRoutes.plotMarket);
                          } else if (url.contains('syndicate-plots')) {
                            // Get.toNamed(AppRoutes.syndicateDetails);
                          } else {
                            _launchURL(url);
                          }
                        }
                      },
                    );
                  }),
                  const SizedBox(height: 10),
                  PropertyMain(),
                  const SizedBox(height: 20),
                  Column(
                    children: [
                      SubtitleWidget(
                        title: "Featured Land Properties",
                        highlightWord: "Land",
                        onViewAllTap: () {
                          Get.toNamed('/plotMarket');
                        },
                      ),
                      const SizedBox(height: 10),
                      FeaturesPlotProperties(),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Column(
                    children: [
                      SubtitleWidget(
                        title: "Featured Flats / Villas Properties",
                        highlightWord: "Flats / Villas",
                        onViewAllTap: () =>
                            Get.toNamed(AppRoutes.residentialList),
                      ),
                      const SizedBox(height: 10),
                      FeaturedFlatsVillasProperties(),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Column(
                    children: [
                      SubtitleWidget(
                        title: "Featured Gio Rental Yield Plots",
                        highlightWord: "Gio Rental Yield",
                        onViewAllTap: () {
                          Get.toNamed(AppRoutes.rentalYieldList);
                        },
                      ),
                      const SizedBox(height: 10),
                      const FeaturedGioRentalYieldPlots(),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Column(
                    children: [
                      SubtitleWidget(
                        title: "Featured GIOO Nano Plots Properties",
                        highlightWord: "GIOO",
                        onViewAllTap: () {
                          Get.toNamed('/gioo');
                        },
                      ),
                      const SizedBox(height: 10),
                      FeaturesGiooPlots(),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Column(
                    children: [
                      SubtitleWidget(
                        title:
                            "Featured Gio Rental Yield – Syndicate Plots Properties",
                        highlightWord: "Gio Rental Yield – Syndicate",
                        onViewAllTap: () {
                          Get.toNamed('/syndicate');
                        },
                      ),
                      const SizedBox(height: 10),
                      FeaturesSyndicateProperties(),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Column(
                    children: [
                      SubtitleWidget(
                        title: "Top Professional Services",
                        highlightWord: "Professional",
                        onViewAllTap: () {
                          Get.toNamed('/service');
                        },
                      ),
                      const SizedBox(height: 10),
                      TopProfessionalService(),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Column(
                    children: [
                      SubtitleWidget(
                        title: "Our BestSelling Products & Materials",
                        highlightWord: "BestSelling",
                        onViewAllTap: () {
                          Get.toNamed('/materialStore');
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
