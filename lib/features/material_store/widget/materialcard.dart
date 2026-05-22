import 'package:cashback_farms/common/colours.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
class MaterialCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String category;
  final String status;
  final String createdDate;
  final String description;
  final VoidCallback onTap;

  const MaterialCard({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.category,
    required this.status,
    required this.createdDate,
    required this.description,
    required this.onTap,
  });

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
            // IMAGE
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10.r),
                topRight: Radius.circular(10.r),
              ),
              child: Image.network(
                imageUrl,
                height: 100.h,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 100.h,
                  color: Colors.grey.shade200,
                  child: Icon(Icons.image_not_supported_outlined,
                      size: 30.w, color: Colors.grey.shade400),
                ),
              ),
            ),

            // CONTENT
            Padding(
              padding: EdgeInsets.all(8.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TITLE
                  Text(
                    name,
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Icon(Icons.category, size: 13.sp, color: AppColor.primary),
                      SizedBox(width: 5.w),
                      Expanded(
                        child: Text(
                          category,
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColor.primary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Icon(Icons.circle,
                          size: 10.sp,
                          color: status == "Active" ? AppColor.primary : Colors.red),
                      SizedBox(width: 5.w),
                      Expanded(
                        child: Text(
                          status,
                          style: GoogleFonts.poppins(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColor.primary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  // SizedBox(height: 6.h),

                  /// DATE
                  // Row(
                  //   children: [
                  //     Icon(Icons.calendar_month, size: 12.sp, color: Colors.grey),
                  //     SizedBox(width: 5.w),
                  //     Expanded(
                  //       child: Text(
                  //         createdDate,
                  //         style: GoogleFonts.poppins(
                  //           fontSize: 10.sp,
                  //           color: Colors.grey[700],
                  //         ),
                  //         maxLines: 1,
                  //         overflow: TextOverflow.ellipsis,
                  //       ),
                  //     ),
                  //   ],
                  // ),

                  SizedBox(height: 6.h),

                  /// DESCRIPTION
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

                  // VIEW BUTTON
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        height: 28.h,
                        child: ElevatedButton(
                          onPressed: onTap,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            padding:
                            EdgeInsets.symmetric(vertical: 4.h, horizontal: 6.w),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                              side: BorderSide(
                                color: AppColor.primary,
                                width: 0.8.w,
                              ),
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
