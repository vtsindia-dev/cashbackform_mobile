import 'package:cashback_farms/common/api_constant.dart';
import 'package:cashback_farms/common/colours.dart';
import 'package:cashback_farms/common/route/router.dart';
import 'package:cashback_farms/common/widget/appbar.dart';
import 'package:cashback_farms/common/widget/loader.dart';
import 'package:cashback_farms/features/service/controller/service_controller.dart';
import 'package:cashback_farms/features/service/model/categories_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ServiceScreen extends StatefulWidget {
  const ServiceScreen({super.key});

  @override
  State<ServiceScreen> createState() => _ServiceScreenState();
}

class _ServiceScreenState extends State<ServiceScreen> {

  final ServiceController controller = Get.put(ServiceController());
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    controller.getCategoriesServiceList();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200 &&
          !controller.isFetchingMoreCategoriesService &&
          controller.categoriesServiceCurrentPage <
              controller.categoriesServiceTotalPages) {

        controller.loadMoreCategoriesService();
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
            return DraggableScrollableSheet(
              initialChildSize: 0.75,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              expand: false,
              builder: (_, scrollController) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Filter Services",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: () => Get.back(),
                            icon: const Icon(Icons.close),
                          )
                        ],
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: ListView(
                          controller: scrollController,
                          children: [
                            _buildSearchBar(controller),
                            const SizedBox(height: 20),
                            _sectionTitle("Category"),
                            _buildDropdown(
                              hint: "Select Category",
                              value: controller.selectedCategory,
                              items: controller.categoryList
                                  .map((e) => DropdownMenuItem(
                                value: e.id.toString(),
                                child: Text(e.categoryName ?? ""),
                              ))
                                  .toList(),
                              onChanged: (val) {
                                controller.selectedCategory = val;
                                controller.getSubCategories(val);
                                controller.update();
                              },
                            ),
                            const SizedBox(height: 15),
                            _sectionTitle("Sub Category"),
                            _buildDropdown(
                              hint: "Select Sub Category",
                              value: controller.selectedSubCategory,
                              items: controller.subCategoryList
                                  .map((e) => DropdownMenuItem<String>(
                                value: e.id.toString(),
                                child: Text(e.name ?? ""),
                              ))
                                  .toList(),
                              onChanged: (val) {
                                controller.selectedSubCategory = val;
                                controller.getSubSubCategories(val);
                                controller.update();
                              },
                            ),
                            const SizedBox(height: 15),
                            _sectionTitle("Sub Sub Category"),
                            _buildDropdown(
                              hint: "Select Sub Sub Category",
                              value: controller.selectedSubSubCategory,
                              items: controller.subSubCategoryList
                                  .map((e) => DropdownMenuItem(
                                value: e.id.toString(),
                                child: Text(e.name ?? ""),
                              ))
                                  .toList(),
                              onChanged: (val) {
                                controller.selectedSubSubCategory = val;
                                controller.update();
                              },
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                controller.clearFilter();
                              },
                              child: const Text("Clear"),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                controller.applyFilter(
                                  search: controller.searchController.text,
                                  category: controller.selectedCategory,
                                  subCategory: controller.selectedSubCategory,
                                  subSubCategory: controller.selectedSubSubCategory,
                                );
                                Get.back();
                              },
                              child: const Text("Apply"),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
  Widget _buildSearchBar(ServiceController controller) {
    return TextField(
      controller: controller.searchController,
      decoration: InputDecoration(
        hintText: "Search services...",
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: Colors.grey,
        ),
      ),
    );
  }
  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          hint: Text(hint),
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
        title: "Professional Services",
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
      body: GetBuilder<ServiceController>(
        builder: (controller) {
          if (controller.isCategoriesServiceLoading) {
            return Center(
              child: GifLoader(
                message: "Loading...",
                size: 100,
              ),
            );
          }
          if (controller.categoriesServiceList.isEmpty) {
            return const Center(child: Text("No Data Found"));
          }
          final list = controller.categoriesServiceList;
          return RefreshIndicator(
            color: AppColor.primary,
            onRefresh: () async {
              await controller.resetCategoriesService();
            },
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: (list.length / 2).ceil() + (controller.isFetchingMoreCategoriesService ? 1 : 0),
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

  Widget _buildServiceCard(CategoriesServiceModel item) {
    String imageUrl = "";
    if (item.image != null && item.image!.isNotEmpty) {
      imageUrl = item.image!.first;
    }
    return GestureDetector(
      onTap: () {
        Get.toNamed(
          AppRoutes.serviceList,
          arguments: {
            "id": item.id,
            "title": item.serviceName,
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
                item.serviceName ?? "",
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
