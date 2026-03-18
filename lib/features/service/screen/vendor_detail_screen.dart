import 'package:cashback_farms/common/widget/loader.dart';
import 'package:cashback_farms/features/service/controller/service_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VendorDataDetailScreen extends StatefulWidget {
  final String vendorId;
  final String vendorTitle;

  const VendorDataDetailScreen({super.key, required this.vendorId, required this.vendorTitle});

  @override
  State<VendorDataDetailScreen> createState() => _VendorDataDetailScreenState();
}

class _VendorDataDetailScreenState extends State<VendorDataDetailScreen> {

  final ServiceController controller = Get.put(ServiceController());


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchVendorDetail(id: widget.vendorId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ServiceController>(
      builder: (controller) {
        if (controller.isVendorDetailLoading) {
          return const Scaffold(
            body: Center(child: GifLoader()),
          );
        }

        final vendor = controller.vendorDetail;

        if (vendor == null) {
          return const Scaffold(
            body: Center(child: Text("No Vendor Found")),
          );
        }

        final imageUrl = (vendor.thumbnail != null &&
            vendor.thumbnail!.isNotEmpty)
            ? vendor.thumbnail!
            : (vendor.image.isNotEmpty ? vendor.image.first : "");

        final rating =
            double.tryParse(vendor.reviewsAvgRating ?? "0") ?? 0;

        return DefaultTabController(
          length: 3,
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: const BackButton(color: Colors.black),
              title: Text(
                vendor.name,
                style: const TextStyle(color: Colors.black),
              ),
            ),
            body: Column(
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: imageUrl.isNotEmpty
                        ? DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    )
                        : null,
                    color: Colors.grey.shade200,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vendor.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.star,
                              color: Colors.orange.shade400, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            rating.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        vendor.address ?? "",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const TabBar(
                  labelColor: Colors.blue,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.blue,
                  tabs: [
                    Tab(text: "Product"),
                    Tab(text: "Service"),
                    Tab(text: "Photos"),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildEmpty("No Products"),
                      ListView.builder(
                        itemCount:
                        vendor.vendorServices?.length ?? 0,
                        itemBuilder: (context, index) {
                          final service =
                              vendor.vendorServices![index].service;

                          return ListTile(
                            leading: Image.network(
                              service.image.first,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                            title: Text(service.serviceName),
                          );
                        },
                      ),
                      GridView.builder(
                        padding: const EdgeInsets.all(10),
                        gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: vendor.image.length,
                        itemBuilder: (context, index) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              vendor.image[index],
                              fit: BoxFit.cover,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmpty(String text) {
    return Center(
      child: Text(
        text,
        style: const TextStyle(color: Colors.grey),
      ),
    );
  }
}