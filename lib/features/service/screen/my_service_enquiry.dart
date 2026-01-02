import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../common/colours.dart';
import '../../../common/widget/appbar.dart';
import '../../../common/widget/loader.dart';
import '../controller/service_controller.dart';
import '../widget/service_product_card.dart';
class MyServicesList extends StatefulWidget {
  const MyServicesList({super.key});

  @override
  State<MyServicesList> createState() => _MyServicesListState();
}

class _MyServicesListState extends State<MyServicesList> {
  final ServiceController controller = Get.put(ServiceController());
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    controller.fetchMyServices();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100 &&
        !controller.isLoadMore.value &&
        controller.hasMoreData.value) {
      controller.fetchMyServices(loadMore: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundLight,
      appBar: const DynamicAppBar(
        title: "My Services",
        showBackButton: true,
      ),
      body: Obx(() {
        /// Initial loader
        if (controller.isLoading.value && controller.enquiries.isEmpty) {
          return const Center(
            child: GifLoader(
              message: "Loading your services...",
              size: 120,
            ),
          );
        }

        /// Empty state
        if (controller.enquiries.isEmpty && !controller.isLoading.value) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () async {
            await controller.fetchMyServices();
          },
          child: ListView(
            controller: _scrollController,
            padding: EdgeInsets.all(16.w),
            children: [
              _buildHeader(),
              SizedBox(height: 16.h),
              _buildEnquiryList(),
              if (controller.isLoadMore.value) _buildLoadMoreIndicator(),
              if (!controller.hasMoreData.value &&
                  controller.enquiries.isNotEmpty)
                _buildEndOfList(),
            ],
          ),
        );
      }),
    );
  }

  /// HEADER
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColor.primary,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColor.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.handyman, color: Colors.white, size: 24.sp),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "My Services",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                "${controller.enquiries.length} enquiries",
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fade(duration: 300.ms).slide(begin: const Offset(-0.1, 0));
  }

  /// 🔥 USE ENQUIRIES LIST
  Widget _buildEnquiryList() {
    return Column(
      children: List.generate(
        controller.enquiries.length,
            (index) {
          final enquiry = controller.enquiries[index];

          return Card(
            margin: EdgeInsets.only(bottom: 12.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: ListTile(
              leading: const Icon(Icons.assignment),
              title: Text(
                "Material Enquiry #${index + 1}",
                style: TextStyle(fontSize: 14.sp),
              ),
              subtitle: Text(
                "Tap to view details",
                style: TextStyle(fontSize: 12.sp),
              ),
              onTap: () {
                debugPrint("Tapped enquiry index: $index");
              },
            ),
          )
              .animate()
              .fade(duration: 300.ms)
              .slide(begin: const Offset(0, 0.1));
        },
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.h),
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _buildEndOfList() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 24.h),
      child: const Center(
        child: Text('All services loaded'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        'No Services Found',
        style: TextStyle(fontSize: 16.sp),
      ),
    );
  }
}


// class MyServicesList extends StatefulWidget {
//   MyServicesList({super.key});
//
//   @override
//   State<MyServicesList> createState() => _MyServicesListState();
// }
// class _MyServicesListState extends State<MyServicesList> {
//   final ServiceController controller = Get.put(ServiceController());
//   final ScrollController _scrollController = ScrollController();
//   @override
//   void initState() {
//     super.initState();
//     controller.fetchMyServices();
//     _scrollController.addListener(_scrollListener);
//   }
//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }
//   void _scrollListener() {
//     if (_scrollController.position.pixels >=
//         _scrollController.position.maxScrollExtent - 100 &&
//         !controller.isLoadMore.value &&
//         controller.hasMoreData.value) {
//       controller.loadMoreMyServices();
//     }
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColor.backgroundLight,
//       appBar: DynamicAppBar(
//         title: "My Services",
//         showBackButton: true,
//       ),
//       body: Obx(() {
//         if (controller.isLoading.value && controller.myServices.isEmpty) {
//           return Center(
//             child: GifLoader(message: "Loading your services...", size: 120),
//           );
//         }
//         if (controller.myServices.isEmpty && !controller.isLoading.value) {
//           return Center(child: _buildEmptyState());
//         }
//         return RefreshIndicator(
//           onRefresh: () async {
//             await controller.fetchMyServices();
//           },
//           child: ListView(
//             controller: _scrollController,
//             padding: EdgeInsets.all(16.w),
//             children: [
//               _buildHeader(),
//               SizedBox(height: 16.h),
//               _buildServicesList(),
//               if (controller.isLoadMore.value)
//                 _buildLoadMoreIndicator(),
//               if (!controller.hasMoreData.value && controller.myServices.isNotEmpty)
//                 _buildEndOfList(),
//             ],
//           ),
//         );
//       }),
//     );
//   }
//   Widget _buildHeader() {
//     return Container(
//       padding: EdgeInsets.all(16.w),
//       decoration: BoxDecoration(
//         color: AppColor.primary,
//         borderRadius: BorderRadius.circular(12.r),
//         boxShadow: [
//           BoxShadow(
//             color: AppColor.primary.withOpacity(0.3),
//             blurRadius: 10,
//             offset: Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Icon(Icons.handyman, color: Colors.white, size: 24.sp),
//           SizedBox(width: 12.w),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   "My Services",
//                   style: TextStyle(
//                     fontSize: 18.sp,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//                 SizedBox(height: 4.h),
//                 Text(
//                   "${controller.myServices.length} services • ${controller.activeServicesCount} active",
//                   style: TextStyle(
//                     fontSize: 12.sp,
//                     color: Colors.white.withOpacity(0.9),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     ).animate().fade(duration: 300.ms).slide(begin: Offset(-0.1, 0));
//   }
//   Widget _buildServicesList() {
//     return Column(
//       children: controller.myServices.map((service) {
//         return ServiceCard(
//           service: service,
//           onTap: () {
//             print("Tapped service: ${service.serviceName}");
//           },
//           onEnquiry: () {
//             _showEnquiryForm(service);
//           },
//           onShare: () {
//             _shareService(service);
//           },
//         )
//             .animate()
//             .fade(duration: 300.ms)
//             .slide(begin: Offset(0, 0.1))
//             .scale(begin: Offset(0.95, 0.95));
//       }).toList(),
//     );
//   }
//   Widget _buildLoadMoreIndicator() {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 20.h),
//       child: Center(
//         child: Column(
//           children: [
//             CircularProgressIndicator(
//               strokeWidth: 2,
//               color: AppColor.primary,
//             ),
//             SizedBox(height: 12.h),
//             Text(
//               'Loading more  ...',
//               style: TextStyle(
//                 fontSize: 12.sp,
//                 color: AppColor.textSecondary,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//   Widget _buildEndOfList() {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 24.h),
//       child: Center(
//         child: Text(
//           'All services loaded',
//           style: TextStyle(
//             fontSize: 14.sp,
//             color: AppColor.textSecondary,
//           ),
//         ),
//       ),
//     );
//   }
//   Widget _buildEmptyState() {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 60.h, horizontal: 32.w),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.handyman_outlined,
//             size: 80.sp,
//             color: AppColor.primary.withOpacity(0.3),
//           ),
//           SizedBox(height: 24.h),
//           Text(
//             'No Services Found',
//             style: TextStyle(
//               fontSize: 20.sp,
//               fontWeight: FontWeight.bold,
//               color: AppColor.textMain,
//             ),
//           ),
//           SizedBox(height: 12.h),
//           Text(
//             'You haven\'t added any services yet.',
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               fontSize: 14.sp,
//               color: AppColor.textSecondary,
//             ),
//           ),
//           SizedBox(height: 32.h),
//           ElevatedButton(
//             onPressed: () {
//               Get.back();
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColor.primary,
//               foregroundColor: Colors.white,
//               padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12.r),
//               ),
//             ),
//             child: Text(
//               'Browse Services',
//               style: TextStyle(fontSize: 14.sp),
//             ),
//           ),
//         ]
//             .animate(interval: 100.ms)
//             .fade(duration: 400.ms)
//             .slide(begin: Offset(0, 0.1)),
//       ),
//     );
//   }
//   void _showEnquiryForm(service) {
//     print("Enquiry for: ${service.serviceName}");
//   }
//   void _shareService(service) {
//     print("Share service: ${service.serviceName}");
//   }
// }