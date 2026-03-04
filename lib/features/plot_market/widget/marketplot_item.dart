// market_plot_item.dart - UPDATED CORRECTLY
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../common/colours.dart';
import '../controller/plot_market_controller.dart';
import '../model/plot_market.dart';

class MarketPlotItem extends StatelessWidget {
  final MarketPlot plot;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onVerify;
  final bool isOwner;

  const MarketPlotItem({
    required this.plot,
    required this.onTap,
    this.onEdit,
    this.onDelete,
    this.onVerify,
    this.isOwner = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Container
              Container(
                height: 120.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12.r),
                    topRight: Radius.circular(12.r),
                  ),
                  image: plot.images != null && plot.images!.isNotEmpty
                      ? DecorationImage(
                    image: NetworkImage(plot.images[0]!),
                    fit: BoxFit.cover,
                  )
                      : DecorationImage(
                    image: AssetImage('assets/images/placeholder_property.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                    // Verified Badge
                    if (plot.verifyStatus == 1)
                      Positioned(
                        top: 8.h,
                        left: 8.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified, size: 10.sp, color: Colors.white),
                              SizedBox(width: 4.w),
                              Text(
                                "Verified",
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Price Tag
                    Positioned(
                      bottom: 8.h,
                      right: 8.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: AppColor.primary.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          plot.formattedPrice,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Details
              Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plot.name,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColor.textMain,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 12.sp, color: AppColor.textSecondary),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            plot.location,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: AppColor.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    // Verification Button (if not verified and is owner)
                    if (isOwner && plot.verifyStatus != 1)
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(top: 8.h),
                        child: ElevatedButton(
                          onPressed: onVerify,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade50,
                            foregroundColor: Colors.orange.shade800,
                            padding: EdgeInsets.symmetric(vertical: 6.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6.r),
                              side: BorderSide(color: Colors.orange.shade300),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.verified_outlined, size: 12.sp),
                              SizedBox(width: 4.w),
                              Text(
                                "Verify Property",
                                style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          // Edit/Delete buttons (only for owner)
          if (isOwner)
            Positioned(
              top: 8.h,
              right: 8.w,
              child: Row(
                children: [
                  if (onEdit != null)
                    GestureDetector(
                      onTap: onEdit,
                      child: Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Icon(Icons.edit, size: 14.sp, color: Colors.white),
                      ),
                    ),
                  if (onDelete != null) SizedBox(width: 4.w),
                  if (onDelete != null)
                    GestureDetector(
                      onTap: onDelete,
                      child: Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Icon(Icons.delete, size: 14.sp, color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}