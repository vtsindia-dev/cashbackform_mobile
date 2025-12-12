import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/widget/appbar.dart';
import '../../../common/widget/loader.dart';
import '../../home/widget/sub_title.dart';
import '../controller/syndicate_controller.dart';
import '../model/syndicate_model.dart';
import '../widget/about_plot.dart';
import '../widget/legal_docments.dart';
import '../widget/referals.dart';
import '../widget/reserve_plots.dart';
import '../widget/scheme_overview.dart';

class SyndicateDetails extends StatefulWidget {
  final int? id;
  SyndicateDetails({super.key, this.id});

  @override
  State<SyndicateDetails> createState() => _SyndicateDetailsState();
}

class _SyndicateDetailsState extends State<SyndicateDetails> {
  final SyndicatePlotController controller = Get.put(SyndicatePlotController());
  final GlobalKey _reserveButtonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    if (widget.id != null) {
      controller.fetchSyndicateDetail(widget.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DynamicAppBar(
        title: "Plots Details",
        showBackButton: true,
      ),
      body: Obx(() {
        if (controller.isLoadingDetail.value) {
          return const Center(child: GifLoader(message: "Loading...", size: 100));
        }
        if (controller.syndicateDetail.value == null) {
          return _buildNoDataAvailable();
        }
        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    AboutPlot(),
                    SchemeOverview(),
                    ReservePlotsScreen(reserveButtonKey: _reserveButtonKey), // Pass the key
                    LegalDocumentsScreen(),
                    Referrals(reservePlotsKey: _reserveButtonKey), // Pass the same key
                    SizedBox(height: 45,)
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildNoDataAvailable() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 16),
          Text(
            "No Data Available",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (widget.id != null) {
                controller.fetchSyndicateDetail(widget.id!);
              }
            },
            child: Text("Retry"),
          ),
        ],
      ),
    );
  }
}