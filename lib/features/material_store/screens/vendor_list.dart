    import 'package:flutter/material.dart';
    import 'package:get/get.dart';
    import 'package:flutter_animate/flutter_animate.dart';
    import 'package:flutter_screenutil/flutter_screenutil.dart';
    import 'package:url_launcher/url_launcher.dart';

    import '../../../common/widget/appbar.dart';
    import '../../../common/widget/loader.dart';
    import '../controller/materialstore_controller.dart';
    import '../model/material_store.dart';

    class VendorListScreen extends StatelessWidget {
      final int materialId;
      final String materialName;

      const VendorListScreen({
        Key? key,
        required this.materialId,
        required this.materialName,
      }) : super(key: key);

      @override
      Widget build(BuildContext context) {
        final controller = Get.find<MaterialController>();
        final Color primaryColor = const Color(0xFF7FA93C);

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: DynamicAppBar(
            title: "Vendor List",
            showBackButton: true, // Set to true if you need to go back
          ),
          body: Obx(() {
            final vendors = controller.vendors;

            if (controller.isLoadingVendors.value && vendors.isEmpty) {
              return Center(
                child: GifLoader(
                  message: "Fetching Suppliers...",
                  size: 100.w,
                ),
              );
            }

            if (vendors.isEmpty) return _buildEmptyState();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStickyHeader(primaryColor),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => controller.fetchVendorsForMaterial(materialId),
                    color: primaryColor,
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      physics: const BouncingScrollPhysics(),
                      itemCount: vendors.length,
                      itemBuilder: (context, index) {
                        return IndustrialVendorTile(
                          vendor: vendors[index],
                          index: index,
                          primaryColor: primaryColor,
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          }),
        );
      }

      Widget _buildStickyHeader(Color color) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          color: color.withOpacity(0.05),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.inventory_2_outlined, size: 18.sp, color: color),
                  SizedBox(width: 8.w),
                  Text(
                    materialName,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              Text(
                "${Get.find<MaterialController>().vendors.length} Sellers",
                style: TextStyle(fontSize: 12.sp, color: color, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      }

      Widget _buildEmptyState() {
        return Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey[50],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.inventory_2_outlined, // More specific than domain_disabled
                    size: 48.sp,
                    color: Colors.blueGrey[200],
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  "No Vendors  Found",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                    color: Colors.blueGrey[800],
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  "We couldn't find any Vendors for this item. Try checking back later or adjusting your filters.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.blueGrey[400],
                    fontSize: 14.sp,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        );
      }}

    class IndustrialVendorTile extends StatelessWidget {
      final Vendor vendor;
      final int index;
      final Color primaryColor;

      const IndustrialVendorTile({
        Key? key,
        required this.vendor,
        required this.index,
        required this.primaryColor,
      }) : super(key: key);

      @override
      Widget build(BuildContext context) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: InkWell(
            onTap: () =>

                Get.toNamed('/VendorDetailScreen', arguments: {'vendorId': vendor.userId,'vendorName' : vendor.name}),
            borderRadius: BorderRadius.circular(12.r),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(12.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Header: Title and Price ---
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  vendor.name,
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  "${vendor.city}, ${vendor.state}",
                                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "Verified",
                                style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.sp,
                                ),
                              ),
                              Text(
                                "Top Seller",
                                style: TextStyle(fontSize: 10.sp, color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),

                      // --- Image and Grid Info (The Magicbricks Look) ---
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image Section
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.r),
                            child: Image.network(
                              vendor.image.isNotEmpty ? vendor.image.first : 'https://via.placeholder.com/150',
                              width: 100.w,
                              height: 80.h,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(width: 12.w),

                          // Grid Info Section
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.all(8.w),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Wrap(
                                runSpacing: 8.h,
                                children: [
                                  _buildInfoItem(Icons.inventory_2, "Items", "${vendor.vendorMaterials.length}"),
                                  _buildInfoItem(Icons.star, "Rating", vendor.reviewsAvgRating?.toString() ?? "N/A"),
                                  _buildInfoItem(Icons.verified, "Status", "Active"),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),

                      // --- Description ---
                      Text(
                        vendor.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 11.sp, color: Colors.grey[700], height: 1.4),
                      ),
                    ],
                  ),
                ),

                // --- Bottom Action Bar (Magicbricks Style Buttons) ---
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: Colors.grey[200]!)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildMagicButton(
                          "Contact Now",
                          primaryColor,
                          Colors.white,
                              () => _launchURL("https://wa.me/${vendor.whatsapp}"),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _buildMagicButton(
                          "Get Phone",
                          Colors.white,
                          primaryColor,
                              () => _launchURL("tel:${vendor.phone}"),
                          isOutlined: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ).animate(delay: (index * 50).ms).fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
      }

      // Magicbricks Info Grid Item
      Widget _buildInfoItem(IconData icon, String label, String value) {
        return SizedBox(
          width: 70.w,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 10.sp, color: Colors.grey),
                  SizedBox(width: 4.w),
                  Text(label, style: TextStyle(fontSize: 9.sp, color: Colors.grey)),
                ],
              ),
              Text(
                value,
                style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ],
          ),
        );
      }

      // Magicbricks Styled Rounded Button
      Widget _buildMagicButton(String text, Color bgColor, Color textColor, VoidCallback onTap, {bool isOutlined = false}) {
        return SizedBox(
          height: 38.h,
          child: ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: bgColor,
              foregroundColor: textColor,
              elevation: 0,
              side: isOutlined ? BorderSide(color: textColor) : null,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
              padding: EdgeInsets.zero,
            ),
            child: Text(
              text,
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
            ),
          ),
        );
      }

      Future<void> _launchURL(String url) async {
        if (await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(Uri.parse(url));
        }
      }
    }