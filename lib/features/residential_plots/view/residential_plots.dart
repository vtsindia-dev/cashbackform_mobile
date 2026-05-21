import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../common/widget/appbar.dart';
import '../../../common/widget/loader.dart';
import '../../../common/widget/note_info.dart';
import '../../menu/controller/dashboard_menu_controller.dart';
import '../controller/residential_controller.dart';
import '../model/residential_model.dart';
import '../widget/residential_plotlist.dart';

// =============================================================================
// MAIN SCREEN
// =============================================================================

class ResidentialPropertiesScreen extends StatefulWidget {
  const ResidentialPropertiesScreen({super.key});

  @override
  State<ResidentialPropertiesScreen> createState() =>
      _ResidentialPropertiesScreenState();
}

class _ResidentialPropertiesScreenState
    extends State<ResidentialPropertiesScreen> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ResidentialPropertyController>(
      init: ResidentialPropertyController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: const Color(0xFFF4F7F2),
          appBar: const DynamicAppBar(
            title: "Flat/Villas",
            showBackButton: true,
          ),
          body: Obx(
                () => controller.isLoading.value
                ? const Center(
                child: GifLoader(
                    message: "Finding best plots...", size: 100))
                : Column(
              children: [
                _CompactFilterSection(controller: controller),
                _buildNoteContent(),
                Expanded(child: ResidentialPropertyList()),
                _BottomActionBar(controller: controller),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNoteContent() {
    final dashboardController = Get.find<DashboardController>();
    return Obx(() {
      if (dashboardController.isLoadingSettings.value) {
        return const SizedBox.shrink();
      }
      final settings = dashboardController.businessSettings.value;
      if (settings == null) return const SizedBox.shrink();
      return Column(
        children: [
          if (settings.plotDescription != null &&
              settings.plotDescription!.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 0.h),
              child: CompactNoteCard(
                title: "Gioo Flat/Villas Information",
                description: settings.plotDescription!,
                icon: Icons.lan,
              ),
            ),
        ],
      );
    });
  }
}

// =============================================================================
// LOCATION INDICATOR BADGE
// Use on any property list card: LocationIndicatorBadge(property: property)
// =============================================================================

class LocationIndicatorBadge extends StatelessWidget {
  final Property property;
  const LocationIndicatorBadge({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    final bool isDubai = property.isDubai; // was: property.isIndia (wrong!)
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: isDubai
            ? const Color(0xFFFFF3E0)
            : const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isDubai
              ? const Color(0xFFFF9800).withOpacity(0.5)
              : const Color(0xFF4CAF50).withOpacity(0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isDubai ? '🇦🇪' : '🇮🇳',
            style: TextStyle(fontSize: 10.sp),
          ),
          SizedBox(width: 3.w),
          Text(
            isDubai ? 'Dubai' : 'India',
            style: TextStyle(
              fontSize: 9.sp,
              fontWeight: FontWeight.w700,
              color: isDubai
                  ? const Color(0xFFE65100)
                  : const Color(0xFF2E7D32),
            ),
          ),
        ],
      ),
    );
  }
}
// =============================================================================
// COMPACT FILTER BAR — with live autocomplete overlay
// =============================================================================

class _CompactFilterSection extends StatefulWidget {
  final ResidentialPropertyController controller;
  const _CompactFilterSection({required this.controller});

  @override
  State<_CompactFilterSection> createState() =>
      _CompactFilterSectionState();
}

class _CompactFilterSectionState extends State<_CompactFilterSection> {
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) _removeOverlay();
    });
  }

  @override
  void dispose() {
    _removeOverlay();
    _focusNode.dispose();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  // Called on every keystroke — filters in memory, shows overlay
  void _onSearchChanged(String query) {
    widget.controller.searchQuery.value = query;
    _removeOverlay();

    widget.controller.filterSuggestionsLocally(query);

    if (query.trim().isEmpty) return;

    final suggestions = widget.controller.searchSuggestions;
    if (suggestions.isEmpty) return;

    _overlayEntry = _buildOverlay(List<String>.from(suggestions));
    Overlay.of(context).insert(_overlayEntry!);
  }

  OverlayEntry _buildOverlay(List<String> suggestions) {
    return OverlayEntry(
      builder: (_) => Positioned(
        width: MediaQuery.of(context).size.width - 16,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 50),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 220.h),
              child: ListView.separated(
                padding: EdgeInsets.symmetric(vertical: 6.h),
                shrinkWrap: true,
                itemCount: suggestions.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  color: Colors.grey.shade100,
                  indent: 16,
                  endIndent: 16,
                ),
                itemBuilder: (_, i) {
                  final suggestion = suggestions[i];
                  return InkWell(
                    onTap: () {
                      widget.controller.searchController.text =
                          suggestion;
                      widget.controller.searchQuery.value =
                          suggestion;
                      widget.controller
                          .filterSuggestionsLocally(suggestion);
                      _removeOverlay();
                      _focusNode.unfocus();
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 10.h),
                      child: Row(
                        children: [
                          Icon(Icons.search,
                              size: 14.sp,
                              color: Colors.grey.shade400),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Text(
                              suggestion,
                              style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CompositedTransformTarget(
        link: _layerLink,
        child: Container(
          padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black12, width: 0.5),
            borderRadius: BorderRadius.circular(35),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2))
            ],
          ),
          child: Row(
            children: [
              // Active query chip
              Obx(() {
                if (controller.searchQuery.value.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Row(
                  children: [
                    Container(
                      constraints: BoxConstraints(
                          maxWidth:
                          MediaQuery.of(context).size.width *
                              0.22),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(25)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: Text(
                              controller.searchQuery.value,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 11),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () {
                              controller.clearSearch();
                              _removeOverlay();
                            },
                            child: const Icon(Icons.close,
                                size: 14, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                        width: 1.5, height: 24, color: Colors.grey),
                    const SizedBox(width: 6),
                  ],
                );
              }),

              // Search field
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.search,
                        size: 18, color: Colors.black),
                    const SizedBox(width: 6),
                    Expanded(
                      child: TextField(
                        controller: controller.searchController,
                        focusNode: _focusNode,
                        onChanged: _onSearchChanged,
                        style: const TextStyle(fontSize: 14),
                        decoration: const InputDecoration(
                          hintText: "Search Property...",
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
                          controller.clearSearch();
                          _removeOverlay();
                        },
                        child: const Icon(Icons.close,
                            size: 16, color: Colors.grey),
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Search button — triggers full API call
              Obx(() {
                final hasQuery =
                    controller.searchQuery.value.isNotEmpty;
                return InkWell(
                  onTap: hasQuery
                      ? () {
                    _removeOverlay();
                    _focusNode.unfocus();
                    controller.applyFilters();
                  }
                      : null,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: hasQuery
                          ? const LinearGradient(
                        colors: [
                          Color(0xFF819E4F),
                          Color(0xFF9CB45A)
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                          : LinearGradient(
                        colors: [
                          Colors.grey.shade300,
                          Colors.grey.shade400,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "Search",
                      style: TextStyle(
                        color: hasQuery
                            ? Colors.black
                            : Colors.grey.shade600,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              }),

              const SizedBox(width: 6),

              // Filter icon
              GestureDetector(
                onTap: () =>
                    _showFilterSheet(context, controller),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF819E4F),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.tune,
                      color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// FILTER BOTTOM SHEET — with country selector added
// =============================================================================

void _showFilterSheet(BuildContext context,
    ResidentialPropertyController controller) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) =>
        _ModernFilterSheet(controller: controller),
  );
}

class _ModernFilterSheet extends StatefulWidget {
  final ResidentialPropertyController controller;
  const _ModernFilterSheet({required this.controller});

  @override
  State<_ModernFilterSheet> createState() =>
      _ModernFilterSheetState();
}

class _ModernFilterSheetState extends State<_ModernFilterSheet> {
  late RangeValues _priceRange;
  late RangeValues _areaRange;
  late List<int> _selectedCategories;
  late int _selectedStateId;
  late int _selectedCityId;
  late int _selectedCountryId; // ← NEW
  List<CityModel> _filteredCities = [];
  late String _selectedTransactionType;
  late String _selectedPostedBy;
  bool _priceChanged = false;
  bool _areaChanged = false;
  bool _showAllStates = false;
  bool _showAllCities = false;
  bool _showAllCategories = false;
  final int _initialItemCount = 4;
  bool _loadingCities = false;
  bool _isApplying = false;

  static const List<_CountryOption> _countryOptions = [
    _CountryOption(id: 3, label: 'India', flag: '🇮🇳'),  
    _CountryOption(id: 2, label: 'Dubai', flag: '🇦🇪'),
  ];

  @override
  void initState() {
    super.initState();
    _initFilters();
    _filteredCities = widget.controller.citiesList;
  }

  void _initFilters() {
    final c = widget.controller;

    _priceChanged = c.selectedMinPrice.value.isNotEmpty;
    double startP = _priceChanged
        ? (double.tryParse(c.selectedMinPrice.value) ?? c.priceMin.value)
        : c.priceMin.value;
    double endP = c.selectedMaxPrice.value.isNotEmpty
        ? (double.tryParse(c.selectedMaxPrice.value) ?? c.priceMax.value)
        : c.priceMax.value;
    _priceRange = RangeValues(
      startP.clamp(c.priceMin.value, c.priceMax.value),
      endP.clamp(c.priceMin.value, c.priceMax.value),
    );

    _areaChanged = c.selectedMinArea.value.isNotEmpty;
    double startA = _areaChanged
        ? (double.tryParse(c.selectedMinArea.value) ?? c.sqftMin.value.toDouble())
        : c.sqftMin.value.toDouble();
    double endA = c.selectedMaxArea.value.isNotEmpty
        ? (double.tryParse(c.selectedMaxArea.value) ?? c.sqftMax.value.toDouble())
        : c.sqftMax.value.toDouble();
    _areaRange = RangeValues(
      startA.clamp(
          c.sqftMin.value.toDouble(), c.sqftMax.value.toDouble()),
      endA.clamp(
          c.sqftMin.value.toDouble(), c.sqftMax.value.toDouble()),
    );

    _selectedCategories = c.selectedCategoryId.value > 0
        ? [c.selectedCategoryId.value]
        : [];
    _selectedStateId = c.selectedStateId.value;
    _selectedCityId = c.selectedCityId.value;
    _selectedCountryId = c.selectedCountryId.value; // ← NEW
    _selectedTransactionType = c.selectedTransactionType.value;
    _selectedPostedBy = c.selectedPostedBy.value;

    if (_selectedStateId > 0) {
      _filteredCities = widget.controller.citiesList
          .where((city) => city.stateId == _selectedStateId)
          .toList();
    }
  }

  Future<void> _updateFilteredCities() async {
    if (_selectedStateId > 0) {
      setState(() {
        _loadingCities = true;
        _filteredCities = [];
      });
      await widget.controller.fetchCitiesByState(_selectedStateId);
      setState(() {
        _filteredCities = widget.controller.citiesList
            .where((city) => city.stateId == _selectedStateId)
            .toList();
        _loadingCities = false;
        _selectedCityId = 0;
      });
    } else {
      setState(() {
        _filteredCities = widget.controller.citiesList;
        _selectedCityId = 0;
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
          borderRadius:
          BorderRadius.vertical(top: Radius.circular(40)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
                width: 45,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10))),
            _buildHeader(),
            Expanded(
              child: ListView(
                controller: scrollController,
                physics: const BouncingScrollPhysics(),
                padding:
                const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  // ── COUNTRY ────────────────────────────────
                  _buildAnimatedSection(
                    0,
                    "COUNTRY",
                    icon: Icons.public_rounded,
                    color: Colors.blueGrey,
                    child: _buildCountrySelector(),
                  ),
                  const SizedBox(height: 32),

                  // ── LOCATION ───────────────────────────────
                  _buildAnimatedSection(
                    1,
                    "LOCATION",
                    icon: Icons.location_on_rounded,
                    color: Colors.orange,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabelTag("STATE"),
                        const SizedBox(height: 10),
                        _buildStateSelector(),
                        if (_selectedStateId > 0) ...[
                          const SizedBox(height: 20),
                          _buildLabelTag("CITY"),
                          const SizedBox(height: 10),
                          _buildCitySelector(),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── PROPERTY TYPE ──────────────────────────
                  _buildAnimatedSection(
                    2,
                    "PROPERTY TYPE",
                    icon: Icons.grid_view_rounded,
                    color: Colors.blueAccent,
                    child: _buildCategoryChips(),
                  ),
                  const SizedBox(height: 32),

                  // ── PRICE ──────────────────────────────────
                  _buildAnimatedSection(
                    3,
                    "PRICE BUDGET",
                    icon: Icons.payments_rounded,
                    color: Colors.green,
                    trailing: _priceChanged
                        ? "₹${_priceRange.start.toInt()} - ₹${_priceRange.end.toInt()}"
                        : "Any Price",
                    child: _buildPriceSlider(),
                  ),
                  const SizedBox(height: 32),

                  // ── AREA ───────────────────────────────────
                  _buildAnimatedSection(
                    4,
                    "AREA RANGE",
                    icon: Icons.square_foot_rounded,
                    color: Colors.redAccent,
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

  // ── Country selector ────────────────────────────────────────────────────────

  Widget _buildCountrySelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildSelectorItem(
          label: "All Countries",
          isSelected: _selectedCountryId == 0,
          onTap: () => setState(() => _selectedCountryId = 0),
        ),
        ..._countryOptions.map(
              (opt) => _buildSelectorItem(
            label: '${opt.flag}  ${opt.label}',
            isSelected: _selectedCountryId == opt.id,
            onTap: () =>
                setState(() => _selectedCountryId = opt.id),
          ),
        ),
      ],
    );
  }

  // ── State selector ──────────────────────────────────────────────────────────

  Widget _buildStateSelector() {
    final statesToShow = _showAllStates
        ? widget.controller.statesList
        : widget.controller.statesList
        .take(_initialItemCount)
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildSelectorItem(
              label: "All States",
              isSelected: _selectedStateId == 0,
              onTap: () async {
                setState(() {
                  _selectedStateId = 0;
                  _selectedCityId = 0;
                });
                await _updateFilteredCities();
              },
            ),
            ...statesToShow.map(
                  (state) => _buildSelectorItem(
                label: state.stateName,
                isSelected: _selectedStateId == state.id,
                onTap: () async {
                  setState(() => _selectedStateId = state.id);
                  await _updateFilteredCities();
                },
              ),
            ),
          ],
        ),
        if (widget.controller.statesList.length > _initialItemCount)
          _buildSeeMore(
                () => setState(
                    () => _showAllStates = !_showAllStates),
            _showAllStates,
          ),
      ],
    );
  }

  // ── City selector ───────────────────────────────────────────────────────────

  Widget _buildCitySelector() {
    if (_loadingCities) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: const Center(
          child: Text('Loading Cities...',
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.bold)),
        ),
      );
    }
    final citiesToShow = _showAllCities
        ? _filteredCities
        : _filteredCities.take(_initialItemCount).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildSelectorItem(
              label: "All Cities",
              isSelected: _selectedCityId == 0,
              onTap: () => setState(() => _selectedCityId = 0),
            ),
            ...citiesToShow.map(
                  (city) => _buildSelectorItem(
                label: city.name,
                isSelected: _selectedCityId == city.id,
                onTap: () =>
                    setState(() => _selectedCityId = city.id),
              ),
            ),
          ],
        ),
        if (_filteredCities.length > _initialItemCount)
          _buildSeeMore(
                () => setState(
                    () => _showAllCities = !_showAllCities),
            _showAllCities,
          ),
      ],
    );
  }

  // ── Category chips ──────────────────────────────────────────────────────────

  Widget _buildCategoryChips() {
    final categoriesToShow = _showAllCategories
        ? widget.controller.propertyCategories
        : widget.controller.propertyCategories
        .take(_initialItemCount)
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildSelectorItem(
              label: "All Types",
              isSelected: _selectedCategories.isEmpty,
              onTap: () =>
                  setState(() => _selectedCategories.clear()),
            ),
            ...categoriesToShow.map(
                  (category) => _buildSelectorItem(
                label: category.categoryName,
                isSelected:
                _selectedCategories.contains(category.id),
                onTap: () => setState(() {
                  if (_selectedCategories
                      .contains(category.id)) {
                    _selectedCategories.remove(category.id);
                  } else {
                    _selectedCategories.add(category.id);
                  }
                }),
              ),
            ),
          ],
        ),
        if (widget.controller.propertyCategories.length >
            _initialItemCount)
          _buildSeeMore(
                () => setState(() =>
            _showAllCategories = !_showAllCategories),
            _showAllCategories,
          ),
      ],
    );
  }

  // ── Shared helpers ──────────────────────────────────────────────────────────

  Widget _buildLabelTag(String text) {
    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                          color: color),
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
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF819E4F)
              : Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: isSelected
                  ? const Color(0xFF819E4F)
                  : Colors.grey[200]!),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color:
              const Color(0xFF819E4F).withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected
                ? FontWeight.bold
                : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
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
              fontWeight: FontWeight.w900),
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
        divisions: 100,
        labels: RangeLabels(
          '₹${_priceRange.start.toInt()}',
          '₹${_priceRange.end.toInt()}',
        ),
        onChanged: (val) =>
            setState(() {
              _priceRange = val;
              _priceChanged = true;
            }),
      ),
    );
  }

  Widget _buildAreaSlider() {
    return _buildSliderCard(
      accentColor: Colors.purple,
      child: RangeSlider(
        values: _areaRange,
        min: widget.controller.sqftMin.value.toDouble(),
        max: widget.controller.sqftMax.value.toDouble(),
        divisions: 100,
        labels: RangeLabels(
          '${_areaRange.start.toInt()} sqft',
          '${_areaRange.end.toInt()} sqft',
        ),
        onChanged: (val) =>
            setState(() {
              _areaRange = val;
              _areaChanged = true;
            }),
      ),
    );
  }

  Widget _buildSliderCard(
      {required Widget child, required Color accentColor}) {
    return Container(
      padding:
      const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
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
              enabledThumbRadius: 12, elevation: 5),
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
              Text("Filters",
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1)),
              Text("Customize your search",
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500)),
            ],
          ),
          GestureDetector(
            onTap: () {
              HapticFeedback.vibrate();
              widget.controller.clearAllFilters();
              setState(() => _initFilters());
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: Colors.red[50], shape: BoxShape.circle),
              child: Icon(Icons.refresh_rounded,
                  color: Colors.red[400], size: 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: EdgeInsets.fromLTRB(24, 16, 24,
          MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5))
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _isApplying
              ? const Color(0xFF819E4F).withOpacity(0.7)
              : const Color(0xFF819E4F),
          minimumSize: const Size(double.infinity, 60),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          elevation: 8,
          shadowColor:
          const Color(0xFF819E4F).withOpacity(0.4),
        ),
        onPressed: _isApplying ? null : _applyFilters,
        child: _isApplying
            ? const SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(
                Colors.white),
          ),
        )
            : const Text(
          "Apply Filters",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Future<void> _applyFilters() async {
    if (_isApplying) return;
    setState(() => _isApplying = true);
    try {
      final c = widget.controller;
      c.selectedStateId.value = _selectedStateId;
      c.selectedCityId.value = _selectedCityId;
      c.selectedCountryId.value = _selectedCountryId; // ← NEW
      c.selectedCategoryId.value = _selectedCategories.isNotEmpty
          ? _selectedCategories.first
          : 0;
      c.selectedMinPrice.value = _priceChanged
          ? _priceRange.start.toInt().toString()
          : "";
      c.selectedMaxPrice.value = _priceChanged
          ? _priceRange.end.toInt().toString()
          : "";
      c.selectedMinArea.value = _areaChanged
          ? _areaRange.start.toInt().toString()
          : "";
      c.selectedMaxArea.value = _areaChanged
          ? _areaRange.end.toInt().toString()
          : "";
      c.selectedTransactionType.value = _selectedTransactionType;
      c.selectedPostedBy.value = _selectedPostedBy;
      c.currentPage.value = 1;
      await c.fetchProperties();
      if (mounted) {
        await Future.delayed(const Duration(milliseconds: 300));
        if (Navigator.canPop(context)) Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to apply filters: $e'),
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      if (mounted) setState(() => _isApplying = false);
    }
  }
}

// Helper data class for country options
class _CountryOption {
  final int id;
  final String label;
  final String flag;
  const _CountryOption(
      {required this.id,
        required this.label,
        required this.flag});
}

// =============================================================================
// BOTTOM ACTION BAR — unchanged
// =============================================================================

class _BottomActionBar extends StatelessWidget {
  final ResidentialPropertyController controller;
  const _BottomActionBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
            top: BorderSide(
                color: Colors.black12, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "${controller.properties.length} Plots found",
            style: const TextStyle(
                fontWeight: FontWeight.w900, fontSize: 15),
          ),
          if (controller.hasFiltersApplied)
            GestureDetector(
              onTap: () => controller.clearAllFilters(),
              child: Text(
                "RESET FILTERS",
                style: TextStyle(
                  color: Colors.red[400],
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  letterSpacing: 1,
                ),
              ),
            ),
        ],
      ),
    ));
  }
}