import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/widget/appbar.dart';
import '../../../common/widget/loader.dart';
import '../controller/gioo_controller.dart';
import '../widget/gioo_plot_list.dart';

class Giooplot extends StatelessWidget {
  const Giooplot({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GiooPlotController>(
      init: GiooPlotController(),
      builder: (controller) {
        return Scaffold(
          appBar: DynamicAppBar(
            title: "Gioo Plots",
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
          child: GiooPlotList(),
        ),
      ],
    );
  }
}