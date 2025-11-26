import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/widget/loader.dart';
import '../controller/syndicate_controller.dart';
import '../model/syndicate_model.dart';

class SyndicateDetails extends StatelessWidget {
  final int? id;
  const SyndicateDetails({super.key, this.id});

  @override
  Widget build(BuildContext context) {
    final SyndicatePlotController controller = Get.put(SyndicatePlotController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (id != null) {
        controller.fetchSyndicateDetail(id!);
      }
    });
    return Scaffold(
      appBar: AppBar(
        title: const Text('Syndicate Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: id != null ? () => controller.fetchSyndicateDetail(id!) : null,
          ),
        ],
      ),
      body: GetBuilder<SyndicatePlotController>(
        init: controller,
        builder: (controller) {
          if (controller.isLoading.value) {
            return const Center(child: GifLoader(message: "Loading...", size: 100));
          }
          if (controller.errorMessage.value.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    controller.errorMessage.value,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: id != null ? () => controller.fetchSyndicateDetail(id!) : null,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final detail = controller.syndicateDetail.value;
          if (detail == null) {
            return const Center(child: Text('No details available'));
          }

          return _buildDetailContent(detail);
        },
      ),
    );
  }

  Widget _buildDetailContent(SyndicateDetail detail) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: NetworkImage(detail.image),
                fit: BoxFit.cover,
              ),
            ),
          ),

          const SizedBox(height: 16),

          Text(
            detail.name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          Text(
            '${detail.city?.cityName ?? ''}, ${detail.state?.stateName ?? ''}',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildInfoItem('Price', '₹${detail.price}'),
              const SizedBox(width: 16),
              _buildInfoItem('Area', '${detail.area} sq.ft'),
            ],
          ),

          const SizedBox(height: 16),

          // Unit Split
          _buildInfoItem('Unit Split', '${detail.unitSpilt} units'),

          const SizedBox(height: 16),

          // Description
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Description',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(detail.description),
            ],
          ),

          const SizedBox(height: 16),

          // Address
          _buildInfoItem('Address', detail.address),

          const SizedBox(height: 16),

          // Work
          if (detail.work.isNotEmpty)
            _buildInfoItem('Work', detail.work),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}