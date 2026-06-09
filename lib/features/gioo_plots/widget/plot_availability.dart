import 'package:cashback_farms/common/colours.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controller/gioo_controller.dart';

class PlotAvailabilityWidget extends StatelessWidget {
  const PlotAvailabilityWidget({super.key});
  final Color colorBooked = AppColor.primary;
  final Color colorAvailable = AppColor.orange;
  final Color colorTextMain = const Color(0xFF2D2D2D);

  @override
  Widget build(BuildContext context) {
    final GiooPlotController controller = Get.put(GiooPlotController());

    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Obx(() {
        if (controller.giooPlotDetail.value == null) {
          return _buildLoadingSkeleton();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBarChartSection(controller)
                .animate()
                .slideX(begin: -0.2, end: 0, duration: 600.ms, curve: Curves.easeOutCubic)
                .fadeIn(duration: 500.ms),

            20.h.verticalSpace,
            Row(
              children: [
                Expanded(
                  child: _buildProfitCard(
                    title: controller.weeklyProfit.value.toInt() == 1
                        ? "Booked Customer"
                        : "Booked Customers",
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


  Widget _buildBarChartSection(GiooPlotController controller) {
    final ranges = controller.unitRanges;
    final bookedValues = controller.bookedValues;
    final availableValues = controller.availableValues;

    final formattedRanges = _formatRanges(ranges, controller.selectedStatsType.value);

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
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
    double maxY = 0;
    if (bookedValues.isNotEmpty && availableValues.isNotEmpty) {
      for (int i = 0; i < bookedValues.length; i++) {
        final total = bookedValues[i] + (i < availableValues.length ? availableValues[i] : 0);
        if (total > maxY) maxY = total;
      }
    }

    maxY = (maxY * 1.1).ceilToDouble();
    if (maxY < 10) maxY = 100;

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
              interval: maxY / 5,
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
                        fontSize: 9.sp,
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
                width: 12.w,
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
              color: Colors.black.withValues(alpha: 0.05),
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
                ],
              ),
            ),
            8.w.horizontalSpace,
          ],
        )
    )
        .animate()
        .slideX(begin: 0.5, end: 0, duration: 600.ms, curve: Curves.easeOutCubic)
        .fadeIn(duration: 500.ms)
        .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1), duration: 600.ms, curve: Curves.easeOutBack)
        .then(delay: 0.ms);

  }


  List<String> _formatRanges(List<String> ranges, String selectedStatsType) {
    if (selectedStatsType == "Monthly") {
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
        for (var fullName in monthAbbreviations.keys) {
          if (range.toLowerCase().contains(fullName.toLowerCase())) {
            return monthAbbreviations[fullName]!;
          }
        }
        return range;
      }).toList();
    } else {
      return ranges.map((range) {
        if (range.length > 3) {
          return range.substring(0, 3);
        }
        return range;
      }).toList();
    }
  }
}

