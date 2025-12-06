import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/widget/appbar.dart';
import '../../../common/widget/loader.dart';
import '../controller/materialstore_controller.dart';
import '../widget/material_aboutus.dart';

class MarketDetails extends StatefulWidget {
  final int id;

  const MarketDetails({super.key, required this.id});

  @override
  State<MarketDetails> createState() => _MarketDetailsState();
}

class _MarketDetailsState extends State<MarketDetails> {
  final MaterialController controller = Get.find<MaterialController>();

  @override
  void initState() {
    super.initState();
    controller.fetchMaterialDetail(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DynamicAppBar(
        title: "Product Details",
        showBackButton: true,
      ),
      body: Obx(() {
        if (controller.isLoadingDetail.value) {
          return const Center(
            child: GifLoader(message: "Loading product details...", size: 100),
          );
        }

        if (controller.materialDetail.value == null) {
          return _buildNoDataAvailable();
        }

        final material = controller.materialDetail.value!;
        final relatedProducts = controller.getMaterialsByCategory(
          material.category?.categoryName ?? '',
        ).where((product) => product.id != material.id).toList();

        return MarketDescriptionContent(
          material: material,
          relatedProducts: relatedProducts,
          onSharePressed: () {
            // Handle share
            Get.snackbar(
              'Share',
              'Sharing ${material.materialName}',
              backgroundColor: Colors.blue[100],
              colorText: Colors.black,
            );
          },
        );
      }),
    );
  }

  Widget _buildNoDataAvailable() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 60, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            "No Product Details Available",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Unable to load product information",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => controller.fetchMaterialDetail(widget.id),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7FA93C),
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            ),
            child: Text(
              "Retry",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}