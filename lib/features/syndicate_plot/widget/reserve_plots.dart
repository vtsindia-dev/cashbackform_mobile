import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../common/colours.dart';
import '../../../common/images.dart';
import '../../../common/widget/toster.dart';
import '../../home/widget/sub_title.dart';
import '../../legal_and_policies/screen.dart';
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

        // Check if property is sold out
        final isSoldOut = detail.isSoldOut == true;

        final selectedCount = controller.selectedPlots.length;
        final pricePerPlot = controller.getPricePerPlotFromAdminBlock();
        double totalAmount = 0;
        if (selectedCount > 0 && !isSoldOut) {
          totalAmount = controller.calculateSelectedPlotsAmount();
          print('💰 Screen - Selected: $selectedCount, Price per plot: $pricePerPlot, Total: $totalAmount');
        }
        final amountWithGst = totalAmount;
        final plotAreas = controller.getPlotAreas();
        final totalArea = plotAreas.fold(0.0, (sum, area) => sum + area);

        // Check if payment can proceed
        final canProceedToPayment = !isSoldOut &&
            selectedCount > 0 &&
            controller.isTermsAccepted.value;

        // Remove Expanded and use SingleChildScrollView directly
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(vertical: 10.h),
          child: Column(
            children: [
              // Show sold out banner if applicable
              if (isSoldOut) _buildSoldOutBanner(),

              if (!isSoldOut) ...[
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
              ],

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
                    // Price and Area info - hide if sold out
                    if (!isSoldOut) ...[
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
                    ],

                    // Legend - hide if sold out
                    if (!isSoldOut)
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

                    if (!isSoldOut) SizedBox(height: 20.h),

                    // Dynamic grid based on API data
                    controller.plots.isEmpty
                        ? (isSoldOut ? SizedBox.shrink() : Center(child: CircularProgressIndicator()))
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
                          // Disable tapping if sold out
                          onTap: isSoldOut ? null : () => controller.toggleSelect(id, type),
                          child: Container(
                            decoration: BoxDecoration(
                              // Use grey color for sold out state
                              color: isSoldOut
                                  ? Colors.grey[400]
                                  : controller.getColor(type, isSelected),
                              borderRadius: BorderRadius.circular(8.r),
                              border: isSelected && !isSoldOut
                                  ? Border.all(color: Colors.white, width: 2)
                                  : null,
                              boxShadow: isSelected && !isSoldOut
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
                                    color: isSoldOut ? Colors.grey[700] : Colors.white,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  formattedArea,
                                  style: TextStyle(
                                    color: isSoldOut ? Colors.grey[700] : Colors.white,
                                    fontSize: 9.sp,
                                  ),
                                ),
                                if (isSelected && !isSoldOut)
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

                    // Payment Summary - only show if not sold out and plots selected
                    if (!isSoldOut && selectedCount > 0) ...[
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

                    SizedBox(height: 8.h),

                    // Terms and Conditions Checkbox
                    Center(
                      child: gioTermsCheckbox(),
                    ),

                    SizedBox(height: 8.h),

                    // Payment Button with terms validation
                    Center(
                      child: InkWell(
                        onTap: () {
                          if (isSoldOut) {
                            SnackBarHelper.showError("This property is sold out");
                            return;
                          }
                          if (selectedCount == 0) {
                            SnackBarHelper.showError("Please select at least one plot");
                            return;
                          }
                          if (!controller.isTermsAccepted.value) {
                            SnackBarHelper.showError("Please accept the Terms & Conditions");
                            return;
                          }
                          controller.initiatePlotPayment();
                        },
                        child: Container(
                          key: widget.reserveButtonKey,
                          width: 230.w,
                          height: 45.h,
                          decoration: BoxDecoration(
                            color: canProceedToPayment
                                ? Colors.green
                                : (isSoldOut || selectedCount == 0)
                                ? Colors.grey[400]
                                : Colors.grey[300],
                            borderRadius: BorderRadius.circular(30.r),
                            boxShadow: canProceedToPayment
                                ? [
                              BoxShadow(
                                color: Colors.green.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              )
                            ]
                                : null,
                            border: Border.all(
                              color: canProceedToPayment
                                  ? Colors.green[700]!
                                  : Colors.grey,
                              width: 1,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                isSoldOut
                                    ? "Sold Out"
                                    : (selectedCount > 0
                                    ? "Pay ₹${amountWithGst.toStringAsFixed(2)}"
                                    : "Select Plots to Reserve"),
                                style: TextStyle(
                                  color: canProceedToPayment || isSoldOut
                                      ? Colors.white
                                      : Colors.grey,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              if (!isSoldOut && selectedCount > 0 && !controller.isTermsAccepted.value) ...[
                                SizedBox(height: 2.h),
                                Text(
                                  "Accept terms to proceed",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 10.sp,
                                  ),
                                ),
                              ],
                              if (!isSoldOut && selectedCount > 0 && controller.isTermsAccepted.value) ...[
                                SizedBox(height: 2.h),
                                Text(
                                  "${selectedCount} plot${selectedCount > 1 ? 's' : ''} selected • Fixed amount",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 10.sp,
                                  ),
                                ),
                              ],
                              if (isSoldOut) ...[
                                SizedBox(height: 2.h),
                                Text(
                                  "No longer available",
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
                          hz: canProceedToPayment ? 3 : 0,
                          offset: const Offset(4, 0),
                          duration: 1000.ms,
                          curve: Curves.easeInOut,
                        ),
                      ),
                    ),

                    // Info text - only show if not sold out and plots selected
                    if (!isSoldOut && selectedCount > 0) ...[
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

                    // Add bottom padding for better scrolling experience
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ],
          ),
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

  Widget gioTermsCheckbox() {
    return Obx(
          () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => controller.isTermsAccepted.value = !controller.isTermsAccepted.value,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
              decoration: BoxDecoration(
                color: controller.isTermsAccepted.value
                    ? AppColor.primary.withOpacity(0.1)
                    : AppColor.textMain.withOpacity(0.03),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: controller.isTermsAccepted.value ? AppColor.primary : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 24.h,
                    width: 24.w,
                    child: Checkbox(
                      value: controller.isTermsAccepted.value,
                      activeColor: AppColor.primary,
                      side: BorderSide(color: AppColor.textMain, width: 2.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      onChanged: (value) {
                        controller.isTermsAccepted.value = value ?? false;
                      },
                    ),
                  ),
                  12.w.horizontalSpace,
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColor.textMain,
                          fontWeight: FontWeight.bold,
                          height: 1.4,
                        ),
                        children: [
                          const TextSpan(text: "I have read and agree to the "),
                          TextSpan(
                            text: "Terms & Conditions",
                            style: TextStyle(
                              color: AppColor.primary,
                              fontWeight: FontWeight.w900,
                              decoration: TextDecoration.underline,
                              decorationThickness: 2.0,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Get.to(() => LegalPageScreen(
                                  slug: "gio_rental_yield_syndicate_plot_reserve_and_document_download_terms_and_condition",
                                  title: "Terms & Conditions",
                                ));
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Error Hint
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: (!controller.isTermsAccepted.value && controller.selectedPlots.isNotEmpty) ? 24.h : 0,
            padding: EdgeInsets.only(left: 12.w, top: 6.h),
            child: Text(
              "● Please accept terms to continue",
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.red.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Sold out banner widget
  Widget _buildSoldOutBanner() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.red.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8.r,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.block_rounded, color: Colors.red.shade600, size: 28.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Property Sold Out",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  "All plots in this property have been booked. No new bookings are available.",
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.red.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1, end: 0);
  }
}