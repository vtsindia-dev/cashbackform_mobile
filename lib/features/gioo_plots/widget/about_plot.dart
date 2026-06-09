import 'package:cashback_farms/features/gioo_plots/controller/gioo_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../common/api_constant.dart';
import '../../../common/colours.dart';
import '../../../common/widget/carousel.dart';
import '../../../common/widget/media_carousel_widget.dart';
import '../../../common/widget/share_action_button_widget.dart';
import '../../../common/widget/view_on_map_button.dart';

class AboutGiooPlot extends StatelessWidget {
   AboutGiooPlot({super.key});
  final GiooPlotController controller = Get.find<GiooPlotController>();
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

  @override
  Widget build(BuildContext context) {
    final GiooPlotController controller = Get.find<GiooPlotController>();

    return Obx(() {
      final detail = controller.giooPlotDetail.value;
      final projectName = detail?.name ?? 'No Name';
      final location = detail?.address ?? 'No Address';
      final pricePerSqFt = '₹ ${detail?.price ?? '0'} per Sq.Ft';
      final totalArea = "${detail?.area} Sq.Ft";
      final totalPrize = "₹  ${detail?.totalPrice}";
      final youtubeLink = detail?.youtubeLink;
      final images = detail?.images.isNotEmpty == true
          ? detail!.images
          : [
        "http://192.168.1.114/admincashback/public/uploads/property/1764237164_Group%201597885062.png",
      ];
      final description = detail?.description ?? 'No description available';
      final plotType = detail?.propertyType?.categoryName;

      // Check sold status
      final isSoldOut = detail?.soldStatus == 1;
      final String uldNo = detail?.uldNo ?? "-";
      final String address = detail?.address ?? "-";

      final cleanBaseUrl =
      ApiUrl.webSideBaseUrl.replaceAll('/public', '');

      final shareUrl =
          '$cleanBaseUrl/gioo-plots/details/${detail?.id}';

      return Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha:0.3),
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
                              color: Colors.white.withValues(alpha:0.4),
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
                                color: Colors.red.withValues(alpha:0.3),
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
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
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
                        if (detail?.share != null &&
                            detail!.share!.isNotEmpty) ...[
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
                ),
                Padding(
                  padding:  EdgeInsets.symmetric(horizontal: 10.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 6.h),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          decoration: BoxDecoration(
                            color: AppColor.primary.withValues(alpha:0.1),
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
                            color: Colors.white.withValues(alpha:0.3),
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
                              SizedBox(
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
                            color: Colors.white.withValues(alpha:0.3),
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
                          color: Colors.white.withValues(alpha:0.3),
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
                          color: Colors.white.withValues(alpha:0.3),
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
                          color: Colors.white.withValues(alpha:0.3),
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
                          color: Colors.white.withValues(alpha:0.3),
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
                                color: AppColor.primary.withValues(alpha:0.1),
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
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: AppColor.backgroundLight.withValues(alpha: 0.5),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 10.h),
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
                            if (detail?.lat != null || detail?.long != null) ...[
                              4.h.verticalSpace,
                              Text(
                                "Coordinates: ${detail?.lat ?? '-'}, ${detail?.long ?? '-'}",
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
                SizedBox(height: 10.h,),
                Padding(
                  padding:  EdgeInsets.symmetric(horizontal: 15.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () => _launchGoogleMaps(
                          detail?.lat,
                          detail?.long,
                        ),
                        child: ViewOnMapButton(
                          onTap: () => _launchGoogleMaps(
                            detail?.lat,
                            detail?.long,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10.h,),

              ],
            ),
          ),
        ],
      );
    });
  }
}