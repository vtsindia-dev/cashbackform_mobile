// widgets/about_plot.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../common/api_constant.dart';
import '../../../common/colours.dart';
import '../../../common/widget/carousel.dart';
import '../../../common/widget/media_carousel_widget.dart';
import '../../../common/widget/share_action_button_widget.dart';
import '../controller/syndicate_controller.dart';

class AboutPlot extends StatelessWidget {
  const AboutPlot({super.key});

  @override
  Widget build(BuildContext context) {
    final SyndicatePlotController controller =
    Get.find<SyndicatePlotController>();

    return Obx(() {
      final detail = controller.syndicateDetail.value;
      final images = detail?.images.isNotEmpty == true
          ? detail!.images
          : [
        '${ApiUrl.baseUrl}/uploads/property/placeholder.png'
      ];

      return Container(
        margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        padding: EdgeInsets.all(12.w),
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
            _buildCarouselSection(images, detail?.isSoldOut ?? false),
            _buildActionRow(controller, detail),
            SizedBox(height: 10.h),
            _buildExpandableSection(controller, detail),
          ],
        ),
      );
    });
  }

  // ────────────────────────────────────────
  Widget _buildCarouselSection(List<String> images, bool isSoldOut) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Stack(
        children: [
          Container(
            height: 190.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.r),
                topRight: Radius.circular(20.r),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.r),
                topRight: Radius.circular(20.r),
              ),
              child: MediaCarouselScreen(images: images, height: 172.h),
            ),
          ),

          // ✅ Sold-Out overlay banner
          if (isSoldOut)
            Positioned(
              top: 12.h,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                  EdgeInsets.symmetric(horizontal: 20.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: Colors.red.shade700,
                    borderRadius: BorderRadius.circular(30.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.block_rounded,
                          color: Colors.white, size: 14.sp),
                      SizedBox(width: 6.w),
                      Text(
                        'SOLD OUT',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 13.sp,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scaleXY(
                  begin: 1.0,
                  end: 1.05,
                  duration: 800.ms,
                  curve: Curves.easeInOut,
                ),
              ),
            ),

          // ✅ Property type badge (top-right)
          Obx(() {
            final detail = Get.find<SyndicatePlotController>()
                .syndicateDetail
                .value;
            final typeName = detail?.propertyType?.categoryName ?? '';
            if (typeName.isEmpty) return const SizedBox.shrink();
            return Positioned(
              top: 10.h,
              right: 10.w,
              child: Container(
                padding:
                EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: AppColor.primary,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  typeName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }


  Widget _buildActionRow(SyndicatePlotController controller, detail) {
    final youtubeLink = detail?.youtubeLink;

    final cleanBaseUrl =
    ApiUrl.webSideBaseUrl.replaceAll('/public', '');

    final shareUrl =
        '$cleanBaseUrl/gioo-plots/details/${detail?.id}';

    return Container(
      margin: EdgeInsets.symmetric(vertical: 6.h, horizontal: 5.h),
      child: SingleChildScrollView(
        child: Row(
          children: [
            if (youtubeLink != null && youtubeLink.isNotEmpty) ...[
              ActionButtonWidget(
                onTap: () async {
                  final Uri url = Uri.parse(youtubeLink);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(
                      url,
                      mode: LaunchMode.externalApplication,
                    );
                  } else {
                    Get.snackbar(
                      "Failed",
                      "Could not open video link",
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  }
                },
                title: "Watch Video",
                icon: Image.asset(
                  'assets/images/youtube.png',
                  height: 18.h,
                ),
                textColor: Colors.red.shade800,
                borderColor: Colors.red.shade200,
                gradientColors: [
                  Colors.red.shade50,
                  Colors.red.shade100.withValues(alpha: 0.5),
                ],
              ),
            ],
            if (detail?.share != null && detail!.share!.isNotEmpty) ...[
              SizedBox(width: 8.w),
              ActionButtonWidget(
                onTap: () async {
                  final whatsappUrl = Uri.parse(
                    'https://wa.me/?text=${Uri.encodeComponent(shareUrl)}',
                  );

                  if (await canLaunchUrl(whatsappUrl)) {
                    await launchUrl(
                      whatsappUrl,
                      mode: LaunchMode.externalApplication,
                    );
                  }
                },
                title: "WhatsApp",
                icon: Image.asset(
                  'assets/images/whatsapp (1).png',
                  height: 18.h,
                ),
                bgColor: Colors.grey.shade100,
                borderColor: Colors.grey.shade300,
                textColor: Colors.grey.shade800,
              ),
            ],
            if (detail?.id != null) ...[
              SizedBox(width: 8.w),
              ActionButtonWidget(
                onTap: () {
                  Share.share(shareUrl);
                },
                title: "Share",
                icon: Icon(
                  Icons.share_outlined,
                  size: 16.sp,
                  color: AppColor.black.withValues(alpha:0.8),
                ),
                bgColor: Colors.grey.shade100,
                borderColor: Colors.grey.shade300,
                textColor: Colors.grey.shade800,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableSection(
      SyndicatePlotController controller, detail) {
    return AnimatedContainer(
      duration: 400.ms,
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      height: null,
      child: _buildExpandedContent(controller, detail),
    );
  }

  Widget _buildExpandedContent(
      SyndicatePlotController controller, detail) {
    if (detail == null) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        SizedBox(height: 6.h),

        // ── Core details ──
        _buildDetailRow(
            label: 'Property Type',
            value: detail.propertyType?.categoryName ?? 'N/A',
            delay: 0.ms,
            index: 0,
            valueColor: AppColor.primary),
        SizedBox(height: 8.h),
        _buildDetailRow(
            label: 'Project Name',
            value: detail.name,
            delay: 50.ms,
            index: 1),
        SizedBox(height: 8.h),
        _buildDetailRow(
            label: 'Location',
            value: detail.address,
            delay: 100.ms,
            index: 2),
        SizedBox(height: 8.h),
        _buildDetailRow(
            label: 'Total Layout',
            value: detail.area,
            delay: 150.ms,
            index: 3),
        SizedBox(height: 8.h),
        _buildDetailRow(
            label: 'Plot Count',
            value: '${detail.unitSpilt} Plots',
            delay: 200.ms,
            index: 4),
        SizedBox(height: 8.h),
        _buildDetailRow(
            label: 'Price / Sq.Ft',
            value: '₹ ${detail.price} per sq.ft',
            delay: 250.ms,
            index: 5),
        SizedBox(height: 8.h),
        _buildDetailRow(
            label: 'Starting Price',
            value: '₹ ${detail.startingPrice} onwards',
            delay: 300.ms,
            index: 6),
        SizedBox(height: 8.h),
        _buildDetailRow(
            label: 'ULPIN',
            value: detail.uldNo.isNotEmpty ? detail.uldNo : 'Not Available',
            delay: 350.ms,
            index: 7),

        // ── Sold-out status row ──
        if (detail.isSoldOut) ...[
          SizedBox(height: 8.h),
          _buildDetailRow(
            label: 'Availability',
            value: 'SOLD OUT',
            delay: 400.ms,
            index: 8,
            valueColor: Colors.red.shade700,
          ),
        ],

        SizedBox(height: 14.h),
      ],
    );
  }

  // ────────────────────────────────────────
  Widget _buildSectionDivider(String label) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: AppColor.primary,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w700,
            color: AppColor.primary,
            letterSpacing: 1.2,
          ),
        ),
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
    return isProjectName
        ? _buildProjectNameHeader(value, delay)
        : _buildRegularRow(label, value, delay, valueColor);
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

  Widget _buildRegularRow(
      String label, String value, Duration delay, Color? valueColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
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
        Text(':',
            style: TextStyle(
                fontSize: 13.sp,
                color: AppColor.black,
                fontWeight: FontWeight.w600,
                height: 1.2)),
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