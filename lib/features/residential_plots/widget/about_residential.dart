import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../../../common/api_constant.dart';
import '../../../common/colours.dart';
import '../../../common/widget/carousel.dart';
import '../controller/residential_controller.dart';

class AboutResidentialProperty extends StatefulWidget {
  const AboutResidentialProperty({super.key});

  @override
  State<AboutResidentialProperty> createState() =>
      _AboutResidentialPropertyState();
}

class _AboutResidentialPropertyState extends State<AboutResidentialProperty> {
  bool isExpanded = false;
  final List<Color> cardColors =  [
    const Color(0xFFFFE0E0), // Soft Red
    const Color(0xFFE0F2FF), // Soft Blue
    const Color(0xFFE8F5E9), // Soft Green
    const Color(0xFFFFF3E0), // Soft Orange
    const Color(0xFFF3E5F5), // Soft Purple
    const Color(0xFFE0F7FA), // Soft Cyan
  ];

  @override
  Widget build(BuildContext context) {
    final ResidentialPropertyController controller =
        Get.find<ResidentialPropertyController>();

    return Obx(() {
      final property = controller.propertyDetail.value;
      if (property == null) {
        return Center(
          child: CircularProgressIndicator(color: AppColor.primary),
        );
      }

      final projectName = property.propertyName;
      final location = property.location;
      final totalArea = property.formattedArea;
      final price = property.formattedPrice;
      final pricePerSqFt = property.formattedPricePerSqft;
      final status = property.status ?? 'Not Specified';
      final description = property.aboutProperty;
      final transactionType = property.transactionType == 'new'
          ? 'New Property'
          : 'Resale';
      final ownership = property.ownership ?? 'Freehold';
      final facing = property.facing ?? 'Not Specified';
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
      final categoryName = property.category?.categoryName ?? 'Residential';

      return Column(
        children: [
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
                // Carousel Section
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Container(
                    height: 190.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20.r),
                        topRight: Radius.circular(20.r),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.4),
                          blurRadius: 8.r,
                          spreadRadius: 2.r,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20.r),
                        topRight: Radius.circular(20.r),
                      ),
                      child: CarouselWidget(
                        images: galleryImages,
                        height: 172.h,
                        autoPlayDuration: const Duration(seconds: 3),
                        borderRadius: 20.r,
                      ),
                    ),
                  ),
                ),

                // Verified Badge
                if (isVerified)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 5.h,
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(color: Colors.green, width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified,
                              size: 16.sp,
                              color: Colors.green,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              'Verified Property',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 5.h,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // View/Hide MORE Details Button
                      GestureDetector(
                        onTap: controller.toggleExpansion,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColor.primary, AppColor.primarylite],
                            ),
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
                                  fontSize: 14.sp,
                                ),
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

                      // Share Button
                      GestureDetector(
                        onTap: () {
                          final cleanBaseUrl = ApiUrl.WebsidebaseUrl.replaceAll(
                            '/public',
                            '',
                          );
                          Share.share(
                            '$cleanBaseUrl/residential-property/details/${property.id}',
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.share,
                                size: 18.sp,
                                color: AppColor.black,
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                "Share",
                                style: TextStyle(
                                  fontSize: 13.sp,
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
                if (controller.isExpanded.value)
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 10.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Project Name
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
                              height: 1.2,
                            ),
                          ),
                        ),
                        SizedBox(height: 8.h),

                        // Category
                        _buildDetailRow(
                          label: 'Category',
                          value: categoryName,
                          delay: 0,
                        ),

                        // // Status
                        // _buildDetailRow(
                        //   label: 'Status',
                        //   value: status,
                        //   delay: 0,
                        // ),

                        // Property Type
                        // _buildDetailRow(
                        //   label: 'Property Type',
                        //   value: transactionType,
                        //   delay: 0,
                        // ),

                        // Area
                        _buildDetailRow(
                          label: 'Total Area',
                          value: totalArea,
                          delay: 0,
                        ),

                        // Price
                        _buildDetailRow(
                          label: 'Total Price',
                          value: price,
                          delay: 0,
                        ),

                        // Price per Sq.Ft
                        _buildDetailRow(
                          label: 'Price per Sq.Ft',
                          value: pricePerSqFt,
                          delay: 0,
                        ),

                        // Location
                        _buildDetailRow(
                          label: 'Location',
                          value: location,
                          delay: 0,
                        ),

                        // Posted By
                        _buildDetailRow(
                          label: 'Posted By',
                          value: postedBy,
                          delay: 0,
                        ),
                        // if (ownership.isNotEmpty)
                        //   _buildDetailRow(
                        //     label: 'Ownership',
                        //     value: ownership,
                        //     delay: 0,
                        //   ),
                        //
                        // // Facing
                        // if (facing.isNotEmpty)
                        //   _buildDetailRow(
                        //     label: 'Facing',
                        //     value: facing,
                        //     delay: 50,
                        //   ),

                        // Completion Date
                        if (completionDate != null)
                          _buildDetailRow(
                            label: 'Completion Date',
                            value:
                                '${completionDate.day}/${completionDate.month}/${completionDate.year}',
                            delay: 100,
                          ),

                        // Handover Date
                        if (handoverDate != null)
                          _buildDetailRow(
                            label: 'Handover Date',
                            value:
                                '${handoverDate.day}/${handoverDate.month}/${handoverDate.year}',
                            delay: 150,
                          ),

                        // Highlights Section
                        if (highlights.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 8.h),
                              _buildSectionHeader('Highlights'),
                              SizedBox(height: 4.h),
                              Container(
                                padding: EdgeInsets.all(12.r),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                  ),
                                ),
                                child: Text(
                                  highlights,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: Colors.black87,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),

                        // Features Section
                        if (features.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 8.h),
                              _buildSectionHeader('Features'),
                              SizedBox(height: 4.h),
                              Container(
                                padding: EdgeInsets.all(12.r),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                  ),
                                ),
                                child: Text(
                                  features,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: Colors.black87,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),

                        SizedBox(height: 20.h),
                      ],
                    ),
                  ),

                // Action Buttons Row (Now for View/Hide MORE Details)

                // DESCRIPTION SECTION (Always Visible - Expandable)
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
                            final isExpanded =
                                controller.isDescriptionExpanded.value;

                            return AnimatedCrossFade(
                              crossFadeState: isExpanded
                                  ? CrossFadeState.showSecond
                                  : CrossFadeState.showFirst,
                              duration: 300.ms,
                              firstChild: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(12.r),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(12.r),
                                      border: Border.all(
                                        color: Colors.grey.shade200,
                                      ),
                                    ),
                                    child: Text(
                                      description.length > 200
                                          ? "${description.substring(0, 200)}..."
                                          : description,
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        height: 1.4,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 6.h),
                                  description.length > 200 ?
                                  GestureDetector(
                                    onTap: controller.toggleDescription,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Show More",
                                          style: TextStyle(
                                            color: AppColor.primary,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13.sp,
                                          ),
                                        ),
                                        Icon(
                                          Icons.keyboard_arrow_down,
                                          color: AppColor.primary,
                                          size: 18.sp,
                                        ),
                                      ],
                                    ),
                                  ) : Container(),
                                ],
                              ),
                              secondChild: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(12.r),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(12.r),
                                      border: Border.all(
                                        color: Colors.grey.shade200,
                                      ),
                                    ),
                                    child: Text(
                                      description,
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        height: 1.4,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 6.h),
                                  GestureDetector(
                                    onTap: controller.toggleDescription,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Show Less",
                                          style: TextStyle(
                                            color: AppColor.primary,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13.sp,
                                          ),
                                        ),
                                        Icon(
                                          Icons.keyboard_arrow_up,
                                          color: AppColor.primary,
                                          size: 18.sp,
                                        ),
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

                // Expandable Content (OTHER DETAILS - Only shows additional info)
              ],
            ),
          ),

          // 2. UI Code:
          if (facilities != null && facilities.isNotEmpty)
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
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Facilities'),
                  SizedBox(height: 12.h),

                  // AnimatedSize handles the container height expansion
                  AnimatedSize(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      // This transition makes items fade in when the list expands
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.1),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: GridView.builder(
                        key: ValueKey<bool>(isExpanded),
                        // Crucial for AnimatedSwitcher
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: isExpanded
                            ? facilities.length
                            : (facilities.length > 4 ? 4 : facilities.length),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisExtent: 52.h,
                          crossAxisSpacing: 10.w,
                          mainAxisSpacing: 10.h,
                        ),
                        itemBuilder: (context, index) {
                          final facility = facilities[index];
                          final Color itemColor =
                          cardColors[index % cardColors.length];

                          return Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w),
                            decoration: BoxDecoration(
                              color: itemColor,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: Colors.black.withOpacity(0.05),
                              ),
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
                                      facility.images ?? '',
                                      fit: BoxFit.cover,
                                      errorBuilder: (c, e, s) => Icon(
                                        Icons.bolt,
                                        size: 16.sp,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        facility.name ?? '',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (facility.value != null)
                                        Text(
                                          facility.value.toString(),
                                          style: TextStyle(
                                            fontSize: 10.sp,
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w600,
                                          ),
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
                            // AnimatedRotation spins the arrow when tapped
                            AnimatedRotation(
                              turns: isExpanded ? 0.5 : 0,
                              duration: const Duration(milliseconds: 300),
                              child: Icon(
                                Icons.keyboard_arrow_down,
                                size: 20.sp,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(width: 5.w),
                            Text(
                              isExpanded ? "Show Less" : "Show More",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 12.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0),
          if (amenities != null && amenities.isNotEmpty)
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 15.h,
                    ),
                    child: _buildSectionHeader('Amenities'),
                  ),
                  SizedBox(height: 8.h),
                  Stack(
                    children: [
                      Container(
                        height: 100.h,
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: ListView.builder(
                          controller: controller.amenitiesScrollController,
                          scrollDirection: Axis.horizontal,
                          itemCount: amenities.length,
                          itemBuilder: (context, index) {
                            final amenity = amenities[index];
                            final imageUrl = amenity['image'] ?? '';
                            final title = amenity['title'] ?? '';

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
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                                border: Border.all(
                                  color: Colors.grey.shade200,
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Amenity Icon/Image - Multi-format support
                                  Container(
                                    width: 40.w,
                                    height: 40.w,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                        10.r,
                                      ),
                                      color: AppColor.primary.withOpacity(
                                        0.1,
                                      ),
                                    ),
                                    child: _buildAmenityImage(imageUrl),
                                  ),
                                  SizedBox(height: 6.h),

                                  // Amenity Title
                                  Text(
                                    title,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),

                      // Left Navigation Arrow
                      if (amenities.length > 3)
                        Positioned(
                          left: 8.w,
                          top: 30.h,
                          child: GestureDetector(
                            onTap: () {
                              controller.scrollAmenitiesLeft();
                            },
                            child: Container(
                              width: 30.w,
                              height: 40.h,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    blurRadius: 5.r,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.arrow_back_ios_rounded,
                                size: 18.sp,
                                color: AppColor.primary,
                              ),
                            ),
                          ),
                        ),

                      // Right Navigation Arrow
                      if (amenities.length > 3)
                        Positioned(
                          right: 8.w,
                          top: 30.h,
                          child: GestureDetector(
                            onTap: () {
                              controller.scrollAmenitiesRight();
                            },
                            child: Container(
                              width: 30.w,
                              height: 40.h,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    blurRadius: 5.r,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 18.sp,
                                color: AppColor.primary,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 15.h),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 500.ms)
                .slideY(begin: 0.2, end: 0, duration: 600.ms),

        ],
      );
    });
  }

  // Helper method to build amenity image with multi-format support
  Widget _buildAmenityImage(String imageUrl) {
    if (imageUrl.isEmpty) {
      return Icon(
        Icons.home_work_outlined,
        size: 24.sp,
        color: AppColor.primary,
      );
    }

    // Check file extension for different formats
    final lowerUrl = imageUrl.toLowerCase();

    if (lowerUrl.endsWith('.svg')) {
      // For SVG files, use an icon or implement SVG rendering
      return Center(
        child: Icon(
          Icons.bolt, // Different icon for SVG
          size: 24.sp,
          color: AppColor.primary,
        ),
      );
    } else if (lowerUrl.endsWith('.png') ||
        lowerUrl.endsWith('.jpg') ||
        lowerUrl.endsWith('.jpeg') ||
        lowerUrl.endsWith('.webp')) {
      // For image files
      return Image.network(
        imageUrl,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                  : null,
              color: AppColor.primary,
              strokeWidth: 2,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.broken_image, size: 24.sp, color: AppColor.primary);
        },
      );
    } else {
      // Unknown format
      return Icon(Icons.image, size: 24.sp, color: AppColor.primary);
    }
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    required int delay,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5.h),
      child:
          Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 120.w,
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColor.primary,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    ':',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColor.black,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColor.black,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              )
              .animate()
              .slideX(
                begin: 0.5,
                end: 0,
                duration: 600.ms,
                curve: Curves.easeOutCubic,
              )
              .fadeIn(duration: 500.ms)
              .scale(
                begin: const Offset(0.9, 0.9),
                end: const Offset(1, 1),
                duration: 600.ms,
                curve: Curves.easeOutBack,
              )
              .then(delay: delay.ms)
              .shimmer(duration: 800.ms, color: Colors.white.withOpacity(0.3)),
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
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
