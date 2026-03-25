import 'package:cashback_farms/common/colours.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../common/widget/appbar.dart';
import '../controller/gioo_controller.dart';
import '../model/gioo_plot.dart';

class GiooBuyingListWidget extends StatefulWidget {
  const GiooBuyingListWidget({super.key});

  @override
  State<GiooBuyingListWidget> createState() => _GiooBuyingListWidgetState();
}

class _GiooBuyingListWidgetState extends State<GiooBuyingListWidget> {
  final GiooPlotController controller = Get.put(GiooPlotController());
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchGiooBuyingList();
    });
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (controller.hasMoreBuyingData.value &&
            !controller.isLoadingBuyingList.value) {
          controller.loadMoreBuyingList();
        }
      }
    });
  }
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DynamicAppBar(
        title: "My Gioo Plot Bookings",
        showBackButton: true,
      ),
      body: _buildBody(),
    );
  }
  Widget _buildBody() {
    return Obx(() {
      if (controller.isLoadingBuyingList.value &&
          controller.buyingList.isEmpty) {
        return _buildLoading();
      }
      if (controller.buyingList.isEmpty) {
        return _buildEmptyState();
      }
      return _buildBookingList();
    });
  }
  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(AppColor.primary),
          ),
          20.h.verticalSpace,
          Text(
            'Loading your bookings...',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildEmptyState() {
    return RefreshIndicator(
      onRefresh: () => controller.fetchGiooBuyingList(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 100.w,
                color: Colors.grey.shade300,
              ),
              20.h.verticalSpace,
              Text(
                'No Bookings Found',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              10.h.verticalSpace,
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.w),
                child: Text(
                  'You haven\'t made any Gioo plot bookings yet.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
              30.h.verticalSpace,
              ElevatedButton.icon(
                onPressed: () => controller.fetchGiooBuyingList(),
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
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
      ),
    );
  }

  Widget _buildBookingList() {
    return RefreshIndicator(
      onRefresh: () => controller.fetchGiooBuyingList(),
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.all(16.w),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: controller.buyingList.length +
            (controller.hasMoreBuyingData.value ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == controller.buyingList.length) {
            return _buildLoadMoreButton();
          }

          final booking = controller.buyingList[index];
          return _buildBookingCard(booking);
        },
      ),
    );
  }

  Widget _buildLoadMoreButton() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Center(
        child: controller.isLoadingBuyingList.value
            ? SizedBox(
          height: 40.h,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(
              AppColor.primary,
            ),
          ),
        )
            : ElevatedButton(
          onPressed: controller.loadMoreBuyingList,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppColor.primary,
            side: BorderSide(
              color: AppColor.primary,
              width: 1,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: 24.w,
              vertical: 10.h,
            ),
          ),
          child: const Text('Load More'),
        ),
      ),
    );
  }

  Widget _buildBookingCard(GiooBuyingList booking) {
    final units = controller.getUnitsList(booking.units);
    final dateFormat = DateFormat('dd MMM yyyy');
    final timeFormat = DateFormat('hh:mm a');
    final statusColor = controller.getStatusColor(booking.transaction.status);

    return Container(
      margin: EdgeInsets.only(bottom: 20.h, left: 4.w, right: 4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: InkWell(
          onTap: () => _showBookingDetails(booking),
          child: Stack(
            children: [
              // Side Accent Bar
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 6.w,
                  color: statusColor,
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 16.w, 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- HEADER ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            booking.property?.name??'No Property Name',
                            style: TextStyle(
                              fontSize: 17.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF1E293B), // Deep Navy Slate
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        _customStatusBadge(statusColor, booking.transaction.status),
                      ],
                    ),
                    6.h.verticalSpace,
                    Row(
                      children: [
                        Icon(Icons.location_on_rounded, size: 14.w, color: statusColor.withOpacity(0.7)),
                        6.w.horizontalSpace,
                        Expanded(
                          child: Text(
                            booking.property?.address??'No Address',
                            style: TextStyle(fontSize: 12.sp, color: Colors.blueGrey.shade400),
                          ),
                        ),
                      ],
                    ),

                    Divider(height: 32.h, thickness: 1, color: Colors.grey.shade100),

                    // --- INFO ROW ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _modernInfoTile(Icons.grid_view_rounded, "Units", "${units.length} Plots"),
                        _modernInfoTile(Icons.account_balance_wallet_rounded, "Paid", "₹${booking.amount.toInt()}", isBold: true),
                      ],
                    ),

                    20.h.verticalSpace,

                    // --- TRANSACTION BOX ---
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                      ),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "TXN: ${booking.transaction.transactionId.toUpperCase()}",
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontFamily: 'Monospace',
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueGrey.shade700,
                                ),
                              ),
                              4.h.verticalSpace,
                              Text(
                                '${dateFormat.format(booking.createdAt)} • ${timeFormat.format(booking.createdAt)}',
                                style: TextStyle(fontSize: 11.sp, color: Colors.blueGrey.shade400),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

// --- UNIQUE HELPER WIDGETS ---

  Widget _customStatusBadge(Color color, dynamic status) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Text(
        Get.find<GiooPlotController>().getStatusText(status).toUpperCase(),
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w900,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _modernInfoTile(IconData icon, String label, String value, {bool isBold = false}) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16.w, color: const Color(0xFF64748B)),
        ),
        10.w.horizontalSpace,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 11.sp, color: Colors.blueGrey.shade300)),
            Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: isBold ? FontWeight.w900 : FontWeight.w600,
                color: const Color(0xFF334155),
              ),
            ),
          ],
        ),
      ],
    );
  }
  Widget _infoItem({
    required IconData icon,
    required String title,
    required String value,
    Color? valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14.w, color: Colors.grey.shade500),
            4.w.horizontalSpace,
            Text(
              title,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        4.h.verticalSpace,
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: valueColor ?? Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  void _refreshData() {
    controller.fetchGiooBuyingList();
    Get.showSnackbar(
      GetSnackBar(
        message: 'Refreshing bookings...',
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _showBookingDetails(GiooBuyingList booking) {
    Get.to(
          () => GiooBuyingDetailsWidget(booking: booking),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 300),
    );
  }
}

class GiooBuyingDetailsWidget extends StatelessWidget {
  final GiooBuyingList booking;
  final GiooPlotController controller = Get.find<GiooPlotController>();
  final ScrollController _scrollController = ScrollController();

  GiooBuyingDetailsWidget({super.key, required this.booking}) {
    controller.selectedTransactionId.value = booking.transaction.id;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchGiooBuyingListDetails();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (controller.hasMoreBuyingDetailData.value &&
            !controller.isLoadingBuyingDetail.value) {
          controller.loadMoreBuyingDetails();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DynamicAppBar(
        title: "Plot Details",
        showBackButton: true,
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingBuyingDetail.value &&
          controller.buyingDetailList.isEmpty) {
        return _buildLoading();
      }

      if (controller.buyingDetailList.isEmpty) {
        return _buildEmptyDetails(context);
      }

      return _buildDetailsContent();
    });
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(AppColor.primary),
          ),
          20.h.verticalSpace,
          Text(
            'Loading plot details...',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyDetails(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => controller.fetchGiooBuyingListDetails(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 80.w,
                color: Colors.grey.shade300,
              ),
              20.h.verticalSpace,
              Text(
                'No Plot Details Found',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              10.h.verticalSpace,
              const Text('Could not load plot details.'),
              30.h.verticalSpace,
              ElevatedButton.icon(
                onPressed: () => controller.fetchGiooBuyingListDetails(),
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsContent() {
    return RefreshIndicator(
      onRefresh: () => controller.fetchGiooBuyingListDetails(),
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverToBoxAdapter(child: _buildBookingHeader()),
          SliverToBoxAdapter(child: _buildTransactionSection()),
          SliverToBoxAdapter(child: _buildUnitsHeader()),
          _buildUnitsList(),
          if (controller.hasMoreBuyingDetailData.value)
            SliverToBoxAdapter(child: _buildLoadMoreButton()),
        ],
      ),
    );
  }

  Widget _buildBookingHeader() {
    final dateFormat = DateFormat('dd MMM yyyy');
    final timeFormat = DateFormat('hh:mm a');

    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 24.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColor.primary.withOpacity(0.12),
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- TAG & UNIT COUNT ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColor.primary,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  "BOOKED PLOT",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              ),
              Text(
                '${controller.getUnitsList(booking.units).length} Units Total',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColor.primary,
                ),
              ),
            ],
          ),
          16.h.verticalSpace,

          // --- PROPERTY TITLE ---
          Text(
            booking.property?.name??'No Property Name',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF0F172A), // Deep Slate
              letterSpacing: -0.5,
            ),
          ),
          8.h.verticalSpace,

          // --- ADDRESS ---
          Row(
            children: [
              Icon(Icons.location_on, size: 16.w, color: Colors.redAccent.withOpacity(0.7)),
              6.w.horizontalSpace,
              Expanded(
                child: Text(
                  booking.property?.address??' No Address',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.blueGrey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          24.h.verticalSpace,

          // --- STATS PILLS ---
          Row(
            children: [
              _headerStatPill(
                label: "Date",
                value: dateFormat.format(booking.createdAt),
                icon: Icons.calendar_today_rounded,
              ),
              12.w.horizontalSpace,
              _headerStatPill(
                label: "Total Value",
                value: "₹${booking.amount.toStringAsFixed(0)}",
                icon: Icons.account_balance_wallet_rounded,
                isHighlight: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerStatPill({
    required String label,
    required String value,
    required IconData icon,
    bool isHighlight = false,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isHighlight ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isHighlight ? AppColor.primary.withOpacity(0.3) : Colors.grey.shade200,
          ),
          boxShadow: isHighlight ? [
            BoxShadow(
              color: AppColor.primary.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ] : [],
        ),
        child: Row(
          children: [
            Icon(icon, size: 18.w, color: isHighlight ? AppColor.primary : Colors.blueGrey),
            10.w.horizontalSpace,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.blueGrey.shade400,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  Widget _bookingInfoItem({
    required IconData icon,
    required String title,
    required String value,
    Color? valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14.w, color: Colors.grey.shade500),
            4.w.horizontalSpace,
            Text(
              title,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        4.h.verticalSpace,
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: valueColor ?? Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionSection() {
    final bookingTransaction = booking.transaction;
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.receipt_long_rounded, size: 20.w, color: const Color(0xFF64748B)),
              10.w.horizontalSpace,
              Text(
                'Payment Summary',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          16.h.verticalSpace,
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                // --- TOP SECTION: STATUS & AMOUNT ---
                Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Total Paid",
                              style: TextStyle(fontSize: 12.sp, color: const Color(0xFF64748B), fontWeight: FontWeight.w600)),
                          Text(
                            '₹${bookingTransaction.amount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.w900,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                      _modernStatusChip(
                        controller.getStatusText(bookingTransaction.status),
                        controller.getStatusColor(bookingTransaction.status),
                      ),
                    ],
                  ),
                ),

                // --- BOTTOM SECTION: DETAILS ---
                Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    children: [
                      _ledgerRow(
                        label: 'Transaction ID',
                        value: bookingTransaction.transactionId,
                        isCopyable: true,
                      ),
                      16.h.verticalSpace,
                      _ledgerRow(
                        label: 'Payment Method',
                        value: bookingTransaction.paymentMode ?? 'N/A',
                        icon: Icons.account_balance_wallet_outlined,
                      ),
                      16.h.verticalSpace,
                      _ledgerRow(
                        label: 'Timestamp',
                        value: dateFormat.format(bookingTransaction.createdAt),
                        icon: Icons.access_time_rounded,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _modernStatusChip(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(radius: 3.r, backgroundColor: color),
          8.w.horizontalSpace,
          Text(
            text.toUpperCase(),
            style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w800, color: color, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }

  Widget _ledgerRow({
    required String label,
    required String value,
    bool isCopyable = false,
    IconData? icon,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 14.w, color: const Color(0xFF94A3B8)),
          8.w.horizontalSpace,
        ],

        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            color: const Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),

        const Spacer(),

        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: isCopyable
                ? () {
              Clipboard.setData(
                ClipboardData(text: value),
              );

              Get.snackbar(
                "Copied",
                "Transaction ID copied to clipboard",
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.black87,
                colorText: Colors.white,
                duration: const Duration(seconds: 2),
              );
            }
                : null,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    value,
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF334155),
                      fontFamily: isCopyable ? 'RobotoMono' : null,
                    ),
                  ),
                ),

                if (isCopyable) ...[
                  8.w.horizontalSpace,
                  Icon(
                    Icons.copy_rounded,
                    size: 14.w,
                    color: AppColor.primary,
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _transactionDetailRow(
      String label,
      String value, {
        Color? valueColor,
        Color? statusColor,
        bool copyable = false,
      }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (copyable)
          Row(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? Colors.grey.shade800,
                ),
              ),
              8.w.horizontalSpace,
              GestureDetector(
                onTap: () {
                  // Copy to clipboard
                  // You can add clipboard functionality here
                  Get.showSnackbar(
                    GetSnackBar(
                      message: 'Transaction ID copied!',
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: Icon(
                  Icons.content_copy,
                  size: 16.w,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          )
        else if (statusColor != null)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: statusColor, width: 1),
            ),
            child: Text(
              value.toUpperCase(),
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          )
        else
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: valueColor ?? Colors.grey.shade800,
            ),
          ),
      ],
    );
  }

  Widget _buildUnitsHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
      child: Text(
        'Plot Units (${controller.buyingDetailList.length})',
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade800,
        ),
      ),
    );
  }


  SliverList _buildUnitsList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          final detail = controller.buyingDetailList[index];
          return _buildUnitCard(detail);
        },
        childCount: controller.buyingDetailList.length,
      ),
    );
  }

  Widget _buildUnitCard(GiooBuyingDetail detail) {
    final dateFormat = DateFormat('dd MMM yyyy');

    // STATUS LOGIC BASED ON REACT CODE
    final int cancelStatus = detail.cancelStatus ?? 0;
    final int refundStatus = detail.refundStatus ?? 0;
    final bool isActive = cancelStatus == 0;
    final bool isRequestSent = cancelStatus == 1;
    final bool isCancelled = cancelStatus == 2;
    /// STATUS TEXT & COLOR - Updated to match React logic
    ///
    String bookingStatusText;
    Color bookingStatusColor;
    if (cancelStatus == 0) {
      bookingStatusText = 'Active';
      bookingStatusColor = const Color(0xFF10B981); // Emerald Green
    }
    else if (cancelStatus == 1) {
      bookingStatusText = 'Request Sent';
      bookingStatusColor = Colors.orange;
    } else if (cancelStatus == 2) {
      if (refundStatus == 0) {
        bookingStatusText = 'Cancelled';
        bookingStatusColor = const Color(0xFFEF4444); // Rose Red
      } else if (refundStatus == 1) {
        bookingStatusText = 'Refunded';
        bookingStatusColor = Colors.green;
      } else {
        bookingStatusText = 'Cancelled';
        bookingStatusColor = const Color(0xFFEF4444);
      }
    } else {
      bookingStatusText = 'Unknown';
      bookingStatusColor = Colors.grey;
    }
    return Container(
      margin: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
      decoration: BoxDecoration(
        color: isActive ? Colors.white : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isActive ? const Color(0xFFE2E8F0) : bookingStatusColor.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                // Unit Badge
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [bookingStatusColor.withOpacity(0.2), bookingStatusColor.withOpacity(0.05)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        detail.unit.toString(),
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w900,
                          color: bookingStatusColor,
                        ),
                        maxLines: 1,
                      ),
                    ),
                  ),
                ),           16.w.horizontalSpace,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Unit Asset #${detail.unit}',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      4.h.verticalSpace,
                      Text(
                        'Market Value: ₹${detail.amount.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF64748B),
                        ),
                      ),

                       if (cancelStatus == 2 && refundStatus == 0) ...[
                        4.h.verticalSpace,
                        Text(
                          'Refund will be sent in 2 Days',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.amber.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (cancelStatus == 0)
                  Material(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10.r),
                    child: InkWell(
                      onTap: () => _showCancelConfirmation(detail),
                      borderRadius: BorderRadius.circular(10.r),
                      child: Padding(
                        padding: EdgeInsets.all(8.r),
                        child: Text('Cancel',style: TextStyle( color: Colors.red.shade400,),),
                      ),
                    ),
                  ),
                if (cancelStatus == 1)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.hourglass_top_rounded, size: 14.w, color: Colors.orange.shade700),
                        4.w.horizontalSpace,
                        Text(
                          'Request Sent',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.orange.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (cancelStatus == 2 && refundStatus == 0)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.cancel_rounded, size: 14.w, color: Colors.red.shade700),
                        4.w.horizontalSpace,
                        Text(
                          'Cancelled',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Show Refunded Successfully (refundStatus == 1)
                if (refundStatus == 1)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_rounded, size: 14.w, color: Colors.green.shade700),
                        4.w.horizontalSpace,
                        Text(
                          'Refunded',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Divider
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Divider(height: 1, thickness: 1, color: Colors.grey.shade100),
          ),

          // Footer: Status Chips & Refund Info
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              children: [
                Row(
                  children: [
                    _modernUnitBadge(
                      'Booking',
                      bookingStatusText,
                      bookingStatusColor,
                    ),
                    8.w.horizontalSpace,
                    _modernUnitBadge(
                      'Payment',
                      controller.getStatusText(detail.transaction.status),
                      controller.getStatusColor(detail.transaction.status),
                    ),
                  ],
                ),

                // Show refund amount if available
                if (detail.refundAmount != null || detail.refundDate != null) ...[
                  12.h.verticalSpace,
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.blue.shade100),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline_rounded, size: 14.w, color: Colors.blue.shade700),
                            6.w.horizontalSpace,
                            Text(
                              refundStatus == 1 ? "Refunded Amount" : "Refund Amount",
                              style: TextStyle(fontSize:  11.sp, color: Colors.blue.shade700, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Text(
                          '₹${detail.refundAmount?.toStringAsFixed(0) ?? "0"}',
                          style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w900, color: Colors.blue.shade800),
                        ),
                      ],
                    ),
                  ),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _modernUnitBadge(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Column(
          children: [
            Text(
              title.toUpperCase(),
              style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade300, letterSpacing: 0.5),
            ),
            2.h.verticalSpace,
            Text(
              value,
              style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w800, color: color),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadMoreButton() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Center(
        child: controller.isLoadingBuyingDetail.value
            ? CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation(
            AppColor.primary,
          ),
        )
            : ElevatedButton(
          onPressed: controller.loadMoreBuyingDetails,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppColor.primary,
            side: BorderSide(
              color: AppColor.primary,
              width: 1,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
          child: const Text('Load More Units'),
        ),
      ),
    );
  }

  void _showCancelConfirmation(GiooBuyingDetail detail) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // --- GRABBER BAR ---
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            24.h.verticalSpace,

            // --- WARNING ICON ---
            Container(
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.report_gmailerrorred_rounded,
                color: const Color(0xFFEF4444),
                size: 40.r,
              ),
            ),
            20.h.verticalSpace,

            // --- TITLE & DESCRIPTION ---
            Text(
              'Confirm Cancellation',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF1E293B),
              ),
            ),
            12.h.verticalSpace,
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(fontSize: 14.sp, color: const Color(0xFF64748B), height: 1.5),
                children: [
                  const TextSpan(text: 'Are you sure you want to cancel '),
                  TextSpan(
                    text: 'Unit Asset #${detail.unit}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  ),
                  const TextSpan(text: '? This action will release the plot back to the market.'),
                ],
              ),
            ),
            24.h.verticalSpace,

            // --- REFUND INFO BOX ---
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F9FF),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: const Color(0xFFBAE6FD)),
              ),
              child: Row(
                children: [
                  Icon(Icons.account_balance_wallet_rounded, color: const Color(0xFF0284C7), size: 20.w),
                  12.w.horizontalSpace,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Estimated Refund',
                          style: TextStyle(fontSize: 11.sp, color: const Color(0xFF0369A1), fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '₹${detail.amount.toStringAsFixed(2)}',
                          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900, color: const Color(0xFF0C4A6E)),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6.r)),
                    child: Text("AUTO-REFUND", style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0369A1))),
                  )
                ],
              ),
            ),
            32.h.verticalSpace,

            // --- ACTIONS ---
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Get.back(),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                    ),
                    child: Text(
                      'Keep Plot',
                      style: TextStyle(color: const Color(0xFF64748B), fontWeight: FontWeight.bold, fontSize: 15.sp),
                    ),
                  ),
                ),
                16.w.horizontalSpace,
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      _processUnitCancellation(detail);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                    ),
                    child: Text(
                      'Cancel Unit',
                      style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            10.h.verticalSpace,
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
  void _processUnitCancellation(GiooBuyingDetail detail) async {
    // Use a simpler loading indicator that doesn't use Get.dialog
    showDialog(
      context: Get.context!,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Cancelling Plot Unit'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(AppColor.primary),
            ),
            16.h.verticalSpace,
            const Text('Please wait while we process your request...'),
          ],
        ),
      ),
    );

    try {
      // Call the cancel API for the specific plot unit
      await controller.cancelGiooBuyingRequest(detail.id);

      // Close dialog
      Navigator.of(Get.context!).pop();

      // Show success message
      Get.showSnackbar(
        GetSnackBar(
          message: 'Plot unit ${detail.unit} cancellation request submitted successfully!',
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.green,
        ),
      );

      // Refresh the details
      await controller.fetchGiooBuyingListDetails();

    } catch (error) {
      // Close dialog
      if (Navigator.of(Get.context!).canPop()) {
        Navigator.of(Get.context!).pop();
      }

      // Show error message
      Get.showSnackbar(
        GetSnackBar(
          message: 'Failed to cancel plot unit: $error',
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.red,
        ),
      );
    }

  }}