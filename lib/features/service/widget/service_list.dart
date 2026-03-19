import 'package:cashback_farms/common/colours.dart';
import 'package:cashback_farms/common/route/router.dart';
import 'package:cashback_farms/common/widget/appbar.dart';
import 'package:cashback_farms/common/widget/loader.dart';
import 'package:cashback_farms/features/service/controller/service_controller.dart' show ServiceController;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/service_model.dart' as vendor;


class ServiceList extends StatefulWidget {
  final int? id;
  final String? title;

  const ServiceList({super.key, this.id, this.title});

  @override
  State<ServiceList> createState() => _ServiceListState();
}

class _ServiceListState extends State<ServiceList> {
  final ServiceController controller = Get.put(ServiceController());
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchVendors(
        selectedCategoryId: widget.id.toString(),
      );
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200 &&
          !controller.isFetchingMoreVendors &&
          controller.vendorCurrentPage < controller.vendorTotalPages) {

        controller.loadMoreVendors(
           selectedCategoryId: widget.id.toString(),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DynamicAppBar(
        title: widget.title ?? '',
        showBackButton: true,
      ),
      body: GetBuilder<ServiceController>(
        builder: (controller) {
          if (controller.isVendorLoading) {
            return const Center(child: GifLoader());
          }
          if (controller.vendorList.isEmpty) {
            return const Center(child: Text("No Vendors Found"));
          }
          return RefreshIndicator(
            onRefresh: () async {
              await controller.fetchVendors(
                selectedCategoryId: widget.id.toString(),
              );
            },
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: controller.vendorList.length +
                  (controller.isFetchingMoreVendors ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == controller.vendorList.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                final vendor = controller.vendorList[index];
                return _buildVendorCard(vendor);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildVendorCard(vendor.Vendor vendor) {
    final String imageUrl =
    (vendor.thumbnail != null && vendor.thumbnail!.isNotEmpty)
        ? vendor.thumbnail!
        : "";
    final double rating = double.tryParse(vendor.reviewsAvgRating ?? "0") ?? 0;

    return Container(
      height: 220,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 130,
              height: double.infinity,
              color: Colors.grey.shade100,
              child: imageUrl.isNotEmpty
                  ? Image.network(imageUrl, fit: BoxFit.cover)
                  : const Icon(Icons.store, color: Colors.grey, size: 40),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      vendor.name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        _buildRatingStars(rating),
                        const SizedBox(width: 4),
                        Text(
                          rating.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _buildInfoBadge(Icons.assignment_turned_in, "GST: ${vendor.gst ?? 'N/A'}", Colors.blue),
                        _buildInfoBadge(Icons.timer, vendor.estimateDate ?? "No Est.", Colors.orange),
                      ],
                    ),
                    _buildIconText(Icons.phone, vendor.phone, Colors.green),
                    _buildIconText(Icons.location_on, vendor.address ?? "No Address", Colors.grey),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Get.toNamed(
                            AppRoutes.vendorDataDetail,
                            arguments: {
                              "id": vendor.userId.toString(),
                              "title": vendor.name,
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        child: const Text("View Details",style: TextStyle(fontWeight: FontWeight.w600),),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBadge(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildIconText(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: color, fontSize: 13),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildRatingStars(double rating) {
    return Row(
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return const Icon(Icons.star, color: Colors.orange, size: 16);
        } else if (index < rating) {
          return const Icon(Icons.star_half,
              color: Colors.orange, size: 16);
        } else {
          return const Icon(Icons.star_border,
              color: Colors.orange, size: 16);
        }
      }),
    );
  }
}

// void _showEnquiryForm(Vendor service) {
//   Get.bottomSheet(
//     ServiceEnquiryForm(serviceName: service.name, serviceId: service.id),
//     isScrollControlled: true,
//     backgroundColor: Colors.transparent,
//     barrierColor: Colors.black54,
//     shape: RoundedRectangleBorder(
//       borderRadius: BorderRadius.only(
//         topLeft: Radius.circular(25.r),
//         topRight: Radius.circular(25.r),
//       ),
//     ),
//     enableDrag: true,
//   );
// }
//
// void _shareService(Vendor service) {
//   final shareMessage = "Check out this Service: ${service.name}\n";
//   print("Sharing: $shareMessage");
// }