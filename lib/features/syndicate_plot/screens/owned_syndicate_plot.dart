import 'package:cashback_farms/common/colours.dart';
import 'package:cashback_farms/features/bank_details/screen/bank_details_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../common/widget/appbar.dart';
import '../../bank_details/controller/bank_details_controller.dart';
import '../controller/syndicate_controller.dart';
import '../model/syndicate_model.dart';

class SyndicateBuyingListWidget extends StatefulWidget {
  const SyndicateBuyingListWidget({super.key});

  @override
  State<SyndicateBuyingListWidget> createState() =>
      _SyndicateBuyingListWidgetState();
}

class _SyndicateBuyingListWidgetState extends State<SyndicateBuyingListWidget> {
  final SyndicatePlotController controller = Get.put(SyndicatePlotController());
  final ScrollController _scrollController = ScrollController();

  final Color _primaryColor = const Color(0xff92AF5D);
  final Color _secondaryColor = const Color(0xffC7DD94);
  final Color _accentColor = const Color(0xFF06B6D4);
  final Color _successColor = const Color(0xFF10B981);
  final Color _warningColor = const Color(0xFFF59E0B);
  final Color _dangerColor = const Color(0xFFEF4444);
  final Color _neutralDark = const Color(0xFF1E293B);
  final Color _neutralLight = const Color(0xFFF8FAFC);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchSyndicateBuyingList();
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
        title: "Buyed Syndicate Plots",
        showBackButton: true,
        backgroundColor: Colors.white,
      ),
      backgroundColor: _neutralLight,
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
      return _buildInvestmentList();
    });
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation(_primaryColor),
          ),
          24.h.verticalSpace,
          Text(
            'Loading your investments...',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: _neutralDark,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Fetching syndicate portfolio',
            style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
      onRefresh: () => controller.fetchSyndicateBuyingList(),
      color: _primaryColor,
      backgroundColor: _neutralLight,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120.w,
                height: 120.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_primaryColor, _secondaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.pie_chart_outline,
                    size: 60.w,
                    color: Colors.white,
                  ),
                ),
              ),
              32.h.verticalSpace,

              Text(
                'No Syndicate Investments',
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                  color: _neutralDark,
                  letterSpacing: -0.5,
                ),
              ),
              12.h.verticalSpace,

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.w),
                child: Text(
                  'You haven\'t invested in any syndicate plots yet. Start your investment journey today!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey.shade600,
                    height: 1.6,
                  ),
                ),
              ),
              30.h.verticalSpace,
              ElevatedButton.icon(
                onPressed: () => controller.fetchSyndicateBuyingList(),
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
      ),
    );
  }

  Widget _buildInvestmentList() {
    return RefreshIndicator(
      onRefresh: () => controller.fetchSyndicateBuyingList(),
      color: _primaryColor,
      backgroundColor: _neutralLight,
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.all(16.w),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount:
            controller.buyingList.length +
            (controller.hasMoreBuyingData.value ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == controller.buyingList.length) {
            return _buildLoadMoreButton();
          }

          final investment = controller.buyingList[index];
          return _buildInvestmentCard(investment);
        },
      ),
    );
  }

  Widget _buildLoadMoreButton() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.h),
      child: Center(
        child: controller.isLoadingBuyingList.value
            ? Container(
                width: 40.w,
                height: 40.w,
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha:0.1),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(_primaryColor),
                ),
              )
            : ElevatedButton(
                onPressed: controller.loadMoreBuyingList,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: _primaryColor,
                  side: BorderSide(
                    color: _primaryColor.withValues(alpha:0.3),
                    width: 2,
                  ),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 32.w,
                    vertical: 14.h,
                  ),
                  shadowColor: Colors.transparent,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.expand_more, size: 20.w),
                    8.w.horizontalSpace,
                    Text(
                      'Load More Investments',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildInvestmentCard(SyndicateBuyingList investment) {
    final units = _parseUnits(investment.units);
    final dateFormat = DateFormat('dd MMM yyyy');
    final statusColor = _getStatusColor(investment.transaction?.status);
    final property = investment.property;

    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: _neutralDark.withValues(alpha:0.05),
            blurRadius: 25,
            spreadRadius: 0,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: InkWell(
          onTap: () => _showInvestmentDetails(investment),
          borderRadius: BorderRadius.circular(24.r),
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 6.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_primaryColor, _secondaryColor],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 60.w,
                          height: 60.w,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                _primaryColor.withValues(alpha:0.1),
                                _secondaryColor.withValues(alpha:0.1),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.account_balance,
                              color: _primaryColor,
                              size: 28.w,
                            ),
                          ),
                        ),
                        16.w.horizontalSpace,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                property?.name ?? "Syndicate Property",
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w800,
                                  color: _neutralDark,
                                  height: 1.3,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              6.h.verticalSpace,
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on_rounded,
                                    size: 14.w,
                                    color: _accentColor,
                                  ),
                                  4.w.horizontalSpace,
                                  Expanded(
                                    child: Text(
                                      property?.address ??
                                          "Location not available",
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
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha:0.1),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            investment.transaction?.status.toUpperCase()??'',
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w800,
                              color: statusColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    24.h.verticalSpace,
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: _neutralLight,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(
                            icon: Icons.grid_view,
                            label: "Plots",
                            value: units.length.toString(),
                            color: _primaryColor,
                          ),
                          _buildStatItem(
                            icon: Icons.attach_money_rounded,
                            label: "Investment",
                            value: "₹${_formatNumber(investment.amount)}",
                            color: _successColor,
                          ),
                          _buildStatItem(
                            icon: Icons.calendar_today,
                            label: "Date",
                            value: dateFormat.format(investment.createdAt),
                            color: _accentColor,
                          ),
                        ],
                      ),
                    ),

                    20.h.verticalSpace,
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _primaryColor.withValues(alpha:0.03),
                            _secondaryColor.withValues(alpha:0.03),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.receipt_long_rounded,
                            size: 20.w,
                            color: _primaryColor,
                          ),
                          12.w.horizontalSpace,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Transaction ID",
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: Colors.grey.shade500,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                2.h.verticalSpace,
                                Text(
                                  investment.transaction?.transactionId.toString()??"",
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w700,
                                    color: _neutralDark,
                                    fontFamily: 'RobotoMono',
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: Colors.grey.shade400,
                            size: 24.w,
                          ),
                        ],
                      ),
                    ),
                    if (investment.transaction?.status.toLowerCase() ==
                        'completed')
                      16.h.verticalSpace,
                    Row(
                      children: [
                        // Expanded(
                        //   child: OutlinedButton.icon(
                        //     onPressed: () => _showCancelConfirmation(investment),
                        //     style: OutlinedButton.styleFrom(
                        //       side: BorderSide(color: _dangerColor.withValues(alpha:0.3)),
                        //       padding: EdgeInsets.symmetric(vertical: 12.h),
                        //       shape: RoundedRectangleBorder(
                        //         borderRadius: BorderRadius.circular(12.r),
                        //       ),
                        //     ),
                        //     icon: Icon(
                        //       Icons.close_rounded,
                        //       size: 18.w,
                        //       color: _dangerColor,
                        //     ),
                        //     label: Text(
                        //       'Request Cancel',
                        //       style: TextStyle(
                        //         fontSize: 14.sp,
                        //         fontWeight: FontWeight.w600,
                        //         color: _dangerColor,
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        12.w.horizontalSpace,
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _showInvestmentDetails(investment),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryColor,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              elevation: 0,
                              shadowColor: Colors.transparent,
                            ),
                            icon: Icon(
                              Icons.visibility_rounded,
                              size: 18.w,
                              color: Colors.white,
                            ),
                            label: Text(
                              'View Details',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            color: color.withValues(alpha:0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: label == "Investment"
                ? Text(
                    "₹",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  )
                : Icon(icon, size: 18.w, color: color),
          ),
        ),
        8.h.verticalSpace,
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w800,
            color: _neutralDark,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _formatNumber(String amount) {
    try {
      final value = double.parse(amount);
      if (value >= 10000000) {
        return '${(value / 10000000).toStringAsFixed(1)}Cr';
      } else if (value >= 100000) {
        return '${(value / 100000).toStringAsFixed(1)}L';
      } else if (value >= 1000) {
        return '${(value / 1000).toStringAsFixed(1)}K';
      }
      return value.toStringAsFixed(0);
    } catch (e) {
      return amount;
    }
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
        return _successColor;
      case 'pending':
        return _warningColor;
      case 'cancelled':
        return _dangerColor;
      case 'processing':
        return _accentColor;
      default:
        return Colors.grey;
    }
  }

  List<String> _parseUnits(String? units) {
    try {
      return units
          ?.split(',')
          .map((unit) => unit.trim())
          .toList() ??
          [];
    } catch (e) {
      return [];
    }
  }

  void _showInvestmentDetails(SyndicateBuyingList investment) {
    Get.to(
      () => SyndicateInvestmentDetailsWidget(investment: investment),
      transition: Transition.cupertino,
      duration: const Duration(milliseconds: 300),
    );
  }

  void _showCancelConfirmation(SyndicateBuyingList investment) {
    controller.showCancelConfirmationDialog(
      investment.id,
      investment.property?.name ?? "Syndicate Property",
    );
  }
}

class SyndicateInvestmentDetailsWidget extends StatelessWidget {
  final SyndicateBuyingList investment;
  final SyndicatePlotController controller =
      Get.find<SyndicatePlotController>();
  final ScrollController _scrollController = ScrollController();

  // Syndicate-specific colors
  // Violet
  final Color _primaryColor = const Color(0xff92AF5D); // Indigo
  final Color _secondaryColor = const Color(0xffC7DD94);
  final Color _accentColor = const Color(0xFF06B6D4); // Cyan
  final Color _successColor = const Color(0xFF10B981); // Emerald
  final Color _warningColor = const Color(0xFFF59E0B); // Amber
  final Color _dangerColor = const Color(0xFFEF4444); // Red
  final Color _neutralDark = const Color(0xFF1E293B); // Slate 800
  final Color _neutralLight = const Color(0xFFF8FAFC); // Slate 50

  SyndicateInvestmentDetailsWidget({super.key, required this.investment}) {
    controller.selectedTransactionId.value = investment.transaction?.id;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchSyndicateBuyingListDetails();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (controller.hasMoreBuyingDetailData.value &&
            !controller.isLoadingBuyingDetail.value) {
          controller.loadMoreBuyingDetail();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DynamicAppBar(
        title: "Investment Details",
        showBackButton: true,
        backgroundColor: _primaryColor,
        textColor: Colors.white,
      ),
      backgroundColor: _neutralLight,
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
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_primaryColor, _secondaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation(Colors.white),
              ),
            ),
          ),
          24.h.verticalSpace,
          Text(
            'Loading investment details...',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: _neutralDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyDetails(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => controller.fetchSyndicateBuyingListDetails(),
      color: _primaryColor,
      backgroundColor: _neutralLight,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120.w,
                height: 120.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_primaryColor, _secondaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.error_outline_rounded,
                    size: 50.w,
                    color: Colors.white,
                  ),
                ),
              ),
              32.h.verticalSpace,

              Text(
                'No Details Available',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w800,
                  color: _neutralDark,
                ),
              ),
              12.h.verticalSpace,

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.w),
                child: Text(
                  'Investment details are currently unavailable. Please try again later.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey.shade600,
                    height: 1.6,
                  ),
                ),
              ),
              40.h.verticalSpace,

              ElevatedButton.icon(
                onPressed: () => controller.fetchSyndicateBuyingListDetails(),
                icon: Icon(
                  Icons.refresh_rounded,
                  color: Colors.white,
                  size: 20.w,
                ),
                label: Text(
                  'Try Again',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  padding: EdgeInsets.symmetric(
                    horizontal: 32.w,
                    vertical: 16.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 0,
                  shadowColor: Colors.transparent,
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
      onRefresh: () => controller.fetchSyndicateBuyingListDetails(),
      color: _primaryColor,
      backgroundColor: _neutralLight,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverToBoxAdapter(child: _buildInvestmentHeader()),
          SliverToBoxAdapter(child: _buildTransactionSection()),
          SliverToBoxAdapter(child: _buildPlotsHeader()),
          _buildPlotsList(),
          if (controller.hasMoreBuyingDetailData.value)
            SliverToBoxAdapter(child: _buildLoadMoreButton()),
        ],
      ),
    );
  }

  Widget _buildInvestmentHeader() {
    final dateFormat = DateFormat('dd MMM yyyy');
    final timeFormat = DateFormat('hh:mm a');
    final property = investment.property;
    final totalPlots = _parseUnits(investment.units).length;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 32.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _primaryColor.withValues(alpha:0.9),
              _secondaryColor.withValues(alpha:0.9),
            ],
          ),
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(40.r),
            top: Radius.circular(40.r),
          ),
          boxShadow: [
            BoxShadow(
              color: _primaryColor.withValues(alpha:0.3),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Investment tag
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha:0.2),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.verified_rounded, color: Colors.white, size: 14.w),
                  6.w.horizontalSpace,
                  Text(
                    'SYNDICATE INVESTMENT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),

            20.h.verticalSpace,

            // Property title
            Text(
              property?.name ?? "Syndicate Property",
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -0.5,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            12.h.verticalSpace,

            // Address
            Row(
              children: [
                Icon(
                  Icons.location_on_rounded,
                  color: Colors.white.withValues(alpha:0.9),
                  size: 18.w,
                ),
                8.w.horizontalSpace,
                Expanded(
                  child: Text(
                    property?.address ?? "Location not available",
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: Colors.white.withValues(alpha:0.9),
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            32.h.verticalSpace,

            // Investment stats
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(color: Colors.white.withValues(alpha:0.2)),
              ),
              child: Row(
                children: [
                  _headerStatItem(
                    icon: Icons.grid_view,
                    label: "Total Plots",
                    value: totalPlots.toString(),
                  ),
                  Container(
                    height: 40.h,
                    width: 1,
                    color: Colors.white.withValues(alpha:0.3),
                    margin: EdgeInsets.symmetric(horizontal: 20.w),
                  ),
                  _headerStatItem(
                    icon: Icons.account_balance_wallet_rounded,
                    label: "Investment",
                    value: "₹${_formatNumber(investment.amount)}",
                    isHighlight: true,
                  ),
                  Container(
                    height: 40.h,
                    width: 1,
                    color: Colors.white.withValues(alpha:0.3),
                    margin: EdgeInsets.symmetric(horizontal: 20.w),
                  ),
                  _headerStatItem(
                    icon: Icons.calendar_today,
                    label: "Invested On",
                    value: dateFormat.format(investment.createdAt),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerStatItem({
    required IconData icon,
    required String label,
    required String value,
    bool isHighlight = false,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isHighlight ? Colors.white : Colors.white.withValues(alpha:0.8),
            size: 24.w,
          ),
          8.h.verticalSpace,
          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          4.h.verticalSpace,
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.white.withValues(alpha:0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionSection() {
    final transaction = investment.transaction;
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
    final statusColor = _getStatusColor(transaction?.status);

    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: _primaryColor.withValues(alpha:0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.receipt_long_rounded,
                  color: _primaryColor,
                  size: 22.w,
                ),
              ),
              12.w.horizontalSpace,
              Text(
                'Transaction Summary',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                  color: _neutralDark,
                ),
              ),
            ],
          ),

          20.h.verticalSpace,

          // Transaction card
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha:0.05),
                  blurRadius: 30,
                  spreadRadius: 0,
                  offset: const Offset(0, 10),
                ),
              ],
              border: Border.all(color: Colors.grey.shade100, width: 1),
            ),
            child: Column(
              children: [
                // Status and amount header
                Container(
                  padding: EdgeInsets.all(24.w),
                  decoration: BoxDecoration(
                    color: _neutralLight,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24.r),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Amount',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          4.h.verticalSpace,
                          Text(
                            '₹${transaction?.amount}',
                            style: TextStyle(
                              fontSize: 28.sp,
                              fontWeight: FontWeight.w900,
                              color: _successColor,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              statusColor.withValues(alpha:0.2),
                              statusColor.withValues(alpha:0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 6.w,
                              height: 6.w,
                              decoration: BoxDecoration(
                                color: statusColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            8.w.horizontalSpace,
                            Text(
                              transaction?.status.toUpperCase()??"",
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w800,
                                color: statusColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Transaction details
                Padding(
                  padding: EdgeInsets.all(24.w),
                  child: Column(
                    children: [
                      _detailRow(
                        icon: Icons.credit_card_rounded,
                        label: 'Transaction ID',
                        value: transaction?.transactionId,
                        isCopyable: true,
                      ),
                      20.h.verticalSpace,
                      _detailRow(
                        icon: Icons.payment_rounded,
                        label: 'Payment Method',
                        value: transaction?.paymentMode ?? 'N/A',
                      ),
                      20.h.verticalSpace,
                      _detailRow(
                        icon: Icons.access_time_rounded,
                        label: 'Transaction Time',
                        value: transaction?.createdAt != null
                            ? dateFormat.format(transaction!.createdAt!)
                            : 'N/A',
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

  Widget _detailRow({
    required IconData icon,
    required String label,
    required String? value,
    bool isCopyable = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20.w, color: _primaryColor),
        12.w.horizontalSpace,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
              4.h.verticalSpace,
              GestureDetector(
                onTap: isCopyable
                    ? () {
                        Clipboard.setData(ClipboardData(text: value??''));

                        Get.snackbar(
                          'Copied',
                          'Transaction ID copied to clipboard',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.black87,
                          colorText: Colors.white,
                          duration: const Duration(seconds: 2),
                        );
                      }
                    : null,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        value??"",
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: _neutralDark,
                          fontFamily: isCopyable ? 'RobotoMono' : null,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isCopyable) ...[
                      8.w.horizontalSpace,
                      Icon(
                        Icons.copy_rounded,
                        size: 18.w,
                        color: _primaryColor,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlotsHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 8.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: _primaryColor.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.grid_view_rounded,
              color: _primaryColor,
              size: 20.w,
            ),
          ),
          12.w.horizontalSpace,
          Text(
            'Plot Units (${controller.buyingDetailList.length})',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: _neutralDark,
            ),
          ),
        ],
      ),
    );
  }

  SliverList _buildPlotsList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final detail = controller.buyingDetailList[index];
        return _buildPlotCard(detail);
      }, childCount: controller.buyingDetailList.length),
    );
  }

  // Alternative: Update just the widget to work with existing model

  // Helper method to get color based on transaction status
  Color _getTransactionStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return _successColor;
      case 'pending':
        return _warningColor;
      case 'cancelled':
        return _dangerColor;
      case 'processing':
        return _accentColor;
      case 'failed':
        return _dangerColor;
      default:
        return Colors.grey.shade600;
    }
  }

  Widget _statusChip(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha:0.05),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: color.withValues(alpha:0.2), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title.toUpperCase(),
              style: TextStyle(
                fontSize: 9.sp,
                fontWeight: FontWeight.w800,
                color: color.withValues(alpha:0.7),
                letterSpacing: 0.5,
              ),
            ),
            4.h.verticalSpace,
            Text(
              value,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w800,
                color: color,
              ),
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
      padding: EdgeInsets.symmetric(vertical: 24.h),
      child: Center(
        child: controller.isLoadingBuyingDetail.value
            ? Container(
                width: 50.w,
                height: 50.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha:0.1),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(_primaryColor),
                  ),
                ),
              )
            : ElevatedButton(
                onPressed: controller.loadMoreBuyingDetail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: _primaryColor,
                  side: BorderSide(
                    color: _primaryColor.withValues(alpha:0.3),
                    width: 2,
                  ),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 32.w,
                    vertical: 14.h,
                  ),
                  shadowColor: Colors.transparent,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.expand_more, size: 22.w),
                    8.w.horizontalSpace,
                    Text(
                      'Load More Plots',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  void _showCancelPlotConfirmation(SyndicateBuyingDetail detail) async {

    final BankDetailsController bankCtrl = Get.isRegistered<BankDetailsController>()
        ? Get.find<BankDetailsController>()
        : Get.put(BankDetailsController());

    Get.dialog(
      const Center(
        child: CircularProgressIndicator(),
      ),
      barrierDismissible: false,
      barrierColor: Colors.black26,
    );

    try {
      await bankCtrl.fetchBankDetails();
    } catch (_) {
    } finally {
      if (Get.isDialogOpen ?? false) Get.back();
    }

    final hasActiveBank = bankCtrl.allBankDetails.any((b) => b.isActive);
    if (!hasActiveBank) {
      _showNoBankDialog(bankCtrl.allBankDetails.isEmpty);
      return;
    }

    final int cancelStatus = detail.cancelStatus ?? 0;
    final int refundStatus = detail.refundStatus ?? 0;

    String bookingStatusText;
    Color bookingStatusColor;

    if (cancelStatus == 0) {
      bookingStatusText = 'Active';
      bookingStatusColor = _successColor;
    } else if (cancelStatus == 1) {
      bookingStatusText = 'Request Sent';
      bookingStatusColor = _warningColor;
    } else if (cancelStatus == 2) {
      if (refundStatus == 0) {
        bookingStatusText = 'Cancelled';
        bookingStatusColor = _dangerColor;
      } else if (refundStatus == 1) {
        bookingStatusText = 'Refunded';
        bookingStatusColor = _successColor;
      } else {
        bookingStatusText = 'Cancelled';
        bookingStatusColor = _dangerColor;
      }
    } else {
      bookingStatusText = 'Unknown';
      bookingStatusColor = Colors.grey;
    }

    if (cancelStatus != 0) {
      Get.snackbar(
        'Cannot Cancel',
        cancelStatus == 1
            ? 'Cancellation request already sent'
            : 'Plot is already cancelled',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: _warningColor,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    // Show bottom sheet (unchanged)
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
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            24.h.verticalSpace,
            Container(
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(
                color: _dangerColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.report_gmailerrorred_rounded,
                color: _dangerColor,
                size: 40.r,
              ),
            ),
            20.h.verticalSpace,
            Text(
              'Confirm Cancellation',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w900,
                color: _neutralDark,
              ),
            ),
            12.h.verticalSpace,
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
                children: [
                  const TextSpan(text: 'Are you sure you want to cancel '),
                  TextSpan(
                    text: 'Plot #${detail.unit}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _neutralDark,
                    ),
                  ),
                  const TextSpan(
                    text: '? This action will release the plot back to the syndicate pool.',
                  ),
                ],
              ),
            ),
            24.h.verticalSpace,
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: _accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: _accentColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet_rounded,
                    color: _accentColor,
                    size: 20.w,
                  ),
                  12.w.horizontalSpace,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Estimated Refund',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: _accentColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '₹${detail.amount}',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w900,
                            color: _neutralDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      "AUTO-REFUND",
                      style: TextStyle(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.bold,
                        color: _accentColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            32.h.verticalSpace,
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Get.back(),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    child: Text(
                      'Keep Plot',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.bold,
                        fontSize: 15.sp,
                      ),
                    ),
                  ),
                ),
                16.w.horizontalSpace,
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      _processPlotCancellation(detail);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _dangerColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    child: Text(
                      'Cancel Plot',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                      ),
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

// ✅ Add this No Bank Dialog (same as Gioo version)
  void _showNoBankDialog(bool noAccountAtAll) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  noAccountAtAll
                      ? Icons.account_balance_outlined
                      : Icons.block_rounded,
                  color: Colors.orange.shade700,
                  size: 36,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                noAccountAtAll ? 'No Bank Account Found' : 'Bank Account Inactive',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E293B),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                noAccountAtAll
                    ? 'You need to add an active bank account before requesting a cancellation. Refunds are processed to your registered bank account.'
                    : 'Your bank account is currently inactive. Please activate it before requesting a cancellation so we can process your refund.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.blueGrey.shade600,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded, size: 16, color: Colors.orange.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Refunds are transferred only to an active bank account.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange.shade800,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.blueGrey.shade600,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        Get.to(
                              () => const BankDetailsListScreen(),
                          transition: Transition.rightToLeft,
                          duration: const Duration(milliseconds: 300),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade600,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        noAccountAtAll ? 'Add Account' : 'Manage Account',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  void _processPlotCancellation(SyndicateBuyingDetail detail) async {
    // Show loading dialog
    showDialog(
      context: Get.context!,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        title: Text(
          'Processing Cancellation',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
            color: _neutralDark,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60.w,
              height: 60.w,
              margin: EdgeInsets.symmetric(vertical: 16.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_primaryColor, _secondaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              ),
            ),
            Text(
              'Please wait while we process your cancellation request...',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );

    try {
      await controller.cancelSyndicateBuyingRequest(detail.id);
      if (Navigator.of(Get.context!).canPop()) {
        Navigator.of(Get.context!).pop();
      }
      Get.snackbar(
        'Success',
        'Plot ${detail.unit} cancellation request submitted successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: _successColor,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        borderRadius: 12.r,
        margin: EdgeInsets.all(16.w),
      );

      // Refresh the details
      await controller.fetchSyndicateBuyingListDetails();
    } catch (error) {
      // Close dialog
      if (Navigator.of(Get.context!).canPop()) {
        Navigator.of(Get.context!).pop();
      }

      // Show error message
      Get.snackbar(
        'Error',
        'Failed to cancel plot: $error',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: _dangerColor,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        borderRadius: 12.r,
        margin: EdgeInsets.all(16.w),
      );
    }
  }

  // Update your plot card to include the cancel button with proper status handling
  Widget _buildPlotCard(SyndicateBuyingDetail detail) {
    // Determine status based on model
    final int cancelStatus = detail.cancelStatus ?? 0;
    final int refundStatus = detail.refundStatus ?? 0;
    final bool isActive = cancelStatus == 0;
    final bool isRequestSent = cancelStatus == 1;
    final bool isCancelled = cancelStatus == 2;
    final bool isRefunded = refundStatus == 1;

    // Status text and color logic
    String statusText;
    Color statusColor;

    if (cancelStatus == 0) {
      statusText = 'Active';
      statusColor = _successColor;
    } else if (cancelStatus == 1) {
      statusText = 'Request Sent';
      statusColor = _warningColor;
    } else if (cancelStatus == 2) {
      if (refundStatus == 0) {
        statusText = 'Cancelled';
        statusColor = _dangerColor;
      } else if (refundStatus == 1) {
        statusText = 'Refunded';
        statusColor = _successColor;
      } else {
        statusText = 'Cancelled';
        statusColor = _dangerColor;
      }
    } else {
      statusText = 'Unknown';
      statusColor = Colors.grey;
    }

    print('userTransactionId${detail.bookingSyndicate?.first.transactionUserId }');

    return Container(
      margin: EdgeInsets.fromLTRB(24.w, 0, 24.w, 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100, width: 1),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Row(
              children: [
                // Plot number with gradient
                Container(
                  width: 60.w,
                  height: 60.w,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_primaryColor, _secondaryColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Center(
                    child: Text(
                      detail.unit,
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                16.w.horizontalSpace,

                // Plot details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Plot #${detail.unit}',
                        style: TextStyle(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w800,
                          color: _neutralDark,
                        ),
                      ),
                      4.h.verticalSpace,
                      Text(
                        'Investment: ₹${detail.amount}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Cancel button - only show for active plots
                if (cancelStatus == 0)
                  Material(
                    color: _dangerColor.withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(12.r),
                    child: InkWell(
                      onTap: () => _showCancelPlotConfirmation(detail),
                      borderRadius: BorderRadius.circular(12.r),
                      child: Padding(
                        padding: EdgeInsets.all(12.w),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: _dangerColor,
                          ),
                        ),
                      ),
                    ),
                  ),

                // Status indicators for non-active plots
                if (cancelStatus == 1)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: _warningColor.withValues(alpha:0.1),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: _warningColor.withValues(alpha:0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.hourglass_top_rounded,
                          size: 14.w,
                          color: _warningColor,
                        ),
                        4.w.horizontalSpace,
                        Text(
                          'Request Sent',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: _warningColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                if (cancelStatus == 2 && refundStatus == 0)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: _dangerColor.withValues(alpha:0.1),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: _dangerColor.withValues(alpha:0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.cancel_rounded,
                          size: 14.w,
                          color: _dangerColor,
                        ),
                        4.w.horizontalSpace,
                        Text(
                          'Cancelled',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: _dangerColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                if (refundStatus == 1)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: _successColor.withValues(alpha:0.1),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: _successColor.withValues(alpha:0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          size: 14.w,
                          color: _successColor,
                        ),
                        4.w.horizontalSpace,
                        Text(
                          'Refunded',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: _successColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

              ],
            ),
          ),

          // Status section
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: _neutralLight,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(24.r),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    _statusChip('Plot Status', statusText, statusColor),
                    12.w.horizontalSpace,
                    _statusChip(
                      'Payment',
                      detail.transaction.status,
                      _getStatusColor(detail.transaction.status),
                    ),
                  ],
                ),

                // Refund info if applicable
                if (isCancelled && !isRefunded)
                  Padding(
                    padding: EdgeInsets.only(top: 16.h),
                    child: Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _warningColor.withValues(alpha:0.1),
                            _primaryColor.withValues(alpha:0.1),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.timer_rounded,
                            color: _warningColor,
                            size: 20.w,
                          ),
                          12.w.horizontalSpace,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Refund Status',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: _warningColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                4.h.verticalSpace,
                                Text(
                                  'Your Amount Refund',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                    color: _neutralDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                if (isRefunded)
                  Padding(
                    padding: EdgeInsets.only(top: 16.h),
                    child: Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _accentColor.withValues(alpha:0.1),
                            _primaryColor.withValues(alpha:0.1),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.account_balance_wallet_rounded,
                            color: _accentColor,
                            size: 20.w,
                          ),
                          12.w.horizontalSpace,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Refund Amount',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: _accentColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                4.h.verticalSpace,
                                Text(
                                  '₹${detail.refundAmountValue?.toStringAsFixed(2) ?? detail.amount}',
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w900,
                                    color: _neutralDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              'REFUNDED',
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w800,
                                color: _accentColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                if ((detail.bookingSyndicate?.isNotEmpty ?? false) &&
                    (detail.bookingSyndicate!.first.transactionUserId?.isNotEmpty ?? false) && (isCancelled && !isRefunded)) ...[
                  10.h.verticalSpace,
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.green.shade100),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Refund Transaction ID",
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        6.h.verticalSpace,
                        SelectableText(
                          detail.bookingSyndicate!.first.transactionUserId??'',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.green.shade900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(String amount) {
    try {
      final value = double.parse(amount);
      if (value >= 10000000) {
        return '${(value / 10000000).toStringAsFixed(2)}Cr';
      } else if (value >= 100000) {
        return '${(value / 100000).toStringAsFixed(2)}L';
      } else if (value >= 1000) {
        return '${(value / 1000).toStringAsFixed(2)}K';
      }
      return value.toStringAsFixed(0);
    } catch (e) {
      return amount;
    }
  }

  List<String> _parseUnits(String? units) {
    try {
      if (units == null || units.trim().isEmpty) {
        return [];
      }

      return units
          .split(',')
          .map((unit) => unit.trim())
          .toList();
    } catch (e) {
      return [];
    }
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
        return _successColor;
      case 'pending':
        return _warningColor;
      case 'cancelled':
        return _dangerColor;
      case 'processing':
        return _accentColor;
      default:
        return Colors.grey;
    }
  }
}
