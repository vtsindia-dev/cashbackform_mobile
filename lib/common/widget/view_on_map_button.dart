import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../colours.dart';

class ViewOnMapButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool active;

  const ViewOnMapButton({
    super.key,
    required this.onTap,
    this.active = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: active ? AppColor.primary : Colors.grey.shade400,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/google-maps.png',
              width: 16.w,
              height: 16.w,
            ),
            4.w.horizontalSpace,
            Text(
              "View on Map",
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: active ? AppColor.primary : Colors.grey.shade400,
              ),
            ),
          ],
        ),
      )
          .animate()
          .fadeIn(duration: 600.ms)
          .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0))
          .then()
          .shimmer(
        duration: 800.ms,
        color: Colors.black.withValues(alpha: 0.05),
      ),
    );
  }
}