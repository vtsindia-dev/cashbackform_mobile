import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import '../../../common/colours.dart';
import '../controller/residential_controller.dart';

class Property3DImageViewer extends StatefulWidget {
  const Property3DImageViewer({super.key});
  @override
  State<Property3DImageViewer> createState() => _Property3DImageViewerState();
}

class _Property3DImageViewerState extends State<Property3DImageViewer> {
  final ResidentialPropertyController controller = Get.find<ResidentialPropertyController>();
  double scale = 1.0;
  bool isInteractive = true;

  void _zoomIn() {
    setState(() {
      scale += 0.2;
    });
  }

  void _zoomOut() {
    setState(() {
      scale = (scale - 0.2).clamp(0.5, 5.0);
    });
  }

  void _resetZoom() {
    setState(() {
      scale = 1.0;
    });
  }

  void _toggleInteractive() {
    setState(() {
      isInteractive = !isInteractive;
    });
  }

  bool _is3DModel(String url) {
    final lowerUrl = url.toLowerCase();
    return lowerUrl.endsWith('.glb') ||
        lowerUrl.endsWith('.gltf') ||
        lowerUrl.endsWith('.obj') ||
        lowerUrl.endsWith('.stl') ||
        lowerUrl.endsWith('.fbx') ||
        lowerUrl.endsWith('.usdz');
  }

  bool _isImage(String url) {
    final lowerUrl = url.toLowerCase();
    return lowerUrl.endsWith('.jpg') ||
        lowerUrl.endsWith('.jpeg') ||
        lowerUrl.endsWith('.png') ||
        lowerUrl.endsWith('.gif') ||
        lowerUrl.endsWith('.webp');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      child: Obx(() {
        final property = controller.propertyDetail.value;
        final String? threeDImageUrl = property?.threeDImage ??
            property?.threeDImage ??
            property?.threeDImage ??
            property?.threeDImage;

        final String imageUrl = threeDImageUrl?.isNotEmpty == true
            ? threeDImageUrl!
            : 'https://via.placeholder.com/600x400?text=3D+Image+Not+Available';

        final is3DModel = _is3DModel(imageUrl);
        final isImageFile = _isImage(imageUrl);

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 10.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: AppColor.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(color: AppColor.primary.withOpacity(0.3), width: 1.w),
                      ),
                      child: Text(
                        is3DModel ? 'Aerial View' : 'Aerial View Image',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColor.textMain,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        if (is3DModel)
                          _buildControlButton(
                            icon: isInteractive ? Icons.touch_app : Icons.touch_app_outlined,
                            onTap: _toggleInteractive,
                            tooltip: isInteractive ? 'Disable Interaction' : 'Enable Interaction',
                          ),
                        8.w.horizontalSpace,
                        _buildControlButton(
                          icon: Icons.fullscreen,
                          onTap: () => _openFullscreenView(context, imageUrl, is3DModel),
                          tooltip: 'Fullscreen View',
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // File Type Indicator
              if (is3DModel || isImageFile)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: is3DModel ? Colors.blue.shade100 : Colors.green.shade100,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          is3DModel ? '3D Model File' : 'High-Res Image',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            color: is3DModel ? Colors.blue.shade800 : Colors.green.shade800,
                          ),
                        ),
                      ),
                      8.w.horizontalSpace,
                      Text(
                        _getFileExtension(imageUrl),
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

              // 3D/Image Viewer
              Container(
                height: 280.h,
                width: double.infinity,
                margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: Colors.grey.shade200, width: 1),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: _buildViewer(imageUrl, is3DModel, isImageFile),
                ),
              ),

              // Controls
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                child: _buildControlPanel(),
              ),

              10.h.verticalSpace,
            ],
          ),
        );
      }),
    );
  }

  Widget _buildViewer(String imageUrl, bool is3DModel, bool isImageFile) {
    if (imageUrl.contains('placeholder')) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 50.w,
              color: Colors.grey.shade400,
            ),
            10.h.verticalSpace,
            Text(
              "3D Image Not Available",
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey.shade500,
              ),
            ),
            if (controller.propertyDetail.value != null)
              Padding(
                padding: EdgeInsets.only(top: 10.h),
                child: Text(
                  "Property: ${controller.propertyDetail.value?.propertyName ?? 'N/A'}",
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
          ],
        ),
      );
    }

    if (is3DModel) {
      // For 3D models, show a preview with model viewer
      return _build3DModelPreview(imageUrl);
    } else {
      // For regular images, use PhotoView with zoom
      return PhotoView(
        imageProvider: NetworkImage(imageUrl),
        minScale: PhotoViewComputedScale.contained * 0.8,
        maxScale: PhotoViewComputedScale.covered * 4,
        initialScale: scale,
        enableRotation: isInteractive,
        backgroundDecoration: const BoxDecoration(color: Colors.transparent),
        loadingBuilder: (context, progress) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                value: progress?.expectedTotalBytes != null
                    ? progress!.cumulativeBytesLoaded / progress.expectedTotalBytes!
                    : null,
              ),
              10.h.verticalSpace,
              Text(
                'Loading 3D Image...',
                style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
        errorBuilder: (context, error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 50.w, color: Colors.red.shade400),
              10.h.verticalSpace,
              Text(
                'Failed to load image',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
              ),
              5.h.verticalSpace,
              Text(
                error.toString(),
                style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade500),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _build3DModelPreview(String modelUrl) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.view_in_ar,
          size: 60.w,
          color: Colors.blue.shade400,
        ),
        20.h.verticalSpace,
        Text(
          '3D Model Detected',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade800,
          ),
        ),
        10.h.verticalSpace,
        Text(
          _getFileExtension(modelUrl).toUpperCase(),
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey.shade600,
          ),
        ),
        20.h.verticalSpace,
        ElevatedButton.icon(
          onPressed: () => _open3DModelViewer(modelUrl),
          icon: Icon(Icons.view_in_ar, size: 20.w),
          label: Text('Open 3D Viewer'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade600,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildControlPanel() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildControlItem(
            icon: Icons.zoom_in,
            label: 'Zoom In',
            onTap: _zoomIn,
          ),
          Container(width: 1.w, height: 24.h, color: Colors.grey.shade300),
          _buildControlItem(
            icon: Icons.zoom_out,
            label: 'Zoom Out',
            onTap: _zoomOut,
          ),
          Container(width: 1.w, height: 24.h, color: Colors.grey.shade300),
          _buildControlItem(
            icon: Icons.restore,
            label: 'Reset',
            onTap: _resetZoom,
          ),
        ],
      ),
    );
  }

  Widget _buildControlItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20.w, color: AppColor.textMain),
            4.h.verticalSpace,
            Text(
              label,
              style: TextStyle(
                fontSize: 10.sp,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.r),
        child: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: Colors.grey.shade300, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, size: 20.w, color: AppColor.textMain),
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.blue.shade100, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.w, color: Colors.blue.shade600),
          4.w.horizontalSpace,
          Text(
            text,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: Colors.blue.shade800,
            ),
          ),
        ],
      ),
    );
  }

  String _getFileExtension(String url) {
    try {
      final uri = Uri.parse(url);
      final path = uri.path;
      final extension = path.split('.').last;
      return extension.length <= 5 ? extension : extension.substring(0, 5);
    } catch (e) {
      return 'file';
    }
  }

  void _openFullscreenView(BuildContext context, String imageUrl, bool is3DModel) {
    Get.to(() => Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          '3D View - ${controller.propertyDetail.value?.propertyName ?? 'Property'}',
          style: TextStyle(color: Colors.white, fontSize: 16.sp),
        ),
        actions: [
          if (is3DModel)
            IconButton(
              icon: Icon(Icons.download, color: Colors.white),
              onPressed: _downloadImage,
              tooltip: 'Download 3D Model',
            ),
        ],
      ),
      body: Center(
        child: is3DModel
            ? _build3DModelFullscreen(imageUrl)
            : PhotoView(
          imageProvider: NetworkImage(imageUrl),
          minScale: PhotoViewComputedScale.contained * 0.8,
          maxScale: PhotoViewComputedScale.covered * 6,
          backgroundDecoration: const BoxDecoration(color: Colors.black),
          loadingBuilder: (context, progress) => Center(
            child: CircularProgressIndicator(
              color: Colors.white,
              value: progress?.expectedTotalBytes != null
                  ? progress!.cumulativeBytesLoaded / progress.expectedTotalBytes!
                  : null,
            ),
          ),
        ),
      ),
    ));
  }

  Widget _build3DModelFullscreen(String modelUrl) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.view_in_ar,
          size: 80.w,
          color: Colors.white,
        ),
        20.h.verticalSpace,
        Text(
          '3D Model Preview',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        10.h.verticalSpace,
        Text(
          'File: ${Uri.parse(modelUrl).path.split('/').last}',
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey.shade300,
          ),
        ),
        30.h.verticalSpace,
        ElevatedButton.icon(
          onPressed: () => _openExternal3DViewer(modelUrl),
          icon: Icon(Icons.open_in_new, size: 22.w),
          label: Text('Open in 3D Viewer'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade600,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        ),
      ],
    );
  }

  void _open3DModelViewer(String modelUrl) {
    // You can integrate with a 3D model viewer package here
    // For now, open in browser or show a dialog
    Get.defaultDialog(
      title: 'Open 3D Model',
      content: Column(
        children: [
          Text(
            'This 3D model can be viewed in external applications.',
            style: TextStyle(fontSize: 14.sp),
            textAlign: TextAlign.center,
          ),
          20.h.verticalSpace,
          Text(
            'Supported formats: .glb, .gltf, .obj',
            style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => _openExternal3DViewer(modelUrl),
          child: Text('Open Externally'),
        ),
      ],
    );
  }

  void _openExternal3DViewer(String modelUrl) async {
    // Open the 3D model in an external viewer or browser
    // You can use url_launcher package for this
    // Example: launchUrl(Uri.parse(modelUrl));
    Get.snackbar(
      '3D Model',
      'Opening 3D model in external viewer...',
      backgroundColor: Colors.blue.shade100,
    );
  }

  void _downloadImage() {
    final property = controller.propertyDetail.value;
    final imageUrl = property?.threeDImage ?? property?.threeDImage;

    if (imageUrl == null || imageUrl.isEmpty) {
      Get.snackbar(
        'Download Failed',
        'No 3D image available to download',
        backgroundColor: Colors.red.shade100,
      );
      return;
    }

    Get.snackbar(
      'Download Started',
      'Downloading 3D image...',
      backgroundColor: Colors.green.shade100,
    );

    // You can implement actual download logic here
    // Using dio or http package to download the file
  }
}