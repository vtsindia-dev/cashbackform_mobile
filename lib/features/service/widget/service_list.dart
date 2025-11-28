import 'package:cashback_farms/features/service/widget/service_product_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../common/widget/loader.dart';
import '../controller/service_controller.dart';

class ServiceList extends StatelessWidget {
  final ServiceController controller = Get.put(ServiceController());

  ServiceList({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final services = controller.services;

      if (controller.isLoading.value && services.isEmpty) {
        return const Center(child: GifLoader(message: "Loading...", size: 100));
        return const Center(child: GifLoader(message: "Loading...", size: 100));
      }
      if (services.isEmpty) {
        return const Center(
          child: Text("No services found"),
        );
      }
      return NotificationListener<ScrollNotification>(
        onNotification: (scrollInfo) {
          if (scrollInfo.metrics.pixels >=
              scrollInfo.metrics.maxScrollExtent * 0.95 && // Increased to 95% to be more conservative
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
                  ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: Text('Loading...'),),
              )
                  : const SizedBox.shrink();
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
        controller.fetchServiceDetail(service.id);
      },
      onEnquiry: () {
        print("Send Enquiry pressed");
      },
      onShare: () {  },
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slide(begin: const Offset(0, 0.20), duration: 450.ms)
        .scale(begin: const Offset(0.92, 0.92), duration: 450.ms);
  }
}