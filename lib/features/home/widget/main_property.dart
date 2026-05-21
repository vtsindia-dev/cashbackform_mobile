import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../common/colours.dart';
import '../../../common/images.dart';
import '../../../common/route/router.dart';


class PropertyMain extends StatelessWidget {
  const PropertyMain({super.key});

  final List<Map<String, dynamic>> properties = const [
    {
      "title": "Market Land/Plots",
      "icon": Images.featuredPlotMarket,
      "color": Color(0xFFE8E5FF),
      "iconColor": Color(0xFF6A5AE0),
      "route": AppRoutes.plotMarket
    },
    {
      "title": "Flats/villas",
      "icon": Images.featuredResidential,
      "color": Color(0xFFE2FBE9),
      "iconColor": Color(0xFF2CC8B3),
      "route": AppRoutes.residentialList
    },
    {
      "title": "Gio Rental Yield Plots",
      "icon": Images.featuredGioo,
      "color": Color(0xFFE3EDFF),
      "iconColor": Color(0xFF0440FF),
      "route": AppRoutes.rentalYieldList
    },
    {
      "title": "Gio Syndicate Plots",
      "icon": Images.featuredSyndicate,
      "color": Color(0xFFFFF0DC),
      "iconColor": Color(0xFFF49B33),
      "route": AppRoutes.syndicate
    },
    {
      "title": "Gio Nano Plots",
      "icon": Images.featuredGioo,
      "color": Color(0xFFFFE3EE),
      "iconColor": Color(0xFFE54788),
      "route": AppRoutes.gioo
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "Plot ",
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
                color: AppColor.textMain,
              ),
            ),
            Text(
              "Categories",
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFFFC107),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(child: _buildAnimateCard(properties[0], 0)),
            SizedBox(width: 12.w),
            Expanded(child: _buildAnimateCard(properties[1], 1)),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(child: _buildAnimateCard(properties[2], 2)),
            SizedBox(width: 10.w),
            Expanded(child: _buildAnimateCard(properties[3], 3)),
            SizedBox(width: 10.w),
            Expanded(child: _buildAnimateCard(properties[4], 4)),
          ],
        ),
      ],
    );
  }

  Widget _buildAnimateCard(Map<String, dynamic> item, int index) {
    return _buildCard(item)
        .animate()
        .slideX(
      begin: (index % 2 == 0) ? 0.4 : -0.4,
      end: 0,
      duration: 600.ms,
      curve: Curves.easeOutCubic,
    )
        .fadeIn(duration: 450.ms);
  }

  Widget _buildCard(Map<String, dynamic> item) {
    final String title = item["title"]!;
    final String icon = item["icon"]!;
    final Color bgColor = item["color"]!;
    final Color iconColor = item["iconColor"]!;
    final String route = item["route"]!;

    return GestureDetector(
      onTap: () => Get.toNamed(route),
      child: Container(
        height: 76.h,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: 4.w,
              bottom: 4.h,
              child: Opacity(
                opacity: 0.05,
                child: Image.asset(
                  icon,
                  height: 52.h,
                  width: 52.h,
                  color: Colors.black,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.all(5.r),
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Image.asset(
                      icon,
                      height: 22.h,
                      width: 22.h,
                      color: iconColor,
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate(onPlay: (c) => c.repeat()).shimmer(
      duration: 2500.ms,
      color: Colors.white.withValues(alpha: 0.25),
    );
  }
}