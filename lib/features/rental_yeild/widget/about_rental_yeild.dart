import 'package:cashback_farms/common/api_constant.dart';
import 'package:cashback_farms/common/widget/share_action_button_widget.dart';
import 'package:cashback_farms/common/widget/view_on_map_button.dart';
import 'package:cashback_farms/features/rental_yeild/widget/rental_overview.dart';
import 'package:cashback_farms/features/syndicate_plot/widget/about_plot.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../common/colours.dart';
import '../../../common/widget/media_carousel_widget.dart';
import '../controller/rental_yield_controller.dart';
import '../model/rental_yeild_model.dart';

class AboutPlot extends StatelessWidget {
  final RentalDetailProperty property;
  final VoidCallback? onEnquirySent;
  const AboutPlot({super.key, required this.property, this.onEnquirySent});

  // ── Sold-out guard ──────────────────────────────────────────────────────────
  bool get _isSoldOut => property.soldStatus == 1;

  @override
  Widget build(BuildContext context) {
    final RentalYieldController controller = Get.find<RentalYieldController>();
    final amenities = property.amenities;
    final nearbyLocations = property.nearbyLocations;

    return Obx(() {
      final fullLocation = property.cityName.isNotEmpty && property.stateName.isNotEmpty
          ? '${property.address}, ${property.cityName}, ${property.stateName}'
          : property.address;

      final images = property.images.isNotEmpty
          ? property.images
          : ['https://via.placeholder.com/500x300.png?text=No+Image'];


      final cleanBaseUrl =
      ApiUrl.webSideBaseUrl.replaceAll('/public', '');

      final shareUrl =
          '$cleanBaseUrl/rental-yield-plots/details/${property.id}';


      return Column(
        children: [
          // ── Main card ────────────────────────────────────────────────────
          Container(
            margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.3),
                  blurRadius: 15.r,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Carousel
                _buildCarousel(images),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: SingleChildScrollView(
                    child: Row(
                      children: [
                        if (property.youtubeLink != null && property.youtubeLink!.isNotEmpty) ...[
                          ActionButtonWidget(
                            onTap: () async {
                              final Uri url = Uri.parse(property.youtubeLink??'');
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
                        if (property.id != null) ...[
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
                        if (property.id != null) ...[
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
                SizedBox(height: 10.h),
                if (_isSoldOut) _buildSoldOutBanner(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [_buildViewDetailsButton(controller)],
                ),
                _buildExpandedContent(property,fullLocation,property.description),
                // Obx(
                //       () => _buildExpandableSection(
                //     controller,
                //     propertyName: property.name,
                //     fullLocation: fullLocation,
                //     description: property.description,
                //     monthlyRent: '₹ ${property.rentAmount}',
                //     annualYield: property.yieldAmount,
                //     property: property,
                //   ),
                // ),
                SizedBox(height: 15.h),
                _buildSimpleEnquiryButton(controller, property),
              ],
            ),
          ),
          RentalOverview(price: property.totalDocumentPrice.toString(),),
          SizedBox(height: 10.h),
          if (property.lat != null && property.lng != null) ...[
            SizedBox(height: 10.h),
            _buildHeaderWithMap(property.lat!, property.lng!, fullLocation),
            SizedBox(height: 10.h),
          ],
          _buildPropertyHeader(fullLocation),
          if (amenities.isNotEmpty) ...[
            SizedBox(height: 15.h),
            _buildAmenitiesSection(amenities),
          ],
          if (nearbyLocations.isNotEmpty) ...[
            SizedBox(height: 15.h),
            _buildNearbyLocationsSection(nearbyLocations),
          ],

          SizedBox(height: 10.h),
        ],
      );
    });
  }

  Widget _buildExpandedContent(RentalDetailProperty? property,String? fullLocation,String? description) {
    if (property == null) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 6.h),
          // buildDetailRow(
          //     label: 'Property Type',
          //     value: property.propertyType?.categoryName ?? 'N/A',
          //     delay: 0.ms,
          //     index: 0,
          //     valueColor: AppColor.primary),
          // SizedBox(height: 8.h),
          buildDetailRow(
              label: 'Project Name',
              value: property.name,
              delay: 50.ms,
              index: 1),
          SizedBox(height: 8.h),
          buildDetailRow(
              label: 'Total Amount',
              value: '₹ ${property.totalPrice}',
              delay: 250.ms,
              index: 5),
          SizedBox(height: 8.h),
          buildDetailRow(
              label: 'Per Sq.Ft',
              value: '₹ ${property.amountPay} sq.ft',
              delay: 250.ms,
              index: 5),
          SizedBox(height: 8.h),
          buildDetailRow(
              label: 'Plot Area',
              value: property.area ?? 'N/A',
              delay: 150.ms,
              index: 3),
          SizedBox(height: 8.h),
          buildDetailRow(
              label: 'Plot Type',
              value: property.propertyCategory?.categoryName ?? 'N/A',
              delay: 150.ms,
              index: 3),
          SizedBox(height: 8.h),
          buildDetailRow(
              label: 'ULPIN',
              value: property.ulpnNo ??"",
              delay: 350.ms,
              index: 7),
          if (property.soldStatus ==1) ...[
            SizedBox(height: 8.h),
            buildDetailRow(
              label: 'Availability',
              value: 'SOLD OUT',
              delay: 400.ms,
              index: 8,
              valueColor: Colors.red.shade700,
            ),
          ],
          Divider(color: Colors.grey.withValues(alpha: 0.2),),
          _buildDescriptionWithSeeMore(description??''),
          SizedBox(height: 14.h),
        ],
      ),
    );
  }


  Widget _buildSoldOutBanner() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.red.shade300, width: 1.2),
      ),
      child: Row(
        children: [
          Icon(Icons.block_rounded, color: Colors.red.shade700, size: 18.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Property Sold Out',
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'This property is no longer available for booking or document purchase.',
                  style: TextStyle(
                    color: Colors.red.shade600,
                    fontSize: 11.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  // ==========================================================================
  // ENQUIRY BUTTON — sold-out aware
  // ==========================================================================

  Widget _buildSimpleEnquiryButton(
      RentalYieldController controller,
      RentalDetailProperty property,
      ) {
    final bool isSoldOut = _isSoldOut;
    final bool isBooked = property.booked == true;
    final bool isEnquiredBySomeone = property.isAnyoneBooked == true;

    // Determine button state
    String buttonText;
    IconData buttonIcon;
    List<Color> gradientColors;
    bool tappable;

    if (isSoldOut) {
      buttonText = 'Sold Out';
      buttonIcon = Icons.block_rounded;
      gradientColors = [Colors.grey.shade400, Colors.grey.shade600];
      tappable = false;
    } else if (isBooked) {
      buttonText = 'Enquired';
      buttonIcon = Icons.check_circle_rounded;
      gradientColors = [Colors.green.shade400, Colors.green.shade600];
      tappable = false;
    } else if (isEnquiredBySomeone) {
      buttonText = 'Enquired By Someone';
      buttonIcon = Icons.people_alt_rounded;
      gradientColors = [Colors.orange.shade400, Colors.orange.shade600];
      tappable = false;
    } else {
      buttonText = 'Send Enquiry';
      buttonIcon = Icons.send_rounded;
      gradientColors = [AppColor.primary, AppColor.primarylite];
      tappable = true;
    }

    // Hide if no documents (existing rule)
    if (property.documents.isEmpty && !isSoldOut) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Obx(
            () => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(35.r),
            boxShadow: tappable
                ? [
              BoxShadow(
                color: gradientColors.last.withValues(alpha:0.25),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ]
                : [],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(35.r),
            child: InkWell(
              borderRadius: BorderRadius.circular(35.r),
              onTap: tappable && !controller.isEnquiryLoading.value
                  ? () => onEnquirySent?.call()
                  : null,
              child: Ink(
                width: double.infinity,
                padding:
                EdgeInsets.symmetric(vertical: 5.h, horizontal: 18.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradientColors,
                  ),
                  borderRadius: BorderRadius.circular(35.r),
                ),
                child: controller.isEnquiryLoading.value && tappable
                    ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 20.sp,
                      width: 20.sp,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.1,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      'Processing...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.sp),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha:0.18),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(buttonIcon,
                          size: 16.sp, color: Colors.white),
                    ),
                    SizedBox(width: 12.w),
                    Flexible(
                      child: Text(
                        buttonText,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // YIELD — show formatted amount, not just the raw number
  // ==========================================================================

  /// Formats yield for display.
  /// If the value looks like a percentage (≤ 100), appends "%".
  /// Otherwise formats as a currency amount.
  String _formatYield(String raw) {
    final double? val = double.tryParse(raw);
    if (val == null) return raw;
    if (val <= 100) {
      // Treat as percentage
      return '${val.toStringAsFixed(val % 1 == 0 ? 0 : 2)}%';
    }
    // Treat as rupee amount
    if (val >= 10000000) {
      return '₹${(val / 10000000).toStringAsFixed(2)} Cr/yr';
    } else if (val >= 100000) {
      return '₹${(val / 100000).toStringAsFixed(2)} L/yr';
    } else if (val >= 1000) {
      return '₹${(val / 1000).toStringAsFixed(1)}K/yr';
    }
    return '₹${val.toStringAsFixed(0)}/yr';
  }

  // ==========================================================================
  // CAROUSEL
  // ==========================================================================

  Widget _buildCarousel(List<String> images) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.r),
              topRight: Radius.circular(20.r),
            ),
            child: MediaCarouselScreen(images: images, height: 190.h),
          ),
        ),
        // Sold-out overlay on image
        if (_isSoldOut)
          Positioned(
            top: 14.h,
            left: 14.w,
            child: Container(
              padding:
              EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: Colors.red.shade700.withValues(alpha:0.92),
                borderRadius: BorderRadius.circular(10.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha:0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.block_rounded,
                      color: Colors.white, size: 12.sp),
                  SizedBox(width: 4.w),
                  Text(
                    'SOLD OUT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // ==========================================================================
  // VIEW DETAILS BUTTON
  // ==========================================================================

  Widget _buildViewDetailsButton(RentalYieldController controller) {
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
              controller.isExpanded.value ? 'Hide Details' : 'View Details',
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

  // ==========================================================================
  // EXPANDABLE DETAILS SECTION
  // ==========================================================================

  Widget _buildExpandableSection(
      RentalYieldController controller, {
        required String propertyName,
        required String fullLocation,
        required String description,
        required String monthlyRent,
        required String annualYield,
        required RentalDetailProperty property,
      }) {
    return AnimatedContainer(
      duration: 400.ms,
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      height: controller.isExpanded.value ? null : 0,
      child: controller.isExpanded.value
          ? _rentalDetailsContent(
        propertyName: propertyName,
        fullLocation: fullLocation,
        description: description,
        monthlyRent: monthlyRent,
        annualYield: annualYield,
        property: property,
      )
          : const SizedBox(),
    );
  }

  Widget _rentalDetailsContent({
    required String propertyName,
    required String fullLocation,
    required String description,
    required String monthlyRent,
    required String annualYield,
    required RentalDetailProperty property,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8.h),
        _headerBox(propertyName)
            .animate()
            .slideX(begin: 0.3, end: 0)
            .fadeIn()
            .scale(
            begin: const Offset(0.95, 0.95),
            end: const Offset(1, 1)),
        SizedBox(height: 10.h),
        _detailRow('Location', fullLocation)
            .animate()
            .slideX(begin: 0.3, end: 0)
            .fadeIn()
            .scale(
            begin: const Offset(0.95, 0.95),
            end: const Offset(1, 1)),
        SizedBox(height: 12.h),
        _rentalInfoGrid(
          monthlyRent: monthlyRent,
          annualYield: annualYield,
          property: property,
        ),
        SizedBox(height: 15.h),
        _buildDescriptionWithSeeMore(description),
        SizedBox(height: 20.h),
      ],
    );
  }

  Widget _rentalInfoGrid({
    required String monthlyRent,
    required String annualYield,
    required RentalDetailProperty property,
  }) {
    // FIX: show formatted yield amount/percentage, not the raw number
    final items = [
      {'title': 'Monthly Rent', 'value': monthlyRent},
      {'title': 'Annual Yield', 'value': _formatYield(annualYield)},
      {'title': 'Area', 'value': '${property.area ?? 'N/A'} Sq.ft'},
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
          final index = entry.key;
          final item = entry.value;
          return _gridItem(item['title']!, item['value']!)
              .animate()
              .slideX(begin: 0.5, end: 0)
              .fadeIn(duration: 400.ms)
              .scale(
              begin: const Offset(0.9, 0.9),
              end: const Offset(1, 1))
              .then(
              delay:
              Duration(milliseconds: 100 * index));
        }).toList(),
      ),
    );
  }

  // ==========================================================================
  // SHARED HELPERS (unchanged from original)
  // ==========================================================================

  Widget _buildDescriptionWithSeeMore(String description) {
    final showAll = ValueNotifier<bool>(false);
    const maxChars = 150;

    return ValueListenableBuilder<bool>(
      valueListenable: showAll,
      builder: (context, showAllValue, child) {
        final isLong = description.length > maxChars;
        final displayText = showAllValue || !isLong
            ? description
            : '${description.substring(0, maxChars)}…';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Description'),
            SizedBox(height: 8.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedSize(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeInOut,
                    child: Text(
                      displayText,
                      style: TextStyle(
                        fontSize: 14.sp,
                        height: 1.65,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                  if (isLong) ...[
                    SizedBox(height: 4.h),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () => showAll.value = !showAllValue,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              showAllValue ? 'Show less' : 'See more',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColor.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 2.w),
                            AnimatedRotation(
                              turns: showAllValue ? 0.5 : 0,
                              duration: const Duration(milliseconds: 300),
                              child: Icon(
                                Icons.keyboard_arrow_down,
                                size: 16.sp,
                                color: AppColor.primary,
                              ),
                            ),
                          ],
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

  Widget _gridItem(String title, String value) {
    return Container(
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        color: AppColor.primary.withValues(alpha:0.05),
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
                fontSize: 13.sp, fontWeight: FontWeight.w600),
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
        color: AppColor.primary.withValues(alpha:0.1),
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
          '$label : ',
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
                fontSize: 13.sp, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.bold,
        color: AppColor.primary,
      ),
    );
  }

  Widget _buildPropertyHeader(String address) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 45.w,
            height: 45.w,
            decoration: BoxDecoration(
              color: AppColor.primary.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Center(
              child: Icon(Icons.location_on_outlined,
                  color: AppColor.primary, size: 25.w),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Property location',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColor.textMain.withValues(alpha:0.8),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  address,
                  style: TextStyle(
                      fontSize: 12.sp, color: Colors.grey.shade600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderWithMap(
      double latitude, double longitude, String address) {
    final mapsUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Location Details',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
              color: AppColor.textMain,
            ),
          ),
          ViewOnMapButton(
            onTap: () async {
              final uri = Uri.parse(mapsUrl);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              } else {
                debugPrint('Could not launch $mapsUrl');
              }
            },
          )
        ],
      ),
    );
  }


  Widget _buildAmenitiesSection(List<AmenityModel> amenities) {
    final scrollController = ScrollController();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _sectionTitle('Amenities'),
              _countBadge(amenities.length),
            ],
          ),
        ),
        SizedBox(height: 10.h),
        SizedBox(
          height: 95.h,
          child: Row(
            children: [
              if (amenities.length > 2)
                _arrowButton(scrollController, false, amenities.length),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  itemCount: amenities.length,
                  itemBuilder: (_, i) => _buildAmenityCard(amenities[i])
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideX(begin: 0.5, end: 0),
                ),
              ),
              if (amenities.length > 2)
                _arrowButton(scrollController, true, amenities.length),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAmenityCard(AmenityModel amenity) {
    return Container(
      width: 140.w,
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 8.r,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppColor.primary.withValues(alpha:0.05),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: amenity.image.isNotEmpty
                ? Image.network(
              amenity.image,
              width: 32.w,
              height: 32.h,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Icon(
                  Icons.category_outlined,
                  size: 24.sp,
                  color: AppColor.primary),
            )
                : Icon(Icons.category_outlined,
                size: 24.sp, color: AppColor.primary),
          ),
          SizedBox(height: 8.h),
          Text(
            amenity.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.bold,
              color: AppColor.textMain,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // NEARBY LOCATIONS
  // ==========================================================================

  Widget _buildNearbyLocationsSection(
      List<NearbyLocationDetail> nearbyLocations) {
    final scrollController = ScrollController();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _sectionTitle('Nearby Places'),
              _countBadge(nearbyLocations.length),
            ],
          ),
        ),
        SizedBox(height: 10.h),
        SizedBox(
          height: 113.h,
          child: Row(
            children: [
              if (nearbyLocations.length > 2)
                _arrowButton(
                    scrollController, false, nearbyLocations.length),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  itemCount: nearbyLocations.length,
                  itemBuilder: (_, i) =>
                      _buildNearbyPlaceCard(nearbyLocations[i])
                          .animate()
                          .fadeIn(duration: 400.ms)
                          .slideX(begin: 0.5, end: 0),
                ),
              ),
              if (nearbyLocations.length > 2)
                _arrowButton(
                    scrollController, true, nearbyLocations.length),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNearbyPlaceCard(NearbyLocationDetail location) {
    return Container(
      width: 160.w,
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 8.r,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppColor.primary.withValues(alpha:0.05),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: location.image.isNotEmpty
                ? Image.network(
              location.image,
              width: 32.w,
              height: 32.h,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Icon(
                  Icons.place_outlined,
                  size: 24.sp,
                  color: AppColor.primary),
            )
                : Icon(Icons.place_outlined,
                size: 24.sp, color: AppColor.primary),
          ),
          SizedBox(height: 8.h),
          Text(
            location.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.bold,
              color: AppColor.textMain,
            ),
          ),
          SizedBox(height: 4.h),
          Container(
            padding:
            EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              location.distance,
              style: TextStyle(
                fontSize: 9.sp,
                color: Colors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // TINY SHARED HELPERS
  // ==========================================================================

  Widget _countBadge(int count) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppColor.primary.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.bold,
          color: AppColor.primary,
        ),
      ),
    );
  }

  Widget _arrowButton(
      ScrollController sc, bool isRight, int itemCount) {
    return GestureDetector(
      onTap: () {
        if (itemCount <= 2) return;
        final offset = isRight ? sc.offset + 180.0 : sc.offset - 180.0;
        sc.animateTo(
          offset.clamp(0.0, sc.position.maxScrollExtent),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      child: Container(
        width: 36.w,
        height: 36.w,
        margin: EdgeInsets.symmetric(horizontal: 2.w),
        decoration: BoxDecoration(
          color: AppColor.primary.withValues(alpha:0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          isRight
              ? Icons.arrow_forward_ios_rounded
              : Icons.arrow_back_ios_rounded,
          size: 16.sp,
          color: AppColor.primary,
        ),
      ),
    );
  }
}