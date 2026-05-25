import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../common/colours.dart';
import '../../../common/widget/appbar.dart';
import '../../../common/widget/loader.dart';
import '../controller/service_controller.dart';
import '../model/service_model.dart' show ServiceEnquiry;

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchServiceEnquiries();
    });
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
      controller.fetchServiceEnquiries(loadMore: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: DynamicAppBar(
        title: "My Services",
        showBackButton: true,
        backgroundColor: Colors.white,
      ),
      body: Obx(() {
        if (controller.isLoading.value &&
            controller.serviceEnquiries.isEmpty) {
          return Center(child: GifLoader(message: "Loading...", size: 100));
        }
        if (controller.serviceEnquiries.isEmpty &&
            !controller.isLoading.value) {
          return _buildEmptyState();
        }
        return RefreshIndicator(
          onRefresh: () async => controller.fetchServiceEnquiries(loadMore: false),
          color: AppColor.primary,
          child: ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            itemCount: controller.serviceEnquiries.length +
                (controller.isLoadMore.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == controller.serviceEnquiries.length) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: Center(
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColor.primary),
                  ),
                );
              }
              return _buildCard(controller.serviceEnquiries[index]);
            },
          ),
        );
      }),
    );
  }

  // ── Compact Card ────────────────────────────────────────────────────────────

  Widget _buildCard(ServiceEnquiry enquiry) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showEnquiryDetails(enquiry),
        borderRadius: BorderRadius.circular(14.r),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Thumbnail ────────────────────────────────────────────────
              ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child: SizedBox(
                  width: 70.w,
                  height: 70.w,
                  child: enquiry.service?.image.isNotEmpty == true
                      ? CachedNetworkImage(
                    imageUrl: enquiry.service!.image.first,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      color: Colors.grey[100],
                      child: Icon(Icons.build_circle_outlined,
                          size: 24.sp, color: Colors.grey[400]),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      color: Colors.grey[100],
                      child: Icon(Icons.build_circle_outlined,
                          size: 24.sp, color: Colors.grey[400]),
                    ),
                  )
                      : Container(
                    color: Colors.grey[100],
                    child: Icon(Icons.build_circle_outlined,
                        size: 24.sp, color: Colors.grey[400]),
                  ),
                ),
              ),
              SizedBox(width: 12.w),

              // ── Content ──────────────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title + Status
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            enquiry.service?.serviceName ??
                                'Service #${enquiry.serviceId}',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1A1D2E),
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        _buildStatusBadge(enquiry.enquiryStatus),
                      ],
                    ),
                    SizedBox(height: 6.h),

                    // Meta row: agent, date, ID
                    Wrap(
                      spacing: 10.w,
                      runSpacing: 4.h,
                      children: [
                        if (enquiry.agentname.isNotEmpty)
                          _buildMeta(Icons.person_outline,
                              enquiry.agentname),
                        _buildMeta(Icons.access_time_rounded,
                            _formatDate(enquiry.createdAt)),
                        _buildMeta(Icons.tag_rounded, '#${enquiry.id}'),
                      ],
                    ),
                    SizedBox(height: 8.h),

                    // Quote
                    if (enquiry.quote.isNotEmpty)
                      Text(
                        enquiry.quote,
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          color: const Color(0xFF6B7280),
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),

              // ── Arrow ────────────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.only(top: 2.h),
                child: Icon(Icons.chevron_right_rounded,
                    size: 18.sp, color: Colors.grey[400]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMeta(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11.sp, color: const Color(0xFF9CA3AF)),
        SizedBox(width: 3.w),
        Text(
          text,
          style: TextStyle(
            fontSize: 11.sp,
            color: const Color(0xFF9CA3AF),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'accepted':
        color = const Color(0xFF10B981);
        break;
      case 'assigned':
        color = const Color(0xFFF59E0B);
        break;
      default:
        color = const Color(0xFF9CA3AF);
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 9.sp,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  // ── Empty State ─────────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                color: AppColor.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.build_circle_outlined,
                  size: 38.sp, color: AppColor.primary),
            ),
            SizedBox(height: 20.h),
            Text(
              'No Service Enquiries',
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1D2E),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'You haven\'t made any service\nenquiries yet.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13.sp,
                  color: const Color(0xFF6B7280),
                  height: 1.5),
            ),
            SizedBox(height: 28.h),
            ElevatedButton.icon(
              onPressed: () =>  controller.fetchServiceEnquiries(loadMore: false),
              icon: const Icon(Icons.refresh,color: Colors.white,),
              label: const Text('Refresh',style: TextStyle(color: Colors.white),),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: 24.w,
                  vertical: 12.h,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                backgroundColor: AppColor.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Detail Bottom Sheet ─────────────────────────────────────────────────────

  void _showEnquiryDetails(ServiceEnquiry enquiry) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 28.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 36.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),

            // Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    enquiry.service?.serviceName ?? 'Service Details',
                    style: TextStyle(
                        fontSize: 16.sp, fontWeight: FontWeight.w700),
                  ),
                ),
                _buildStatusBadge(enquiry.enquiryStatus),
              ],
            ),
            SizedBox(height: 16.h),

            // Details
            _buildDetailRow('Enquiry ID', '#${enquiry.id}'),
            if (enquiry.shopName.isNotEmpty)
              _buildDetailRow('Shop', enquiry.shopName),
            if (enquiry.agentname.isNotEmpty)
              _buildDetailRow('Agent', enquiry.agentname),
            if (enquiry.quote.isNotEmpty)
              _buildDetailRow('Quote', enquiry.quote),
            if (enquiry.datePreference != null)
              _buildDetailRow('Date Pref', enquiry.datePreference!),
            if (enquiry.timePreference != null)
              _buildDetailRow('Time Pref', enquiry.timePreference!),
            _buildDetailRow('Submitted', _formatDate(enquiry.createdAt)),

            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r)),
                  elevation: 0,
                ),
                child: Text('Close',
                    style: TextStyle(
                        fontSize: 14.sp, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 85.w,
            child: Text(
              label,
              style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF6B7280)),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                  fontSize: 12.sp, color: const Color(0xFF1A1D2E)),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 7) return '${date.day}/${date.month}/${date.year}';
    if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    }
    if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    }
    if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    }
    return 'Just now';
  }
}