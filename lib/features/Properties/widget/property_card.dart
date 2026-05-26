import 'package:cashback_farms/common/colours.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../common/images.dart';

class PropertyCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String price;
  final String area;
  final String location;
  final String description;
  final VoidCallback onTap;
  final int? soldStatus;

  const PropertyCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.price,
    required this.area,
    required this.location,
    required this.description,
    required this.onTap,
    this.soldStatus,
  });


  bool get isSoldOut => soldStatus == 1;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 3.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image + sold overlay ──────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10.r),
                topRight: Radius.circular(10.r),
              ),
              child: Stack(
                children: [
                  // Property image
                  Image.network(
                    imageUrl,
                    height: 100.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 100.h,
                        width: double.infinity,
                        color: Colors.grey.shade200,
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          size: 30.w,
                          color: Colors.grey.shade400,
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 100.h,
                        width: double.infinity,
                        color: Colors.grey.shade200,
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2.w,
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                  ),

                  // ✅ Sold out dim overlay
                  if (isSoldOut)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withOpacity(0.55),
                      ),
                    ),

                  // ✅ Sold out centre stamp
                  if (isSoldOut)
                    Positioned.fill(
                      child: Center(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 5.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.shade700,
                            borderRadius: BorderRadius.circular(6.r),
                            border: Border.all(
                              color: Colors.white,
                              width: 1.5.w,
                            ),
                          ),
                          child: Text(
                            "SOLD OUT",
                            style: GoogleFonts.poppins(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),
                    ),

                  // ✅ Available green badge (top-left) when NOT sold
                  if (!isSoldOut)
                    Positioned(
                      top: 6.h,
                      left: 6.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 7.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade600,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          "Available",
                          style: GoogleFonts.poppins(
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ── Card body ─────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.all(8.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      // ✅ Grey out title when sold
                      color: isSoldOut ? Colors.grey.shade500 : Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      // Price
                      Expanded(
                        flex: 1,
                        child: Row(
                          children: [
                            SizedBox(width: 4.w),
                            Expanded(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  price,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                    // ✅ Grey price when sold
                                    color: isSoldOut
                                        ? Colors.grey.shade400
                                        : AppColor.primary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(width: 10.w),

                      // Area
                      Expanded(
                        flex: 1,
                        child: Row(
                          children: [
                            Image.asset(
                              Images.squareFeet,
                              height: 13.h,
                              width: 13.w,
                              color: isSoldOut
                                  ? Colors.grey.shade400
                                  : AppColor.primary,
                            ),
                            SizedBox(width: 4.w),
                            Expanded(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  area,
                                  style: GoogleFonts.poppins(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w600,
                                    color: isSoldOut
                                        ? Colors.grey.shade400
                                        : AppColor.primary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),

                  // Location
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 6.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.location_on,
                            size: 12.sp, color: Colors.grey),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Text(
                            location,
                            style: GoogleFonts.poppins(
                              fontSize: 10.sp,
                              color: Colors.grey[700],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 5.h),

                  // Description
                  Text(
                    description,
                    style: GoogleFonts.poppins(
                      fontSize: 11.sp,
                      color: Colors.grey[800],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8.h),

                  // ── View / Sold button ────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        height: 28.h,
                        child: isSoldOut
                        // ✅ Disabled "Sold Out" button
                            ? Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 4.h, horizontal: 6.w),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                              color: Colors.red.shade300,
                              width: 0.8.w,
                            ),
                          ),
                          child: Text(
                            "Sold Out",
                            style: GoogleFonts.poppins(
                              color: Colors.red.shade600,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                        // ✅ Normal "View" button
                            : ElevatedButton(
                          onPressed: onTap,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            padding: EdgeInsets.symmetric(
                                vertical: 4.h, horizontal: 6.w),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                              side: BorderSide(
                                color: AppColor.primary,
                                width: 0.8.w,
                              ),
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize:
                            MaterialTapTargetSize.shrinkWrap,
                            elevation: 0,
                          ),
                          child: Text(
                            "View",
                            style: GoogleFonts.poppins(
                              color: AppColor.primary,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}