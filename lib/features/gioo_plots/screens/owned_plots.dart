// widgets/gioo_buying_list_widget.dart
import 'dart:async';

import 'package:cashback_farms/common/colours.dart';
import 'package:flutter/material.dart';
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

    // Setup scroll listener for pagination
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

    return Card(
      color: Colors.white,
      margin: EdgeInsets.only(bottom: 16.w),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: InkWell(
        onTap: () => _showBookingDetails(booking),
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with property name and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.property.name,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        4.h.verticalSpace,
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 14.w,
                              color: Colors.grey.shade500,
                            ),
                            4.w.horizontalSpace,
                            Expanded(
                              child: Text(
                                booking.property.address,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey.shade600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  10.w.horizontalSpace,
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: controller
                          .getStatusColor(booking.transaction.status)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: controller.getStatusColor(
                          booking.transaction.status,
                        ),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      controller.getStatusText(booking.transaction.status)
                          .toUpperCase(),
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: controller.getStatusColor(
                          booking.transaction.status,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              16.h.verticalSpace,

              // Booking details
              Row(
                children: [
                  _infoItem(
                    icon: Icons.grid_view,
                    title: 'Units',
                    value: '${units.length} units',
                  ),
                  Expanded(child: Container()),
                  _infoItem(
                    icon: Icons.currency_rupee,
                    title: 'Amount',
                    value: '₹${booking.amount.toStringAsFixed(2)}',
                    valueColor: Colors.green,
                  ),
                ],
              ),

              12.h.verticalSpace,

              // Transaction info
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.receipt_outlined,
                          size: 14.w,
                          color: Colors.grey.shade600,
                        ),
                        6.w.horizontalSpace,
                        Expanded(
                          child: Text(
                            'TXN: ${booking.transaction.transactionId}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    8.h.verticalSpace,
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 14.w,
                          color: Colors.grey.shade600,
                        ),
                        6.w.horizontalSpace,
                        Text(
                          '${dateFormat.format(booking.createdAt)} • ${timeFormat.format(booking.createdAt)}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              16.h.verticalSpace,

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showBookingDetails(booking),
                      icon: const Icon(Icons.remove_red_eye_outlined),
                      label: const Text('View Details'),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColor.primary.withOpacity(0.05),
        border: Border(
          bottom: BorderSide(
            color: AppColor.darkGrey,
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            booking.property.name,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade800,
            ),
          ),
          8.h.verticalSpace,
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 16.w,
                color: Colors.grey.shade600,
              ),
              6.w.horizontalSpace,
              Expanded(
                child: Text(
                  booking.property.address,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
          12.h.verticalSpace,
          Row(
            children: [
              _bookingInfoItem(
                icon: Icons.event_note,
                title: 'Booked On',
                value: dateFormat.format(booking.createdAt),
              ),
              Expanded(child: Container()),
              _bookingInfoItem(
                icon: Icons.currency_rupee,
                title: 'Total Amount',
                value: '₹${booking.amount.toStringAsFixed(2)}',
                valueColor: Colors.green,
              ),
            ],
          ),
          8.h.verticalSpace,
          Text(
            'Total Units: ${controller.getUnitsList(booking.units).length}',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade600,
            ),
          ),
        ],
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
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Transaction Information',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          12.h.verticalSpace,
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade100,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _transactionDetailRow(
                  'Transaction ID',
                  bookingTransaction.transactionId,
                  copyable: true,
                ),
                Divider(height: 20.h, color: Colors.grey.shade200),
                _transactionDetailRow(
                  'Status',
                  controller.getStatusText(bookingTransaction.status),
                  statusColor: controller.getStatusColor(
                    bookingTransaction.status,
                  ),
                ),
                Divider(height: 20.h, color: Colors.grey.shade200),
                _transactionDetailRow(
                  'Payment Mode',
                  bookingTransaction.paymentMode ?? 'N/A',
                ),
                Divider(height: 20.h, color: Colors.grey.shade200),
                _transactionDetailRow(
                  'Amount',
                  '₹${bookingTransaction.amount.toStringAsFixed(2)}',
                  valueColor: Colors.green,
                ),
                Divider(height: 20.h, color: Colors.grey.shade200),
                _transactionDetailRow(
                  'Date & Time',
                  dateFormat.format(bookingTransaction.createdAt),
                ),
              ],
            ),
          ),
        ],
      ),
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
    final canCancel = detail.cancelStatus == 0; // Can cancel if not already cancelled

    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Unit header with cancel button
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Center(
                  child: Text(
                    detail.unit.toString(),
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
              ),
              12.w.horizontalSpace,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Plot Unit ${detail.unit}',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    2.h.verticalSpace,
                    Text(
                      'Amount: ₹${detail.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              if (canCancel)
                IconButton(
                  onPressed: () => _showCancelConfirmation(detail),
                  icon: Icon(
                    Icons.cancel_outlined,
                    size: 20.w,
                    color: Colors.red,
                  ),
                  tooltip: 'Cancel this plot',
                ),
            ],
          ),

          16.h.verticalSpace,

          // Status badges
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              _unitStatusBadge(
                'Payment',
                controller.getStatusText(detail.transaction.status),
                controller.getStatusColor(detail.transaction.status),
              ),
              _unitStatusBadge(
                'Booking',
                detail.cancelStatus == 1 ? 'Cancelled' : 'Active',
                detail.cancelStatus == 1 ? Colors.red : Colors.green,
              ),
              _unitStatusBadge(
                'Refund',
                detail.refundStatus == 1 ? 'Processed' : 'Pending',
                detail.refundStatus == 1 ? Colors.blue : Colors.orange,
              ),
            ],
          ),

          // Refund information (if available)
          if (detail.refundAmount != null || detail.refundDate != null) ...[
            16.h.verticalSpace,
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Refund Information',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  8.h.verticalSpace,
                  if (detail.refundAmount != null)
                    Padding(
                      padding: EdgeInsets.only(bottom: 4.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Amount:',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            '₹${detail.refundAmount!.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (detail.refundDate != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Date:',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          dateFormat.format(detail.refundDate!),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _unitStatusBadge(String title, String value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 10.sp,
              color: Colors.grey.shade600,
            ),
          ),
          2.h.verticalSpace,
          Text(
            value,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
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
    Get.defaultDialog(
      title: 'Cancel Plot Unit ${detail.unit}',
      titlePadding: EdgeInsets.only(top: 20.h, bottom: 10.h),
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w),
      titleStyle: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        color: Colors.red,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 60.w,
            color: Colors.orange,
          ),
          16.h.verticalSpace,
          Text(
            'Are you sure you want to cancel this plot unit?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14.sp),
          ),
          8.h.verticalSpace,
          Text(
            'Only this plot unit (${detail.unit}) will be cancelled, not the entire booking.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey.shade600,
            ),
          ),
          8.h.verticalSpace,
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16.w, color: Colors.orange),
                8.w.horizontalSpace,
                Expanded(
                  child: Text(
                    'Amount to be refunded: ₹${detail.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.orange.shade800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('No, Keep It'),
        ),
        ElevatedButton(
          onPressed: () {
            Get.back(); // Close confirmation dialog
            _processUnitCancellation(detail); // Start cancellation process
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: const Text('Yes, Cancel Unit'),
        ),
      ],
      barrierDismissible: false,
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