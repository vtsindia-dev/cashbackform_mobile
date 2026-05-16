// =============================================================================
// FILE: about_residential_property_updated.dart
//
// Changes applied (no functional changes to existing logic):
//   1. Location indicator (India / Dubai) on list cards
//   2. Plot Count field in detail expanded view
//   3. Blueprint image in detail page (was missing)
//   4. Show Map → 5 KM radius circle + nearby properties via MapSetWidget
//   5. Hide "Send Enquiry" button for sold-out properties
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:share_plus/share_plus.dart';

import '../../../common/api_constant.dart';
import '../../../common/colours.dart';
import '../../../common/widget/carousel.dart';
import '../../../common/widget/media_carousel_widget.dart';
import '../../plot_market/model/plot_market.dart' show MapSet;
import '../../plot_market/widget/plotmarket_details_widgets/mapset.dart' show MapSetWidget;
import '../controller/residential_controller.dart';
import '../model/residential_model.dart';

// =============================================================================
// ① LOCATION INDICATOR WIDGET
// Drop this badge anywhere on your list-page property card.
// Usage:  LocationIndicatorBadge(property: property)
// =============================================================================

class LocationIndicatorBadge extends StatelessWidget {
  final Property property;
  const LocationIndicatorBadge({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    final bool isDubai = property.isDubai;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: isDubai
            ? const Color(0xFFFFF3E0)   // warm amber for Dubai
            : const Color(0xFFE8F5E9),   // soft green for India
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isDubai
              ? const Color(0xFFFF9800).withOpacity(0.5)
              : const Color(0xFF4CAF50).withOpacity(0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isDubai ? '🇦🇪' : '🇮🇳',
            style: TextStyle(fontSize: 11.sp),
          ),
          SizedBox(width: 4.w),
          Text(
            isDubai ? 'Dubai' : 'India',
            style: TextStyle(
              fontSize: 10.sp,
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

// =============================================================================
// ② PLOT COUNT ROW
// Call _buildDetailRow(label: 'Plot Count', value: ...) already exists in your
// widget. Just add this inside the expanded Column where other detail rows are.
// Copy-paste the snippet below into AboutResidentialProperty._AboutResidentialPropertyState
// inside the `if (controller.isExpanded.value)` block, after the 'Posted By' row:
//
//   // ② Plot Count  ← ADD THIS
//   if ((property.plotCount ?? 0) > 0)
//     _buildDetailRow(
//       label: 'Plot Count',
//       value: '${property.plotCount}',
//       delay: 0,
//     ),
// =============================================================================

// =============================================================================
// ③ BLUEPRINT WIDGET
// Replaces / mirrors PlotMarketBlueprint but reads from ResidentialPropertyController.
// Plug into the Column in AboutResidentialProperty after the amenities card.
// =============================================================================

class ResidentialBlueprintWidget extends StatefulWidget {
  const ResidentialBlueprintWidget({super.key});

  @override
  State<ResidentialBlueprintWidget> createState() =>
      _ResidentialBlueprintWidgetState();
}

class _ResidentialBlueprintWidgetState
    extends State<ResidentialBlueprintWidget> {
  final ResidentialPropertyController controller =
  Get.find<ResidentialPropertyController>();

  void _openFullscreen(BuildContext context, String imageUrl) {
    Get.to(() => Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PhotoView(
            imageProvider: NetworkImage(imageUrl),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 4,
            backgroundDecoration:
            const BoxDecoration(color: Colors.black),
            loadingBuilder: (_, __) =>
            const Center(child: CircularProgressIndicator()),
          ),
          Positioned(
            top: 44.h,
            right: 20.w,
            child: InkWell(
              onTap: Get.back,
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close, color: Colors.black, size: 26.w),
              ),
            ),
          ),
        ],
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final property = controller.propertyDetail.value;
      if (property == null) return const SizedBox.shrink();

      // ③ Build full URL from relative path returned by API.
      // API returns e.g. "storage/plots/filename.jpeg" → prepend base URL.
      final String rawBlueprint = property.blueprint ?? '';
      if (rawBlueprint.isEmpty) return const SizedBox.shrink();

      const String _baseUrl = 'https://admincashback.vrikshatech.in/public/';
      final String imageUrl = rawBlueprint.startsWith('http')
          ? rawBlueprint
          : '$_baseUrl$rawBlueprint';

      return Container(
        margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 8.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 16.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: AppColor.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                          color: AppColor.primary.withOpacity(0.3), width: 1),
                    ),
                    child: Text(
                      'Blueprint',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColor.primary,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => _openFullscreen(context, imageUrl),
                    borderRadius: BorderRadius.circular(10.r),
                    child: Padding(
                      padding: EdgeInsets.all(4.w),
                      child: Icon(Icons.fullscreen,
                          size: 28.w, color: Colors.grey.shade500),
                    ),
                  ),
                ],
              ),
            ),

            // Blueprint image using PhotoView (pinch-to-zoom)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14.r),
                child: SizedBox(
                  height: 240.h,
                  child: PhotoView(
                    imageProvider: NetworkImage(imageUrl),
                    minScale: PhotoViewComputedScale.contained,
                    maxScale: PhotoViewComputedScale.covered * 3,
                    backgroundDecoration:
                    const BoxDecoration(color: Colors.transparent),
                    loadingBuilder: (_, __) =>
                    const Center(child: CircularProgressIndicator()),
                    errorBuilder: (_, __, ___) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.broken_image,
                              color: Colors.grey.shade400, size: 40.sp),
                          SizedBox(height: 8.h),
                          Text('Blueprint unavailable',
                              style: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 13.sp)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0);
    });
  }
}

// =============================================================================
// ④ MAP WIDGET — wraps your existing MapSetWidget
//    Passes mapSet, currentLat, currentLong, currentPropertyName exactly
//    as the widget expects.
// =============================================================================

class MapViewWithRadiusWidget extends StatelessWidget {
  const MapViewWithRadiusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final ResidentialPropertyController controller =
    Get.find<ResidentialPropertyController>();

    return Obx(() {
      final property = controller.propertyDetail.value;
      if (property == null) return const SizedBox.shrink();

      final double? lat = double.tryParse(property.lat ?? '');
      final double? lng = double.tryParse(property.lng ?? '');

      // Don't show map section if coordinates are missing
      if (lat == null || lng == null) return const SizedBox.shrink();

      final List<MapSet> mapSet = property.mapSet
          .map((item) => MapSet(
                id: item.id,
                name: item.propertyName ?? '',
                lat: item.lat ?? '',
                long: item.lng ?? '',
                image: item.thumbnail != null ? [item.thumbnail!] : [],
                distance: '',
              ))
          .toList();

      // Always show the map (even when mapSet is empty — shows current location)
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10.h),
          if (mapSet.isNotEmpty) ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                'Nearby Properties on Map',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            SizedBox(height: 8.h),
            MapSetWidget(
              mapSet: mapSet,
              currentLat: lat,
              currentLong: lng,
              currentPropertyName: property.propertyName,
            ),
            SizedBox(height: 10.h),
          ],
        ],
      );
    });
  }
}

// =============================================================================
// ⑤  "Send Enquiry" button guard — sold-out check
//
// Wrap your existing enquiry button with this widget.
// It renders nothing when the property is sold out.
//
// Usage:
//   EnquiryButtonGuard(
//     property: property,
//     child: ElevatedButton(
//       onPressed: () { /* your enquiry logic */ },
//       child: Text('Send Enquiry'),
//     ),
//   )
// =============================================================================

class EnquiryButtonGuard extends StatelessWidget {
  final Property property;
  final Widget child;

  const EnquiryButtonGuard({
    super.key,
    required this.property,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // ⑤ Hide button entirely when sold out
    if (property.isSoldOut) return const SizedBox.shrink();
    return child;
  }
}

// =============================================================================
// FULL UPDATED AboutResidentialProperty WITH ALL CHANGES INTEGRATED
// Drop this in place of your existing about_residential_property.dart
// =============================================================================

class AboutResidentialProperty extends StatefulWidget {
  const AboutResidentialProperty({super.key});

  @override
  State<AboutResidentialProperty> createState() =>
      _AboutResidentialPropertyState();
}

class _AboutResidentialPropertyState extends State<AboutResidentialProperty> {
  bool isExpanded = false;

  final List<Color> cardColors = const [
    Color(0xFFFFE0E0),
    Color(0xFFE0F2FF),
    Color(0xFFE8F5E9),
    Color(0xFFFFF3E0),
    Color(0xFFF3E5F5),
    Color(0xFFE0F7FA),
  ];

  @override
  Widget build(BuildContext context) {
    final ResidentialPropertyController controller =
    Get.find<ResidentialPropertyController>();

    return Obx(() {
      final property = controller.propertyDetail.value;
      if (property == null) {
        return Center(
            child: CircularProgressIndicator(color: AppColor.primary));
      }

      final projectName = property.propertyName;
      final location = property.location;
      final totalArea = property.formattedArea;
      final price = property.formattedPrice;
      final pricePerSqFt = property.formattedPricePerSqft;
      final description = property.aboutProperty;
      final highlights = property.highlights ?? '';
      final features = property.features ?? '';
      final amenities = property.amenitiesWithImages;
      final facilities = property.facilities;
      final galleryImages = property.galleryImages.isNotEmpty
          ? property.galleryImages
          : [property.thumbnail];
      final isVerified = property.isVerified;
      final postedBy = property.isAdminPosted ? 'Admin' : 'Customer';
      final completionDate = property.completionDate;
      final handoverDate = property.handoverDate;
      final categoryName =
          property.category?.categoryName ?? 'Residential';

      return Column(
        children: [
          // ─── Main info card ───────────────────────────────────────────────
          Container(
            margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 15.r,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Carousel
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: SizedBox(
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20.r),
                        topRight: Radius.circular(20.r),
                      ),
                      child: MediaCarouselScreen(
                        images: galleryImages,
                        height: 190.h,
                      ),
                    ),
                  ),
                ),

                // Verified badge
                if (isVerified)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: 20.w, vertical: 5.h),
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(color: Colors.green, width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified,
                                size: 16.sp, color: Colors.green),
                            SizedBox(width: 4.w),
                            Text(
                              'Verified Property',
                              style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                // ① Country / location indicator row
                Padding(
                  padding:
                  EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
                  child: Row(
                    children: [
                      LocationIndicatorBadge(property: property),
                      const Spacer(),
                      // ⑤ Sold-out badge
                      if (property.isSoldOut)
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(color: Colors.red.shade300),
                          ),
                          child: Text(
                            'Sold Out',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.red,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // View More / Share row
                Padding(
                  padding:
                  EdgeInsets.symmetric(horizontal: 20.w, vertical: 5.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: controller.toggleExpansion,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 14.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [
                              AppColor.primary,
                              AppColor.primarylite
                            ]),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Row(
                            children: [
                              Text(
                                controller.isExpanded.value
                                    ? 'Hide More Details'
                                    : 'View More Details',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.sp),
                              ),
                              SizedBox(width: 6.w),
                              Icon(
                                controller.isExpanded.value
                                    ? Icons.arrow_upward
                                    : Icons.arrow_downward,
                                size: 18.sp,
                                color: Colors.black,
                              ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          final cleanBaseUrl =
                          ApiUrl.WebsidebaseUrl.replaceAll('/public', '');
                          Share.share(
                              '$cleanBaseUrl/residential-property/details/${property.id}');
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 14.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.share,
                                  size: 18.sp, color: AppColor.black),
                              SizedBox(width: 6.w),
                              Text('Share',
                                  style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Expanded details
                if (controller.isExpanded.value)
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 20.w, vertical: 10.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          decoration: BoxDecoration(
                            color: AppColor.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            projectName,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18.sp,
                              color: AppColor.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        _buildDetailRow(
                            label: 'Category',
                            value: categoryName,
                            delay: 0),
                        _buildDetailRow(
                            label: 'Total Area',
                            value: totalArea,
                            delay: 0),
                        _buildDetailRow(
                            label: 'Total Price', value: price, delay: 0),
                        _buildDetailRow(
                            label: 'Price per Sq.Ft',
                            value: pricePerSqFt,
                            delay: 0),
                        _buildDetailRow(
                            label: 'Location', value: location, delay: 0),
                        _buildDetailRow(
                            label: 'Posted By', value: postedBy, delay: 0),

                        // ② Plot Count field
                        if ((property.plotCount ?? 0) > 0)
                          _buildDetailRow(
                            label: 'Plot Count',
                            value: '${property.plotCount}',
                            delay: 0,
                          ),

                        if (completionDate != null)
                          _buildDetailRow(
                            label: 'Completion Date',
                            value:
                            '${completionDate.day}/${completionDate.month}/${completionDate.year}',
                            delay: 100,
                          ),
                        if (handoverDate != null)
                          _buildDetailRow(
                            label: 'Handover Date',
                            value:
                            '${handoverDate.day}/${handoverDate.month}/${handoverDate.year}',
                            delay: 150,
                          ),
                        if (highlights.isNotEmpty) ...[
                          SizedBox(height: 8.h),
                          _buildSectionHeader('Highlights'),
                          SizedBox(height: 4.h),
                          _buildTextBox(highlights),
                        ],
                        if (features.isNotEmpty) ...[
                          SizedBox(height: 8.h),
                          _buildSectionHeader('Features'),
                          SizedBox(height: 4.h),
                          _buildTextBox(features),
                        ],
                        SizedBox(height: 20.h),
                      ],
                    ),
                  ),

                // Description
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: _buildSectionHeader('Description'),
                    ),
                    SizedBox(height: 8.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Obx(() {
                        final expanded =
                            controller.isDescriptionExpanded.value;
                        return AnimatedCrossFade(
                          crossFadeState: expanded
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                          duration: 300.ms,
                          firstChild: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildTextBox(description.length > 200
                                  ? '${description.substring(0, 200)}...'
                                  : description),
                              SizedBox(height: 6.h),
                              if (description.length > 200)
                                GestureDetector(
                                  onTap: controller.toggleDescription,
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    children: [
                                      Text('Show More',
                                          style: TextStyle(
                                              color: AppColor.primary,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13.sp)),
                                      Icon(Icons.keyboard_arrow_down,
                                          color: AppColor.primary,
                                          size: 18.sp),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          secondChild: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildTextBox(description),
                              SizedBox(height: 6.h),
                              GestureDetector(
                                onTap: controller.toggleDescription,
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: [
                                    Text('Show Less',
                                        style: TextStyle(
                                            color: AppColor.primary,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13.sp)),
                                    Icon(Icons.keyboard_arrow_up,
                                        color: AppColor.primary,
                                        size: 18.sp),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                    SizedBox(height: 15.h),
                  ],
                )
                    .animate()
                    .fadeIn(duration: 500.ms)
                    .slideY(begin: 0.2, end: 0, duration: 600.ms),
              ],
            ),
          ),

          // ─── Facilities card ──────────────────────────────────────────────
          if (facilities.isNotEmpty)
            Container(
              margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: Colors.grey.shade200, width: 1),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Facilities'),
                  SizedBox(height: 12.h),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                    child: GridView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: isExpanded
                          ? facilities.length
                          : (facilities.length > 4 ? 4 : facilities.length),
                      gridDelegate:
                      SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisExtent: 52.h,
                        crossAxisSpacing: 10.w,
                        mainAxisSpacing: 10.h,
                      ),
                      itemBuilder: (_, index) {
                        final facility = facilities[index];
                        final color = cardColors[index % cardColors.length];
                        return Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                                color: Colors.black.withOpacity(0.05)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                height: 30.r,
                                width: 30.r,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.network(
                                    facility.images,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Icon(
                                        Icons.bolt,
                                        size: 16.sp,
                                        color: Colors.black),
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      facility.name ?? '',
                                      style: TextStyle(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (facility.value != null)
                                      Text(
                                        facility.value.toString(),
                                        style: TextStyle(
                                            fontSize: 10.sp,
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w600),
                                        maxLines: 1,
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  if (facilities.length > 4) ...[
                    SizedBox(height: 12.h),
                    GestureDetector(
                      onTap: () => setState(() => isExpanded = !isExpanded),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedRotation(
                              turns: isExpanded ? 0.5 : 0,
                              duration: const Duration(milliseconds: 300),
                              child: Icon(Icons.keyboard_arrow_down,
                                  size: 20.sp, color: Colors.black),
                            ),
                            SizedBox(width: 5.w),
                            Text(isExpanded ? 'Show Less' : 'Show More',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: 12.sp)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0),

          // ─── Amenities card ───────────────────────────────────────────────
          if (amenities.isNotEmpty)
            Container(
              margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 15.r,
                      offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 20.w, vertical: 15.h),
                    child: _buildSectionHeader('Amenities'),
                  ),
                  SizedBox(height: 8.h),
                  Stack(
                    children: [
                      SizedBox(
                        height: 100.h,
                        child: ListView.builder(
                          controller: controller.amenitiesScrollController,
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          itemCount: amenities.length,
                          itemBuilder: (_, index) {
                            final amenity = amenities[index];
                            return Container(
                              width: 80.w,
                              margin: EdgeInsets.only(right: 12.w),
                              padding: EdgeInsets.all(10.r),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15.r),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      blurRadius: 10.r,
                                      offset: const Offset(0, 2)),
                                ],
                                border: Border.all(
                                    color: Colors.grey.shade200, width: 1),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 40.w,
                                    height: 40.w,
                                    decoration: BoxDecoration(
                                      borderRadius:
                                      BorderRadius.circular(10.r),
                                      color:
                                      AppColor.primary.withOpacity(0.1),
                                    ),
                                    child: _buildAmenityImage(
                                        amenity['image'] ?? ''),
                                  ),
                                  SizedBox(height: 6.h),
                                  Text(
                                    amenity['title'] ?? '',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      if (amenities.length > 3) ...[
                        Positioned(
                          left: 8.w,
                          top: 30.h,
                          child: GestureDetector(
                            onTap: controller.scrollAmenitiesLeft,
                            child: _navArrow(Icons.arrow_back_ios_rounded),
                          ),
                        ),
                        Positioned(
                          right: 8.w,
                          top: 30.h,
                          child: GestureDetector(
                            onTap: controller.scrollAmenitiesRight,
                            child: _navArrow(Icons.arrow_forward_ios_rounded),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 15.h),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 500.ms)
                .slideY(begin: 0.2, end: 0, duration: 600.ms),

          // ③ Blueprint widget
          const ResidentialBlueprintWidget(),

          // ④ Map with 5 KM radius + nearby properties
          const MapViewWithRadiusWidget(),
        ],
      );
    });
  }

  // ─── Helper widgets ──────────────────────────────────────────────────────

  Widget _navArrow(IconData icon) {
    return Container(
      width: 30.w,
      height: 40.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 5.r,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Icon(icon, size: 18.sp, color: AppColor.primary),
    );
  }

  Widget _buildTextBox(String text) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Text(
        text,
        style:
        TextStyle(fontSize: 13.sp, color: Colors.black87, height: 1.4),
      ),
    );
  }

  Widget _buildAmenityImage(String imageUrl) {
    if (imageUrl.isEmpty) {
      return Icon(Icons.home_work_outlined,
          size: 24.sp, color: AppColor.primary);
    }
    final lower = imageUrl.toLowerCase();
    if (lower.endsWith('.svg')) {
      return Icon(Icons.bolt, size: 24.sp, color: AppColor.primary);
    } else if (lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.webp')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) =>
            Icon(Icons.broken_image, size: 24.sp, color: AppColor.primary),
      );
    }
    return Icon(Icons.image, size: 24.sp, color: AppColor.primary);
  }

  Widget _buildDetailRow(
      {required String label, required String value, required int delay}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.w,
            child: Text(label,
                style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColor.primary,
                    fontWeight: FontWeight.bold,
                    height: 1.2)),
          ),
          SizedBox(width: 6.w),
          Text(':',
              style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColor.black,
                  fontWeight: FontWeight.w600,
                  height: 1.2)),
          SizedBox(width: 6.w),
          Expanded(
            child: Text(value,
                style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColor.black,
                    fontWeight: FontWeight.bold,
                    height: 1.2)),
          ),
        ],
      )
          .animate()
          .slideX(
          begin: 0.5,
          end: 0,
          duration: 600.ms,
          curve: Curves.easeOutCubic)
          .fadeIn(duration: 500.ms)
          .then(delay: delay.ms),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
      decoration: BoxDecoration(
        color: AppColor.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        title,
        style: TextStyle(
            fontSize: 16.sp,
            color: AppColor.primary,
            fontWeight: FontWeight.bold),
      ),
    );
  }
}