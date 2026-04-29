import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../model/plot_market.dart';

class MarketPlotItem extends StatelessWidget {
  final MarketPlot plot;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onVerify;
  final bool isOwner;

  const MarketPlotItem({
    super.key,
    required this.plot,
    required this.onTap,
    this.onEdit,
    this.onDelete,
    this.onVerify,
    this.isOwner = false,
  });

  // =======================
  // STATUS HELPERS
  // =======================

  bool get isPaid => plot.documentVerification == true;

  String get verifyBadgeText =>
      plot.verifyStatus == 1 ? "Verified ✓" : "Not Verified";

  Color get verifyBadgeColor =>
      plot.verifyStatus == 1 ? Colors.green : Colors.grey;

  // =======================

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: InkWell(
        borderRadius: BorderRadius.circular(20.r),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // =======================
              // IMAGE
              // =======================

              Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                    BorderRadius.vertical(top: Radius.circular(20.r)),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: plot.images.isNotEmpty
                          ? Image.network(
                        plot.images[0],
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Image.asset(
                          'assets/images/placeholder_property.jpg',
                          fit: BoxFit.cover,
                        ),
                      )
                          : Image.asset(
                        'assets/images/placeholder_property.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  // MENU
                  if (isOwner)
                    Positioned(
                      top: 10.h,
                      right: 10.w,
                      child: _menuButton(),
                    ),

                  // PRICE
                  Positioned(
                    bottom: 10.h,
                    left: 10.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.75),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Text(
                        plot.formattedPrice,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // =======================
              // DETAILS
              // =======================

              Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // NAME
                    Text(
                      plot.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    SizedBox(height: 4.h),

                    // LOCATION
                    Text(
                      plot.location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    SizedBox(height: 8.h),

                    // AREA + VERIFY BUTTON
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [

                        Text(
                          plot.formattedArea,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        // SHOW VERIFY BUTTON ONLY IF NOT PAID
                        if (isOwner && !isPaid)
                          GestureDetector(
                            onTap: onVerify,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12.w, vertical: 6.h),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.verified,
                                      size: 12.sp, color: Colors.orange),
                                  SizedBox(width: 4.w),
                                  Text(
                                    "Verify to pay",
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.orange,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),

                    SizedBox(height: 10.h),

                    // =======================
                    // BADGES
                    // =======================

                    Wrap(
                      spacing: 8.w,
                      runSpacing: 6.h,
                      children: [

                        // VERIFIED STATUS
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.w, vertical: 5.h),
                          decoration: BoxDecoration(
                            color: verifyBadgeColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                plot.verifyStatus == 1
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                size: 12.sp,
                                color: verifyBadgeColor,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                verifyBadgeText,
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w600,
                                  color: verifyBadgeColor,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // SHOW ONLY WHEN PAID
                        if (isPaid)
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.w, vertical: 5.h),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.verified,
                                    size: 12.sp, color: Colors.green),
                                SizedBox(width: 4.w),
                                Text(
                                  "Paid",
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
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
      ),
    );
  }

  // =======================
  // MENU
  // =======================

  Widget _menuButton() {
    return Container(
      height: 30.w,
      width: 30.w,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        shape: BoxShape.circle,
      ),
      child: PopupMenuButton<String>(
        padding: EdgeInsets.zero,
        icon: Icon(Icons.more_vert, size: 18.sp),
        onSelected: (val) {
          if (val == 'edit') onEdit?.call();
          if (val == 'delete') onDelete?.call();
        },
        itemBuilder: (context) => [
          _menuItem('edit', Icons.edit, "Edit"),
          _menuItem('delete', Icons.delete, "Delete", isRed: true),
        ],
      ),
    );
  }

  PopupMenuItem<String> _menuItem(String val, IconData icon, String text,
      {bool isRed = false}) {
    return PopupMenuItem(
      value: val,
      child: Row(
        children: [
          Icon(icon,
              size: 16.sp, color: isRed ? Colors.red : Colors.black),
          SizedBox(width: 8.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 13.sp,
              color: isRed ? Colors.red : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}