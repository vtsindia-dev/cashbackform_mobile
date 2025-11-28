import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';

import '../../../common/widget/appbar.dart';
import '../../../common/widget/loader.dart';
import '../../gioo_plots/controller/gioo_controller.dart';
import '../../gioo_plots/widget/gioo_plot_list.dart';
import '../widget/service_list.dart';
class Service extends StatefulWidget {
  const Service({super.key});

  @override
  State<Service> createState() => _MaterialStoreState();
}

class _MaterialStoreState extends State<Service> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<GiooPlotController>(
      init: GiooPlotController(),
      builder: (controller) {
      return Scaffold(
        appBar: DynamicAppBar(
          title: "Service",
          showBackButton: true,
        ),
        body: controller.isLoading.value
            ? const Center(child: GifLoader(message: "Loading...", size: 100))
            : _buildContent(),
      );
      },
    );
  }
}

Widget _buildContent() {
  return Column(
    children: [
      Expanded(
        child: ServiceList(),
      ),
    ],
  );
}
