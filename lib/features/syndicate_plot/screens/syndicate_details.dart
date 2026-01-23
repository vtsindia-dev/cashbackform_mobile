import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
  final String? title;
  SyndicateDetails({super.key, this.id,  this.title});

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
        title: widget.title ?? 'Plots Details',
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
                    Description(),
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

  Widget Description(){
    bool isExpanded = false;
    int maxLines = 3; // Show only 3 lines initially

    return StatefulBuilder(
      builder: (context, setState) {
        final description = controller.syndicateDetail.value?.description ?? "";

        // Check if text needs "Show More" option
        final textSpan = TextSpan(
          text: description,
          style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade800),
        );
        final textPainter = TextPainter(
          text: textSpan,
          maxLines: maxLines,
          textDirection: TextDirection.ltr,
        );
        textPainter.layout(maxWidth: MediaQuery.of(context).size.width - 40); // Account for padding
        final needsExpansion = textPainter.didExceedMaxLines;

        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Description",
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (description.isNotEmpty && needsExpansion)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isExpanded = !isExpanded;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.green.shade100, width: 1),
                        ),
                        child: Text(
                          isExpanded ? "Show Less" : "Show More",
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.green.shade800,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 10),
              Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 1,
                      offset: Offset(0, 1),
                    ),
                  ],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      description,
                      maxLines: isExpanded ? null : maxLines,
                      overflow: isExpanded ? null : TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey.shade800,
                        height: 1.5,
                      ),
                    ),
                    if (!isExpanded && description.isNotEmpty && needsExpansion)
                      SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
        );
      },
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