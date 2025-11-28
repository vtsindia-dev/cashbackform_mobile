import 'package:cashback_farms/features/gioo_plots/model/gioo_plot.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../common/colours.dart';
import '../controller/gioo_controller.dart';

class NearbyProject extends StatelessWidget {
  NearbyProject({super.key});

  final GiooPlotController controller = Get.find<GiooPlotController>();
  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final detail = controller.giooPlotDetail.value;

      if (detail == null) {
        return const Center(child: CircularProgressIndicator());
      }

      final String uldNo = detail.uldNo ?? "-";
      final String address = detail.address ?? "-";
      final String mapUrl = detail.map ?? "";
      final List<Amenity> amenities = detail.amenity ?? [];

      return Container(
        color: AppColor.backgroundLight.withOpacity(0.5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
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
                      ],
                    ),
                  )
                ],
              ),
            ),

            25.h.verticalSpace,

            // ------------------------------------
            // HEADER (VIEW MORE ON MAP)
            // ------------------------------------
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Around This Plot properties",
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColor.textMain,
                    ),
                  ),

                  // VIEW MAP BUTTON
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
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.w, vertical: 6.h),
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
                  ),
                ],
              ),
            ),

            15.h.verticalSpace,

            // ------------------------------------
            // AMENITIES LIST
            // ------------------------------------
            amenities.isEmpty
                ? Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Text(
                "No amenities available",
                style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600
                ),
              ),
            )
                : SizedBox(
              height: 70.h,
              child: Row(
                children: [
                  // Left arrow button
                  _buildArrowButton(isRight: false),

                  // Amenities list
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      itemCount: amenities.length,
                      itemBuilder: (context, index) {
                        final amenity = amenities[index];
                        return _buildAmenityCard(amenity);
                      },
                    ),
                  ),

                  // Right arrow button
                  _buildArrowButton(isRight: true),
                ],
              ),
            ),

            20.h.verticalSpace,
          ],
        ),
      );
    });
  }

  // ------------------------------------
  // AMENITY CARD (SMALLER VERSION)
  // ------------------------------------
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
            child: amenity.image != null && amenity.image!.isNotEmpty
                ? Image.network(
              amenity.image!,
              width: 32.w,
              height: 32.h,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.image_not_supported_outlined,
                  size: 24.sp,
                  color: Colors.grey,
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return SizedBox(
                  width: 32.w,
                  height: 32.h,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
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

// Add this arrow button method
  Widget _buildArrowButton({required bool isRight}) {
    return GestureDetector(
      onTap: () {
        // Add scroll functionality here
        final scrollController = ScrollController(); // You'll need to get this from your controller
        final scrollAmount = 150.0; // Adjust as needed

        if (isRight) {
          scrollController.animateTo(
            scrollController.offset + scrollAmount,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        } else {
          scrollController.animateTo(
            scrollController.offset - scrollAmount,
            duration: Duration(milliseconds: 300),
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
          isRight ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
          size: 18.sp,
          color: AppColor.primary,
        ),
      ),
    );
  }


}
