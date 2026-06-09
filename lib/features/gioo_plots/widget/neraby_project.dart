import 'package:cashback_farms/features/gioo_plots/model/gioo_plot.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../common/colours.dart';
import '../controller/gioo_controller.dart';

class NearbyProject extends StatelessWidget {
  NearbyProject({super.key});

  final GiooPlotController controller = Get.find<GiooPlotController>();
  final ScrollController amenitiesScrollController = ScrollController();
  final ScrollController nearbyScrollController = ScrollController();

  String _formatDistance(dynamic distance) {
    if (distance == null) return "";
    if (distance is String) {
      // Remove any extra spaces
      final trimmed = distance.trim();

      // Check if it already contains "km" (case insensitive)
      if (trimmed.toLowerCase().contains("km")) {
        return trimmed;
      }

      // Try to parse as number and add km
      final parsed = double.tryParse(trimmed);
      if (parsed != null) {
        // Format to 1 decimal place if needed
        return parsed % 1 == 0 ?
        "${parsed.toInt()} km" :
        "${parsed.toStringAsFixed(1)} km";
      }

      // If can't parse, just add km
      return "$trimmed km";
    }

    // If it's a number
    if (distance is num) {
      final doubleValue = distance.toDouble();
      return doubleValue % 1 == 0 ?
      "${doubleValue.toInt()} km" :
      "${doubleValue.toStringAsFixed(1)} km";
    }

    return "";
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final detail = controller.giooPlotDetail.value;

      if (detail == null) {
        return const Center(child: CircularProgressIndicator());
      }

      final String uldNo = detail.uldNo ?? "-";
      final String address = detail.address ?? "-";
      final List<Amenity> amenities = detail.amenity ?? [];
      final List<NearbyLocation> nearbyLocations = detail.nearby_locations ?? [];

      return Container(
        color: AppColor.backgroundLight.withOpacity(0.5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // LOCATION DETAILS SECTION


            25.h.verticalSpace,

            // ------------------------------------
            // HEADER FOR AMENITIES
            // ------------------------------------
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Amenities",
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColor.textMain,
                    ),
                  ),

                ],
              ),
            ),

            15.h.verticalSpace,

            // ------------------------------------
            // AMENITIES LIST - Using small card design
            // ------------------------------------
            _buildHorizontalSmallCardList(
              items: amenities,
              scrollController: amenitiesScrollController,
              getImage: (item) => (item as Amenity).image,
              getTitle: (item) => (item as Amenity).title ?? "",
              getSubtitle: (item) => "", // EMPTY for amenities - no distance shown
              fallbackIcon: Icons.category_outlined,
              emptyMessage: "No amenities available",
              showKm: false, // Set to false for amenities
            ),

            25.h.verticalSpace,

            // ------------------------------------
            // NEARBY LOCATIONS SECTION
            // ------------------------------------
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Text(
                "Nearby to This Plot",
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColor.textMain,
                ),
              ),
            ),

            15.h.verticalSpace,

            // ------------------------------------
            // NEARBY LOCATIONS LIST - Using SAME small card design
            // ------------------------------------
            _buildHorizontalSmallCardList(
              items: nearbyLocations,
              scrollController: nearbyScrollController,
              getImage: (item) => (item as NearbyLocation).image,
              getTitle: (item) => (item as NearbyLocation).title,
              getSubtitle: (item) {
                final nearbyItem = item as NearbyLocation;

                // Get distance from pivot
                if (nearbyItem.pivot?.distance != null) {
                  return _formatDistance(nearbyItem.pivot!.distance);
                }

                // If pivot is null or distance is null, check for direct distance field
                final distance = nearbyItem.pivot.distance;
                return _formatDistance(distance);
              },
              fallbackIcon: Icons.location_on,
              emptyMessage: "No nearby locations available",
              showKm: true, // Set to true for nearby locations
            ),

            20.h.verticalSpace,
          ],
        ),
      );
    });
  }

  // ------------------------------------
  // HORIZONTAL SMALL CARD LIST
  // ------------------------------------
  Widget _buildHorizontalSmallCardList({
    required List<dynamic> items,
    required ScrollController scrollController,
    required String? Function(dynamic) getImage,
    required String Function(dynamic) getTitle,
    required String Function(dynamic) getSubtitle,
    required IconData fallbackIcon,
    required String emptyMessage,
    bool showKm = false,
  }) {
    if (items.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Text(
          emptyMessage,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey.shade600,
          ),
        ),
      );
    }

    final hasMoreThanTwoItems = items.length > 2;

    return SizedBox(
      height: showKm ? 80.h : 70.h, // Taller height if showing km
      child: Row(
        children: [
          // Left arrow button - only show if more than 2 items
          if (hasMoreThanTwoItems)
            _buildArrowButton(
              isRight: false,
              scrollController: scrollController,
            ),

          // Items list
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(
                horizontal: hasMoreThanTwoItems ? 4.w : 20.w,
              ),
              physics: hasMoreThanTwoItems
                  ? const BouncingScrollPhysics()
                  : const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final image = getImage(item);
                final title = getTitle(item);
                final subtitle = getSubtitle(item);

                // Adjust width based on item count
                final itemWidth = items.length <= 2
                    ? 140.w
                    : 140.w;

                return Container(
                  width: itemWidth,
                  margin: EdgeInsets.only(
                    right: index < items.length - 1 ? 8.w : 0,
                  ),
                  child: _buildSmallCard(
                    image: image,
                    title: title,
                    subtitle: subtitle,
                    icon: fallbackIcon,
                    showKm: showKm,
                  ),
                );
              },
            ),
          ),

          // Right arrow button - only show if more than 2 items
          if (hasMoreThanTwoItems)
            _buildArrowButton(
              isRight: true,
              scrollController: scrollController,
            ),
        ],
      ),
    );
  }

  // ------------------------------------
  // SMALL CARD DESIGN
  // ------------------------------------
  Widget _buildSmallCard({
    String? image,
    required String title,
    required String subtitle,
    IconData? icon,
    bool showKm = false,
  }) {
    final hasDistance = subtitle.isNotEmpty && showKm;

    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Image/Icon container
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: image != null && image.isNotEmpty
                    ? Image.network(
                  image,
                  width: 32.w,
                  height: 32.h,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildSmallCardFallbackIcon(icon);
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return SizedBox(
                      width: 32.w,
                      height: 32.h,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                )
                    : _buildSmallCardFallbackIcon(icon),
              ),
              6.w.horizontalSpace,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColor.textMain,
                      ),
                    ),
                    if (hasDistance) ...[
                      2.h.verticalSpace,
                      Padding(
                        padding: EdgeInsets.only(left: 0.w),
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 10.sp,
                              color: AppColor.primary,
                            ),
                            2.w.horizontalSpace,
                            Flexible(
                              child: Text(
                                subtitle,
                                style: TextStyle(
                                  fontSize: 9.sp,
                                  color: AppColor.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Fallback icon for small card
  Widget _buildSmallCardFallbackIcon(IconData? icon) {
    return Icon(
      icon ?? Icons.category_outlined,
      size: 24.sp,
      color: Colors.grey,
    );
  }

  // ------------------------------------
  // ARROW BUTTON
  // ------------------------------------
  Widget _buildArrowButton({
    required bool isRight,
    required ScrollController scrollController,
  }) {
    return GestureDetector(
      onTap: () {
        final scrollAmount = 180.0;

        if (isRight) {
          scrollController.animateTo(
            scrollController.offset + scrollAmount,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        } else {
          scrollController.animateTo(
            scrollController.offset - scrollAmount,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      },
      child: Container(
        width: 40.w,
        height: 40.w,
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        decoration: BoxDecoration(
          color: AppColor.primary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          isRight ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
          size: 18.sp,
          color: AppColor.primary,
        ),
      ),
    );
  }
}