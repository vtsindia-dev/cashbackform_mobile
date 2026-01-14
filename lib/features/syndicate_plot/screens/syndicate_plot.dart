import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../common/widget/appbar.dart';
import '../../../common/widget/loader.dart';
import '../controller/syndicate_controller.dart';
import '../widget/syndicate_plot_list.dart';
import '../model/syndicate_model.dart';

class SyndicatePlot extends StatefulWidget {
  const SyndicatePlot({super.key});

  @override
  State<SyndicatePlot> createState() => _SyndicatePlotState();
}

class _SyndicatePlotState extends State<SyndicatePlot> {
  final SyndicatePlotController controller = Get.put(SyndicatePlotController());
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller.fetchSyndicatePlots();
    _searchController.text = controller.searchQuery.value;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F2),
      appBar: const DynamicAppBar(
        title: "Syndicate Plots",
        showBackButton: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: GifLoader(message: "Loading...", size: 100));
        }

        return Column(
          children: [
            _SearchAndFiltersSection(
              controller: controller,
              searchController: _searchController,
            ),
          Container(
              height : MediaQuery.of(context).size.height * 0.74,
              child: SyndicatePlotList()),
            Spacer(),
            _BottomActionBar(controller: controller),
          ],
        );
      }),
    );
  }}

// Search Bar with Filter Chips below
class _SearchAndFiltersSection extends StatelessWidget {
  final SyndicatePlotController controller;
  final TextEditingController searchController;

  const _SearchAndFiltersSection({
    required this.controller,
    required this.searchController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black12, width: 0.5),
              borderRadius: BorderRadius.circular(35),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
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
                          controller: searchController,
                          onChanged: (value) {
                            controller.onSearchChanged(value);
                          },
                          onSubmitted: (_) {
                            // Only submit if query has at least 5 characters
                            if (controller.searchQuery.value.trim().length >= 5) {
                              controller.applySearch();
                            }
                          },
                          style: const TextStyle(fontSize: 14),
                          decoration: const InputDecoration(
                            hintText: "Search syndicate plots... (min 5 chars)",
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      Obx(() {
                        if (controller.searchQuery.value.isEmpty)
                          return const SizedBox.shrink();
                        return GestureDetector(
                          onTap: () {
                            controller.searchQuery.value = '';
                            searchController.clear();
                            controller.fetchSyndicatePlots(); // Trigger API
                          },
                          child: const Icon(Icons.close, size: 16, color: Colors.grey),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Obx(() {
                  final hasEnoughChars = controller.searchQuery.value.trim().length >= 5;
                  return InkWell(
                    onTap: hasEnoughChars ? () => controller.applySearch() : null,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: hasEnoughChars
                            ? const LinearGradient(
                          colors: [Color(0xFF819E4F), Color(0xFF9CB45A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                            : LinearGradient(
                          colors: [Colors.grey.shade300, Colors.grey.shade400],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "Search",
                        style: TextStyle(
                          color: hasEnoughChars ? Colors.black : Colors.grey.shade600,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () => _showFilterSheet(context, controller),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF819E4F),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.tune, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Applied Filter Chips (Single Line Scrollable)
        // Obx(() {
        //   final appliedFilters = _getAppliedFilters(controller);
        //
        //   if (appliedFilters.isEmpty) return const SizedBox.shrink();
        //
        //   return Container(
        //     height: 30, // Compact height
        //     margin: const EdgeInsets.only(bottom: 8),
        //     child: ListView.builder(
        //       scrollDirection: Axis.horizontal,
        //       padding: const EdgeInsets.symmetric(horizontal: 12),
        //       itemCount: appliedFilters.length,
        //       itemBuilder: (context, index) {
        //         final filter = appliedFilters[index];
        //         return Padding(
        //           padding: const EdgeInsets.only(right: 6),
        //           child: Container(
        //             height: 26, // Fixed height for consistency
        //             padding: const EdgeInsets.only(left: 10, right: 6),
        //             decoration: BoxDecoration(
        //               color: const Color(0xFF819E4F).withOpacity(0.08),
        //               borderRadius: BorderRadius.circular(20), // More rounded
        //               border: Border.all(
        //                 color: const Color(0xFF819E4F).withOpacity(0.2),
        //                 width: 0.8,
        //               ),
        //             ),
        //             child: Row(
        //               mainAxisSize: MainAxisSize.min,
        //               children: [
        //                 ConstrainedBox(
        //                   constraints: BoxConstraints(
        //                     maxWidth: MediaQuery.of(context).size.width * 0.25,
        //                   ),
        //                   child: Text(
        //                     _getShortLabel(filter['label']),
        //                     style: const TextStyle(
        //                       fontSize: 10,
        //                       fontWeight: FontWeight.w500,
        //                       color: Color(0xFF819E4F),
        //                     ),
        //                     maxLines: 1,
        //                     overflow: TextOverflow.ellipsis,
        //                   ),
        //                 ),
        //                 const SizedBox(width: 4),
        //                 GestureDetector(
        //                   onTap: () async {
        //                     filter['onRemove']();
        //                     await controller.fetchSyndicatePlots(); // Trigger API
        //                   },
        //                   child: Container(
        //                     width: 16,
        //                     height: 16,
        //                     decoration: BoxDecoration(
        //                       color: const Color(0xFF819E4F).withOpacity(0.1),
        //                       borderRadius: BorderRadius.circular(8), // Circular
        //                     ),
        //                     child: const Icon(
        //                       Icons.close_rounded,
        //                       size: 10,
        //                       color: Color(0xFF819E4F),
        //                     ),
        //                   ),
        //                 ),
        //               ],
        //             ),
        //           ),
        //         );
        //       },
        //     ),
        //   );
        // }),
      ],
    );
  }

  // Helper method to shorten labels
  String _getShortLabel(String fullLabel) {
    // Extract just the value without the prefix for shorter display
    if (fullLabel.startsWith('Search: ')) {
      String query = fullLabel.substring(8);
      return query.length > 10 ? '${query.substring(0, 8)}...' : query;
    } else if (fullLabel.startsWith('Type: ')) {
      return fullLabel.substring(6);
    } else if (fullLabel.startsWith('State: ')) {
      return fullLabel.substring(7);
    } else if (fullLabel.startsWith('City: ')) {
      return fullLabel.substring(6);
    } else if (fullLabel.startsWith('Price: ')) {
      return '₹${fullLabel.substring(7)}';
    } else if (fullLabel.startsWith('Area: ')) {
      return fullLabel.substring(6);
    }
    return fullLabel;
  }

  List<Map<String, dynamic>> _getAppliedFilters(
      SyndicatePlotController controller) {
    final filters = <Map<String, dynamic>>[];

    if (controller.searchQuery.value.isNotEmpty) {
      filters.add({
        'label': "Search: ${controller.searchQuery.value}",
        'onRemove': () => controller.searchQuery.value = '',
      });
    }

    if (controller.selectedPropertyTypeId.value > 0) {
      filters.add({
        'label': "Type: ${controller.selectedPropertyTypeName.value}",
        'onRemove': () => controller.clearPropertyTypeFilter(),
      });
    }

    if (controller.selectedStateId.value > 0) {
      filters.add({
        'label': "State: ${controller.selectedStateName.value}",
        'onRemove': () async {
          controller.selectedStateId.value = 0;
          controller.selectedStateName.value = '';
          controller.selectedCityId.value = 0;
          controller.selectedCityName.value = '';
        },
      });
    }

    if (controller.selectedCityId.value > 0) {
      filters.add({
        'label': "City: ${controller.selectedCityName.value}",
        'onRemove': () {
          controller.selectedCityId.value = 0;
          controller.selectedCityName.value = '';
        },
      });
    }

    if (controller.minPrice.value.isNotEmpty &&
        controller.maxPrice.value.isNotEmpty) {
      filters.add({
        'label':
        "Price: ₹${controller.minPrice.value} - ₹${controller.maxPrice.value}",
        'onRemove': () {
          controller.minPrice.value = '';
          controller.maxPrice.value = '';
        },
      });
    }

    if (controller.minAreaSqft.value.isNotEmpty &&
        controller.maxAreaSqft.value.isNotEmpty) {
      filters.add({
        'label':
        "Area: ${controller.minAreaSqft.value} - ${controller.maxAreaSqft.value} sq.ft",
        'onRemove': () {
          controller.minAreaSqft.value = '';
          controller.maxAreaSqft.value = '';
        },
      });
    }

    return filters;
  }
}

// Filter Bottom Sheet with Show More/Less
void _showFilterSheet(BuildContext context, SyndicatePlotController controller) {
  showModalBottomSheet(

    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _ModernFilterSheet(controller: controller),
  );
}

class _ModernFilterSheet extends StatefulWidget {
  final SyndicatePlotController controller;
  const _ModernFilterSheet({required this.controller});

  @override
  State<_ModernFilterSheet> createState() => _ModernFilterSheetState();
}

class _ModernFilterSheetState extends State<_ModernFilterSheet> {
  late RangeValues _priceRange;
  late RangeValues _areaRange;

  late int _selectedStateId;
  late String _selectedStateName;
  late int _selectedCityId;
  late String _selectedCityName;

  late List<Map<String, dynamic>> _availableStates;
  late List<Map<String, dynamic>> _availableCities;

  late int _selectedPropertyTypeId;
  late String _selectedPropertyTypeName;
  late List<PropertyType> _propertyTypes;

  bool _priceChanged = false;
  bool _areaChanged = false;

  // Show More/Less states for all sections
  bool _showAllStates = false;
  bool _showAllCities = false;
  bool _showAllPropertyTypes = false;

  final int _initialItemCount = 5; // Show 5 items initially

  @override
  void initState() {
    super.initState();
    _initFilters();
    _availableStates = widget.controller.getAvailableStates();
    _propertyTypes = widget.controller.getAvailablePropertyTypes();

    if (_selectedStateId > 0) {
      _availableCities = widget.controller.getCitiesByStateId(_selectedStateId);
    } else {
      _availableCities = widget.controller.getAvailableCities();
    }
  }

  void _initFilters() {
    final c = widget.controller;

    // Price Init
    _priceChanged = c.minPrice.value.isNotEmpty && c.maxPrice.value.isNotEmpty;
    double startP = _priceChanged && c.minPrice.value.isNotEmpty
        ? double.parse(c.minPrice.value)
        : 0;
    double endP = _priceChanged && c.maxPrice.value.isNotEmpty
        ? double.parse(c.maxPrice.value)
        : 10000000;

    // Area Init
    _areaChanged = c.minAreaSqft.value.isNotEmpty && c.maxAreaSqft.value.isNotEmpty;
    double startA = _areaChanged && c.minAreaSqft.value.isNotEmpty
        ? double.parse(c.minAreaSqft.value)
        : 0;
    double endA = _areaChanged && c.maxAreaSqft.value.isNotEmpty
        ? double.parse(c.maxAreaSqft.value)
        : 10000;

    // Get max price and area from plots
    double maxPlotPrice = 0;
    double maxPlotArea = 0;
    for (var plot in widget.controller.syndicatePlots) {
      try {
        double price = double.tryParse(plot.price?.replaceAll(',', '') ?? '0') ?? 0;
        if (price > maxPlotPrice) maxPlotPrice = price;

        double area = double.tryParse(plot.area?.replaceAll(RegExp(r'[^0-9.]'), '') ?? '0') ?? 0;
        if (area > maxPlotArea) maxPlotArea = area;
      } catch (e) {
        print('Error parsing plot data: $e');
      }
    }

    _priceRange = RangeValues(
      startP.clamp(0, maxPlotPrice > 0 ? maxPlotPrice : 10000000),
      endP.clamp(0, maxPlotPrice > 0 ? maxPlotPrice : 10000000),
    );

    _areaRange = RangeValues(
      startA.clamp(0, maxPlotArea > 0 ? maxPlotArea : 10000),
      endA.clamp(0, maxPlotArea > 0 ? maxPlotArea : 10000),
    );

    // Initialize with IDs
    _selectedStateId = c.selectedStateId.value;
    _selectedStateName = c.selectedStateName.value;
    _selectedCityId = c.selectedCityId.value;
    _selectedCityName = c.selectedCityName.value;

    // Property type init
    _selectedPropertyTypeId = c.selectedPropertyTypeId.value;
    _selectedPropertyTypeName = c.selectedPropertyTypeName.value;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.85,
      minChildSize: 0.7,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 45, height: 4, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10))),
            _buildHeader(),
            Expanded(
              child: ListView(
                controller: scrollController,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  // Location Section with Show More/Less
                  _buildFilterSection(
                    title: "SYNDICATE LOCATION",
                    icon: Icons.location_on_rounded,
                    color: Colors.orange,
                    child: _buildLocationSection(),
                  ),

                  const SizedBox(height: 32),

                  // Property Type Section with Show More/Less
                  _buildFilterSection(
                    title: "PROPERTY TYPE",
                    icon: Icons.category_rounded,
                    color: Colors.purple,
                    child: _buildPropertyTypeSection(),
                  ),

                  const SizedBox(height: 32),

                  // Price Section
                  _buildFilterSection(
                    title: "PRICE BUDGET",
                    icon: Icons.payments_rounded,
                    color: Colors.green,
                    child: _buildPriceSection(),
                  ),

                  const SizedBox(height: 32),

                  // Area Section
                  _buildFilterSection(
                    title: "PLOT AREA (SQ.FT)",
                    icon: Icons.aspect_ratio_rounded,
                    color: Colors.blue,
                    child: _buildAreaSection(),
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

  // Reusable filter section widget with Show More/Less
  Widget _buildFilterSection({
    required String title,
    required IconData icon,
    required Color color,
    required Widget child,
  }) {
    return Column(
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
          ],
        ),
        const SizedBox(height: 16),
        child,
      ],
    );
  }

  // Location Section with State and City (both with Show More/Less)
  Widget _buildLocationSection() {
    return Column(
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
    );
  }

  // Property Type Section with Show More/Less
  Widget _buildPropertyTypeSection() {
    final propertyTypesToShow = _showAllPropertyTypes
        ? _propertyTypes
        : _propertyTypes.take(_initialItemCount).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildSelectorItem(
              label: "All Types",
              isSelected: _selectedPropertyTypeId == 0,
              onTap: () {
                setState(() {
                  _selectedPropertyTypeId = 0;
                  _selectedPropertyTypeName = '';
                });
              },
            ),
            for (var type in propertyTypesToShow)
              _buildSelectorItem(
                label: type.categoryName,
                isSelected: _selectedPropertyTypeId == type.id,
                onTap: () {
                  setState(() {
                    _selectedPropertyTypeId = type.id;
                    _selectedPropertyTypeName = type.categoryName;
                  });
                },
              ),
          ],
        ),

        // Show More/Less button for Property Types
        if (_propertyTypes.length > _initialItemCount)
          _buildShowMoreButton(
            isExpanded: _showAllPropertyTypes,
            totalCount: _propertyTypes.length,
            onTap: () => setState(() => _showAllPropertyTypes = !_showAllPropertyTypes),
            sectionName: "Property Types",
          ),
      ],
    );
  }

  // State Selector with Show More/Less
  Widget _buildStateSelector() {
    final statesToShow = _showAllStates
        ? _availableStates
        : _availableStates.take(_initialItemCount).toList();

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
              onTap: () {
                setState(() {
                  _selectedStateId = 0;
                  _selectedStateName = '';
                  _selectedCityId = 0;
                  _selectedCityName = '';
                  _availableCities = widget.controller.getAvailableCities();
                  _showAllCities = false;
                });
              },
            ),
            for (var state in statesToShow)
              _buildSelectorItem(
                label: state['name'] as String? ?? '',
                isSelected: _selectedStateId == state['id'],
                onTap: () {
                  setState(() {
                    _selectedStateId = state['id'] as int;
                    _selectedStateName = state['name'] as String? ?? '';
                    _selectedCityId = 0;
                    _selectedCityName = '';
                    _availableCities = widget.controller.getCitiesByStateId(state['id'] as int);
                    _showAllCities = false;
                  });
                },
              ),
          ],
        ),

        // Show More/Less button for States
        if (_availableStates.length > _initialItemCount)
          _buildShowMoreButton(
            isExpanded: _showAllStates,
            totalCount: _availableStates.length,
            onTap: () => setState(() => _showAllStates = !_showAllStates),
            sectionName: "States",
          ),
      ],
    );
  }

  // City Selector with Show More/Less
  Widget _buildCitySelector() {
    final citiesToShow = _showAllCities
        ? _availableCities
        : _availableCities.take(_initialItemCount).toList();

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
              onTap: () {
                setState(() {
                  _selectedCityId = 0;
                  _selectedCityName = '';
                });
              },
            ),
            for (var city in citiesToShow)
              _buildSelectorItem(
                label: city['name'] as String? ?? '',
                isSelected: _selectedCityId == city['id'],
                onTap: () {
                  setState(() {
                    _selectedCityId = city['id'] as int;
                    _selectedCityName = city['name'] as String? ?? '';
                  });
                },
              ),
          ],
        ),

        // Show More/Less button for Cities
        if (_availableCities.length > _initialItemCount)
          _buildShowMoreButton(
            isExpanded: _showAllCities,
            totalCount: _availableCities.length,
            onTap: () => setState(() => _showAllCities = !_showAllCities),
            sectionName: "Cities",
          ),
      ],
    );
  }

  // Price Section
  Widget _buildPriceSection() {
    double maxPlotPrice = 0.0;
    for (var plot in widget.controller.syndicatePlots) {
      try {
        double price = double.tryParse(plot.price?.replaceAll(',', '') ?? '0') ?? 0.0;
        if (price > maxPlotPrice) maxPlotPrice = price;
      } catch (e) {
        print('Error parsing price: $e');
      }
    }

    final maxValue = maxPlotPrice > 0 ? maxPlotPrice : 10000000.0;

    return _buildSliderCard(
      accentColor: Colors.green,
      child: Column(
        children: [
          RangeSlider(
            values: _priceRange,
            min: 0.0,
            max: maxValue,
            divisions: 20,
            labels: RangeLabels(
              "₹${_formatNumber(_priceRange.start.toInt())}",
              "₹${_formatNumber(_priceRange.end.toInt())}",
            ),
            onChanged: (RangeValues val) {
              setState(() {
                _priceRange = val;
                _priceChanged = true;
              });
            },
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Min: ₹${_formatNumber(_priceRange.start.toInt())}",
                style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500),
              ),
              Text(
                "Max: ₹${_formatNumber(_priceRange.end.toInt())}",
                style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Area Section
  Widget _buildAreaSection() {
    double maxPlotArea = 0.0;
    for (var plot in widget.controller.syndicatePlots) {
      try {
        double area = double.tryParse(plot.area?.replaceAll(RegExp(r'[^0-9.]'), '') ?? '0') ?? 0.0;
        if (area > maxPlotArea) maxPlotArea = area;
      } catch (e) {
        print('Error parsing area: $e');
      }
    }

    final maxValue = maxPlotArea > 0 ? maxPlotArea : 10000.0;

    return _buildSliderCard(
      accentColor: Colors.blue,
      child: Column(
        children: [
          RangeSlider(
            values: _areaRange,
            min: 0.0,
            max: maxValue,
            divisions: 20,
            labels: RangeLabels(
              "${_areaRange.start.toInt()} sq.ft",
              "${_areaRange.end.toInt()} sq.ft",
            ),
            onChanged: (RangeValues val) {
              setState(() {
                _areaRange = val;
                _areaChanged = true;
              });
            },
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Min: ${_areaRange.start.toInt()} sq.ft",
                style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500),
              ),
              Text(
                "Max: ${_areaRange.end.toInt()} sq.ft",
                style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Reusable Show More/Less Button
  Widget _buildShowMoreButton({
    required bool isExpanded,
    required int totalCount,
    required VoidCallback onTap,
    required String sectionName,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isExpanded ? Icons.expand_less : Icons.expand_more,
                size: 16,
                color: const Color(0xFF819E4F),
              ),
              const SizedBox(width: 6),
              Text(
                isExpanded ? "Show Less" : "Show More ($totalCount)",
                style: const TextStyle(
                  color: Color(0xFF819E4F),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 10000000) {
      return '${(number / 10000000).toStringAsFixed(1)} Cr';
    } else if (number >= 100000) {
      return '${(number / 100000).toStringAsFixed(1)} L';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)} K';
    }
    return number.toString();
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
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF819E4F), letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildSelectorItem({required String label, required bool isSelected, required VoidCallback onTap}) {
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
          boxShadow: isSelected ? [BoxShadow(color: const Color(0xFF819E4F).withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))] : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 13,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
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
              Text("Filters", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -1)),
              Text("Customize your search", style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
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
              decoration: BoxDecoration(color: Colors.red[50], shape: BoxShape.circle),
              child: Icon(Icons.refresh_rounded, color: Colors.red[400], size: 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    bool _isApplying = false; // Local variable to prevent double execution

    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).padding.bottom + 16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))
            ],
          ),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _isApplying ? Colors.grey.shade400 : const Color(0xFF819E4F),
              minimumSize: const Size(double.infinity, 60),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: _isApplying ? 0 : 8,
              shadowColor: _isApplying ? Colors.transparent : const Color(0xFF819E4F).withOpacity(0.4),
            ),
            onPressed: _isApplying ? null : () async {
              // Prevent double tap
              if (_isApplying) return;
              setState(() {
                _isApplying = true;
              });

              try {
                // Apply filters
                widget.controller.minPrice.value = _priceChanged ? _priceRange.start.toInt().toString() : "";
                widget.controller.maxPrice.value = _priceChanged ? _priceRange.end.toInt().toString() : "";

                widget.controller.minAreaSqft.value = _areaChanged ? _priceRange.start.toInt().toString() : "";
                widget.controller.maxAreaSqft.value = _areaChanged ? _priceRange.end.toInt().toString() : "";

                widget.controller.selectedStateId.value = _selectedStateId;
                widget.controller.selectedStateName.value = _selectedStateName;
                widget.controller.selectedCityId.value = _selectedCityId;
                widget.controller.selectedCityName.value = _selectedCityName;

                widget.controller.selectedPropertyTypeId.value = _selectedPropertyTypeId;
                widget.controller.selectedPropertyTypeName.value = _selectedPropertyTypeName;

                // Fetch data
                await widget.controller.fetchSyndicatePlots();

                // Close filter sheet
                Get.back();
              } catch (e) {
                // Handle error
                Get.snackbar(
                  'Error',
                  'Failed to apply filters',
                  backgroundColor: Colors.red.shade100,
                );
              } finally {
                if (mounted) {
                  setState(() {
                    _isApplying = false;
                  });
                }
              }
            },
            child: _isApplying
                ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  "Applying...",
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                ),
              ],
            )
                : const Text("Show Plots", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
          ),
        );
      },
    );
  }}

// Bottom Action Bar
class _BottomActionBar extends StatelessWidget {
  final SyndicatePlotController controller;
  const _BottomActionBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.black12, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "${controller.totalItems.value} Plots found",
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
          ),
          if (controller.hasFiltersApplied())
            GestureDetector(
              onTap: () => controller.clearFilters(),
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