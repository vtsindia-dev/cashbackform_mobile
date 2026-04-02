import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import '../../model/plot_market.dart';

class MapSetWidget extends StatefulWidget {
  final List<MapSet> mapSet;
  final double currentLat;
  final double currentLong;
  final String currentPropertyName;

  const MapSetWidget({
    super.key,
    required this.mapSet,
    required this.currentLat,
    required this.currentLong,
    required this.currentPropertyName,
  });

  @override
  State<MapSetWidget> createState() => _MapSetWidgetState();
}

class _MapSetWidgetState extends State<MapSetWidget> {
  GoogleMapController? _mapController;
  final PageController _pageController = PageController(viewportFraction: 0.85);
  Map<MarkerId, Marker> _markers = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCustomMarkers();
  }

  Future<void> _loadCustomMarkers() async {
    final Map<MarkerId, Marker> newMarkers = {};

    // 1. Current Location Marker
    newMarkers[const MarkerId('current_loc')] = Marker(
      markerId: const MarkerId('current_loc'),
      position: LatLng(widget.currentLat, widget.currentLong),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      infoWindow: InfoWindow(title: widget.currentPropertyName),
      zIndex: 2,
    );

    // 2. Property Markers with Images
    for (int i = 0; i < widget.mapSet.length; i++) {
      final p = widget.mapSet[i];
      final lat = double.tryParse(p.lat);
      final lng = double.tryParse(p.long);

      if (lat != null && lng != null) {
        try {
          final markerIcon = await _getRemoteMarkerIcon(p.firstImage);
          final mId = MarkerId(p.id.toString());
          newMarkers[mId] = Marker(
            markerId: mId,
            position: LatLng(lat, lng),
            icon: markerIcon,
            onTap: () => _pageController.animateToPage(i,
                duration: const Duration(milliseconds: 500), curve: Curves.easeInOut),
          );
        } catch (e) {
          // Fallback to default marker if image fails
          newMarkers[MarkerId(p.id.toString())] = Marker(
            markerId: MarkerId(p.id.toString()),
            position: LatLng(lat, lng),
          );
        }
      }
    }

    if (mounted) {
      setState(() {
        _markers = newMarkers;
        _isLoading = false;
      });
    }
  }

  Future<BitmapDescriptor> _getRemoteMarkerIcon(String url) async {
    const int size = 120;
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint()..color = Colors.white;
    final double radius = size / 2;

    canvas.drawCircle(Offset(radius, radius), radius, paint);

    final Uint8List imageBytes = await _fetchImage(url);
    final ui.Codec codec = await ui.instantiateImageCodec(
        imageBytes,
        targetWidth: size,
        targetHeight: size
    );
    final ui.FrameInfo fi = await codec.getNextFrame();

    Path path = Path()..addOval(Rect.fromLTWH(6, 6, size - 12, size - 12));
    canvas.clipPath(path);
    canvas.drawImage(fi.image, const Offset(0, 0), Paint());

    final ui.Image markerAsImage = await pictureRecorder.endRecording().toImage(size, size);
    final ByteData? byteData = await markerAsImage.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }

  Future<Uint8List> _fetchImage(String url) async {
    final Uri uri = Uri.parse(url);
    final HttpClient httpClient = HttpClient();
    final HttpClientRequest request = await httpClient.getUrl(uri);
    final HttpClientResponse response = await request.close();
    return consolidateHttpClientResponseBytes(response);
  }

  void _onPageChanged(int index) {
    final p = widget.mapSet[index];
    final lat = double.tryParse(p.lat);
    final lng = double.tryParse(p.long);
    if (lat != null && lng != null) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(lat, lng), 15),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: 260.h,
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      height: 260.h,
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24.r),
            child: GoogleMap(
              onMapCreated: (c) => _mapController = c,
              initialCameraPosition: CameraPosition(
                target: LatLng(widget.currentLat, widget.currentLong),
                zoom: 13,
              ),
              markers: _markers.values.toSet(),
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
              mapToolbarEnabled: false,
            ),
          ),

          // Zoom & Fullscreen Controls
          Positioned(
            right: 12.w,
            top: 12.h,
            child: _buildMapActions(),
          ),

          // Bottom Preview Slider
          Positioned(
            bottom: 12.h,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 70.h, // Increased slightly to prevent overflow
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: widget.mapSet.length,
                itemBuilder: (context, index) => _buildCompactCard(widget.mapSet[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapActions() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _actionBtn(Icons.fullscreen, () => _openFullScreenMap()),
          const Divider(height: 1, indent: 5, endIndent: 5),
          _actionBtn(Icons.add, () => _mapController?.animateCamera(CameraUpdate.zoomIn())),
          const Divider(height: 1, indent: 5, endIndent: 5),
          _actionBtn(Icons.remove, () => _mapController?.animateCamera(CameraUpdate.zoomOut())),
        ],
      ),
    );
  }

  Widget _actionBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Icon(icon, size: 20.sp, color: Colors.black87),
      ),
    );
  }

  void _openFullScreenMap() {
    Get.to(() => Scaffold(
      appBar: AppBar(
        title: Text(widget.currentPropertyName, style: TextStyle(fontSize: 16.sp)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(widget.currentLat, widget.currentLong),
              zoom: 13,
            ),
            markers: _markers.values.toSet(),
            myLocationButtonEnabled: true,
          ),
          Positioned(
            bottom: 24.h,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 75.h,
              child: PageView.builder(
                controller: PageController(viewportFraction: 0.85),
                itemCount: widget.mapSet.length,
                itemBuilder: (context, index) => _buildCompactCard(widget.mapSet[index]),
              ),
            ),
          )
        ],
      ),
    ));
  }

  Widget _buildCompactCard(MapSet property) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.w),
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6)],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: Image.network(
              property.firstImage,
              width: 50.w,
              height: 50.w,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 50.w, height: 50.w, color: Colors.grey[200],
                child: Icon(Icons.apartment, size: 20.sp, color: Colors.grey),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // FIX: Avoid vertical overflow
              children: [
                Flexible(
                  child: Text(
                    property.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  property.distance,
                  maxLines: 1,
                  style: TextStyle(fontSize: 11.sp, color: Colors.blueAccent, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, size: 18.sp, color: Colors.grey[300]),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _pageController.dispose();
    super.dispose();
  }
}