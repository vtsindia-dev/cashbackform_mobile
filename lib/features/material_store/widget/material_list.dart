import 'package:cashback_farms/features/material_store/controller/materialstore_controller.dart';
import 'package:flutter/material.dart' hide Material;
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../common/widget/loader.dart';
import '../model/material_store.dart';
import 'materialcard.dart';

class MaterialListScreen extends StatelessWidget {
  final MaterialController controller = Get.find<MaterialController>();

  MaterialListScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final materials = controller.materials;
      if (controller.isLoading.value && materials.isEmpty) {
        return const Center(
          child: GifLoader(
            message: "Loading materials...",
            size: 100,
          ),
        );
      }
      if (materials.isEmpty && !controller.isLoading.value) {
        return _buildEmptyState();
      }
      final rowCount = (materials.length / 2).ceil();
      return RefreshIndicator(
        onRefresh: () => controller.refreshData(),
        color: const Color(0xFF7FA93C),
        child: NotificationListener<ScrollNotification>(
          onNotification: (scrollNotification) {
            if (!controller.hasMore.value ||
                controller.isLoading.value ||
                materials.isEmpty) {
              return false;
            }
            if (scrollNotification.metrics.pixels >=
                scrollNotification.metrics.maxScrollExtent * 0.8) {
              controller.loadMoreMaterials();
            }
            return false;
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: rowCount + (controller.hasMore.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == rowCount) {
                return _buildLoadingIndicator();
              }
              final leftIndex = index * 2;
              final rightIndex = leftIndex + 1;
              if (leftIndex >= materials.length) {
                return const SizedBox.shrink();
              }
              final leftMaterial = materials[leftIndex];
              final rightMaterial = rightIndex < materials.length
                  ? materials[rightIndex]
                  : null;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildCard(leftMaterial),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: rightMaterial != null
                          ? _buildCard(rightMaterial)
                          : _buildEmptyCardPlaceholder(),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );
    });
  }

  Widget _buildCard(MaterialModel material) {
    return MaterialCard(
      imageUrl: material.image.isNotEmpty
          ? material.image.first
          : 'https://via.placeholder.com/300x200?text=No+Image',
      name: material.materialName.isNotEmpty
          ? material.materialName
          : 'Unnamed Material',
      category: material.category?.categoryName ?? 'Uncategorized',
      status: material.status == 1 ? "Active" : "Inactive",
      createdDate: material != null
          ? _formatDate(DateTime.fromMillisecondsSinceEpoch(material.id! as int))
          : 'N/A',
      description: material.description ?? 'No description available',
      onTap: () {
        _navigateToMaterialDetail(material.id);
      },
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slide(begin: const Offset(0, 0.2), duration: 500.ms)
        .scale(begin: const Offset(0.9, 0.9), duration: 500.ms);
  }

  Widget _buildEmptyCardPlaceholder() {
    return Container(
      height: 200, // Match your MaterialCard height
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Text(''),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Column(
          children: [
            const CircularProgressIndicator(
              color: Color(0xFF7FA93C),
            ),
            const SizedBox(height: 8),
            Text(
              'Loading more materials...',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Materials Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for new materials',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => controller.refreshData(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7FA93C),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            ),
            child: const Text(
              'Refresh',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  void _navigateToMaterialDetail(int materialId) {
    controller.fetchVendorsForMaterial(materialId);
    Get.toNamed(
      '/VendorListScreen',
      arguments: {
        'materialId': materialId,
        'materialName' : 'Vendor List',
      },
    );
  }
}

// Optional: Add a search and filter header widget
class MaterialListHeader extends StatelessWidget {
  final MaterialController controller;
  final VoidCallback onSearchTap;

  const MaterialListHeader({
    super.key,
    required this.controller,
    required this.onSearchTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onSearchTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      'Search materials...',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

        ],
      ),
    );
  }


  Widget _buildFilterOption(String label, VoidCallback onTap) {
    return ListTile(
      title: Text(label),
      onTap: onTap,
      dense: true,
    );
  }
}