import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CompactNoteCard extends StatefulWidget {
  final String title;
  final String description;
  final IconData? icon;

  const CompactNoteCard({
    super.key,
    required this.title,
    required this.description,
    this.icon,
  });

  @override
  State<CompactNoteCard> createState() => _CompactNoteCardState();
}

class _CompactNoteCardState extends State<CompactNoteCard> with SingleTickerProviderStateMixin {
  bool isExpanded = false;
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => isExpanded = !isExpanded),
      child: AnimatedBuilder(
        animation: _shimmerController,
        builder: (context, child) {
          final shaderGradient = _redLiquidGradient();

          return Container(
            margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.red.withOpacity(0.15), width: 0.5),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: StarPainter(animationValue: _shimmerController.value),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: 3.w,
                      decoration: BoxDecoration(
                        gradient: shaderGradient,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(14.w, 10.h, 10.w, 10.h),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            ShaderMask(
                              shaderCallback: (bounds) => shaderGradient.createShader(bounds),
                              child: Icon(
                                widget.icon ?? Icons.flash_on_rounded,
                                size: 16.sp,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: ShaderMask(
                                shaderCallback: (bounds) => shaderGradient.createShader(bounds),
                                child: Text(
                                  widget.title,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ),
                            ),
                            // Smoother Rotating Arrow
                            RotationTransition(
                              turns: AlwaysStoppedAnimation(isExpanded ? 0.5 : 0),
                              child: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 18.sp,
                                color: Colors.red.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),

                        AnimatedSize(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.fastOutSlowIn,
                          alignment: Alignment.topCenter,
                          child: isExpanded
                              ? Padding(
                            padding: EdgeInsets.only(top: 8.h, left: 26.w),
                            child: ShaderMask(
                              shaderCallback: (bounds) => shaderGradient.createShader(bounds),
                              child: Text(
                                widget.description,
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          )
                              : const SizedBox(width: double.infinity, height: 0),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  LinearGradient _redLiquidGradient() {
    return LinearGradient(
      colors: const [Color(0xFF440000), Color(0xFFFF0000), Color(0xFF440000)],
      stops: const [0.0, 0.5, 1.0],
      begin: Alignment(-2.0 + (_shimmerController.value * 4.0), -0.5),
      end: Alignment(0.0 + (_shimmerController.value * 4.0), 0.5),
    );
  }
}

class StarPainter extends CustomPainter {
  final double animationValue;
  StarPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.red.withOpacity(0.2);
    final rand = math.Random(123);
    for (int i = 0; i < 15; i++) {
      double x = rand.nextDouble() * size.width;
      double y = rand.nextDouble() * size.height;
      double opacity = (math.sin((animationValue * 2 * math.pi) + i) + 1) / 2;
      canvas.drawCircle(Offset(x, y), 0.8.w * opacity, paint);
    }
  }

  @override
  bool shouldRepaint(StarPainter oldDelegate) => true;
}