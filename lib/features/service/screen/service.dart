import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/widget/appbar.dart';
import '../../../common/widget/loader.dart';
import '../controller/service_controller.dart';
import '../widget/service_list.dart';

class Service extends StatefulWidget {
  const Service({super.key});

  @override
  State<Service> createState() => _ServiceState();
}

class _ServiceState extends State<Service> {
  // Controller instance
  final ServiceController controller = Get.put(ServiceController());

  @override
  void initState() {
    super.initState();
    controller.fetchServices(); // Fetch services when widget initializes
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DynamicAppBar(
        title: "Service",
        showBackButton: false,
      ),
      body: Obx(() {
        // Show loader until data is fetched
        if (controller.isLoading.value) {
          return const Center(
            child: GifLoader(
              message: "Loading...",
              size: 100,
            ),
          );
        }
        if (controller.services.isEmpty) {
          return const Center(
            child: GifLoader(
              message: "Loading...",
              size: 100,
            ),
          );

        }
        // Once data is loaded, show the list
        return ServiceList();
      }),
    );
  }
}
