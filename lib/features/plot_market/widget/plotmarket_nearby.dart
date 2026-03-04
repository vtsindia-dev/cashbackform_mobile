import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../common/colours.dart';
import '../controller/plot_market_controller.dart';
import '../model/plot_market.dart';

class NearbyPlotMarket extends StatelessWidget {
  NearbyPlotMarket({super.key});

  final PlotMarketController controller = Get.find<PlotMarketController>();
  final ScrollController amenitiesScrollController = ScrollController();
  final ScrollController nearbyPlacesScrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final detail = controller.marketDetail.value;

      if (detail == null) {
        return const Center(child: CircularProgressIndicator());
      }

      final String uldNo = detail.uldNo?.isNotEmpty == true ? detail.uldNo! : "-";
      final String address = detail.address.isNotEmpty ? detail.address : "-";
      final String lat = detail.lat;
      final String lng = detail.long;
      final List<Amenity> amenities = detail.amenityList;
      final List<NearbyLocation> nearbyLocations = detail.nearbyLocations;

      return Container(
        color: AppColor.backgroundLight.withOpacity(0.5),
        padding: EdgeInsets.only(bottom: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPropertyHeader(address, uldNo)
                .animate()
                .fadeIn(duration: 400.ms)
                .slideY(begin: 0.3, end: 0, duration: 400.ms),
            25.h.verticalSpace,
            _buildHeaderWithMap(lat, lng, address)
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
                isAmenity: true,
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
                isAmenity: false,
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
                        text: uldNo,
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

  Widget _buildHeaderWithMap(String lat, String lng, String address) {
    // Check if coordinates are valid
    final hasValidCoordinates = lat.isNotEmpty && lng.isNotEmpty &&
        double.tryParse(lat) != null && double.tryParse(lng) != null;

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
            onTap: hasValidCoordinates
                ? () => _openGoogleMaps(lat, lng, address)
                : () {
              Get.snackbar(
                "Location Unavailable",
                "Coordinates not available",
                backgroundColor: Colors.orange,
                colorText: Colors.white,
              );
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
              decoration: BoxDecoration(
                color: hasValidCoordinates
                    ? AppColor.primary.withOpacity(0.7)
                    : Colors.grey.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.map_outlined,
                      size: 14.sp,
                      color: hasValidCoordinates ? Colors.white : Colors.grey[300]),
                  4.w.horizontalSpace,
                  Text(
                    "View on Map",
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: hasValidCoordinates ? Colors.white : Colors.grey[300],
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
            duration: 800.ms,
            color: hasValidCoordinates
                ? Colors.white.withOpacity(0.3)
                : Colors.grey.withOpacity(0.2),
          ),
        ],
      ),
    );
  }

  Future<void> _openGoogleMaps(String lat, String lng, String address) async {
    try {
      // Create Google Maps URL with coordinates
      final encodedAddress = Uri.encodeComponent(address);
      final googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng&query_place_id=$encodedAddress';

      // Alternative: For direct navigation
      // final googleMapsUrl = 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng';

      final uri = Uri.parse(googleMapsUrl);

      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        Get.snackbar(
          "Error",
          "Could not open Google Maps",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to open map: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
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
    required bool isAmenity,
  }) {
    return SizedBox(
      height: isAmenity ? 95.h : 113.h,
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
                return builder(item)
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideX(begin: 0.5, end: 0)
                    .scale(
                  begin: const Offset(0.9, 0.9),
                  end: const Offset(1, 1),
                  duration: 500.ms,
                  curve: Curves.easeOutBack,
                )
                    .shimmer(duration: 800.ms, color: Colors.white.withOpacity(0.3));
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
      width: 140.w,
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(10.w),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppColor.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: amenity.image.isNotEmpty
                ? Image.network(
              amenity.image,
              width: 32.w,
              height: 32.h,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.category_outlined,
                  size: 24.sp,
                  color: AppColor.primary,
                );
              },
            )
                : Icon(
              Icons.category_outlined,
              size: 24.sp,
              color: AppColor.primary,
            ),
          ),
          8.h.verticalSpace,
          Text(
            amenity.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.bold,
              color: AppColor.textMain,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNearbyPlaceCard(NearbyLocation place) {
    final distance = place.pivot?.distance ?? 0.0;

    return Container(
      width: 160.w,
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(10.w),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppColor.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: place.image.isNotEmpty
                ? Image.network(
              place.image,
              width: 32.w,
              height: 32.h,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.place_outlined,
                  size: 24.sp,
                  color: AppColor.primary,
                );
              },
            )
                : Icon(
              Icons.place_outlined,
              size: 24.sp,
              color: AppColor.primary,
            ),
          ),
          8.h.verticalSpace,
          Text(
            place.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.bold,
              color: AppColor.textMain,
            ),
          ),
          4.h.verticalSpace,
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              "${distance.toStringAsFixed(1)} km",
              style: TextStyle(
                fontSize: 9.sp,
                color: Colors.green,
                fontWeight: FontWeight.w600,
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
      visible: itemCount > 2, // Show arrows only if there are enough items
      child: GestureDetector(
        onTap: () {
          if (itemCount <= 2) return;

          final scrollAmount = 180.0;
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
          width: 36.w,
          height: 36.w,
          margin: EdgeInsets.symmetric(horizontal: 2.w),
          decoration: BoxDecoration(
            color: AppColor.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isRight ? Icons.arrow_forward_ios_rounded : Icons.arrow_back_ios_rounded,
            size: 16.sp,
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