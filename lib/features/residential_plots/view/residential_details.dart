import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../common/colours.dart';
import '../../../common/widget/appbar.dart';
import '../../../common/widget/loader.dart';
import '../controller/residential_controller.dart';
import '../widget/3d_viewer.dart';
import '../widget/about_residential.dart';
import '../widget/nearby_residential.dart';

class ResidentialPlotDetailsScreen extends StatefulWidget {
  final int? propertyId;
  final String? propertyTitle;
  const ResidentialPlotDetailsScreen({super.key, this.propertyId, this.propertyTitle});

  @override
  State<ResidentialPlotDetailsScreen> createState() => _ResidentialPlotDetailsScreenState();
}

class _ResidentialPlotDetailsScreenState extends State<ResidentialPlotDetailsScreen> {
  final ResidentialPropertyController controller = Get.find<ResidentialPropertyController>();
  @override
  void initState() {
    super.initState();
    controller.enquirySent.value =false;
    if (widget.propertyId != null) {
      controller.fetchPropertyDetail(widget.propertyId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DynamicAppBar(
        title: widget.propertyTitle ?? "Property Details",
        showBackButton: true,
      ),
      body: Obx(() {
        if (controller.isLoadingDetail.value) {
          return const Center(child: GifLoader(message: "Loading plot details...", size: 100));
        }
        if (controller.propertyDetail.value == null) {
          return _buildNoDataAvailable();
        }
        return Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  AboutResidentialProperty(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: NearbyProject(),
                  ),
                  Property3DImageViewer(),
                  SizedBox(height: 60.h),
                ],
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
          Icon(Icons.home_work_outlined, size: 80, color: Colors.grey[400]),
          SizedBox(height: 16.h),
          Text(
            "Property Details Not Available",
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "The property information could not be loaded",
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: () {
              if (widget.propertyId != null) {
                controller.fetchPropertyDetail(widget.propertyId!);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF819E4F),
              padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
            ),
            child: Text(
              "Retry",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}