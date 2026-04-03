import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import 'package:cashback_farms/common/colours.dart';

class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white,
                AppColor.primary.withOpacity(0.08),
              ],
            ),
          ),
          child: Stack( // Using Stack to allow the character to move freely
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // The Running Character with Loop Movement
                    SizedBox(
                      height: 180.h,
                      width: double.infinity,
                      child: Lottie.asset(
                        'assets/images/running_animation.json',
                        repeat: true,
                        fit: BoxFit.contain,
                      ),
                    )
                        .animate(onPlay: (controller) => controller.repeat())
                        .moveX(
                      begin: -ScreenUtil().screenWidth, // Start off-screen left
                      end: ScreenUtil().screenWidth,   // End off-screen right
                      duration: 4.seconds,             // Adjust speed here
                      curve: Curves.linear,
                    ),

                    SizedBox(height: 40.h),

                    // Text Content
                    Text(
                      'Searching for Signal...',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                    ).animate().fadeIn(duration: 800.ms),

                    SizedBox(height: 12.h),

                    Text(
                      'We\'re trying to get you back online.\nDon\'t go too far!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: Colors.grey[500],
                        height: 1.5,
                      ),
                    ).animate(delay: 300.ms).fadeIn(),

                    SizedBox(height: 50.h),

                    // Status Pill
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30.r),
                        boxShadow: [
                          BoxShadow(
                            color: AppColor.primary.withOpacity(0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 14.w,
                            height: 14.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(AppColor.primary),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Text(
                            'Retrying...',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColor.primary,
                            ),
                          ),
                        ],
                      ),
                    ).animate().scale(delay: 600.ms, curve: Curves.elasticOut),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}