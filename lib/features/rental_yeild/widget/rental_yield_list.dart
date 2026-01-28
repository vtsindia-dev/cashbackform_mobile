import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../Properties/widget/property_card.dart';
import '../controller/rental_yield_controller.dart';
import '../model/rental_yeild_model.dart';

class RentalYieldList extends StatelessWidget {
  const RentalYieldList({super.key});

  @override
  Widget build(BuildContext context) {
    final RentalYieldController controller = Get.find();

    return Obx(() {
      final properties = controller.filteredProperties.isNotEmpty
          ? controller.filteredProperties
          : controller.properties;

      if (controller.isLoading.value && properties.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (properties.isEmpty) {
        return Center(
          child: Text(
            'No rental properties found',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey[600],
            ),
          ),
        );
      }

      final rowCount = (properties.length / 2).ceil();

      return NotificationListener<ScrollNotification>(
        onNotification: (scroll) {
          if (!controller.hasMore.value) return false;

          if (scroll.metrics.pixels >= scroll.metrics.maxScrollExtent * 0.9) {
            controller.loadMore();
          }
          return false;
        },
        child: ListView.builder(
          padding: EdgeInsets.all(16.r),
          itemCount: rowCount + 1,
          itemBuilder: (context, index) {
            if (index == rowCount) {
              return controller.isLoading.value && controller.hasMore.value
                  ? Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h),
                child: Center(child: CircularProgressIndicator()),
              )
                  : SizedBox.shrink();
            }

            final leftIndex = index * 2;
            final rightIndex = leftIndex + 1;

            final leftProperty = properties[leftIndex];
            final rightProperty = rightIndex < properties.length ? properties[rightIndex] : null;

            return Row(
              children: [
                Expanded(child: _buildPropertyCard(leftProperty)),
                SizedBox(width: 12.w),
                Expanded(
                  child: rightProperty != null
                      ? _buildPropertyCard(rightProperty)
                      : const SizedBox.shrink(),
                ),
              ],
            );
          },
        ),
      );
    });
  }

  Widget _buildPropertyCard(RentalYieldModel property) {
    // Create a yield badge widget
    final yieldBadge = Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: _getYieldColor(property.annualYield),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${property.annualYield.toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 4.w),
          Icon(
            Icons.trending_up,
            size: 12.r,
            color: Colors.white,
          ),
        ],
      ),
    );

    // Create rent information
    final rentInfo = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Monthly Rent',
          style: TextStyle(
            fontSize: 10.sp,
            color: Colors.grey[600],
          ),
        ),
        Text(
          '₹${property.monthlyRent.toStringAsFixed(1)}K',
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w900,
            color: Colors.green[700],
          ),
        ),
      ],
    );

    // Modify the description to include rental info
    final description = '${property.bedrooms} BHK • ${property.furnishingStatus}\nYield: ${property.annualYield.toStringAsFixed(1)}%';

    return PropertyCard(
      imageUrl: property.images.isNotEmpty ? property.images[0] : '',
      title: property.name,
      price: '₹${property.price.toStringAsFixed(1)}L', // Property price
      area: '${property.area} ${property.area}',
      location: property.address,
      description: description,
      onTap: () {
        Get.toNamed(
          '/rentalYieldDetails',
          arguments: {
            'property': property,
          },
        );
      },
    );
  }

  Color _getYieldColor(double yieldPercentage) {
    if (yieldPercentage >= 7.0) return Colors.green;
    if (yieldPercentage >= 5.0) return Colors.blue;
    if (yieldPercentage >= 3.0) return Colors.amber;
    return Colors.red;
  }
}