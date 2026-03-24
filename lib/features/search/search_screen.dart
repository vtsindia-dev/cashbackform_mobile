import 'dart:ui';
import 'package:cashback_farms/common/colours.dart';
import 'package:cashback_farms/common/route/router.dart';
import 'package:cashback_farms/common/widget/appbar.dart';
import 'package:cashback_farms/features/residential_plots/controller/residential_controller.dart';
import 'package:cashback_farms/features/search/controller/search_controller.dart';
import 'package:cashback_farms/features/search/model/common_search_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/widget/loader.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final CommonSearchController controller = Get.put(CommonSearchController());
  final ScrollController _scrollController = ScrollController();
  final ScrollController _scrollCategoryController = ScrollController();
  final ResidentialPropertyController residentialPropertyController = Get.put(ResidentialPropertyController());

  @override
  void initState() {
    super.initState();

    controller.resetSearch();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !controller.isLoadMore &&
          controller.currentPage < controller.totalPages) {
        controller.loadMoreSearch();
      }
    });
  }

  final List<GlobalKey> _itemKeys = [];

  void _scrollToIndex(int index) {
    final context = _itemKeys[index].currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        alignment: 0.5,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: DynamicAppBar(title: "Search", showBackButton: true),
        body: GetBuilder<CommonSearchController>(
          init: CommonSearchController(),
          builder: (controller) {
            if (_itemKeys.length != controller.filterCategoryItems.length) {
              _itemKeys.clear();
              _itemKeys.addAll(
                List.generate(
                  controller.filterCategoryItems.length,
                  (index) => GlobalKey(),
                ),
              );
            }
            return Column(
              children: [
                const SizedBox(height: 10),
                searchWidget(controller),
                const SizedBox(height: 10),
                _buildCategoryBar(controller),
                const SizedBox(height: 10),
                _buildList(controller),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategoryBar(CommonSearchController controller) {
    return SizedBox(
      height: 45,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        controller: _scrollCategoryController,
        scrollDirection: Axis.horizontal,
        itemCount: controller.filterCategoryItems.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = controller.selectedIndex == index;

          return GestureDetector(
            key: _itemKeys[index],
            onTap: () {
              controller.selectCategory(index);
              Future.delayed(const Duration(milliseconds: 50), () {
                _scrollToIndex(index);
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Color.fromRGBO(199, 221, 148, 1),
                          Color.fromRGBO(146, 175, 93, 1),
                        ],
                      )
                    : null,
                color: isSelected ? null : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(25),
                boxShadow: isSelected
                    ? [
                        const BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
              child: Center(
                child: Text(
                  controller.filterCategoryItems[index].title,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget searchWidget(CommonSearchController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          const Icon(Icons.search_rounded, color: Colors.black54, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller.searchTextController,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              decoration: const InputDecoration(
                hintText: "Search Your Location...",
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
          Material(
            color: Colors.black,
            borderRadius: BorderRadius.circular(30),
            child: InkWell(
              onTap: () {
                FocusScope.of(context).unfocus();
                controller.resetSearch();
              },
              borderRadius: BorderRadius.circular(30),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: const Text(
                  "Search",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(CommonSearchController controller) {
    final list = controller.searchList;
    if (controller.isLoading) {
      return Expanded(
        child: Center(child: GifLoader(message: "Loading...", size: 100)),
      );
    }

    if (list.isEmpty) {
      return Expanded(child: Center(child: Text("No Data Found")));
    }
    return Expanded(
      child: RefreshIndicator(
        color: AppColor.primary,
        onRefresh: () async => controller.resetSearch(),
        child: ListView.separated(
          separatorBuilder: (context, i) => SizedBox(height: 10),
          controller: _scrollController,
          padding: const EdgeInsets.all(12),
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: (list.length / 2).ceil() + (controller.isLoadMore ? 1 : 0),
          itemBuilder: (context, rowIndex) {
            if (rowIndex == (list.length / 2).ceil()) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: CircularProgressIndicator(color: AppColor.primary),
                ),
              );
            }

            final leftIndex = rowIndex * 2;
            final rightIndex = leftIndex + 1;

            final leftItem = list[leftIndex];
            final rightItem = rightIndex < list.length
                ? list[rightIndex]
                : null;

            return Row(
              children: [
                Expanded(child: _buildCard(leftItem, controller)),
                const SizedBox(width: 10),
                Expanded(
                  child: rightItem != null
                      ? _buildCard(rightItem, controller)
                      : const SizedBox(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _navigateByTitle(CommonSearchModel item) {
    String type = item.type ?? "";
    if (type == "market") {
      Get.toNamed(AppRoutes.plotMarketDetails, arguments: {"id": item.id, "title": item.name});
    } else if (type == "geo") {
      Get.toNamed(AppRoutes.giooDetails, arguments: {"id": item.id, "title": item.name});
    } else if (type == "syndicate") {
      Get.toNamed(AppRoutes.syndicateDetails, arguments: {"id": item.id, "title": item.name,});
    }
    else if (type == "rental") {
      Get.toNamed(AppRoutes.rentalDetails, arguments: {'id': item.id, 'title': item.name,},);
    } else {
      Get.toNamed(AppRoutes.residentialDetails, arguments: {"id": item.id, "title": item.propertyName});
    }
  }

  Widget _buildCard(CommonSearchModel item, CommonSearchController controller) {
    String imageUrl = (item.image != null && item.image!.isNotEmpty)
        ? item.image!.first
        : "";

    return GestureDetector(
      onTap: () => _navigateByTitle(item),
      child: Container(
        height: 260,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              blurRadius: 15,
              offset: const Offset(0, 8),
              color: Colors.black.withOpacity(0.05),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) => Image.asset(
                                'assets/images/no-image.jpg',
                                fit: BoxFit.cover,
                              ),
                            )
                          : Image.asset(
                              'assets/images/no-image.jpg',
                              fit: BoxFit.cover,
                            ),
                    ),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.center,
                            colors: [
                              Colors.black.withOpacity(0.2),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      left: 10,
                      child: _buildTag(
                        title: getTypeLabel(item.type),
                        bgColor: Colors.white.withOpacity(0.85),
                        textColor: AppColor.primary,
                      ),
                    ),
                    if (item.propertyType?.categoryName != null)
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: _buildTag(
                          title: item.propertyType?.categoryName ?? '',
                          bgColor: Colors.black.withOpacity(0.6),
                          textColor: Colors.white,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.type == "plot"
                              ? item.propertyName ?? ""
                              : item.name ?? "",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              color: Colors.grey,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                item.type == "plot"
                                    ? item.location ?? ''
                                    : item.address ?? "",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (item.type == "rental") ...[
                      Flexible(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: "Rent: ",
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              TextSpan(
                                text: "₹${item.rentAmount ?? '0'}",
                                style: const TextStyle(
                                  color: AppColor.primary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Flexible(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: "Yield: ",
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 11,
                                ),
                              ),
                              TextSpan(
                                text: "₹${item.yieldAmount ?? '0'}",
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (item.type != "rental")
                          Text(
                            "₹${item.price ?? item.startingPrice ?? 0}",
                            style: const TextStyle(
                              color: AppColor.primary,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                      ],
                    ),
                      Row(
                        children: [
                          if (item.city?.cityName != null) ...[
                            Flexible(
                              child: Text(
                                item.city!.cityName!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 11,
                                ),
                              ),
                            ),

                            const SizedBox(width: 4),

                            Text(
                              "•",
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 12,
                              ),
                            ),

                            const SizedBox(width: 4),
                          ],

                          Text(
                            item.type == "rental" || item.type == "synticate" || item.type == "geo" ||   item.type == "market"
                                ? '${item.area} /sq.ft'
                                : '${item.areaSqftPrice} /sq.ft',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 11,
                            ),
                          ),
                        ],
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

  Widget _buildTag({
    required String title,
    required Color bgColor,
    required Color textColor,
  }) {
    if (title.isEmpty) return const SizedBox();
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 9,
              letterSpacing: 0.5,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }

  String getTypeLabel(String? type) {
    switch (type) {
      case "market":
        return "Land / Plot";
      case "geo":
        return "Gioo Nano Plots";
      case "rental":
        return "GIO Rental Yield";
      case "syndicate":
        return "GIO Rental Syndicate";
      case "plot":
        return "Flats / Villas";
      default:
        return "";
    }
  }
}
