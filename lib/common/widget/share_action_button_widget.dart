import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ActionButtonWidget extends StatelessWidget {
  final VoidCallback onTap;
  final String title;
  final Widget icon;
  final Color? bgColor;
  final Color? borderColor;
  final Color? textColor;
  final List<Color>? gradientColors;

  const ActionButtonWidget({
    super.key,
    required this.onTap,
    required this.title,
    required this.icon,
    this.bgColor,
    this.borderColor,
    this.textColor,
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24.r),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 14.w,
            vertical: 8.h,
          ),
          decoration: BoxDecoration(
            color: gradientColors == null ? bgColor : null,
            gradient: gradientColors != null
                ? LinearGradient(
              colors: gradientColors!,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
                : null,
            border: Border.all(
              color: borderColor ?? Colors.transparent,
              width: 0.8,
            ),
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: gradientColors != null
                ? [
              BoxShadow(
                color: borderColor?.withValues(alpha: 0.25) ??
                    Colors.black.withValues(alpha: 0.08),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon,
              SizedBox(width: 6.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: textColor ?? Colors.black,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}