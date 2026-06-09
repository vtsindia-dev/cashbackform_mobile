import 'package:cashback_farms/common/route/router.dart';
import 'package:cashback_farms/common/widget/carousel.dart';
import 'package:cashback_farms/features/home/widget/featured_gio_rental_yield_plots.dart';
import 'package:cashback_farms/features/home/widget/features_flats_villas_properties.dart';
import 'package:cashback_farms/features/menu/controller/dashboard_menu_controller.dart';
import 'package:cashback_farms/features/plot_market/controller/plot_market_controller.dart';
import 'package:cashback_farms/features/residential_plots/controller/residential_add_controller.dart';
import 'package:cashback_farms/features/residential_plots/view/add_residential.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../common/widget/loader.dart';
import '../../drawer/screen/drawer.dart';
import '../../plot_market/screens/add_plot.dart';
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
import 'package:cashback_farms/common/widget/service_material_banner_widget.dart' as service_material_banner_widget;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final HomeController controller = Get.put(HomeController());
  DashboardController dashboardController = Get.put(DashboardController());

  final PlotMarketController plotMarketController = Get.put(PlotMarketController());
  final ResidentialPropertyFormController residentialPropertyFormController = Get.put(ResidentialPropertyFormController());

  void _launchURL(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar('Error', 'Cannot open link',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 2));
      }
    } catch (e) {
      Get.snackbar('Error', 'Invalid URL',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2));
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
                        .map((b) => b.image)
                        .where((i) => i.isNotEmpty)
                        .toList()
                        : [];
                    final List<String> redirectUrls = banners.isNotEmpty
                        ? banners
                        .map((b) => b.redirectUrl)
                        .where((u) => u != null && u.isNotEmpty)
                        .cast<String>()
                        .toList()
                        : [];
                    return CarouselWidget(
                      images: images,
                      redirectUrls:
                      redirectUrls.isNotEmpty ? redirectUrls : null,
                      height: 160,
                      autoPlayDuration: const Duration(seconds: 3),
                      borderRadius: 15,
                      onTap: (url) {
                        if (url.isNotEmpty) {
                          if (url.contains('residential-property')) {
                          } else if (url.contains('plot-marketplace')) {
                          } else if (url.contains('syndicate-plots')) {
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
                  // _buildAddMyPropertySection(),
                  // const SizedBox(height: 20),
                  Column(
                    children: [
                      SubtitleWidget(
                        title: "Featured Land Properties",
                        highlightWord: "Land",
                        onViewAllTap: () => Get.toNamed('/plotMarket'),
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
                        onViewAllTap: () =>
                            Get.toNamed(AppRoutes.rentalYieldList),
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
                        onViewAllTap: () => Get.toNamed('/gioo'),
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
                        onViewAllTap: () => Get.toNamed('/syndicate'),
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
                        onViewAllTap: () => Get.toNamed('/service'),
                      ),
                      const SizedBox(height: 10),
                      TopProfessionalService(),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Obx(() {
                    final profile = dashboardController.profile.value;
                    final bool isService = profile?.isServices == 1;
                    if (!isService) return const SizedBox.shrink();

                    final banners = controller.serviceMaterialBanners;
                    final hasService = banners.any((b) => b.isService);
                    if (!hasService) return const SizedBox.shrink();
                    return Column(
                      children: [
                        SubtitleWidget(
                          showViewAll: false,
                          title: "Our Services",
                          highlightWord: "Services",
                        ),
                        const SizedBox(height: 10),
                        service_material_banner_widget.ServiceBanner(banners: banners),
                        const SizedBox(height: 20),
                      ],
                    );
                  }),

                  Column(
                    children: [
                      SubtitleWidget(
                        title: "Our BestSelling Products & Materials",
                        highlightWord: "BestSelling",
                        onViewAllTap: () => Get.toNamed('/materialStore'),
                      ),
                      const SizedBox(height: 10),
                      MaterialCategory(),
                    ],
                  ),
                  Obx(() {
                    final profile = dashboardController.profile.value;
                    final bool isVendor = profile?.isVendor == 1;
                    if (!isVendor) return const SizedBox.shrink();
                    final banners = controller.serviceMaterialBanners;
                    final hasMaterial = banners.any((b) => b.isMaterial);
                    if (!hasMaterial) return const SizedBox.shrink();

                    return Column(
                      children: [
                        const SizedBox(height: 10),
                        SubtitleWidget(
                          showViewAll: false,
                          title: "Our Materials",
                          highlightWord: "Materials",
                        ),
                        const SizedBox(height: 10),
                        service_material_banner_widget.MaterialBanner(banners: banners),
                        const SizedBox(height: 20),
                      ],
                    );
                  }),
                  const SizedBox(height: 15),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildAddMyPropertySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: const Color(0xff92AF5D),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              "List Your Property",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Padding(
          padding: EdgeInsets.only(left: 12),
          child: Text(
            "Reach thousands of buyers & investors",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildAddCard(
                icon: Icons.terrain_rounded,
                title: "Add My Land",
                subtitle: "Plot / Agricultural",
                gradientColors: [
                  const Color(0xff92AF5D),
                  const Color(0xffC7DD94),
                ],
                onTap: () => Get.to(() => MarketPlotForm()),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildAddCard(
                icon: Icons.apartment_rounded,
                title: "Add My Flat/Villas",
                subtitle: "Residential Property",
                gradientColors: [
                  const Color(0xFF06B6D4),
                  const Color(0xFF67E8F9),
                ],
                onTap: () => Get.to(() => const AddEditPropertyScreen()),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAddCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradientColors[0].withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.85),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, size: 13, color: gradientColors[0]),
                      const SizedBox(width: 3),
                      Text(
                        "Add Now",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: gradientColors[0],
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}