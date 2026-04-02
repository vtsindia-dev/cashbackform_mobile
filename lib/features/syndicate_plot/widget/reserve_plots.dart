import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../common/images.dart';
import '../../home/widget/sub_title.dart';
import '../../payment/controller/razorpay_controller.dart';
import '../controller/syndicate_controller.dart';

class ReservePlotsScreen extends StatefulWidget {
  final GlobalKey reserveButtonKey;

  ReservePlotsScreen({super.key, required this.reserveButtonKey});

  @override
  State<ReservePlotsScreen> createState() => _ReservePlotsScreenState();
}

class _ReservePlotsScreenState extends State<ReservePlotsScreen> {
  final controller = Get.find<SyndicatePlotController>();
  final paymentController = Get.put(RazorpayController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SyndicatePlotController>(
      builder: (_) {
        final detail = controller.syndicateDetail.value;
        if (detail == null) return SizedBox.shrink();

        final selectedCount = controller.selectedPlots.length;
        // Use adminBlockAmount for price per plot instead of calculated price
        final pricePerPlot = controller.getPricePerPlotFromAdminBlock();

        double totalAmount = 0;
        if (selectedCount > 0) {
          totalAmount = controller.calculateSelectedPlotsAmount();
        }
        final amountWithGst = totalAmount;
        final plotAreas = controller.getPlotAreas();
        final totalArea = plotAreas.fold(0.0, (sum, area) => sum + area);

        return Column(
          children: [
            SizedBox(height: 10.h),
            Padding(
              padding: EdgeInsets.all(8.w),
              child: SubtitleWidget(
                showViewAll: false,
                title: "Plot Split-Up",
                highlightWord: "Split-Up",
              ).animate()
                  .fadeIn(duration: 500.ms)
                  .slideY(begin: 0.3, end: 0),
            ),
            Container(
              margin: EdgeInsets.all(8.w),
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8.r,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price and Area info
                  Padding(
                    padding: EdgeInsets.only(bottom: 10.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Price per Plot: ₹${pricePerPlot.toStringAsFixed(2)}",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Total Plots: ${detail.unitSpilt}",
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey[700],
                              ),
                            ),
                            Text(
                              "Total Area: ${totalArea.toStringAsFixed(0)} sq.ft",
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Legend
                  Wrap(
                    spacing: 15.w,
                    runSpacing: 10.h,
                    children: [
                      legendBox(
                        Colors.orange,
                        "Selected ($selectedCount)",
                      ),
                      legendBox(
                        const Color(0xFF3B711A),
                        "Booked  (${controller.countStatus("booked")})",
                      ),
                      legendBox(
                        const Color(0xFFB8D79A),
                        "Available (${controller.countStatus("available")})",
                      ),
                    ],
                  ),

                  SizedBox(height: 20.h),

                  // Dynamic grid based on API data
                  controller.plots.isEmpty
                      ? Center(child: CircularProgressIndicator())
                      : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.plots.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 10.h,
                      crossAxisSpacing: 10.w,
                      childAspectRatio: 2.3,
                    ),
                    itemBuilder: (context, index) {
                      final item = controller.plots[index];
                      final id = item["id"];
                      final type = item["status"];
                      final area = item["area"] ?? 0.0;
                      final formattedArea = controller.formatArea(area);
                      final isSelected = controller.selectedPlots.contains(id);
                      final adminBlockAmount = controller.getPricePerPlotFromAdminBlock();

                      return GestureDetector(
                        onTap: () => controller.toggleSelect(id, type),
                        child: Container(
                          decoration: BoxDecoration(
                            color: controller.getColor(type, isSelected),
                            borderRadius: BorderRadius.circular(8.r),
                            border: isSelected
                                ? Border.all(color: Colors.white, width: 2)
                                : null,
                            boxShadow: isSelected
                                ? [
                              BoxShadow(
                                color: Colors.orange.withOpacity(0.3),
                                blurRadius: 4,
                                spreadRadius: 1,
                              )
                            ]
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Plot-$id",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                formattedArea,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9.sp,
                                ),
                              ),
                              if (isSelected)
                                Text(
                                  "₹${adminBlockAmount.toStringAsFixed(2)}",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  if (selectedCount > 0) ...[
                    SizedBox(height: 15.h),
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: Colors.blue[100]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Payment Summary",
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[800],
                            ),
                          ),
                          SizedBox(height: 8.h),
                          // Calculation Formula
                          Text(
                            "Calculation:",
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            "${selectedCount} plots × ₹${pricePerPlot.toStringAsFixed(2)} = ₹${totalAmount.toStringAsFixed(2)}",
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.green,
                            ),
                          ),
                          Divider(height: 12.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Base Amount:",
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                "₹${totalAmount.toStringAsFixed(2)}",
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                          // SizedBox(height: 4.h),
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //   children: [
                          //     Text(
                          //       "GST (18%) :",
                          //       style: TextStyle(fontSize: 12.sp),
                          //     ),
                          //     Text(
                          //       "₹${(totalAmount * 0.18).toStringAsFixed(2)}",
                          //       style: TextStyle(
                          //         fontSize: 12.sp,
                          //         color: Colors.orange,
                          //       ),
                          //     ),
                          //   ],
                          // ),
                          Divider(height: 12.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Total Amount:",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "₹${amountWithGst.toStringAsFixed(2)}",
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                  SizedBox(height: 15.h),
                  Center(
                    child: InkWell(
                      onTap: selectedCount > 0
                          ? () => controller.initiatePlotPayment()
                          : null,
                      child: Container(
                        key: widget.reserveButtonKey,
                        width: 230.w,
                        height: 45.h,
                        decoration: BoxDecoration(
                          color: selectedCount > 0 ? Colors.green : Colors.grey[300],
                          borderRadius: BorderRadius.circular(30.r),
                          boxShadow: selectedCount > 0
                              ? [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            )
                          ]
                              : null,
                          border: Border.all(
                            color: selectedCount > 0 ? Colors.green[700]! : Colors.grey,
                            width: 1,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              selectedCount > 0
                                  ? "Pay ₹${amountWithGst.toStringAsFixed(2)}"
                                  : "Select Plots to Reserve",
                              style: TextStyle(
                                color: selectedCount > 0 ? Colors.white : Colors.grey,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (selectedCount > 0) ...[
                              SizedBox(height: 2.h),
                              Text(
                                "${selectedCount} plots selected",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 10.sp,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ).animate(
                        onPlay: (ctrl) => ctrl.repeat(),
                      ).shake(
                        hz: selectedCount > 0 ? 3 : 0,
                        offset: const Offset(4, 0),
                        duration: 1000.ms,
                        curve: Curves.easeInOut,
                      ),
                    ),
                  ),

                  // Info text
                  if (selectedCount > 0) ...[
                    SizedBox(height: 10.h),
                    Center(
                      child: Text(
                        "(${selectedCount} plots × ₹${pricePerPlot.toStringAsFixed(2)})",
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget legendBox(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16.w,
          height: 16.h,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4.r),
          ),
        ),
        SizedBox(width: 6.w),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 10.sp,
              color: Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}