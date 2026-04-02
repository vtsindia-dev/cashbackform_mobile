import 'package:flutter/material.dart';
import 'package:cashback_farms/features/plot_market/model/plot_market.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CommonFacilityWidget extends StatefulWidget {
  final MarketPlotDetail? marketPlotDetail;

  const CommonFacilityWidget({
    super.key,
    required this.marketPlotDetail,
  });

  @override
  State<CommonFacilityWidget> createState() =>
      _CommonFacilityWidgetState();
}

class _CommonFacilityWidgetState
    extends State<CommonFacilityWidget> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final facilities =
        widget.marketPlotDetail?.commonFacility ?? [];

    if (facilities.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 10, 12),
          child: Text(
            "Common Facilities",
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF2D3436),
            ),
          ),
        ),
        SizedBox(
          height: 125,
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(), // manual scroll
            padding: const EdgeInsets.symmetric(horizontal: 15),
            itemCount: facilities.length,
            itemBuilder: (context, index) {
              final item = facilities[index];
              return _buildFacilityCard(item);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFacilityCard(dynamic item) {
    return Container(
      width: 100,
      margin:
      const EdgeInsets.only(right: 12, bottom: 8, top: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment:
        MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: ClipRRect(
              borderRadius:
              BorderRadius.circular(4),
              child: Image.network(
                item.image ?? '',
                height: 32,
                width: 32,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(
                  Icons.bolt,
                  color: Colors.green,
                  size: 28,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              item.title ?? '',
              textAlign: TextAlign.center,
              maxLines: 2,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}