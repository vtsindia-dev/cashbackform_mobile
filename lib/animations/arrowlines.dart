import 'package:flutter/material.dart';

import '../common/colours.dart';
class ArrowLine extends StatefulWidget {
  const ArrowLine({super.key});

  @override
  State<ArrowLine> createState() => _ArrowLineState();
}
class _ArrowLineState extends State<ArrowLine>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> fade;
  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    fade = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeInOut),
    );
  }
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        return Opacity(
          opacity: fade.value,
          child: CustomPaint(
            painter: ArrowLinePainter(),
          ),
        );
      },
    );
  }
}
class ArrowLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColor.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    // Draw continuous ---> pattern
    const dashLength = 8.0;
    const gapLength = 4.0;
    const arrowSize = 6.0;
    double x = 0;
    while (x < size.width) {
      // Draw dash "---"
      if (x + dashLength <= size.width) {
        canvas.drawLine(
          Offset(x, size.height / 2),
          Offset(x + dashLength, size.height / 2),
          paint,
        );
      }
      x += dashLength + gapLength;
      if (x + arrowSize <= size.width) {
        final arrowX = x;
        final arrowY = size.height / 2;

        final arrowPaint = Paint()
          ..color = AppColor.primary
          ..style = PaintingStyle.fill;

        final Path arrowPath = Path();
        arrowPath.moveTo(arrowX, arrowY);                    // Tip of arrow
        arrowPath.lineTo(arrowX - arrowSize, arrowY - 4);    // Top point
        arrowPath.lineTo(arrowX - arrowSize, arrowY + 4);    // Bottom point
        arrowPath.close();

        canvas.drawPath(arrowPath, arrowPaint);

        x += arrowSize + gapLength;
      }
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}