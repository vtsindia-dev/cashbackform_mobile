import 'package:cashback_farms/common/route/router.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../Properties/widget/property_card.dart';
import '../controller/plot_market_controller.dart';
import '../model/plot_market.dart';

class PlotMarketList extends StatelessWidget {
  final PlotMarketController controller = Get.put(PlotMarketController());

  PlotMarketList({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.marketPlots.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.marketPlots.isEmpty) {
        return const Center(child: Text('No market plots found'));
      }

      return NotificationListener<ScrollNotification>(
        onNotification: (scrollNotification) {
          if (scrollNotification is ScrollEndNotification) {
            final metrics = scrollNotification.metrics;
            if (metrics.atEdge && metrics.pixels != 0) {
              controller.loadMore();
            }
          }
          return false;
        },
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _getCrossAxisCount(),
                  crossAxisSpacing: 12.w,
                  mainAxisSpacing: 12.h,
                  childAspectRatio: _getChildAspectRatio(),
                ),
                padding: EdgeInsets.all(16.r),
                itemCount: controller.marketPlots.length + (controller.hasMoreData.value ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == controller.marketPlots.length) {
                    return _buildLoadMoreButton();
                  }

                  final plot = controller.marketPlots[index];

                  return _buildAnimatedPlotCard(plot, index);
                },
              ),
            ),
            if (controller.isLoadMore.value)
              Padding(
                padding: EdgeInsets.all(16.r),
                child: const CircularProgressIndicator(),
              ),
          ],
        ),
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
        Get.toNamed(AppRoutes.plotMarketDetails, arguments: {"id": plot.id, "title": plot.name});
      },
    )
        .animate()
        .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1), duration: 600.ms, curve: Curves.easeOutBack)
        .fadeIn(duration: 500.ms)
        .slide(begin: const Offset(0, 0.3), end: Offset.zero, duration: 600.ms, curve: Curves.easeOutCubic)
        .then(delay: (index % 6 * 100).ms)
        .shimmer(duration: 1000.ms, color: Colors.white.withOpacity(0.2));
  }

  Widget _buildLoadMoreButton() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: controller.isLoadMore.value
            ? const CircularProgressIndicator()
            : ElevatedButton(
          onPressed: controller.loadMore,
          child: const Text('Load More'),
        )
            .animate()
            .fadeIn(duration: 400.ms)
            .scale(begin: const Offset(0.9, 0.9), duration: 400.ms),
      ),
    );
  }

  int _getCrossAxisCount() {
    if (1.sw > 1200) return 4;
    if (1.sw > 800) return 3;
    if (1.sw > 600) return 2;
    return 2;
  }

  double _getChildAspectRatio() {
    if (1.sw > 1200) return 0.8;
    if (1.sw > 800) return 0.75;
    if (1.sw > 600) return 0.7;
    return 0.71;
  }
}