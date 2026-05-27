import 'package:cashback_farms/common/colours.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';


class ProductCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String price;
  final String location;
  final String description;
  final VoidCallback onTap;
  final bool isFavourite;
  final String? rentalAmount;
  final String? yieldAmount;
  final int? soldStatus;

  const ProductCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.price,
    required this.location,
    required this.description,
    required this.onTap,
    required this.isFavourite,
    this.yieldAmount,
    this.rentalAmount,
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
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10.r),
                    topRight: Radius.circular(10.r),
                  ),
                  child: Image.network(
                    imageUrl,
                    height: 120.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    color: isSoldOut ? Colors.grey : null,
                    colorBlendMode: isSoldOut ? BlendMode.saturation : null,
                  ),
                ),
                if (isSoldOut)
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10.r),
                        topRight: Radius.circular(10.r),
                      ),
                      child: Container(
                        color: Colors.black.withOpacity(0.50),
                      ),
                    ),
                  ),

                if (isSoldOut)
                  Positioned.fill(
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 5.h),
                        decoration: BoxDecoration(
                          color: Colors.red.shade700,
                          borderRadius: BorderRadius.circular(6.r),
                          border: Border.all(color: Colors.white, width: 1.5.w),
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

                if (!isSoldOut)
                  Positioned(
                    top: 6.h,
                    left: 6.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 7.w, vertical: 3.h),
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
                      color: isSoldOut ? Colors.grey.shade500 : Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  if (rentalAmount == null && yieldAmount == null)
                    Row(
                      children: [
                        SizedBox(width: 4.w),
                        Text(
                          price,
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: isSoldOut
                                ? Colors.grey.shade400
                                : AppColor.primary,
                          ),
                        ),
                      ],
                    ),
                  if (rentalAmount != null && yieldAmount != null) ...[
                    Row(
                      children: [
                        Flexible(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "₹ $rentalAmount",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: isSoldOut
                                      ? Colors.grey.shade400
                                      : Colors.black,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                "Rental Amount",
                                style:
                                TextStyle(fontSize: 10, color: Colors.grey),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 28,
                          width: 1,
                          color: Colors.orange,
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                        ),
                        Flexible(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "₹ $yieldAmount",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: isSoldOut
                                      ? Colors.grey.shade400
                                      : Colors.black,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                "Yield Amount",
                                style:
                                TextStyle(fontSize: 10, color: Colors.grey),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                  ],
                  SizedBox(height: 3.h),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}