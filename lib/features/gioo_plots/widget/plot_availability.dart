import 'dart:math';

import 'package:cashback_farms/common/colours.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controller/gioo_controller.dart';

class PlotAvailabilityWidget extends StatelessWidget {
  const PlotAvailabilityWidget({super.key});
  final Color colorBooked = AppColor.primary; // Olive Green
  final Color colorAvailable = AppColor.orange; // Amber
  final Color colorTextMain = const Color(0xFF2D2D2D);

  @override
  Widget build(BuildContext context) {
    final GiooPlotController controller = Get.put(GiooPlotController());

    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Obx(() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Top Bar Chart Section (Animation for Entrance)
          _buildBarChartSection(controller)
              .animate()
              .slideX(begin: -0.2, end: 0, duration: 600.ms, curve: Curves.easeOutCubic)
              .fadeIn(duration: 500.ms),

          20.h.verticalSpace,

          // 2. Bottom Profit Cards Section (Animation for Entrance)
          Row(
            children: [
              Expanded(
                child: _buildProfitCard(
                  title: "Weekly Profit",
                  subtitle: "This Week Units booked Range",
                  value: controller.weeklyProfit.value,
                  percent: controller.weeklyProfitPercent.value,
                  isDashed: true,
                ),
              ),
              12.w.horizontalSpace,
              Expanded(
                child: _buildProfitCard(
                  title: "Over all Booked",
                  subtitle: "This Week Over all booked Units Range",
                  value: controller.overallProfit.value,
                  percent: controller.overallProfitPercent.value,
                  isDashed: false,
                ),
              ),
            ],
          ),
        ],
      )),
    );
  }

  // ---------------------------------------------------------------------------
  // SECTION 1: BAR CHART CARD
  // ---------------------------------------------------------------------------
  Widget _buildBarChartSection(GiooPlotController controller) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Number of Units",
                        style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: colorTextMain)),
                    8.h.verticalSpace,
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildLegend(colorBooked, "Booked"),
                          12.w.horizontalSpace,
                          _buildLegend(colorAvailable, "Available"),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              _buildToggleButtons(controller),
            ],
          ),

          30.h.verticalSpace,

          // The Chart
          SizedBox(
            height: 220.h,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceBetween,
                maxY: 100,
                barTouchData: BarTouchData(enabled: false),



                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30.w,
                      interval: 20,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          "${value.toInt()}%",
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 10.sp,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24.h,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index >= 0 && index < controller.unitRanges.length) {
                          return Padding(
                            padding: EdgeInsets.only(top: 8.h),
                            child: Text(
                              controller.unitRanges[index],
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 8.sp,
                              ),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 20,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.shade100,
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(controller.unitRanges.length, (index) {
                  // Safety check for index bounds
                  if (index >= controller.bookedValues.length) return BarChartGroupData(x: index);

                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: controller.bookedValues[index] + controller.availableValues[index],
                        width: 8.w,
                        borderRadius: BorderRadius.circular(2.r),
                        rodStackItems: [
                          BarChartRodStackItem(
                              0, controller.bookedValues[index], colorBooked),
                          BarChartRodStackItem(
                              controller.bookedValues[index],
                              controller.bookedValues[index] + controller.availableValues[index],
                              colorAvailable),
                        ],
                        color: Colors.transparent,
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),

          15.h.verticalSpace,

          Text(
            "Unit Ranges",
            style: TextStyle(
                fontSize: 12.sp, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 10.w,
          height: 10.w,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(2.r)),
        ),
        6.w.horizontalSpace,
        Text(text, style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _buildToggleButtons(GiooPlotController controller) {
    return Container(
      height: 32.h,
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Row(
        children: [
          _toggleBtn("Monthly", controller),
          10.w.horizontalSpace,
          _toggleBtn("Weekly", controller),
        ],
      ),
    );
  }

  Widget _toggleBtn(String text, GiooPlotController controller) {
    bool isSelected = controller.selectedStatsType.value == text;

    return InkWell(
      onTap: () => controller.updateStats(text),
      borderRadius: BorderRadius.circular(6.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: isSelected
            ? EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h)
            : EdgeInsets.zero,
        decoration: BoxDecoration(
          color: isSelected ? colorBooked : Colors.transparent,
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : colorBooked,
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
  Widget _buildProfitCard({
    required String title,
    required String subtitle,
    required int value,
    required int percent,
    required bool isDashed,
  }) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: colorTextMain),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  4.h.verticalSpace,
                  Text(
                    subtitle,
                    style: TextStyle(
                        fontSize: 10.sp,
                        color: Colors.grey.shade500,
                        height: 1.2),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  12.h.verticalSpace,
                  Text(
                    "$value",
                    style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: colorTextMain),
                  ),
                  4.h.verticalSpace,
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        "$percent% ↑ ",
                        style: TextStyle(
                            color: const Color(0xFF2ECC71),
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold),
                      ),
                      Text("From previous period",
                          style: TextStyle(
                              fontSize: 9.sp, color: Colors.grey.shade400))
                    ],
                  )
                ],
              ),
            ),

            8.w.horizontalSpace,

            // GAUGE (Fixed Size)
            SizedBox(
              height: 70.w,
              width: 70.w,
              child: isDashed
                  ? _buildDashedGauge(percent)
                  : _buildSolidGauge(percent),
            )
          ],
        )
    )
    // NON-REPEATING ENTRANCE ANIMATION + COLORIZE FILL EFFECT
        .animate()
        .slideX(begin: 0.5, end: 0, duration: 600.ms, curve: Curves.easeOutCubic)
        .fadeIn(duration: 500.ms)
        .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1), duration: 600.ms, curve: Curves.easeOutBack)
        .then(delay: 0.ms);

  }

  // --- WIDGET FOR DASHED GAUGE (Weekly Profit) ---
  Widget _buildDashedGauge(int percent) {
    return CustomPaint(
      painter: DashedRingPainter(
        percent: percent / 100,
        activeColor: const Color(0xFF00C853), // Bright Green
        inactiveColor: Colors.grey.shade100,
        width: 8.w,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "$percent%",
              style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade400),
            ),
            Text(
              "Profit",
              style: TextStyle(
                  fontSize: 10.sp,
                  color: Colors.grey.shade400),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET FOR SOLID GAUGE (Overall Booked) ---
  Widget _buildSolidGauge(int percent) {
    const Color primaryColor = Color(0xFF8BB55F);

    return Stack(
      alignment: Alignment.center,
      children: [
        PieChart(
          PieChartData(
            startDegreeOffset: 270, // Start from top
            sectionsSpace: 0,
            centerSpaceRadius: 25.w,
            sections: [
              PieChartSectionData(
                color: primaryColor, // Olive Green
                value: percent.toDouble(),
                title: '',
                radius: 8.w,
              ),
              PieChartSectionData(
                color: Colors.grey.shade100,
                value: (100 - percent).toDouble(),
                title: '',
                radius: 8.w,
              ),
            ],
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "$percent%",
              style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade400),
            ),
            Text(
              "Profit",
              style: TextStyle(
                  fontSize: 10.sp,
                  color: Colors.grey.shade400),
            ),
          ],
        ),
      ],
    );
  }
}
// -----------------------------------------------------------------------------
// CUSTOM PAINTER FOR DASHED RING (Remains unchanged)
// -----------------------------------------------------------------------------
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
      ..strokeWidth = width
      ..strokeCap = StrokeCap.butt;

    const int dashCount = 40;
    const double startAngle = -pi / 2;
    const double sweepAngle = 2 * pi;
    final double dashAngle = sweepAngle / dashCount;
    const double gapRatio = 0.2;
    final double segmentAngle = dashAngle * (1 - gapRatio);

    final int activeDashes = (dashCount * percent).round();

    for (int i = 0; i < dashCount; i++) {
      final double currentAngle = startAngle + (dashAngle * i);
      paint.color = i < activeDashes ? activeColor : inactiveColor;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        currentAngle,
        segmentAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant DashedRingPainter oldDelegate) {
    return oldDelegate.percent != percent;
  }
}