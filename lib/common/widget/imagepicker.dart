 import 'dart:io';

import 'package:flutter/material.dart';


class ImagePickerWidget extends StatelessWidget {
  final VoidCallback? onImagePick;
  final bool isImagePathSet;
  final bool isPicker;
  final String? imagePath;
  final String imageUrl;

  const ImagePickerWidget({
    super.key,
    this.onImagePick,
    this.isImagePathSet = false,
    this.imagePath,
    required this.imageUrl,
    this.isPicker = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              width: 3,
              color: Colors.white,
            ),
          ),
          child: ClipOval(
            child: isImagePathSet
                ? Image.file(
              File(imagePath!),
              fit: BoxFit.cover,
            )
                : imageUrl.isNotEmpty
                ? Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.person, size: 40);
              },
            )
                : const ShimmerCircle(),
          ),
        ),
        if (isPicker && onImagePick != null)
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: onImagePick,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    width: 2,
                    color: Colors.white,
                  ),
                ),
                child: Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class ShimmerCircle extends StatefulWidget {
  const ShimmerCircle({super.key});

  @override
  _ShimmerCircleState createState() => _ShimmerCircleState();
}

class _ShimmerCircleState extends State<ShimmerCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[300],
      ),
      child: CustomPaint(
        painter: ShimmerCirclePainter(animation: _animationController),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

class ShimmerCirclePainter extends CustomPainter {
  final Animation<double> animation;

  ShimmerCirclePainter({required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint();
    paint.shader = _createGradientShader(size, animation.value);

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  Shader _createGradientShader(Size size, double animationValue) {
    final List<Color> colors = [
      Colors.transparent,
      Colors.white.withOpacity(0.5),
      Colors.transparent,
    ];

    final stops = [0.0, 0.5, 1.0];

    final double dx = size.width * animationValue - size.width;

    return LinearGradient(
      begin: Alignment(-1.0, 0.0),
      end: Alignment(2.0, 0.0),
      colors: colors,
      stops: stops,
      tileMode: TileMode.mirror,
    ).createShader(Rect.fromLTWH(dx, 0, size.width, size.height));
  }
}