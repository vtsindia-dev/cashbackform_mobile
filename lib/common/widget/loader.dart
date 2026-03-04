import 'package:cashback_farms/common/colours.dart';
import 'package:flutter/material.dart';
import '../images.dart';

class GifLoader extends StatefulWidget {
  final double size;
  final String? message;
  final String gifAsset;

  const GifLoader({
    super.key,
    this.size = 90,
    this.message,
    this.gifAsset = Images.loader,
  });

  @override
  State<GifLoader> createState() => _GifLoaderState();
}

class    _GifLoaderState extends State<GifLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller =
    AnimationController(vsync: this, duration: Duration(seconds: 1))
      ..repeat(reverse: true);

    _pulse = Tween<double>(begin: 4, end: 12).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (_, __) {
              return Container(
                padding: EdgeInsets.all(_pulse.value),
                decoration: BoxDecoration(
                  color: AppColor.primary.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  widget.gifAsset,
                  width: widget.size,
                  height: widget.size,

                ),
              );
            },
          ),

          if (widget.message != null) ...[
            SizedBox(height: 10),
            Text(
              widget.message!,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
