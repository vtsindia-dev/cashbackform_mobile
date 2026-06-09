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
  const MyPlotsScreen({super.key});

  @override
  State<MyPlotsScreen> createState() => _MyPlotsScreenState();
}

class _MyPlotsScreenState extends State<MyPlotsScreen> {
  final controller = Get.put(ResidentialPropertyFormController());
  final dashboardController = Get.put(DashboardController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      dashboardController.fetchBusinessSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.h),
        child: DynamicAppBar(
          title: "My Flat/Villas",
          showBackButton: true,
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
              child:
              CircularProgressIndicator(color: AppColor.primary));
        }
        if (controller.properties.isEmpty) {
          return _buildEmptyState();
        }
        return RefreshIndicator(
          color: AppColor.primary,
          onRefresh: () => controller.fetchMyProperties(),
          child: ListView.builder(
            padding: EdgeInsets.only(left: 16.w,right: 16.w,top: 12.h,bottom: 80.h),
            itemCount: controller.properties.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              return _PropertyCard(
                property: controller.properties[index],
                controller: controller,
                index: index,
                onDelete: () =>
                    _showDeleteConfirmation(controller,
                        controller.properties[index].id, index),
              );
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => const AddEditPropertyScreen()),
        backgroundColor: AppColor.primary,
        elevation: 4,
        icon: const Icon(Iconsax.add, color: Colors.white),
        label: Text(
          "ADD PROPERTY",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24.r),
            decoration: BoxDecoration(
              color: AppColor.primary.withValues(alpha:0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Iconsax.house_2,
                size: 56.sp, color: AppColor.primary.withValues(alpha:0.5)),
          ),
          SizedBox(height: 20.h),
          Text(
            "No properties yet",
            style: TextStyle(
              color: AppColor.textMain,
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "Tap the button below to add\nyour first property",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColor.textSecondary,
              fontSize: 13.sp,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(
      ResidentialPropertyFormController controller, int id, int index) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r)),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 30.r,
                backgroundColor: Colors.red.withValues(alpha:0.1),
                child: Icon(Icons.delete_sweep_rounded,
                    color: Colors.red, size: 30.sp),
              ),
              SizedBox(height: 16.h),
              Text(
                "Delete Property?",
                style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColor.textMain),
              ),
              SizedBox(height: 8.h),
              Text(
                "This action cannot be undone. Are you sure you want to remove this listing?",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14.sp, color: AppColor.textSecondary),
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColor.primary),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r)),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      child: Text("CANCEL",
                          style:
                          TextStyle(color: AppColor.primary)),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        controller.deleteProperty(id, index);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r)),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      child: const Text("DELETE",
                          style: TextStyle(color: Colors.white)),
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

class _PropertyCard extends StatefulWidget {
  final Property property;
  final ResidentialPropertyFormController controller;
  final int index;
  final VoidCallback onDelete;

  const _PropertyCard({
    required this.property,
    required this.controller,
    required this.index,
    required this.onDelete,
  });

  @override
  State<_PropertyCard> createState() => _PropertyCardState();
}

class _PropertyCardState extends State<_PropertyCard> {
  bool _renewLoading = false;

  Property get property => widget.property;
  ResidentialPropertyFormController get controller => widget.controller;
  VoidCallback get onDelete => widget.onDelete;

  bool get _docsPaid => property.documentVerification;
  bool get _isVerified => property.isVerified;
  bool get _isSoldOut => property.isSoldOut;
  bool get _showPayButton => !_docsPaid && !_isVerified;
  bool get _showRenewButton => !property.isActive;

  Future<void> _renew() async {
    setState(() => _renewLoading = true);
    await controller.renewProperty(property.id);
    if (mounted) setState(() => _renewLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageSection(context),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        property.propertyName,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColor.textMain,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      property.formattedPrice,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColor.primary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Icon(Iconsax.location,
                        size: 13.sp, color: AppColor.textSecondary),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        property.location,
                        style: TextStyle(
                          color: AppColor.textSecondary,
                          fontSize: 12.sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    _statChip(Iconsax.maximize_1,
                        '${property.areaSqft} sqft'),
                    SizedBox(width: 8.w),
                    if ((property.plotCount ?? 0) > 0)
                      _statChip(Iconsax.building_3,
                          '${property.plotCount} plots'),
                    if (property.category != null) ...[
                      SizedBox(width: 8.w),
                      _statChip(Iconsax.category,
                          property.category!.categoryName),
                    ],
                  ],
                ),
                SizedBox(height: 12.h),
                _buildStatusBanners(),
                SizedBox(height: 14.h),
                Divider(
                    height: 1,
                    color: Colors.grey.shade100),
                SizedBox(height: 12.h),
                _buildActionRow(context),
                SizedBox(height: 14.h),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildImageSection(BuildContext context) {
    final imageUrl = property.galleryImages.isNotEmpty
        ? property.galleryImages[0]
        : property.thumbnail;

    return Stack(
      children: [
        ClipRRect(
          borderRadius:
          BorderRadius.vertical(top: Radius.circular(20.r)),
          child: SizedBox(
            height: 185.h,
            width: double.infinity,
            child: imageUrl.isNotEmpty
                ? Image.network(
              imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (_, child, progress) {
                if (progress == null) return child;
                return Container(
                  color: Colors.grey.shade100,
                  child: const Center(
                      child: CircularProgressIndicator(
                          strokeWidth: 2)),
                );
              },
              errorBuilder: (_, __, ___) =>
                  _imagePlaceholder(),
            )
                : _imagePlaceholder(),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 60.h,
            decoration: BoxDecoration(
              borderRadius:
              BorderRadius.vertical(top: Radius.circular(20.r)),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withValues(alpha:0.45),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 10.h,
          left: 10.w,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_isVerified) _overlayBadge('✅ Verified', Colors.green),
              if (!_isVerified && _docsPaid)
                SizedBox(height: _isVerified ? 6.h : 0),
              if (!_isVerified && _docsPaid)
                _overlayBadge('💳 Paid', const Color(0xFF1565C0)),
            ],
          ),
        ),
        Positioned(
          top: 10.h,
          right: 10.w,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _statusPill(property.status ?? ''),
              if (_isSoldOut) ...[
                SizedBox(height: 6.h),
                _overlayBadge('🔴 Sold Out', Colors.red.shade700),
              ],
            ],
          ),
        ),
        Positioned(
          bottom: 8.h,
          left: 10.w,
          child: _countryBadge(),
        ),
      ],
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: Colors.grey.shade100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.image,
              color: Colors.grey.shade400, size: 28.sp),
          SizedBox(height: 4.h),
          Text("No Image",
              style: TextStyle(
                  color: Colors.grey.shade400, fontSize: 11.sp)),
        ],
      ),
    );
  }
  
  Widget _buildStatusBanners() {
    final List<Widget> banners = [];
    if (_isSoldOut) {
      banners.add(_infoBanner(
        icon: Icons.block_rounded,
        label: 'This property is marked as Sold Out',
        color: Colors.red.shade600,
        bg: Colors.red.shade50,
      ));
    }
    if (_isVerified) {
      banners.add(_infoBanner(
        icon: Icons.verified_rounded,
        label: 'Property is fully verified by admin',
        color: Colors.green.shade700,
        bg: Colors.green.shade50,
      ));
    }
    if (!_isVerified && _docsPaid) {
      banners.add(_infoBanner(
        icon: Icons.credit_card_rounded,
        label: 'Verification payment done — awaiting admin review',
        color: const Color(0xFF1565C0),
        bg: const Color(0xFFE3F2FD),
      ));
    }
    if (!_isVerified && !_docsPaid) {
      banners.add(_infoBanner(
        icon: Icons.info_outline_rounded,
        label: 'Pay to get this property verified',
        color: Colors.orange.shade700,
        bg: Colors.orange.shade50,
      ));
    }

    if (banners.isEmpty) return const SizedBox.shrink();

    return Column(
      children: banners
          .map((b) => Padding(
        padding: EdgeInsets.only(bottom: 6.h),
        child: b,
      ))
          .toList(),
    );
  }

  Widget _infoBanner({
    required IconData icon,
    required String label,
    required Color color,
    required Color bg,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: color.withValues(alpha:0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 15.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionRow(BuildContext context) {
    return Row(
      children: [
        if (_showRenewButton) ...[
          Expanded(
            child: _actionButton(
              label: 'Renew',
              icon: Icons.autorenew_rounded,
              color: const Color(0xFF1565C0),
              isLoading: _renewLoading,
              onTap: _renewLoading ? null : _renew,
            ),
          ),
          SizedBox(width: 8.w),
        ],
        if (_showPayButton) ...[
          Expanded(
            child: _actionButton(
              label: 'Pay to Verify',
              icon: Iconsax.verify,
              color: AppColor.primary,
              onTap: () =>
                  controller.initiateVerificationPayment(property),
            ),
          ),
          SizedBox(width: 8.w),
        ],
        _circleIcon(
          icon: Iconsax.edit_2,
          color: AppColor.accent,
          onTap: () => Get.to(
                  () => AddEditPropertyScreen(propertyId: property.id)),
        ),
        SizedBox(width: 10.w),
        _circleIcon(
          icon: Iconsax.trash,
          color: Colors.red,
          onTap: onDelete,
        ),
      ],
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          color: isLoading ? color.withValues(alpha: 0.6) : color,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading) ...[
              SizedBox(
                width: 14.sp,
                height: 14.sp,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 6.w),
              Text(
                'Loading...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ] else ...[
              Icon(icon, color: Colors.white, size: 15.sp),
              SizedBox(width: 6.w),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _circleIcon({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(9.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha:0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 18.sp),
      ),
    );
  }
  
  Widget _statChip(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: AppColor.primary.withValues(alpha:0.07),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.sp, color: AppColor.primary),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: AppColor.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _overlayBadge(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.92),
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha:0.15),
              blurRadius: 4,
              offset: const Offset(0, 2))
        ],
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontSize: 10.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _statusPill(String status) {
    Color color;
    String text;
    switch (status.toLowerCase()) {
      case 'active':
      case 'approved':
        color = Colors.green.shade600;
        text = 'ACTIVE';
        break;
      case 'rejected':
        color = Colors.red.shade600;
        text = 'REJECTED';
        break;
      default:
        color = Colors.orange.shade600;
        text = status.isEmpty ? 'PENDING' : status.toUpperCase();
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.9),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 10.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _countryBadge() {
    final bool isDubai = property.isIndia;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha:0.55),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(isDubai ? '🇦🇪' : '🇮🇳',
              style: TextStyle(fontSize: 11.sp)),
          SizedBox(width: 4.w),
          Text(
            isDubai ? 'Dubai' : 'India',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}