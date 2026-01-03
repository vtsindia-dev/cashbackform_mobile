import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/widget/appbar.dart';
import '../../../common/widget/loader.dart';
import '../controller/gioo_controller.dart';
import '../widget/gioo_plot_list.dart';

class Giooplot extends StatelessWidget {
  const Giooplot({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GiooPlotController>(
      init: GiooPlotController(),
      builder: (controller) {
        return Scaffold(
          appBar: const DynamicAppBar(
            title: "Gioo Plots",
            showBackButton: true,
          ),
          body: controller.isLoading.value
              ? const Center(
            child: GifLoader(message: "Loading...", size: 100),
          )
              : RefreshIndicator(
            onRefresh: () async {
              controller.clearFilters();
              controller.selectedPlotTypes.clear();
              await controller.fetchGiooPlots();
            },
            child: Column(
              children: [
                _FilterSection(controller: controller),
                Expanded(
                  child:   GiooPlotList(),
                ),
                _BottomActionBar(controller: controller),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FilterSection extends StatelessWidget {
  final GiooPlotController controller;

  const _FilterSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter header with clear all button
          Row(
            children: [
              const Text(
                "Filters",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              Obx(
                    () => AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: controller.hasFiltersApplied() ? 1.0 : 0.0,
                  child: TextButton.icon(
                    onPressed: controller.clearFilters,
                    icon: const Icon(Icons.close, size: 14),
                    label: const Text(
                      "Clear All",
                      style: TextStyle(fontSize: 13),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey.shade600,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Active filters chips
          Obx(
                () {
              if (!controller.hasFiltersApplied()) {
                return const SizedBox.shrink();
              }

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    // Filter button
                    _FilterChipButton(
                      label: "More Filters",
                      icon: Icons.add,
                      color: const Color(0xFFFDB913),
                      onTap: () => _openFilterSheet(context, controller),
                    ),
                    const SizedBox(width: 8),

                    // Selected plot types
                    ...controller.selectedPlotTypes.map(
                          (type) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _FilterChip(
                          label: _shortenTypeName(type),
                          onRemove: () {
                            controller.selectedPlotTypes.remove(type);
                            controller.fetchGiooPlots();
                          },
                        ),
                      ),
                    ),

                    // Search filter
                    if (controller.searchQuery.value.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _FilterChip(
                          label: "Search: ${controller.searchQuery.value}",
                          icon: Icons.search,
                          onRemove: () {
                            controller.searchQuery.value = '';
                            controller.fetchGiooPlots();
                          },
                        ),
                      ),

                    // Price filter
                    if (controller.minPrice.value.isNotEmpty ||
                        controller.maxPrice.value.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _FilterChip(
                          label: _formatPriceRange(controller),
                          icon: Icons.attach_money,
                          onRemove: () {
                            controller.minPrice.value = '';
                            controller.maxPrice.value = '';
                            controller.fetchGiooPlots();
                          },
                        ),
                      ),

                    // Area filter
                    if (controller.minAreaSqft.value.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _FilterChip(
                          label: "Min ${controller.minAreaSqft.value} sqft",
                          icon: Icons.square_foot,
                          onRemove: () {
                            controller.minAreaSqft.value = '';
                            controller.fetchGiooPlots();
                          },
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _shortenTypeName(String type) {
    return type
        .replaceAll('Gioo ', '')
        .replaceAll(' Plots', '')
        .replaceAll(' Properties', '');
  }

  String _formatPriceRange(GiooPlotController controller) {
    if (controller.minPrice.value.isNotEmpty &&
        controller.maxPrice.value.isNotEmpty) {
      return "₹${controller.minPrice.value} - ₹${controller.maxPrice.value}";
    } else if (controller.minPrice.value.isNotEmpty) {
      return "From ₹${controller.minPrice.value}";
    } else if (controller.maxPrice.value.isNotEmpty) {
      return "Up to ₹${controller.maxPrice.value}";
    }
    return "Price";
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onRemove;

  const _FilterChip({
    required this.label,
    this.icon,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF819E4F).withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF819E4F).withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 14,
              color: const Color(0xFF819E4F),
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF819E4F),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 18,
              height: 18,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF819E4F),
              ),
              child: const Icon(
                Icons.close,
                size: 12,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _FilterChipButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: Colors.white,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomActionBar extends StatelessWidget {
  final GiooPlotController controller;

  const _BottomActionBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Filter summary
          Expanded(
            child: Obx(
                  () {
                final count = controller.getActiveFilterCount();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      count > 0
                          ? "$count filter${count > 1 ? 's' : ''} active"
                          : "No filters applied",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    if (count > 0)
                      Text(
                        "Tap to refine",
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                  ],
                );
              },
            ),
          ),

          // Filter button
          Obx(
                () {
              final count = controller.getActiveFilterCount();
              return ElevatedButton.icon(
                onPressed: () => _openFilterSheet(context, controller),
                icon: count > 0
                    ? Badge(
                  label: Text(count.toString()),
                  smallSize: 18,
                  backgroundColor: Colors.white,
                  textColor: const Color(0xFFFDB913),
                  child: const Icon(Icons.filter_alt,
                      size: 20, color: Color(0xFFFDB913)),
                )
                    : const Icon(Icons.filter_alt_outlined,
                    size: 20, color: Colors.white),
                label: Text(
                  count > 0 ? "Edit Filters" : "Add Filters",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: count > 0 ? const Color(0xFFFDB913) : Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  count > 0 ? const Color(0xFFFDB913).withOpacity(0.1) : const Color(0xFFFDB913),
                  foregroundColor: count > 0 ? const Color(0xFFFDB913) : Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                    side: count > 0
                        ? const BorderSide(color: Color(0xFFFDB913), width: 1.5)
                        : BorderSide.none,
                  ),
                  elevation: 0,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

void _openFilterSheet(BuildContext context, GiooPlotController controller) {
  TextEditingController searchController =
  TextEditingController(text: controller.searchQuery.value);
  TextEditingController minPriceController =
  TextEditingController(text: controller.minPrice.value);
  TextEditingController maxPriceController =
  TextEditingController(text: controller.maxPrice.value);
  TextEditingController minAreaController =
  TextEditingController(text: controller.minAreaSqft.value);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    enableDrag: true,
    builder: (_) {
      return GestureDetector(
        onTap: () => Get.back(),
        child: Container(
          color: Colors.black.withOpacity(0.4),
          child: GestureDetector(
            onTap: () {},
            child: DraggableScrollableSheet(
              initialChildSize: 0.9,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              snap: true,
              snapSizes: const [0.5, 0.7, 0.95],
              builder: (_, scrollController) {
                return StatefulBuilder(
                  builder: (context, setState) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 30,
                            spreadRadius: -5,
                            offset: const Offset(0, -10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Drag handle
                          Padding(
                            padding: const EdgeInsets.only(top: 12, bottom: 4),
                            child: Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade400,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),

                          // Header
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 16),
                            child: Row(
                              children: [
                                const Text(
                                  "Filter & Sort",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                ),
                                const Spacer(),
                                Obx(
                                      () => AnimatedOpacity(
                                    duration:
                                    const Duration(milliseconds: 300),
                                    opacity: controller.hasFiltersApplied()
                                        ? 1.0
                                        : 0.0,
                                    child: TextButton(
                                      onPressed: controller.clearFilters,
                                      child: const Text(
                                        "Clear All",
                                        style: TextStyle(
                                          color: Color(0xFFFDB913),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                IconButton(
                                  icon: const Icon(Icons.close,
                                      size: 20, color: Colors.black54),
                                  onPressed: () => Get.back(),
                                ),
                              ],
                            ),
                          ),

                          const Divider(height: 1, color: Colors.grey),

                          // Content
                          Expanded(
                            child: SingleChildScrollView(
                              controller: scrollController,
                              physics: const ClampingScrollPhysics(),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Search
                                    _FilterSectionCard(
                                      title: "Search Properties",
                                      icon: Icons.search,
                                      child: _buildModernTextField(
                                        controller: searchController,
                                        hint: 'Enter location, name...',
                                        icon: Icons.search,
                                      ),
                                    ),

                                    const SizedBox(height: 24),

                                    // Plot Types
                                    _FilterSectionCard(
                                      title: "Plot Types",
                                      icon: Icons.category,
                                      child: _buildPlotTypeGrid(controller),
                                    ),

                                    const SizedBox(height: 24),

                                    // Price Range
                                    _FilterSectionCard(
                                      title: "Price Range",
                                      icon: Icons.attach_money,
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: _buildModernTextField(
                                              controller: minPriceController,
                                              hint: "Min",
                                              prefix: "₹",
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: _buildModernTextField(
                                              controller: maxPriceController,
                                              hint: "Max",
                                              prefix: "₹",
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 24),

                                    // Area
                                    _FilterSectionCard(
                                      title: "Area (Square Feet)",
                                      icon: Icons.square_foot,
                                      child: _buildModernTextField(
                                        controller: minAreaController,
                                        hint: "Minimum area",
                                        suffix: "sqft",
                                      ),
                                    ),

                                    const SizedBox(height: 40),

                                    // Apply Button
                                    SizedBox(
                                      width: double.infinity,
                                      height: 56,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          controller.searchQuery.value =
                                              searchController.text;
                                          controller.minPrice.value =
                                              minPriceController.text;
                                          controller.maxPrice.value =
                                              maxPriceController.text;
                                          controller.minAreaSqft.value =
                                              minAreaController.text;
                                          controller.fetchGiooPlots();
                                          Get.back();
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                          const Color(0xFF819E4F),
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(16),
                                          ),
                                          elevation: 2,
                                        ),
                                        child: const Text(
                                          "Apply Filters",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),

                                    SizedBox(
                                        height: MediaQuery.of(context)
                                            .padding
                                            .bottom +
                                            20),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      );
    },
  );
}

class _FilterSectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _FilterSectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: const Color(0xFF819E4F),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

Widget _buildModernTextField({
  required TextEditingController controller,
  required String hint,
  IconData? icon,
  String? prefix,
  String? suffix,
}) {
  return Container(
    height: 52,
    decoration: BoxDecoration(
      color: Colors.grey.shade50,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: Row(
      children: [
        if (prefix != null)
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text(
              prefix,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
        if (icon != null)
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 8),
            child: Icon(icon, color: Colors.grey.shade500, size: 20),
          ),
        Expanded(
          child: TextField(
            controller: controller,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade500),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            ),
          ),
        ),
        if (suffix != null)
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Text(
              suffix,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
      ],
    ),
  );
}

Widget _buildPlotTypeGrid(GiooPlotController controller) {
  final plotTypes = [
    "Gioo Plots Properties",
    "Gioo Rich Plots",
    "Gioo Main Plots",
    "Gioo Metro Plots",
    "Gioo Urban Plots",
  ];

  return GridView.builder(
    physics: const NeverScrollableScrollPhysics(),
    shrinkWrap: true,
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 3.5,
    ),
    itemCount: plotTypes.length,
    itemBuilder: (context, index) {
      final type = plotTypes[index];
      return Obx(() {
        final isSelected = controller.selectedPlotTypes.contains(type);
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              if (isSelected) {
                controller.selectedPlotTypes.remove(type);
              } else {
                controller.selectedPlotTypes.add(type);
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF819E4F).withOpacity(0.1)
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF819E4F)
                      : Colors.grey.shade300,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected ? Icons.check_circle : Icons.circle_outlined,
                    color: isSelected
                        ? const Color(0xFF819E4F)
                        : Colors.grey.shade400,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      type.replaceAll('Gioo ', ''),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected ? Colors.black87 : Colors.grey.shade700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      });
    },
  );
}