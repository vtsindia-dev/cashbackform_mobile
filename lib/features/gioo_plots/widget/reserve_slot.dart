import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../common/colours.dart';
import '../controller/gioo_controller.dart';
import '../model/gioo_plot.dart';
import 'package:lottie/lottie.dart';

class ReserveSlot extends StatelessWidget {
  const ReserveSlot({super.key});
  @override
  Widget build(BuildContext context) {
    final GiooPlotController controller = Get.find<GiooPlotController>();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      child: Container(
        constraints: BoxConstraints(maxWidth: 900.w),
        decoration: BoxDecoration(
          color: AppColor.backgroundLight,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 4),
            )
          ],
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLegend(controller)
                      .animate()
                      .fade(duration: 350.ms)
                      .slideY(begin: 0.15),
                  15.h.verticalSpace,
                  _buildPlotGrid(controller)
                      .animate()
                      .fade(duration: 350.ms),
                ],
              ),
            ),

            Divider(height: 1, color: Colors.black.withOpacity(0.1)),

            _buildSidebarCard(controller)
                .animate()
                .fade(duration: 450.ms)
                .slideY(begin: 0.1),
          ],
        ),
      ),
    );
  }

  // LEGEND ----------------------------------------------------------------
  Widget _buildLegend(GiooPlotController controller) {
    return Obx(() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "GreenHeap Plots",
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: AppColor.textMain,
          ),
        ),
        10.h.verticalSpace,
        Row(
          children: [
            _legendItem( AppColor.orange, "Selected (${controller.selectedCount.value})"),
            12.w.horizontalSpace,
            _legendItem(AppColor.primary, "Booked (${controller.bookedCount.value})"),
            12.w.horizontalSpace,
            _legendItem(Colors.grey.withOpacity(0.5), "Available (${controller.availableCount.value})"),
          ],
        ),
      ],
    ));
  }
  Widget _legendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 18.w, // Bigger box
          height: 18.w,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4.r),
          ),
        ),
        8.w.horizontalSpace,
        Text(text, style: TextStyle(fontSize: 12.sp, color: AppColor.textMain)),
      ],
    );
  }
  Widget _buildPlotGrid(GiooPlotController controller) {
    return Obx(
          () => GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 10,
          crossAxisSpacing: 6.w,
          mainAxisSpacing: 6.h,
          childAspectRatio: 1.0,
        ),
        itemCount: controller.units.length.clamp(0, 100),
        itemBuilder: (context, index) {
          final unit = controller.units[index];

          Color color;
          switch (unit.status) {
            case 'Selected':
              color = AppColor.orange;
              break;
            case 'Booked':
              color = AppColor.primary;
              break;
            default:
              color = Colors.grey.withOpacity(0.5);
          }

          return InkWell(
            onTap: unit.status == 'Booked'
                ? null
                : () => controller.toggleUnitSelection(unit.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10.r), // bigger radius
                border: unit.status == 'Selected'
                    ? Border.all(color: AppColor.orangeAccent, width: 2.w)
                    : null,
              ),
              child: Center(
                child: Text(
                  unit.label,
                  style: TextStyle(
                    fontSize: 14.sp, // bigger text
                    color: unit.status == 'Available' ? AppColor.textMain : Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
                .animate(onPlay: (controller) => controller.repeat()) // repeat shimmer
                .shimmer(duration: 3000.ms, color: Colors.white.withOpacity(0.5)),
          );
        },
      ),
    );
  }

  // SIDEBAR ---------------------------------------------------------------
  Widget _buildSidebarCard(GiooPlotController controller) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(25.w),
      decoration: BoxDecoration(
        color: AppColor.backgroundLight,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16.r),
          bottomRight: Radius.circular(16.r),
        ),
      ),
      child: Obx(() {
        final detail = controller.giooPlotDetail.value;

        if (detail == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLocationDetail(controller, detail)
                .animate()
                .fade(duration: 350.ms),
            20.h.verticalSpace,
            _buildStatusAndUnitInfo(controller, detail)
                .animate()
                .fade(duration: 350.ms),
            20.h.verticalSpace,
            _buildPriceSummary(controller)
                .animate()
                .fade(duration: 350.ms),
            30.h.verticalSpace,
            _buildPayNowButton(controller)

          ],
        );
      }),
    );
  }

  Widget _buildLocationDetail(GiooPlotController controller, GiooPlotDetail detail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.location_on_outlined, color: AppColor.black, size: 18.w),
            5.w.horizontalSpace,
            Text(
              "Property location",
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColor.black,
              ),
            ),
          ],
        ),
        10.h.verticalSpace,
        Text(
          detail.address ?? "No address",
          style: TextStyle(fontSize: 12.sp, color: AppColor.black,),
        ),
        5.h.verticalSpace,
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "ULPIN Number: ",
                style: GoogleFonts.montserrat(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColor.primary,
                ),
              ),
              TextSpan(
                text: detail.uldNo ?? "N/A",
                style: GoogleFonts.montserrat(
                  fontSize: 12.sp,
                  color: AppColor.black,
                ),
              ),
            ],
          ),
        ),      ],
    );
  }


  Widget _buildStatusAndUnitInfo(GiooPlotController controller, GiooPlotDetail detail) {
    final dateFormatter = DateFormat('dd MMM yyyy'); // e.g., 28 Nov 2025
    final timeFormatter = DateFormat('hh:mm a');    // e.g., 09:45 AM

    final createdDate = dateFormatter.format(detail.createdAt);
    final createdTime = timeFormatter.format(detail.createdAt);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                detail.name,
                style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColor.black),
              ),
            ),
            Row(
              children: [
                Icon(Icons.check_circle, size: 16.w, color: AppColor.black),
                5.w.horizontalSpace,
                Text(
                  "Approved Plot",
                  style: TextStyle(fontSize: 12.sp, color: AppColor.black),
                ),
              ],
            ),
          ],
        ),
        15.h.verticalSpace,
        Row(
          children: [
            _infoItem(Icons.calendar_today_outlined, createdDate, AppColor.black),
            20.w.horizontalSpace,
            _infoItem(Icons.access_time, createdTime, AppColor.black),
          ],
        ),
        10.h.verticalSpace,
        _infoItem(Icons.location_city_outlined, controller.getSelectedUnitRange(), AppColor.black),
      ],
    );
  }

  Widget _infoItem(IconData icon, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 30.w,
          height: 30.w,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Center(
            child: Icon(icon, size: 16.w, color: color),
          ),
        ),
        10.w.horizontalSpace,
        Text(
          value,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSummary(GiooPlotController controller) {
    final detail = controller.giooPlotDetail.value;
    if (detail == null) return const SizedBox();

    // Use API values
    final totalArea = detail.area;
    final pricePerUnit = detail.price;
    final totalPriceUnits = detail.totalPrice ?? "0"; // fallback
    final totalFinalPrice = detail.totalPrice ?? "0";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Price of Selected plots",
          style: TextStyle(
              fontSize: 15.sp, fontWeight: FontWeight.bold, color: AppColor.black),
        ),
        15.h.verticalSpace,
        _priceRow("Plot Area:", "$totalArea sq.ft"),
        5.h.verticalSpace,
        _priceRow("Price per unit:", "₹$pricePerUnit"),
        5.h.verticalSpace,
        _priceRow("Total Price:", "₹$totalPriceUnits"),
        Divider(height: 20, color: Colors.black.withOpacity(0.1)),
        _priceRow("Total Payable:", "₹$totalFinalPrice", isBold: true),
      ],
    );
  }

  Widget _priceRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13.sp, color: AppColor.primary,fontWeight: FontWeight.bold)),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: isBold ? FontWeight.bold : FontWeight.bold,
            color: AppColor.black,
          ),
        ),
      ],
    );
  }


  Widget _buildPayNowButton(GiooPlotController controller) {
    final enabled = controller.selectedUnits.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "Will Process your Registration After payment",
          style: TextStyle(fontSize: 10.sp, color: AppColor.black),
        ),

        10.h.verticalSpace,

        GestureDetector(
          onTap: enabled ? controller.proceedToPayment : null,
          child: Container(
            height: 55.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: enabled
                  ? AppColor.orange
                  : AppColor.orange.withOpacity(0.5),
              borderRadius: BorderRadius.circular(35.r),
            ),

            // 👇 The row is INSIDE the container
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // LEFT SIDE LOTTIE
                SizedBox(
                  width: 60.w,
                  height: 50.w,
                  child: Lottie.asset(
                    "assets/images/paynow.json",
                    repeat: true,
                  ),
                ),

                10.w.horizontalSpace,

                // PAY NOW TEXT
                Text(
                  "Pay Now",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColor.black,
                  ),
                ),
                SizedBox(width: 30.w,)
              ],
            ),
          ),
        ),
      ],
    );
  }
}
