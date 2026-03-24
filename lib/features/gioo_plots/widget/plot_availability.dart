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
      child: Obx(() {
        // Show loading skeleton if no data
        if (controller.giooPlotDetail.value == null) {
          return _buildLoadingSkeleton();
        }

        return Column(
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
                    value: controller.weeklyProfit.value.toInt(),
                    percent: controller.weeklyProfitPercent.value.toInt(),
                    isDashed: true,
                  ),
                ),
                12.w.horizontalSpace,
                Expanded(
                  child: _buildProfitCard(
                    title: "Overall Booked",
                    subtitle: "Total booked units",
                    value: controller.overallProfit.value.toInt(),
                    percent: controller.overallProfitPercent.value.toInt(),
                    isDashed: false,
                  ),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }

  // Loading skeleton while data is being fetched
  Widget _buildLoadingSkeleton() {
    return Column(
      children: [
        Container(
          height: 300.h,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Center(child: CircularProgressIndicator()),
        ),
        20.h.verticalSpace,
        Row(
          children: [
            Expanded(child: _buildCardSkeleton()),
            12.w.horizontalSpace,
            Expanded(child: _buildCardSkeleton()),
          ],
        ),
      ],
    );
  }

  Widget _buildCardSkeleton() {
    return Container(
      height: 120.h,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16.r),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SECTION 1: BAR CHART CARD
  // ---------------------------------------------------------------------------
  Widget _buildBarChartSection(GiooPlotController controller) {
    // Get dynamic data
    final ranges = controller.unitRanges;
    final bookedValues = controller.bookedValues;
    final availableValues = controller.availableValues;

    // Format month names to short form
    final formattedRanges = _formatRanges(ranges, controller.selectedStatsType.value);

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
            child: ranges.isEmpty
                ? _buildEmptyChart()
                : _buildChartWithData(formattedRanges, bookedValues, availableValues),
          ),

          15.h.verticalSpace,

          Text(
            controller.selectedStatsType.value == "Weekly" ? "Days" : "Months",
            style: TextStyle(
                fontSize: 12.sp, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  Widget _buildChartWithData(List<String> ranges, List<double> bookedValues, List<double> availableValues) {
    // Calculate max Y value
    double maxY = 0;
    if (bookedValues.isNotEmpty && availableValues.isNotEmpty) {
      for (int i = 0; i < bookedValues.length; i++) {
        final total = bookedValues[i] + (i < availableValues.length ? availableValues[i] : 0);
        if (total > maxY) maxY = total;
      }
    }

    // Round up to nearest 10 for better grid
    maxY = (maxY * 1.1).ceilToDouble(); // Add 10% padding
    if (maxY < 10) maxY = 100; // Default minimum

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceBetween,
        maxY: maxY,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30.w,
              interval: maxY / 5, // Show 5 intervals
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: EdgeInsets.only(right: 4.w),
                  child: Text(
                    "${value.toInt()}",
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 10.sp,
                    ),
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
                if (index >= 0 && index < ranges.length) {
                  return Padding(
                    padding: EdgeInsets.only(top: 8.h),
                    child: Text(
                      ranges[index],
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 9.sp, // Slightly larger font
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
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
          horizontalInterval: maxY / 5,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey.shade100,
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(ranges.length, (index) {
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: (index < bookedValues.length ? bookedValues[index] : 0) +
                    (index < availableValues.length ? availableValues[index] : 0),
                width: 12.w, // Slightly wider bars
                borderRadius: BorderRadius.circular(2.r),
                rodStackItems: [
                  BarChartRodStackItem(
                      0,
                      index < bookedValues.length ? bookedValues[index] : 0,
                      colorBooked
                  ),
                  BarChartRodStackItem(
                      index < bookedValues.length ? bookedValues[index] : 0,
                      (index < bookedValues.length ? bookedValues[index] : 0) +
                          (index < availableValues.length ? availableValues[index] : 0),
                      colorAvailable
                  ),
                ],
                color: Colors.transparent,
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildEmptyChart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart, size: 40.w, color: Colors.grey.shade300),
          SizedBox(height: 8.h),
          Text(
            "No data available",
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey.shade400,
            ),
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
                  // 4.h.verticalSpace,
                  // Wrap(
                  //   crossAxisAlignment: WrapCrossAlignment.center,
                  //   children: [
                  //     Text(
                  //       "$percent% ${percent >= 0 ? '↑' : '↓'} ",
                  //       style: TextStyle(
                  //           color: percent >= 0 ? const Color(0xFF2ECC71) : Colors.red,
                  //           fontSize: 10.sp,
                  //           fontWeight: FontWeight.bold),
                  //     ),
                  //     Text("From previous period",
                  //         style: TextStyle(
                  //             fontSize: 9.sp, color: Colors.grey.shade400))
                  //   ],
                  // )
                ],
              ),
            ),

            8.w.horizontalSpace,

            // // GAUGE (Fixed Size)
            // SizedBox(
            //   height: 70.w,
            //   width: 70.w,
            //   child: isDashed
            //       ? _buildDashedGauge(percent)
            //       : _buildSolidGauge(percent),
            // )
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

  // Helper method to format ranges (convert full month names to abbreviations)
  List<String> _formatRanges(List<String> ranges, String selectedStatsType) {
    if (selectedStatsType == "Monthly") {
      // Map full month names to abbreviations
      final monthAbbreviations = {
        'January': 'Jan',
        'February': 'Feb',
        'March': 'Mar',
        'April': 'Apr',
        'May': 'May',
        'June': 'Jun',
        'July': 'Jul',
        'August': 'Aug',
        'September': 'Sep',
        'October': 'Oct',
        'November': 'Nov',
        'December': 'Dec',
      };

      return ranges.map((range) {
        // Check if it's a full month name
        for (var fullName in monthAbbreviations.keys) {
          if (range.toLowerCase().contains(fullName.toLowerCase())) {
            return monthAbbreviations[fullName]!;
          }
        }
        return range;
      }).toList();
    } else {
      // For weekly view, keep as is but use first 3 letters
      return ranges.map((range) {
        if (range.length > 3) {
          return range.substring(0, 3);
        }
        return range;
      }).toList();
    }
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