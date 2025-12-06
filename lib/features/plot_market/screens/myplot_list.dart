import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../common/route/router.dart';
import '../../../common/widget/appbar.dart';
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
        controller.loadMore(); // Changed from loadMorePlots() to loadMore()
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundLight,
      // appBar: DynamicAppBar(
      //   title: "My Properties",
      //   showBackButton: true,
      //   actions: [
      //     IconButton(
      //       icon: Icon(Icons.add_circle_outline, size: 24.sp, color: Colors.white),
      //       onPressed: () => controller.openAddForm(),
      //     ),
      //   ],
      // ),
      body: Column(
        children: [
          // Header with Stats
          _buildHeaderStats(),

          // Search and Filter Section
          _buildSearchFilterSection(),

          // Main Content
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.marketPlots.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GifLoader(message: "Loading Properties", size: 120),
                      SizedBox(height: 20.h),
                      Text(
                        "Fetching your properties...",
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColor.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (controller.marketPlots.isEmpty && !controller.isLoading.value) {
                return _buildEmptyState();
              }

              return RefreshIndicator(
                onRefresh: () => controller.refreshData(),
                backgroundColor: AppColor.white,
                color: AppColor.primary,
                child: ListView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  children: [
                    // Results Info
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Showing ${controller.marketPlots.length} of ${controller.totalItems.value} plots',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColor.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: AppColor.primarylite.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              selectedFilter,
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: AppColor.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ).animate().fade(duration: 300.ms).slide(begin: Offset(0, 0.05)),
                    ),

                    // Plots Grid
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
                          onTap: () =>   Get.toNamed(AppRoutes.plotMarketDetails, arguments: {"id": plot.id}),
                          onEdit: () => controller.openEditForm(plot),
                          onDelete: () => _confirmDelete(controller, plot),
                        )
                            .animate()
                            .fade(duration: 400.ms)
                            .slide(begin: Offset(0, 0.1))
                            .scale(duration: 300.ms, begin: Offset(0.95, 0.95))
                            .then(delay: (index * 50).ms);
                      },
                    ),

                    // Load More Indicator
                    if (controller.isLoadMore.value)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.h),
                        child: Center(
                          child: Column(
                            children: [
                              CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColor.primary,
                              ),
                              SizedBox(height: 12.h),
                              Text(
                                'Loading more properties...',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: AppColor.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    if (!controller.hasMoreData.value && controller.marketPlots.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 24.h),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                color: AppColor.primary,
                                size: 32.sp,
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                'All properties loaded',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: AppColor.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                'You have ${controller.totalItems.value} properties',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: AppColor.textSecondary.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ).animate().fade(duration: 300.ms),
                      ),

                    SizedBox(height: 80.h), // Bottom padding for FAB
                  ],
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => controller.openAddForm(),
        backgroundColor: AppColor.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Icon(Icons.add, size: 24.sp),
      )
          .animate()
          .scale(begin: Offset(0.8, 0.8), duration: 500.ms)
          .fade(duration: 500.ms)
          .shake(duration: 1000.ms, delay: 1000.ms),
    );
  }

  Widget _buildHeaderStats() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: AppColor.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24.r),
          bottomRight: Radius.circular(24.r),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColor.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back button and title row
            Row(
              children: [
                // Back button
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    width: 36.w,
                    height: 36.h,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18.sp,
                        color: Colors.white,
                      ),
                    ),
                  ).animate().fade(duration: 300.ms).scale(begin: Offset(0.8, 0.8)),
                ),
                SizedBox(width: 12.w),
                // Title
                Expanded(
                  child: Text(
                    "My Properties",
                    style: TextStyle(
                      fontSize: 24.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ).animate().fade(duration: 400.ms).slide(begin: Offset(-0.1, 0)),
                ),
              ],
            ),
        
            SizedBox(height: 12.h),
        
            // Stats row
            Obx(() {
              return Row(
                children: [
                  _buildStatItem(
                    icon: Icons.real_estate_agent,
                    value: controller.totalItems.value.toString(),
                    label: "Total Plots",
                  ),
                  SizedBox(width: 20.w),
                  _buildStatItem(
                    icon: Icons.verified,
                    value: "12",
                    label: "Verified",
                  ),
                  SizedBox(width: 20.w),
                  _buildStatItem(
                    icon: Icons.trending_up,
                    value: "₹${controller.totalItems.value * 500000}",
                    label: "Total Value",
                  ),
                ].animate(interval: 100.ms).slide(begin: Offset(0, 0.1)).fade(),
              );
            }),
          ],
        ),
      ),
    );
  }
  Widget _buildStatItem({required IconData icon, required String value, required String label}) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20.sp, color: Colors.white),
            SizedBox(height: 4.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.sp,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchFilterSection() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColor.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: AppColor.backgroundLight,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search plots by name, location, type...',
                hintStyle: TextStyle(
                  fontSize: 13.sp,
                  color: AppColor.textSecondary.withOpacity(0.7),
                ),
                prefixIcon: Icon(Icons.search, color: AppColor.primary, size: 20.sp),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: Icon(Icons.close, size: 18.sp, color: AppColor.textSecondary),
                  onPressed: () {
                    _searchController.clear();
                    controller.searchPlots('');
                  },
                )
                    : null,
              ),
              onChanged: (value) => controller.searchPlots(value),
              style: TextStyle(fontSize: 14.sp, color: AppColor.textMain),
            ),
          ).animate().fade(duration: 300.ms).scale(begin: Offset(0.95, 0.95)),

          SizedBox(height: 12.h),

          // Filter Chips
          SizedBox(
            height: 40.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: filterChips.length,
              separatorBuilder: (_, __) => SizedBox(width: 8.w),
              itemBuilder: (context, index) {
                final chip = filterChips[index];
                return FilterChip(
                  label: Text(chip),
                  selected: selectedFilter == chip,
                  onSelected: (selected) {
                    setState(() {
                      selectedFilter = selected ? chip : 'All';
                    });
                    // Add your filter logic here
                    if (selectedFilter == 'All') {
                      controller.clearFilters();
                    }
                  },
                  backgroundColor: AppColor.backgroundLight,
                  selectedColor: AppColor.primarylite.withOpacity(0.2),
                  labelStyle: TextStyle(
                    fontSize: 12.sp,
                    color: selectedFilter == chip ? AppColor.primary : AppColor.textMain,
                    fontWeight: selectedFilter == chip ? FontWeight.w600 : FontWeight.normal,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                    side: BorderSide(
                      color: selectedFilter == chip ? AppColor.primary : Colors.grey.shade300,
                      width: selectedFilter == chip ? 1.5 : 1,
                    ),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 0),
                  elevation: 0,
                  showCheckmark: false,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.real_estate_agent,
              size: 80.sp,
              color: AppColor.primary.withOpacity(0.3),
            ),
            SizedBox(height: 24.h),
            Text(
              'No Properties Found',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: AppColor.textMain,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'You haven\'t added any properties yet.\nStart by adding your first property!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColor.textSecondary,
              ),
            ),
            SizedBox(height: 32.h),
            ElevatedButton(
              onPressed: () => controller.openAddForm(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 2,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, size: 18.sp),
                  SizedBox(width: 8.w),
                  Text('Add First Property', style: TextStyle(fontSize: 14.sp)),
                ],
              ),
            ),
          ]
              .animate(interval: 100.ms)
              .fade(duration: 400.ms)
              .slide(begin: Offset(0, 0.1)),
        ),
      ),
    );
  }

  void _confirmDelete(PlotMarketController controller, MarketPlot plot) {
    Get.dialog(
      Animate(
        effects: [FadeEffect(duration: 300.ms), ScaleEffect(duration: 300.ms)],
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColor.orange, size: 24.sp),
              SizedBox(width: 12.w),
              Text(
                'Delete Property',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to delete:',
                style: TextStyle(fontSize: 14.sp, color: AppColor.textSecondary),
              ),
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColor.backgroundLight,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plot.name,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColor.textMain,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      plot.address ?? '',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColor.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'This action cannot be undone.',
                style: TextStyle(fontSize: 12.sp, color: AppColor.orange),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              ),
              child: Text(
                'Cancel',
                style: TextStyle(color: AppColor.textSecondary, fontSize: 14.sp),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Get.back();
                await controller.deleteMarketPlot(plot.id);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Changed from AppColor.red
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              child: Text('Delete', style: TextStyle(fontSize: 14.sp)),
            ),
          ],
        ),
      ),
    );
  }
}