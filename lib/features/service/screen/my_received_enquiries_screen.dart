import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../common/colours.dart';
import '../../../common/widget/appbar.dart';
import '../../../common/widget/loader.dart';
import '../../company_profile/controller/company_profile_controller.dart';
import '../../company_profile/screen/add_company_profile.dart';
import '../controller/service_controller.dart';
import '../model/received_enquiry_model.dart';

class MyReceivedEnquiriesScreen extends StatefulWidget {
  final bool showServiceTab;
  final bool showMaterialTab;

  const MyReceivedEnquiriesScreen({
    super.key,
    this.showServiceTab = true,
    this.showMaterialTab = true,
  });

  @override
  State<MyReceivedEnquiriesScreen> createState() =>
      _MyReceivedEnquiriesScreenState();
}

class _MyReceivedEnquiriesScreenState extends State<MyReceivedEnquiriesScreen>
    with SingleTickerProviderStateMixin {
  final ServiceController _controller = Get.put(ServiceController());
  final VendorStoreController _storeController = Get.put(VendorStoreController());
  TabController? _tabController;
  final ScrollController _serviceScrollController = ScrollController();
  final ScrollController _materialScrollController = ScrollController();

  bool get _showBoth => widget.showServiceTab && widget.showMaterialTab;

  @override
  void initState() {
    super.initState();
    if (_showBoth) {
      _tabController = TabController(length: 2, vsync: this);
    }
    _serviceScrollController.addListener(_onServiceScroll);
    _materialScrollController.addListener(_onMaterialScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _storeController.fetchStore();
      if (_storeController.store.value != null) {
        if (widget.showServiceTab) _controller.fetchMyServicesEnquiryList();
        if (widget.showMaterialTab) _controller.fetchMyMaterialEnquiryList();
      }
    });
  }

  void _onServiceScroll() {
    if (_serviceScrollController.position.pixels >=
        _serviceScrollController.position.maxScrollExtent - 200) {
      _controller.fetchMyServicesEnquiryList(loadMore: true);
    }
  }

  void _onMaterialScroll() {
    if (_materialScrollController.position.pixels >=
        _materialScrollController.position.maxScrollExtent - 200) {
      _controller.fetchMyMaterialEnquiryList(loadMore: true);
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _serviceScrollController.dispose();
    _materialScrollController.dispose();
    super.dispose();
  }

  String get _appBarTitle {
    if (_showBoth) return 'My Enquiries Received';
    if (widget.showServiceTab) return 'Service Enquiries';
    return 'Material Enquiries';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: DynamicAppBar(
        title: _appBarTitle,
        showBackButton: true,
        backgroundColor: Colors.white,
      ),
      body: Obx(() {
        if (_storeController.isFetching.value) {
          return Center(
            child: GifLoader(message: 'Loading...', size: 100),
          );
        }
        if (_storeController.store.value == null) {
          return _buildCompanyGate();
        }
        return _showBoth ? _buildTabbed() : _buildSingle();
      }),
    );
  }

  Widget _buildCompanyGate() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.store_mall_directory_outlined,
              size: 72.sp,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: 18.h),
            Text(
              'Complete Company Details First',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              'Please add your company/store details before viewing enquiries.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            SizedBox(height: 24.h),
            SizedBox(
              height: 48.h,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await Get.to(() => const VendorStoreView());
                  await _storeController.fetchStore();
                  if (_storeController.store.value != null) {
                    if (widget.showServiceTab) {
                      _controller.fetchMyServicesEnquiryList();
                    }
                    if (widget.showMaterialTab) {
                      _controller.fetchMyMaterialEnquiryList();
                    }
                  }
                },
                icon: const Icon(Icons.add_business_outlined),
                label: const Text(
                  'Add Company Details',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabbed() {
    return Column(
      children: [
        _buildTabBar(),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildServicesList(),
              _buildMaterialsList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSingle() {
    return widget.showServiceTab ? _buildServicesList() : _buildMaterialsList();
  }

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      padding: EdgeInsets.all(3.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFF0F0F0)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: AppColor.primary,
          borderRadius: BorderRadius.circular(9.r),
          boxShadow: [
            BoxShadow(
                color: AppColor.primary.withValues(alpha: 0.25),
                blurRadius: 6,
                offset: const Offset(0, 2)),
          ],
        ),
        labelColor: Colors.white,
        unselectedLabelColor: const Color(0xFF9CA3AF),
        labelStyle:
            TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700),
        unselectedLabelStyle:
            TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500),
        tabs: const [
          Tab(text: 'Services'),
          Tab(text: 'Materials'),
        ],
      ),
    );
  }

  Widget _buildServicesList() {
    return Obx(() {
      if (_controller.isLoadingServiceReceived.value &&
          _controller.myServiceEnquiriesReceived.isEmpty) {
        return Center(
            child: GifLoader(message: 'Loading enquiries...', size: 100));
      }
      if (_controller.myServiceEnquiriesReceived.isEmpty) {
        return _buildEmptyState(
          icon: Icons.miscellaneous_services_rounded,
          title: 'No Service Enquiries',
          subtitle: 'No one has enquired about your services yet.',
          onRefresh: () => _controller.fetchMyServicesEnquiryList(),
        );
      }
      final hasMore = _controller.serviceReceivedHasMore.value;
      final isLoadingMore = _controller.isLoadMoreServiceReceived.value;
      return RefreshIndicator(
        onRefresh: () => _controller.fetchMyServicesEnquiryList(),
        color: AppColor.primary,
        child: ListView.builder(
          controller: _serviceScrollController,
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
          itemCount: _controller.myServiceEnquiriesReceived.length + (hasMore ? 1 : 0),
          itemBuilder: (_, i) {
            if (i == _controller.myServiceEnquiriesReceived.length) {
              return _buildLoadMoreIndicator(isLoadingMore);
            }
            return _buildCard(_controller.myServiceEnquiriesReceived[i]);
          },
        ),
      );
    });
  }

  Widget _buildMaterialsList() {
    return Obx(() {
      if (_controller.isLoadingMaterialReceived.value &&
          _controller.myMaterialEnquiriesReceived.isEmpty) {
        return Center(
            child: GifLoader(message: 'Loading enquiries...', size: 100));
      }
      if (_controller.myMaterialEnquiriesReceived.isEmpty) {
        return _buildEmptyState(
          icon: Icons.settings_input_component_rounded,
          title: 'No Material Enquiries',
          subtitle: 'No one has enquired about your materials yet.',
          onRefresh: () => _controller.fetchMyMaterialEnquiryList(),
        );
      }
      final hasMore = _controller.materialReceivedHasMore.value;
      final isLoadingMore = _controller.isLoadMoreMaterialReceived.value;
      return RefreshIndicator(
        onRefresh: () => _controller.fetchMyMaterialEnquiryList(),
        color: AppColor.primary,
        child: ListView.builder(
          controller: _materialScrollController,
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
          itemCount: _controller.myMaterialEnquiriesReceived.length + (hasMore ? 1 : 0),
          itemBuilder: (_, i) {
            if (i == _controller.myMaterialEnquiriesReceived.length) {
              return _buildLoadMoreIndicator(isLoadingMore);
            }
            return _buildCard(_controller.myMaterialEnquiriesReceived[i]);
          },
        ),
      );
    });
  }

  Widget _buildLoadMoreIndicator(bool isLoading) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Center(
        child: isLoading
            ? SizedBox(
                width: 24.w,
                height: 24.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColor.primary,
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }


  Widget _buildCard(ReceivedEnquiry enquiry) {
    final user = enquiry.user;
    final service = enquiry.service;
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha:0.05),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: InkWell(
        onTap: () => _showDetails(enquiry),
        borderRadius: BorderRadius.circular(14.r),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child: SizedBox(
                  width: 60.w,
                  height: 60.w,
                  child: service?.image.isNotEmpty == true
                      ? CachedNetworkImage(
                          imageUrl: service!.image.first,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => _imagePlaceholder(),
                        )
                      : _imagePlaceholder(),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            service?.serviceName ??
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
                        _statusBadge(enquiry.enquiryStatusLabel),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    if (user != null)
                      Row(
                        children: [
                          _avatar(user),
                          SizedBox(width: 6.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.displayName,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF374151),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (user.phone != null)
                                  Text(
                                    user.phone!,
                                    style: TextStyle(
                                        fontSize: 11.sp,
                                        color: const Color(0xFF9CA3AF)),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),

                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        _meta(Icons.access_time_rounded,
                            _formatDate(enquiry.createdAt)),
                        SizedBox(width: 10.w),
                        _meta(Icons.tag_rounded, '${enquiry.id}'),
                      ],
                    ),

                    if (enquiry.quote.isNotEmpty) ...[
                      SizedBox(height: 6.h),
                      Text(
                        enquiry.quote,
                        style: TextStyle(
                            fontSize: 11.5.sp,
                            color: const Color(0xFF6B7280),
                            height: 1.4),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              Icon(Icons.chevron_right_rounded,
                  size: 18.sp, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imagePlaceholder() => Container(
        color: AppColor.primary.withValues(alpha:0.08),
        child: Icon(Icons.miscellaneous_services_rounded,
            size: 24.sp, color: AppColor.primary.withValues(alpha:0.4)),
      );

  Widget _avatar(EnquiryUserInfo user) {
    return ClipOval(
      child: SizedBox(
        width: 32.w,
        height: 32.w,
        child: user.avatar != null && user.avatar!.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: user.avatar!,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => _defaultAvatar(),
              )
            : _defaultAvatar(),
      ),
    );
  }

  Widget _defaultAvatar() => Container(
        color: AppColor.primary.withValues(alpha:0.1),
        child: Icon(Icons.person_rounded,
            size: 18.sp, color: AppColor.primary.withValues(alpha:0.5)),
      );

  Widget _meta(IconData icon, String text) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11.sp, color: const Color(0xFF9CA3AF)),
          SizedBox(width: 3.w),
          Text(text,
              style: TextStyle(
                  fontSize: 11.sp,
                  color: const Color(0xFF9CA3AF),
                  fontWeight: FontWeight.w500)),
        ],
      );

  Widget _statusBadge(String label) {
    final isAccepted = label.toLowerCase() == 'accepted';
    final color =
        isAccepted ? const Color(0xFF10B981) : const Color(0xFFF59E0B);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withValues(alpha:0.3)),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
            fontSize: 9.sp,
            fontWeight: FontWeight.w700,
            color: color,
            letterSpacing: 0.4),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onRefresh,
  }) {
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
                  color: AppColor.primary.withValues(alpha:0.08),
                  shape: BoxShape.circle),
              child: Icon(icon, size: 38.sp, color: AppColor.primary),
            ),
            SizedBox(height: 20.h),
            Text(title,
                style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1D2E))),
            SizedBox(height: 8.h),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13.sp,
                    color: const Color(0xFF6B7280),
                    height: 1.5)),
            SizedBox(height: 28.h),
            ElevatedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh, color: Colors.white),
              label:
                  const Text('Refresh', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primary,
                padding:
                    EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetails(ReceivedEnquiry enquiry) {
    Get.bottomSheet(
      isScrollControlled: true,
      Container(
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 32.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36.w,
                height: 4.h,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2.r)),
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: Text(
                    enquiry.service?.serviceName ??
                        'Service #${enquiry.serviceId}',
                    style: TextStyle(
                        fontSize: 16.sp, fontWeight: FontWeight.w700),
                  ),
                ),
                _statusBadge(enquiry.enquiryStatusLabel),
              ],
            ),
            SizedBox(height: 16.h),
            if (enquiry.user != null) ...[
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColor.primary.withValues(alpha:0.04),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                      color: AppColor.primary.withValues(alpha:0.15)),
                ),
                child: Row(
                  children: [
                    _avatar(enquiry.user!),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(enquiry.user!.displayName,
                              style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1A1D2E))),
                          if (enquiry.user!.email != null)
                            Text(enquiry.user!.email!,
                                style: TextStyle(
                                    fontSize: 11.sp,
                                    color: const Color(0xFF6B7280))),
                          if (enquiry.user!.phone != null)
                            Text(enquiry.user!.phone!,
                                style: TextStyle(
                                    fontSize: 11.sp,
                                    color: const Color(0xFF6B7280))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 14.h),
            ],

            _detailRow('Enquiry ID', '#${enquiry.id}'),
            if (enquiry.quote.isNotEmpty)
              _detailRow('Note / Quote', enquiry.quote),
            if (enquiry.quantity != null)
              _detailRow('Quantity', '${enquiry.quantity}'),
            if (enquiry.datePreference != null)
              _detailRow('Date Preference', enquiry.datePreference!),
            if (enquiry.timePreference != null)
              _detailRow('Time Preference', enquiry.timePreference!),
            _detailRow('Submitted', _formatDate(enquiry.createdAt)),

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

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110.w,
            child: Text(label,
                style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF6B7280))),
          ),
          Expanded(
            child: Text(value,
                style: TextStyle(
                    fontSize: 12.sp, color: const Color(0xFF1A1D2E))),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 7) return '${date.day}/${date.month}/${date.year}';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }
}