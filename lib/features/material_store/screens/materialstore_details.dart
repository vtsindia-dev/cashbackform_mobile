import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../common/widget/appbar.dart';
import '../../../common/widget/loader.dart';
import '../controller/materialstore_controller.dart';
import '../model/material_store.dart';
import '../widget/enquiry_sheet.dart';

class VendorDetailScreen extends StatefulWidget {
  final int vendorId;
  final String? vendorName;

  const VendorDetailScreen({
    Key? key,
    required this.vendorId,
    this.vendorName,
  }) : super(key: key);

  @override
  State<VendorDetailScreen> createState() => _VendorDetailScreenState();
}

class _VendorDetailScreenState extends State<VendorDetailScreen> with TickerProviderStateMixin {
  final MaterialController controller = Get.find<MaterialController>();
  final Color primaryColor = const Color(0xFF7FA93C);

  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  final ScrollController _scrollController = ScrollController();
  bool _isAppBarExpanded = true;
  final Map<String, bool> _expandedStates = {}; // Track expanded states for multiple sections

  @override
  void initState() {
    super.initState();
    print('🔵 [INIT] VendorDetailScreen initialized with vendorId: ${widget.vendorId}');

    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fabAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.easeInOut),
    );

    _scrollController.addListener(_onScroll);
    _initializeData();
  }

  void _onScroll() {
    if (_scrollController.offset > 100 && _isAppBarExpanded) {
      setState(() => _isAppBarExpanded = false);
      _fabAnimationController.forward();
    } else if (_scrollController.offset <= 100 && !_isAppBarExpanded) {
      setState(() => _isAppBarExpanded = true);
      _fabAnimationController.reverse();
    }
  }

  Future<void> _initializeData() async {
    print('🟡 [INIT] Starting _initializeData');
    await controller.fetchVendorDetail(widget.vendorId);
    _fabAnimationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: DynamicAppBar(
        title: widget.vendorName ?? "Vendor Details",
        showBackButton: true,
        backgroundColor: _isAppBarExpanded ? Colors.transparent : Colors.white,

        actions: [
          IconButton(
            icon: Icon(
              Icons.share_outlined,
              color: _isAppBarExpanded ? Colors.white : Colors.black87,
            ),
            onPressed: _handleShare,
            tooltip: 'Share Vendor',
          ).animate().fadeIn(duration: 600.ms),
        ],
      ),
      body: Obx(() {
        print('🟡 [OBX] Building with isLoadingVendorDetail: ${controller.isLoadingVendorDetail.value}');

        if (controller.isLoadingVendorDetail.value) {
          return const Center(
            child: GifLoader(
              message: "Loading vendor details...",
              size: 100,
            ),
          );
        }

        if (controller.vendorDetail.value == null) {
          return _buildErrorState();
        }

        final vendor = controller.vendorDetail.value!;

        return RefreshIndicator(
          onRefresh: () => controller.fetchVendorDetail(widget.vendorId),
          color: primaryColor,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Vendor Header with Parallax Effect
              _buildVendorHeader(vendor),

              // Content Sections
              SliverPadding(
                padding: EdgeInsets.all(16.w),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Quick Stats Card
                    _buildQuickStats(vendor).animate().fadeIn(duration: 400.ms, delay: 100.ms),

                    SizedBox(height: 16.h),

                    // About Section with Read More
                    _buildAboutSection(vendor).animate().fadeIn(duration: 400.ms, delay: 200.ms),

                    SizedBox(height: 16.h),

                    // Contact Buttons
                    _buildContactButtons(vendor).animate().fadeIn(duration: 400.ms, delay: 300.ms),

                    SizedBox(height: 16.h),

                    // Horizontal Materials Section
                    if (vendor.vendorMaterials.isNotEmpty)
                      _buildHorizontalMaterials(vendor).animate().fadeIn(duration: 400.ms, delay: 400.ms),

                    SizedBox(height: 16.h),

                    // Services Section (horizontal)
                    if (vendor.vendorServices != null && vendor.vendorServices!.isNotEmpty)
                      _buildHorizontalServices(vendor).animate().fadeIn(duration: 400.ms, delay: 500.ms),

                    SizedBox(height: 16.h),

                    // Reviews Section
                    if (vendor.reviews.isNotEmpty)
                      _buildReviewsSection(vendor).animate().fadeIn(duration: 400.ms, delay: 600.ms),

                    SizedBox(height: 16.h),

                    // Add Review Button
                    _buildAddReviewButton(vendor).animate().fadeIn(duration: 400.ms, delay: 700.ms),

                    SizedBox(height: 20.h),
                  ]),
                ),
              ),
            ],
          ),
        );
      }),

      // Floating Action Button for Quick Quote
      floatingActionButton: Obx(() {
        if (controller.vendorDetail.value == null) return const SizedBox();

        return ScaleTransition(
          scale: _fabAnimation,
          child: FloatingActionButton.extended(
            onPressed: () => _showQuickQuoteDialog(),
            backgroundColor: primaryColor,
            icon: const Icon(Icons.chat, color: Colors.white),
            label: Text(
              'Get Quote',
              style: TextStyle(fontSize: 14.sp, color: Colors.white),
            ),
          ).animate().shake(duration: 600.ms, delay: 1000.ms),
        );
      }),
    );
  }

  // Helper method to extract images from vendor
  List<String> _getVendorImages(Vendor vendor) {
    try {
      // Check if vendor.image is a List and not empty
      if (vendor.image is List && (vendor.image as List).isNotEmpty) {
        return List<String>.from(vendor.image.map((e) => e.toString()));
      }

      // If it's a single string
      if (vendor.image is String && (vendor.image as String).isNotEmpty) {
        return [vendor.image as String];
      }

      return [];
    } catch (e) {
      print('Error extracting vendor images: $e');
      return [];
    }
  }

  // Modern Vendor Header with Parallax and Professional Polish
  Widget _buildVendorHeader(Vendor vendor) {
    final PageController headerPageController = PageController();
    final List<String> images = _getVendorImages(vendor);

    return SliverAppBar(
      expandedHeight: 280.h,
      pinned: false,
      stretch: true,
      elevation: 0,
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground,
        ],
        background: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Image Gallery with proper type handling
            _buildImageGallery(images, headerPageController),

            // 2. Refined Scrim
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.2),
                    Colors.transparent,
                    Colors.black.withOpacity(0.85),
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
            ),

            // 3. Vendor Info Overlay
            Positioned(
              bottom: 24.h,
              left: 20.w,
              right: 20.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated Badge
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20.r),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified, color: primaryColor, size: 14.sp),
                            SizedBox(width: 6.w),
                            Text(
                              'VERIFIED VENDOR',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.1),

                  SizedBox(height: 12.h),

                  Text(
                    vendor.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                      shadows: const [
                        Shadow(color: Colors.black38, offset: Offset(0, 2), blurRadius: 10),
                      ],
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),

                  SizedBox(height: 8.h),

                  // Location
                  Container(
                    padding: EdgeInsets.only(right: 12.w),
                    child: Row(
                      children: [
                        Icon(Icons.location_on, color: primaryColor, size: 16.sp),
                        SizedBox(width: 6.w),
                        Expanded(
                          child: Text(
                            _getVendorLocation(vendor),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 400.ms),
                ],
              ),
            ),

            // Page indicator dots
            if (images.length > 1)
              Positioned(
                bottom: 100.h,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    images.length,
                        (index) => Container(
                      width: 6.w,
                      height: 6.w,
                      margin: EdgeInsets.symmetric(horizontal: 3.w),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGallery(List<String> images, PageController controller) {
    if (images.isEmpty) {
      return Container(
        color: Colors.grey[300],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.store,
                size: 60.sp,
                color: Colors.grey[600],
              ),
              SizedBox(height: 8.h),
              Text(
                'No Image Available',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return PageView.builder(
      controller: controller,
      itemCount: images.length,
      itemBuilder: (context, index) {
        return Image.network(
          images[index],
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print('Error loading image at index $index: $error');
            return Container(
              color: Colors.grey[300],
              child: Center(
                child: Icon(
                  Icons.broken_image,
                  size: 40.sp,
                  color: Colors.grey[600],
                ),
              ),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: Colors.grey[200],
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                      : null,
                  color: primaryColor,
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Compact Quick Stats Card
  Widget _buildQuickStats(Vendor vendor) {
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            Icons.inventory_2_outlined,
            '${vendor.vendorMaterials.length}',
            'Materials',
          ),
          _buildStatItem(
            Icons.star_outline,
            vendor.reviewsAvgRating?.toStringAsFixed(1) ?? '0.0',
            'Rating',
          ),
          _buildStatItem(
            Icons.reviews_outlined,
            '${vendor.reviewsCount}',
            'Reviews',
          ),
          _buildStatItem(
            Icons.verified_outlined,
            'Verified',
            'Seller',
            isVerified: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label, {bool isVerified = false}) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: isVerified ? Colors.green.withOpacity(0.1) : primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isVerified ? Colors.green : primaryColor,
            size: 20.sp,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  // About Section with Expandable Text
  Widget _buildAboutSection(Vendor vendor) {
    final String sectionKey = 'about_${vendor.id}';
    _expandedStates.putIfAbsent(sectionKey, () => false);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: primaryColor, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                'About Vendor',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          _buildReadMoreText(
            vendor.description.isNotEmpty ? vendor.description : 'No description available',
            sectionKey,
          ),
        ],
      ),
    );
  }

  Widget _buildReadMoreText(String text, String sectionKey) {
    return StatefulBuilder(
      builder: (context, setState) {
        final isExpanded = _expandedStates[sectionKey] ?? false;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              maxLines: isExpanded ? null : 3,
              overflow: isExpanded ? null : TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
            if (text.length > 100)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _expandedStates[sectionKey] = !isExpanded;
                    });
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size(50.w, 30.h),
                  ),
                  child: Text(
                    isExpanded ? 'Read less' : 'Read more',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  // Contact Buttons
  Widget _buildContactButtons(Vendor vendor) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.contact_phone_outlined, color: primaryColor, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                'Contact',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  'Call',
                  Icons.phone,
                  primaryColor,
                      () => _launchURL('tel:${vendor.phone}'),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildActionButton(
                  'WhatsApp',
                  Icons.message,
                  Colors.green,
                      () => _launchURL('https://wa.me/${vendor.whatsapp ?? vendor.phone.replaceAll('+', '')}'),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildActionButton(
                  'Website',
                  Icons.language,
                  Colors.blue,
                  vendor.website != null ? () => _launchURL(vendor.website!) : null,
                  enabled: vendor.website != null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      String text,
      IconData icon,
      Color bgColor,
      VoidCallback? onTap, {
        bool enabled = true,
      }) {
    return Container(
      height: 45.h,
      child: ElevatedButton(
        onPressed: enabled ? onTap : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor.withOpacity(0.1),
          foregroundColor: bgColor,
          elevation: 0,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18.sp),
            SizedBox(width: 4.w),
            Text(
              text,
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  // Horizontal Materials Section
  Widget _buildHorizontalMaterials(Vendor vendor) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.inventory_2_outlined, color: primaryColor, size: 20.sp),
                  SizedBox(width: 8.w),
                  Text(
                    'Materials',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => _showAllMaterials(vendor.vendorMaterials),
                child: Text(
                  'View All (${vendor.vendorMaterials.length})',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 12.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Container(
            height: 200.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: vendor.vendorMaterials.length,
              itemBuilder: (context, index) {
                return _buildCompactMaterialCard(vendor.vendorMaterials[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactMaterialCard(VendorMaterial vm) {
    return Container(
      width: 160.w,
      margin: EdgeInsets.only(right: 12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
            child: Container(
              height: 110.h,
              width: double.infinity,
              color: Colors.grey[100],
              child: vm.material.image.isNotEmpty
                  ? Image.network(
                vm.material.image.first,
                fit: BoxFit.cover,
                errorBuilder: (c, o, s) => Icon(
                  Icons.image,
                  size: 40.sp,
                  color: Colors.grey[400],
                ),
              )
                  : Icon(
                Icons.image,
                size: 40.sp,
                color: Colors.grey[400],
              ),
            ),
          ),

          // Content
          Padding(
            padding: EdgeInsets.all(10.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vm.material.materialName,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  vm.material.getFormattedPrice(),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  vm.material.category?.categoryName ?? 'Uncategorized',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8.h),
                SizedBox(
                  width: double.infinity,
                  height: 30.h,
                  child: ElevatedButton(
                    onPressed: () => _showMaterialEnquiry(vm.material),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Quote',
                      style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600),
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

  // Horizontal Services Section
  Widget _buildHorizontalServices(Vendor vendor) {
    if (vendor.vendorServices == null || vendor.vendorServices!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.build_circle_outlined, color: primaryColor, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                'Services',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Container(
            height: 160.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: vendor.vendorServices!.length,
              itemBuilder: (context, index) {
                return _buildCompactServiceCard(vendor.vendorServices![index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactServiceCard(VendorService vendorService) {
    final service = vendorService.service;

    return Container(
      width: 140.w,
      margin: EdgeInsets.only(right: 12.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
              child: Container(
                width: double.infinity,
                color: Colors.grey[100],
                child: service.image.isNotEmpty
                    ? Image.network(
                  service.image.first,
                  fit: BoxFit.cover,
                  errorBuilder: (c, o, s) => Icon(
                    Icons.build_circle_outlined,
                    size: 30.sp,
                    color: Colors.grey[400],
                  ),
                )
                    : Icon(
                  Icons.build_circle_outlined,
                  size: 30.sp,
                  color: Colors.grey[400],
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(8.w),
            child: Column(
              children: [
                Text(
                  service.serviceName.isNotEmpty ? service.serviceName : 'Service',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                SizedBox(
                  width: double.infinity,
                  height: 28.h,
                  child: OutlinedButton(
                    onPressed: () => _showServiceEnquiry(service),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryColor,
                      side: BorderSide(color: primaryColor),
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                    ),
                    child: Text(
                      'Inquire',
                      style: TextStyle(fontSize: 10.sp),
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

  // Reviews Section
  Widget _buildReviewsSection(Vendor vendor) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.reviews_outlined, color: primaryColor, size: 20.sp),
                  SizedBox(width: 8.w),
                  Text(
                    'Reviews',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => _showAllReviews(vendor.reviews),
                child: Text(
                  'See All (${vendor.reviews.length})',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 12.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // Rating Summary
          _buildRatingSummary(vendor),
          SizedBox(height: 16.h),

          // Horizontal Reviews
          Container(
            height: 160.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: vendor.reviews.length > 5 ? 5 : vendor.reviews.length,
              itemBuilder: (context, index) {
                return _buildCompactReviewCard(vendor.reviews[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSummary(Vendor vendor) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Container(
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  vendor.reviewsAvgRating?.toStringAsFixed(1) ?? '0.0',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 12.sp,
                    ),
                    Text(
                      '/5',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              children: [
                _buildCompactRatingBar(5, _getRatingPercentage(vendor.reviews, 5)),
                _buildCompactRatingBar(4, _getRatingPercentage(vendor.reviews, 4)),
                _buildCompactRatingBar(3, _getRatingPercentage(vendor.reviews, 3)),
                _buildCompactRatingBar(2, _getRatingPercentage(vendor.reviews, 2)),
                _buildCompactRatingBar(1, _getRatingPercentage(vendor.reviews, 1)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactRatingBar(int stars, double percentage) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        children: [
          SizedBox(
            width: 25.w,
            child: Text(
              '$stars ★',
              style: TextStyle(
                fontSize: 10.sp,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2.r),
              child: LinearProgressIndicator(
                value: percentage,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                minHeight: 4.h,
              ),
            ),
          ),
          SizedBox(width: 20.w),
        ],
      ),
    );
  }

  double _getRatingPercentage(List<Review> reviews, int star) {
    if (reviews.isEmpty) return 0;
    int count = reviews.where((r) => r.rating.round() == star).length;
    return count / reviews.length;
  }

  Widget _buildCompactReviewCard(Review review) {
    return Container(
      width: 250.w,
      margin: EdgeInsets.only(right: 12.w),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16.r,
                backgroundImage: review.user.avatar != null
                    ? NetworkImage(review.user.avatar!)
                    : null,
                child: review.user.avatar == null
                    ? Text(
                  review.user.name[0].toUpperCase(),
                  style: TextStyle(fontSize: 10.sp),
                )
                    : null,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.user.name,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: List.generate(5, (starIndex) {
                        return Icon(
                          starIndex < review.rating.floor()
                              ? Icons.star
                              : starIndex < review.rating
                              ? Icons.star_half
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 10.sp,
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Expanded(
            child: Text(
              review.review,
              style: TextStyle(
                fontSize: 11.sp,
                color: Colors.grey[700],
                height: 1.3,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // Add Review Button
  Widget _buildAddReviewButton(Vendor vendor) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: InkWell(
        onTap: () => _showAddReviewDialog(vendor),
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                primaryColor,
                primaryColor.withValues(alpha: 0.8),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.25),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.rate_review_rounded,
                  size: 18.sp,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'Share your experience',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.3, end: 0);
  }

  // Helper Methods
  String _getVendorLocation(Vendor vendor) {
    List<String> parts = [];
    if (vendor.city != null && vendor.city!.isNotEmpty) parts.add(vendor.city!);
    if (vendor.state != null && vendor.state!.isNotEmpty) parts.add(vendor.state!);
    if (vendor.postalCode != null && vendor.postalCode!.isNotEmpty) parts.add(vendor.postalCode!);
    if (vendor.address != null && vendor.address!.isNotEmpty) parts.add(vendor.address!);
    return parts.isNotEmpty ? parts.join(', ') : 'Location not specified';
  }

  Future<void> _launchURL(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar(
          'Error',
          'Could not launch $url',
          backgroundColor: Colors.red[50],
          colorText: Colors.red[900],
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('Error launching URL: $e');
      Get.snackbar(
        'Error',
        'Invalid URL',
        backgroundColor: Colors.red[50],
        colorText: Colors.red[900],
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _handleShare() {
    final vendor = controller.vendorDetail.value;
    if (vendor == null) return;

    Get.snackbar(
      'Share',
      'Sharing ${vendor.name}...',
      backgroundColor: Colors.blue[50],
      colorText: Colors.blue[900],
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _showQuickQuoteDialog() {
    Get.dialog(
      Dialog(
        insetPadding: EdgeInsets.all(16.w),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        child: Container(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.chat, color: primaryColor, size: 40.sp),
              SizedBox(height: 16.h),
              Text(
                'Quick Quote Request',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Send a quick quote request to this vendor',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      child: Text('Cancel'),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        Get.snackbar(
                          'Success',
                          'Quote request sent successfully',
                          backgroundColor: Colors.green[50],
                          colorText: Colors.green[900],
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      child: Text('Send Request'),
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

  void _showAllMaterials(List<VendorMaterial> materials) {
    Get.bottomSheet(
      Container(
        height: 500.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'All Materials (${materials.length})',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(16.w),
                itemCount: materials.length,
                itemBuilder: (context, index) {
                  return _buildMaterialTile(materials[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialTile(VendorMaterial vm) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: Container(
              width: 60.w,
              height: 60.w,
              color: Colors.grey[100],
              child: vm.material.image.isNotEmpty
                  ? Image.network(
                vm.material.image.first,
                fit: BoxFit.cover,
                errorBuilder: (c, o, s) => Icon(
                  Icons.image,
                  size: 30.sp,
                  color: Colors.grey[400],
                ),
              )
                  : Icon(
                Icons.image,
                size: 30.sp,
                color: Colors.grey[400],
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vm.material.materialName,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  vm.material.getFormattedPrice(),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  vm.material.category?.categoryName ?? 'Uncategorized',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _showMaterialEnquiry(vm.material),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6.r),
              ),
              elevation: 0,
            ),
            child: Text(
              'Quote',
              style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showAllReviews(List<Review> reviews) {
    Get.bottomSheet(
      Container(
        height: 500.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'All Reviews (${reviews.length})',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(16.w),
                itemCount: reviews.length,
                itemBuilder: (context, index) {
                  return _buildReviewTile(reviews[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewTile(Review review) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18.r,
                backgroundImage: review.user.avatar != null
                    ? NetworkImage(review.user.avatar!)
                    : null,
                child: review.user.avatar == null
                    ? Text(
                  review.user.name[0].toUpperCase(),
                  style: TextStyle(fontSize: 12.sp),
                )
                    : null,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.user.name,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        ...List.generate(5, (starIndex) {
                          return Icon(
                            starIndex < review.rating.floor()
                                ? Icons.star
                                : starIndex < review.rating
                                ? Icons.star_half
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 12.sp,
                          );
                        }),
                        SizedBox(width: 4.w),
                        Text(
                          review.rating.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            review.review,
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  void _showMaterialEnquiry(MaterialModel material) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MaterialEnquirySheet(
        materialId: material.id,
        vendorId: widget.vendorId,
        onSubmitted: (success) {
          if (success) {
            Get.back();
            Get.snackbar(
              'Success',
              'Enquiry submitted successfully',
              backgroundColor: Colors.green,
              colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM,
            );
          }
        },
      ),
    );
  }

  void _showServiceEnquiry(dynamic service) {
    Get.snackbar(
      'Service Enquiry',
      'Service enquiry feature coming soon',
      backgroundColor: Colors.orange[50],
      colorText: Colors.orange[900],
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _showAddReviewDialog(Vendor vendor) {
    final reviewController = TextEditingController();
    double selectedRating = 5.0;

    Get.bottomSheet(
      isScrollControlled: true,
      ignoreSafeArea: false,
      Container(
        padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, MediaQuery.of(Get.context!).viewInsets.bottom + 24.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle for bottom sheet
            Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.only(bottom: 24.h),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),

            Text(
              'How was your experience?',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1F2937),
              ),
            ),

            SizedBox(height: 8.h),

            Text(
              'Your feedback helps ${vendor.name} and the community.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
            ),

            SizedBox(height: 24.h),

            // Rating Selector with Animation
            StatefulBuilder(
              builder: (context, setState) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    bool isSelected = index < selectedRating;
                    return GestureDetector(
                      onTap: () => setState(() => selectedRating = index + 1.0),
                      child: Icon(
                        isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
                        color: isSelected ? Colors.amber[600] : Colors.grey[300],
                        size: 48.sp,
                      ).animate(target: isSelected ? 1 : 0)
                          .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.1, 1.1), duration: 150.ms)
                          .then()
                          .scale(begin: const Offset(1.1, 1.1), end: const Offset(1.0, 1.0)),
                    );
                  }),
                );
              },
            ),

            SizedBox(height: 24.h),

            // Review TextField with better styling
            TextField(
              controller: reviewController,
              maxLines: 4,
              style: TextStyle(fontSize: 14.sp),
              decoration: InputDecoration(
                hintText: 'Describe your experience (optional)',
                hintStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  borderSide: BorderSide(color: primaryColor.withOpacity(0.5), width: 2),
                ),
              ),
            ),

            SizedBox(height: 24.h),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (reviewController.text.trim().isEmpty) {
                    Get.snackbar(
                      'Message Required',
                      'Please tell us a bit more about your experience.',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.black87,
                      colorText: Colors.white,
                    );
                    return;
                  }

                  // Close Sheet
                  Get.back();

                  // Show success message
                  Get.snackbar(
                    'Success',
                    'Review submitted successfully',
                    backgroundColor: Colors.green[50],
                    colorText: Colors.green[900],
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                ),
                child: Text(
                  'Submit Review',
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 60.sp,
            color: Colors.red[300],
          ).animate().shake(duration: 600.ms),
          SizedBox(height: 16.h),
          Text(
            'Failed to load vendor details',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Please try again',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 20.h),
          ElevatedButton(
            onPressed: () => controller.fetchVendorDetail(widget.vendorId),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            child: const Text(
              'Retry',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _scrollController.dispose();
    print('🔴 [LIFECYCLE] VendorDetailScreen disposing');
    super.dispose();
  }
}