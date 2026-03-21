import 'package:cashback_farms/features/material_store/controller/material_store_controller.dart';
import 'package:cashback_farms/features/material_store/model/material_home_list_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/widget/appbar.dart';
import '../../../common/widget/loader.dart';
import 'package:cashback_farms/common/colours.dart';
import 'package:cashback_farms/common/route/router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class MaterialStore extends StatefulWidget {
  const MaterialStore({super.key});

  @override
  State<MaterialStore> createState() => _MaterialStoreState();
}

class _MaterialStoreState extends State<MaterialStore> {

  final MaterialController controller = Get.put(MaterialController());
  final ScrollController _scrollController = ScrollController();


  @override
  void initState() {
    super.initState();
    controller.clearFilter();
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

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return GetBuilder<MaterialController>(
          builder: (controller) {
            return Container(
              padding: EdgeInsets.only(
                  left: 20, right: 20, top: 12,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20
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
                        width: 45, height: 4,
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
                          "Material Services",
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A)),
                        ),
                        IconButton(
                          onPressed: () => Get.back(),
                          icon: const Icon(Icons.close, color: Colors.grey),
                        )
                      ],
                    ),
                    const SizedBox(height: 15),

                    _buildSearchBar(controller),
                    const SizedBox(height: 25),
                    _sectionTitle("Main Category"),
                    _buildDropdown(
                      hint: "Select Category",
                      value: controller.selectedCategory,
                      icon: Icons.grid_view_rounded,
                      items: controller.categoryList.map((e) => DropdownMenuItem(
                        value: e.id.toString(),
                        child: Text(e.categoryName ?? ""),
                      )).toList(),
                      onChanged: (val) {
                        controller.selectedCategory = val;
                        controller.selectedSubCategory = null;
                        controller.selectedSubSubCategory = null;
                        controller.subCategoryList.clear();
                        controller.subSubCategoryList.clear();
                        controller.update();
                        if (val != null && val.isNotEmpty) {
                          controller.getSubCategories(val);
                        }
                      },
                    ),

                    const SizedBox(height: 20),
                    _sectionTitle("Sub Category"),
                    _buildDropdown(
                      hint: controller.isSubCategoryLoading
                          ? "Loading..."
                          : "Select Sub Category",
                      value: controller.selectedSubCategory,
                      icon: Icons.account_tree_outlined,
                      items: controller.subCategoryList.map((e) => DropdownMenuItem(
                        value: e.id.toString(),
                        child: Text(e.name ?? ""),
                      )).toList(),
                      onChanged: (val) {
                        controller.selectedSubCategory = val;

                        controller.selectedSubSubCategory = null;
                        controller.subSubCategoryList.clear();

                        controller.update();
                        controller.getSubSubCategories(val);
                      },
                    ),

                    const SizedBox(height: 20),
                    _sectionTitle("Specific Type"),
                    _buildDropdown(
                      hint: controller.isSubSubCategoryLoading
                          ? "Loading..."
                          : "Sub Sub Category",
                      value: controller.selectedSubSubCategory,
                      icon: Icons.category_outlined,
                      items: controller.subSubCategoryList.map((e) => DropdownMenuItem(
                        value: e.id.toString(),
                        child: Text(e.name ?? ""),
                      )).toList(),
                      onChanged: (val) {
                        controller.selectedSubSubCategory = val;
                        controller.update();
                      },
                    ),
                    const SizedBox(height: 20),
                    _sectionTitle("Product Brand"),

                    _buildMultiSelectDropdown(controller),
                    const SizedBox(height: 35),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              controller.clearFilter();
                              Get.back();
                            },
                            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
                            child: const Text("Reset", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 0,
                            ),
                            onPressed: () {
                              controller.applyFilter(
                                search: controller.searchController.text,
                                category: controller.selectedCategory,
                                subCategory: controller.selectedSubCategory,
                                subSubCategory: controller.selectedSubSubCategory,
                                brandIds: controller.selectedBrandIds,
                              );
                              Get.back();
                            },
                            child: const Text("Apply Filter", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Colors.white)),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMultiSelectDropdown(MaterialController controller) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: controller.selectedBrandNames.map((name) {
              int index = controller.selectedBrandNames.indexOf(name);
              return Chip(
                backgroundColor: Colors.white,
                label: Text(name),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () {
                  controller.selectedBrandIds.removeAt(index);
                  controller.selectedBrandNames.removeAt(index);
                  controller.update();
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 200,
            child: ListView.builder(
              itemCount: controller.brandList.length,
              itemBuilder: (context, index) {
                final brand = controller.brandList[index];

                bool isSelected = controller.selectedBrandIds
                    .contains(brand.id.toString());

                return CheckboxListTile(
                  activeColor: AppColor.primary,
                  value: isSelected,
                  title: Text(brand.name ?? ""),
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (val) {
                    if (val == true) {
                      controller.selectedBrandIds.add(brand.id.toString());
                      controller.selectedBrandNames.add(brand.name ?? "");
                    } else {
                      controller.selectedBrandIds.remove(brand.id.toString());
                      controller.selectedBrandNames.remove(brand.name ?? "");
                    }
                    controller.update();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(MaterialController controller) {
    return TextField(
      controller: controller.searchController,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        hintText: "Search products",
        prefixIcon: const Icon(Icons.search, color: AppColor.primary, size: 22),
        filled: true,
        fillColor: const Color(0xFFF5F7FA),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DynamicAppBar(
        title: "Material Store",
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterBottomSheet(context);
            },
          )
        ],
      ),
      body: GetBuilder<MaterialController>(
        builder: (controller) {
          if (controller.isMaterialServiceLoading) {
            return Center(
              child: GifLoader(
                message: "Loading...",
                size: 100,
              ),
            );
          }
          if (controller.materialServiceList.isEmpty) {
            return const Center(child: Text("No Data Found"));
          }
          final list = controller.materialServiceList;
          return RefreshIndicator(
            color: AppColor.primary,
            onRefresh: () async {
                controller.clearFilter();
            },
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: (list.length / 2).ceil() + (controller.isFetchingMoreMaterialService ? 1 : 0),
              itemBuilder: (context, rowIndex) {
                if (rowIndex == (list.length / 2).ceil()) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator(color: AppColor.primary,)),
                  );
                }
                final leftIndex = rowIndex * 2;
                final rightIndex = leftIndex + 1;

                final leftItem = list[leftIndex];
                final rightItem =
                rightIndex < list.length ? list[rightIndex] : null;
                return Row(
                  children: [
                    Expanded(child: _buildServiceCard(leftItem)),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: rightItem != null
                          ? _buildServiceCard(rightItem)
                          : const SizedBox(),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildServiceCard(MaterialHomeListModel item) {
    String imageUrl = "";
    if (item.image != null && item.image!.isNotEmpty) {
      imageUrl = item.image!.first;
    }
    return GestureDetector(
      onTap: () {
        Get.toNamed(
          AppRoutes.vendorList,
          arguments: {
            "id": item.id,
            "title": item.materialName,
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              blurRadius: 6,
              color: Colors.black.withOpacity(0.1),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: imageUrl.isNotEmpty
                  ? Image.network(
                imageUrl,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
              )
                  : Container(
                height: 120,
                color: Colors.grey.shade300,
                child: const Icon(Icons.image),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                item.materialName ?? "",
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (item.category?.categoryName != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  item.category?.categoryName ?? "",
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey,
                  ),
                ),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

