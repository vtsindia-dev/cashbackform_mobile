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

  ReservePlotsScreen({super.key, required this.reserveButtonKey,});
  @override
  State<ReservePlotsScreen> createState() => _ReservePlotsScreenState();
}

class _ReservePlotsScreenState extends State<ReservePlotsScreen> {
  final controller = Get.find<SyndicatePlotController>();
  final RazorpayController paymentcontroller = Get.put(RazorpayController());


  @override
  Widget build(BuildContext context) {
    return GetBuilder<SyndicatePlotController>(
      builder: (_) {
        final detail = controller.syndicateDetail.value;
        if (detail == null) {
          return SizedBox.shrink();
        }
        return Stack(
          children: [
            Column(
              children: [
                SizedBox(height: 10.h),
                Padding(
                  padding: EdgeInsets.all(8.w),
                  child: SubtitleWidget(
                    showViewAll: false,
                    title: "Plot Split-Up",
                    highlightWord: "Split-Up",
                  )
                      .animate()
                      .fadeIn(duration: 500.ms)
                      .slideY(begin: 0.3, end: 0),
                ),
                Container(
                  margin: EdgeInsets.all(8.w),
                  padding: EdgeInsets.only(
                    left: 12.w,
                    right: 12.w,
                    bottom: 12.w,
                    top: 20.h,
                  ),
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
                    image: const DecorationImage(
                      image: AssetImage(Images.appbarBg),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Total plots info
                      Padding(
                        padding: EdgeInsets.only(bottom: 10.h),
                        child: Text(
                          "Total Plots: ${detail.unitSpilt}",
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),

                      Wrap(
                        spacing: 15.w,
                        runSpacing: 10.h,
                        children: [
                          legendBox(
                            Colors.orange,
                            "Selected (${controller.selectedPlots.length})",
                          ).animate().fadeIn(delay: 100.ms),

                          legendBox(
                            const Color(0xFF3B711A),
                            "Booked (${controller.countStatus("booked")})",
                          ).animate().fadeIn(delay: 200.ms),

                          legendBox(
                            const Color(0xFFB8D79A),
                            "Available (${controller.countStatus("available")})",
                          ).animate().fadeIn(delay: 300.ms),
                        ],
                      ),

                      SizedBox(height: 20.h),

                      // Dynamic grid based on API data
                      controller.plots.isEmpty
                          ? Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.h),
                          child: CircularProgressIndicator(),
                        ),
                      )
                          : GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controller.plots.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 10.h,
                          crossAxisSpacing: 10.w,
                          childAspectRatio: 2.6,
                        ),
                        itemBuilder: (context, index) {
                          final item = controller.plots[index];
                          final id = item["id"];
                          final type = item["status"];
                          final isSelected = controller.selectedPlots.contains(id);
                          return GestureDetector(
                              onTap: () => controller.toggleSelect(id, type),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: controller.getColor(type, isSelected),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  "Plot-$id",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )
                                  .animate()
                                  .fadeIn(delay: (50 * index).ms)
                                  .scale(
                                begin: const Offset(0.9, 0.9),
                                end: const Offset(1, 1),
                                duration: 300.ms,
                              )
                          );
                        },
                      ),
                      SizedBox(height: 5.h),
                      Center(
                        child: InkWell(
                          onTap: () {
                            paymentcontroller.openCheckout(
                              customerName: "Abishek Jr",
                              customerEmail: "abishek@gmail.com",
                              customerPhone: "9876543210",
                              amount: 15000*100,
                              description: "Premium Plan",
                            );
                          },
                          child: Container(
                            key: widget.reserveButtonKey,
                            width: 230.w,
                            height: 45.h,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.18),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                )
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              "Reserve Selected Plots",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                              .animate(
                            onPlay: (ctrl) => ctrl.repeat(),
                          )
                              .shake(
                            hz: 3,
                            offset: const Offset(4, 0),
                            duration: 1000.ms,
                            curve: Curves.easeInOut,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
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