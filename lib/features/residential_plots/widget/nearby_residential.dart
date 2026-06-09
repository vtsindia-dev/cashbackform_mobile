import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../common/colours.dart';
import '../../../common/widget/view_on_map_button.dart';
import '../controller/residential_controller.dart';
import '../model/residential_model.dart';

class NearbyProject extends StatefulWidget {
  const NearbyProject({super.key});
  @override
  State<NearbyProject> createState() => _NearbyProjectState();
}
class _NearbyProjectState extends State<NearbyProject> with SingleTickerProviderStateMixin {
  final ResidentialPropertyController controller = Get.find<ResidentialPropertyController>();
  final ScrollController _scrollController = ScrollController();
  late final AnimationController _ticker;
  bool _isReversing = false;
  double _scrollProgress = 0.0;
  @override
  void initState() {
    super.initState();
    _ticker = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 100000), // very long duration
    )..addListener(_autoScrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ticker.repeat();
    });
  }
  void _autoScrollListener() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    if (maxScroll == 0) return;
    final property = controller.propertyDetail.value;
    final itemCount = property?.nearbyLocations.length ?? 1;
    double baseSpeed = 1.5;
    double adjustedSpeed;
    if (itemCount <= 2) {
      adjustedSpeed = baseSpeed * 0.3;
    } else if (itemCount <= 4) {
      adjustedSpeed = baseSpeed * 0.6;
    } else {
      adjustedSpeed = baseSpeed;
    }
    double nextOffset = _scrollController.offset + (_isReversing ? -adjustedSpeed : adjustedSpeed);
    double buffer = 20.0;

    if (nextOffset >= maxScroll - buffer) {
      nextOffset = maxScroll - buffer;
      if (!_isReversing) {
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            _isReversing = true;
          }
        });
      }
    } else if (nextOffset <= buffer) {
      nextOffset = buffer;
      if (_isReversing) {
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            _isReversing = false;
          }
        });
      }
    }
    _scrollController.jumpTo(nextOffset);
    setState(() {
      _scrollProgress = (nextOffset / maxScroll).clamp(0.0, 1.0);
    });
  }
  @override
  void dispose() {
    _ticker.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  String _safeString(dynamic value) => value?.toString() ?? '';

  Future<void> _launchGoogleMaps(dynamic lat, dynamic lng) async {
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final property = controller.propertyDetail.value;
      if (property == null) return const SizedBox.shrink();
      final locations = [...property.nearbyLocations]
        ..sort((a, b) {
          final distA = double.tryParse(_safeString(a.pivot?.distance)) ?? 9999;
          final distB = double.tryParse(_safeString(b.pivot?.distance)) ?? 9999;
          return distA.compareTo(distB);
        });
      final itemCount = locations.length;
      final cardWidth = itemCount <= 2 ? 250.w : 190.w;
      final margin = itemCount <= 2 ? 20.w : 16.w;
      return Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(0.w),
              child: Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColor.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.location_on, color: AppColor.primary, size: 22.sp),
                        8.w.horizontalSpace,
                        Text(
                          "Property Location",
                          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w900, color: Colors.black),
                        ),
                        const Spacer(),
                        ViewOnMapButton(
                          onTap: () => _launchGoogleMaps(property.lat, property.lng),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      _safeString(property.location),
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                "Nearby Places",
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900, color: AppColor.textMain),
              ),
            ),
            SizedBox(
              height: 200.h,
              child: Stack(
                children: [
                  Positioned(
                    top: 50.h,
                    left: 20.w,
                    right: 20.w,
                    child: Container(height: 3.h, color: Colors.grey.shade200),
                  ),
                  Positioned(
                    top: 50.h,
                    left: 20.w,
                    child: Container(
                      height: 3.h,
                      width: (1.sw - 40.w) * _scrollProgress,
                      color: AppColor.primary,
                    ),
                  ),
                  Positioned(
                    left: (1.sw - 80.w) * _scrollProgress + 15.w,
                    top: 2.h,
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.rotationY(_isReversing ? 3.14159 : 0),
                      child: SizedBox(
                        width: 70.w,
                        height: 70.w,
                        child: Lottie.asset(
                          'assets/images/running_animation.json',
                          repeat: true,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 42.h),
                    child: ListView.builder(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                      itemCount: locations.length,
                      itemBuilder: (context, index) => _buildBolderRowCard(
                        locations[index],
                        cardWidth: cardWidth,
                        margin: margin,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
  Widget _buildBolderRowCard(NearbyLocation loc, {required double cardWidth, required double margin}) {
    return Container(
      width: cardWidth,
      margin: EdgeInsets.only(right: margin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dot on line
          Container(
            width: 14.w,
            height: 14.w,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColor.primary, width: 3),
              boxShadow: [BoxShadow(color: AppColor.primary.withOpacity(0.3), blurRadius: 4)],
            ),
          ),
          15.h.verticalSpace,
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15.r),
              border: Border.all(color: Colors.grey.shade100, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 15,
                  spreadRadius: 1,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 45.w,
                  height: 45.w,
                  decoration: BoxDecoration(

                    borderRadius: BorderRadius.circular(10.r),
                    color: AppColor.primary.withOpacity(0.1),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.r),
                    child: _safeString(loc.image).isNotEmpty
                        ? Image.network(_safeString(loc.image), fit: BoxFit.cover)
                        : Icon(Icons.business_rounded, color: AppColor.primary),
                  ),
                ),
                12.w.horizontalSpace,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _safeString(loc.title),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w900, color: Colors.black),
                      ),
                      Text(
                        '${loc.pivot?.distance ?? '--'} KM',
                        style: TextStyle(fontSize: 11.sp, color: AppColor.primary, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}