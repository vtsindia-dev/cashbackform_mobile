// widgets/syndicate_nearby.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../common/colours.dart';
import '../controller/syndicate_controller.dart';
import '../model/syndicate_model.dart';

class SyndicateNearby extends StatelessWidget {
  SyndicateNearby({super.key});

  final SyndicatePlotController controller = Get.find<SyndicatePlotController>();
  final ScrollController _amenitiesScroll = ScrollController();
  final ScrollController _nearbyScroll = ScrollController();
  final ScrollController _facilitiesScroll = ScrollController();

  Future<void> _launchMaps(double lat, double lon) async {
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lon');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar("Error", "Could not open maps");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to open maps");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final detail = controller.syndicateDetail.value;
      if (detail == null) return const Center(child: CircularProgressIndicator());

      final bool soldOut = detail.isSoldOut;
      final String address = detail.address.isNotEmpty ? detail.address : "-";
      final double? lat = double.tryParse(detail.lat ?? '');
      final double? lon = double.tryParse(detail.long ?? '');
      final amenities = detail.amenities;
      final nearby = detail.nearbyLocations ?? <NearbyLocation>[];
      final facilities = detail.commonFacilities;

      return ColoredBox(
        color: AppColor.backgroundLight.withOpacity(0.5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ──────────────────────────────────────────
            _PropertyHeader(
              address: address,
              uldNo: detail.uldNo,
              soldOut: soldOut,
            ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.2, end: 0),

            _MapRow(
              lat: lat,
              lon: lon,
              address: address,
              onTap: (lat != null && lon != null) ? () => _launchMaps(lat, lon) : null,
            ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),

            // ── Sections ─────────────────────────────────────────
            if (!soldOut) ...[
              if (facilities.isNotEmpty)
                _ScrollSection(
                  title: "Common Facilities",
                  count: facilities.length,
                  controller: _facilitiesScroll,
                  items: facilities,
                  itemWidth: 110.w,
                  builder: (item) => _FacilityCard(item),
                ).animate().fadeIn(duration: 450.ms),

              if (amenities.isNotEmpty)
                _ScrollSection(
                  title: "Amenities",
                  count: amenities.length,
                  controller: _amenitiesScroll,
                  items: amenities,
                  itemWidth: 110.w,
                  builder: (item) => _AmenityCard(item as Amenity),
                ).animate().fadeIn(duration: 500.ms),

              if (nearby.isNotEmpty)
                _ScrollSection(
                  title: "Nearby Places",
                  count: nearby.length,
                  controller: _nearbyScroll,
                  items: nearby,
                  itemWidth: 190.w,
                  itemHeight: 80.h,
                  builder: (item) => _NearbyCard(item as NearbyLocation),
                ).animate().fadeIn(duration: 550.ms),

              if (facilities.isEmpty && amenities.isEmpty && nearby.isEmpty)
                _EmptyCard()
                    .animate()
                    .fadeIn(duration: 500.ms)
                    .scale(begin: const Offset(0.95, 0.95)),
            ],

            if (soldOut)
              _SoldOutBanner(
                hasFacilities: facilities.isNotEmpty,
                hasAmenities: amenities.isNotEmpty,
                hasNearby: nearby.isNotEmpty,
              ).animate().fadeIn(duration: 450.ms),

            SizedBox(height: 16.h),
          ],
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Property Header
// ─────────────────────────────────────────────────────────────────────────────
class _PropertyHeader extends StatelessWidget {
  const _PropertyHeader({
    required this.address,
    required this.uldNo,
    required this.soldOut,
  });
  final String address, uldNo;
  final bool soldOut;

  @override
  Widget build(BuildContext context) {
    final color = soldOut ? Colors.red.shade600 : AppColor.primary;
    return Padding(
      padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38.w,
            height: 38.w,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(9.r),
            ),
            child: Icon(
              soldOut ? Icons.block_rounded : Icons.location_on_outlined,
              color: color,
              size: 20.w,
            ),
          ),
          10.w.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  soldOut ? "Property Sold Out" : "Property Location",
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: soldOut ? Colors.red.shade700 : AppColor.textMain,
                  ),
                ),
                3.h.verticalSpace,
                Text(
                  address,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: soldOut ? Colors.red.shade400 : Colors.grey.shade600,
                    height: 1.3,
                  ),
                ),
                3.h.verticalSpace,
                RichText(
                  text: TextSpan(children: [
                    TextSpan(
                      text: "ULPIN: ",
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColor.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(
                      text: uldNo.isNotEmpty ? uldNo : "—",
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: soldOut ? Colors.red.shade400 : Colors.grey.shade700,
                      ),
                    ),
                  ]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Map Row
// ─────────────────────────────────────────────────────────────────────────────
class _MapRow extends StatelessWidget {
  const _MapRow({required this.lat, required this.lon, required this.address, this.onTap});
  final double? lat, lon;
  final String address;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final active = onTap != null;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Location Details",
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
              color: AppColor.textMain,
            ),
          ),
          GestureDetector(
            onTap: active
                ? onTap
                : () => Get.snackbar("Location Not Available", "Coordinates not available"),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: active ? AppColor.primary.withOpacity(0.8) : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(7.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.map_outlined, size: 12.sp, color: Colors.white),
                  4.w.horizontalSpace,
                  Text(
                    "View Map",
                    style: TextStyle(
                      fontSize: 10.sp,
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
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Generic Horizontal Scroll Section
// ─────────────────────────────────────────────────────────────────────────────
class _ScrollSection extends StatelessWidget {
  const _ScrollSection({
    required this.title,
    required this.count,
    required this.controller,
    required this.items,
    required this.itemWidth,
    required this.builder,
    this.itemHeight,
  });

  final String title;
  final int count;
  final ScrollController controller;
  final List<dynamic> items;
  final double itemWidth;
  final double? itemHeight;
  final Widget Function(dynamic) builder;

  void _scroll(bool forward) {
    final target = (controller.offset + (forward ? 130.0 : -130.0))
        .clamp(0.0, controller.position.maxScrollExtent);
    controller.animateTo(target,
        duration: const Duration(milliseconds: 280), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Section title + count badge
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            child: Row(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColor.textMain,
                  ),
                ),
                6.w.horizontalSpace,
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: AppColor.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    "$count",
                    style: TextStyle(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColor.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          6.h.verticalSpace,
          // Scroll row
          SizedBox(
            height: itemHeight ?? 105.h,
            child: Row(
              children: [
                if (items.length > 2)
                  _ArrowBtn(onTap: () => _scroll(false), isRight: false),
                Expanded(
                  child: ListView.builder(
                    controller: controller,
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    itemCount: items.length,
                    itemBuilder: (_, i) => SizedBox(
                      width: itemWidth,
                      child: builder(items[i])
                          .animate()
                          .fadeIn(duration: 300.ms)
                          .slideX(begin: 0.3, end: 0, duration: 300.ms),
                    ),
                  ),
                ),
                if (items.length > 2)
                  _ArrowBtn(onTap: () => _scroll(true), isRight: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Arrow Button
// ─────────────────────────────────────────────────────────────────────────────
class _ArrowBtn extends StatelessWidget {
  const _ArrowBtn({required this.onTap, required this.isRight});
  final VoidCallback onTap;
  final bool isRight;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 26.w,
        height: 26.w,
        margin: EdgeInsets.symmetric(horizontal: 2.w),
        decoration: BoxDecoration(
          color: AppColor.primary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          isRight ? Icons.arrow_forward_ios_rounded : Icons.arrow_back_ios_rounded,
          size: 11.sp,
          color: AppColor.primary,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Facility Card
// ─────────────────────────────────────────────────────────────────────────────
class _FacilityCard extends StatelessWidget {
  const _FacilityCard(this.facility);
  final dynamic facility;

  @override
  Widget build(BuildContext context) => _IconCard(
    imageUrl: facility.image ?? '',
    title: facility.title ?? '',
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Amenity Card
// ─────────────────────────────────────────────────────────────────────────────
class _AmenityCard extends StatelessWidget {
  const _AmenityCard(this.amenity);
  final Amenity amenity;

  @override
  Widget build(BuildContext context) => _IconCard(
    imageUrl: amenity.image,
    title: amenity.title,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared Icon Card (Facility + Amenity)
// ─────────────────────────────────────────────────────────────────────────────
class _IconCard extends StatelessWidget {
  const _IconCard({required this.imageUrl, required this.title});
  final String imageUrl, title;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            padding: EdgeInsets.all(7.w),
            decoration: BoxDecoration(
              color: AppColor.primary.withOpacity(0.06),
              borderRadius: BorderRadius.circular(9.r),
            ),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.contain,
              placeholder: (_, __) =>
                  Icon(Icons.category_outlined, size: 18.sp, color: AppColor.primary),
              errorWidget: (_, __, ___) =>
                  Icon(Icons.category_outlined, size: 18.sp, color: AppColor.primary),
            ),
          ),
          6.h.verticalSpace,
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 9.sp,
              fontWeight: FontWeight.w600,
              color: AppColor.textMain,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Nearby Place Card
// ─────────────────────────────────────────────────────────────────────────────
class _NearbyCard extends StatelessWidget {
  const _NearbyCard(this.place);
  final NearbyLocation place;

  @override
  Widget build(BuildContext context) {
    final dist = double.tryParse(place.pivot?.distance ?? '0') ?? 0.0;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          SizedBox(
            width: 62.w,
            child: place.image.isNotEmpty
                ? Image.network(place.image, fit: BoxFit.cover, height: double.infinity)
                : ColoredBox(color: Colors.grey.shade200),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    place.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColor.textMain,
                      height: 1.3,
                    ),
                  ),
                  5.h.verticalSpace,
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 10.sp, color: AppColor.primary),
                      3.w.horizontalSpace,
                      Flexible(
                        child: Text(
                          "${dist.toStringAsFixed(1)} km",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
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
}

// ─────────────────────────────────────────────────────────────────────────────
// Sold Out Banner
// ─────────────────────────────────────────────────────────────────────────────
class _SoldOutBanner extends StatelessWidget {
  const _SoldOutBanner({
    required this.hasFacilities,
    required this.hasAmenities,
    required this.hasNearby,
  });
  final bool hasFacilities, hasAmenities, hasNearby;

  @override
  Widget build(BuildContext context) {
    if (!hasFacilities && !hasAmenities && !hasNearby) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 0),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.block_rounded, color: Colors.red.shade600, size: 18.sp),
            10.w.horizontalSpace,
            Expanded(
              child: Text(
                "Property sold out. Amenities, facilities and nearby places are locked.",
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 0),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline_rounded, size: 20.sp, color: Colors.grey.shade400),
            10.w.horizontalSpace,
            Expanded(
              child: Text(
                "No amenities, facilities, or nearby places available yet.",
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
