import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../common/route/router.dart';
import '../../Properties/widget/property_card.dart';
import '../controller/homecontroller.dart';

class FeaturesPlotProperties extends StatelessWidget {
  const FeaturesPlotProperties({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) {
        if (controller.isLoadingMarket.value) {
          return SizedBox(
            height: 230,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (controller.marketError.value.isNotEmpty) {
          return SizedBox(
            height: 230,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 40),
                  SizedBox(height: 10),
                  Text(
                    'Failed to load properties',
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: controller.refreshMarket,
                    child: Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (controller.featuredMarketProperties.isEmpty) {
          return SizedBox(
            height: 230,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.home_outlined, color: Colors.grey, size: 40),
                  SizedBox(height: 10),
                  Text(
                    'No properties available',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: [
            SizedBox(
              height: 230,
              child: NotificationListener<ScrollNotification>(
                onNotification: (scrollNotification) {
                  if (scrollNotification is ScrollEndNotification) {
                    final scrollController = scrollNotification.metrics;
                    if (scrollController.pixels >=
                        scrollController.maxScrollExtent - 100) {
                      if (controller.marketHasMore.value &&
                          !controller.isLoadingMoreMarket.value) {
                        controller.loadMoreFeaturedMarket();
                      }
                    }
                  }
                  return false;
                },
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  itemCount: controller.featuredMarketProperties.length +
                      (controller.marketHasMore.value ? 1 : 0),
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    if (index == controller.featuredMarketProperties.length) {
                      return SizedBox(
                        width: 170,
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    final property = controller.featuredMarketProperties[index];
                    return SizedBox(
                      width: 170,
                      child: PropertyCard(
                        soldStatus: property.soldStatus,
                        imageUrl: property.thumbnailImage,
                        title: property.name,
                        price: property.formattedPrice,
                        area: property.formattedArea,
                        location: property.address,
                        description: property.description,
                        onTap: () {
                          Get.toNamed(AppRoutes.plotMarketDetails, arguments: {"id": property.id});
                        },
                      )
                          .animate()
                          .slideX(
                        begin: 0.5,
                        end: 0,
                        duration: 600.ms,
                        curve: Curves.easeOutCubic,
                      )
                          .fadeIn(duration: 500.ms)
                          .scale(
                        begin: const Offset(0.9, 0.9),
                        end: const Offset(1, 1),
                        duration: 600.ms,
                        curve: Curves.easeOutBack,
                      )
                          .then(delay: (index * 200).ms)
                          .shimmer(
                        duration: 800.ms,
                        color: Colors.white.withOpacity(0.3),
                      ),
                    );
                  },
                ),
              ),
            ),
            if (controller.marketPagination.value != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (int i = 0; i < min(5, controller.marketTotalPages.value); i++)
                      Container(
                        width: 8,
                        height: 8,
                        margin: EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: controller.marketCurrentPage.value == i + 1
                              ? Colors.blue
                              : Colors.grey[300],
                        ),
                      ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}