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
import '../model/gioo_plot.dart';
import '../../../common/colours.dart';

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
              _BuyersListSection(buyers: controller.giooPlotDetail.value?.users ?? []),
              SizedBox(height: 45,)
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


class _BuyersListSection extends StatefulWidget {
  final List<User> buyers;
  const _BuyersListSection({required this.buyers});

  @override
  State<_BuyersListSection> createState() => _BuyersListSectionState();
}

enum _FilterPeriod { all, days15, month1 }

class _BuyersListSectionState extends State<_BuyersListSection>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  _FilterPeriod _filter = _FilterPeriod.all;
  late final AnimationController _animCtrl;
  late final Animation<double> _expandAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _expandAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    _expanded ? _animCtrl.forward() : _animCtrl.reverse();
  }

  void _setFilter(_FilterPeriod f) {
    if (_filter == f) return;
    setState(() {
      _filter = f;
      _expanded = false;
    });
    _animCtrl.reverse();
  }

  List<User> get _filtered {
    if (_filter == _FilterPeriod.all) return widget.buyers;
    final cutoff = DateTime.now().subtract(
      _filter == _FilterPeriod.days15
          ? const Duration(days: 15)
          : const Duration(days: 30),
    );
    return widget.buyers.where((u) {
      if (u.createdAt == null || u.createdAt!.isEmpty) return false;
      try {
        return DateTime.parse(u.createdAt!).toLocal().isAfter(cutoff);
      } catch (_) {
        return false;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              const Text(
                "Our Buyers List",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    _FilterChip(
                      label: "All",
                      selected: _filter == _FilterPeriod.all,
                      onTap: () => _setFilter(_FilterPeriod.all),
                    ),
                    _FilterChip(
                      label: "15 Days",
                      selected: _filter == _FilterPeriod.days15,
                      onTap: () => _setFilter(_FilterPeriod.days15),
                    ),
                    _FilterChip(
                      label: "1 Month",
                      selected: _filter == _FilterPeriod.month1,
                      onTap: () => _setFilter(_FilterPeriod.month1),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (filtered.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              _filter == _FilterPeriod.all
                  ? "No buyers yet"
                  : "No buyers in this period",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          )
        else ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _BuyerCard(buyer: filtered.first),
          ),
          if (filtered.length > 1) ...[
            SizeTransition(
              sizeFactor: _expandAnim,
              axisAlignment: -1,
              child: FadeTransition(
                opacity: _expandAnim,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      for (int i = 1; i < filtered.length; i++) ...[
                        const SizedBox(height: 12),
                        _BuyerCard(buyer: filtered[i]),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _toggle,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _expanded
                        ? [AppColor.primary.withValues(alpha: 0.12), AppColor.primarylite.withValues(alpha: 0.08)]
                        : [AppColor.primary, AppColor.primarylite],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _expanded ? AppColor.primary : Colors.transparent,
                    width: 1.2,
                  ),
                  boxShadow: _expanded
                      ? []
                      : [
                          BoxShadow(
                            color: AppColor.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 20,
                        color: _expanded ? AppColor.primary : Colors.white,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _expanded
                          ? "Show Less"
                          : "View More  •  ${filtered.length - 1} more",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _expanded ? AppColor.primary : Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? AppColor.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: selected
              ? [BoxShadow(color: AppColor.primary.withValues(alpha: 0.25), blurRadius: 4, offset: const Offset(0, 2))]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}

class _BuyerCard extends StatelessWidget {
  final User buyer;
  const _BuyerCard({required this.buyer});

  String _maskedPhone(String phone) {
    if (phone.length < 6) return phone;
    const visible = 2;
    final masked = phone.length - visible * 2;
    return "Phone: ${phone.substring(0, visible)}${'x' * masked}${phone.substring(phone.length - visible)}";
  }

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return '—';
    try {
      final localDate = DateTime.parse(raw).toUtc().toLocal();
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

  @override
  Widget build(BuildContext context) {
    final transactions = buyer.gioTransaction ?? [];
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
                  backgroundImage: (buyer.avatar != null && buyer.avatar!.isNotEmpty)
                      ? NetworkImage(buyer.avatar!)
                      : null,
                  child: (buyer.avatar == null || buyer.avatar!.isEmpty)
                      ? Icon(Icons.person, size: 22, color: Colors.grey.shade500)
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
                            fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                      if (buyer.phone != null && buyer.phone!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          _maskedPhone(buyer.phone!),
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade600),
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
              separatorBuilder: (_, __) =>
                  Divider(height: 12, color: Colors.grey.shade100),
              itemBuilder: (context, txIndex) {
                final tx = transactions[txIndex];
                final buyingPrice = tx.amount ?? 0;
                final sellingPrice = tx.afterAmount ?? 0.0;
                final sellVal = double.tryParse(sellingPrice.toString()) ?? 0.0;
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
                                color: Colors.black87),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatDate(tx.createdAt),
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "Selling Price: ₹${sellVal.toStringAsFixed(sellVal % 1 == 0 ? 0 : 1)}",
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.green.shade600),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatDate(tx.afterTwoYear),
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey.shade500),
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
  }
}