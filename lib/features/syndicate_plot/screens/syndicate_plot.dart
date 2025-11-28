import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/widget/appbar.dart';
import '../../../common/widget/loader.dart';
import '../controller/syndicate_controller.dart';
import '../widget/syndicate_plot_list.dart';

class SyndicatePlot extends StatefulWidget {
  const SyndicatePlot({super.key});

  @override
  State<SyndicatePlot> createState() => _SyndicatePlotState();
}

class _SyndicatePlotState extends State<SyndicatePlot> {
  final SyndicatePlotController controller = Get.put(SyndicatePlotController());

  @override
  void initState() {
    super.initState();
    // Fetch data when the widget is initialized
    controller.fetchSyndicatePlots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DynamicAppBar(
        title: "Syndicate Plots",
        showBackButton: true,
      ),
      body: Obx(() {
        // Show loader until data is loaded
        if (controller.isLoading.value) {
          return const Center(child: GifLoader(message: "Loading...", size: 100));
        }

        // Show content when data is loaded
        return _buildContent();
      }),
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