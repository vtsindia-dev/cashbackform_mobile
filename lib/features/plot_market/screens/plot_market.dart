import 'package:cashback_farms/common/colours.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../common/widget/appbar.dart';
import '../../../common/widget/loader.dart';
import '../controller/plot_market_controller.dart';
import '../model/plot_market.dart';
import '../widget/plot_market_list.dart';

class PlotMarket extends StatelessWidget {
  const PlotMarket({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PlotMarketController>(
      init: PlotMarketController(),
      builder: (controller) {
        return Scaffold(
          appBar: DynamicAppBar(
            title: "Land",
            showBackButton: true,
          ),
          body: controller.isLoading.value
              ? const Center(child: GifLoader(message: "Loading...", size: 100))
              : _buildContent(controller),
        );
      },
    );
  }

  Widget _buildContent(PlotMarketController controller) {
    return Column(
      children: [
        _buildSearchFilterSection(controller),
        SizedBox(height: 8.h),
        Expanded(
          child: PlotMarketList(),
        ),
      ],
    );
  }

  Widget _buildSearchFilterSection(PlotMarketController controller) {
    return Container(
      margin: EdgeInsets.all(12.w),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Search icon
          Icon(Icons.search, color: Colors.grey.shade600, size: 20.w),
          SizedBox(width: 8.w),

          // Search input — onChanged drives autocomplete, no spinner
          Expanded(
            child: TextField(
              controller: controller.searchController,
              onChanged: controller.onSearchChanged, // ← autocomplete hook
              onSubmitted: (_) => controller.applySearch(),
              decoration: InputDecoration(
                hintText: "Search plots...",
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: TextStyle(fontSize: 14.sp),
            ),
          ),

          // Clear button — only shown when there is text
          Obx(() {
            if (controller.searchQuery.value.isNotEmpty) {
              return GestureDetector(
                onTap: controller.clearRecentSearch,
                child: Icon(Icons.close,
                    color: Colors.grey.shade500, size: 18.w),
              );
            }
            return const SizedBox.shrink();
          }),
          SizedBox(width: 8.w),

          // Explicit search button (still works for Enter / tap)
          GestureDetector(
            onTap: controller.applySearch,
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF819E4F), Color(0xFF9CB45A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "Search",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),

          // Filter button with active-count badge
          GestureDetector(
            onTap: () => _showFilterSheet(controller),
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppColor.primary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.tune, color: AppColor.primary, size: 18.w),
                  SizedBox(width: 4.w),
                  Obx(() {
                    final filterCount = controller.getActiveFilterCount();
                    if (filterCount > 0) {
                      return Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: AppColor.primary,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text(
                          filterCount.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFiltersBar(PlotMarketController controller) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.w),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.filter_list, color: AppColor.primary, size: 16.w),
              SizedBox(width: 6.w),
              Obx(() {
                final filterCount = controller.getActiveFilterCount();
                return Text(
                  "$filterCount filter${filterCount > 1 ? 's' : ''} active",
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColor.primary,
                    fontWeight: FontWeight.w500,
                  ),
                );
              }),
            ],
          ),
          GestureDetector(
            onTap: controller.clearFilters,
            child: Row(
              children: [
                Icon(Icons.refresh, color: Colors.red, size: 16.w),
                SizedBox(width: 4.w),
                Text(
                  "Clear all",
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(PlotMarketController controller) {
    showModalBottomSheet(
      context: Get.context!,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ModernFilterSheet(controller: controller),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Modern Filter Sheet
// ─────────────────────────────────────────────────────────────────────────────
class _ModernFilterSheet extends StatefulWidget {
  final PlotMarketController controller;
  const _ModernFilterSheet({required this.controller});

  @override
  State<_ModernFilterSheet> createState() => _ModernFilterSheetState();
}

class _ModernFilterSheetState extends State<_ModernFilterSheet> {
  late RangeValues _priceRange;
  late RangeValues _areaRange;
  late List<PropertyType> _selectedTypes;
  late AppState? _selectedState;
  late City? _selectedCity;

  bool _priceChanged = false;
  bool _areaChanged = false;

  bool _showAllStates = false;
  bool _showAllCities = false;
  bool _showAllPlotTypes = false;
  final int _initialItemCount = 4;

  bool _isLoadingStates = false;
  bool _isLoadingCities = false;

  @override
  void initState() {
    super.initState();
    _initFilters();
    _ensureStatesLoaded();
  }

  void _ensureStatesLoaded() async {
    if (widget.controller.states.isEmpty && !_isLoadingStates) {
      setState(() => _isLoadingStates = true);
      await widget.controller.fetchStates();
      setState(() => _isLoadingStates = false);
    }
  }

  void _initFilters() {
    final c = widget.controller;

    _priceChanged = c.minPrice.value.isNotEmpty;
    double startP =
    _priceChanged ? double.parse(c.minPrice.value) : c.priceMin.value;
    double endP = c.maxPrice.value.isNotEmpty
        ? double.parse(c.maxPrice.value)
        : c.priceMax.value;
    _priceRange = RangeValues(
      startP.clamp(c.priceMin.value, c.priceMax.value),
      endP.clamp(c.priceMin.value, c.priceMax.value),
    );

    _areaChanged = c.minAreaSqft.value.isNotEmpty;
    double startA =
    _areaChanged ? double.parse(c.minAreaSqft.value) : c.areaMin.value;
    double endA = c.maxAreaSqft.value.isNotEmpty
        ? double.parse(c.maxAreaSqft.value)
        : c.areaMax.value;
    _areaRange = RangeValues(
      startA.clamp(c.areaMin.value, c.areaMax.value),
      endA.clamp(c.areaMin.value, c.areaMax.value),
    );

    _selectedTypes = List.from(c.selectedPlotTypes);
    _selectedState = c.selectedState.value;
    _selectedCity = c.selectedCity.value;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      minChildSize: 0.6,
      builder: (_, scrollController) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(40.r)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 45.w,
              height: 4.h,
              decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10.r)),
            ),
            _buildHeader(),
            Expanded(
              child: ListView(
                controller: scrollController,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                children: [
                  _buildAnimatedSection(
                    0,
                    "LOCATION",
                    icon: Icons.location_on_rounded,
                    color: Colors.orange,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabelTag("STATE"),
                        const SizedBox(height: 10),
                        Obx(() => _buildStateSelector()),
                        if (_selectedState != null) ...[
                          const SizedBox(height: 20),
                          _buildLabelTag("CITY"),
                          const SizedBox(height: 10),
                          Obx(() => _buildCitySelector()),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildAnimatedSection(
                    1,
                    "PLOT TYPE",
                    icon: Icons.grid_view_rounded,
                    color: Colors.blueAccent,
                    child: _buildPlotTypeChips(),
                  ),
                  const SizedBox(height: 32),
                  _buildAnimatedSection(
                    2,
                    "PRICE RANGE",
                    icon: Icons.payments_rounded,
                    color: Colors.green,
                    trailing: _priceChanged
                        ? "₹${_formatNumber(_priceRange.start)} - ₹${_formatNumber(_priceRange.end)}"
                        : "Any Price",
                    child: _buildPriceSlider(),
                  ),
                  const SizedBox(height: 32),
                  _buildAnimatedSection(
                    3,
                    "AREA RANGE",
                    icon: Icons.square_foot_rounded,
                    color: Colors.purple,
                    trailing: _areaChanged
                        ? "${_areaRange.start.toInt()} - ${_areaRange.end.toInt()} sqft"
                        : "Any Area",
                    child: _buildAreaSlider(),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  String _formatNumber(double number) {
    if (number >= 10000000)
      return '${(number / 10000000).toStringAsFixed(1)}Cr';
    if (number >= 100000) return '${(number / 100000).toStringAsFixed(1)}L';
    if (number >= 1000) return '${(number / 1000).toStringAsFixed(1)}K';
    return number.toStringAsFixed(0);
  }

  Widget _buildLabelTag(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w900,
          color: AppColor.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildAnimatedSection(
      int index,
      String title, {
        required IconData icon,
        required Color color,
        required Widget child,
        String? trailing,
      }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 100)),
      builder: (context, value, _) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 15 * (1 - value)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 16.w, color: color),
                  SizedBox(width: 8.w),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: Colors.grey[600],
                    ),
                  ),
                  const Spacer(),
                  if (trailing != null)
                    Text(
                      trailing,
                      style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: color),
                    ),
                ],
              ),
              SizedBox(height: 16.h),
              child,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectorItem({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColor.primary : Colors.grey[50],
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
              color: isSelected ? AppColor.primary : Colors.grey[200]!),
          boxShadow: isSelected
              ? [
            BoxShadow(
                color: Colors.blue.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight:
            isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 13.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildStateSelector() {
    if (_isLoadingStates) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40.h),
          child: const CircularProgressIndicator(),
        ),
      );
    }

    final statesToShow = _showAllStates
        ? widget.controller.states
        : widget.controller.states.take(_initialItemCount).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: [
            _buildSelectorItem(
              label: "All States",
              isSelected: _selectedState == null,
              onTap: () {
                setState(() {
                  _selectedState = null;
                  _selectedCity = null;
                  widget.controller.cities.clear();
                });
              },
            ),
            ...statesToShow.map(
                  (state) => _buildSelectorItem(
                label: state.stateName,
                isSelected: _selectedState?.id == state.id,
                onTap: () async {
                  setState(() {
                    _selectedState = state;
                    _selectedCity = null;
                    _isLoadingCities = true;
                  });
                  widget.controller.onStateChanged(state);
                  await Future.delayed(const Duration(milliseconds: 100));
                  setState(() => _isLoadingCities = false);
                },
              ),
            ),
          ],
        ),
        if (widget.controller.states.length > _initialItemCount)
          _buildSeeMore(
                () => setState(() => _showAllStates = !_showAllStates),
            _showAllStates,
          ),
      ],
    );
  }

  Widget _buildCitySelector() {
    if (widget.controller.isCityLoading.value) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40.h),
          child: const CircularProgressIndicator(),
        ),
      );
    }

    if (_selectedState == null) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        child: const Text("Select state first",
            style: TextStyle(color: Colors.grey)),
      );
    }

    if (widget.controller.cities.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        child: const Text("No cities found",
            style: TextStyle(color: Colors.grey)),
      );
    }

    final citiesToShow = _showAllCities
        ? widget.controller.cities
        : widget.controller.cities.take(_initialItemCount).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: [
            _buildSelectorItem(
              label: "All Cities",
              isSelected: _selectedCity == null,
              onTap: () {
                setState(() {
                  _selectedCity = null;
                  widget.controller.selectedCity.value = null;
                });
              },
            ),
            ...citiesToShow.map(
                  (city) => _buildSelectorItem(
                label: city.cityName,
                isSelected: _selectedCity?.id == city.id,
                onTap: () {
                  setState(() {
                    _selectedCity = city;
                    widget.controller.selectedCity.value = city;
                  });
                },
              ),
            ),
          ],
        ),
        if (widget.controller.cities.length > _initialItemCount)
          _buildSeeMore(
                () => setState(() => _showAllCities = !_showAllCities),
            _showAllCities,
          ),
      ],
    );
  }

  Widget _buildPlotTypeChips() {
    final typesToShow = _showAllPlotTypes
        ? widget.controller.plotTypes
        : widget.controller.plotTypes.take(_initialItemCount).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: typesToShow
              .map(
                (type) => _buildSelectorItem(
              label: type.categoryName,
              isSelected: _selectedTypes.contains(type),
              onTap: () => setState(() {
                if (_selectedTypes.contains(type)) {
                  _selectedTypes.remove(type);
                } else {
                  _selectedTypes.add(type);
                }
              }),
            ),
          )
              .toList(),
        ),
        if (widget.controller.plotTypes.length > _initialItemCount)
          _buildSeeMore(
                () =>
                setState(() => _showAllPlotTypes = !_showAllPlotTypes),
            _showAllPlotTypes,
          ),
      ],
    );
  }

  Widget _buildSeeMore(VoidCallback onTap, bool isOpen) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Text(
          isOpen ? "- See Less" : "+ See More",
          style: TextStyle(
            color: AppColor.primary,
            fontSize: 12.sp,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget _buildPriceSlider() {
    return _buildSliderCard(
      accentColor: Colors.green,
      child: RangeSlider(
        values: _priceRange,
        min: widget.controller.priceMin.value,
        max: widget.controller.priceMax.value,
        divisions: 10,
        labels: RangeLabels(
          "₹${_formatNumber(_priceRange.start)}",
          "₹${_formatNumber(_priceRange.end)}",
        ),
        onChanged: (val) {
          setState(() {
            _priceRange = val;
            _priceChanged = true;
          });
        },
      ),
    );
  }

  Widget _buildAreaSlider() {
    return _buildSliderCard(
      accentColor: Colors.purple,
      child: RangeSlider(
        values: _areaRange,
        min: widget.controller.areaMin.value,
        max: widget.controller.areaMax.value,
        divisions: 10,
        labels: RangeLabels(
          "${_areaRange.start.toInt()} sqft",
          "${_areaRange.end.toInt()} sqft",
        ),
        onChanged: (val) {
          setState(() {
            _areaRange = val;
            _areaChanged = true;
          });
        },
      ),
    );
  }

  Widget _buildSliderCard(
      {required Widget child, required Color accentColor}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: SliderTheme(
        data: SliderTheme.of(context).copyWith(
          trackHeight: 6.h,
          activeTrackColor: accentColor,
          inactiveTrackColor: accentColor.withOpacity(0.1),
          thumbColor: Colors.white,
          rangeThumbShape:
          RoundRangeSliderThumbShape(enabledThumbRadius: 12.r, elevation: 5),
        ),
        child: child,
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Filters",
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
              ),
              Text(
                "Customize your search",
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: _resetAllFilters,
            child: Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.red[50],
                shape: BoxShape.circle,
              ),
              child:
              Icon(Icons.refresh_rounded, color: Colors.red[400], size: 22.w),
            ),
          ),
        ],
      ),
    );
  }

  void _resetAllFilters() {
    final c = widget.controller;

    c.minPrice.value = "";
    c.maxPrice.value = "";
    c.minAreaSqft.value = "";
    c.maxAreaSqft.value = "";
    c.selectedPlotTypes.clear();
    c.selectedState.value = null;
    c.selectedCity.value = null;
    c.cities.clear();

    setState(() {
      _priceRange = RangeValues(c.priceMin.value, c.priceMax.value);
      _areaRange = RangeValues(c.areaMin.value, c.areaMax.value);
      _selectedTypes.clear();
      _selectedState = null;
      _selectedCity = null;
      _priceChanged = false;
      _areaChanged = false;
      _showAllStates = false;
      _showAllCities = false;
      _showAllPlotTypes = false;
    });
  }

  Widget _buildFooter() {
    return Container(
      padding: EdgeInsets.fromLTRB(
          24.w, 16.h, 24.w, MediaQuery.of(context).padding.bottom + 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.primary,
          minimumSize: Size(double.infinity, 60.h),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r)),
          elevation: 8,
          shadowColor: Colors.blue.withOpacity(0.4),
        ),
        onPressed: () {
          widget.controller.selectedPlotTypes.assignAll(_selectedTypes);

          widget.controller.minPrice.value =
          _priceChanged ? _priceRange.start.toInt().toString() : "";
          widget.controller.maxPrice.value =
          _priceChanged ? _priceRange.end.toInt().toString() : "";

          widget.controller.minAreaSqft.value =
          _areaChanged ? _areaRange.start.toInt().toString() : "";
          widget.controller.maxAreaSqft.value =
          _areaChanged ? _areaRange.end.toInt().toString() : "";

          widget.controller.selectedState.value = _selectedState;
          widget.controller.selectedCity.value = _selectedCity;
          widget.controller.fetchMarketPlots();
          Get.back();
        },
        child: Text(
          "Show Plots",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}