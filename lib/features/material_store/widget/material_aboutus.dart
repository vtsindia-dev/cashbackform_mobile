// market_description_content.dart
import 'package:flutter/material.dart' hide Material;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../common/colours.dart';
import '../controller/material_store_controller.dart';
import '../model/material_store.dart';

// --- Main Widget ---
class MarketDescriptionContent extends StatefulWidget {
  final MaterialModel material;
  final List<MaterialModel> relatedProducts;
  final VoidCallback? onCartPressed;
  final VoidCallback? onSharePressed;
  final VoidCallback onEnquirePressed;

  const MarketDescriptionContent({
    super.key,
    required this.material,
    this.relatedProducts = const [],
    this.onCartPressed,
    this.onSharePressed,
    required this.onEnquirePressed,
  });

  @override
  State<MarketDescriptionContent> createState() => _MarketDescriptionContentState();
}

class _MarketDescriptionContentState extends State<MarketDescriptionContent> {
  final MaterialController _controller = Get.find<MaterialController>();

  final RxDouble _quantity = 1.0.obs;
  final RxString _selectedUnit = 'Unit'.obs;
  final RxList<String> _availableUnits = <String>[].obs;

  @override
  void initState() {
    super.initState();
    _initializeUnits();
  }

  void _initializeUnits() {
    _selectedUnit.value = _getDefaultUnit(widget.material.categoryId);
    _availableUnits.value = _getUnitsForCategory(widget.material.categoryId);
  }

  @override
  Widget build(BuildContext context) {
    final Color gradientStart = AppColor.primary;
    final Color gradientEnd = AppColor.primarylite;
    final Color accent = AppColor.orange;
    final Color green = AppColor.secondary;
    final priceText = _getFormattedPrice(widget.material);
    final createdAt =  DateTime.now();
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
                  _inputsBox(),
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

  Widget _imageSection() {
    final String imageUrl = widget.material.image.isNotEmpty
        ? widget.material.image.first
        : 'https://via.placeholder.com/600x400/CCCCCC/FFFFFF?text=No+Image';

    final thumbnails = [
      imageUrl,
      ...widget.material.image.skip(1).take(2),
    ];

    while (thumbnails.length < 3) {
      thumbnails.add('https://via.placeholder.com/150x150/CCCCCC/FFFFFF?text=Image');
    }

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
                return Center(
                  child: CircularProgressIndicator(
                    color: AppColor.primary,
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
              errorBuilder: (c, o, s) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image_not_supported, size: 48.sp, color: Colors.grey[400]),
                    SizedBox(height: 8.h),
                    Text('Image not available', style: TextStyle(color: Colors.grey[600], fontSize: 12.sp)),
                  ],
                ),
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
                  _showImageFullScreen(thumb);
                },
                child: Obx(() {
                  final isSelected = _controller.selectedImage.value == thumb;
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r),
                      border: isSelected
                          ? Border.all(color: AppColor.primary, width: 2.w)
                          : null,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: Container(
                        width: 72.w,
                        height: 56.h,
                        color: Colors.grey[100],
                        child: Image.network(
                          thumb,
                          fit: BoxFit.cover,
                          errorBuilder: (c, o, s) => Center(
                            child: Icon(Icons.image, size: 20.sp, color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              );
            },
          ),
        ),
      ],
    ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.02);
  }

  void _showImageFullScreen(String imageUrl) {
    _controller.selectedImage.value = imageUrl;
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(20.w),
        child: Container(
          decoration: BoxDecoration(
            color: AppColor.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.all(12.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Product Image', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
              ),
              Container(
                height: 300.h,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (c, o, s) => Center(child: Icon(Icons.broken_image, size: 50.sp)),
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
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
                widget.material.materialName.isNotEmpty
                    ? widget.material.materialName
                    : 'Unnamed Material',
                style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColor.textMain
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                priceText,
                style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColor.primary
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            _iconCircleButton(
              icon: Icons.share_outlined,
              label: 'Share',
              onTap: () => widget.onSharePressed ?? _showShareOptions(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _iconCircleButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool filled = false
  }) {
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
            if (filled)
              BoxShadow(
                  color: AppColor.primary.withOpacity(0.18),
                  blurRadius: 8.r,
                  offset: const Offset(0, 4)
              ),
          ],
        ),
        child: Center(
          child: Icon(
              icon,
              color: filled ? Colors.white : AppColor.primary,
              size: 20.sp
          ),
        ),
      ).animate().scale(begin: const Offset(0.98, 0.98), end: const Offset(1, 1)).then(delay: 50.ms),
    );
  }

  // --- Meta row: category, status ---
  Widget _metaRow(MaterialModel material, Color green) {  // Changed parameter type
    return Row(
      children: [
        Icon(Icons.category_outlined, color: green, size: 16.sp),
        SizedBox(width: 6.w),
        Expanded(
          child: Text(
            material.category?.categoryName ?? 'No category',
            style: TextStyle(
                fontSize: 13.sp,
                color: AppColor.textMain,
                fontWeight: FontWeight.w600
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: material.status == 1
                ? Colors.green.withOpacity(0.12)
                : Colors.red.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Text(
            material.status == 1 ? 'Active' : 'Inactive',
            style: TextStyle(
                color: material.status == 1 ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 12.sp
            ),
          ),
        ),
      ],
    );
  }

  // --- Description ---
  Widget _description(MaterialModel material) {  // Changed parameter type
    return Text(
      material.description?.isNotEmpty == true
          ? material.description!
          : 'No description provided for this product.',
      style: TextStyle(
          fontSize: 13.sp,
          color: Colors.grey[700],
          height: 1.4
      ),
    ).animate().fadeIn();
  }

  // --- Inputs box: quantity & unit selection + social share icons ---
  Widget _inputsBox() {
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
              Expanded(
                child: _labelledQuantityInput("Quantity"),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _labelledUnitInput("Unit"),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Text("Share:", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
              SizedBox(width: 10.w),
              _socialIconButton(
                  Icons.chat_bubble,
                  "WhatsApp",
                      () => _shareOnWhatsApp(widget.material)
              ),
              _socialIconButton(
                  Icons.send,
                  "Telegram",
                      () => _shareOnTelegram(widget.material)
              ),
              _socialIconButton(
                  Icons.camera_alt,
                  "Instagram",
                      () => _shareOnInstagram(widget.material)
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  // FIXED: Proper quantity input with stepper
  Widget _labelledQuantityInput(String label) {
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
              GestureDetector(
                onTap: () {
                  if (_quantity.value > 0.5) {
                    _quantity.value -= 0.5;
                  }
                },
                child: Icon(Icons.remove, size: 18.sp, color: AppColor.primary),
              ),
              Expanded(
                child: Obx(() => Text(
                  _quantity.value.toStringAsFixed(1),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13.sp, color: Colors.grey[700]),
                )),
              ),
              GestureDetector(
                onTap: () {
                  _quantity.value += 0.5;
                },
                child: Icon(Icons.add, size: 18.sp, color: AppColor.primary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // FIXED: Proper unit selection dropdown
  Widget _labelledUnitInput(String label) {
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
          child: Obx(() => DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedUnit.value,
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down, size: 18.sp, color: AppColor.primary),
              items: _availableUnits.map((String unit) {
                return DropdownMenuItem<String>(
                  value: unit,
                  child: Text(unit, style: TextStyle(fontSize: 13.sp)),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  _selectedUnit.value = newValue;
                }
              },
            ),
          )),
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
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                blurRadius: 6.r
            )
          ],
        ),
        child: Icon(icon, size: 18.sp, color: AppColor.primary),
      ),
    );
  }

  // --- Action Row: Get Quote only ---
  Widget _actionRow(Color gStart, Color gEnd, Color orange, Color green) {
    return Row(
      children: [
     /*   Expanded(
          child: Obx(() {
            final isLoading = _controller.isSubmittingEnquiry.value;

            return GestureDetector(
              onTap: isLoading ? null : () => _getQuote(widget.material),
              child: Container(
                height: 48.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [gStart, gEnd]),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Center(
                  child: isLoading
                      ? SizedBox(
                    width: 24.w,
                    height: 24.w,
                    child: CircularProgressIndicator(
                      color: AppColor.black,
                      strokeWidth: 2,
                    ),
                  )
                      : Text(
                    "Get Quote",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColor.black,
                    ),
                  ),
                ),
              ).animate().scale(),
            );
          }),
        ),*/
      ],
    );
  }

  // --- Details panel ---
  Widget _detailsPanel(MaterialModel material, String priceText, DateTime createdAt) {  // Changed parameter type
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: AppColor.primary.withOpacity(0.95),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text(
            "Product Details",
            style: TextStyle(
                color: AppColor.black,
                fontWeight: FontWeight.bold,
                fontSize: 14.sp
            ),
          ),
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
              _detailRow("Description", material.description ?? ''),
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
        Text(
          "$label:",
          style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: Colors.grey[800]
          ),
        ),
        SizedBox(height: 6.h),
        if (isStatus)
          Row(
            children: [
              Container(
                width: 10.h,
                height: 10.h,
                decoration: BoxDecoration(
                    color: value == 'Active' ? Colors.green : Colors.red,
                    shape: BoxShape.circle
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                  value,
                  style: TextStyle(fontSize: 13.sp, color: Colors.grey[700])
              ),
            ],
          )
        else
          Text(
            value.isNotEmpty ? value : 'Not specified',
            style: TextStyle(
                fontSize: 13.sp,
                color: Colors.grey[700],
                height: 1.4
            ),
          ),
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
              Get.toNamed(
                '/material-detail',
                arguments: {'materialId': related.id},
              );
            },
            child: Container(
              width: 160.w,
              decoration: BoxDecoration(
                color: AppColor.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.withOpacity(0.06),
                      blurRadius: 8.r
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12.r),
                        topRight: Radius.circular(12.r)
                    ),
                    child: Container(
                      height: 110.h,
                      color: Colors.grey[100],
                      child: related.image.isNotEmpty
                          ? Image.network(
                        related.image.first,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (c, o, s) => Icon(
                            Icons.image,
                            size: 36.sp,
                            color: Colors.grey
                        ),
                      )
                          : Icon(
                          Icons.image,
                          size: 36.sp,
                          color: Colors.grey
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          related.materialName.isNotEmpty
                              ? related.materialName
                              : 'Unnamed',
                          style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          relatedPrice,
                          style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColor.primary
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          related.category?.categoryName ?? '',
                          style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.grey[600]
                          ),
                        ),
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
  String _getFormattedPrice(MaterialModel m) {  // Changed parameter type
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

  List<String>  _getUnitsForCategory(int? categoryId) {
    switch (categoryId) {
      case 12:
        return ["Bag (50 kg)", "Bag (25 kg)", "Kg", "Ton",];
      case 13:
        return ["Ton", "Kg", "Quintal"];
      case 14:
        return ["Sq. Ft", "Sq. M", "Piece"];
      case 15:
        return ["Piece", "Dozen", "Box"];
      default:
        return ["Unit", "Piece", "Kg", "Ton"];
    }
  }

  String _formatDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  void _getQuote(MaterialModel material) async {  // Changed parameter type
    final userId =  0;

    if (userId == 0) {
      Get.snackbar(
        'Login Required',
        'Please login to request a quote',
        backgroundColor: Colors.orange[50],
        colorText: AppColor.textMain,
        snackPosition: SnackPosition.BOTTOM,
        margin: EdgeInsets.all(12.w),
      );
      Get.toNamed('/login');
      return;
    }

    final unitId = _getUnitId(_selectedUnit.value);
  }

  int _getUnitId(String unit) {
    switch (unit) {
      case 'Bag (50 kg)':
        return 1;
      case 'Bag (25 kg)':
        return 2;
      case 'Kg':
        return 3;
      case 'Ton':
        return 4;
      case 'Sq. Ft':
        return 5;
      case 'Sq. M':
        return 6;
      case 'Piece':
        return 7;
      case 'Dozen':
        return 8;
      case 'Box':
        return 9;
      case 'Quintal':
        return 10;
      default:
        return 0;
    }
  }

  void _showShareOptions() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Share via',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _shareOption(Icons.chat_bubble, 'WhatsApp', () {
                  Get.back();
                  _shareOnWhatsApp(widget.material);
                }),
                _shareOption(Icons.send, 'Telegram', () {
                  Get.back();
                  _shareOnTelegram(widget.material);
                }),
                _shareOption(Icons.camera_alt, 'Instagram', () {
                  Get.back();
                  _shareOnInstagram(widget.material);
                }),
                _shareOption(Icons.share, 'More', () {
                  Get.back();
                  _defaultShare();
                }),
              ],
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _shareOption(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: AppColor.backgroundLight,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColor.primary, size: 24.sp),
          ),
          SizedBox(height: 8.h),
          Text(label, style: TextStyle(fontSize: 12.sp)),
        ],
      ),
    );
  }

  void _defaultShare() {
    Get.snackbar(
        'Share',
        'Sharing product...',
        backgroundColor: Colors.blue[50],
        colorText: AppColor.textMain
    );
  }

  void _shareOnWhatsApp(MaterialModel material) {  // Changed parameter type
    Get.snackbar(
        'WhatsApp',
        'Opening WhatsApp...',
        backgroundColor: Colors.green[50],
        colorText: AppColor.textMain
    );
  }

  void _shareOnInstagram(MaterialModel material) {  // Changed parameter type
    Get.snackbar(
        'Instagram',
        'Opening Instagram...',
        backgroundColor: Colors.pink[50],
        colorText: AppColor.textMain
    );
  }

  void _shareOnTelegram(MaterialModel material) {  // Changed parameter type
    Get.snackbar(
        'Telegram',
        'Opening Telegram...',
        backgroundColor: Colors.blue[50],
        colorText: AppColor.textMain
    );
  }
}