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

  // Function to open Google Maps with coordinates
  Future<void> _launchGoogleMaps(dynamic lat, dynamic lng) async {
    double? latitude;
    double? longitude;

    // Helper function to safely convert any type to double
    double? _toDouble(dynamic value) {
      if (value == null) return null;
      if (value is int) {
        return value.toDouble();
      } else if (value is double) {
        return value;
      } else if (value is String) {
        return double.tryParse(value);
      } else if (value is num) {
        return value.toDouble();
      }
      return null;
    }

    // Convert lat to double
    latitude = _toDouble(lat);

    // Convert lng to double
    longitude = _toDouble(lng);

    // Fallback to controller values if needed
    if (latitude == null || longitude == null) {
      final detail = controller.giooPlotDetail.value;
      if (detail != null) {
        latitude = _toDouble(detail.lat) ?? 0.0;
        longitude = _toDouble(detail.long) ?? 0.0;
      } else {
        latitude = 0.0;
        longitude = 0.0;
      }
    }

    // Check if coordinates are valid
    if (latitude == 0.0 && longitude == 0.0) {
      Get.snackbar("Error", "Location coordinates not available");
      return;
    }

    // Google Maps URL
    final googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );

    // Alternative: Apple Maps for iOS
    final appleMapsUrl = Uri.parse(
      'https://maps.apple.com/?q=$latitude,$longitude',
    );

    try {
      // Try Google Maps first
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(
          googleMapsUrl,
          mode: LaunchMode.externalApplication,
        );
      } else if (await canLaunchUrl(appleMapsUrl)) {
        // Fallback to Apple Maps
        await launchUrl(
          appleMapsUrl,
          mode: LaunchMode.externalApplication,
        );
      } else {
        Get.snackbar("Error", "Could not launch maps application");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to open maps: ${e.toString()}");
    }
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
      final List<NearbyLocation> nearbyLocations = detail.nearby_locations;

      return Container(
        color: AppColor.backgroundLight.withOpacity(0.5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // LOCATION DETAILS SECTION
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 45.w,
                    height: 45.w,
                    decoration: BoxDecoration(
                      color: AppColor.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Center(
                      child: Icon(Icons.location_on_outlined,
                          color: AppColor.primary, size: 25.w),
                    ),
                  ),
                  12.w.horizontalSpace,

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Property location",
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColor.textMain.withOpacity(0.8),
                          ),
                        ),
                        4.h.verticalSpace,
                        Text(
                          address,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        4.h.verticalSpace,
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "ULPIN Number: ",
                                style: TextStyle(
                                    fontSize: 12.sp,
                                    color: AppColor.primary,
                                    fontWeight: FontWeight.w500),
                              ),
                              TextSpan(
                                text: uldNo,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Show coordinates if available
                        if (detail.lat != null || detail.long != null) ...[
                          4.h.verticalSpace,
                          Text(
                            "Coordinates: ${detail.lat ?? '-'}, ${detail.long ?? '-'}",
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  )
                ],
              ),
            ),

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
                    "Amenities Nearby",
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColor.textMain,
                    ),
                  ),

                  // VIEW MAP BUTTON
                  GestureDetector(
                    onTap: () => _launchGoogleMaps(
                      detail.lat,
                      detail.long,
                    ),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: AppColor.primary.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.map_outlined,
                            size: 14.sp,
                            color: Colors.white,
                          ),
                          4.w.horizontalSpace,
                          Text(
                            "View on Map",
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
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
              getSubtitle: (item) => (item as Amenity).distance != null
                  ? "${(item as Amenity).distance} km"
                  : "",
              fallbackIcon: Icons.category_outlined,
              emptyMessage: "No amenities available",
            ),

            25.h.verticalSpace,

            // ------------------------------------
            // NEARBY LOCATIONS SECTION
            // ------------------------------------
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Text(
                "Around This Plot",
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColor.textMain,
                ),
              ),
            ),

            15.h.verticalSpace,

            // ------------------------------------
            // NEARBY LOCATIONS LIST - Using SAME small card design as amenities
            // ------------------------------------
            _buildHorizontalSmallCardList(
              items: nearbyLocations,
              scrollController: nearbyScrollController,
              getImage: (item) => (item as NearbyLocation).image,
              getTitle: (item) => (item as NearbyLocation).title,
              getSubtitle: (item) => "Nearby location",
              fallbackIcon: Icons.location_on,
              emptyMessage: "No nearby locations available",
            ),

            20.h.verticalSpace,
          ],
        ),
      );
    });
  }

  // ------------------------------------
  // HORIZONTAL SMALL CARD LIST (for both amenities and nearby locations)
  // ------------------------------------
  Widget _buildHorizontalSmallCardList({
    required List<dynamic> items,
    required ScrollController scrollController,
    required String? Function(dynamic) getImage,
    required String Function(dynamic) getTitle,
    required String Function(dynamic) getSubtitle,
    required IconData fallbackIcon,
    required String emptyMessage,
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

    return SizedBox(
      height: 70.h, // Same height as amenities section
      child: Row(
        children: [
          // Left arrow button
          _buildArrowButton(
            isRight: false,
            scrollController: scrollController,
          ),

          // Items list
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final image = getImage(item);
                final title = getTitle(item);
                final subtitle = getSubtitle(item);

                return _buildSmallCard(
                  image: image,
                  title: title,
                  subtitle: subtitle,
                  icon: fallbackIcon,
                );
              },
            ),
          ),

          // Right arrow button
          _buildArrowButton(
            isRight: true,
            scrollController: scrollController,
          ),
        ],
      ),
    );
  }

  // ------------------------------------
  // SMALL CARD DESIGN (same as original amenities design)
  // ------------------------------------
  Widget _buildSmallCard({
    String? image,
    required String title,
    required String subtitle,
    IconData? icon,
  }) {
    return Container(
      width: 140.w, // Same width as amenities cards
      margin: EdgeInsets.symmetric(horizontal: 4.w),
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
      child: Row(
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
          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
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
                // 4.h.verticalSpace,
                // Text(
                //   subtitle,
                //   style: TextStyle(
                //     fontSize: 10.sp,
                //     color: Colors.grey.shade600,
                //   ),
                // ),
              ],
            ),
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