import 'package:cashback_farms/features/rental_yeild/model/rental_yeild_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../common/widget/appbar.dart';
import '../../../common/widget/loader.dart';
import '../../../common/widget/note_info.dart';
import '../../menu/controller/dashboard_menu_controller.dart';
import '../controller/rental_yield_controller.dart';
import '../widget/rental_yield_list.dart';

class RentalYieldScreen extends StatefulWidget {
  const RentalYieldScreen({super.key});

  @override
  State<RentalYieldScreen> createState() => _RentalYieldScreenState();
}
class _RentalYieldScreenState extends State<RentalYieldScreen> {
  final RentalYieldController controller = Get.put(RentalYieldController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F2),
      appBar: const DynamicAppBar(
        title: "Gio Rental Yield",
        showBackButton: true,
      ),
      body: Obx(() => controller.isLoading.value
          ? const Center(child: GifLoader(message: "Finding Gio best rental yields...", size: 100))
          : Column(
        children: [
          _CompactFilterSection(controller: controller),
          _buildNoteContent(),
          Expanded(child: RentalYieldList()),
          _BottomActionBar(controller: controller),
        ],
      )),
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
          if (settings.gioorentalDescription != null &&
              settings.gioorentalDescription!.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 0.h),
              child: CompactNoteCard(
                title: "Gioo Rental Information",
                description: settings.gioorentalDescription!,
                icon: Icons.lan,
              ),
            ),
        ],
      );
    });
  }

}

void _showFilterSheet(BuildContext context, RentalYieldController controller) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _ModernFilterSheet(controller: controller),
  );
}

class _ModernFilterSheet extends StatefulWidget {
  final RentalYieldController controller;
  const _ModernFilterSheet({required this.controller});

  @override
  State<_ModernFilterSheet> createState() => _ModernFilterSheetState();
}

class _ModernFilterSheetState extends State<_ModernFilterSheet> {
  late RangeValues _rentRange;
  late RangeValues _yieldRange;
  late List<int> _selectedPropertyTypes;
  late int _selectedStateId;
  late int _selectedCityId;
  List<CityModel> _filteredCities = [];
  late String _selectedFurnishingStatus;
  late String _selectedPropertyAge;
  late int _selectedBedrooms;
  late bool _includeCommercial;
  bool _rentChanged = false;
  bool _yieldChanged = false;
  bool _showAllStates = false;
  bool _showAllCities = false;
  bool _showAllPropertyTypes = false;
  final int _initialItemCount = 4;
  bool _loadingCities = false;
  bool _isApplying = false;

  @override
  void initState() {
    super.initState();
    _initFilters();
    _filteredCities = widget.controller.citiesList;
  }

  void _initFilters() {
    final c = widget.controller;

    // Rent Range (Monthly Rent)
    _rentChanged = c.selectedMinRent.value.isNotEmpty;
    double startR = _rentChanged ? (double.tryParse(c.selectedMinRent.value) ?? c.rentMin.value) : c.rentMin.value;
    double endR = c.selectedMaxRent.value.isNotEmpty ? (double.tryParse(c.selectedMaxRent.value) ?? c.rentMax.value) : c.rentMax.value;
    _rentRange = RangeValues(
      startR.clamp(c.rentMin.value, c.rentMax.value),
      endR.clamp(c.rentMin.value, c.rentMax.value),
    );

    // Yield Range (Annual Yield Percentage)
    // Since yieldMin and yieldMax might not exist in your controller, use defaults
    _yieldChanged = c.selectedMinYield.value.isNotEmpty;
    double startY = _yieldChanged ? (double.tryParse(c.selectedMinYield.value) ?? 0.0) : 0.0;
    double endY = c.selectedMaxYield.value.isNotEmpty ? (double.tryParse(c.selectedMaxYield.value) ?? 20.0) : 20.0;
    _yieldRange = RangeValues(
      startY.clamp(0.0, 20.0),
      endY.clamp(0.0, 20.0),
    );
    _selectedPropertyTypes = [];
    _selectedStateId = c.selectedStateId.value;
    _selectedCityId = c.selectedCityId.value;
    _selectedFurnishingStatus = ''; // Your API doesn't have this
    _selectedPropertyAge = ''; // Your API doesn't have this
    _selectedBedrooms = 0; // Your API doesn't have this
    _includeCommercial = false; // Your API doesn't have this
  }

  Future<void> _updateFilteredCities() async {
    if (_selectedStateId > 0) {
      setState(() {
        _loadingCities = true;
        _filteredCities = [];
      });

      await widget.controller.fetchCitiesByState(_selectedStateId);

      setState(() {
        _filteredCities = widget.controller.citiesList;
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
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.4,
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
                decoration:
                BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10))),
            _buildHeader(),
            Expanded(
              child: ListView(
                controller: scrollController,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
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
                          _buildStateSelector(),
                          if (_selectedStateId > 0) ...[
                            const SizedBox(height: 20),
                            _buildLabelTag("CITY"),
                            const SizedBox(height: 10),
                            _buildCitySelector(),
                          ],
                        ],
                      )),
                  const SizedBox(height: 32),
                  _buildAnimatedSection(
                      1,
                      "MONTHLY RENT",
                      icon: Icons.money_rounded,
                      color: Colors.blue,
                      trailing: _rentChanged
                          ? "₹${_rentRange.start.toInt()} - ₹${_rentRange.end.toInt()}"
                          : "Any Rent",
                      child: _buildRentSlider()),
                  const SizedBox(height: 32),
                  _buildAnimatedSection(
                      2,
                      "YIELD % (Annual)",
                      icon: Icons.trending_up_rounded,
                      color: Colors.amber,
                      trailing: _yieldChanged
                          ? "${_yieldRange.start.toStringAsFixed(1)}% - ${_yieldRange.end.toStringAsFixed(1)}%"
                          : "Any Yield",
                      child: _buildYieldSlider()),
                  const SizedBox(height: 32),
                  _buildAnimatedSection(
                      3,
                      "BEDROOMS",
                      icon: Icons.bed_rounded,
                      color: Colors.teal,
                      child: _buildBedroomSelector()),
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
            letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildAnimatedSection(int index, String title,
      {required IconData icon,
        required Color color,
        required Widget child,
        String? trailing}) {
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
                  Text(title,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          color: Colors.grey[600])),
                  const Spacer(),
                  if (trailing != null)
                    Text(trailing,
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.bold, color: color)),
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

  Widget _buildSelectorItem(
      {required String label, required bool isSelected, required VoidCallback onTap}) {
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
          border: Border.all(color: isSelected ? const Color(0xFF819E4F) : Colors.grey[200]!),
          boxShadow: isSelected
              ? [
            BoxShadow(
                color: const Color(0xFF819E4F).withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 13),
        ),
      ),
    );
  }


  Widget _buildStateSelector() {
    final statesToShow = _showAllStates
        ? widget.controller.statesList
        : widget.controller.statesList.take(_initialItemCount).toList();
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
                }),
            ...statesToShow.map((state) => _buildSelectorItem(
                label: state.stateName,
                isSelected: _selectedStateId == state.id,
                onTap: () async {
                  setState(() {
                    _selectedStateId = state.id;
                  });
                  await _updateFilteredCities();
                })),
          ],
        ),
        if (widget.controller.statesList.length > _initialItemCount)
          _buildSeeMore(() => setState(() => _showAllStates = !_showAllStates), _showAllStates),
      ],
    );
  }

  Widget _buildCitySelector() {
    if (_loadingCities) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: const Center(
          child: SizedBox(
            height: 20,
            child: Text(
              'Loading Cities...',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
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
                onTap: () => setState(() => _selectedCityId = 0)),
            ...citiesToShow.map((city) => _buildSelectorItem(
                label: city.cityName,
                isSelected: _selectedCityId == city.id,
                onTap: () => setState(() => _selectedCityId = city.id))),
          ],
        ),
        if (_filteredCities.length > _initialItemCount)
          _buildSeeMore(() => setState(() => _showAllCities = !_showAllCities), _showAllCities),
      ],
    );
  }

  Widget _buildBedroomSelector() {
    final options = [1, 2, 3, 4, 5];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildSelectorItem(
            label: "Any",
            isSelected: _selectedBedrooms == 0,
            onTap: () => setState(() => _selectedBedrooms = 0)),
        ...options.map((count) => _buildSelectorItem(
            label: "$count BHK",
            isSelected: _selectedBedrooms == count,
            onTap: () => setState(() => _selectedBedrooms = count))),
      ],
    );
  }

  Widget _buildSeeMore(VoidCallback onTap, bool isOpen) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(isOpen ? "- See Less" : "+ See More",
            style: const TextStyle(color: Color(0xFF819E4F), fontSize: 12, fontWeight: FontWeight.w900)),
      ),
    );
  }

  Widget _buildRentSlider() {
    return _buildSliderCard(
      accentColor: Colors.blue,
      child: RangeSlider(
        values: _rentRange,
        min: widget.controller.rentMin.value,
        max: widget.controller.rentMax.value,
        divisions: 100,
        labels: RangeLabels(
          '₹${_rentRange.start.toInt()}',
          '₹${_rentRange.end.toInt()}',
        ),
        onChanged: (val) {
          setState(() {
            _rentRange = val;
            _rentChanged = true;
          });
        },
      ),
    );
  }

  Widget _buildYieldSlider() {
    return _buildSliderCard(
      accentColor: Colors.amber,
      child: RangeSlider(
        values: _yieldRange,
        min: 0.0,
        max: 20.0,
        divisions: 100,
        labels: RangeLabels(
          '${_yieldRange.start.toStringAsFixed(1)}%',
          '${_yieldRange.end.toStringAsFixed(1)}%',
        ),
        onChanged: (val) {
          setState(() {
            _yieldRange = val;
            _yieldChanged = true;
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
          border: Border.all(color: Colors.grey[100]!)),
      child: SliderTheme(
        data: SliderTheme.of(context).copyWith(
          trackHeight: 6,
          activeTrackColor: accentColor,
          inactiveTrackColor: accentColor.withOpacity(0.1),
          thumbColor: Colors.white,
          rangeThumbShape: const RoundRangeSliderThumbShape(enabledThumbRadius: 12, elevation: 5),
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
              Text("Rental Yield Filters",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -1)),
              Text("Find high yield properties",
                  style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
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
              decoration: BoxDecoration(color: Colors.red[50], shape: BoxShape.circle),
              child: Icon(Icons.refresh_rounded, color: Colors.red[400], size: 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _isApplying
              ? const Color(0xFF819E4F).withOpacity(0.7)
              : const Color(0xFF819E4F),
          minimumSize: const Size(double.infinity, 60),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 8,
          shadowColor: const Color(0xFF819E4F).withOpacity(0.4),
        ),
        onPressed: _isApplying ? null : _applyFilters,
        child: _isApplying
            ? SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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

    setState(() {
      _isApplying = true;
    });

    try {
      // Apply filters to controller
      widget.controller.selectedStateId.value = _selectedStateId;
      widget.controller.selectedCityId.value = _selectedCityId;

      // Rent
      widget.controller.selectedMinRent.value =
      _rentChanged ? _rentRange.start.toInt().toString() : "";
      widget.controller.selectedMaxRent.value =
      _rentChanged ? _rentRange.end.toInt().toString() : "";

      // Yield
      widget.controller.selectedMinYield.value =
      _yieldChanged ? _yieldRange.start.toStringAsFixed(1) : "";
      widget.controller.selectedMaxYield.value =
      _yieldChanged ? _yieldRange.end.toStringAsFixed(1) : "";

      // Apply filters
      widget.controller.currentPage.value = 1;
      await widget.controller.fetchProperties();

      // Close the modal with a delay
      if (mounted) {
        await Future.delayed(const Duration(milliseconds: 300));
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      // Handle error if needed
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to apply filters: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isApplying = false;
        });
      }
    }
  }
}

class _CompactFilterSection extends StatelessWidget {
  final RentalYieldController controller;
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
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
        ),
        child: Row(
          children: [
            Obx(() {
              if (controller.searchQuery.value.isEmpty) return const SizedBox.shrink();
              return Row(
                children: [
                  Container(
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.22),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.25), borderRadius: BorderRadius.circular(25)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                            child: Text(controller.searchQuery.value,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, color: Colors.white, fontSize: 11),
                                overflow: TextOverflow.ellipsis)),
                        const SizedBox(width: 4),
                        GestureDetector(
                            onTap: controller.clearSearch,
                            child: const Icon(Icons.close, size: 14, color: Colors.white)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(width: 1.5, height: 24, color: Colors.grey),
                  const SizedBox(width: 6),
                ],
              );
            }),
            Expanded(
              child: Row(
                children: [
                  const Icon(Icons.search, size: 18, color: Colors.black),
                  const SizedBox(width: 6),
                  Expanded(
                    child: TextField(
                      controller: controller.searchController,
                      onChanged: (value) {
                        controller.searchQuery.value = value;
                        controller.onSearchChanged(value);
                      },
                      style: const TextStyle(fontSize: 14),
                      decoration: const InputDecoration(
                          hintText: "Search Property...",
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero),
                    ),
                  ),
                  Obx(() {
                    if (controller.searchQuery.value.isEmpty) return const SizedBox.shrink();
                    return GestureDetector(
                        onTap: () {
                          controller.searchController.clear();
                          controller.searchQuery.value = '';
                        },
                        child: const Icon(Icons.close, size: 16, color: Colors.grey));
                  }),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Obx(() {
              final hasQuery = controller.searchQuery.value.isNotEmpty;
              return InkWell(
                onTap: hasQuery ? controller.applyFilters : null,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                      gradient: hasQuery
                          ? const LinearGradient(
                          colors: [Color(0xFF819E4F), Color(0xFF9CB45A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight)
                          : LinearGradient(
                          colors: [Colors.grey.shade300, Colors.grey.shade400],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(20)),
                  child: Text("Search",
                      style: TextStyle(
                          color: hasQuery ? Colors.black : Colors.grey.shade600,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                ),
              );
            }),
            const SizedBox(width: 6),
            GestureDetector(
                onTap: () => _showFilterSheet(context, controller),
                child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration:
                    BoxDecoration(color: const Color(0xFF819E4F), borderRadius: BorderRadius.circular(20)),
                    child: const Icon(Icons.tune, color: Colors.white, size: 18))),
          ],
        ),
      ),
    );
  }
}

class _BottomActionBar extends StatelessWidget {
  final RentalYieldController controller;
  const _BottomActionBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
          color: Colors.white, border: Border(top: BorderSide(color: Colors.black12, width: 0.5))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("${controller.filteredProperties.length} Properties found",
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
          if (controller.hasFiltersApplied)
            GestureDetector(
              onTap: () => controller.clearAllFilters(),
              child: Text("RESET FILTERS",
                  style: TextStyle(
                      color: Colors.red[400],
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      letterSpacing: 1)),
            ),
        ],
      ),
    ));
  }
}