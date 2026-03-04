// my_plots_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../common/colours.dart';
import '../../../common/route/router.dart';
import '../../../common/widget/loader.dart';
import '../../../common/widget/toster.dart';
import '../../menu/controller/dashboard_menu_controller.dart';
import '../controller/plot_market_controller.dart';
import '../model/plot_market.dart';
import '../widget/marketplot_item.dart';

class MyPlotsMArkScreen extends StatefulWidget {
  const MyPlotsMArkScreen({super.key});

  @override
  State<MyPlotsMArkScreen> createState() => _MyPlotsMArkScreenState();
}

class _MyPlotsMArkScreenState extends State<MyPlotsMArkScreen> {
  final PlotMarketController controller = Get.put(PlotMarketController());
  final ScrollController _scrollController = ScrollController();
  final dashboardController = Get.put(DashboardController());

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchMyMarketPlots();
      dashboardController.fetchBusinessSettings();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      if (controller.myHasMoreData.value && !controller.isLoadMoreMyPlots.value) {
        controller.loadMoreMyPlots();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundLight,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Obx(() {
              if (controller.isLoadingMyPlots.value && controller.myMarketPlots.isEmpty) {
                return Center(
                  child: GifLoader(message: "Loading Your Properties", size: 120),
                );
              }

              if (controller.myMarketPlots.isEmpty) {
                return _buildEmptyState();
              }

              return RefreshIndicator(
                onRefresh: controller.refreshMyPlots,
                color: AppColor.primary,
                child: ListView(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  children: [
                    // Stats Card
                    // _buildStatsCard(),
                    // SizedBox(height: 16.h),

                    // // Filter Chips
                    // _buildFilterChips(),
                    // SizedBox(height: 16.h),

                    // Plots Grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12.w,
                        mainAxisSpacing: 12.h,
                        childAspectRatio: 0.72,
                      ),
                      itemCount: controller.myMarketPlots.length,
                      itemBuilder: (context, index) {
                        final plot = controller.myMarketPlots[index];
                        return MarketPlotItem(
                          plot: plot,
                          onTap: () => Get.toNamed(
                            AppRoutes.plotMarketDetails,
                            arguments: {"id": plot.id,"title": plot.name},
                          ),
                          onEdit: () => controller.openEditForm(plot),
                          onDelete: () => _confirmDelete(plot),
                          onVerify: () => controller.initiateVerificationPayment(plot),
                          isOwner: true,
                        );
                      },
                    ),

                    if (controller.isLoadMoreMyPlots.value)
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

  Widget _buildHeader() {
    return Container(
      height: 110.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColor.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20.r)),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: Get.back,
                  child: Container(
                    width: 32.w,
                    height: 32.h,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(Icons.arrow_back_ios_new,
                        size: 14.sp, color: Colors.white),
                  ),
                ),
                SizedBox(width: 12.w),
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

            // Quick stats row
            // Obx(() => Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceAround,
            //   children: [
            //     _buildStatItem(
            //       "Total",
            //       controller.myTotalItems.value.toString(),
            //       Icons.home,
            //     ),
            //     _buildStatItem(
            //       "Verified",
            //       controller.myMarketPlots.where((p) => p.verifyStatus == 1).length.toString(),
            //       Icons.verified,
            //       color: Colors.green,
            //     ),
            //     _buildStatItem(
            //       "Pending",
            //       controller.myMarketPlots.where((p) => p.verifyStatus == 0).length.toString(),
            //       Icons.pending,
            //       color: Colors.orange,
            //     ),
            //   ],
            // )),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, {Color? color}) {
    return Column(
      children: [
        Icon(icon, size: 22.sp, color: color ?? Colors.white),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 16.sp,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Manage Your Properties",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColor.textMain,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                "Add, edit or delete your properties",
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColor.textSecondary,
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: controller.openAddForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primary,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.add, size: 16.sp),
                SizedBox(width: 4.w),
                Text("Add New", style: TextStyle(fontSize: 12.sp)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Obx(() {
      final verifiedCount = controller.myMarketPlots
          .where((plot) => plot.verifyStatus == 1)
          .length;
      final pendingCount = controller.myMarketPlots
          .where((plot) => plot.verifyStatus == 0)
          .length;

      return SizedBox(
        height: 40.h,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            _buildFilterChip("All", true),
            SizedBox(width: 8.w),
            _buildFilterChip("Verified ($verifiedCount)", false),
            SizedBox(width: 8.w),
            _buildFilterChip("Pending ($pendingCount)", false),
            SizedBox(width: 8.w),
            _buildFilterChip("For Sale", false),
            SizedBox(width: 8.w),
            _buildFilterChip("For Rent", false),
          ],
        ),
      );
    });
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isSelected ? AppColor.primary : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isSelected ? AppColor.primary : Colors.grey.shade300,
        ),
        boxShadow: isSelected ? [] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: isSelected ? Colors.white : AppColor.textMain,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/empty_properties.png',
            height: 180.h,
            width: 180.h,
            color: AppColor.primary.withOpacity(0.3),
          ),
          SizedBox(height: 24.h),
          Text(
            "No Properties Found",
            style: TextStyle(
              fontSize: 18.sp,
              color: AppColor.textMain,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Text(
              "You haven't added any properties yet. Start by adding your first property to list it in the market.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColor.textSecondary,
              ),
            ),
          ),
          SizedBox(height: 32.h),
          ElevatedButton(
            onPressed: controller.openAddForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primary,
              padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 14.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              elevation: 2,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_circle_outline, size: 18.sp),
                SizedBox(width: 8.w),
                Text(
                  "Add Your First Property",
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(MarketPlot plot) {
    Get.defaultDialog(
      title: "Delete Property",
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Are you sure you want to delete:"),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plot.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  plot.location,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            "This action cannot be undone.",
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.red.shade600,
            ),
          ),
        ],
      ),
      textConfirm: "Delete",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () async {
        Get.back();
        final success = await controller.deleteMarketPlot(plot.id);
        if (success) {
          SnackBarHelper.showSuccess("Property deleted successfully");
        }
      },
    );
  }
}