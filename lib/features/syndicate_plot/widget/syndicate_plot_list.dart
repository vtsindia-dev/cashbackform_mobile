import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../Properties/widget/property_card.dart';
import '../controller/syndicate_controller.dart';
import '../model/syndicate_model.dart';

class SyndicatePlotList extends StatelessWidget {
  final SyndicatePlotController controller = Get.put(SyndicatePlotController());

  SyndicatePlotList({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(()

    {
      final plots = controller.syndicatePlots;
      if (controller.isLoading.value && plots.isEmpty) {
        return const Expanded(child: Center(child: CircularProgressIndicator()));
      }
      if (plots.isEmpty) {
        return const Expanded(
          child: Center(child: Text("No syndicate plots found")),
        );
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
          padding: const EdgeInsets.all(16),
          itemCount: rowCount + 1,
          itemBuilder: (context, index) {
            if (index == rowCount) {
              return controller.isLoadMore.value
                  ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: SizedBox.shrink()),
              )
                  : const SizedBox.shrink();
            }

            final leftIndex = index * 2;
            final rightIndex = leftIndex + 1;
            final leftPlot = plots[leftIndex];
            final rightPlot =
            rightIndex < plots.length ? plots[rightIndex] : null;
            return Row(
              children: [
                Expanded(child: _buildCardAnimated(leftPlot, leftIndex)),
                const SizedBox(width: 12),
                Expanded(
                  child: rightPlot != null
                      ? _buildCardAnimated(rightPlot, rightIndex)
                      : const SizedBox.shrink(),
                ),
              ],
            );
          },
        ),
      );
    });
  }

  Widget _buildCardAnimated(SyndicatePlot plot, int index) {
    return PropertyCard(
      imageUrl: plot.images.isNotEmpty ? plot.images[0] :'',
      title: plot.name,
      price: plot.formattedPrice,
      area: plot.formattedArea,
      location: plot.location,
      description: plot.description,
      soldStatus: plot.soldStatus,
      onTap: () {
        Get.toNamed('/syndicateDetails', arguments: {"id": plot.id, "title": plot.name,});
      },
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slide(begin: const Offset(0, 0.2), duration: 500.ms)
        .scale(begin: const Offset(0.9, 0.9), duration: 500.ms);
  }
}