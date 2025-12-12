import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../service/widget/service_card.dart';
import '../controller/homecontroller.dart';

class MaterialCategory extends StatelessWidget {
  MaterialCategory({super.key});

  final HomeController controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return GetX<HomeController>(
      builder: (controller) {
        return SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 0),
            itemCount: controller.materials.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final item = controller.materials[index];
              return ServiceCard(
                imageUrl: item["image"]!,
                title: item["title"]!,
                width: 170,
                height: 140,
                isAsset: false,
                onTap: () {
                  print("Tapped → ${item["title"]}");
                },
              )
                  .animate()
                  .slideX(
                begin: -0.5,
                end: 0,
                duration: 600.ms,
                curve: Curves.easeOutCubic,
              )
                  .fadeIn(duration: 500.ms)
                  .scale(
                begin: const Offset(0.9, 0.9),
                end: const Offset(1, 1),
                duration: 600.ms,
                curve: Curves.easeOutBack,
              )
                  .then(delay: (index * 200).ms)
                  .shimmer(
                duration: 800.ms,
                color: Colors.white.withOpacity(0.3),
              );
            },
          ),
        );
      },
    );
  }
}