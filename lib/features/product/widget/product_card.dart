import 'package:cashback_farms/common/colours.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../common/images.dart';

class ProductCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String price;
  final String location;
  final String description;
  final VoidCallback onTap;
  final bool isFavourite;
  final VoidCallback onFavToggle;
  final VoidCallback onAddToCart;

  const ProductCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.price,
    required this.location,
    required this.description,
    required this.onTap,
    required this.isFavourite,
    required this.onFavToggle,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
                ),
              ),
              // Positioned(
              //   top: 8.h,
              //   right: 8.w,
              //   child: InkWell(
              //     onTap: onFavToggle,
              //     child: Container(
              //       padding: EdgeInsets.all(6.r),
              //       decoration: BoxDecoration(
              //         color: AppColor.white,
              //         shape: BoxShape.circle,
              //         boxShadow: [
              //           BoxShadow(
              //             color: Colors.black12,
              //             blurRadius: 2.r,
              //             offset: Offset(0, 1.h),
              //           )
              //         ],
              //       ),
              //       child: Icon(
              //         isFavourite ? Icons.favorite : Icons.favorite_border,
              //         color: AppColor.primary,
              //         size: 18.sp,
              //       ),
              //     ),
              //   ),
              // ),
              //
              // Positioned(
              //   top: 8.h,
              //   left: 8.w,
              //   child: InkWell(
              //     onTap: onAddToCart,
              //     child: Container(
              //       padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              //       decoration: BoxDecoration(
              //         color: AppColor.primary,
              //         borderRadius: BorderRadius.circular(8.r),
              //         boxShadow: [
              //           BoxShadow(
              //             color: Colors.black12,
              //             blurRadius: 2.r,
              //             offset: Offset(0, 1.h),
              //           )
              //         ],
              //       ),
              //       child: Row(
              //         children: [
              //           Icon(Icons.shopping_cart_outlined,
              //               color: Colors.white, size: 14.sp),
              //           SizedBox(width: 3.w),
              //           Text(
              //             "Add",
              //             style: TextStyle(
              //                 color: Colors.white,
              //                 fontSize: 10.sp,
              //                 fontWeight: FontWeight.w600),
              //           )
              //         ],
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(8.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.montserrat(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Image.asset(
                      Images.price,
                      height: 13.h,
                      width: 13.w,
                      color: AppColor.primary,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      price,
                      style: GoogleFonts.montserrat(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColor.primary,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 3.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.location_on, size: 12.sp, color: Colors.grey),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Text(
                          location,
                          style: GoogleFonts.montserrat(
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
                  style: GoogleFonts.montserrat(
                    fontSize: 11.sp,
                    color: Colors.grey[800],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      height: 28.h,
                      child: ElevatedButton(
                        onPressed: onTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 6.w),
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
                          style: GoogleFonts.montserrat(
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
    );
  }
}