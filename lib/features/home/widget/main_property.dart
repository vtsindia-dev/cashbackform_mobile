import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../common/colours.dart';
import '../../../common/images.dart';
import '../../../common/route/router.dart';

class PropertyMain extends StatelessWidget {
  const PropertyMain({super.key});

  final List<Map<String, String>> properties = const [
    {"title": "Land", "icon": Images.featuredPlotMarket},
    {"title": "Gioo Nano Plots", "icon": Images.featuredGioo},
    {"title": "Gio Rental Yield – Syndicate Plot", "icon": Images.featuredSyndicate},
    {"title": "Flat/Villas", "icon": Images.featuredResidential},
    {"title": "Gio Rental Yield", "icon": Images.featuredGioo},
  ];

  final List<Color> iconColors = const [
         Color(0xFF6A5AE0),
    Color(0xFF2CC8B3),
    Color(0xFFF49B33),
    Color(0xFFE54788),
    Color(0xFF0440FF),
  ];

  @override
  Widget build(BuildContext context) {
    final rowCount = (properties.length / 2).ceil();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start ,
      children: [
        Text(
          "Explore All",
          style: TextStyle(
            fontSize: 19.sp,
            fontWeight: FontWeight.bold,
            color: AppColor.textMain,
          ),
        ),

        SizedBox(height: 12.h),

        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: rowCount,
          itemBuilder: (context, rowIndex) {
            final left = rowIndex * 2;
            final right = left + 1;

            return Row(
              children: [
                Expanded(
                  child: _buildCard(properties[left], left)
                      .animate()
                      .slideX(
                    begin: (left % 2 == 0) ? 0.6 : -0.6,
                    end: 0,
                    duration: 650.ms,
                    curve: Curves.easeOutCubic,
                  )
                      .fadeIn(duration: 500.ms),
                ),
                SizedBox(width: 12.w),


                Expanded(
                  child: right < properties.length
                      ? _buildCard(properties[right], right)
                      .animate()
                      .slideX(
                    begin: (right % 2 == 0) ? 0.6 : -0.6,
                    end: 0,
                    duration: 650.ms,
                    curve: Curves.easeOutCubic,
                  )
                      .fadeIn(duration: 500.ms)
                      : SizedBox.shrink(),
                ),
              ],
            ).paddingOnly(bottom: 10.h);
          },
        ),
      ],
    );
  }
  

  void _navigateByTitle(String title) {
    if (title == "Land") {
      Get.toNamed(AppRoutes.plotMarket);
    } else if (title == "Gioo Nano Plots") {
      Get.toNamed(AppRoutes.gioo);
    } else if (title == "Gio Rental Yield – Syndicate Plot") {
      Get.toNamed(AppRoutes.syndicate);
    }
    else if (title == "Gio Rental Yield") {
      Get.toNamed(AppRoutes.rentalYieldList);
    } else {
      Get.toNamed(AppRoutes.residentialList);
    }
  }

  Widget _buildCard(Map<String, String> item, int index) {
    final title = item["title"]!;
    final icon = item["icon"]!;
    final iconBg = iconColors[index % iconColors.length];

    return GestureDetector(
      onTap: () => _navigateByTitle(title),
      child: Container(
        height: 80.h,
        decoration: BoxDecoration(
          color: iconBg.withOpacity(0.2),
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: 8.w,
              bottom: 8.h,
              child: Opacity(
                opacity: 0.06,
                child: Image.asset(
                  icon,
                  height: 55.h,
                  width: 55.h,
                  color: Colors.black,
                ),
              ),
            ),

            Positioned(
              top: 10.h,
              left: 10.w,
              child: Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: iconBg.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Image.asset(
                  icon,
                  height: 26.h,
                  width: 26.h,
                  color: iconBg,
                ),
              ),
            ),

            Positioned(
              bottom: 8.h,
              left: 12.w,
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    )
        .animate(onPlay: (c) => c.repeat())
        .shimmer(
      duration: 2300.ms,
      color: Colors.white.withOpacity(0.40),
    );
  }
}
