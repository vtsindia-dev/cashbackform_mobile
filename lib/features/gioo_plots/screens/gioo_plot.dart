import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../common/widget/appbar.dart';
import '../../../common/widget/loader.dart';
import '../../../common/widget/note_info.dart';
import '../../menu/controller/dashboard_menu_controller.dart';
import '../controller/gioo_controller.dart';
import '../model/gioo_plot.dart';
import '../widget/gioo_plot_list.dart';

class Giooplot extends StatefulWidget {
  const Giooplot({super.key});

  @override
  State<Giooplot> createState() => _GiooplotState();
}

class _GiooplotState extends State<Giooplot> {
  final GiooPlotController controller = Get.put(GiooPlotController());

  @override
  void initState() {
    super.initState();
    // Fetch initial data
    controller.fetchGiooPlots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F2),
      appBar: const DynamicAppBar(title: "Gioo Plots", showBackButton: true),
      body: Obx(
        () => Column(
          children: [
            _CompactFilterSection(controller: controller),
            _buildNoteContent(),
            controller.isLoading.value
                ? Expanded(
                    child: const Center(
                      child: GifLoader(
                        message: "Finding best plots...",
                        size: 100,
                      ),
                    ),
                  )
                : Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        await controller.refreshData();
                      },
                      child: Obx(() {
                        if (controller.giooPlots.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(height: 20),
                                const Text(
                                  'No plots found',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'Try adjusting your filters',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          );
                        }
                        return GiooPlotList();
                      }),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
  Widget _buildNoteContent() {
    final dashboardController = Get.find<DashboardController>();

    return Obx(() {
      if (dashboardController.isLoadingSettings.value) {
        return const SizedBox.shrink(); // Or show a small loader
      }

      final settings = dashboardController.businessSettings.value;
      if (settings == null) return const SizedBox.shrink();

      return Column(
        children: [
          if (settings.gioonanoDescription != null &&
              settings.gioonanoDescription!.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 0.h),
              child: CompactNoteCard(
                title: "Gioo Nano Information",
                description: settings.gioonanoDescription!,
                icon: Icons.lan,
              ),
            ),
        ],
      );
    });
  }
}

void _showFilterSheet(BuildContext context, GiooPlotController controller) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _ModernFilterSheet(controller: controller),
  );
}

class _ModernFilterSheet extends StatefulWidget {
  final GiooPlotController controller;

  const _ModernFilterSheet({required this.controller});

  @override
  State<_ModernFilterSheet> createState() => _ModernFilterSheetState();
}

class _ModernFilterSheetState extends State<_ModernFilterSheet> {
  late RangeValues _priceRange;
  late RangeValues _areaRange;
  late List<String> _selectedTypes;
  late AppState? _selectedState;
  late City? _selectedCity;
  late List<City> _filteredCities;

  bool _priceChanged = false;
  bool _areaChanged = false;

  bool _showAllStates = false;
  bool _showAllCities = false;
  bool _showAllPropertyTypes = false;
  final int _initialItemCount = 4;

  bool _isApplyingFilters = false;

  @override
  void initState() {
    super.initState();
    _initFilters();
    _filteredCities = widget.controller.cities;
  }

  void _initFilters() {
    final c = widget.controller;

    // Price Init
    _priceChanged = c.minPrice.value.isNotEmpty;
    double startP = _priceChanged
        ? double.tryParse(c.minPrice.value) ?? c.priceMin.value
        : c.priceMin.value;
    double endP = c.maxPrice.value.isNotEmpty
        ? double.tryParse(c.maxPrice.value) ?? c.priceMax.value
        : c.priceMax.value;
    _priceRange = RangeValues(
      startP.clamp(c.priceMin.value, c.priceMax.value),
      endP.clamp(c.priceMin.value, c.priceMax.value),
    );

    // Area Init (Now as a Range)
    _areaChanged = c.minAreaSqft.value.isNotEmpty;
    double startA = _areaChanged
        ? double.tryParse(c.minAreaSqft.value) ?? c.sqftMin.value
        : c.sqftMin.value;
    double endA = c.maxAreaSqft.value.isNotEmpty
        ? double.tryParse(c.maxAreaSqft.value) ?? c.sqftMax.value
        : c.sqftMax.value;
    _areaRange = RangeValues(
      startA.clamp(c.sqftMin.value, c.sqftMax.value),
      endA.clamp(c.sqftMin.value, c.sqftMax.value),
    );

    _selectedTypes = List.from(c.selectedPlotTypes);
    _selectedState = c.selectedState.value;
    _selectedCity = c.selectedCity.value;

    _updateFilteredCities();
  }

  void _updateFilteredCities() {
    if (_selectedState != null) {
      // If state is selected, fetch cities for that state
      widget.controller.fetchCitiesForState(_selectedState!.id);
      // Wait for cities to load or use existing ones
      _filteredCities = widget.controller.cities;
    } else {
      _filteredCities = widget.controller.cities;
    }
  }

  Future<void> _applyFilters() async {
    setState(() {
      _isApplyingFilters = true;
    });

    // Add a small delay for better UX
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      widget.controller.selectedPlotTypes.assignAll(_selectedTypes);

      // PRICE LOGIC
      widget.controller.minPrice.value = _priceChanged
          ? _priceRange.start.toInt().toString()
          : "";
      widget.controller.maxPrice.value = _priceChanged
          ? _priceRange.end.toInt().toString()
          : "";

      // AREA LOGIC (Now handles Min and Max)
      widget.controller.minAreaSqft.value = _areaChanged
          ? _areaRange.start.toInt().toString()
          : "";
      widget.controller.maxAreaSqft.value = _areaChanged
          ? _areaRange.end.toInt().toString()
          : "";

      // State and City
      widget.controller.selectedState.value = _selectedState;
      widget.controller.selectedCity.value = _selectedCity;

      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      await widget.controller.fetchGiooPlots();
    } catch (e) {
      print('Error applying filters: $e');
    } finally {
      setState(() {
        _isApplyingFilters = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      minChildSize: 0.6,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 45,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            _buildHeader(),
            Expanded(
              child: ListView(
                controller: scrollController,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  _buildAnimatedSection(
                    0,
                    "GIOO LOCATION",
                    icon: Icons.location_on_rounded,
                    color: Colors.orange,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabelTag("STATE"),
                        const SizedBox(height: 10),
                        _buildStateSelector(),
                        if (_selectedState != null) ...[
                          const SizedBox(height: 20),
                          _buildLabelTag("CITY"),
                          const SizedBox(height: 10),
                          _buildCitySelector(),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildAnimatedSection(
                    1,
                    "PROPERTY CATEGORY",
                    icon: Icons.grid_view_rounded,
                    color: Colors.blueAccent,
                    child: _buildTypeChips(),
                  ),
                  const SizedBox(height: 32),
                  _buildAnimatedSection(
                    2,
                    "PRICE BUDGET",
                    icon: Icons.payments_rounded,
                    color: Colors.green,
                    trailing: _priceChanged
                        ? "₹${_priceRange.start.toInt()} - ₹${_priceRange.end.toInt()}"
                        : "Open Budget",
                    child: _buildPriceSlider(),
                  ),
                  const SizedBox(height: 32),
                  _buildAnimatedSection(
                    3,
                    "LAND AREA RANGE",
                    icon: Icons.square_foot_rounded,
                    color: Colors.purple,
                    trailing: _areaChanged
                        ? "${_areaRange.start.toInt()} - ${_areaRange.end.toInt()} sqft"
                        : "Any Size",
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

  Widget _buildLabelTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF819E4F).withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: Color(0xFF819E4F),
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
                  Icon(icon, size: 16, color: color),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
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
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
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
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF819E4F) : Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF819E4F) : Colors.grey[200]!,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF819E4F).withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildStateSelector() {
    final statesToShow = _showAllStates
        ? widget.controller.states
        : widget.controller.states.take(_initialItemCount).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildSelectorItem(
              label: "All States",
              isSelected: _selectedState == null,
              onTap: () {
                setState(() {
                  _selectedState = null;
                  _selectedCity = null;
                  _updateFilteredCities();
                });
              },
            ),
            ...statesToShow.map(
              (state) => _buildSelectorItem(
                label: state.stateName,
                isSelected: _selectedState?.id == state.id,
                onTap: () {
                  setState(() {
                    _selectedState = state;
                    _selectedCity = null;
                    _updateFilteredCities();
                  });
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
    return Obx(() {
      // Show loading when cities are being fetched
      if (widget.controller.isLoadingCities.value && _selectedState != null) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              alignment: Alignment.center,
              child: const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF819E4F),
                ),
              ),
            ),
          ],
        );
      }

      // If no state is selected, show message
      if (_selectedState == null) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: const Center(
                child: Text(
                  "Please select a state first",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        );
      }

      // If state selected but no cities found
      if (widget.controller.cities.isEmpty) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: const Center(
                child: Text(
                  "No cities available for this state",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        );
      }

      // Cities are loaded, show the selector
      final citiesToShow = _showAllCities
          ? widget.controller.cities
          : widget.controller.cities.take(_initialItemCount).toList();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildSelectorItem(
                label: "All Cities",
                isSelected: _selectedCity == null,
                onTap: () => setState(() => _selectedCity = null),
              ),
              ...citiesToShow.map(
                (city) => _buildSelectorItem(
                  label: city.cityName,
                  isSelected: _selectedCity?.id == city.id,
                  onTap: () => setState(() => _selectedCity = city),
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
    });
  }

  Widget _buildTypeChips() {
    final typesToShow = _showAllPropertyTypes
        ? widget.controller.propertyTypes
        : widget.controller.propertyTypes.take(_initialItemCount).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: typesToShow
              .map(
                (type) => _buildSelectorItem(
                  label: type.categoryName.replaceAll('GreenHeap ', ''),
                  isSelected: _selectedTypes.contains(type.categoryName),
                  onTap: () => setState(
                    () => _selectedTypes.contains(type.categoryName)
                        ? _selectedTypes.remove(type.categoryName)
                        : _selectedTypes.add(type.categoryName),
                  ),
                ),
              )
              .toList(),
        ),
        if (widget.controller.propertyTypes.length > _initialItemCount)
          _buildSeeMore(
            () =>
                setState(() => _showAllPropertyTypes = !_showAllPropertyTypes),
            _showAllPropertyTypes,
          ),
      ],
    );
  }

  Widget _buildSeeMore(VoidCallback onTap, bool isOpen) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          isOpen ? "- See Less" : "+ See More",
          style: const TextStyle(
            color: Color(0xFF819E4F),
            fontSize: 12,
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
        min: widget.controller.sqftMin.value,
        max: widget.controller.sqftMax.value,
        onChanged: (val) {
          setState(() {
            _areaRange = val;
            _areaChanged = true;
          });
        },
      ),
    );
  }

  Widget _buildSliderCard({required Widget child, required Color accentColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: SliderTheme(
        data: SliderTheme.of(context).copyWith(
          trackHeight: 6,
          activeTrackColor: accentColor,
          inactiveTrackColor: accentColor.withOpacity(0.1),
          thumbColor: Colors.white,
          rangeThumbShape: const RoundRangeSliderThumbShape(
            enabledThumbRadius: 12,
          ),
        ),
        child: child,
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Filters",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
              ),
              Text(
                "Customize your search",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              HapticFeedback.vibrate();
              widget.controller.clearFilters();
              setState(() => _initFilters());
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.refresh_rounded,
                color: Colors.red[400],
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        MediaQuery.of(context).padding.bottom + 16,
      ),
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
      child: _isApplyingFilters
          ? Container(
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFF819E4F),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            )
          : ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF819E4F),
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 8,
                shadowColor: const Color(0xFF819E4F).withOpacity(0.4),
              ),
              onPressed: _applyFilters,
              child: const Text(
                "Show Plots",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
    );
  }
}

class _CompactFilterSection extends StatelessWidget {
  final GiooPlotController controller;

  const _CompactFilterSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black12, width: 0.5),
          borderRadius: BorderRadius.circular(35),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  const Icon(Icons.search, size: 18, color: Colors.black),
                  const SizedBox(width: 6),
                  Expanded(
                    child: TextField(
                      controller: controller.searchController,
                      onChanged: controller.onSearchChanged,
                      onSubmitted: (_) => controller.applySearch(),
                      style: const TextStyle(fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: "Search your plots...",
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  Obx(() {
                    if (controller.searchQuery.value.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return GestureDetector(
                      onTap: () {
                        controller.searchController.clear();
                        controller.searchQuery.value = '';
                      },
                      child: const Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.grey,
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: controller.applySearch,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
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
            const SizedBox(width: 6),
            Obx(() {
              final filterCount = controller.getActiveFilterCount();
              return GestureDetector(
                onTap: () => _showFilterSheet(context, controller),
                child: Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF819E4F),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.tune,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    if (filterCount > 0)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            filterCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
