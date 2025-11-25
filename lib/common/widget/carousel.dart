import 'dart:async';
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
    this.autoPlayDuration = const Duration(seconds: 3),
    this.borderRadius = 12,
  });

  @override
  State<CarouselWidget> createState() => _CarouselWidgetState();
}

class _CarouselWidgetState extends State<CarouselWidget>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  Timer? _timer;

  int _currentIndex = 0;
  bool _isImageLoaded = false;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    _fadeController.forward();

    _timer = Timer.periodic(widget.autoPlayDuration, (timer) {
      _changeImage();
    });
  }

  void _changeImage() {
    _fadeController.reverse().then((_) {
      setState(() {
        _isImageLoaded = false;
        _currentIndex = (_currentIndex + 1) % widget.images.length;
      });

      _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: Stack(
            children: [
              // IMAGE
              FadeTransition(
                opacity: _fadeAnimation,
                child: Image.network(
                  widget.images[_currentIndex],
                  width: double.infinity,
                  height: widget.height,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      Future.microtask(() {
                        if (!_isImageLoaded) {
                          setState(() {
                            _isImageLoaded = true;
                          });
                        }
                      });
                      return child;
                    }
                    return _buildShimmer();
                  },
                ),
              ),
              if (!_isImageLoaded) Positioned.fill(child: _buildShimmer()),
            ],
          ),
        ),

        const SizedBox(height: 8),
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
                  ),
                ]
                    : [],
              ),
            );
          }),
        ),
      ],
    );
  }
  Widget _buildShimmer() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: -1, end: 2),
      duration: const Duration(seconds: 2),
      builder: (context, value, child) {
        return ShaderMask(
          shaderCallback: (rect) {
            return LinearGradient(
              begin: Alignment(-1, 0),
              end: Alignment(1, 0),
              colors: [
                Colors.grey.shade300,
                Colors.grey.shade100,
                Colors.grey.shade300,
              ],
              stops: [value - 1, value, value + 1],
            ).createShader(rect);
          },
          blendMode: BlendMode.srcATop,
          child: Container(
            color: Colors.grey.shade300,
            width: double.infinity,
            height: widget.height,
          ),
        );
      },
    );
  }
}
