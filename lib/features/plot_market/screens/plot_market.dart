import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/widget/appbar.dart';
import '../../../common/widget/loader.dart';
import '../controller/plot_market_controller.dart';
import '../widget/plot_market_list.dart';

class PlotMarket extends StatelessWidget {
  const PlotMarket({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PlotMarketController>(
      init: PlotMarketController(),
      builder: (controller) {
        return Scaffold(
          appBar: DynamicAppBar(
            title: "Plot Market",
            showBackButton: true,
          ),
          body: controller.isLoading.value
              ? const Center(child: GifLoader(message: "Loading...", size: 100))
              : _buildContent(),
        );
      },
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        Expanded(
          child: PlotMarketList(),
        ),
      ],
    );
  }
}