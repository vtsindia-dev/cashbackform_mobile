import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../Properties/widget/property_card.dart';
import '../controller/residential_controller.dart';
import '../model/residential_model.dart';

class ResidentialPropertyList extends StatelessWidget {
  ResidentialPropertyList({super.key});

  @override
  Widget build(BuildContext context) {
    final ResidentialPropertyController controller = Get.find();

    return Obx(() {
      final properties = controller.properties;

      if (controller.isLoading.value && properties.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (properties.isEmpty) {
        return const Center(child: Text('No properties found'));
      }

      final rowCount = (properties.length / 2).ceil();

      return NotificationListener<ScrollNotification>(
        onNotification: (scroll) {
          if (!controller.hasMoreData.value) return false;

          if (scroll.metrics.pixels >= scroll.metrics.maxScrollExtent * 0.9) {
            controller.loadMoreProperties();
          }
          return false;
        },
        child: ListView.builder(
          padding: EdgeInsets.all(16.r),
          itemCount: rowCount + 1,
          itemBuilder: (context, index) {
            if (index == rowCount) {
              return controller.isLoadMore.value
                  ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: CircularProgressIndicator()),
              )
                  : const SizedBox.shrink();
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

  Widget _buildPropertyCard(Property property) {
    return PropertyCard(
      imageUrl: property.thumbnail.isNotEmpty
          ? property.thumbnail
          : (property.galleryImages.isNotEmpty ? property.galleryImages[0] : ''),
      title: property.propertyName,
      price: property.formattedPrice,
      area: property.formattedArea,
      location: property.location,
      description: property.aboutProperty.isNotEmpty
          ? property.aboutProperty.substring(0, property.aboutProperty.length > 50 ? 50 : property.aboutProperty.length)
          : '',
      onTap: () {
        print("View Property: ${property.propertyName}");
        Get.toNamed('residentialDetails', arguments: {"id": property.id, "title": property.propertyName});
      },
    );
  }
}