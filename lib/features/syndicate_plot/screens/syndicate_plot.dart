import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/widget/appbar.dart';
import '../../../common/widget/loader.dart';
import '../controller/syndicate_controller.dart';
import '../widget/syndicate_plot_list.dart';

class SyndicatePlot extends StatelessWidget {
  const SyndicatePlot({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SyndicatePlotController>(
      init: SyndicatePlotController(),
      builder: (controller) {
        return Scaffold(
          appBar: DynamicAppBar(
            title: "Syndicate Plots",
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
          child: SyndicatePlotList(),
        ),
      ],
    );
  }
}