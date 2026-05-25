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
                child: const Center(child: CircularProgressIndicator()),
              )
                  : const SizedBox.shrink();
            }

            final leftIndex = index * 2;
            final rightIndex = leftIndex + 1;

            final leftProperty = properties[leftIndex];
            final rightProperty = rightIndex < properties.length ? properties[rightIndex] : null;

            return Padding(
              padding: EdgeInsets.only(bottom: 16.h),
              child: Row(
                children: [
                  Expanded(child: _buildPropertyCard(leftProperty)),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: rightProperty != null
                        ? _buildPropertyCard(rightProperty)
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildPropertyCard(RentalListProperty property) {

    final monthlyRentDouble = property.rentAmountDouble;
    final monthlyRentInK = monthlyRentDouble / 1000;
    final annualYield = property.yieldAmountDouble > 0 && monthlyRentDouble > 0
        ? (property.yieldAmountDouble / (monthlyRentDouble * 12)) * 100
        : 0.0;

    final yieldBadge = Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: _getYieldColor(annualYield),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${annualYield.toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 4.w),
          Icon(
            annualYield >= 5 ? Icons.trending_up : Icons.trending_flat,
            size: 12.r,
            color: Colors.white,
          ),
        ],
      ),
    );

    final imageUrl = property.images.isNotEmpty
        ? property.images[0]
        : 'https://via.placeholder.com/300x200.png?text=Property';

    final area = property.areaDouble;
    final description = '${area != null ? '${area.toInt()} sq.ft • ' : ''}Yield: ${annualYield.toStringAsFixed(1)}%';

    final location = property.address;
    final cityState = [
      if (property.cityName.isNotEmpty) property.cityName,
      if (property.stateName.isNotEmpty) property.stateName,
    ].where((element) => element.isNotEmpty).join(', ');

    final fullLocation = cityState.isNotEmpty ? '$location, $cityState' : location;

    return PropertyCard(
      imageUrl: imageUrl,
      soldStatus: property.soldStatus,
      title: property.name,
      price: '₹${monthlyRentInK.toStringAsFixed(1)}K/mo',
      area: '${property.areaDouble?.toInt() ?? 0} sq.ft',
      location: fullLocation,
      description: description,
      onTap: () {
        Get.toNamed(
          '/rentalDetails',
          arguments: {
            'id': property.id,
            'title': property.name,
          },
        );
      },
    );
  }

  Color _getYieldColor(double yieldPercentage) {
    if (yieldPercentage >= 7.0) return Colors.green[700]!;
    if (yieldPercentage >= 5.0) return Colors.blue[700]!;
    if (yieldPercentage >= 3.0) return Colors.amber[700]!;
    return Colors.red[700]!;
  }
}