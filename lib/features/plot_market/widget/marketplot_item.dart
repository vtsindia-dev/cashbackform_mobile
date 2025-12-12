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
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MarketPlotItem({
    super.key,
    required this.plot,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final Color adityaGreen = const Color(0xFF7FA93C);
    final Color adityaYellow = const Color(0xFFF3C623);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Stack(
              children: [
                Container(
                  height: 160.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12.r),
                      topRight: Radius.circular(12.r),
                    ),
                    color: Colors.grey[100],
                  ),
                  child: plot.images.isNotEmpty
                      ? ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12.r),
                      topRight: Radius.circular(12.r),
                    ),
                    child: Image.network(
                      plot.images[0],
                      fit: BoxFit.cover,
                      errorBuilder: (c, o, s) => Center(
                        child: Icon(
                          Icons.image,
                          size: 40.sp,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  )
                      : Center(
                    child: Icon(
                      Icons.image,
                      size: 40.sp,
                      color: Colors.grey,
                    ),
                  ),
                ),

                // Verified Badge - Show ONLY if verifyStatus == 1 (VERIFIED)
                if (plot.verifyStatus == 1)
                  Positioned(
                    top: 8.w,
                    left: 8.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: adityaGreen,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified, size: 12.sp, color: Colors.white),
                          SizedBox(width: 4.w),
                          Text(
                            'Verified',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Price Tag
                Positioned(
                  bottom: 8.w,
                  left: 8.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: adityaGreen,
                      borderRadius: BorderRadius.circular(6.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Text(
                      plot.formattedPrice,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // Actions Menu
                Positioned(
                  top: 8.w,
                  right: 8.w,
                  child: PopupMenuButton<String>(
                    icon: Container(
                      padding: EdgeInsets.all(6.r),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Icon(Icons.more_vert, size: 18.sp, color: Colors.grey[700]),
                    ),
                    onSelected: (value) {
                      if (value == 'edit') {
                        onEdit();
                      } else if (value == 'delete') {
                        onDelete();
                      } else if (value == 'verify') {
                        _initiateVerification(plot);
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      // Create menu items list
                      List<PopupMenuItem<String>> items = [];

                      // Always show Edit
                      items.add(
                        PopupMenuItem<String>(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 16.sp, color: adityaGreen),
                              SizedBox(width: 8.w),
                              Text('Edit', style: TextStyle(fontSize: 12.sp)),
                            ],
                          ),
                        ),
                      );

                      // Show Verify option only if plot is NOT verified (verifyStatus == 0)
                      if (plot.verifyStatus == 0) {
                        items.add(
                          PopupMenuItem<String>(
                            value: 'verify',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.verified_outlined,
                                  size: 16.sp,
                                  color: adityaGreen,
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  'Get Verified',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: adityaGreen,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      // Always show Delete
                      items.add(
                        PopupMenuItem<String>(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 16.sp, color: Colors.red),
                              SizedBox(width: 8.w),
                              Text('Delete', style: TextStyle(fontSize: 12.sp)),
                            ],
                          ),
                        ),
                      );

                      return items;
                    },
                  ),
                ),
              ],
            ),

            // Details Section (unchanged)
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    plot.name,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[900],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: 4.h),

                  // Location
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14.sp,
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          plot.location,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 6.h),

                  // Description
                  Text(
                    plot.description,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: 12.h),

                  // Footer Info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Area
                      Row(
                        children: [
                          Icon(
                            Icons.aspect_ratio,
                            size: 14.sp,
                            color: adityaGreen,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            plot.formattedArea,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),

                      // Type
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: adityaGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          plot.type?.toString() ?? 'N/A',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: adityaGreen,
                            fontWeight: FontWeight.w500,
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

  void _initiateVerification(MarketPlot plot) {
    // Only allow verification if plot is not verified (verifyStatus == 0)
    if (plot.verifyStatus == 1) {
      Get.snackbar(
        "Already Verified",
        "This plot is already verified!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      return;
    }

    final controller = Get.find<PlotMarketController>();
    controller.initiateVerificationPayment(plot);
  }
}