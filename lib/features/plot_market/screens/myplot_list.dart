import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../common/route/router.dart';
import '../../../common/widget/loader.dart';
import '../../../common/colours.dart';
import '../controller/plot_market_controller.dart';
import '../model/plot_market.dart';
import '../widget/marketplot_item.dart';

class MarketPlotsScreen extends StatefulWidget {
  const MarketPlotsScreen({super.key});

  @override
  State<MarketPlotsScreen> createState() => _MarketPlotsScreenState();
}

class _MarketPlotsScreenState extends State<MarketPlotsScreen> {
  final PlotMarketController controller = Get.put(PlotMarketController());
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  List<String> filterChips = ['All', 'Residential', 'Commercial', 'Verified', 'Pending'];
  String selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchMarketPlots();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      if (controller.hasMoreData.value && !controller.isLoadMore.value) {
        controller.loadMore();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundLight,
      body: Column(
        children: [
          _buildHeaderStats(),
          _buildSearchFilterSection(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.marketPlots.isEmpty) {
                return Center(
                  child: GifLoader(message: "Loading Properties", size: 120),
                );
              }

              if (controller.marketPlots.isEmpty) {
                return _buildEmptyState();
              }

              return RefreshIndicator(
                onRefresh: controller.refreshData,
                color: AppColor.primary,
                child: ListView(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  children: [
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12.w,
                        mainAxisSpacing: 12.h,
                        childAspectRatio: 0.6,
                      ),
                      itemCount: controller.marketPlots.length,
                      itemBuilder: (context, index) {
                        final plot = controller.marketPlots[index];
                        return MarketPlotItem(
                          plot: plot,
                          onTap: () => Get.toNamed(
                            AppRoutes.plotMarketDetails,
                            arguments: {"id": plot.id},
                          ),
                          onEdit: () => controller.openEditForm(plot),
                          onDelete: () => _confirmDelete(controller, plot),
                        );
                      },
                    ),
                    if (controller.isLoadMore.value)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.h),
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColor.primary,
                          ),
                        ),
                      ),
                    SizedBox(height: 80.h),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.openAddForm,
        backgroundColor: AppColor.primary,
        child: Icon(Icons.add, size: 24.sp),
      ),
    );
  }

  // 🔹 HEADER (NO OVERFLOW)
  Widget _buildHeaderStats() {
    return Container(
      height: 155,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColor.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20.r)),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: Get.back,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.arrow_back_ios_new, size: 14, color: Colors.white),
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  "My Properties",
                  style: TextStyle(
                    fontSize: 20.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            SizedBox(height: 8),

            Obx(() {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _statCard(Icons.home, controller.totalItems.value.toString(), "Total"),
                  SizedBox(width: 8),
                  _statCard(Icons.verified, "12", "Verified"),
                  SizedBox(width: 8),
                  _statCard(Icons.currency_rupee,
                      "${controller.totalItems.value * 5}L", "Value"),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _statCard(IconData icon, String value, String label) {
    return Flexible(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 6.h),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.white),
            SizedBox(height: 2),
            Text(value,
                style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
            Text(label,
                style: TextStyle(fontSize: 9.sp, color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  // 🔹 FILTER (CLEAN, NOT FILLED)
  Widget _buildSearchFilterSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      color: AppColor.white,
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: "Search plots...",
              prefixIcon: Icon(Icons.search, size: 18),
              filled: true,
              fillColor: AppColor.backgroundLight,
              contentPadding: EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            // onChanged: controller.searchPlots,
          ),

          SizedBox(height: 8),

          SizedBox(
            height: 32,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: filterChips.length,
              separatorBuilder: (_, __) => SizedBox(width: 8),
              itemBuilder: (context, index) {
                final chip = filterChips[index];
                final selected = selectedFilter == chip;

                return InkWell(
                  onTap: () {
                    setState(() => selectedFilter = chip);
                    if (chip == 'All') controller.clearFilters();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColor.primary.withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected
                            ? AppColor.primary
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        chip,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color:
                          selected ? AppColor.primary : AppColor.textMain,
                          fontWeight:
                          selected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(child: Text("No Properties Found"));
  }

  void _confirmDelete(PlotMarketController controller, MarketPlot plot) {
    Get.defaultDialog(
      title: "Delete Property",
      middleText: "Are you sure?",
      onConfirm: () async {
        Get.back();
        await controller.deleteMarketPlot(plot.id);
      },
      onCancel: () {},
    );
  }
}
