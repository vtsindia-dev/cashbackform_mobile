import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../common/colours.dart';
import '../../../common/widget/appbar.dart';
import '../controller/rental_yield_controller.dart';
import '../model/rental_yeild_model.dart';

class RentalEnquiryScreen extends StatefulWidget {
  const RentalEnquiryScreen({Key? key}) : super(key: key);

  @override
  State<RentalEnquiryScreen> createState() => _RentalEnquiryScreenState();
}

class _RentalEnquiryScreenState extends State<RentalEnquiryScreen> {
  final controller = Get.put(RentalYieldController());

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchRentalEnquiries();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundLight,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.h),
        child: DynamicAppBar(
          title: "Rental Enquiries",
          showBackButton: true,
          actions: [
            IconButton(
              onPressed: controller.refreshRentalEnquiries,
              icon: Icon(Iconsax.refresh, size: 20.sp),
            ),
          ],
        ),
      ),
      body: Obx(() {
        if (controller.isLoadingEnquiries.value) {
          return Center(
            child: CircularProgressIndicator(
              color: AppColor.primary,
              strokeWidth: 2.0,
            ),
          );
        }

        if (controller.rentalEnquiries.isEmpty) {
          return _buildEmptyEnquiryState();
        }

        return RefreshIndicator(
          color: AppColor.primary,
          backgroundColor: AppColor.white,
          onRefresh: () => controller.refreshRentalEnquiries(),
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 15.h),
            itemCount: controller.rentalEnquiries.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final enquiry = controller.rentalEnquiries[index];
              final property = enquiry.property;
              return _buildEnquiryCard(enquiry, property!);
            },
          ),
        );
      }),
    );
  }

  Widget _buildEnquiryCard(RentalEnquiry enquiry, RentalEnquiryProperty property) {
    return Container(
      margin: EdgeInsets.only(bottom: 18.h),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColor.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header: Enquiry Info
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(6.w),
                      decoration: BoxDecoration(
                        color: AppColor.primarylite.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Iconsax.receipt_item, size: 14.sp, color: AppColor.primary),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      "Enquiry #${enquiry.id}",
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColor.textSecondary,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      DateFormat('dd MMM yyyy').format(enquiry.createdAt),
                      style: TextStyle(fontSize: 10.sp, color: AppColor.grey),
                    ),
                    Text(
                      DateFormat('hh:mm a').format(enquiry.createdAt),
                      style: TextStyle(fontSize: 9.sp, color: AppColor.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Main Image & Content
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Square Image
              Padding(
                padding: EdgeInsets.only(left: 12.w, bottom: 12.h),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15.r),
                  child: Image.network(
                    property.thumbnail,
                    width: 100.w,
                    height: 100.h,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: 100.w,
                        height: 100.h,
                        color: AppColor.lightGrey,
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (c, e, s) => Container(
                      width: 100.w,
                      height: 100.h,
                      color: AppColor.lightGrey,
                      child: Icon(Iconsax.image, color: AppColor.grey),
                    ),
                  ),
                ),
              ),

              // Property Details
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        property.name,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColor.textMain,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(Iconsax.location, size: 12.sp, color: AppColor.grey),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              property.address,
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: AppColor.textSecondary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),

                      // Rental Amount
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: AppColor.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Row(
                              children: [
                                Icon(Iconsax.dollar_circle, size: 12.sp, color: AppColor.primary),
                                SizedBox(width: 4.w),
                                Text(
                                  property.formattedRent,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColor.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 8.w),

                          // Yield if available
                          if (property.yieldAmount != null && property.yieldAmount!.isNotEmpty)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: AppColor.accent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Row(
                                children: [
                                  Icon(Iconsax.chart_3, size: 12.sp, color: AppColor.accent),
                                  SizedBox(width: 4.w),
                                  Text(
                                    "${property.yieldAmount}% Yield",
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w600,
                                      color: AppColor.accent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),


                    ],
                  ),
                ),
              ),
            ],
          ),

          // Action Footer
          Container(
            decoration: BoxDecoration(
              color: AppColor.primarylite.withOpacity(0.1),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20.r)),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: () {
                    _viewPropertyDetails(property);
                  },
                  borderRadius: BorderRadius.circular(10.r),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: AppColor.primary,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Row(
                      children: [
                        Icon(Iconsax.eye, size: 12.sp, color: AppColor.white),
                        SizedBox(width: 6.w),
                        Text(
                          "View Property",
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColor.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Color _getStatusColor(int counts) {
    if (counts >= 5) return Colors.green;
    if (counts >= 3) return Colors.orange;
    return Colors.blue;
  }
  String _getStatusText(int counts) {
    if (counts >= 5) return "High Priority - Multiple enquiries";
    if (counts >= 3) return "Active Interest - Good response";
    return "New Enquiry - Recently received";
  }
  void _viewPropertyDetails(RentalEnquiryProperty property) {
    Get.toNamed(
      '/rentalDetails',
      arguments: {
        'id': property.id,
        'title': property.name,
      },
    );
  }
  Widget _buildEmptyEnquiryState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120.w,
            height: 120.h,
            decoration: BoxDecoration(
              color: AppColor.lightGrey,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Iconsax.receipt_search,
              size: 50.sp,
              color: AppColor.grey.withOpacity(0.5),
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            "No Rental Enquiries Yet",
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColor.textMain,
            ),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Text(
              "Your rental property enquiries will appear here once you submit them",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColor.textSecondary,
                height: 1.5,
              ),
            ),
          ),
          SizedBox(height: 20.h),
          ElevatedButton(
            onPressed: controller.refreshRentalEnquiries,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primary,
              foregroundColor: AppColor.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Iconsax.refresh, size: 16.sp),
                SizedBox(width: 8.w),
                Text("Refresh", style: TextStyle(fontSize: 13.sp)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}