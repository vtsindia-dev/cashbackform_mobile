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

class AboutGiooPlot extends StatelessWidget {
  const AboutGiooPlot({super.key});

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

      return Container(
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
                          final url = detail.share ?? '';
                          final whatsappUrl = Uri.parse(
                            "https://wa.me/?text=${Uri.encodeComponent(url)}",
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
                          final cleanBaseUrl =
                          ApiUrl.webSideBaseUrl.replaceAll('/public', '');
                          Share.share(
                            '$cleanBaseUrl/gioo-plots/details/${detail?.id}',
                          );
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
            )
          ],
        ),
      );
    });
  }
}