import 'package:cashback_farms/common/colours.dart';
import 'package:cashback_farms/common/route/router.dart';
import 'package:cashback_farms/common/widget/appbar.dart';
import 'package:cashback_farms/common/widget/loader.dart';
import 'package:cashback_farms/features/material_store/controller/material_store_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/material_model.dart' as vendor;



class MaterialVendorList extends StatefulWidget {
  final int? id;
  final String? title;

  const MaterialVendorList({super.key, this.id, this.title});

  @override
  State<MaterialVendorList> createState() => _MaterialVendorListState();
}

class _MaterialVendorListState extends State<MaterialVendorList> {
  final MaterialController controller = Get.put(MaterialController());
  final ScrollController _scrollController = ScrollController();

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
                          "Filter Location",
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
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () {
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
                                cityId: controller.selectedCityId, selectedCategoryId: widget.id.toString(),
                              );
                              Get.back();
                            },
                            child: const Text(
                              "Apply Filter",
                              style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),
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
              _showLocationFilterBottomSheet(context);
            },
          )
        ],
      ),
      body: GetBuilder<MaterialController>(
        builder: (controller) {
          if (controller.isVendorLoading) {
            return const Center(child: GifLoader());
          }
          if (controller.vendorList.isEmpty) {
            return const Center(child: Text("No Vendors Found"));
          }
          return RefreshIndicator(
            onRefresh: () async {
              controller.clearLocationFilter(selectedCategoryId: widget.id.toString());
            },
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: controller.vendorList.length +
                  (controller.isFetchingMoreVendors ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == controller.vendorList.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                final vendor = controller.vendorList[index];
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
    final double rating = double.tryParse(vendor.reviewsAvgRating ?? "0") ?? 0;

    return Container(
      height: 220,
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
            Container(
              width: 130,
              height: double.infinity,
              color: Colors.grey.shade100,
              child: imageUrl.isNotEmpty
                  ? Image.network(imageUrl, fit: BoxFit.cover)
                  : const Icon(Icons.store, color: Colors.grey, size: 40),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      vendor.name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        _buildRatingStars(rating),
                        const SizedBox(width: 4),
                        Text(
                          rating.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _buildInfoBadge(Icons.assignment_turned_in, "GST: ${vendor.gst ?? 'N/A'}", Colors.blue),
                        _buildInfoBadge(Icons.timer, vendor.estimateDate ?? "No Est.", Colors.orange),
                      ],
                    ),
                    _buildIconText(Icons.phone, vendor.phone, Colors.green),
                    _buildIconText(Icons.location_on, vendor.address ?? "No Address", Colors.grey),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Get.toNamed(
                            AppRoutes.vendorDetailScreen,
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
                        child: const Text("View Details",style: TextStyle(fontWeight: FontWeight.w600),),
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
    return Row(
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
    );
  }

  Widget _buildRatingStars(double rating) {
    return Row(
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return const Icon(Icons.star, color: Colors.orange, size: 16);
        } else if (index < rating) {
          return const Icon(Icons.star_half,
              color: Colors.orange, size: 16);
        } else {
          return const Icon(Icons.star_border,
              color: Colors.orange, size: 16);
        }
      }),
    );
  }
}
