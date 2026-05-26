import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../Properties/widget/property_card.dart';
import '../../product/widget/product_card.dart';
import '../controller/homecontroller.dart';

class FeaturesGiooPlots extends StatelessWidget {
  const FeaturesGiooPlots({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) {
        // Show loading state
        if (controller.isLoadingGioo.value && controller.featuredGiooPlots.isEmpty) {
          return SizedBox(
            height: 242,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Show error state
        if (controller.giooError.value.isNotEmpty) {
          return SizedBox(
            height: 242,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 40),
                  SizedBox(height: 10),
                  Text(
                    'Failed to load GIOO plots',
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: controller.refreshGioo,
                    child: Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        // Show empty state
        if (controller.featuredGiooPlots.isEmpty) {
          return SizedBox(
            height: 242,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.home_outlined, color: Colors.grey, size: 40),
                  SizedBox(height: 10),
                  Text(
                    'No GIOO plots available',
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
              height: 242,
              child: NotificationListener<ScrollNotification>(
                onNotification: (scrollNotification) {
                  if (scrollNotification is ScrollEndNotification) {
                    final scrollController = scrollNotification.metrics;
                    if (scrollController.pixels >=
                        scrollController.maxScrollExtent - 100) {
                      if (controller.giooHasMore.value &&
                          !controller.isLoadingMoreGioo.value) {
                        controller.loadMoreFeaturedGioo();
                      }
                    }
                  }
                  return false;
                },
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  itemCount: controller.featuredGiooPlots.length +
                      (controller.giooHasMore.value ? 1 : 0),
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    // Load more indicator
                    if (index == controller.featuredGiooPlots.length) {
                      return SizedBox(
                        width: 170,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      );
                    }

                    final plot = controller.featuredGiooPlots[index];

                    return SizedBox(
                      width: 170,
                      child: ProductCard(
                         soldStatus: plot.soldStatus,
                        imageUrl: plot.thumbnailImage,
                        title: plot.name,
                        price: plot.formattedPrice,
                        location: plot.location,
                        description: plot.description.isNotEmpty
                            ? plot.description
                            : 'Premium GIOO Plot',
                        onTap: () {
                          Get.toNamed('/giooDetails', arguments: {"id": plot.id, "title": plot.name});
                        },
                        isFavourite: true,
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

            // Pagination indicators (optional)
            if (controller.giooPagination.value != null && controller.giooTotalPages.value > 1)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (int i = 0; i < min(5, controller.giooTotalPages.value); i++)
                      Container(
                        width: 8,
                        height: 8,
                        margin: EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: controller.giooCurrentPage.value == i + 1
                              ? Colors.blue
                              : Colors.grey[300],
                        ),
                      ),
                    if (controller.giooTotalPages.value > 5)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          '${controller.giooCurrentPage.value}/${controller.giooTotalPages.value}',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
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