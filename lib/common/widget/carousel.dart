import 'package:carousel_slider/carousel_slider.dart';
import 'package:cashback_farms/common/colours.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class CarouselWidget extends StatefulWidget {
  final List<String> images;
  final List<String>? redirectUrls;
  final double? height;
  final Duration autoPlayDuration;
  final double borderRadius;
  final BoxFit imageFit;
  final Function(String)? onTap;
  final Function(int, dynamic)? onError;

  const CarouselWidget({
    super.key,
    required this.images,
    this.redirectUrls,
    this.height,
    this.autoPlayDuration = const Duration(seconds: 5),
    this.borderRadius = 12,
    this.imageFit = BoxFit.cover,
    this.onTap,
    this.onError,
  });

  @override
  State<CarouselWidget> createState() => _CarouselWidgetState();
}

class _CarouselWidgetState extends State<CarouselWidget> {
  int _currentIndex = 0;
  final Map<int, bool> _imageErrorMap = {};
  Future<void> _handleBannerTap(int index) async {
    String? redirectUrl;
    if (widget.redirectUrls != null && index < widget.redirectUrls!.length) {
      redirectUrl = widget.redirectUrls![index];
    }

    if (widget.onTap != null) {
      widget.onTap!(redirectUrl ?? '');
      return;
    }
    if (redirectUrl != null && redirectUrl.isNotEmpty) {
      try {
        final Uri url = Uri.parse(redirectUrl);
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        } else {
          _showErrorSnackBar('Cannot open link');
        }
      } catch (e) {
        _showErrorSnackBar('Invalid URL');
      }
    } else {
      _showInfoSnackBar('No link available for this banner');
    }
  }

  void _showErrorSnackBar(String message) {
    Get.snackbar('Error', message,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2));
  }

  void _showInfoSnackBar(String message) {
    Get.snackbar('Info', message,
        backgroundColor: Colors.grey,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2));
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
      ),
    );
  }

  Widget _buildErrorPlaceholder({bool isAsset = false}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(widget.borderRadius),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isAsset ? Icons.image_not_supported : Icons.broken_image,
            size: 40,
            color: Colors.grey,
          ),
          const SizedBox(height: 8),
          Text(
            isAsset ? 'Asset not found' : 'Failed to load image',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String path, int index) {
    if (_imageErrorMap[index] == true) {
      return _buildErrorPlaceholder();
    }

    final bool isNetwork = path.startsWith('http') || path.startsWith('https');

    if (isNetwork) {
      return Image.network(
        path,
        width: double.infinity,
        height: double.infinity,
        fit: widget.imageFit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildShimmer();
        },
        errorBuilder: (context, error, stackTrace) {
          widget.onError?.call(index, error);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _imageErrorMap[index] = true);
          });
          return _buildErrorPlaceholder();
        },
      );
    } else {
      return Image.asset(
        path,
        width: double.infinity,
        height: double.infinity,
        fit: widget.imageFit,
        errorBuilder: (context, error, stackTrace) =>
            _buildErrorPlaceholder(isAsset: true),
      );
    }
  }
  Widget _sizeWrapper({required Widget child}) {
    if (widget.height != null) {
      return SizedBox(height: widget.height, child: child);
    }
    return AspectRatio(aspectRatio: 16 / 9, child: child);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) {
      return _sizeWrapper(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image_search, size: 40, color: Colors.grey),
              SizedBox(height: 8),
              Text("No images available",
                  style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => _handleBannerTap(_currentIndex),
          child: _sizeWrapper(
            child: CarouselSlider.builder(
              itemCount: widget.images.length,
              itemBuilder: (context, index, realIndex) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  child: _buildImage(widget.images[index], index),
                );
              },
              options: CarouselOptions(
                height: widget.height ?? double.infinity,
                viewportFraction: 1.0,
                autoPlay: widget.images.length > 1,
                autoPlayInterval: widget.autoPlayDuration,
                autoPlayAnimationDuration:
                const Duration(milliseconds: 800),
                enableInfiniteScroll: widget.images.length > 1,
                onPageChanged: widget.images.length > 1
                    ? (index, reason) =>
                    setState(() => _currentIndex = index)
                    : null,
              ),
            ),
          ),
        ),
        if (widget.images.length > 1) const SizedBox(height: 5),
        if (widget.images.length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.images.length, (index) {
              final isActive = index == _currentIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 8,
                width: isActive ? 26 : 8,
                decoration: BoxDecoration(
                  color: isActive ? AppColor.primary : Colors.black26,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: isActive
                      ? [
                    BoxShadow(
                      color: AppColor.primary.withOpacity(0.6),
                      blurRadius: 8,
                    )
                  ]
                      : [],
                ),
              );
            }),
          ),
      ],
    );
  }
}