import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../common/colours.dart';
import '../../../common/images.dart';
import '../../../common/route/router.dart';
import '../../plot_market/screens/add_plot.dart';
import '../../residential_plots/view/add_residential.dart';


class PropertyMain extends StatelessWidget {
  const PropertyMain({super.key});

  final List<Map<String, dynamic>> properties = const [
    {
      "title": "Market Land/Plots",
      "icon": Images.featuredPlotMarket,
      "color": Color(0xFFE2FBE9),
      "iconColor": Color(0xFF2CC8B3),
      "route": AppRoutes.plotMarket,
      "asset": "assets/images/home-categories-1.png",
    },
    {
      "title": "Flats/villas",
      "icon": Images.featuredResidential,
      "color": Color(0xFFFFE3EE),
      "iconColor": Color(0xFFE54788),
      "route": AppRoutes.residentialList,
      "asset": "assets/images/home-categories-2.png",
    },
    {
      "title": "Gio Rental Yield Plots",
      "icon": Images.featuredGioo,
      "color": Color(0xFFE3EDFF),
      "iconColor": Color(0xFF0440FF),
      "route": AppRoutes.rentalYieldList,
      "asset": "assets/images/home-categories-3.png",
    },
    {
      "title": "Gio Syndicate Plots",
      "icon": Images.featuredSyndicate,
      "color": Color(0xFFFFF0DC),
      "iconColor": Color(0xFFF49B33),
      "route": AppRoutes.syndicate,
      "asset": "assets/images/home-categories-4.png",
    },
    {
      "title": "Gioo Nano Plots",
      "icon": Images.featuredGioo,
      "color": Color(0xFFE8E5FF),
      "iconColor": Color(0xFF6A5AE0),
      "route": AppRoutes.gioo,
      "asset": "assets/images/home-categories-5.png",
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
              "Buy & Add ",
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
                color: AppColor.textMain,
              ),
            ),
            Text(
              "Properties",
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
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: addPropertyCard(
                title: "Add My Land",
                subtitle: "Plot / Agricultural",
                bgColor: const Color(0xFFE2FBE9),
                iconBgColor: const Color(0xff92AF5D),
                image: "assets/images/home-categories-1.png",
                onTap: () => Get.to(() => MarketPlotForm()),
              ),
            ),

            SizedBox(width: 12.w),

            Expanded(
              child: addPropertyCard(
                title: "Add My Flats",
                subtitle: "Residential Property",
                bgColor: const Color(0xFFFFE3EE),
                iconBgColor: const Color(0xFFE54788),
                image: "assets/images/home-categories-2.png",
                onTap: () => Get.to(() => const AddEditPropertyScreen()),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Text(
              "Gio Properties ",
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

  Widget addPropertyCard({
    required String title,
    required String subtitle,
    required Color bgColor,
    required Color iconBgColor,
    required String image,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 70.h,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Row(
            children: [
              Image.asset(image,height: 42.h, width: 42.h,),
              SizedBox(width: 5 .w),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: iconBgColor,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 7.sp,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 5.w),
              Container(
                height: 34.h,
                width: 34.h,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
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
    final String asset = item["asset"]!;

    return GestureDetector(
      onTap: () => Get.toNamed(route),
      child: Container(
        height: 76.h,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
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
                      asset,
                      height: 22.h,
                      width: 22.h,
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
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
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