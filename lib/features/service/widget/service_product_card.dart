import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../common/colours.dart';
import '../model/service_model.dart';

class ServiceCard extends StatelessWidget {
  final Service service;
  final VoidCallback onTap;
  final VoidCallback onShare;
  final VoidCallback onEnquiry;

  ServiceCard({
    super.key,
    required this.service,
    required this.onTap,
    required this.onShare,
    required this.onEnquiry,
  });

  final double imageWidth = 100.w;
  final double imageHeight = 100.h;
  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 14.sp, color: Colors.grey.shade700),
          SizedBox(width: 6.w),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.montserrat(
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          )
        ],
      ),
    );
  }
  Widget _linkRow(IconData icon, String text) {
    final isLink = text == "Get Direction";
    final linkColor = isLink ? AppColor.primary : Colors.grey.shade700;

    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 14.sp, color: linkColor),
          SizedBox(width: 6.w),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.montserrat(
                fontSize: 11.sp,
                fontWeight: isLink ? FontWeight.w600 : FontWeight.w500,
                color: isLink ? AppColor.primary : Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          )
        ],
      ),
    );
  }
  Widget _buildVerifiedBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40.r),
        border: Border.all(color: Colors.green.shade600),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified, size: 14.sp, color: Colors.green),
          SizedBox(width: 4.w),
          Text(
            "verified Service",
            style: GoogleFonts.montserrat(
              fontSize: 9.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          )
        ],
      ),
    ).animate().fade(duration: 350.ms).slideX(begin: -0.1);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4.r,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: InkWell(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14.r),
                  child: Image.network(
                    service.image,
                    width: imageWidth,
                    height: imageHeight,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: imageWidth,
                      height: imageHeight,
                      color: Colors.grey.shade200,
                      child: Icon(Icons.image_not_supported, size: 24.w),
                    ),
                  ),
                ).animate().fade(duration: 300.ms).scaleXY(begin: 0.95),

                SizedBox(height: 8.h),

                _buildVerifiedBadge(),
              ],
            ),

            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          service.serviceName,
                          style: GoogleFonts.montserrat(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      InkWell(
                        onTap: onShare,
                        child: Padding(
                          padding: EdgeInsets.all(4.w),
                          child: Icon(Icons.share,
                              size: 16.sp, color: AppColor.primary),
                        ),
                      ).animate().fade(duration: 200.ms).scaleXY(begin: 0.9),
                    ],
                  ).animate().fade(duration: 300.ms).slideY(begin: 0.1),

                  SizedBox(height: 5.h),
                  if (service.description != null && service.description!.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(bottom: 4.h),
                      child: Text(
                        service.description!,
                        style: GoogleFonts.montserrat(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColor.primary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  _infoRow(Icons.location_on,
                      service.category.categoryName),
                  _infoRow(Icons.email,
                      service.description ?? "No email available"),
                  _infoRow(Icons.language,
                      "greenheapfarms.com"),
                  _linkRow(Icons.directions, "Get Direction"),

                  SizedBox(height: 8.h),

                  /// ENQUIRY BUTTON
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: onEnquiry,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 14.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColor.primary, AppColor.primarylite],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(8.r),
                            boxShadow: [
                              BoxShadow(
                                color: AppColor.primary.withOpacity(0.4),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            "Send Enquiry",
                            style: GoogleFonts.montserrat(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ).animate().fade(duration: 350.ms).slideX(begin: 0.1),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().slideY(begin: 0.1, duration: 400.ms).fade(duration: 400.ms);
  }
}
