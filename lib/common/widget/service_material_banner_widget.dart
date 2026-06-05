import 'package:cashback_farms/common/colours.dart';
import 'package:cashback_farms/features/material_store/screens/add_materials_screen.dart';
import 'package:cashback_farms/features/service/screen/add_service_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ServiceMaterialBanner {
  final int id;
  final String title;
  final String image;
  final String createdAt;
  final String updatedAt;

  ServiceMaterialBanner({
    required this.id,
    required this.title,
    required this.image,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ServiceMaterialBanner.fromJson(Map<String, dynamic> json) {
    return ServiceMaterialBanner(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      image: json['image'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  void navigate() {
    final t = title.toLowerCase();
    if (t.contains('service')) {
      Get.to(() => const AddServiceScreen());
    } else if (t.contains('material')) {
      Get.to(() => const AddMaterialsScreen());
    }
  }

  bool get isService => title.toLowerCase().contains('service');
  bool get isMaterial => title.toLowerCase().contains('material');
}


class ServiceBanner extends StatelessWidget {
  final List<ServiceMaterialBanner> banners;
  const ServiceBanner({super.key, required this.banners});

  @override
  Widget build(BuildContext context) {
    final serviceBanners = banners.where((b) => b.isService).toList();
    if (serviceBanners.isEmpty) return const SizedBox.shrink();
    return _BannerCard(banner: serviceBanners.first);
  }
}

class MaterialBanner extends StatelessWidget {
  final List<ServiceMaterialBanner> banners;
  const MaterialBanner({super.key, required this.banners});

  @override
  Widget build(BuildContext context) {
    final materialBanners =
    banners.where((b) => b.isMaterial).toList();
    if (materialBanners.isEmpty) return const SizedBox.shrink();
    return _BannerCard(banner: materialBanners.first);
  }
}


class _BannerCard extends StatelessWidget {
  final ServiceMaterialBanner banner;
  const _BannerCard({required this.banner});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => banner.navigate(),
      child: Container(
        width: double.infinity,
        height: 160.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14.r),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                banner.image,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey.shade100,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_badgeIcon,
                          size: 32.sp, color: Colors.grey.shade400),
                      SizedBox(height: 8.h),
                      Text(
                        banner.title,
                        style: TextStyle(
                            fontSize: 12.sp, color: Colors.grey.shade500),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                loadingBuilder: (_, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    color: Colors.grey.shade100,
                    child: Center(
                      child: SizedBox(
                        width: 22.w,
                        height: 22.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: _badgeColor.withOpacity(0.5),
                        ),
                      ),
                    ),
                  );
                },
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.3),
                      ],
                      stops: const [0.6, 1.0],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 14.h,
                left: 14.w,
                right: 14.w,
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: _badgeColor,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Click Here",
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Icon(Icons.arrow_forward_ios_rounded,
                              size: 10.sp, color: Colors.white),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              //
              // Positioned(
              //   top: 10.h,
              //   left: 10.w,
              //   child: Container(
              //     padding: EdgeInsets.symmetric(
              //         horizontal: 10.w, vertical: 4.h),
              //     decoration: BoxDecoration(
              //       color: _badgeColor.withOpacity(0.88),
              //       borderRadius: BorderRadius.circular(20.r),
              //     ),
              //     child: Row(
              //       mainAxisSize: MainAxisSize.min,
              //       children: [
              //         Icon(_badgeIcon, size: 11.sp, color: Colors.white),
              //         SizedBox(width: 4.w),
              //         Text(
              //           _badgeLabel,
              //           style: TextStyle(
              //             fontSize: 10.sp,
              //             color: Colors.white,
              //             fontWeight: FontWeight.w700,
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Color get _badgeColor =>
      banner.isMaterial ? Colors.orange.shade700 : AppColor.primary;

  IconData get _badgeIcon => banner.isMaterial
      ? Icons.inventory_2_rounded
      : Icons.miscellaneous_services_rounded;

  String get _badgeLabel => banner.isMaterial ? 'Materials' : 'Services';

  String _capitalize(String text) => text
      .split(' ')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');
}