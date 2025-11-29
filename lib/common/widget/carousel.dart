import 'package:carousel_slider/carousel_slider.dart';
import 'package:cashback_farms/common/colours.dart';
import 'package:flutter/material.dart';

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
          return Image.asset(
            'assets/images/placeholder.png',
            width: double.infinity,
            height: widget.height,
            fit: BoxFit.cover,
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            'assets/images/placeholder.png',
            width: double.infinity,
            height: widget.height,
            fit: BoxFit.cover,
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
        child: const Center(child: Text("No images")),
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
            autoPlayAnimationDuration: const Duration(seconds: 2),
            enableInfiniteScroll: widget.images.length > 1,
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        ),
        const SizedBox(height: 5),
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
