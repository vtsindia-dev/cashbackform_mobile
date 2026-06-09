import 'package:cashback_farms/common/colours.dart';
import 'package:cashback_farms/common/route/router.dart';
import 'package:cashback_farms/common/widget/loader.dart';
import 'package:cashback_farms/features/material_store/controller/material_store_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/material_model.dart' as vendorModel;

class MaterialVendorList extends StatefulWidget {
  final int? id;
  final String? title;

  const MaterialVendorList({super.key, this.id, this.title});

  @override
  State<MaterialVendorList> createState() => _MaterialVendorListState();
}

class _MaterialVendorListState extends State<MaterialVendorList>
    with TickerProviderStateMixin {
  final MaterialController controller = Get.put(MaterialController());
  final ScrollController _scrollController = ScrollController();

  late AnimationController _headerAnim;
  late AnimationController _fabAnim;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;

  @override
  void initState() {
    super.initState();
    _headerAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _headerFade = CurvedAnimation(parent: _headerAnim, curve: Curves.easeOut);
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _headerAnim, curve: Curves.easeOutCubic));
    _fabAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.clearLocationFilter(selectedCategoryId: widget.id.toString());
      controller.fetchStates();
      _headerAnim.forward();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200 &&
          !controller.isFetchingMoreVendors &&
          controller.vendorCurrentPage < controller.vendorTotalPages) {
        controller.loadMoreVendors(
          selectedCategoryId: widget.id.toString(),
        );
      }
    });
  }

  @override
  void dispose() {
    _headerAnim.dispose();
    _fabAnim.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _showLocationFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return GetBuilder<MaterialController>(
          builder: (controller) {
            return Container(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 28,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFFFAF7F0),
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColor.primary.withValues(alpha:0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "FILTER",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: AppColor.primary,
                                letterSpacing: 3,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              "By Location",
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: AppColor.textMain,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => Get.back(),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColor.lightGrey,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close,
                                color: AppColor.textMain, size: 18),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    _sheetLabel("State"),
                    const SizedBox(height: 8),
                    _buildDropdown(
                      hint: controller.isStateLoading
                          ? "Loading..."
                          : "Select State",
                      value: controller.selectedStateId,
                      icon: Icons.map_outlined,
                      items: controller.stateList.map((e) {
                        return DropdownMenuItem(
                          value: e.id.toString(),
                          child: Text(e.stateName),
                        );
                      }).toList(),
                      onChanged: (val) {
                        controller.selectedStateId = val;
                        controller.fetchCity(int.parse(val!));
                      },
                    ),
                    const SizedBox(height: 20),
                    _sheetLabel("City"),
                    const SizedBox(height: 8),
                    _buildDropdown(
                      hint: controller.isCityLoading
                          ? "Loading..."
                          : "Select City",
                      value: controller.selectedCityId,
                      icon: Icons.location_city,
                      items: controller.cityList.map((e) {
                        return DropdownMenuItem(
                          value: e.id.toString(),
                          child: Text(e.cityName),
                        );
                      }).toList(),
                      onChanged: (val) {
                        controller.selectedCityId = val;
                        controller.update();
                      },
                    ),
                    const SizedBox(height: 36),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              controller.clearLocationFilter(
                                  selectedCategoryId: widget.id.toString());
                              Get.back();
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColor.red,
                              side: const BorderSide(
                                  color: AppColor.red, width: 1.5),
                              padding:
                              const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text("Reset",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF4E8020),
                                  Color(0xFF92AF5D),
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColor.primary.withValues(alpha:0.35),
                                  blurRadius: 14,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              onPressed: () {
                                controller.applyLocationFilter(
                                  stateId: controller.selectedStateId,
                                  cityId: controller.selectedCityId,
                                  selectedCategoryId: widget.id.toString(),
                                );
                                Get.back();
                              },
                              child: const Text(
                                "Apply Filter",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _sheetLabel(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 10,
          color: AppColor.textSecondary,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    required String? value,
    required IconData icon,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.lightGrey),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          dropdownColor: Colors.white,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: AppColor.grey),
          value: value,
          hint: Row(
            children: [
              Icon(icon, size: 18, color: AppColor.primary),
              const SizedBox(width: 10),
              Text(hint,
                  style: const TextStyle(
                      color: AppColor.grey, fontSize: 14)),
            ],
          ),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F2EC),
      body: Column(
        children: [
          FadeTransition(
            opacity: _headerFade,
            child: SlideTransition(
              position: _headerSlide,
              child: _buildHeader(),
            ),
          ),
          Expanded(
            child: GetBuilder<MaterialController>(
              builder: (ctrl) {
                if (ctrl.isVendorLoading) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const GifLoader(),
                        const SizedBox(height: 16),
                        Text(
                          "Finding vendors…",
                          style: TextStyle(
                            color: AppColor.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                if (ctrl.vendorList.isEmpty) {
                  return _buildEmptyState();
                }
                return RefreshIndicator(
                  color: AppColor.primary,
                  backgroundColor: Colors.white,
                  onRefresh: () async {
                    ctrl.clearLocationFilter(
                        selectedCategoryId: widget.id.toString());
                  },
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                    itemCount: ctrl.vendorList.length +
                        (ctrl.isFetchingMoreVendors ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == ctrl.vendorList.length) {
                        return const Padding(
                          padding: EdgeInsets.all(20),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColor.primary,
                              strokeWidth: 2.5,
                            ),
                          ),
                        );
                      }
                      return _AnimatedVendorCard(
                        vendor: ctrl.vendorList[index],
                        index: index,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF3A5C1A), Color(0xFF7BA048)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha:0.06),
              ),
            ),
          ),
          Positioned(
            top: 30,
            right: 80,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha:0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -20,
            left: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha:0.04),
              ),
            ),
          ),
          Positioned(
            top: 50,
            left: 60,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColor.orange,
              ),
            ),
          ),

          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha:0.15),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white.withValues(alpha:0.25),
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                      AnimatedBuilder(
                        animation: _fabAnim,
                        builder: (context, child) {
                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColor.orange.withValues(alpha:
                                      0.2 + 0.15 * _fabAnim.value),
                                  blurRadius: 12 + 6 * _fabAnim.value,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: child,
                          );
                        },
                        child: GestureDetector(
                          onTap: () =>
                              _showLocationFilterBottomSheet(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColor.orange,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.tune_rounded,
                                    color: Colors.white, size: 16),
                                SizedBox(width: 6),
                                Text(
                                  "Filter",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Title block
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "VENDORS",
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: Colors.white.withValues(alpha:0.65),
                                letterSpacing: 3.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.title ?? 'All Vendors',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: -0.8,
                                height: 1.1,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      GetBuilder<MaterialController>(
                        builder: (ctrl) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha:0.18),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha:0.3),
                            ),
                          ),
                          child: Text(
                            "${ctrl.vendorList.length} found",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
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
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColor.primary.withValues(alpha:0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.store_outlined,
              size: 48,
              color: AppColor.primary,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "No Vendors Found",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColor.textMain,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Try changing your location filter\nor pull down to refresh",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColor.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}


class _AnimatedVendorCard extends StatefulWidget {
  final vendorModel.Vendor vendor;
  final int index;

  const _AnimatedVendorCard({required this.vendor, required this.index});

  @override
  State<_AnimatedVendorCard> createState() => _AnimatedVendorCardState();
}

class _AnimatedVendorCardState extends State<_AnimatedVendorCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;
  bool _pressed = false;

  String _maskPhone(String phone) {
    if (phone.length < 6) return phone;
    const edge = 2;
    final mid = 'X' * (phone.length - edge * 2);
    return '${phone.substring(0, edge)}$mid${phone.substring(phone.length - edge)}';
  }
  
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 420 + (widget.index % 5) * 60),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0.05, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    // Stagger entrance
    Future.delayed(Duration(milliseconds: (widget.index % 8) * 60), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.vendor;
    final String imageUrl =
    (v.thumbnail != null && v.thumbnail!.isNotEmpty) ? v.thumbnail! : "";
    final double rating = double.tryParse(v.reviewsAvgRating ?? "0") ?? 0;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: GestureDetector(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          child: AnimatedScale(
            scale: _pressed ? 0.97 : 1.0,
            duration: const Duration(milliseconds: 120),
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha:_pressed ? 0.03 : 0.07),
                    blurRadius: _pressed ? 8 : 20,
                    offset: Offset(0, _pressed ? 2 : 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Column(
                  children: [
                    // ── Top row: image + info ─────────────────────────────
                    SizedBox(
                      height: 140,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Image panel
                          Stack(
                            children: [
                              SizedBox(
                                width: 120,
                                height: 140,
                                child: imageUrl.isNotEmpty
                                    ? Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      _placeholder(),
                                )
                                    : _placeholder(),
                              ),
                              // Rating badge on image
                              Positioned(
                                bottom: 8,
                                left: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha:0.65),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.star_rounded,
                                          color: AppColor.orange, size: 12),
                                      const SizedBox(width: 3),
                                      Text(
                                        rating.toStringAsFixed(1),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Info panel
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Name
                                  Text(
                                    v.name,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: AppColor.textMain,
                                      height: 1.2,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),

                                  // Star row
                                  _buildRatingStars(rating),
                                  const SizedBox(height: 10),

                                  // Badges
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 6,
                                    children: [
                                      _badge(
                                        Icons.verified_outlined,
                                        "GST: ${v.gst ?? 'N/A'}",
                                        AppColor.info,
                                      ),
                                      _badge(
                                        Icons.schedule_rounded,
                                        v.estimateDate ?? "No Est.",
                                        AppColor.warning,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── Divider ──────────────────────────────────────────
                    Container(
                      height: 1,
                      color: const Color(0xFFF0EDE8),
                    ),

                    // ── Bottom row: contact + CTA ─────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                      child: Row(
                        children: [
                          // Phone
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppColor.green.withValues(alpha:0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.phone_rounded,
                                      size: 13, color: AppColor.green),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    _maskPhone(v.phone),
                                    style: const TextStyle(
                                      color: AppColor.textSecondary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),

                          // View Details CTA
                          GestureDetector(
                            onTap: () {
                              Get.toNamed(
                                AppRoutes.vendorDetailScreen,
                                arguments: {
                                  "id": v.userId.toString(),
                                  "title": v.name,
                                  "userId": v.userId.toString(),
                                },
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 9),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF4E8020),
                                    Color(0xFF92AF5D),
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColor.primary.withValues(alpha:0.35),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "View Details",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Icon(Icons.arrow_forward_rounded,
                                      color: Colors.white, size: 13),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // if (v.address != null && v.address!.isNotEmpty)
                    //   Container(
                    //     width: double.infinity,
                    //     padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
                    //     decoration: const BoxDecoration(
                    //       color: Color(0xFFF8F5F0),
                    //     ),
                    //     child: Row(
                    //       children: [
                    //         const Icon(Icons.location_on_rounded,
                    //             size: 13, color: AppColor.grey),
                    //         const SizedBox(width: 6),
                    //         Expanded(
                    //           child: Text(
                    //             v.address!,
                    //             style: const TextStyle(
                    //               color: AppColor.grey,
                    //               fontSize: 11,
                    //               fontWeight: FontWeight.w400,
                    //             ),
                    //             maxLines: 1,
                    //             overflow: TextOverflow.ellipsis,
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: const Color(0xFFEEF2E8),
      child: Center(
        child: Icon(
          Icons.store_rounded,
          color: AppColor.primary.withValues(alpha:0.25),
          size: 36,
        ),
      ),
    );
  }

  Widget _badge(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingStars(double rating) {
    return Row(
      children: List.generate(5, (i) {
        if (i < rating.floor()) {
          return const Icon(Icons.star_rounded,
              color: AppColor.orange, size: 14);
        } else if (i < rating) {
          return const Icon(Icons.star_half_rounded,
              color: AppColor.orange, size: 14);
        } else {
          return Icon(Icons.star_border_rounded,
              color: AppColor.orange.withValues(alpha:0.4), size: 14);
        }
      }),
    );
  }
}