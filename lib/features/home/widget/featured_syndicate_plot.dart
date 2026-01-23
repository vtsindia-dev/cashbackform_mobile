import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../product/widget/product_card.dart';
import '../controller/homecontroller.dart';

class FeaturesSyndicateProperties extends StatelessWidget {
  const FeaturesSyndicateProperties({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) {
        // Show loading state
        if (controller.isLoadingSyndicates.value && controller.featuredSyndicates.isEmpty) {
          return SizedBox(
            height: 242,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Show error state
        if (controller.syndicateError.value.isNotEmpty) {
          return SizedBox(
            height: 242,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 40),
                  SizedBox(height: 10),
                  Text(
                    'Failed to load syndicates',
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: controller.refreshSyndicates,
                    child: Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        // Show empty state
        if (controller.featuredSyndicates.isEmpty) {
          return SizedBox(
            height: 242,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.business_outlined, color: Colors.grey, size: 40),
                  SizedBox(height: 10),
                  Text(
                    'No syndicates available',
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

                      if (controller.syndicateHasMore.value &&
                          !controller.isLoadingMoreSyndicates.value) {
                        controller.loadMoreFeaturedSyndicates();
                      }
                    }
                  }
                  return false;
                },
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  itemCount: controller.featuredSyndicates.length +
                      (controller.syndicateHasMore.value ? 1 : 0),
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    // Load more indicator
                    if (index == controller.featuredSyndicates.length) {
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

                    final syndicate = controller.featuredSyndicates[index];

                    return SizedBox(
                      width: 170,
                      child: ProductCard(
                        imageUrl: syndicate.thumbnailImage,
                        title: syndicate.name,
                        price: syndicate.formattedPrice,
                        location: syndicate.location,
                        description: syndicate.description.isNotEmpty
                            ? syndicate.description
                            : 'Premium Syndicate Property',
                        onTap: () {
                          print("View: ${syndicate.name}");
                          Get.toNamed('/syndicateDetails', arguments: {"id": syndicate.id,"title": syndicate.name});

                        },
                        isFavourite: true,
                        onFavToggle: () {
                          print("Fav Toggled for: ${syndicate.name}");
                          // Add to favorites logic here
                        },
                        onAddToCart: () {
                          print("Add to Cart: ${syndicate.name}");
                          // Add to cart logic here
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

            // Pagination indicators (optional)
            if (controller.syndicatePagination.value != null && controller.syndicateTotalPages.value > 1)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (int i = 0; i < min(5, controller.syndicateTotalPages.value); i++)
                      Container(
                        width: 8,
                        height: 8,
                        margin: EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: controller.syndicateCurrentPage.value == i + 1
                              ? Colors.blue
                              : Colors.grey[300],
                        ),
                      ),
                    if (controller.syndicateTotalPages.value > 5)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          '${controller.syndicateCurrentPage.value}/${controller.syndicateTotalPages.value}',
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