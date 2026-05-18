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
      // +1 for the load-more/end indicator row
      final itemCount = rowCount + 1;

      return NotificationListener<ScrollNotification>(
        onNotification: (scroll) {
          if (scroll is! ScrollEndNotification) return false; // only fire on scroll end
          if (!controller.hasMoreData.value) return false;
          if (controller.isLoadMore.value) return false; // prevent duplicate calls
          if (scroll.metrics.pixels >=
              scroll.metrics.maxScrollExtent - 200) { // 200px before end
            controller.loadMoreProperties();
          }
          return false;
        },
        child: ListView.builder(
          padding: EdgeInsets.all(16.r),
          itemCount: itemCount,
          itemBuilder: (context, index) {
            // Last item — load more indicator or end message
            if (index == rowCount) {
              if (controller.isLoadMore.value) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (!controller.hasMoreData.value && properties.isNotEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text(
                      'No more properties',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            }

            final leftIndex = index * 2;
            final rightIndex = leftIndex + 1;

            // Guard against out-of-bounds during load
            if (leftIndex >= properties.length) return const SizedBox.shrink();

            final leftProperty = properties[leftIndex];
            final rightProperty = rightIndex < properties.length
                ? properties[rightIndex]
                : null;

            return Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
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
  Widget _buildPropertyCard(Property property) {
    return Stack(
      children: [
        // Existing property card — untouched
        PropertyCard(
          imageUrl: property.galleryImages.isNotEmpty
              ? property.galleryImages[0]
              : (property.thumbnail.isNotEmpty
              ? property.thumbnail
              : ''),
          title: property.propertyName,
          price: property.formattedPrice,
          area: property.formattedArea,
          location: property.location,
          description: property.aboutProperty.isNotEmpty
              ? property.aboutProperty.substring(
              0,
              property.aboutProperty.length > 50
                  ? 50
                  : property.aboutProperty.length)
              : '',
          onTap: () {
            print("View Property: ${property.propertyName}");
            Get.toNamed('residentialDetails',
                arguments: {
                  "id": property.id,
                  "title": property.propertyName
                });
          },
        ),

        // India / Dubai badge — top-left corner over the card
        Positioned(
          top: 8,
          left: 8,
          child: _LocationBadge(property: property),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// Location badge widget
// -----------------------------------------------------------------------------

class _LocationBadge extends StatelessWidget {
  final Property property;
  const _LocationBadge({required this.property});

  @override
  Widget build(BuildContext context) {
    final bool isDubai = property.isIndia;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: isDubai
            ? const Color(0xFFFFF3E0)   // warm amber for Dubai
            : const Color(0xFFE8F5E9),  // soft green for India
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isDubai
              ? const Color(0xFFFF9800).withOpacity(0.6)
              : const Color(0xFF4CAF50).withOpacity(0.6),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isDubai ? '🇦🇪' : '🇮🇳',
            style: TextStyle(fontSize: 10.sp),
          ),
          SizedBox(width: 3.w),
          Text(
            isDubai ? 'Dubai' : 'India',
            style: TextStyle(
              fontSize: 9.sp,
              fontWeight: FontWeight.w700,
              color: isDubai
                  ? const Color(0xFFE65100)
                  : const Color(0xFF2E7D32),
            ),
          ),
        ],
      ),
    );
  }
}