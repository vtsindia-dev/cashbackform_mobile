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
  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final detail = controller.marketDetail.value;

      if (detail == null) {
        return const Center(child: CircularProgressIndicator());
      }

      final String uldNo = detail.uldNo.isNotEmpty ? detail.uldNo : "-";
      final String address = detail.address.isNotEmpty ? detail.address : "-";
      final String mapUrl = detail.map ?? "";
      final List<Amenity> amenities = detail.amenities;

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
            _buildHeaderWithMap(mapUrl)
                .animate()
                .fadeIn(duration: 500.ms)
                .slideY(begin: 0.3, end: 0, duration: 500.ms),
            15.h.verticalSpace,
            _buildAmenitiesSection(amenities)
                .animate()
                .fadeIn(duration: 600.ms)
                .slideY(begin: 0.3, end: 0, duration: 600.ms),
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

  Widget _buildHeaderWithMap(String mapUrl) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Around This Plot ",
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
              color: AppColor.textMain,
            ),
          ),
          GestureDetector(
            onTap: () async {
              if (mapUrl.isNotEmpty) {
                await launchUrl(Uri.parse(mapUrl),
                    mode: LaunchMode.externalApplication);
              } else {
                Get.snackbar("No Map URL", "Map link not provided");
              }
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColor.primary.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                "View more on maps",
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          )
              .animate()
              .fadeIn(duration: 600.ms)
              .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1))
              .then()
              .shimmer(duration: 800.ms, color: Colors.white.withOpacity(0.3)),
        ],
      ),
    );
  }

  Widget _buildAmenitiesSection(List<Amenity> amenities) {
    if (amenities.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Text(
          "No amenities available",
          style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
        ),
      );
    }

    return SizedBox(
      height: 70.h,
      child: Row(
        children: [
          _buildArrowButton(isRight: false),
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              itemCount: amenities.length,
              itemBuilder: (context, index) {
                final amenity = amenities[index];
                return _buildAmenityCard(amenity)
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
          _buildArrowButton(isRight: true),
        ],
      ),
    );
  }

  Widget _buildAmenityCard(Amenity amenity) {
    return Container(
      width: 140.w,
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(8.w),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: amenity.image.isNotEmpty
                ? Image.network(
              amenity.image,
              width: 32.w,
              height: 32.h,
              fit: BoxFit.contain,
            )
                : Icon(
              Icons.category_outlined,
              size: 24.sp,
              color: Colors.grey,
            ),
          ),
          6.w.horizontalSpace,
          Expanded(
            child: Text(
              amenity.title ?? "",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.bold,
                color: AppColor.textMain,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArrowButton({required bool isRight}) {
    return GestureDetector(
      onTap: () {
        final scrollAmount = 150.0;
        if (isRight) {
          scrollController.animateTo(
            scrollController.offset + scrollAmount,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        } else {
          scrollController.animateTo(
            scrollController.offset - scrollAmount,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      },
      child: Container(
        width: 40.w,
        height: 40.w,
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        decoration: BoxDecoration(
          color: AppColor.primary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          isRight ? Icons.arrow_forward : Icons.arrow_back,
          size: 18.sp,
          color: AppColor.primary,
        ),
      )
          .animate()
          .scale(
        duration: 500.ms,
        curve: Curves.easeInOutBack,
      )
          .shimmer(duration: 800.ms, color: Colors.white.withOpacity(0.2)),
    );
  }
}
