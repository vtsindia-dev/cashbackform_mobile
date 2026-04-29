import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../colours.dart';
import 'toster.dart';

class CopyableText extends StatelessWidget {
  final String text;
  final String label;
  final bool showCopyIcon;
  final TextStyle? textStyle;
  final TextStyle? labelStyle;

  const CopyableText({
    Key? key,
    required this.text,
    this.label = "",
    this.showCopyIcon = true,
    this.textStyle,
    this.labelStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty)
          Text(
            label,
            style: labelStyle ?? TextStyle(
              fontSize: 12.sp,
              color: AppColor.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        SizedBox(height: 4.h),
        GestureDetector(
          onTap: () {
            Clipboard.setData(ClipboardData(text: text));
            SnackBarHelper.showSuccess("Copied to clipboard!");
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: AppColor.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  text,
                  style: textStyle ?? TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColor.primary,
                  ),
                ),
                if (showCopyIcon) ...[
                  SizedBox(width: 8.w),
                  Icon(
                    Icons.copy_rounded,
                    size: 16.sp,
                    color: AppColor.primary,
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}