import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../animations/arrowlines.dart';
import '../../../common/colours.dart';
import '../../../common/images.dart';
import '../../home/widget/sub_title.dart';
class GioSchemeOverview extends StatelessWidget {
  const GioSchemeOverview({super.key});
  final List<Map<String, dynamic>> _schemeItems = const [
    {
      'image': Images.selectSlot,
      'title': 'Select Your Slot',
    },
    {
      'image': Images.getPayment,
      'title': 'Get Payment Verified',
    },
    {
      'image': Images.registrationProcess,
      'title': 'Registration Process',
    },
    {
      'image': Images.plotRegistered,
      'title': 'Plot Registered',
    },
  ];
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(8.w),
          child: SubtitleWidget(
            showViewAll: false,
            title: "How it's Works",
            highlightWord: "Works",
            onViewAllTap: () {
              print("View All clicked");
            },
          ),
        ),
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 8.r,
                offset: const Offset(0, 2),
              ),
            ],
            image: DecorationImage(
              image: AssetImage(Images.appbarBg),
              fit: BoxFit.cover,
            ),
          ),
          child: _buildTimeline(),
        ),      ],
    );
  }
  Widget _buildTimeline() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          height: 60.h,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                top: 25.h,
                bottom: 25.h,
                left: 25.w,
                right: 25.w,
                child: ArrowLine(),
              ),
              Positioned.fill(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: List.generate(
                    _schemeItems.length,
                        (i) => _buildAvatar(_schemeItems[i], i),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 5,),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(_schemeItems.length, (index) {
            return Expanded(
              child: Center(
                child: Text(
                  _schemeItems[index]['title'],
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColor.black,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2, // allow wrapping
                  overflow: TextOverflow.ellipsis,
                )
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.2, end: 0)
                    .then(delay: (index * 200).ms),
              ),
            );
          }),
        ),
      ],
    );
  }
  Widget _buildAvatar(Map<String, dynamic> item, int index) {
    return Container(
        width: 50.w,
        height: 50.h,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColor.primary, width: 2.w),
          boxShadow: [
            BoxShadow(
              color: AppColor.primary.withOpacity(0.3),
              blurRadius: 8.r,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: CircleAvatar(
          radius: 28,
          backgroundColor: AppColor.white,
          child: ClipOval(
            child: Image.asset(
              item['image'],
              width: 30,
              height: 30,
              fit: BoxFit.contain, // image shrinks inside
            ),
          ),
        )

    )
        .animate()
        .scale(begin: const Offset(0.3, 0.3), end: const Offset(1, 1))
        .fadeIn(duration: 400.ms)
        .then(delay: (index * 200).ms);
  }
}

