import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../Properties/widget/property_card.dart';
import '../controller/gioo_controller.dart';
import '../model/gioo_plot.dart';

class GiooPlotList extends StatelessWidget {
  final controller = Get.find<GiooPlotController>(); // ✅ reuse

  GiooPlotList({super.key});

  @override
  Widget build(BuildContext context) {
    final GiooPlotController controller = Get.find();

    return Obx(() {
      final plots = controller.giooPlots;

      if (controller.isLoading.value && plots.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (plots.isEmpty) {
        return const Center(child: Text('No Gioo plots found'));
      }

      final rowCount = (plots.length / 2).ceil();

      return NotificationListener<ScrollNotification>(
        onNotification: (scroll) {
          if (!controller.hasMoreData.value) return false;

          if (scroll.metrics.pixels >= scroll.metrics.maxScrollExtent * 0.9) {
            controller.loadMore();
          }
          return false;
        },

        child: ListView.builder(
          padding: EdgeInsets.all(16.r),
          itemCount: rowCount + 1,
          itemBuilder: (context, index) {
            if (index == rowCount) {
              return controller.isLoadMore.value
                  ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: CircularProgressIndicator()),
              )
                  : const SizedBox.shrink();
            }

            final leftIndex = index * 2;
            final rightIndex = leftIndex + 1;

            final leftPlot = plots[leftIndex];
            final rightPlot = rightIndex < plots.length ? plots[rightIndex] : null;

            return Row(
              children: [
                Expanded(child: _buildAnimatedPlotCard(leftPlot)),
                SizedBox(width: 12.w),
                Expanded(
                    child: rightPlot != null
                        ? _buildAnimatedPlotCard(rightPlot)
                        : const SizedBox.shrink()),
              ],
            );
          },
        ),
      );
    });
  }

  String getSingleImage(List<String> images) {
    return images.firstWhere(
          (url) {
        final lower = url.toLowerCase();
        return lower.endsWith('.jpg') ||
            lower.endsWith('.jpeg') ||
            lower.endsWith('.png') ||
            lower.endsWith('.webp');
      },
      orElse: () => '',
    );
  }
  Widget _buildAnimatedPlotCard(GiooPlot plot) {
    final imageUrl = getSingleImage(plot.images);
    return PropertyCard(
      imageUrl: imageUrl,
      title: plot.name,
      price: plot.formattedPrice,
      area: plot.formattedArea,
      location: plot.location,
      description: plot.description,
      onTap: () {
        print("View Gioo Plot: ${plot.name}");
        Get.toNamed('/giooDetails', arguments: {"id": plot.id, "title": plot.name});

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
        .shimmer(
      duration: 1000.ms,
      color: Colors.white.withOpacity(0.2),
    );
  }
}