import 'package:cashback_farms/common/route/router.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../Properties/widget/property_card.dart';
import '../controller/plot_market_controller.dart';
import '../model/plot_market.dart';

class PlotMarketList extends StatefulWidget {
  const PlotMarketList({super.key});

  @override
  State<PlotMarketList> createState() => _PlotMarketListState();
}

class _PlotMarketListState extends State<PlotMarketList> {
  final PlotMarketController controller = Get.put(PlotMarketController());
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        controller.loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.marketPlots.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.marketPlots.isEmpty) {
        return const Center(child: Text('No market plots found'));
      }

      final productList = controller.marketPlots;

      return ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        controller: _scrollController,
        padding: EdgeInsets.only(bottom: 100.h, left: 10.w, right: 10.w, top: 10.h),
        itemCount: (productList.length / 2).ceil() +
            (controller.isLoadMore.value && controller.hasMoreData.value ? 1 : 0),
        itemBuilder: (context, rowIndex) {
          // Loading indicator row
          if (rowIndex == (productList.length / 2).ceil()) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 30),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final leftIndex = rowIndex * 2;
          final rightIndex = leftIndex + 1;
          final leftPlot = productList[leftIndex];
          final rightPlot =
          rightIndex < productList.length ? productList[rightIndex] : null;

          return Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: Row(
              children: [
                Expanded(child: _buildAnimatedPlotCard(leftPlot, leftIndex)),
                SizedBox(width: 10.w),
                Expanded(
                  child: rightPlot != null
                      ? _buildAnimatedPlotCard(rightPlot, rightIndex)
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          );
        },
      );
    });
  }

  Widget _buildAnimatedPlotCard(MarketPlot plot, int index) {
    return PropertyCard(
      imageUrl: plot.images.isNotEmpty ? plot.images[0] : '',
      title: plot.name,
      soldStatus: plot.soldStatus,
      price: plot.formattedPrice,
      area: plot.formattedArea,
      location: plot.location,
      description: plot.description,
      onTap: () {
        Get.toNamed(
          AppRoutes.plotMarketDetails,
          arguments: {"id": plot.id, "title": plot.name},
        );
      },
    )
        .animate()
        .scale(
      begin: const Offset(0.8, 0.8),
      end: const Offset(1, 1),
      duration: 600.ms,
      curve: Curves.easeOutBack,
    )
        .fadeIn(duration: 500.ms)
        .slide(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
      duration: 600.ms,
      curve: Curves.easeOutCubic,
    )
        .then(delay: (index % 6 * 100).ms)
        .shimmer(duration: 1000.ms, color: Colors.white.withOpacity(0.2));
  }
}