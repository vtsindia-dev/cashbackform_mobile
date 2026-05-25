import 'package:cashback_farms/common/colours.dart';
import 'package:cashback_farms/common/route/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controller/homecontroller.dart';

class MaterialCategory extends StatelessWidget {
  MaterialCategory({super.key});

  final HomeController controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return GetX<HomeController>(
      builder: (controller) {
        if (controller.materials.isEmpty) {
          return SizedBox(
            height: 160.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: 4,
              separatorBuilder: (_, __) => SizedBox(width: 12.w),
              itemBuilder: (_, __) => _ShimmerCard(),
            ),
          );
        }

        return SizedBox(
          height: 160.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            itemCount: controller.materials.length,
            separatorBuilder: (_, __) => SizedBox(width: 12.w),
            itemBuilder: (context, index) {
              final item = controller.materials[index];
              final String imageUrl =
              (item["images"] != null && (item["images"] as List).isNotEmpty)
                  ? item["images"][0].toString()
                  : '';
              final String title = item["title"]?.toString() ?? '';
              final String code = item["material_code"]?.toString() ?? '';
              final String categoryName =
              (item["category"] != null)
                  ? item["category"]["name"]?.toString() ?? ''
                  : '';
              final bool isFeatured = item["featured"] == 1;

              return _MaterialCard(
                imageUrl: imageUrl,
                title: title,
                code: code,
                categoryName: categoryName,
                isFeatured: isFeatured,
                onTap: () {
                  Get.toNamed(
                    AppRoutes.vendorList,
                    arguments: {
                      'id': item["id"] ?? '',
                      'title': title,
                    },
                  );
                },
              )
                  .animate()
                  .slideX(
                begin: -0.4,
                end: 0,
                duration: 550.ms,
                delay: (index * 80).ms,
                curve: Curves.easeOutCubic,
              )
                  .fadeIn(
                duration: 450.ms,
                delay: (index * 80).ms,
              )
                  .scale(
                begin: const Offset(0.92, 0.92),
                end: const Offset(1, 1),
                duration: 550.ms,
                delay: (index * 80).ms,
                curve: Curves.easeOutBack,
              );
            },
          ),
        );
      },
    );
  }
}


class _MaterialCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String code;
  final String categoryName;
  final bool isFeatured;
  final VoidCallback onTap;

  const _MaterialCard({
    required this.imageUrl,
    required this.title,
    required this.code,
    required this.categoryName,
    required this.isFeatured,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150.w,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(14.r),
                topRight: Radius.circular(14.r),
              ),
              child: Stack(
                children: [
                  imageUrl.isNotEmpty
                      ? Image.network(
                    imageUrl,
                    height: 95.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _imageFallback(),
                    loadingBuilder: (_, child, progress) {
                      if (progress == null) return child;
                      return _imageLoading();
                    },
                  )
                      : _imageFallback(),
                  if (categoryName.isNotEmpty)
                    Positioned(
                      bottom: 6.h,
                      right: 6.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: AppColor.primary.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          categoryName,
                          style: GoogleFonts.poppins(
                            fontSize: 8.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (code.isNotEmpty)
                      Row(
                        children: [
                          Icon(
                            Icons.qr_code_rounded,
                            size: 10.sp,
                            color: Colors.grey.shade400,
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: Text(
                              code,
                              style: GoogleFonts.poppins(
                                fontSize: 9.sp,
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageFallback() {
    return Container(
      height: 95.h,
      width: double.infinity,
      color: Colors.grey.shade100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.category_outlined,
              size: 26.sp, color: Colors.grey.shade400),
          SizedBox(height: 4.h),
          Text(
            "No Image",
            style: TextStyle(fontSize: 9.sp, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  Widget _imageLoading() {
    return Container(
      height: 95.h,
      width: double.infinity,
      color: Colors.grey.shade100,
      child: Center(
        child: SizedBox(
          width: 18.w,
          height: 18.w,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColor.primary.withOpacity(0.5),
          ),
        ),
      ),
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150.w,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(14.r),
              topRight: Radius.circular(14.r),
            ),
            child: Container(
              height: 95.h,
              color: Colors.grey.shade200,
            )
                .animate(onPlay: (c) => c.repeat())
                .shimmer(
              duration: 1200.ms,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 10.h,
                  width: 100.w,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                )
                    .animate(onPlay: (c) => c.repeat())
                    .shimmer(
                  duration: 1200.ms,
                  color: Colors.white.withOpacity(0.6),
                ),
                SizedBox(height: 6.h),
                Container(
                  height: 8.h,
                  width: 70.w,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                )
                    .animate(onPlay: (c) => c.repeat())
                    .shimmer(
                  duration: 1200.ms,
                  color: Colors.white.withOpacity(0.6),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}