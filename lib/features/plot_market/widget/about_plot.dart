import 'package:cashback_farms/common/api_constant.dart';
import 'package:cashback_farms/common/widget/share_action_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../common/colours.dart';
import '../../../common/widget/media_carousel_widget.dart';
import '../controller/plot_market_controller.dart';

class AboutPlot extends StatelessWidget {
  const AboutPlot({super.key});

  @override
  Widget build(BuildContext context) {
    final PlotMarketController controller = Get.find<PlotMarketController>();

    return Obx(() {
      final detail = controller.marketDetail.value;

      final projectName = detail?.name ?? 'No Name';
      final location = detail?.fullAddress ?? 'No Address';
      final plotCounts = '${detail?.plotCount ?? 0} Plots';
      final plottype = detail?.propertyType?.categoryName ?? 'Not Defined';
      final propertyId = detail?.id ?? 0; // Get property ID

      // Dynamic verify status with proper text mapping
      final verifiedStatus = _getVerifyStatusText(detail?.verifyStatus ?? 0);

      final plotAreaSqFt = '${detail?.area ?? 0} Sq.ft';
      final totalPrice = '₹ ${detail?.price ?? '0'}';
      final pricePerSqFt = '${detail?.pricePerSqft ?? '0'}';

      // Dynamic dates from the API
      final postedDate = _formatDate(detail?.createdAt);
      final lastUpdate = _formatDate(detail?.updatedAt);

      // Check if property is sold out
      final isSoldOut = detail?.status == 0 || detail?.soldout == 1;

      final images = detail?.images.isNotEmpty == true
          ? detail!.images
          : ["https://via.placeholder.com/500x300.png?text=No+Image"];

      final cleanBaseUrl = ApiUrl.webSideBaseUrl.replaceAll('/public', '');

      final shareUrl =
          '$cleanBaseUrl/plot-marketplace/details/${detail?.id}';

      return Container(
        margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 15.r,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildCarousel(images, detail?.shareLink ?? '', isSoldOut),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: SingleChildScrollView(
                child: Row(
                  children: [
                    if (detail?.youtubeLink != null && (detail?.youtubeLink?.isNotEmpty ?? false)) ...[
                      ActionButtonWidget(
                        onTap: () async {
                          final Uri url = Uri.parse(detail?.youtubeLink??'');
                          if (await canLaunchUrl(url)) {
                            await launchUrl(
                              url,
                              mode: LaunchMode.externalApplication,
                            );
                          } else {
                            Get.snackbar(
                              "Failed",
                              "Could not open video link",
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          }
                        },
                        title: "Watch Video",
                        icon: Image.asset(
                          'assets/images/youtube.png',
                          height: 18.h,
                        ),
                        textColor: Colors.red.shade800,
                        borderColor: Colors.red.shade200,
                        gradientColors: [
                          Colors.red.shade50,
                          Colors.red.shade100.withValues(alpha: 0.5),
                        ],
                      ),
                    ],
                    if (detail?.id != null) ...[
                      SizedBox(width: 8.w),
                      ActionButtonWidget(
                        onTap: () async {
                          final whatsappUrl = Uri.parse(
                            'https://wa.me/?text=${Uri.encodeComponent(shareUrl)}',
                          );

                          if (await canLaunchUrl(whatsappUrl)) {
                            await launchUrl(
                              whatsappUrl,
                              mode: LaunchMode.externalApplication,
                            );
                          }
                        },
                        title: "WhatsApp",
                        icon: Image.asset(
                          'assets/images/whatsapp (1).png',
                          height: 18.h,
                        ),
                        bgColor: Colors.grey.shade100,
                        borderColor: Colors.grey.shade300,
                        textColor: Colors.grey.shade800,
                      ),
                    ],
                    if (detail?.id != null) ...[
                      SizedBox(width: 8.w),
                      ActionButtonWidget(
                        onTap: () {
                          Share.share(shareUrl);
                        },
                        title: "Share",
                        icon: Icon(
                          Icons.share_outlined,
                          size: 16.sp,
                          color: AppColor.black.withValues(alpha:0.8),
                        ),
                        bgColor: Colors.grey.shade100,
                        borderColor: Colors.grey.shade300,
                        textColor: Colors.grey.shade800,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            SizedBox(height: 15.h,),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [_buildViewDetailsButton(controller)],
            ),
            Obx(
                  () => _buildExpandableSection(
                controller,
                projectName: projectName,
                location: location,
                plotCounts: plotCounts,
                verifiedStatus: verifiedStatus,
                plotAreaSqFt: plotAreaSqFt,
                totalPrice: totalPrice,
                pricePerSqFt: pricePerSqFt,
                postedDate: postedDate,
                lastUpdate: lastUpdate,
                isSoldOut: isSoldOut,
                plottype: plottype,
                propertyId: propertyId, // Pass property ID
              ),
            ),
          ],
        ),
      );
    });
  }

  // Helper method to get verify status text
  String _getVerifyStatusText(int status) {
    switch (status) {
      case 0:
        return 'Pending';
      case 1:
        return 'Verified ✓';
      case 2:
        return 'Rejected';
      case 3:
        return 'Under Review';
      default:
        return 'Not Defined';
    }
  }

  // Helper method to get status color (optional, for visual indicator)
  Color _getVerifyStatusColor(int status) {
    switch (status) {
      case 0:
        return Colors.orange;
      case 1:
        return Colors.green;
      case 2:
        return Colors.red;
      case 3:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  // Helper method to format date
  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) return 'Not Available';
    return DateFormat('dd/MM/yyyy').format(dateTime.toLocal());
  }

  Widget _buildCarousel(List<String> images, String shareLink, bool isSoldOut) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
        child: Stack(
          children: [
            MediaCarouselScreen(
              images: images,
              height: 190.h,
            ),
            // Sold Out Badge
            if (isSoldOut)
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shopping_cart, size: 14.sp, color: Colors.white),
                      SizedBox(width: 4.w),
                      Text(
                        'SOLD OUT',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (shareLink.isNotEmpty)
              Positioned(
                top: 12,
                right: 12,
                child: GestureDetector(
                  onTap: () async {
                    await SharePlus.instance.share(
                      ShareParams(
                        text: shareLink,
                      ),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.share,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewDetailsButton(PlotMarketController controller) {
    return GestureDetector(
      onTap: controller.toggleExpansion,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        margin: EdgeInsets.only(right: 10.w, bottom: 8.h),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColor.primary, AppColor.primarylite],
          ),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          children: [
            Text(
              controller.isExpanded.value ? "Hide Details" : "View Details",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
            ),
            SizedBox(width: 6.w),
            Icon(
              controller.isExpanded.value
                  ? Icons.arrow_upward
                  : Icons.arrow_downward,
              color: Colors.black,
              size: 18.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableSection(
      PlotMarketController controller, {
        required String projectName,
        required String location,
        required String plotCounts,
        required String verifiedStatus,
        required String plotAreaSqFt,
        required String totalPrice,
        required String pricePerSqFt,
        required String postedDate,
        required String lastUpdate,
        required bool isSoldOut,
        required String plottype,
        required int propertyId, // Add propertyId parameter
      }) {
    return AnimatedContainer(
      duration: 400.ms,
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      height: controller.isExpanded.value ? null : 0,
      child: controller.isExpanded.value
          ? _detailsContent(
        projectName: projectName,
        location: location,
        plotCounts: plotCounts,
        verifiedStatus: verifiedStatus,
        plotAreaSqFt: plotAreaSqFt,
        totalPrice: totalPrice,
        pricePerSqFt: pricePerSqFt,
        postedDate: postedDate,
        lastUpdate: lastUpdate,
        isSoldOut: isSoldOut,
        plottype: plottype,
        propertyId: propertyId, // Pass propertyId
      )
          : const SizedBox(),
    );
  }

  Widget _detailsContent({
    required String projectName,
    required String location,
    required String plotCounts,
    required String verifiedStatus,
    required String plotAreaSqFt,
    required String totalPrice,
    required String pricePerSqFt,
    required String postedDate,
    required String lastUpdate,
    required bool isSoldOut,
    required String plottype,
    required int propertyId, // Add propertyId parameter
  }) {
    return GetBuilder<PlotMarketController>(
      builder: (controllerx) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8.h),
            _headerBox(projectName)
                .animate()
                .slideX(begin: 0.3, end: 0)
                .fadeIn()
                .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1)),
            SizedBox(height: 10.h),
            _detailRow('Location', location)
                .animate()
                .slideX(begin: 0.3, end: 0)
                .fadeIn()
                .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1)),
            SizedBox(height: 12.h),
            _plotInfoGrid(
              plotCounts: plotCounts,
              verifiedStatus: verifiedStatus,
              plotAreaSqFt: plotAreaSqFt,
              totalPrice: totalPrice,
              pricePerSqFt: pricePerSqFt,
              plottype: plottype,
            ),
            SizedBox(height: 15.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _dateBox(postedDate, 'Posted On')
                    .animate()
                    .slideX(begin: 0.2, end: 0)
                    .fadeIn(),
                _dateBox(lastUpdate, 'Last Update')
                    .animate()
                    .slideX(begin: 0.2, end: 0)
                    .fadeIn(),
              ],
            ),
            SizedBox(height: 20.h),
            // Show Sold Out button instead of Send Enquiry if sold out
            if (isSoldOut)
              _buildSoldOutButton()
                  .animate()
                  .shake(duration: 800.ms, hz: 2)
            else
              _centerEnquiryButton(controllerx, propertyId) // Pass propertyId
                  .animate(onPlay: (controller) => controller.repeat())
                  .shake(duration: 800.ms, hz: 2),
            SizedBox(height: 15.h),
          ],
        );
      },
    );
  }

  Widget _plotInfoGrid({
    required String plotCounts,
    required String verifiedStatus,
    required String plotAreaSqFt,
    required String totalPrice,
    required String pricePerSqFt,
    required String plottype,
  }) {
    final items = [
      {"title": "Plot Count", "value": plotCounts},
      {"title": "Verify Status", "value": verifiedStatus},
      {"title": "Plot Area", "value": plotAreaSqFt},
      {"title": "Total Price", "value": totalPrice},
      {"title": "Per Sq.Ft", "value": pricePerSqFt},
      {"title": "Plot Type", "value": plottype},
    ];

    return SizedBox(
      width: double.infinity,
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 2.5,
        children: items.asMap().entries.map((entry) {
          int index = entry.key;
          var item = entry.value;
          return _gridItem(item["title"]!, item["value"]!)
              .animate()
              .slideX(begin: 0.5, end: 0)
              .fadeIn(duration: 400.ms)
              .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1))
              .then(delay: Duration(milliseconds: 100 * index));
        }).toList(),
      ),
    );
  }

  Widget _gridItem(String title, String value) {
    return Container(
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        color: AppColor.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColor.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerBox(String name) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColor.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        name,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: AppColor.primary,
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$label : ",
          style: TextStyle(
            fontSize: 13.sp,
            color: AppColor.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _dateBox(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 10.sp, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildSoldOutButton() {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.grey.shade400,
          borderRadius: BorderRadius.circular(30.r),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shopping_cart, size: 18.sp, color: Colors.white),
            SizedBox(width: 8.w),
            Text(
              "Sold Out",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _centerEnquiryButton(PlotMarketController enquiryController, int propertyId) {
    return Obx(() => Center(
      child: InkWell(
        borderRadius: BorderRadius.circular(30.r),
        onTap: enquiryController.isEnquiryLoading.value
            ? null
            : () {
          // Pass property ID to sendEnquiry method
          enquiryController.sendEnquiry(propertyId);
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 12.h),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColor.primary, AppColor.primarylite],
            ),
            borderRadius: BorderRadius.circular(30.r),
          ),
          child: enquiryController.isEnquiryLoading.value
              ? SizedBox(
            height: 18.sp,
            width: 18.sp,
            child: const CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.black,
            ),
          )
              : Text(
            "Send Enquiry",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 15.sp,
            ),
          ),
        ),
      ),
    ));
  }
}