import 'dart:math';
import 'package:cashback_farms/features/home/controller/homecontroller.dart';
import 'package:cashback_farms/features/product/widget/product_card.dart';
import 'package:cashback_farms/features/residential_plots/controller/residential_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

class FeaturedFlatsVillasProperties extends StatelessWidget {
  const FeaturedFlatsVillasProperties({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return GetBuilder<ResidentialPropertyController>(
      init: ResidentialPropertyController(),
      builder: (residentialPropertyController) {
        return Obx(() {
          if (controller.isLoadingPlots.value &&
              controller.featuredPlots.isEmpty) {
            return const SizedBox(
              height: 242,
              child: Center(child: CircularProgressIndicator()),
            );
          }
          if (controller.plotError.value.isNotEmpty &&
              controller.featuredPlots.isEmpty) {
            return SizedBox(
              height: 242,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 40,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      controller.plotError.value,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        controller.fetchFeaturedPlots();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
          if (controller.featuredPlots.isEmpty) {
            return const SizedBox(
              height: 242,
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
                height: 242,
                child: NotificationListener<ScrollNotification>(
                  onNotification: (scrollNotification) {
                    if (scrollNotification.metrics.pixels >=
                            scrollNotification.metrics.maxScrollExtent - 100 &&
                        controller.plotHasMore.value &&
                        !controller.isLoadingMorePlots.value) {
                      controller.fetchFeaturedPlots(loadMore: true);
                    }

                    return false;
                  },
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.zero,
                    itemCount:
                        controller.featuredPlots.length +
                        (controller.plotHasMore.value ? 1 : 0),
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      if (index == controller.featuredPlots.length) {
                        return const SizedBox(
                          width: 170,
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        );
                      }
                      final plot = controller.featuredPlots[index];
                      final imageUrl =
                          (plot.galleryImages != null &&
                              plot.galleryImages!.isNotEmpty)
                          ? plot.galleryImages!.first
                          : (plot.thumbnail ?? '');

                      final title = plot.propertyName ?? '';
                      final location = plot.location ?? '';
                      final description =
                          (plot.aboutProperty != null &&
                              plot.aboutProperty!.trim().isNotEmpty)
                          ? plot.aboutProperty!
                          : 'Premium Property';

                      return SizedBox(
                        width: 170,
                        child:
                            ProductCard(
                                  imageUrl: imageUrl,
                                  soldStatus: plot.soldStatus,
                                  title: title,
                                  price: plot.price ?? '₹0',
                                  location: location,
                                  description: description,
                                  onTap: () {
                                    Get.toNamed(
                                      'residentialDetails',
                                      arguments: {
                                        "id": plot.id,
                                        "title": plot.propertyName,
                                      },
                                    );
                                  },
                                  isFavourite: false,
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

              if (controller.plotTotalPages.value > 1)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (
                        int i = 0;
                        i < min(5, controller.plotTotalPages.value);
                        i++
                      )
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: controller.plotCurrentPage.value == i + 1
                                ? Colors.green
                                : Colors.grey[300],
                          ),
                        ),

                      if (controller.plotTotalPages.value > 5)
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text(
                            '${controller.plotCurrentPage.value}/${controller.plotTotalPages.value}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          );
        });
      },
    );
  }
}
