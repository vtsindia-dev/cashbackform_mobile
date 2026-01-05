import 'package:cashback_farms/features/gioo_plots/widget/gio_scheme_overview.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../common/widget/appbar.dart';
import '../../../common/widget/loader.dart';
import '../../home/widget/sub_title.dart';
import '../../syndicate_plot/widget/scheme_overview.dart';
import '../controller/gioo_controller.dart';
import '../model/gioo_plot.dart' show User;
import '../widget/about_plot.dart';
import '../widget/blue_print.dart';
import '../widget/neraby_project.dart';
import '../widget/plot_availability.dart';
import '../widget/reserve_slot.dart';

class GiooDetails extends StatefulWidget {
  final int? id;
  final String? title;
  GiooDetails({super.key, this.id,  this.title});

  @override
  State<GiooDetails> createState() => _GiooDetailsState();
}

class _GiooDetailsState extends State<GiooDetails> {
  final GiooPlotController controller = Get.put(GiooPlotController());


  @override
  void initState() {
    super.initState();
    if (widget.id != null) {
      controller.fetchGiooPlotDetail(widget.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DynamicAppBar(
        title: widget.title??'Plot Details',
        showBackButton: true,
      ),
      body: Obx(() {
        if (controller.isLoadingDetail.value) {
          return const Center(child: GifLoader(message: "Loading...", size: 100));
        }
        if (controller.giooPlotDetail.value == null) {
          return _buildNoDataAvailable();
        }
        return SingleChildScrollView(
          child: Column(
            children: [
              AboutGiooPlot(),
              PlotAvailabilityWidget(),
              NearbyProject(),
              GioSchemeOverview(),
              buyersList(controller),
              BluePrint(),
              ReserveSlot(),

              SizedBox(height: 45,)
            ],
          ),
        );
      }),
    );
  }
  Widget buyersList(GiooPlotController controller) {
    final buyers = controller.giooPlotDetail.value?.users ?? [];

    if (buyers.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          "No buyers yet",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    // 🔥 dynamic values
    final int visibleCount = buyers.length > 4 ? 4 : buyers.length;
    const double itemHeight = 60;
    const double separatorHeight = 8;

    final double listHeight =
        (visibleCount * itemHeight) +
            ((visibleCount - 1) * separatorHeight);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            "Our Buyers List",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        /// 🔥 DYNAMIC HEIGHT LIST
        SizedBox(
          height: listHeight,
          child: ListView.separated(
            physics: buyers.length > 4
                ? const BouncingScrollPhysics()
                : const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: visibleCount,
            separatorBuilder: (_, __) =>
            const SizedBox(height: separatorHeight),
            itemBuilder: (context, index) {
              final buyer = buyers[index];

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    /// Avatar
                    CircleAvatar(
                      radius: 22,
                      backgroundImage:
                      buyer.avatar != null && buyer.avatar!.isNotEmpty
                          ? NetworkImage(buyer.avatar!)
                          : null,
                      child: buyer.avatar == null
                          ? const Icon(Icons.person, size: 20)
                          : null,
                    ),

                    const SizedBox(width: 10),

                    /// Name + Email
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            buyer.name ?? 'Unknown',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            buyer.email ?? '',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Avatar fallback
  Widget _avatarFallback() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.person, color: Colors.white),
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
                controller.fetchGiooPlotDetail(widget.id!);

              }
            },
            child: Text("Retry"),
          ),
        ],
      ),
    );
  }
}