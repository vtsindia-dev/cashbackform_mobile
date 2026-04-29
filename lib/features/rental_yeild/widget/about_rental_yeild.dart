import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../common/colours.dart';
import '../../../common/widget/carousel.dart';
import '../../../common/widget/media_carousel_widget.dart';
import '../controller/rental_yield_controller.dart';
import '../model/rental_yeild_model.dart';

class AboutPlot extends StatelessWidget {
  final RentalDetailProperty property; // Updated type

  const AboutPlot({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    final RentalYieldController controller = Get.find<RentalYieldController>();
    final amenities = property.amenities ?? []         ;
    final nearbyLocations = property.nearbyLocations ?? [];

    return Obx(() {
      final propertyName = property.name ?? 'No Name';
      final yeildamout = property.yieldAmount ?? 'No Name';
      final location = property.address ?? 'No Address';
      final city = property.cityName ?? '';
      final state = property.stateName ?? '';
      final fullLocation = city.isNotEmpty && state.isNotEmpty
          ? '$location, $city, $state'
          : location;

      final rentAmount = '₹ ${property.rentAmount ?? '0'}';
      final yieldAmount = '${property.yieldAmount ?? '0'}';
      final description = property.description ?? 'No description available';

      final images = property.images.isNotEmpty
          ? property.images
          : ["https://via.placeholder.com/500x300.png?text=No+Image"];

      // Get coordinates for Google Maps
      final lat = property.lat;
      final lng = property.lng;

      return Column(
        children: [
          Container(
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
                _buildCarousel(images),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [_buildViewDetailsButton(controller)],
                ),
                Obx(
                      () => _buildExpandableSection(
                    controller,
                    propertyName: propertyName,
                    fullLocation: fullLocation,
                    description: description,
                    monthlyRent: rentAmount,
                    annualYield: yieldAmount,
                    property: property,
                  ),
                ),
                SizedBox(height: 15.h),
                _buildSimpleEnquiryButton(controller, property),
                SizedBox(height: 15.h),
              ],
            ),
          ),
          if (amenities.isNotEmpty) ...[
            SizedBox(height: 15.h),
            _buildAmenitiesSection(amenities),
          ],
          if (nearbyLocations.isNotEmpty) ...[
            SizedBox(height: 15.h),
            _buildNearbyLocationsSection(nearbyLocations),
          ],
          if (lat != null && lng != null) ...[
            SizedBox(height: 10.h),
            _buildHeaderWithMap(lat, lng, fullLocation),
            SizedBox(height: 10.h),
          ],
          _buildPropertyHeader(fullLocation),
          SizedBox(height: 10.h),
        ],
      );
    });
  }

  // Property Header Widget
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
              color: AppColor.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Center(
              child: Icon(Icons.location_on_outlined,
                  color: AppColor.primary, size: 25.w),
            ),
          ),
          12.w.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Property location",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColor.textMain.withOpacity(0.8),
                  ),
                ),
                4.h.verticalSpace,
                Text(
                  address,
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
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

  Widget _buildHeaderWithMap(double latitude, double longitude, String address) {
    final String googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude&query_place_id=${Uri.encodeComponent(address)}';
    final String googleMapsAppUrl = 'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude&travelmode=driving';

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Location Details",
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
              color: AppColor.textMain,
            ),
          ),
          GestureDetector(
            onTap: () async {
              try {
                final Uri uri = Uri.parse(googleMapsUrl);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(
                    uri,
                    mode: LaunchMode.externalApplication,
                  );
                } else {
                  final Uri altUri = Uri.parse(googleMapsAppUrl);
                  if (await canLaunchUrl(altUri)) {
                    await launchUrl(
                      altUri,
                      mode: LaunchMode.externalApplication,
                    );
                  } else {
                    throw Exception('Could not launch Google Maps');
                  }
                }
              } catch (e) {
                print('Error launching Google Maps: $e');
                Get.snackbar(
                  "Error",
                  "Unable to open Google Maps. Please install Google Maps app.",
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 3),
                );
              }
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
              decoration: BoxDecoration(
                color: AppColor.primary.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.map_outlined, size: 14.sp, color: Colors.white),
                  4.w.horizontalSpace,
                  Text(
                    "View on Map",
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          )
              .animate()
              .fadeIn(duration: 600.ms)
              .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1))
              .then()
              .shimmer(duration: 800.ms, color: Colors.white.withOpacity(0.3)),
        ],
      ),
    );
  }

  Widget _buildCarousel(List<String> images) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
        child: MediaCarouselScreen(
          images: images,
          height: 190.h,
        ),
      ),
    );
  }

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
            .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1)),
        SizedBox(height: 10.h),
        _detailRow('Location', fullLocation)
            .animate()
            .slideX(begin: 0.3, end: 0)
            .fadeIn()
            .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1)),
        SizedBox(height: 12.h),
        _rentalInfoGrid(
          monthlyRent: monthlyRent,
          annualYield: annualYield,
          property: property,
        ),
        SizedBox(height: 15.h),

        // Description Section with See More
        _buildDescriptionWithSeeMore(description),
        SizedBox(height: 20.h),
      ],
    );
  }

  Widget _buildDescriptionWithSeeMore(String description) {
    final showAll = ValueNotifier<bool>(false);
    final maxChars = 150;

    return ValueListenableBuilder<bool>(
      valueListenable: showAll,
      builder: (context, showAllValue, child) {
        final displayText = showAllValue || description.length <= maxChars
            ? description
            : '${description.substring(0, maxChars)}...';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Description'),
            SizedBox(height: 8.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayText,
                    style: TextStyle(
                      fontSize: 14.sp,
                      height: 1.5,
                    ),
                  ),
                  if (description.length > maxChars)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          showAll.value = !showAllValue;
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          showAllValue ? 'Show Less' : 'See More',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColor.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _rentalInfoGrid({
    required String monthlyRent,
    required String annualYield,
    required RentalDetailProperty property,
  }) {
    final items = [
      {"title": "Monthly Rent", "value": monthlyRent},
      {"title": "Annual Yield", "value": annualYield},
      {"title": "Area", "value": '${property.area ?? 'N/A'} Sq.ft'},
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

  // Amenities Section
  Widget _buildAmenitiesSection(List<AmenityModel> amenities) {
    final ScrollController scrollController = ScrollController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _sectionTitle('Amenities'),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: AppColor.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  "${amenities.length}",
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColor.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10.h),
        SizedBox(
          height: 95.h,
          child: Row(
            children: [
              // Left arrow button
              if (amenities.length > 2)
                _buildArrowButton(
                  scrollController: scrollController,
                  isRight: false,
                  itemCount: amenities.length,
                ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  itemCount: amenities.length,
                  itemBuilder: (context, index) {
                    final amenity = amenities[index];
                    return _buildAmenityCard(amenity)
                        .animate()
                        .fadeIn(duration: 400.ms)
                        .slideX(begin: 0.5, end: 0)
                        .scale(
                      begin: const Offset(0.9, 0.9),
                      end: const Offset(1, 1),
                      duration: 500.ms,
                      curve: Curves.easeOutBack,
                    );
                  },
                ),
              ),
              // Right arrow button
              if (amenities.length > 2)
                _buildArrowButton(
                  scrollController: scrollController,
                  isRight: true,
                  itemCount: amenities.length,
                ),
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
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8.r,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppColor.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: (amenity.image != null && amenity.image.isNotEmpty)
                ? Image.network(
              amenity.image,
              width: 32.w,
              height: 32.h,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.category_outlined,
                  size: 24.sp,
                  color: AppColor.primary,
                );
              },
            )
                : Icon(
              Icons.category_outlined,
              size: 24.sp,
              color: AppColor.primary,
            ),
          ),
          8.h.verticalSpace,
          Text(
            amenity.title ?? 'Unknown',
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

  // Nearby Locations Section
  Widget _buildNearbyLocationsSection(List<NearbyLocationDetail> nearbyLocations) {
    final ScrollController scrollController = ScrollController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _sectionTitle('Nearby Places'),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: AppColor.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  "${nearbyLocations.length}",
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColor.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10.h),
        SizedBox(
          height: 113.h,
          child: Row(
            children: [
              // Left arrow button
              if (nearbyLocations.length > 2)
                _buildArrowButton(
                  scrollController: scrollController,
                  isRight: false,
                  itemCount: nearbyLocations.length,
                ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  itemCount: nearbyLocations.length,
                  itemBuilder: (context, index) {
                    final location = nearbyLocations[index];
                    return _buildNearbyPlaceCard(location)
                        .animate()
                        .fadeIn(duration: 400.ms)
                        .slideX(begin: 0.5, end: 0)
                        .scale(
                      begin: const Offset(0.9, 0.9),
                      end: const Offset(1, 1),
                      duration: 500.ms,
                      curve: Curves.easeOutBack,
                    );
                  },
                ),
              ),
              // Right arrow button
              if (nearbyLocations.length > 2)
                _buildArrowButton(
                  scrollController: scrollController,
                  isRight: true,
                  itemCount: nearbyLocations.length,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNearbyPlaceCard(NearbyLocationDetail location) {
    final title = location.title ?? 'Unknown';
    final distance = location.distance;
    final imageUrl = location.image;

    return Container(
      width: 160.w,
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8.r,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppColor.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: (imageUrl != null && imageUrl.isNotEmpty)
                ? Image.network(
              imageUrl,
              width: 32.w,
              height: 32.h,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.place_outlined,
                  size: 24.sp,
                  color: AppColor.primary,
                );
              },
            )
                : Icon(
              Icons.place_outlined,
              size: 24.sp,
              color: AppColor.primary,
            ),
          ),
          8.h.verticalSpace,
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.bold,
              color: AppColor.textMain,
            ),
          ),
          4.h.verticalSpace,
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              distance,
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

  Widget _buildArrowButton({
    required ScrollController scrollController,
    required bool isRight,
    required int itemCount,
  }) {
    return GestureDetector(
      onTap: () {
        if (itemCount <= 2) return;

        final scrollAmount = 180.0;
        final newOffset = isRight
            ? scrollController.offset + scrollAmount
            : scrollController.offset - scrollAmount;

        final maxOffset = scrollController.position.maxScrollExtent;
        final targetOffset = isRight
            ? newOffset.clamp(0.0, maxOffset)
            : newOffset.clamp(0.0, maxOffset);

        scrollController.animateTo(
          targetOffset,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      child: Container(
        width: 36.w,
        height: 36.w,
        margin: EdgeInsets.symmetric(horizontal: 2.w),
        decoration: BoxDecoration(
          color: AppColor.primary.withOpacity(0.1),
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

  // Simple Enquiry Button
  Widget _buildSimpleEnquiryButton(
      RentalYieldController controller,
      RentalDetailProperty property,
      ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Obx(
            () => InkWell(
          borderRadius: BorderRadius.circular(30.r),
          onTap: controller.isEnquiryLoading.value
              ? null
              : () {
            _sendEnquiryDirectly(controller, property);
          },
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 14.h),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColor.primary, AppColor.primarylite],
              ),
              borderRadius: BorderRadius.circular(30.r),
            ),
            child: controller.isEnquiryLoading.value
                ? Center(
              child: SizedBox(
                height: 20.sp,
                width: 20.sp,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.black,
                ),
              ),
            )
                : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.message, size: 18.sp, color: Colors.black),
                SizedBox(width: 8.w),
                Text(
                  "Send Enquiry",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _sendEnquiryDirectly(
      RentalYieldController controller,
      RentalDetailProperty property,
      ) async {
    // Create enquiry data
    final enquiryData = {
      'property_id': property.id,
      'property_type': 'rental',
      'name': 'User Enquiry',
      'email': 'enquiry@example.com',
      'phone': '0000000000',
      'message':
      'I am interested in ${property.name}. Please contact me with more details.',
    };

    await controller.sendRentalEnquiry(enquiryData);
  }
}