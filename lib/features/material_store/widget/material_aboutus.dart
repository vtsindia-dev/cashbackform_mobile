// market_description_content.dart
import 'package:flutter/material.dart' hide Material;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../common/colours.dart'; // keep if you have common colours
// If you prefer AppColor from your snippet, you can import it instead:
// import 'package:your_app/common/app_color.dart';
import '../controller/materialstore_controller.dart';
import '../model/material_store.dart';


// --- Main Widget ---
class MarketDescriptionContent extends StatefulWidget {
  final Material material;
  final List<Material> relatedProducts;
  final VoidCallback? onCartPressed;
  final VoidCallback? onSharePressed;

  const MarketDescriptionContent({
    super.key,
    required this.material,
    this.relatedProducts = const [],
    this.onCartPressed,
    this.onSharePressed,
  });

  @override
  State<MarketDescriptionContent> createState() => _MarketDescriptionContentState();
}

class _MarketDescriptionContentState extends State<MarketDescriptionContent> {
  @override
  Widget build(BuildContext context) {
    // Colors
    final Color gradientStart = AppColor.primary;
    final Color gradientEnd = AppColor.primarylite;
    final Color accent = AppColor.orange;
    final Color green = AppColor.secondary;

    // Derived values
    final priceText = _getFormattedPrice(widget.material);
    final defaultUnit = _getDefaultUnit(widget.material.categoryId);
    final createdAt = widget.material.createdAt ?? DateTime.now();

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _cardShell(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _imageSection(),
                  SizedBox(height: 12.h),
                  _titleRow(priceText, green),
                  SizedBox(height: 10.h),
                  _metaRow(widget.material, green),
                  SizedBox(height: 14.h),
                  _description(widget.material),
                  SizedBox(height: 14.h),
                  _inputsBox(defaultUnit),
                  SizedBox(height: 14.h),
                  _actionRow(gradientStart, gradientEnd, accent, green),
                  SizedBox(height: 18.h),
                  _detailsPanel(widget.material, priceText, createdAt),
                ],
              ),
            ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.03),
            if (widget.relatedProducts.isNotEmpty) ...[
              SizedBox(height: 22.h),
              Text(
                "Related Products",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColor.textMain,
                ),
              ),
              SizedBox(height: 12.h),
              _relatedProductsCarousel(),
            ],
            SizedBox(height: 22.h),
          ],
        ),
      ),
    );
  }

  // --- Shell with shadow & rounded corners ---
  Widget _cardShell({required Widget child}) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.12),
            blurRadius: 18.r,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  // --- Image Section with thumbnails ---
  Widget _imageSection() {
    final String imageUrl = widget.material.image.first.isNotEmpty
        ? widget.material.image.first
        : 'https://via.placeholder.com/600x400.png?text=No+Image';

    final thumbnails = [
      imageUrl,
      'https://via.placeholder.com/150x150.png?text=Side+View',
      'https://via.placeholder.com/150x150.png?text=Packaging',
    ];

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            height: 220.h,
            color: Colors.grey[100],
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(child: CircularProgressIndicator(color: AppColor.primary));
              },
              errorBuilder: (c, o, s) => Center(
                child: Icon(Icons.image_not_supported, size: 48.sp, color: Colors.grey[400]),
              ),
            ),
          ),
        ),
        SizedBox(height: 10.h),
        SizedBox(
          height: 56.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: thumbnails.length,
            separatorBuilder: (_, __) => SizedBox(width: 10.w),
            itemBuilder: (context, index) {
              final thumb = thumbnails[index];
              return GestureDetector(
                onTap: () {
                  // TODO: implement full-screen viewer or switch main image
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: Container(
                    width: 72.w,
                    height: 56.h,
                    color: Colors.grey[100],
                    child: Image.network(
                      thumb,
                      fit: BoxFit.cover,
                      errorBuilder: (c, o, s) => Icon(Icons.image, size: 20.sp, color: Colors.grey),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.02);
  }

  // --- Title and price + cart/share icons ---
  Widget _titleRow(String priceText, Color accent) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.material.materialName.isNotEmpty ? widget.material.materialName : 'Unnamed Material',
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700, color: AppColor.textMain),
              ),
              SizedBox(height: 6.h),
              Text(
                priceText,
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColor.primary),
              ),
            ],
          ),
        ),
        Row(
          children: [
            _iconCircleButton(
              icon: Icons.share_outlined,
              label: 'Share',
              onTap: () => widget.onSharePressed ?? _defaultShare(),
            ),

          ],
        ),
      ],
    );
  }

  Widget _iconCircleButton({required IconData icon, required String label, required VoidCallback onTap, bool filled = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42.w,
        height: 42.w,
        decoration: BoxDecoration(
          color: filled ? AppColor.primary : AppColor.white,
          borderRadius: BorderRadius.circular(12.r),
          border: filled ? null : Border.all(color: Colors.grey.shade200),
          boxShadow: [
            if (filled) BoxShadow(color: AppColor.primary.withOpacity(0.18), blurRadius: 8.r, offset: const Offset(0, 4)),
          ],
        ),
        child: Center(
          child: Icon(icon, color: filled ? Colors.white : AppColor.primary, size: 20.sp),
        ),
      ).animate().scale(begin: const Offset(0.98, 0.98), end: const Offset(1, 1)).then(delay: 50.ms),
    );
  }

  // --- Meta row: category, status ---
  Widget _metaRow(Material material, Color green) {
    return Row(
      children: [
        Icon(Icons.category_outlined, color: green, size: 16.sp),
        SizedBox(width: 6.w),
        Expanded(
          child: Text(
            material.category?.categoryName ?? 'No category',
            style: TextStyle(fontSize: 13.sp, color: AppColor.textMain, fontWeight: FontWeight.w600),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: material.status == 1 ? Colors.green.withOpacity(0.12) : Colors.red.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Text(
            material.status == 1 ? 'Active' : 'Inactive',
            style: TextStyle(color: material.status == 1 ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: 12.sp),
          ),
        ),
      ],
    );
  }

  // --- Description ---
  Widget _description(Material material) {
    return Text(
      material.description.isNotEmpty ? material.description : 'No description provided for this product.',
      style: TextStyle(fontSize: 13.sp, color: Colors.grey[700], height: 1.4),
    ).animate().fadeIn();
  }

  // --- Inputs box: quantity & unit selection + social share icons ---
  Widget _inputsBox(String defaultUnit) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColor.backgroundLight,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _labelledInput("Quantity", "1", isNumber: true)),
              SizedBox(width: 10.w),
              Expanded(child: _labelledInput("Unit", defaultUnit, isDropdown: true)),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Text("Share:", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
              SizedBox(width: 10.w),
              _socialIconButton(Icons.chat_bubble, "WhatsApp", () => _shareOnWhatsApp(widget.material)),
              _socialIconButton(Icons.send, "Telegram", () => _shareOnTelegram(widget.material)),
              _socialIconButton(Icons.camera_alt, "Instagram", () => _shareOnInstagram(widget.material)),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _labelledInput(String label, String placeholder, {bool isNumber = false, bool isDropdown = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600)),
        SizedBox(height: 6.h),
        Container(
          height: 42.h,
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          decoration: BoxDecoration(
            color: AppColor.white,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Expanded(child: Text(placeholder, style: TextStyle(fontSize: 13.sp, color: Colors.grey[700]))),
              if (isDropdown)
                Icon(Icons.keyboard_arrow_down, size: 18.sp, color: AppColor.primary)
              else if (isNumber)
                Row(
                  children: [
                    Icon(Icons.keyboard_arrow_up, size: 14.sp, color: AppColor.primary),
                    Icon(Icons.keyboard_arrow_down, size: 14.sp, color: AppColor.primary),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _socialIconButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(left: 8.w),
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: AppColor.white,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 6.r)],
        ),
        child: Icon(icon, size: 18.sp, color: AppColor.primary),
      ),
    );
  }

  // --- Action Row: Add to Cart and Get Quote ---
  Widget _actionRow(Color gStart, Color gEnd, Color orange, Color green) {
    return Row(
      children: [
        // Expanded(
        //   flex: 2,
        //   child: GestureDetector(
        //     onTap: () => _addToCart(widget.material),
        //     child: Container(
        //       height: 48.h,
        //       decoration: BoxDecoration(
        //         gradient: const LinearGradient(colors: [AppColor.orange, AppColor.orangeAccent]),
        //         borderRadius: BorderRadius.circular(12.r),
        //         boxShadow: [BoxShadow(color: AppColor.orange.withOpacity(0.18), blurRadius: 10.r, offset: const Offset(0, 6))],
        //       ),
        //       child: Center(
        //         child: Row(
        //           mainAxisSize: MainAxisSize.min,
        //           children: [
        //             Icon(Icons.shopping_cart, color: AppColor.black, size: 20.sp),
        //             SizedBox(width: 8.w),
        //             Text("Add to Cart", style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: AppColor.black)),
        //           ],
        //         ),
        //       ),
        //     ).animate().shake(),
        //   ),
        // ),
        SizedBox(width: 12.w),
        Expanded(
          flex: 1,
          child: GestureDetector(
            onTap: () => _getQuote(widget.material),
            child: Container(
              height: 48.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [gStart, gEnd]),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Center(
                child: Text("Get Quote", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: AppColor.black)),
              ),
            ).animate().scale(),
          ),
        ),
      ],
    );
  }

  // --- Details panel ---
  Widget _detailsPanel(Material material, String priceText, DateTime createdAt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: AppColor.primary.withOpacity(0.95),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text("Product Details", style: TextStyle(color: AppColor.black, fontWeight: FontWeight.bold, fontSize: 14.sp)),
        ),
        Container(
          width: double.infinity,
          margin: EdgeInsets.only(top: 6.h),
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(10.r),
            color: AppColor.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow("Product Name", material.materialName),
              SizedBox(height: 10.h),
              _detailRow("Category", material.category?.categoryName ?? 'N/A'),
              SizedBox(height: 10.h),
              _detailRow("Description", material.description),
              SizedBox(height: 10.h),
              _detailRow("Price", priceText),
              SizedBox(height: 10.h),
              _detailRow("Status", material.status == 1 ? 'Active' : 'Inactive', isStatus: true),
              SizedBox(height: 10.h),
              _detailRow("Added On", _formatDate(createdAt)),
            ],
          ),
        ),
      ],
    ).animate().fadeIn();
  }

  Widget _detailRow(String label, String value, {bool isStatus = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$label:", style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: Colors.grey[800])),
        SizedBox(height: 6.h),
        if (isStatus)
          Row(
            children: [
              Container(width: 10.h, height: 10.h, decoration: BoxDecoration(color: value == 'Active' ? Colors.green : Colors.red, shape: BoxShape.circle)),
              SizedBox(width: 8.w),
              Text(value, style: TextStyle(fontSize: 13.sp, color: Colors.grey[700])),
            ],
          )
        else
          Text(value.isNotEmpty ? value : 'Not specified', style: TextStyle(fontSize: 13.sp, color: Colors.grey[700], height: 1.4)),
      ],
    );
  }

  // --- Related products horizontal list ---
  Widget _relatedProductsCarousel() {
    return SizedBox(
      height: 230.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: widget.relatedProducts.length,
        separatorBuilder: (_, __) => SizedBox(width: 12.w),
        itemBuilder: (context, index) {
          final related = widget.relatedProducts[index];
          final relatedPrice = _getFormattedPrice(related);

          return GestureDetector(
            onTap: () {
              try {
                Get.find<MaterialController>().fetchMaterialDetail(related.id);
              } catch (e) {
              }
            },
            child: Container(
              width: 160.w,
              decoration: BoxDecoration(
                color: AppColor.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.06), blurRadius: 8.r)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(12.r), topRight: Radius.circular(12.r)),
                    child: Container(
                      height: 110.h,
                      color: Colors.grey[100],
                      child: related.image.isNotEmpty
                          ? Image.network(related.image.first, fit: BoxFit.cover, width: double.infinity, errorBuilder: (c, o, s) => Icon(Icons.image))
                          : Icon(Icons.image, size: 36.sp, color: Colors.grey),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(related.materialName.isNotEmpty ? related.materialName : 'Unnamed', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700), maxLines: 2, overflow: TextOverflow.ellipsis),
                        SizedBox(height: 6.h),
                        Text(relatedPrice, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppColor.primary)),
                        SizedBox(height: 6.h),
                        Text(related.category?.categoryName ?? '', style: TextStyle(fontSize: 11.sp, color: Colors.grey[600])),
                      ],
                    ),
                  ),

                ],
              ),
            ).animate().slideX(begin: 0.06, end: 0).fadeIn(),
          );
        },
      ),
    );
  }

  // --- Utilities & Actions ---
  String _getFormattedPrice(Material m) {
    return m.getFormattedPrice();
  }

  String _getDefaultUnit(int? categoryId) {
    switch (categoryId) {
      case 12:
        return "Bag (50 kg)";
      case 13:
        return "Ton";
      case 14:
        return "Sq. Ft";
      case 15:
        return "Piece";
      default:
        return "Unit";
    }
  }

  String _formatDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  void _addToCart(Material material) {
    Get.snackbar(
      'Added to Cart',
      '${material.materialName} added',
      backgroundColor: Colors.green[50],
      colorText: AppColor.textMain,
      snackPosition: SnackPosition.BOTTOM,
      margin: EdgeInsets.all(12.w),
    );
    // TODO: Add actual add-to-cart logic (call controller or service)
  }

  void _getQuote(Material material) {
    Get.snackbar(
      'Quote Requested',
      'We will contact you soon for ${material.materialName}',
      backgroundColor: Colors.blue[50],
      colorText: AppColor.textMain,
      snackPosition: SnackPosition.BOTTOM,
      margin: EdgeInsets.all(12.w),
    );
    // TODO: implement quote request API call
  }

  void _defaultShare() {
    Get.snackbar('Share', 'Sharing product...', backgroundColor: Colors.blue[50], colorText: AppColor.textMain);
  }

  void _shareOnWhatsApp(Material material) {
    // TODO: implement WhatsApp share intent
    Get.snackbar('WhatsApp', 'Opening WhatsApp...', backgroundColor: Colors.green[50], colorText: AppColor.textMain);
  }

  void _shareOnInstagram(Material material) {
    // TODO: Instagram
    Get.snackbar('Instagram', 'Opening Instagram...', backgroundColor: Colors.pink[50], colorText: AppColor.textMain);
  }

  void _shareOnTelegram(Material material) {
    // TODO: Telegram
    Get.snackbar('Telegram', 'Opening Telegram...', backgroundColor: Colors.blue[50], colorText: AppColor.textMain);
  }
}
