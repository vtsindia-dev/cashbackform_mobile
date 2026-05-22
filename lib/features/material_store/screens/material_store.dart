import 'dart:async';
import 'package:cashback_farms/common/colours.dart';
import 'package:cashback_farms/common/route/router.dart';
import 'package:cashback_farms/common/widget/loader.dart';
import 'package:cashback_farms/features/material_store/controller/material_store_controller.dart';
import 'package:cashback_farms/features/material_store/model/material_home_list_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class MaterialStore extends StatefulWidget {
  const MaterialStore({super.key});

  @override
  State<MaterialStore> createState() => _MaterialStoreState();
}

class _MaterialStoreState extends State<MaterialStore>
    with SingleTickerProviderStateMixin {
  final MaterialController controller = Get.put(MaterialController());
  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocusNode = FocusNode();

  Timer? _debounce;
  final RxList<MaterialHomeListModel> _suggestions =
      <MaterialHomeListModel>[].obs;
  final RxBool _showSuggestions = false.obs;
  final RxString _liveQuery = ''.obs;
  bool _isSearchFocused = false;

  // ── Enter-animation ──────────────────────────────────────────────────────
  late AnimationController _enterAnim;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();

    controller.clearFilter();

    _enterAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    _fadeAnim =
        CurvedAnimation(parent: _enterAnim, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, -0.07),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _enterAnim, curve: Curves.easeOut));
    _enterAnim.forward();

    _searchFocusNode.addListener(() {
      setState(() => _isSearchFocused = _searchFocusNode.hasFocus);
      if (!_searchFocusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 160), () {
          _showSuggestions.value = false;
        });
      }
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200 &&
          !controller.isFetchingMoreMaterialService &&
          controller.materialServiceCurrentPage <
              controller.materialServiceTotalPages) {
        controller.loadMoreMaterialService();
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchFocusNode.dispose();
    _enterAnim.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ── Autocomplete helpers ──────────────────────────────────────────────────

  void _onSearchChanged(String value) {
    _liveQuery.value = value;
    _debounce?.cancel();
    if (value.trim().isEmpty) {
      _suggestions.clear();
      _showSuggestions.value = false;
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 150), () {
      _computeSuggestions(value.trim());
    });
  }

  void _computeSuggestions(String query) {
    final lower = query.toLowerCase();
    final Set<String> seen = {};
    final List<MaterialHomeListModel> out = [];
    for (final item in controller.materialServiceList) {
      final name = item.materialName ?? '';
      final cat = item.category?.categoryName ?? '';
      if ((name.toLowerCase().contains(lower) ||
          cat.toLowerCase().contains(lower)) &&
          !seen.contains(name)) {
        seen.add(name);
        out.add(item);
      }
      if (out.length >= 6) break;
    }
    _suggestions.assignAll(out);
    _showSuggestions.value = out.isNotEmpty;
  }

  void _applySuggestion(MaterialHomeListModel item) {
    controller.searchController.text = item.materialName ?? '';
    _liveQuery.value = item.materialName ?? '';
    _suggestions.clear();
    _showSuggestions.value = false;
    _searchFocusNode.unfocus();
    controller.applyFilter(
      search: item.materialName ?? '',
      category: controller.selectedCategory,
      subCategory: controller.selectedSubCategory,
      subSubCategory: controller.selectedSubSubCategory,
      brandIds: controller.selectedBrandIds,
    );
  }

  void _clearSearch() {
    controller.searchController.clear();
    _liveQuery.value = '';
    _suggestions.clear();
    _showSuggestions.value = false;
    controller.clearFilter();
  }

  void _submitSearch() {
    _suggestions.clear();
    _showSuggestions.value = false;
    _searchFocusNode.unfocus();
    controller.applyFilter(
      search: controller.searchController.text,
      category: controller.selectedCategory,
      subCategory: controller.selectedSubCategory,
      subSubCategory: controller.selectedSubSubCategory,
      brandIds: controller.selectedBrandIds,
    );
  }

  // ── Filter bottom sheet ───────────────────────────────────────────────────

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return GetBuilder<MaterialController>(
          builder: (ctrl) {
            return Container(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 28,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius:
                BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Filter",
                              style: TextStyle(
                                fontSize: 26.sp,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF1A1A1A),
                                letterSpacing: -0.5,
                              ),
                            ),
                            Text(
                              "Narrow down your materials",
                              style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => Get.back(),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close,
                                color: Colors.black54, size: 18),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    _sheetLabel("Main Category"),
                    const SizedBox(height: 8),
                    _styledDropdown(
                      hint: "Select Category",
                      value: ctrl.selectedCategory,
                      icon: Icons.grid_view_rounded,
                      items: ctrl.categoryList
                          .map((e) => DropdownMenuItem(
                        value: e.id.toString(),
                        child: Text(e.categoryName ?? ""),
                      ))
                          .toList(),
                      onChanged: (val) {
                        ctrl.selectedCategory = val;
                        ctrl.selectedSubCategory = null;
                        ctrl.selectedSubSubCategory = null;
                        ctrl.subCategoryList.clear();
                        ctrl.subSubCategoryList.clear();
                        ctrl.update();
                        if (val != null && val.isNotEmpty) {
                          ctrl.getSubCategories(val);
                        }
                      },
                    ),

                    const SizedBox(height: 20),
                    _sheetLabel("Sub Category"),
                    const SizedBox(height: 8),
                    _styledDropdown(
                      hint: ctrl.isSubCategoryLoading
                          ? "Loading..."
                          : "Select Sub Category",
                      value: ctrl.selectedSubCategory,
                      icon: Icons.account_tree_outlined,
                      items: ctrl.subCategoryList
                          .map((e) => DropdownMenuItem(
                        value: e.id.toString(),
                        child: Text(e.name ?? ""),
                      ))
                          .toList(),
                      onChanged: (val) {
                        ctrl.selectedSubCategory = val;
                        ctrl.selectedSubSubCategory = null;
                        ctrl.subSubCategoryList.clear();
                        ctrl.update();
                        ctrl.getSubSubCategories(val);
                      },
                    ),

                    const SizedBox(height: 20),
                    _sheetLabel("Specific Type"),
                    const SizedBox(height: 8),
                    _styledDropdown(
                      hint: ctrl.isSubSubCategoryLoading
                          ? "Loading..."
                          : "Select Specific Type",
                      value: ctrl.selectedSubSubCategory,
                      icon: Icons.category_outlined,
                      items: ctrl.subSubCategoryList
                          .map((e) => DropdownMenuItem(
                        value: e.id.toString(),
                        child: Text(e.name ?? ""),
                      ))
                          .toList(),
                      onChanged: (val) {
                        ctrl.selectedSubSubCategory = val;
                        ctrl.update();
                      },
                    ),

                    const SizedBox(height: 20),
                    _sheetLabel("Product Brand"),
                    const SizedBox(height: 8),
                    _buildMultiSelectBrands(ctrl),

                    const SizedBox(height: 36),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              ctrl.clearFilter();
                              Get.back();
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.redAccent,
                              side: const BorderSide(
                                  color: Colors.redAccent, width: 1.5),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15),
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(16)),
                            ),
                            child: const Text("Reset",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          flex: 2,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF4E8020),
                                  Color(0xFF85C038)
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColor.primary
                                      .withOpacity(0.32),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 16),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(16)),
                                elevation: 0,
                              ),
                              onPressed: () {
                                ctrl.applyFilter(
                                  search: ctrl.searchController.text,
                                  category: ctrl.selectedCategory,
                                  subCategory: ctrl.selectedSubCategory,
                                  subSubCategory:
                                  ctrl.selectedSubSubCategory,
                                  brandIds: ctrl.selectedBrandIds,
                                );
                                Get.back();
                              },
                              child: const Text(
                                "Apply Filter",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
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

  Widget _sheetLabel(String label) => Padding(
    padding: const EdgeInsets.only(left: 2),
    child: Text(
      label.toUpperCase(),
      style: TextStyle(
        fontSize: 10.sp,
        fontWeight: FontWeight.w700,
        color: Colors.blueGrey.shade400,
        letterSpacing: 1.2,
      ),
    ),
  );

  Widget _styledDropdown({
    required String hint,
    required String? value,
    required IconData icon,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          dropdownColor: Colors.white,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded,
              color: Colors.grey.shade400, size: 22),
          value: value,
          hint: Row(
            children: [
              Icon(icon, size: 18, color: AppColor.primary),
              const SizedBox(width: 10),
              Text(hint,
                  style: TextStyle(
                      color: Colors.grey.shade400, fontSize: 14.sp)),
            ],
          ),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildMultiSelectBrands(MaterialController ctrl) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Selected chips
          if (ctrl.selectedBrandNames.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ctrl.selectedBrandNames.map((name) {
                int index = ctrl.selectedBrandNames.indexOf(name);
                return Chip(
                  backgroundColor: Colors.white,
                  label: Text(name,
                      style: const TextStyle(fontSize: 12)),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  onDeleted: () {
                    ctrl.selectedBrandIds.removeAt(index);
                    ctrl.selectedBrandNames.removeAt(index);
                    ctrl.update();
                  },
                );
              }).toList(),
            ),
          if (ctrl.selectedBrandNames.isNotEmpty)
            const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: ListView.builder(
              itemCount: ctrl.brandList.length,
              itemBuilder: (context, index) {
                final brand = ctrl.brandList[index];
                bool isSelected = ctrl.selectedBrandIds
                    .contains(brand.id.toString());
                return CheckboxListTile(
                  activeColor: AppColor.primary,
                  value: isSelected,
                  title: Text(
                    brand.name ?? "",
                    style: TextStyle(fontSize: 13.sp),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  onChanged: (val) {
                    if (val == true) {
                      ctrl.selectedBrandIds.add(brand.id.toString());
                      ctrl.selectedBrandNames.add(brand.name ?? "");
                    } else {
                      ctrl.selectedBrandIds.remove(brand.id.toString());
                      ctrl.selectedBrandNames.remove(brand.name ?? "");
                    }
                    ctrl.update();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── ROOT BUILD ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _searchFocusNode.unfocus();
        _showSuggestions.value = false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6F0),
        body: Column(
          children: [
            // ── Animated Header ─────────────────────────────────────────────
            FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: _buildHeader(),
              ),
            ),

            // ── Body + autocomplete overlay ─────────────────────────────────
            Expanded(
              child: Stack(
                children: [
                  // Grid content
                  _buildGrid(),

                  // Autocomplete dropdown
                  Obx(() {
                    if (!_showSuggestions.value ||
                        _suggestions.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Positioned(
                      top: 0,
                      left: 14.w,
                      right: 14.w,
                      child: Material(
                        color: Colors.transparent,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.13),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius:
                            BorderRadius.circular(20.r),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                for (int i = 0;
                                i < _suggestions.length;
                                i++) ...[
                                  _suggestionTile(
                                      _suggestions[i],
                                      _liveQuery.value),
                                  if (i <
                                      _suggestions.length - 1)
                                    Divider(
                                      height: 1,
                                      thickness: 1,
                                      color:
                                      Colors.grey.shade100,
                                      indent: 60.w,
                                    ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2A5410), Color(0xFF68A82A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Decorative blobs
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          Positioned(
            top: 26,
            right: 72,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            bottom: 8,
            left: -24,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.04),
              ),
            ),
          ),

          SafeArea(
            bottom: false,
            child: Padding(
              padding:
              EdgeInsets.fromLTRB(18.w, 14.h, 18.w, 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title row + filter icon
                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            "MATERIAL",
                            style: TextStyle(
                              fontSize: 9.5.sp,
                              color: Colors.white.withOpacity(
                                  0.68),
                              letterSpacing: 3,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            "Store",
                            style: TextStyle(
                              fontSize: 30.sp,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -0.8,
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                      // Filter button
                      GestureDetector(
                        onTap: () =>
                            _showFilterBottomSheet(context),
                        child: Container(
                          padding: EdgeInsets.all(10.w),
                          decoration: BoxDecoration(
                            color:
                            Colors.white.withOpacity(0.18),
                            borderRadius:
                            BorderRadius.circular(14.r),
                            border: Border.all(
                              color: Colors.white
                                  .withOpacity(0.28),
                              width: 1,
                            ),
                          ),
                          child: Icon(Icons.tune_rounded,
                              color: Colors.white, size: 22.w),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 18.h),

                  // ── Search bar ───────────────────────────────────────────
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 50.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(
                              _isSearchFocused ? 0.20 : 0.13),
                          blurRadius:
                          _isSearchFocused ? 24 : 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                      border: Border.all(
                        color: _isSearchFocused
                            ? Colors.white.withOpacity(0.75)
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: 16.w),
                        Icon(Icons.search_rounded,
                            color: AppColor.primary,
                            size: 21.w),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: TextField(
                            controller:
                            controller.searchController,
                            focusNode: _searchFocusNode,
                            onChanged: _onSearchChanged,
                            textInputAction:
                            TextInputAction.search,
                            onSubmitted: (_) => _submitSearch(),
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: const Color(0xFF1A1A1A),
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              hintText: "Search materials…",
                              hintStyle: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 13.5.sp,
                                fontWeight: FontWeight.w400,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding:
                              EdgeInsets.symmetric(
                                  vertical: 13.h),
                            ),
                          ),
                        ),
                        Obx(() => _liveQuery.value.isNotEmpty
                            ? GestureDetector(
                          onTap: _clearSearch,
                          child: Container(
                            margin: EdgeInsets.only(
                                right: 10.w),
                            padding:
                            EdgeInsets.all(4.w),
                            decoration: BoxDecoration(
                              color:
                              Colors.grey.shade200,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.close,
                                size: 13.w,
                                color: Colors
                                    .grey.shade600),
                          ),
                        )
                            : SizedBox(width: 12.w)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Grid ──────────────────────────────────────────────────────────────────

  Widget _buildGrid() {
    return GetBuilder<MaterialController>(
      builder: (ctrl) {
        if (ctrl.isMaterialServiceLoading) {
          return Center(
            child: GifLoader(message: "Loading...", size: 90),
          );
        }
        if (ctrl.materialServiceList.isEmpty) {
          return _buildEmptyState();
        }
        final list = ctrl.materialServiceList;
        return RefreshIndicator(
          color: AppColor.primary,
          onRefresh: () async => ctrl.clearFilter(),
          child: GridView.builder(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding:
            EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 28.h),
            gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: 0.78,
            ),
            itemCount: list.length +
                (ctrl.isFetchingMoreMaterialService ? 2 : 0),
            itemBuilder: (context, index) {
              if (index >= list.length) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.55),
                    borderRadius:
                    BorderRadius.circular(20.r),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                        color: AppColor.primary,
                        strokeWidth: 2),
                  ),
                );
              }
              return _buildServiceCard(list[index], index);
            },
          ),
        );
      },
    );
  }

  // ── Suggestion tile ───────────────────────────────────────────────────────

  Widget _suggestionTile(
      MaterialHomeListModel item, String query) {
    final imageUrl = (item.image != null && item.image!.isNotEmpty)
        ? item.image!.first
        : '';
    final name = item.materialName ?? '';
    final cat = item.category?.categoryName ?? '';

    return InkWell(
      onTap: () => _applySuggestion(item),
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(
            horizontal: 14.w, vertical: 12.h),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: imageUrl.isNotEmpty
                  ? Image.network(
                imageUrl,
                width: 40.w,
                height: 40.w,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    _suggestionThumb(),
              )
                  : _suggestionThumb(),
            ),
            SizedBox(width: 12.w),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _highlightText(
                    name,
                    query,
                    TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                  if (cat.isNotEmpty) ...[
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Icon(Icons.grid_view_rounded,
                            size: 10.w,
                            color: AppColor.primary
                                .withOpacity(0.7)),
                        SizedBox(width: 3.w),
                        Text(
                          cat,
                          style: TextStyle(
                            fontSize: 10.5.sp,
                            color: AppColor.primary
                                .withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.north_west_rounded,
                size: 13.w, color: Colors.grey.shade300),
          ],
        ),
      ),
    );
  }

  Widget _suggestionThumb() {
    return Container(
      width: 40.w,
      height: 40.w,
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2E8),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Icon(Icons.store_rounded,
          color: AppColor.primary.withOpacity(0.3), size: 18),
    );
  }

  Widget _highlightText(
      String text, String query, TextStyle base) {
    if (query.isEmpty) {
      return Text(text,
          style: base,
          maxLines: 1,
          overflow: TextOverflow.ellipsis);
    }
    final lower = text.toLowerCase();
    final lowerQ = query.toLowerCase();
    final idx = lower.indexOf(lowerQ);
    if (idx == -1) {
      return Text(text,
          style: base,
          maxLines: 1,
          overflow: TextOverflow.ellipsis);
    }
    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(style: base, children: [
        if (idx > 0) TextSpan(text: text.substring(0, idx)),
        TextSpan(
          text: text.substring(idx, idx + query.length),
          style: base.copyWith(
            color: AppColor.primary,
            fontWeight: FontWeight.w900,
            backgroundColor: AppColor.primary.withOpacity(0.10),
          ),
        ),
        if (idx + query.length < text.length)
          TextSpan(
              text: text.substring(idx + query.length)),
      ]),
    );
  }

  // ── Service card ──────────────────────────────────────────────────────────

  Widget _buildServiceCard(MaterialHomeListModel item, int index) {
    final imageUrl = (item.image != null && item.image!.isNotEmpty)
        ? item.image!.first
        : '';

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 280 + (index % 6) * 55),
      curve: Curves.easeOut,
      builder: (context, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(
            offset: Offset(0, 16 * (1 - v)), child: child),
      ),
      child: GestureDetector(
        onTap: () => Get.toNamed(
          AppRoutes.vendorList,
          arguments: {
            'id': item.id,
            'title': item.materialName,
          },
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image + badges
              Expanded(
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20.r)),
                      child: imageUrl.isNotEmpty
                          ? Image.network(
                        imageUrl,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _cardPlaceholder(),
                      )
                          : _cardPlaceholder(),
                    ),
                    // Subtle bottom gradient
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: ClipRRect(
                        borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20.r)),
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.18),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Category badge
                    if (item.category?.categoryName != null)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          constraints: BoxConstraints(
                              maxWidth:
                              MediaQuery.of(context)
                                  .size
                                  .width *
                                  0.28),
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h),
                          decoration: BoxDecoration(
                            color: AppColor.primary
                                .withOpacity(0.88),
                            borderRadius:
                            BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            item.category!.categoryName!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 9.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Name + code + arrow
              Padding(
                padding: EdgeInsets.fromLTRB(
                    10.w, 10.h, 10.w, 10.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.materialName ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.5.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1A1A1A),
                              height: 1.3,
                            ),
                          ),

                          if (item.materialCode != null &&
                              item.materialCode!.isNotEmpty) ...[
                            SizedBox(height: 4.h),
                            Text(
                              "Code: ${item.materialCode}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    SizedBox(width: 4.w),

                    Container(
                      padding: EdgeInsets.all(5.w),
                      decoration: BoxDecoration(
                        color: AppColor.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color: AppColor.primary,
                        size: 12.w,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cardPlaceholder() {
    return Container(
      color: const Color(0xFFEEF2E8),
      child: Center(
        child: Icon(Icons.store_rounded,
            color: AppColor.primary.withOpacity(0.22),
            size: 36),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(26.w),
            decoration: BoxDecoration(
              color: AppColor.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.store_outlined,
                size: 48.w, color: AppColor.primary),
          ),
          SizedBox(height: 20.h),
          Text(
            "No Materials Found",
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "Try adjusting your filters\nor pull down to refresh",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey.shade500,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}