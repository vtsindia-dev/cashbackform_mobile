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

  Future<void> _launchGoogleMaps(dynamic lat, dynamic lng) async {
    double? latitude;
    double? longitude;
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
    latitude = _toDouble(lat);
    longitude = _toDouble(lng);
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
    if (latitude == 0.0 && longitude == 0.0) {
      Get.snackbar("Error", "Location coordinates not available");
      return;
    }
    final googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );
    final appleMapsUrl = Uri.parse(
      'https://maps.apple.com/?q=$latitude,$longitude',
    );
    try {
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(
          googleMapsUrl,
          mode: LaunchMode.externalApplication,
        );
      } else if (await canLaunchUrl(appleMapsUrl)) {
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
                    "Amenities",
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

    return SizedBox(
      height: showKm ? 80.h : 70.h, // Taller height if showing km
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
                  showKm: showKm,
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
      width: 140.w,
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

          // Distance (subtitle) below the row - ONLY for nearby locations (showKm = true)
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