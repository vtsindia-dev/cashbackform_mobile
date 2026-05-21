import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:panorama_viewer/panorama_viewer.dart';
import 'package:cashback_farms/features/plot_market/model/plot_market.dart';

class Plot360ViewWidget extends StatefulWidget {
  final MarketPlotDetail? marketPlotDetail;
  const Plot360ViewWidget({super.key, required this.marketPlotDetail});

  @override
  State<Plot360ViewWidget> createState() => _Plot360ViewWidgetState();
}

class _Plot360ViewWidgetState extends State<Plot360ViewWidget> {
  bool _isInteracted = false;

  void _onInteractionStarted() {
    if (!_isInteracted) {
      setState(() {
        _isInteracted = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String imageUrl = widget.marketPlotDetail?.threeDImage ?? "";

    if (imageUrl.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 12.h),
          child: Row(
            children: [
              const Icon(Icons.view_in_ar, color: Color(0xFF689F00), size: 20),
              SizedBox(width: 8.w),
              Text(
                "Aerial View",
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF2D3436),
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 200.h,
          margin: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                PanoramaViewer(
                  animSpeed: _isInteracted ? 0.0 : 1.0,
                  sensorControl: SensorControl.orientation,
                  onTap: (lon, lat, tilt) => _onInteractionStarted(),
                  onLongPressStart: (lon, lat, tilt) => _onInteractionStarted(),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
                if (!_isInteracted)
                  IgnorePointer(
                    child: Container(
                      color: Colors.black26,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.swipe_outlined, color: Colors.white, size: 40),
                            SizedBox(height: 8.h),
                            Text(
                              "Swipe to Explore • Tap to close",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 12.h,
                  right: 12.w,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 500),
                    opacity: _isInteracted ? 0.6 : 1.0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF689F00),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.view_in_ar,
                            color: Colors.white,
                            size: 16.sp,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            "360°",
                            style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}