import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../common/colours.dart';
import 'package:photo_view/photo_view.dart';
import '../controller/gioo_controller.dart';

class BluePrint extends StatefulWidget {
  final String title;
  final String? imageUrl;

  const BluePrint({super.key, required this.title, required this.imageUrl});

  @override
  State<BluePrint> createState() => _BluePrintState();
}

class _BluePrintState extends State<BluePrint> {
  double scale = 1.0;

  void _zoomIn() => setState(() => scale += 0.2);

  void _zoomOut() => setState(() => scale = (scale - 0.2).clamp(0.5, 5.0));

  void _resetZoom() => setState(() => scale = 1.0);

  @override
  Widget build(BuildContext context) {
    final String imageUrl = widget.imageUrl?.isNotEmpty == true
        ? widget.imageUrl!
        : 'https://via.placeholder.com/600x400?text=Image+Unavailable';

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 10.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColor.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColor.textMain,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => _openFullscreenView(context, imageUrl),
                    child: Icon(Icons.fullscreen, size: 28.w),
                  ),
                ],
              ),
            ),
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                SizedBox(
                  height: 250.h,
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.r),
                    child: PhotoView(
                      imageProvider: NetworkImage(imageUrl),
                      minScale: PhotoViewComputedScale.contained,
                      maxScale: PhotoViewComputedScale.covered * 3,
                      initialScale: scale,
                      backgroundDecoration: const BoxDecoration(
                        color: Colors.transparent,
                      ),
                    ),
                  ),
                ),
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
      ),
    );
  }

  Widget _buildZoomControls() {
    return Row(
      children: [
        IconButton(onPressed: _zoomIn, icon: const Icon(Icons.add)),
        IconButton(onPressed: _zoomOut, icon: const Icon(Icons.remove)),
        IconButton(onPressed: _resetZoom, icon: const Icon(Icons.refresh)),
      ],
    );
  }

  void _openFullscreenView(BuildContext context, String imageUrl) {
    Get.to(
      () => Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            PhotoView(
              imageProvider: NetworkImage(imageUrl),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 4,
              backgroundDecoration: const BoxDecoration(color: Colors.black),
            ),
            Positioned(
              top: 40.h,
              left: 20.w,
              child: _fullscreenButton(Icons.arrow_back, () {
                Navigator.pop(context);
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fullscreenButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.black, size: 26.w),
      ),
    );
  }
}
