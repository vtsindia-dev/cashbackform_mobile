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
  GiooDetails({super.key, this.id});

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
        title: "Plots Details",
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

        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: buyers.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final buyer = buyers[index] as Map<String, dynamic>;

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 26,
                    backgroundImage: buyer['avatar'] != null &&
                        buyer['avatar'].toString().isNotEmpty
                        ? NetworkImage(buyer['avatar'])
                        : null,
                    child: buyer['avatar'] == null
                        ? const Icon(Icons.person)
                        : null,
                  ),

                  const SizedBox(width: 12),

                  // Name + Email
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          buyer['name'] ?? 'Unknown',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          buyer['email'] ?? '',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Phone icon
                  if (buyer['phone'] != null)
                    IconButton(
                      icon: const Icon(Icons.call, size: 20),
                      onPressed: () {
                        launchUrl(
                          Uri.parse('tel:${buyer['phone']}'),
                        );
                      },
                    ),
                ],
              ),
            );
          },
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