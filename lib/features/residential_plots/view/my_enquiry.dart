import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart'; // Add this to your pubspec.yaml
import '../../../common/colours.dart';
import '../../../common/widget/appbar.dart';
import '../controller/residential_add_controller.dart';
import '../controller/residential_controller.dart';
import '../model/residential_model.dart';

class PlotEnquiryScreen extends StatefulWidget {
  const PlotEnquiryScreen({Key? key}) : super(key: key);

  @override
  State<PlotEnquiryScreen> createState() => _PlotEnquiryScreenState();
}

class _PlotEnquiryScreenState extends State<PlotEnquiryScreen> {
  final controller = Get.put(ResidentialPropertyFormController());
  final controller2 = Get.put(ResidentialPropertyController());

  @override
  void initState() {
    controller.fetchEnquiredProperties();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {


    return Scaffold(
      backgroundColor: AppColor.backgroundLight,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.h),
        child: DynamicAppBar(
          title: "Interest & Enquiries",
          showBackButton: true,
        ),
      ),
      body: Obx(() {
        if (controller.isLoadingEnquiries.value) {
          return Center(child: CircularProgressIndicator(color: AppColor.primary));
        }

        if (controller.enquiryProperties.isEmpty) {
          return _buildEmptyEnquiryState();
        }

        return RefreshIndicator(
          color: AppColor.primary,
          onRefresh: () => controller.fetchEnquiredProperties(),
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 15.h),
            itemCount: controller.enquiryProperties.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final property = controller.enquiryProperties[index];
              return _buildEnquiryCard(property);
            },
          ),
        );
      }),
    );
  }

  Widget _buildEnquiryCard(Property property) {
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
                      child: Icon(Iconsax.info_circle, size: 14.sp, color: AppColor.primary),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      "ID: #ENQ${property.id}", // Using the plot ID from your JSON
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColor.textSecondary,
                      ),
                    ),
                  ],
                ),
                // Text(
                //   "Enquired on Jan 08", // You can parse property.createdAt if needed
                //   style: TextStyle(fontSize: 11.sp, color: AppColor.grey),
                // ),
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
                    property.thumbnail ?? '',
                    width: 100.w,
                    height: 100.h,
                    fit: BoxFit.cover,
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
                        property.propertyName,
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
                              property.location,
                              style: TextStyle(fontSize: 11.sp, color: AppColor.textSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          Text(
                            '₹${property.price}',
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColor.primary,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: AppColor.lightGrey,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              "${property.areaSqft} Sq.ft",
                              style: TextStyle(fontSize: 10.sp, color: AppColor.textMain),
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
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            child: Row(
              children: [
                Icon(Iconsax.message_question, size: 14.sp, color: AppColor.primary),
                SizedBox(width: 8.w),
                Text(
                  "Enquiry Status: Received",
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColor.primary,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    Get.toNamed('residentialDetails', arguments: {"id": property.id, "title": property.propertyName});

                  },
                  child: Text(
                    "View Plot",
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColor.accent,
                      decoration: TextDecoration.underline,
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

  Widget _buildEmptyEnquiryState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.document_filter, size: 60.sp, color: AppColor.grey.withOpacity(0.5)),
          SizedBox(height: 16.h),
          Text(
            "No enquiries found yet.",
            style: TextStyle(color: AppColor.textSecondary, fontSize: 15.sp),
          ),
        ],
      ),
    );
  }
}