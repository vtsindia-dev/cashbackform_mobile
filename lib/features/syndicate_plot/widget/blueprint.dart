import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../common/colours.dart';
import 'package:photo_view/photo_view.dart';

import '../controller/syndicate_controller.dart';

class SyndicateBlueprint extends StatefulWidget {
  const SyndicateBlueprint({super.key});
  @override
  State<SyndicateBlueprint> createState() => _SyndicateBlueprintState();
}

class _SyndicateBlueprintState extends State<SyndicateBlueprint> {
  final SyndicatePlotController controller = Get.find<SyndicatePlotController>();
  double scale = 1.0;

  void _zoomIn() {
    setState(() {
      scale += 0.2;
    });
  }

  void _zoomOut() {
    setState(() {
      scale = (scale - 0.2).clamp(0.5, 5.0);
    });
  }

  void _resetZoom() {
    setState(() {
      scale = 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: Obx(() {
        final String? bluePrintUrl = controller.syndicateDetail.value?.plotImage;
        final String imageUrl = bluePrintUrl?.isNotEmpty == true
            ? bluePrintUrl!
            : 'https://via.placeholder.com/600x400?text=Plot+Blueprint+Unavailable';

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 10.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: AppColor.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(color: AppColor.primary.withOpacity(0.3), width: 1.w),
                      ),
                      child: Text(
                        'Plot Structure',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColor.textMain,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => _openFullscreenView(context, imageUrl),
                      borderRadius: BorderRadius.circular(10.r),
                      child: Padding(
                        padding: EdgeInsets.all(4.w),
                        child: Icon(
                          Icons.fullscreen,
                          size: 28.w,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    height: 250.h,
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.r),
                      child: imageUrl.contains('placeholder')
                          ? Center(
                        child: Text(
                          "Blueprint Image Missing",
                          style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade400),
                        ),
                      )
                          : PhotoView(
                        imageProvider: NetworkImage(imageUrl),
                        minScale: PhotoViewComputedScale.contained,
                        maxScale: PhotoViewComputedScale.covered * 3,
                        initialScale: scale,
                        enableRotation: false,
                        backgroundDecoration: const BoxDecoration(color: Colors.transparent),
                        loadingBuilder: (context, progress) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ).animate().fadeIn(duration: 300.ms).scale(
                        begin: const Offset(0.95, 0.95),
                        end: const Offset(1, 1),
                        duration: 300.ms,
                      ),
                    ),
                  ),

                  // Zoom Controls
                  Positioned(
                    bottom: 15.h,
                    right: 35.w,
                    child: _buildZoomControls(),
                  ),
                ],
              ),
              20.h.verticalSpace,
            ],
          ),
        );
      }),
    );
  }

  Widget _buildZoomControls() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(onTap: _zoomIn, child: Icon(Icons.add_circle_outline, size: 22.w, color: AppColor.textMain)),
          10.w.horizontalSpace,
          Container(height: 20.w, width: 1.w, color: Colors.grey.shade300),
          10.w.horizontalSpace,
          InkWell(onTap: _zoomOut, child: Icon(Icons.remove_circle_outline, size: 22.w, color: AppColor.textMain)),
          10.w.horizontalSpace,
          Container(height: 20.w, width: 1.w, color: Colors.grey.shade300),
          10.w.horizontalSpace,
          InkWell(onTap: _resetZoom, child: Icon(Icons.search, size: 22.w, color: AppColor.textMain)),
        ],
      ),
    );
  }

  void _openFullscreenView(BuildContext context, String imageUrl) {
    Get.to(() => Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PhotoView(
            imageProvider: NetworkImage(imageUrl),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 4,
            backgroundDecoration: const BoxDecoration(color: Colors.black),
            loadingBuilder: (context, progress) => const Center(child: CircularProgressIndicator()),
          ),
          Positioned(
            top: 40.h,
            right: 20.w,
            child: Column(
              children: [
                _fullscreenZoomButton(Icons.close, () => Get.back()),
              ],
            ),
          ),
        ],
      ),
    ));
  }

  Widget _fullscreenZoomButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.black, size: 28.w),
      ),
    );
  }
}