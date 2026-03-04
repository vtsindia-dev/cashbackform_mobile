// Updated ServiceList widget
import 'package:cashback_farms/features/service/widget/service_product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../common/widget/loader.dart';
import '../controller/service_controller.dart';
import 'enquiry_form.dart';

class ServiceList extends StatelessWidget {
  final ServiceController controller = Get.put(ServiceController());

  ServiceList({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final services = controller.services;

      if (controller.isLoading.value && services.isEmpty) {
        return const Center(child: GifLoader(message: "Loading Services...", size: 100));

      }

      return NotificationListener<ScrollNotification>(
        onNotification: (scrollInfo) {
          if (scrollInfo.metrics.pixels >=
              scrollInfo.metrics.maxScrollExtent * 0.95 &&
              !controller.isLoadMore.value &&
              controller.hasMoreData.value) {
            controller.loadMoreServices();
          }
          return false;
        },
        child: ListView.builder(
          itemCount: services.length + (controller.hasMoreData.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == services.length) {
              return controller.isLoadMore.value
                  ? Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h),
                child: Center(
                  child: CircularProgressIndicator(
                    color: Colors.green,
                    strokeWidth: 2,
                  ),
                ),
              )
                  : SizedBox.shrink();
            }
            final service = services[index];

            return _buildAnimatedCard(service, index);
          },
        ),
      );
    });
  }

  Widget _buildAnimatedCard(service, int index) {
    return ServiceCard(
      service: service,
      onTap: () {
          _showEnquiryForm(service);
      },
      onEnquiry: () {
        _showEnquiryForm(service);
      },
      onShare: () {
        _shareService(service);
      },
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slide(begin: const Offset(0, 0.20), duration: 450.ms)
        .scale(begin: const Offset(0.92, 0.92), duration: 450.ms)
        .then(delay: (index * 50).ms);
  }

  void _showEnquiryForm(service) {
    Get.bottomSheet(
      ServiceEnquiryForm(
        serviceName: service.serviceName,
        serviceId: service.id,
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25.r),
          topRight: Radius.circular(25.r),
        ),
      ),
      enableDrag: true,
    );
  }

  void _sharematerial(service) {

  }
  void _shareService(service) {
    // Implement share functionality
    final shareMessage = "Check out this Service: ${service.serviceName}\n";
    print("Sharing: $shareMessage");

    // You can use share_plus package for actual sharing
    // Share.share(shareMessage);
  }
}