import 'package:cashback_farms/features/material_store/controller/materialstore_controller.dart' show MaterialController;
import 'package:flutter/material.dart' hide Material;
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../common/widget/loader.dart';
import '../model/material_store.dart';
import 'materialcard.dart';

class MaterialListScreen extends StatelessWidget {
  final MaterialController controller = Get.put(MaterialController());

  MaterialListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final materials = controller.materials;

      if (controller.isLoading.value && materials.isEmpty) {
        return const Center(child: GifLoader(message: "Loading...", size: 100));
      }

      final rowCount = (materials.length / 2).ceil();

      return NotificationListener<ScrollNotification>(
        onNotification: (scroll) {
          if (!controller.hasMoreData.value || controller.isLoadMore.value) {
            return false;
          }

          // Only trigger when scrolled to 95% and not already loading
          if (scroll.metrics.pixels >= scroll.metrics.maxScrollExtent * 0.95) {
            controller.loadMoreMaterials();
          }
          return false;
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: rowCount + (controller.hasMoreData.value ? 1 : 0),
          itemBuilder: (context, index) {
            // Loading indicator at the end
            if (index == rowCount) {
              return controller.isLoadMore.value
                  ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: CircularProgressIndicator()),
              )
                  : const SizedBox.shrink();
            }

            final leftIndex = index * 2;
            final rightIndex = leftIndex + 1;

            final leftMaterial = materials[leftIndex];
            final rightMaterial =
            rightIndex < materials.length ? materials[rightIndex] : null;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(child: _buildCard(leftMaterial)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: rightMaterial != null
                        ? _buildCard(rightMaterial)
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildCard(Material material) {
    return MaterialCard(
      imageUrl: material.image,
      name: material.materialName,
      category: material.category.categoryName,
      status: material.status == 1 ? "Active" : "Inactive",
      createdDate: material.createdAt.toString().substring(0, 10),
      description: material.description,
      onTap: () {
      },
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slide(begin: const Offset(0, 0.2), duration: 500.ms)
        .scale(begin: const Offset(0.9, 0.9), duration: 500.ms);
  }
}