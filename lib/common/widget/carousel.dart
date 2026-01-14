import 'package:carousel_slider/carousel_slider.dart';
import 'package:cashback_farms/common/colours.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CarouselWidget extends StatefulWidget {
  final List<String> images;
  final double height;
  final Duration autoPlayDuration;
  final double borderRadius;

  const CarouselWidget({
    super.key,
    required this.images,
    this.height = 180,
    this.autoPlayDuration = const Duration(seconds: 5),
    this.borderRadius = 12,
  });

  @override
  State<CarouselWidget> createState() => _CarouselWidgetState();
}

class _CarouselWidgetState extends State<CarouselWidget> {
  int _currentIndex = 0;

  // Shimmer effect widget
  Widget _buildShimmerPlaceholder() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: double.infinity,
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
      ),
    );
  }

  // Loading skeleton with animation
  Widget _buildLoadingSkeleton() {
    return Container(
      width: double.infinity,
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(widget.borderRadius),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(AppColor.primary),
        ),
      ),
    );
  }

  Widget _buildImage(String path) {
    final bool isNetwork = path.startsWith('http') || path.startsWith('https');

    if (isNetwork) {
      return Image.network(
        path,
        width: double.infinity,
        height: widget.height,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;

          // Show shimmer effect while loading
          return _buildShimmerPlaceholder();
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: double.infinity,
            height: widget.height,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.broken_image,
                  size: 40,
                  color: Colors.grey,
                ),
                const SizedBox(height: 8),
                Text(
                  'Failed to load image',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        },
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(2.0),
        child: Image.asset(
          path,
          width: double.infinity,
          height: widget.height,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: double.infinity,
              height: widget.height,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(widget.borderRadius),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.image_not_supported,
                    size: 40,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Asset not found',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) {
      return Container(
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image_search, size: 40, color: Colors.grey),
              SizedBox(height: 8),
              Text(
                "No images available",
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CarouselSlider.builder(
          itemCount: widget.images.length,
          itemBuilder: (context, index, realIndex) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              child: Padding(
                padding: const EdgeInsets.all(1.0),
                child: _buildImage(widget.images[index]),
              ),
            );
          },
          options: CarouselOptions(
            height: widget.height,
            viewportFraction: 1.0,
            autoPlay: widget.images.length > 1,
            autoPlayInterval: widget.autoPlayDuration,
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            enableInfiniteScroll: widget.images.length > 1,
            onPageChanged: widget.images.length > 1
                ? (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            }
                : null,
          ),
        ),
        // Only show indicators if there's more than 1 image
        if (widget.images.length > 1) const SizedBox(height: 5),
        if (widget.images.length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.images.length, (index) {
              bool isActive = index == _currentIndex;
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