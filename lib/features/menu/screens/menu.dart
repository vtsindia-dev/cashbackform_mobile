import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../common/colours.dart';
import '../../../common/widget/appbar.dart';

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  String selectedRole = "User";

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);

    return Scaffold(
      appBar: DynamicAppBar(
        title: "DashBoard",
        showBackButton: true,
      ),
      backgroundColor: AppColor.backgroundLight,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            _buildHeader().animate().fade().slideY(begin: -0.2),
            SizedBox(height: 20.h),

            _buildRoleButtons()
                .animate().fade(duration: 400.ms)
                .slideY(begin: -0.1),
            SizedBox(height: 25.h),

            _buildDashboardTitle(),
            SizedBox(height: 12.h),

            _buildDashboardGrid()
                .animate()
                .fade(duration: 450.ms)
                .slide(begin: const Offset(0, 0.1)),
            SizedBox(height: 30.h),

            _buildMenuTitle(),
            SizedBox(height: 12.h),

            _buildMenuList()
                .animate()
                .fade(duration: 450.ms)
                .slide(begin: const Offset(0, 0.1)),
            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  // HEADER
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColor.primarylite,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35.r,
            backgroundImage: const NetworkImage("https://i.pravatar.cc/150?img=3"),
          ),
          SizedBox(width: 16.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Abishek Jr",
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColor.black,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                "Role: $selectedRole",
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColor.textSecondary,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  // ROLE BUTTONS
  Widget _buildRoleButtons() {
    List<String> roles = ["User", "Agent", "Vendor"];

    return SizedBox(
      height: 45.h,
      child: Row(
        children: roles.map((role) {
          bool active = selectedRole == role;

          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => selectedRole = role),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                decoration: BoxDecoration(
                  color: active ? AppColor.primary : AppColor.lightGrey,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                alignment: Alignment.center,
                child: Text(
                  role,
                  style: TextStyle(
                    color: active ? AppColor.white : AppColor.textMain,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDashboardTitle() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        "Dashboard",
        style: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
          color: AppColor.textMain,
        ),
      ),
    );
  }

  // 🔥 FIXED SIZE GRID
  Widget _buildDashboardGrid() {
    List<Map<String, dynamic>> data = [
      {
        "title": "Plot Enquiries",
        "count": 23,
        "percent": 70,
        "color": AppColor.primary,
      },
      {
        "title": "Material Enquiries",
        "count": 12,
        "percent": 52,
        "color": AppColor.orange,
      },
      {
        "title": "Service Enquiries",
        "count": 18,
        "percent": 40,
        "color": AppColor.secondary,
      },
      {
        "title": "Visits Booked",
        "count": 9,
        "percent": 64,
        "color": AppColor.green,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: data.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 0.92, // ⭐ PERFECT SIZE
      ),
      itemBuilder: (context, index) {
        final item = data[index];
        return _dashboardCard(
          title: item["title"],
          count: item["count"],
          percent: item["percent"],
          color: item["color"],
        ).animate().fade().scale();
      },
    );
  }

  // DASHBOARD CARD
  Widget _dashboardCard({
    required String title,
    required int count,
    required int percent,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ⭐ SMALL FIXED GAUGE
          SizedBox(
            width: 60.w,
            height: 60.w,
            child: CustomPaint(
              painter: DashedRingPainter(
                percent: percent / 100,
                activeColor: color,
                inactiveColor: Colors.grey.shade300,
                width: 6.w,
              ),
              child: Center(
                child: Text(
                  "$percent%",
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: 8.h),

          Text(
            "$count",
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 6.h),

          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColor.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // MENU TITLE
  Widget _buildMenuTitle() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        "Menu",
        style: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
          color: AppColor.textMain,
        ),
      ),
    );
  }

  // MENU LIST
  Widget _buildMenuList() {
    return Column(
      children: [
        _menuTile(Icons.info, "About Us"),
        _menuTile(Icons.history, "Transaction Details"),
        _menuTile(Icons.support_agent, "Support"),
        _menuTile(Icons.logout, "Logout", isLogout: true),
      ],
    );
  }

  Widget _menuTile(IconData icon, String title, {bool isLogout = false}) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 12.w),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: AppColor.grey.withOpacity(0.18),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: isLogout ? AppColor.red : AppColor.primary),
          SizedBox(width: 14.w),
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              color: isLogout ? AppColor.red : AppColor.textMain,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Icon(Icons.arrow_forward_ios, size: 16, color: AppColor.grey),
        ],
      ),
    );
  }
}

// CUSTOM DASHED GAUGE
class DashedRingPainter extends CustomPainter {
  final double percent;
  final Color activeColor;
  final Color inactiveColor;
  final double width;

  DashedRingPainter({
    required this.percent,
    required this.activeColor,
    required this.inactiveColor,
    required this.width,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - width) / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;

    const int dashCount = 40;
    const double startAngle = -pi / 2;
    const double sweepAngle = 2 * pi;

    final double dashAngle = sweepAngle / dashCount;
    const double gapRatio = 0.25;
    final double segmentAngle = dashAngle * (1 - gapRatio);

    final int activeDashes = (dashCount * percent).round();

    for (int i = 0; i < dashCount; i++) {
      paint.color = i < activeDashes ? activeColor : inactiveColor;

      final double angle = startAngle + i * dashAngle;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        angle,
        segmentAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
