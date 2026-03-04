import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../common/colours.dart';
import '../../../common/widget/appbar.dart';
import '../../menu/controller/dashboard_menu_controller.dart';
import '../controller/residential_add_controller.dart';
import '../model/residential_model.dart';
import 'add_residential.dart';

class MyPlotsScreen extends StatefulWidget {
  const MyPlotsScreen({Key? key}) : super(key: key);

  @override
  State<MyPlotsScreen> createState() => _MyPlotsScreenState();
}

class _MyPlotsScreenState extends State<MyPlotsScreen> {
  final controller = Get.put(ResidentialPropertyFormController());
  final dashboardController = Get.put(DashboardController());

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      dashboardController.fetchBusinessSettings();
    });    super.initState();
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColor.backgroundLight,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.h),
        child: DynamicAppBar(
          title: "My Residential Plots",
          showBackButton: true,
        ),
      ),
      body: Stack(
        children: [
          // Subtle background decoration
          // _buildOrganicDecor(),

          Obx(() {
            if (controller.isLoading.value) {
              return Center(child: CircularProgressIndicator(color: AppColor.primary));
            }

            if (controller.properties.isEmpty) {
              return _buildEmptyState();
            }

            return RefreshIndicator(
              color: AppColor.primary,
              onRefresh: () => controller.fetchMyProperties(),
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
                itemCount: controller.properties.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  final property = controller.properties[index];
                  return _buildNaturalPropertyCard(property, controller, index);
                },
              ),
            );
          }),
        ],
      ),
      floatingActionButton: _buildModernFAB(),
    );
  }

  Widget _buildOrganicDecor() {
    return Positioned(
      bottom: -50.h,
      left: -30.w,
      child: CircleAvatar(
        radius: 100.r,
        backgroundColor: AppColor.primarylite.withOpacity(0.2),
      ),
    );
  }

  Widget _buildNaturalPropertyCard(Property property, ResidentialPropertyFormController controller, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: AppColor.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Image Section ---
          Stack(
            children: [
              Container(
                height: 190.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
                  child: property.galleryImages.isNotEmpty
                      ? Image.network(
                    property.galleryImages[0],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: AppColor.lightGrey,
                        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      );
                    },
                    errorBuilder: (c, e, s) => _buildImagePlaceholder(),
                  )
                      : _buildImagePlaceholder(),
                ),
              ),

              // Verification Badge (if verified)
              if (property.isVerified)
                Positioned(
                  top: 12.h,
                  left: 12.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified, size: 12.sp, color: Colors.white),
                        SizedBox(width: 4.w),
                        Text(
                          "VERIFIED",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Status Badge
              Positioned(
                top: 12.h,
                right: 12.w,
                child: _buildStatusPill(property.status ?? 'Pending'),
              ),
            ],
          ),

          // --- Content Section ---
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        property.propertyName,
                        style: TextStyle(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColor.textMain,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '₹${property.price}',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColor.primary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Icon(Iconsax.location, size: 14.sp, color: AppColor.textSecondary),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        property.location,
                        style: TextStyle(color: AppColor.textSecondary, fontSize: 13.sp),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  child: Divider(height: 1, color: AppColor.lightGrey.withOpacity(0.5)),
                ),
                Row(
                  children: [
                    _featurePill(Iconsax.maximize_1, '${property.areaSqft} Sqft'),
                    const Spacer(),

                    // Verify Button (only if not verified)
                    if (!property.isVerified)
                      _circleAction(
                        Iconsax.verify,
                        AppColor.primary,
                            () {
                          controller.initiateVerificationPayment(property);
                        },
                      ),

                    if (!property.isVerified) SizedBox(width: 12.w),

                    _circleAction(
                      Iconsax.edit_2,
                      AppColor.accent,
                          () {
                        Get.to(() => AddEditPropertyScreen(propertyId: property.id));
                      },
                    ),
                    SizedBox(width: 12.w),

                    _circleAction(
                      Iconsax.trash,
                      AppColor.red,
                          () {
                        _showDeleteConfirmation(controller, property.id, index);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper for the image placeholder
  Widget _buildImagePlaceholder() {
    return Container(
      color: AppColor.lightGrey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.image, color: AppColor.grey, size: 30.sp),
          SizedBox(height: 4.h),
          Text("No Image", style: TextStyle(color: AppColor.grey, fontSize: 10.sp)),
        ],
      ),
    );
  }

  Widget _buildStatusPill(String status) {
    Color color = AppColor.warning;
    String statusText = status;

    if (status.toLowerCase() == 'active' || status.toLowerCase() == 'approved') {
      color = AppColor.success;
      statusText = 'ACTIVE';
    } else if (status.toLowerCase() == 'pending') {
      color = AppColor.warning;
      statusText = 'PENDING';
    } else if (status.toLowerCase() == 'rejected') {
      color = AppColor.red;
      statusText = 'REJECTED';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        statusText.toUpperCase(),
        style: TextStyle(
          color: AppColor.white,
          fontSize: 10.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _featurePill(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColor.primarylite.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14.sp, color: AppColor.primary),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppColor.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleAction(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 18.sp),
      ),
    );
  }

  Widget _buildModernFAB() {
    return FloatingActionButton.extended(
      onPressed: () => Get.to(() => const AddEditPropertyScreen()),
      backgroundColor: AppColor.primary,
      elevation: 4,
      icon: const Icon(Iconsax.add, color: AppColor.white),
      label: Text(
        "ADD PROPERTY",
        style: TextStyle(
          color: AppColor.white,
          fontWeight: FontWeight.bold,
          fontSize: 13.sp,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.house_2, size: 70.sp, color: AppColor.grey.withOpacity(0.5)),
          SizedBox(height: 16.h),
          Text(
            "No properties found",
            style: TextStyle(color: AppColor.textSecondary, fontSize: 16.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            "Add your first residential property",
            style: TextStyle(color: AppColor.textSecondary.withOpacity(0.7), fontSize: 12.sp),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(ResidentialPropertyFormController controller, int id, int index) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Warning Icon
              CircleAvatar(
                radius: 30.r,
                backgroundColor: AppColor.red.withOpacity(0.1),
                child: Icon(Icons.delete_sweep_rounded, color: AppColor.red, size: 30.sp),
              ),
              SizedBox(height: 16.h),

              // Text Content
              Text(
                "Delete Property?",
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColor.textMain),
              ),
              SizedBox(height: 8.h),
              Text(
                "This action cannot be undone. Are you sure you want to remove this listing?",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14.sp, color: AppColor.textSecondary),
              ),
              SizedBox(height: 24.h),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColor.primary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      child: Text("CANCEL", style: TextStyle(color: AppColor.primary)),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back(); // Close confirmation dialog
                        controller.deleteProperty(id, index); // Start deletion
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.red,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      child: const Text("DELETE", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}