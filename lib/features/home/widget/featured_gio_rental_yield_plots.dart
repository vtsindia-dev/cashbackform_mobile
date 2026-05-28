import 'dart:math';

import 'package:cashback_farms/common/route/router.dart';
import 'package:cashback_farms/features/home/controller/homecontroller.dart';
import 'package:cashback_farms/features/product/widget/product_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class FeaturedGioRentalYieldPlots extends StatelessWidget {
  const FeaturedGioRentalYieldPlots({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) {
        if (controller.isLoadingRental &&
            controller.rentalList.isEmpty) {
          return const SizedBox(
            height: 250,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (controller.rentalError.isNotEmpty) {
          return SizedBox(
            height: 250,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      color: Colors.red, size: 40),
                  const SizedBox(height: 8),
                  Text(controller.rentalError,
                      style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: controller.fetchFeaturedRental,
                    child: const Text("Retry"),
                  ),
                ],
              ),
            ),
          );
        }
        if (controller.rentalList.isEmpty) {
          return const SizedBox(
            height: 250,
            child: Center(child: Text("No Rental Plots Available")),
          );
        }

        return Column(
          children: [
            SizedBox(
              height: 252,
              child: NotificationListener<ScrollNotification>(
                onNotification: (scrollNotification) {

                  if (scrollNotification.metrics.pixels >=
                      scrollNotification.metrics.maxScrollExtent - 80 &&
                      !controller.isLoadingMoreRental &&
                      controller.rentalHasMore) {

                    controller.loadMoreRentalPlots();
                  }

                  return false;
                },
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.rentalList.length +
                      (controller.rentalHasMore ? 1 : 0),
                  separatorBuilder: (_, __) =>
                  const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    if (index == controller.rentalList.length) {
                      return const SizedBox(
                        width: 160,
                        child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    }

                    final item = controller.rentalList[index];

                    return SizedBox(
                      width: 170,
                      child: ProductCard(
                        soldStatus: item.soldStatus,
                        rentalAmount: item.totalPrice?? "N/A",
                        yieldAmount:'${item.pricePerSqft?? 'N/A'} sq.ft',
                        imageUrl: item.files?.first??'',
                        title: item.name,
                        price: item.formattedPrice,
                        location: item.location,
                        description: item.description.isNotEmpty
                            ? item.description
                            : 'Gio Rental Yield Plot',
                        onTap: () {
                          Get.toNamed(AppRoutes.rentalDetails, arguments: {'id': item.id, 'title': item.name,},);
                        },
                        isFavourite: true,
                      ),
                    );
                  },
                ),
              ),
            ),
            if (controller.rentalTotalPages > 1)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    min(5, controller.rentalTotalPages),
                        (index) => Container(
                      width: 7,
                      height: 7,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: controller.rentalCurrentPage == index + 1
                            ? Colors.blue
                            : Colors.grey.shade300,
                      ),
                    ),
                  ),
                ),
              ),

            if (controller.rentalTotalPages > 5)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '${controller.rentalCurrentPage}/${controller.rentalTotalPages}',
                  style: const TextStyle(
                      fontSize: 12, color: Colors.grey),
                ),
              ),
          ],
        );
      },
    );
  }
}