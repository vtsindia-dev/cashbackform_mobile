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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DynamicAppBar(
        title: "Professional Services",
        showBackButton: false,
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
