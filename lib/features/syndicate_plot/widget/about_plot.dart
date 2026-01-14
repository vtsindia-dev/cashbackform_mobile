import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../../../common/api_constant.dart';
import '../../../common/colours.dart';
import '../../../common/widget/carousel.dart';
import '../controller/syndicate_controller.dart';

class AboutPlot extends StatelessWidget {
  const AboutPlot({super.key});

  @override
  Widget build(BuildContext context) {
    final SyndicatePlotController controller = Get.find<SyndicatePlotController>();

    return Obx(() {
      final detail = controller.syndicateDetail.value;
      final projectName = detail?.name ?? 'No Name';
      final location = detail?.address ?? 'No Address';
      final totalLayout = detail?.area ?? 'No Area';
      final plotCount = '${detail?.unitSpilt ?? 0} Residential Plots';
      final pricePerSqFt = '₹ ${detail?.price ?? '0'} per sq.ft';
      final startingPrice = '₹ ${detail?.startingPrice ?? '0'} onwards';
      final status = detail?.work ?? 'No Status';
      final ulpin = detail?.uldNo ?? 'Not Available';
      final images = detail?.images.isNotEmpty == true ? detail!.images : ["http://192.168.1.114/admincashback/public/uploads/property/1764237164_Group%201597885062.png",];
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
            _buildCarouselSection(images),
            _buildArrowButton(controller),

            Obx(() => _buildExpandableSection(controller,
              projectName: projectName,
              location: location,
              totalLayout: totalLayout,
              // plotCount: plotCount,
              pricePerSqFt: pricePerSqFt,
              startingPrice: startingPrice,
              // status: status,
              ulpin: ulpin,
            )),
          ],
        ),
      );
    });
  }

  Widget _buildCarouselSection(List<String> images) {
    return Padding(
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
            images: images,
            height: 172.h,
            autoPlayDuration: const Duration(seconds: 3),
            borderRadius: 20.r,
          ),
        ),
      ),
    );
  }

  Widget _buildArrowButton(SyndicatePlotController controller) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6.h, horizontal: 5.h),
      child: Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                /// View / Hide Details Button
                GestureDetector(
                  onTap: controller.toggleExpansion,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColor.primary, AppColor.primarylite],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
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

                /// 🔹 SPACE BETWEEN BUTTONS
                SizedBox(width: 12.w),

                /// Share Button
                GestureDetector(
                  onTap: () {
                    if (controller.syndicateDetail.value?.id == null) return;

                    final cleanBaseUrl =
                    ApiUrl.baseUrl.replaceAll('/public', '');

                    final shareUrl =
                        '$cleanBaseUrl/syndicate-plots/details/${controller.syndicateDetail.value!.id}';

                    Share.share(shareUrl);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
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
              ],
            )
        ,
      ),
    );
  }


  Widget _buildExpandableSection(
      SyndicatePlotController controller, {
        required String projectName,
        required String location,
        required String totalLayout,
        // required String plotCount,
        required String pricePerSqFt,
        required String startingPrice,
        // required String status,
        required String ulpin,
      }) {
    return AnimatedContainer(
      duration: 400.ms,
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      height: controller.isExpanded.value ? null : 0,
      child: controller.isExpanded.value
          ? _buildDetailsContent(
        projectName: projectName,
        location: location,
        totalLayout: totalLayout,
        // plotCount: plotCount,
        pricePerSqFt: pricePerSqFt,
        startingPrice: startingPrice,
        // status: status,
        ulpin: ulpin,
      )
          : const SizedBox(),
    );
  }

  Widget _buildDetailsContent({
    required String projectName,
    required String location,
    required String totalLayout,
    // required String plotCount,
    required String pricePerSqFt,
    required String startingPrice,
    // required String status,
    required String ulpin,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 6.h),
        _buildDetailRow(label: 'Project Name', value: projectName, delay: 0.ms, index: 0,),
        SizedBox(height: 8.h),
        _buildDetailRow(label: 'Location', value: location, delay: 100.ms, index: 1,),
        SizedBox(height: 8.h),
        _buildDetailRow(label: 'Total Layout', value: totalLayout, delay: 200.ms, index: 2,),
        // SizedBox(height: 8.h),
        // _buildDetailRow(label: 'Plot Count', value: plotCount, delay: 300.ms, index: 3,),
        SizedBox(height: 8.h),
        _buildDetailRow(label: 'Price per Sq.Ft', value: pricePerSqFt, delay: 400.ms, index: 4,),
        SizedBox(height: 8.h),
        _buildDetailRow(label: 'Starting Price', value: startingPrice, delay: 500.ms, index: 5,),
        // _buildDetailRow(label: 'Status', value: status, delay: 600.ms, index: 6, valueColor: AppColor.secondary,),
        SizedBox(height: 8.h),
        _buildDetailRow(label: 'ULPIN', value: ulpin, delay: 700.ms, index: 7,),
        SizedBox(height: 10.h),
      ],
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    required Duration delay,
    required int index,
    Color? valueColor,
  }) {
    final bool isProjectName = label == 'Project Name';

    return Container(
      padding: EdgeInsets.symmetric(vertical: isProjectName ? 8.h : 5.h),
      child: isProjectName
          ? _buildProjectNameHeader(value, delay)
          : _buildRegularRow(label, value, delay, valueColor),
    );
  }

  Widget _buildProjectNameHeader(String value, Duration delay) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColor.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        value,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 18.sp,
          color: AppColor.primary,
          fontWeight: FontWeight.bold,
          height: 1.2,
        ),
      )
          .animate()
          .slideX(begin: 0.5, end: 0, duration: 600.ms, curve: Curves.easeOutCubic)
          .fadeIn(duration: 500.ms)
          .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1), duration: 600.ms, curve: Curves.easeOutBack)
          .then(delay: delay)
          .shimmer(duration: 800.ms, color: Colors.white.withOpacity(0.3)),
    );
  }

  Widget _buildRegularRow(String label, String value, Duration delay, Color? valueColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 110.w,
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
              color: valueColor ?? AppColor.black,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
        ),
      ],
    )
        .animate()
        .slideX(begin: 0.5, end: 0, duration: 600.ms, curve: Curves.easeOutCubic)
        .fadeIn(duration: 500.ms)
        .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1), duration: 600.ms, curve: Curves.easeOutBack)
        .then(delay: delay)
        .shimmer(duration: 800.ms, color: Colors.white.withOpacity(0.3));
  }
}