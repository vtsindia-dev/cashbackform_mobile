import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../common/colours.dart';
import '../../../common/widget/appbar.dart';
import '../../../common/widget/loader.dart';
import '../controller/residential_controller.dart';
import '../widget/3d_viewer.dart';
import '../widget/about_residential.dart';
import '../widget/nearby_residential.dart';

class ResidentialPlotDetailsScreen extends StatefulWidget {
  final int? propertyId;
  final String? propertyTitle;
  const ResidentialPlotDetailsScreen({super.key, this.propertyId, this.propertyTitle});

  @override
  State<ResidentialPlotDetailsScreen> createState() => _ResidentialPlotDetailsScreenState();
}

class _ResidentialPlotDetailsScreenState extends State<ResidentialPlotDetailsScreen> {
  final ResidentialPropertyController controller = Get.find<ResidentialPropertyController>();
  @override
  void initState() {
    super.initState();
    controller.enquirySent.value =false;
    if (widget.propertyId != null) {
      controller.fetchPropertyDetail(widget.propertyId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DynamicAppBar(
        title: widget.propertyTitle ?? "Property Details",
        showBackButton: true,
      ),
      body: Obx(() {
        if (controller.isLoadingDetail.value) {
          return const Center(child: GifLoader(message: "Loading plot details...", size: 100));
        }
        if (controller.propertyDetail.value == null) {
          return _buildNoDataAvailable();
        }
        return Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  AboutResidentialProperty(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: NearbyProject(),
                  ),
                  Property3DImageViewer(),
                  SizedBox(height: 60.h),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 16.h,
              child: _centerEnquiryButton(controller),
            ),
          ],
        );
      }),
    );
  }

  Widget _centerEnquiryButton(ResidentialPropertyController controller) {
    return Obx(() {
      // Get the current property from your controller
      final property = controller.propertyDetail.value; // Adjust based on your controller
      final bool isSoldOut = property?.soldStatus == 1; // Or property?.isSoldOut if you have that field

      // Check if button should be disabled
      final bool isDisabled = isSoldOut || controller.isEnquiryLoading.value || controller.enquirySent.value;

      // Determine button text and colors based on state
      String buttonText;
      Gradient buttonGradient;

      if (isSoldOut) {
        buttonText = "Sold Out";
        buttonGradient = LinearGradient(
          colors: [Colors.grey, Colors.grey.shade600],
        );
      } else if (controller.isEnquiryLoading.value) {
        buttonText = "Sending...";
        buttonGradient = LinearGradient(
          colors: [AppColor.primary, AppColor.primarylite],
        );
      } else if (controller.enquirySent.value) {
        buttonText = "Enquiry Sent";
        buttonGradient = LinearGradient(
          colors: [Colors.green, Colors.greenAccent],
        );
      } else {
        buttonText = "Send Enquiry";
        buttonGradient = LinearGradient(
          colors: [AppColor.primary, AppColor.primarylite],
        );
      }

      Widget buttonWidget = Center(
        child: InkWell(
          borderRadius: BorderRadius.circular(30.r),
          onTap: isDisabled
              ? null
              : () {
            controller.sendEnquiry();
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 12.h),
            decoration: BoxDecoration(
              gradient: buttonGradient,
              borderRadius: BorderRadius.circular(30.r),
              boxShadow: [
                BoxShadow(
                  color: isDisabled
                      ? Colors.grey.withOpacity(0.3)
                      : controller.isEnquiryLoading.value
                      ? AppColor.primary.withOpacity(0.5)
                      : Colors.black.withOpacity(0.2),
                  blurRadius: isDisabled ? 0 : (controller.isEnquiryLoading.value ? 15 : 8),
                  spreadRadius: 0,
                  offset: Offset(0, isDisabled ? 0 : (controller.isEnquiryLoading.value ? 0 : 3)),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (controller.isEnquiryLoading.value && !isSoldOut)
                  SizedBox(
                    height: 18.sp,
                    width: 18.sp,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                if (controller.isEnquiryLoading.value && !isSoldOut) SizedBox(width: 8.w),
                if (controller.enquirySent.value && !isSoldOut)
                  Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 18.sp,
                  ),
                if (controller.enquirySent.value && !isSoldOut) SizedBox(width: 8.w),
                if (isSoldOut)
                  Icon(
                    Icons.shopping_cart,
                    color: Colors.white,
                    size: 18.sp,
                  ),
                if (isSoldOut) SizedBox(width: 8.w),
                Text(
                  buttonText,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // Apply shake animation only when loading and not sold out
      return (controller.isEnquiryLoading.value && !isSoldOut)
          ? buttonWidget.animate(
        autoPlay: true,
        onPlay: (controller) => controller.repeat(),
      ).shake(
        hz: 3,
        offset: const Offset(4, 0),
        duration: 1000.ms,
        curve: Curves.easeInOut,
      )
          : buttonWidget;
    });
  }  Widget _buildNoDataAvailable() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.home_work_outlined, size: 80, color: Colors.grey[400]),
          SizedBox(height: 16.h),
          Text(
            "Property Details Not Available",
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "The property information could not be loaded",
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: () {
              if (widget.propertyId != null) {
                controller.fetchPropertyDetail(widget.propertyId!);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF819E4F),
              padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
            ),
            child: Text(
              "Retry",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}