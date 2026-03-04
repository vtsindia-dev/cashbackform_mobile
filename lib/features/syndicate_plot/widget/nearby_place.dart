import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../common/colours.dart';
import '../controller/syndicate_controller.dart';
import '../model/syndicate_model.dart';

class SyndicateNearby extends StatelessWidget {
  SyndicateNearby({super.key});

  final SyndicatePlotController controller = Get.find<SyndicatePlotController>();
  final ScrollController amenitiesScrollController = ScrollController();
  final ScrollController nearbyPlacesScrollController = ScrollController();

  // Function to launch Google Maps with coordinates
  Future<void> _launchGoogleMaps(double? lat, double? lon, String address) async {
    if (lat == null || lon == null) {
      // Fallback to generic map or show error
      Get.snackbar("Location Error", "Coordinates not available");
      return;
    }

    final googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=$lat,$lon';
    final appleMapsUrl = 'https://maps.apple.com/?q=$lat,$lon';

    try {
      // Try launching with Google Maps URL first
      final uri = Uri.parse(googleMapsUrl);

      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        // Fallback to Apple Maps URL
        final appleUri = Uri.parse(appleMapsUrl);
        if (await canLaunchUrl(appleUri)) {
          await launchUrl(
            appleUri,
            mode: LaunchMode.externalApplication,
          );
        } else {
          Get.snackbar("Error", "Could not launch maps app");
        }
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to open maps: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final detail = controller.syndicateDetail.value;

      if (detail == null) {
        return const Center(child: CircularProgressIndicator());
      }

      final String address = detail.address.isNotEmpty ? detail.address : "-";
      final double? lat = double.tryParse(detail.lat ?? '');
      final double? lon = double.tryParse(detail.long ?? '');
      final List<Amenity> amenities = detail.amenities;
      List<NearbyLocation> nearbyLocations = detail.nearbyLocations ?? [];

      return Container(
        color: AppColor.backgroundLight.withOpacity(0.5),
        padding: EdgeInsets.only(bottom: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPropertyHeader(address, detail.uldNo)
                .animate()
                .fadeIn(duration: 400.ms)
                .slideY(begin: 0.3, end: 0, duration: 400.ms),
            25.h.verticalSpace,
            _buildHeaderWithMap(lat, lon, address)
                .animate()
                .fadeIn(duration: 500.ms)
                .slideY(begin: 0.3, end: 0, duration: 500.ms),

            // Amenities Section
            if (amenities.isNotEmpty) ...[
              20.h.verticalSpace,
              _buildSectionHeader("Amenities", amenities.length)
                  .animate()
                  .fadeIn(duration: 550.ms)
                  .slideY(begin: 0.2, end: 0),
              10.h.verticalSpace,
              _buildHorizontalScrollSection(
                items: amenities,
                scrollController: amenitiesScrollController,
                builder: (item) => _buildAmenityCard(item as Amenity),
              ).animate()
                  .fadeIn(duration: 600.ms)
                  .slideY(begin: 0.3, end: 0),
            ],

            // Nearby Places Section
            if (nearbyLocations.isNotEmpty) ...[
              25.h.verticalSpace,
              _buildSectionHeader("Nearby Places", nearbyLocations.length)
                  .animate()
                  .fadeIn(duration: 650.ms)
                  .slideY(begin: 0.2, end: 0),
              10.h.verticalSpace,
              _buildHorizontalScrollSection(
                items: nearbyLocations,
                scrollController: nearbyPlacesScrollController,
                builder: (item) => _buildNearbyPlaceCard(item as NearbyLocation),
                itemWidth: 167.w, // Width for square cards
              ).animate()
                  .fadeIn(duration: 700.ms)
                  .slideY(begin: 0.3, end: 0),
            ],

            // No Content Message
            if (amenities.isEmpty && nearbyLocations.isEmpty) ...[
              20.h.verticalSpace,
              _buildNoContentSection()
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .scale(begin: const Offset(0.9, 0.9)),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildPropertyHeader(String address, String uldNo) {
    return Padding(
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
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
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
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextSpan(
                        text: uldNo.isNotEmpty ? uldNo : "-",
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderWithMap(double? lat, double? lon, String address) {
    final hasCoordinates = lat != null && lon != null;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Location Details",
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
              color: AppColor.textMain,
            ),
          ),
          GestureDetector(
            onTap: () async {
              if (hasCoordinates) {
                await _launchGoogleMaps(lat, lon, address);
              } else {
                Get.snackbar(
                  "Location Not Available",
                  "Coordinates not provided for this property",
                  backgroundColor: Colors.orange[100],
                  colorText: Colors.orange[900],
                );
              }
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
              decoration: BoxDecoration(
                color: hasCoordinates
                    ? AppColor.primary.withOpacity(0.7)
                    : Colors.grey.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(
                      Icons.map_outlined,
                      size: 14.sp,
                      color: Colors.white
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
          )
              .animate()
              .fadeIn(duration: 600.ms)
              .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1))
              .then()
              .shimmer(
              duration: hasCoordinates ? 800.ms : 0.ms,
              color: Colors.white.withOpacity(0.3)
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
              color: AppColor.textMain,
            ),
          ),
          8.w.horizontalSpace,
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: AppColor.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              "$count",
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.bold,
                color: AppColor.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalScrollSection({
    required List<dynamic> items,
    required ScrollController scrollController,
    required Widget Function(dynamic) builder,
    double itemWidth = 130,
  }) {
    return SizedBox(
      height: 80.h, // Increased height for square cards
      child: Row(
        children: [
          _buildArrowButton(
            scrollController: scrollController,
            isRight: false,
            itemCount: items.length,
          ),
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Container(
                  width: itemWidth,
                  padding: EdgeInsets.symmetric(horizontal: 2.w),
                  child: builder(item)
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideX(begin: 0.5, end: 0)
                      .scale(
                    begin: const Offset(0.9, 0.9),
                    end: const Offset(1, 1),
                    duration: 500.ms,
                    curve: Curves.easeOutBack,
                  )
                      .shimmer(duration: 800.ms, color: Colors.white.withOpacity(0.3)),
                );
              },
            ),
          ),
          _buildArrowButton(
            scrollController: scrollController,
            isRight: true,
            itemCount: items.length,
          ),
        ],
      ),
    );
  }

  Widget _buildAmenityCard(Amenity amenity) {
    return Container(
      width: 130.w,
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: AppColor.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: amenity.image.isNotEmpty
                ? Image.network(
              amenity.image,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.category_outlined,
                  size: 18.sp,
                  color: AppColor.primary,
                );
              },
            )
                : Icon(
              Icons.category_outlined,
              size: 18.sp,
              color: AppColor.primary,
            ),
          ),
          8.w.horizontalSpace,
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  amenity.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColor.textMain,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNearbyPlaceCard(NearbyLocation place) {
    final distance = place.pivot?.distance ?? "0.0";
    final double parsedDistance = double.tryParse(distance) ?? 0.0;

    return Container(
      width: 220.w, // Slightly wider for the row layout
      height: 70.h,  // Much shorter height
      margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: [
          // 1. Image on the Left
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12.r),
              bottomLeft: Radius.circular(12.r),
            ),
            child: SizedBox(
              width: 50.w,
              height: 50.h,
              child: place.image.isNotEmpty
                  ? Image.network(place.image, fit: BoxFit.cover)
                  : Container(color: Colors.grey[200]),
            ),
          ),

          // 2. Content on the Right
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    place.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColor.textMain,
                    ),
                  ),
                  4.h.verticalSpace,

                  // Distance Indicator
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 10.sp, color: AppColor.primary),
                      2.w.horizontalSpace,
                      Text(
                        "${parsedDistance.toStringAsFixed(1)} km away",
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildArrowButton({
    required ScrollController scrollController,
    required bool isRight,
    required int itemCount,
  }) {
    return Visibility(
      visible: itemCount > 2,
      child: GestureDetector(
        onTap: () {
          if (itemCount <= 2) return;

          final scrollAmount = 150.0;
          final newOffset = isRight
              ? scrollController.offset + scrollAmount
              : scrollController.offset - scrollAmount;

          final maxOffset = scrollController.position.maxScrollExtent;
          final targetOffset = isRight
              ? newOffset.clamp(0.0, maxOffset)
              : newOffset.clamp(0.0, maxOffset);

          scrollController.animateTo(
            targetOffset,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        child: Container(
          width: 30.w,
          height: 30.w,
          margin: EdgeInsets.symmetric(horizontal: 2.w),
          decoration: BoxDecoration(
            color: AppColor.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isRight ? Icons.arrow_forward_ios_rounded : Icons.arrow_back_ios_rounded,
            size: 14.sp,
            color: AppColor.primary,
          ),
        )
            .animate()
            .scale(
          duration: 500.ms,
          curve: Curves.easeInOutBack,
        )
            .shimmer(duration: 800.ms, color: Colors.white.withOpacity(0.2)),
      ),
    );
  }

  Widget _buildNoContentSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              Icons.info_outline_rounded,
              size: 40.sp,
              color: Colors.grey.withOpacity(0.5),
            ),
            8.h.verticalSpace,
            Text(
              "No additional information",
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            4.h.verticalSpace,
            Text(
              "Amenities and nearby places information will appear here when available",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.sp,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}