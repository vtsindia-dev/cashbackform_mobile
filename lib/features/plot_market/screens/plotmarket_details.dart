import 'package:cashback_farms/features/plot_market/widget/about_plot.dart';
import 'package:cashback_farms/features/plot_market/widget/plotmarket_details_widgets/common_facility_widget.dart';
import 'package:cashback_farms/features/plot_market/widget/plotmarket_details_widgets/description_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/widget/appbar.dart';
import '../../../common/widget/loader.dart';
import '../../syndicate_plot/widget/scheme_overview.dart';
import '../controller/plot_market_controller.dart';
import '../widget/plot_market_blueprint.dart';
import '../widget/plotmarket_details_widgets/three_d_image_view_widget.dart';
import '../widget/plotmarket_document.dart' show LegalDocumentsScreen;
import '../widget/plotmarket_nearby.dart';


class PlotMarketDetails extends StatefulWidget {
  final int? id;
  final String? title;
  const PlotMarketDetails({super.key, this.id, this.title});

  @override
  State<PlotMarketDetails> createState() => _PlotMarketDetailsState();
}

class _PlotMarketDetailsState extends State<PlotMarketDetails> {
  final PlotMarketController controller = Get.put(PlotMarketController());

  @override
  void initState() {
    super.initState();
    if (widget.id != null) {
      controller.fetchMarketPlotDetail(widget.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DynamicAppBar(
        title: widget.title ?? "Plot Market Details",
        showBackButton: true,
      ),
      body: Obx(() {
        if (controller.isLoadingDetail.value) {
          return const Center(
            child: GifLoader(message: "Loading...", size: 100),
          );
        }

        if (controller.marketDetail.value == null) {
          return _buildNoDataAvailable();
        }
        final detail = controller.marketDetail.value!;
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AboutPlot(),
              NearbyPlotMarket(),
              DescriptionWidget(marketPlotDetail: detail),
              CommonFacilityWidget(marketPlotDetail: detail),
              Plot360ViewWidget(marketPlotDetail: detail),
              PlotMarketBlueprint(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildNoDataAvailable() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          const Text(
            "No Data Available",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (widget.id != null) {
                controller.fetchMarketPlotDetail(widget.id!);
              }
            },
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }
}
