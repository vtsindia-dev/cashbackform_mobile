import 'package:cashback_farms/features/gioo_plots/controller/gioo_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../../../common/api_constant.dart';
import '../../../common/colours.dart';
import '../../../common/widget/carousel.dart';
import '../../../common/widget/media_carousel_widget.dart';

class AboutGiooPlot extends StatelessWidget {
  const AboutGiooPlot({super.key});

  @override
  Widget build(BuildContext context) {
    final GiooPlotController controller = Get.find<GiooPlotController>();

    return Obx(() {
      final detail = controller.giooPlotDetail.value;
      final projectName = detail?.name ?? 'No Name';
      final location = detail?.address ?? 'No Address';
      final totalLayout = detail?.area ?? 'No Area';
      final plotCount = '${detail?.unitSpilt ?? 0} Residential Plots';
      final pricePerSqFt = '₹ ${detail?.price ?? '0'} per Sq.Ft';
      final status = detail?.work ?? 'No Status';
      final totalArea = "${detail?.area} Sq.Ft";
      final ulpin = detail?.uldNo ?? '';
      final totalPrize = "₹  ${detail?.totalPrice}";
      final images = detail?.images.isNotEmpty == true
          ? detail!.images
          : [
        "http://192.168.1.114/admincashback/public/uploads/property/1764237164_Group%201597885062.png",
      ];
      final description = detail?.description ?? 'No description available';
      final plotType = detail?.propertyType?.categoryName;

      // Check sold status
      final isSoldOut = detail?.soldStatus == 1;

      return Container(
        margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
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
            /// Image Section with Sold Out Badge
            Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Container(
                    height: 200.h,
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
                      child: MediaCarouselScreen(images: images, height: 172.h),
                    ),
                  ),
                ),

                /// Sold Out Badge
                if (isSoldOut)
                  Positioned(
                    top: 16.h,
                    right: 16.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.red, Colors.redAccent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.3),
                            blurRadius: 8.r,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.shopping_cart,
                            size: 14.sp,
                            color: Colors.white,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            "SOLD OUT",
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                /// SHARE BUTTON
                Padding(
                  padding: EdgeInsets.only(right: 12.w, left: 8.w),
                  child: GestureDetector(
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
                                ? 'Hide Details'
                                : 'View Details',
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
                ),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.w),
                  child: GestureDetector(
                    onTap: () {
                      final cleanBaseUrl =
                      ApiUrl.WebsidebaseUrl.replaceAll('/public', '');

                      Share.share(
                        '$cleanBaseUrl/gioo-plots/details/${detail?.id ?? ''}',
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
                          Icon(Icons.share, size: 18.sp, color: AppColor.black),
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
                ),
              ],
            ),

            AnimatedContainer(
              duration: 400.ms,
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              height: controller.isExpanded.value ? null : 0,
              child: controller.isExpanded.value
                  ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 6.h),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 8.h),
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
                          .then(delay: 0.ms)
                          .shimmer(
                        duration: 800.ms,
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                  ),

                  if (plotType != null) ...[
                    SizedBox(height: 8.h),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 5.h),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 110.w,
                            child: Text(
                              'Plot Type',
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
                              plotType,
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
                      ).then(delay: 200.ms)
                          .shimmer(
                        duration: 800.ms,
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                  ],

                  SizedBox(height: 8.h),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 5.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 110.w,
                          child: Text(
                            'Plot Area',
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
                            totalArea,
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
                        .then(delay: 200.ms)
                        .shimmer(
                      duration: 800.ms,
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),

                  SizedBox(height: 8.h),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 5.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 110.w,
                          child: Text(
                            'Price per Sq.Ft',
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
                            pricePerSqFt,
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
                        .then(delay: 400.ms)
                        .shimmer(
                      duration: 800.ms,
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),

                  SizedBox(height: 8.h),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 5.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 110.w,
                          child: Text(
                            'Total Price',
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
                            totalPrize,
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
                        .then(delay: 400.ms)
                        .shimmer(
                      duration: 800.ms,
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),

                  SizedBox(height: 8.h),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 5.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 110.w,
                          child: Text(
                            'Location',
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
                            location,
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
                        .then(delay: 100.ms)
                        .shimmer(
                      duration: 800.ms,
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),

                  SizedBox(height: 8.h),
                  Obx(() {
                    final isExpanded = controller.isDescriptionExpanded.value;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColor.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            "Description",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 17.sp,
                              color: AppColor.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        AnimatedCrossFade(
                          crossFadeState: isExpanded
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                          duration: 300.ms,
                          firstChild: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                description.length > 120
                                    ? "${description.substring(0, 120)}..."
                                    : description,
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  height: 1.3,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 6.h),
                              GestureDetector(
                                onTap: controller.toggleDescription,
                                child: Text(
                                  "Show More",
                                  style: TextStyle(
                                    color: AppColor.primary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          secondChild: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                description,
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  height: 1.3,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 6.h),
                              GestureDetector(
                                onTap: controller.toggleDescription,
                                child: Text(
                                  "Show Less",
                                  style: TextStyle(
                                    color: AppColor.primary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                        .animate()
                        .slideY(begin: 0.2, end: 0, duration: 600.ms)
                        .fadeIn(duration: 500.ms);
                  }),
                  SizedBox(height: 10.h),
                ],
              )
                  : const SizedBox(),
            ),
          ],
        ),
      );
    });
  }
}