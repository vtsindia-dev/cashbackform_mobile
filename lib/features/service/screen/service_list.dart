import 'package:cashback_farms/common/colours.dart';
import 'package:cashback_farms/common/route/router.dart';
import 'package:cashback_farms/common/widget/appbar.dart';
import 'package:cashback_farms/common/widget/loader.dart';
import 'package:cashback_farms/features/service/controller/service_controller.dart' show ServiceController;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../model/service_model.dart' as vendor;

class ServiceList extends StatefulWidget {
  final int? id;
  final String? title;

  const ServiceList({super.key, this.id, this.title});

  @override
  State<ServiceList> createState() => _ServiceListState();
}

class _ServiceListState extends State<ServiceList> {
  final ServiceController controller = Get.put(ServiceController());
  final ScrollController _scrollController = ScrollController();

  // Rating filter state
  double? _selectedRating;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.clearLocationFilter(selectedCategoryId: widget.id.toString());
      controller.fetchStates();
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

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return GetBuilder<ServiceController>(
          builder: (controller) {
            return StatefulBuilder(
              builder: (context, setStateBottomSheet) {
                return Container(
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 12,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 45,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Filter",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            IconButton(
                              onPressed: () => Get.back(),
                              icon: const Icon(Icons.close),
                            )
                          ],
                        ),
                        const SizedBox(height: 20),

                        // State Filter
                        _sectionTitle("State"),
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

                        // City Filter
                        _sectionTitle("City"),
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

                        const SizedBox(height: 20),

                        // Rating Filter
                        _sectionTitle("Rating"),
                        _buildRatingFilterWidget(setStateBottomSheet),

                        const SizedBox(height: 30),

                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () {
                                  setState(() {
                                    _selectedRating = null;
                                  });
                                  controller.clearLocationFilter(selectedCategoryId: widget.id.toString());
                                  Get.back();
                                },
                                child: const Text(
                                  "Reset",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 2,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColor.primary,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
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
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
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
      },
    );
  }

  Widget _buildRatingFilterWidget(StateSetter setStateBottomSheet) {
    final ratings = [4.5, 4.0, 3.5, 3.0];

    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          // Current selection display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(Icons.star, color: Colors.amber, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedRating != null
                        ? "${_selectedRating!.toStringAsFixed(1)}★ & above"
                        : "Any Rating",
                    style: TextStyle(
                      color: _selectedRating != null ? AppColor.primary : Colors.grey,
                      fontSize: 15,
                      fontWeight: _selectedRating != null ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
                if (_selectedRating != null)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedRating = null;
                      });
                      setStateBottomSheet(() {});
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, size: 14),
                    ),
                  ),
              ],
            ),
          ),

          // Rating options
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Column(
              children: ratings.map((rating) {
                final isSelected = _selectedRating == rating;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedRating = isSelected ? null : rating;
                    });
                    setStateBottomSheet(() {});
                  },
                  child: Container(
                    margin: EdgeInsets.only(bottom: 12.h),
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColor.primary.withOpacity(0.1) : Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: isSelected ? AppColor.primary : Colors.grey.shade200,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Stars
                        Row(
                          children: List.generate(5, (index) {
                            final starValue = index + 1;
                            if (rating >= starValue) {
                              return Icon(Icons.star, color: Colors.amber, size: 16.sp);
                            } else if (rating >= starValue - 0.5) {
                              return Icon(Icons.star_half, color: Colors.amber, size: 16.sp);
                            } else {
                              return Icon(Icons.star_border, color: Colors.amber, size: 16.sp);
                            }
                          }),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          "${rating.toStringAsFixed(1)}★ & up",
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? AppColor.primary : Colors.grey.shade700,
                          ),
                        ),
                        const Spacer(),
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            color: AppColor.primary,
                            size: 18.sp,
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blueGrey, letterSpacing: 0.5),
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
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(15),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          dropdownColor: Colors.white,
          isExpanded: true,
          icon: const Icon(Icons.expand_more_rounded, color: Colors.blueGrey),
          value: value,
          hint: Row(
            children: [
              Icon(icon, size: 20, color: AppColor.primary,),
              const SizedBox(width: 12),
              Text(hint, style: const TextStyle(color: Colors.grey, fontSize: 15)),
            ],
          ),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }

  // Filter vendors by rating
  List<vendor.Vendor> _getFilteredVendors() {
    var vendors = controller.vendorList;
    if (_selectedRating != null) {
      vendors = vendors.where((v) {
        final rating = double.tryParse(v.reviewsAvgRating?.toString() ?? "0") ?? 0;
        return rating >= _selectedRating!;
      }).toList();
    }
    return vendors;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DynamicAppBar(
        title: widget.title ?? '',
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterBottomSheet(context);
            },
          ),
        ],
      ),
      body: GetBuilder<ServiceController>(
        builder: (controller) {
          if (controller.isVendorLoading) {
            return const Center(child: GifLoader());
          }

          final filteredVendors = _getFilteredVendors();

          if (filteredVendors.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.store_outlined,
                    size: 60,
                    color: Colors.grey.shade400,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    "No Vendors Found",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  if (_selectedRating != null) ...[
                    SizedBox(height: 8.h),
                    Text(
                      "No vendors with ${_selectedRating!.toStringAsFixed(1)}★ rating",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedRating = null;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primary,
                      ),
                      child: const Text("Clear Rating Filter"),
                    ),
                  ],
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _selectedRating = null;
              });
              controller.clearLocationFilter(selectedCategoryId: widget.id.toString());
            },
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: filteredVendors.length +
                  (controller.isFetchingMoreVendors ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == filteredVendors.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                final vendor = filteredVendors[index];
                return _buildVendorCard(vendor);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildVendorCard(vendor.Vendor vendor) {
    final String imageUrl =
    (vendor.thumbnail != null && vendor.thumbnail!.isNotEmpty)
        ? vendor.thumbnail!
        : "";
    final double rating = double.tryParse(vendor.reviewsAvgRating?.toString() ?? "0") ?? 0;
    final int reviewCount = int.tryParse(vendor.reviewsCount?.toString() ?? "0") ?? 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fixed width image container - remove height constraints
            SizedBox(
              width: 130,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
                child: imageUrl.isNotEmpty
                    ? Image.network(
                  imageUrl,
                  width: 130,
                  height: 200, // Fixed height instead of double.infinity
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 200,
                    color: Colors.grey.shade100,
                    child: const Icon(Icons.store, color: Colors.grey, size: 40),
                  ),
                )
                    : Container(
                  height: 200,
                  color: Colors.grey.shade100,
                  child: const Icon(Icons.store, color: Colors.grey, size: 40),
                ),
              ),
            ),
            // Expanded content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      vendor.name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildRatingStars(rating),
                        const SizedBox(width: 4),
                        Text(
                          rating.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "($reviewCount ${reviewCount == 1 ? 'review' : 'reviews'})",
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _buildInfoBadge(Icons.assignment_turned_in, "GST: ${vendor.gst ?? 'N/A'}", Colors.blue),
                        _buildInfoBadge(Icons.timer, vendor.estimateDate ?? "No Est.", Colors.orange),
                      ],
                    ),
                    const SizedBox(height: 6),
                    _buildIconText(Icons.phone, vendor.phone, Colors.green),
                    const SizedBox(height: 4),
                    _buildIconText(Icons.location_on, vendor.address ?? "No Address", Colors.grey),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Get.toNamed(
                            AppRoutes.vendorDataDetail,
                            arguments: {
                              "id": vendor.userId.toString(),
                              "title": vendor.name,
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        child: const Text("View Details", style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBadge(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildIconText(IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: color, fontSize: 13),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingStars(double rating) {
    return Row(
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return const Icon(Icons.star, color: Colors.orange, size: 16);
        } else if (index < rating) {
          return const Icon(Icons.star_half, color: Colors.orange, size: 16);
        } else {
          return const Icon(Icons.star_border, color: Colors.orange, size: 16);
        }
      }),
    );
  }
}