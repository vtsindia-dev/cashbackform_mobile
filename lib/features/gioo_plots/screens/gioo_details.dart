import 'package:cashback_farms/features/gioo_plots/widget/gio_scheme_overview.dart';
import 'package:cashback_farms/features/menu/controller/dashboard_menu_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/widget/appbar.dart';
import '../../../common/widget/loader.dart';
import '../controller/gioo_controller.dart';
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
  DashboardController dashboardController = Get.put(DashboardController());

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
              GioSchemeOverview(youtubeLink: dashboardController.businessSettings.value?.howItWorkYoutubeLink),
              BluePrint(
                title: "Green Heap Plots Layout Sketch",
                imageUrl: controller.giooPlotDetail.value?.bluePrint,
              ),
              BluePrint(
                title: "GreenHeap Plots Structure Detail",
                imageUrl: controller.giooPlotDetail.value?.plotImage,
              ),
              ReserveSlot(),
              NearbyProject(),
              PlotAvailabilityWidget(),
              buyersList(controller),
              SizedBox(height: 45,)
            ],
          ),
        );
      }),
    );
  }
  Widget buyersList(GiooPlotController controller) {
    final buyers = controller.giooPlotDetail.value?.users ?? [];
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

        if (buyers.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "No buyers yet",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          )
        else
          Container(
            constraints: buyers.length <= 3
                ? null
                : const BoxConstraints(maxHeight: 420),
            child: ListView.separated(
              shrinkWrap: buyers.length <= 3,
              physics: buyers.length <= 3
                  ? const NeverScrollableScrollPhysics()
                  : const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: buyers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final buyer = buyers[index];
                final transactions = buyer.gioTransaction ?? [];

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                        child: Row(
                          children: [

                            CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.grey.shade200,
                              backgroundImage: (buyer.avatar != null &&
                                  buyer.avatar!.isNotEmpty)
                                  ? NetworkImage(buyer.avatar!)
                                  : null,
                              child: (buyer.avatar == null ||
                                  buyer.avatar!.isEmpty)
                                  ? Icon(Icons.person,
                                  size: 22, color: Colors.grey.shade500)
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    buyer.name ?? '—',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  if (buyer.phone != null &&
                                      buyer.phone!.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      _maskedPhone(buyer.phone!),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            if (transactions.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.green.shade200),
                                ),
                                child: Text(
                                  "${transactions.length} txn${transactions.length > 1 ? 's' : ''}",
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (transactions.isNotEmpty) ...[
                        Divider(height: 1, color: Colors.grey.shade100, indent: 14),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
                          itemCount: transactions.length,
                          separatorBuilder: (_, __) => Divider(
                            height: 12,
                            color: Colors.grey.shade100,
                          ),
                          itemBuilder: (context, txIndex) {
                            final tx = transactions[txIndex];
                            final buyingPrice = tx.amount ?? 0;
                            final sellingPrice = tx.afterAmount ?? 0.0;
                            final buyDate = _formatDate(tx.createdAt);
                            final sellDate = _formatDate(tx.afterTwoYear);

                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Buying Price: ₹$buyingPrice",
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        buyDate,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        "Selling Price: ₹${(double.tryParse(sellingPrice.toString()) ?? 0.0).toStringAsFixed(
                                          ((double.tryParse(sellingPrice.toString()) ?? 0.0) % 1 == 0) ? 0 : 1,
                                        )}",
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.green.shade600,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        sellDate,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  String _maskedPhone(String phone) {
    if (phone.length < 6) return phone;
    final visible = 2;
    final masked = phone.length - visible * 2;
    return "Phone: ${phone.substring(0, visible)}${'x' * masked}${phone.substring(phone.length - visible)}";
  }
  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return '—';
    try {
      final utcDate = DateTime.parse(raw).toUtc();
      final localDate = utcDate.toLocal();

      final dd = localDate.day.toString().padLeft(2, '0');
      final mm = localDate.month.toString().padLeft(2, '0');
      final yyyy = localDate.year;

      final hour = localDate.hour;
      final min = localDate.minute.toString().padLeft(2, '0');

      final period = hour >= 12 ? 'PM' : 'AM';
      final h12 = hour % 12 == 0 ? 12 : hour % 12;

      return "$dd/$mm/$yyyy ${h12.toString().padLeft(2, '0')}:$min $period";
    } catch (_) {
      return raw;
    }
  }

  Widget _buildNoDataAvailable() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 16),
          Text(
            "No Data  ",
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