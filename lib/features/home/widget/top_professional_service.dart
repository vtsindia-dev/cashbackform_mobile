import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../service/widget/service_card.dart';
import '../controller/homecontroller.dart';

class TopProfessionalService extends StatelessWidget {
  TopProfessionalService({super.key});

  final HomeController controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return GetX<HomeController>(
      builder: (controller) {
        return SizedBox(
          height: 230,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 0),
            itemCount: controller.services.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final item = controller.services[index];
              return ServiceCard(
                imageUrl: item["image"]!,
                title: item["title"]!,
                width: 170,
                height: 230,
                onTap: () {
                  print("Tapped → ${item["title"]}");
                },
              );
            },
          ),
        );
      },
    );
  }
}
