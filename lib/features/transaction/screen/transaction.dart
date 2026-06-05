import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

import '../../../common/colours.dart';
import '../controller/transaction.dart';
import '../model/transaction_model.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({Key? key}) : super(key: key);

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen>
    with SingleTickerProviderStateMixin {
  final TransactionController controller = Get.put(TransactionController());
  late TabController _tabController;

  static const List<String> _tabLabels = [
    'Gioo Nano Plots',
    'Gio Rental Yield – Syndicate Plot',
    'Flats / Villas',
    'Land',
    'Gio Rental Yield',
  ];

  static const List<TransactionType> _tabTypes = [
    TransactionType.gioo,
    TransactionType.syndicate,
    TransactionType.residential,
    TransactionType.market,
    TransactionType.rental,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 5,
      vsync: this,
      initialIndex: controller.currentTabIndex.value,
    );
    _tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) return;
    HapticFeedback.selectionClick();
    controller.changeTab(_tabController.index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F9),
      appBar: AppBar(
        backgroundColor: AppColor.primary,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Transactions',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => controller.refreshCurrentTab(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50.h),
          child: Container(
            color: AppColor.primary,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorColor: Colors.white,
              indicatorWeight: 3.5,
              indicatorSize: TabBarIndicatorSize.label,
              indicatorPadding: EdgeInsets.only(bottom: 6.h),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withOpacity(0.55),
              labelStyle: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700),
              unselectedLabelStyle: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500),
              dividerColor: Colors.transparent,
              tabs: _tabLabels.map((label) => Tab(text: label)).toList(),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: List.generate(5, (i) => _buildTransactionList(_tabTypes[i], _tabLabels[i])),
      ),
    );
  }

  Widget _buildTransactionList(TransactionType type, String tabLabel) {
    return Obx(() {
      final transactions = _getTransactionsByType(type);
      final isLoading = _getLoadingByType(type);
      final meta = _getMetaByType(type);
      final errorMessage = _getErrorByType(type);

      if (isLoading && transactions.isEmpty) {
        return Center(child: CircularProgressIndicator(color: AppColor.primary));
      }

      if (errorMessage.isNotEmpty && transactions.isEmpty) {
        return _buildErrorState(errorMessage, type);
      }

      if (transactions.isEmpty) {
        return _buildEmptyState(type, tabLabel);
      }

      return Column(
        children: [
          SizedBox(height: 10.h),
          _buildSummaryBar(transactions.length, meta.total, type, tabLabel),
          Expanded(
            child: RefreshIndicator(
              color: AppColor.primary,
              onRefresh: () => _refreshTab(type),
              child: ListView.builder(
                padding: EdgeInsets.only(bottom: 20.h, top: 6.h),
                itemCount: transactions.length + 1,
                itemBuilder: (context, index) {
                  if (index < transactions.length) {
                    return _buildAnimatedCard(transactions[index], index);
                  } else {
                    return _buildLoadMoreWidget(meta, type, isLoading);
                  }
                },
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildSummaryBar(int showing, int total, TransactionType type, String tabLabel) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: AppColor.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.receipt_long_rounded, size: 14.sp, color: AppColor.primary),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              'Showing $showing of $total records',
              style: TextStyle(color: Colors.grey[700], fontSize: 11.sp, fontWeight: FontWeight.w600),
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildAnimatedCard(Transaction transaction, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 350 + (index.clamp(0, 6) * 60)),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutQuart,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: _buildModernCard(transaction),
    );
  }


/*
  Widget _buildModernCard(Transaction transaction) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(14.w),
            child: Row(
              children: [
                Container(
                  width: 46.w,
                  height: 46.w,
                  decoration: BoxDecoration(
                    color: AppColor.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Icon(
                    _getPaymentIcon(transaction.paymentType),
                    color: AppColor.primary,
                    size: 22.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.propertyName.isNotEmpty
                            ? transaction.propertyName
                            : transaction.propertyType,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13.sp,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 3.h),
                      Row(
                        children: [
                          Icon(Icons.person_outline_rounded, size: 10.sp, color: Colors.grey[400]),
                          SizedBox(width: 3.w),
                          Text(
                            transaction.userName.isNotEmpty ? transaction.userName : 'User',
                            style: TextStyle(fontSize: 10.sp, color: Colors.grey[500]),
                          ),
                          SizedBox(width: 8.w),
                          Container(
                            width: 3.w,
                            height: 3.w,
                            decoration: const BoxDecoration(
                              color: Colors.grey,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Icon(Icons.payment_outlined, size: 10.sp, color: Colors.grey[400]),
                          SizedBox(width: 3.w),
                          Text(
                            transaction.paymentType,
                            style: TextStyle(fontSize: 10.sp, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${transaction.amount}',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15.sp,
                        color: AppColor.primary,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      _formatDate(transaction.createdAt),
                      style: TextStyle(fontSize: 9.sp, color: Colors.grey[400]),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey.withOpacity(0.1)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_getTransactionTypeFromTab() == TransactionType.syndicate ||
                    _getTransactionTypeFromTab() == TransactionType.rental)
                GestureDetector(
                  onTap: () => _showAddTransactionSheet(
                      _getTransactionTypeFromTab(),
                      _tabLabels[_tabController.index],
                      transaction
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(30.r),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.shopping_cart_outlined, size: 12, color: Colors.green.shade700),
                        SizedBox(width: 4.w),
                        Text(
                          'Add Transaction',
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w600,
                            fontSize: 10.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => controller.downloadInvoice(transaction.invoiceUrl),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
                    decoration: BoxDecoration(
                      color: AppColor.primary,
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.open_in_browser_rounded, size: 14, color: Colors.white),
                        SizedBox(width: 5.w),
                        Text(
                          'View Receipt',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 11.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
*/
/*
  Widget _buildModernCard(Transaction transaction) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(14.w),
            child: Row(
              children: [
                Container(
                  width: 46.w,
                  height: 46.w,
                  decoration: BoxDecoration(
                    color: AppColor.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Icon(
                    _getPaymentIcon(transaction.paymentType),
                    color: AppColor.primary,
                    size: 22.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.propertyName.isNotEmpty
                            ? transaction.propertyName
                            : transaction.propertyType,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13.sp,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 3.h),
                      Row(
                        children: [
                          Icon(Icons.person_outline_rounded, size: 10.sp, color: Colors.grey[400]),
                          SizedBox(width: 3.w),
                          Text(
                            transaction.userName.isNotEmpty ? transaction.userName : 'User',
                            style: TextStyle(fontSize: 10.sp, color: Colors.grey[500]),
                          ),
                          SizedBox(width: 8.w),
                          Container(
                            width: 3.w,
                            height: 3.w,
                            decoration: const BoxDecoration(
                              color: Colors.grey,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Icon(Icons.payment_outlined, size: 10.sp, color: Colors.grey[400]),
                          SizedBox(width: 3.w),
                          Text(
                            transaction.paymentType,
                            style: TextStyle(fontSize: 10.sp, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${transaction.amount}',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15.sp,
                        color: AppColor.primary,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      _formatDate(transaction.createdAt),
                      style: TextStyle(fontSize: 9.sp, color: Colors.grey[400]),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey.withOpacity(0.1)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_getTransactionTypeFromTab() == TransactionType.syndicate ||
                    _getTransactionTypeFromTab() == TransactionType.rental)
                GestureDetector(
                  onTap: () => _showAddTransactionSheet(
                      _getTransactionTypeFromTab(),
                      _tabLabels[_tabController.index],
                      transaction
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(30.r),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.shopping_cart_outlined, size: 12, color: Colors.green.shade700),
                        SizedBox(width: 4.w),
                        Text(
                          'Add Transaction',
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w600,
                            fontSize: 10.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => controller.downloadInvoice(transaction.invoiceUrl),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
                    decoration: BoxDecoration(
                      color: AppColor.primary,
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.open_in_browser_rounded, size: 14, color: Colors.white),
                        SizedBox(width: 5.w),
                        Text(
                          'View Receipt',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 11.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
*/

  TransactionType _getTransactionTypeFromTab() {
    return _tabTypes[_tabController.index];
  }


  Widget _buildModernCard(Transaction transaction) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Top Row (unchanged) ──────────────────────────────
          Padding(
            padding: EdgeInsets.all(14.w),
            child: Row(
              children: [
                Container(
                  width: 46.w,
                  height: 46.w,
                  decoration: BoxDecoration(
                    color: AppColor.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Icon(
                    _getPaymentIcon(transaction.paymentType),
                    color: AppColor.primary,
                    size: 22.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.propertyName.isNotEmpty
                            ? transaction.propertyName
                            : transaction.propertyType,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13.sp,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${transaction.amount}',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15.sp,
                        color: AppColor.primary,
                      ),
                    ),

                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding:  EdgeInsets.symmetric(horizontal: 15.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.payment_outlined, size: 10.sp, color: Colors.grey[400]),
                    SizedBox(width: 3.w),
                    Text(
                      transaction.paymentType,
                      style: TextStyle(fontSize: 10.sp, color: Colors.grey[500]),
                    ),
                  ],
                ),
                Text(
                  _formatDate(transaction.createdAt),
                  style: TextStyle(fontSize: 9.sp, color: Colors.grey[400]),
                ),
              ],
            ),
          ),
          SizedBox(height: 5.h,),
          if (_getTransactionTypeFromTab() == TransactionType.syndicate ||
              _getTransactionTypeFromTab() == TransactionType.rental)
            ...[
              Divider(height: 1, color: Colors.grey.withOpacity(0.1)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Status',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(color: Colors.orange.shade200),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 5.w,
                                height: 5.w,
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade500,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                'Processing',
                                style: TextStyle(
                                  fontSize: 9.sp,
                                  color: Colors.orange.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),

                    // ── Step indicators ──────────────────────────
                    Row(
                      children: [
                        // Step 1 — Tracking (done ✅)
                        _buildStep(
                          icon: Icons.radar_rounded,
                          label: 'Tracking',
                          isActive: true,
                          isDone: true,
                        ),

                        // Connector line
                        Expanded(
                          child: Stack(
                            alignment: Alignment.centerLeft,
                            children: [
                              Container(height: 2.h, color: Colors.grey.shade200),
                              FractionallySizedBox(
                                widthFactor: 0.5,
                                child: Container(
                                  height: 2.h,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Colors.green.shade400, Colors.orange.shade400],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Step 2 — Processing (active 🔄)
                        _buildStep(
                          icon: Icons.autorenew_rounded,
                          label: 'Processing',
                          isActive: true,
                          isDone: false,
                        ),

                        // Connector line
                        Expanded(
                          child: Container(height: 2.h, color: Colors.grey.shade200),
                        ),

                        // Step 3 — Completed (pending)
                        _buildStep(
                          icon: Icons.check_circle_outline_rounded,
                          label: 'Completed',
                          isActive: false,
                          isDone: false,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Divider(height: 1, color: Colors.grey.withOpacity(0.1)),
            ],

          // ── Bottom Buttons (unchanged) ───────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_getTransactionTypeFromTab() == TransactionType.syndicate ||
                    _getTransactionTypeFromTab() == TransactionType.rental)
                  GestureDetector(
                    onTap: () => _showAddTransactionSheet(
                      _getTransactionTypeFromTab(),
                      _tabLabels[_tabController.index],
                      transaction,
                    ),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(30.r),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.shopping_cart_outlined, size: 12, color: Colors.green.shade700),
                          SizedBox(width: 4.w),
                          Text(
                            'Add Transaction',
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w600,
                              fontSize: 10.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                GestureDetector(
                  onTap: () => controller.downloadInvoice(transaction.invoiceUrl),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
                    decoration: BoxDecoration(
                      color: AppColor.primary,
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.open_in_browser_rounded, size: 14, color: Colors.white),
                        SizedBox(width: 5.w),
                        Text(
                          'View Receipt',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 11.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

// ── ✅ Helper: Step Widget ────────────────────────────────────
  Widget _buildStep({
    required IconData icon,
    required String label,
    required bool isActive,
    required bool isDone,
  }) {
    final Color activeColor = isDone ? Colors.green.shade500 : Colors.orange.shade500;
    final Color bgColor = isDone
        ? Colors.green.shade50
        : isActive
        ? Colors.orange.shade50
        : Colors.grey.shade100;
    final Color iconColor = isDone
        ? Colors.green.shade600
        : isActive
        ? Colors.orange.shade600
        : Colors.grey.shade400;

    return Column(
      children: [
        Container(
          width: 32.w,
          height: 32.w,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive || isDone ? activeColor : Colors.grey.shade300,
              width: 1.5,
            ),
          ),
          child: Icon(icon, size: 15.sp, color: iconColor),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 8.sp,
            fontWeight: isActive || isDone ? FontWeight.w600 : FontWeight.w400,
            color: isActive || isDone ? Colors.black87 : Colors.grey[400],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(TransactionType type, String tabLabel) {
    // Clean up the tab label for a more natural sentence flow
    final formattedLabel = tabLabel.toLowerCase().replaceAll('transactions', '').trim();

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon Container with Gradient & Soft Shadow
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColor.primary.withOpacity(0.08),
                    AppColor.primary.withOpacity(0.03),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.primary.withOpacity(0.04),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                Icons.history_toggle_off_rounded,
                size: 56.sp, // Slightly larger for better visual hierarchy
                color: AppColor.primary.withOpacity(0.6),
              ),
            ),
            SizedBox(height: 24.h),

            // Main Title
            Text(
              'No Transactions Found',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[800], // Darker contrast for better readability
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            SizedBox(height: 8.h),

            // Contextual Subtitle
            Text(
              "You haven't made any $formattedLabel transactions yet.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.grey[500],
                fontWeight: FontWeight.w400,
                height: 1.4, // Better line spacing
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String msg, TransactionType type) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, color: Colors.red[300], size: 40.sp),
            SizedBox(height: 10.h),
            Text(msg, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600], fontSize: 13.sp)),
            SizedBox(height: 12.h),
            TextButton(onPressed: () => _refreshTab(type), child: const Text('Try Again')),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadMoreWidget(TransactionMeta meta, TransactionType type, bool isLoading) {
    if (meta.currentPage >= meta.lastPage) return SizedBox(height: 20.h);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.h),
      child: isLoading
          ? Center(child: CircularProgressIndicator(color: AppColor.primary, strokeWidth: 2))
          : Center(
        child: OutlinedButton(
          onPressed: () => _loadMore(type),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColor.primary,
            side: BorderSide(color: AppColor.primary.withOpacity(0.5)),
            shape: const StadiumBorder(),
          ),
          child: Text('Load More', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp)),
        ),
      ),
    );
  }

  List<Transaction> _getTransactionsByType(TransactionType t) {
    if (t == TransactionType.gioo) return controller.giooTransactions;
    if (t == TransactionType.syndicate) return controller.syndicateTransactions;
    if (t == TransactionType.residential) return controller.residentialTransactions;
    if (t == TransactionType.market) return controller.marketTransactions;
    if (t == TransactionType.rental) return controller.rentalTransactions;
    return [];
  }

  bool _getLoadingByType(TransactionType t) {
    if (t == TransactionType.gioo) return controller.isLoadingGioo.value;
    if (t == TransactionType.syndicate) return controller.isLoadingSyndicate.value;
    if (t == TransactionType.residential) return controller.isLoadingResidential.value;
    if (t == TransactionType.market) return controller.isLoadingMarket.value;
    if (t == TransactionType.rental) return controller.isLoadingRental.value;
    return false;
  }

  TransactionMeta _getMetaByType(TransactionType t) {
    if (t == TransactionType.gioo) return controller.giooMeta.value;
    if (t == TransactionType.syndicate) return controller.syndicateMeta.value;
    if (t == TransactionType.residential) return controller.residentialMeta.value;
    if (t == TransactionType.market) return controller.marketMeta.value;
    if (t == TransactionType.rental) return controller.rentalMeta.value;
    return TransactionMeta(currentPage: 1, lastPage: 1, perPage: 10, total: 0);
  }

  String _getErrorByType(TransactionType t) {
    if (t == TransactionType.gioo) return controller.giooErrorMessage;
    if (t == TransactionType.syndicate) return controller.syndicateErrorMessage;
    if (t == TransactionType.residential) return controller.residentialErrorMessage;
    if (t == TransactionType.market) return controller.marketErrorMessage;
    if (t == TransactionType.rental) return controller.rentalErrorMessage;
    return '';
  }

  IconData _getPaymentIcon(String type) {
    final t = type.toLowerCase();
    if (t.contains('cash')) return Icons.account_balance_wallet_rounded;
    if (t.contains('bank')) return Icons.account_balance_rounded;
    if (t.contains('cheque')) return Icons.description_rounded;
    if (t.contains('dd')) return Icons.request_quote_rounded;
    return Icons.payment_rounded;
  }

  String _formatDate(String date) {
    try {
      return DateFormat('dd MMM yyyy • hh:mm a').format(DateTime.parse(date).toLocal());
    } catch (_) {
      return date;
    }
  }

  Future<void> _refreshTab(TransactionType type) async {
    if (type == TransactionType.gioo) await controller.fetchGiooTransactions();
    if (type == TransactionType.syndicate) await controller.fetchSyndicateTransactions();
    if (type == TransactionType.residential) await controller.fetchResidentialTransactions();
    if (type == TransactionType.market) await controller.fetchMarketTransactions();
    if (type == TransactionType.rental) await controller.fetchRentalTransactions();
  }

  void _loadMore(TransactionType type) => controller.loadMoreTransactions(type);

  void _showAddTransactionSheet(TransactionType type, String tabLabel, Transaction? existingTransaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddTransactionSheet(
        controller: controller,
        transactionType: type,
        tabLabel: tabLabel,
        existingTransaction: existingTransaction,
      ),
    );
  }
}

// ==================== ADD TRANSACTION SHEET ====================

class AddTransactionSheet extends StatefulWidget {
  final TransactionController controller;
  final TransactionType transactionType;
  final String tabLabel;
  final Transaction? existingTransaction;

  const AddTransactionSheet({
    Key? key,
    required this.controller,
    required this.transactionType,
    required this.tabLabel,
    this.existingTransaction,
  }) : super(key: key);

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _propertyIdController = TextEditingController();
  final _amountController = TextEditingController();
  final _otherDetailsController = TextEditingController();
  final _chequeNumberController = TextEditingController();
  final _ddNumberController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _transactionRefController = TextEditingController();

  String? _selectedPaymentMode;
  final List<DateTime> _selectedDates = [];
  File? _receiptImage;
  final ImagePicker _imagePicker = ImagePicker();

  final List<Map<String, dynamic>> _paymentModes = [
    {'value': 'bank_transfer', 'label': 'Bank Transfer', 'icon': Icons.account_balance_rounded},
    {'value': 'cash', 'label': 'Cash', 'icon': Icons.account_balance_wallet_rounded},
    {'value': 'cheque', 'label': 'Cheque', 'icon': Icons.description_rounded},
    {'value': 'dd', 'label': 'DD', 'icon': Icons.request_quote_rounded},
    {'value': 'others', 'label': 'Others', 'icon': Icons.more_horiz_rounded},
  ];

  String get _apiTypeString {
    switch (widget.transactionType) {
      case TransactionType.gioo: return 'gioo';
      case TransactionType.syndicate: return 'syndicate';
      case TransactionType.residential: return 'residential';
      case TransactionType.market: return 'market';
      case TransactionType.rental: return 'rental';
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.existingTransaction != null) {
      _propertyIdController.text = widget.existingTransaction!.id.toString();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _propertyIdController.dispose();
    _amountController.dispose();
    _otherDetailsController.dispose();
    _chequeNumberController.dispose();
    _ddNumberController.dispose();
    _bankNameController.dispose();
    _transactionRefController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    if (_selectedDates.length >= 3) {
      Get.snackbar(
        'Limit Reached',
        'Maximum 3 registration dates allowed',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange.shade50,
        colorText: Colors.orange.shade800,
      );
      return;
    }

    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);

    final DateTime blockedUntil = today.add(const Duration(days: 6));
    final DateTime firstDate = blockedUntil.add(const Duration(days: 1));
    final DateTime lastDate = DateTime(today.year + 5, today.month, today.day);

    DateTime initialDate = firstDate;
    for (int i = 0; i <= 365 * 5; i++) {
      final DateTime candidate = firstDate.add(Duration(days: i));
      final bool alreadySelected = _selectedDates.any(
            (date) =>
        date.year == candidate.year &&
            date.month == candidate.month &&
            date.day == candidate.day,
      );
      if (!alreadySelected) {
        initialDate = candidate;
        break;
      }
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      selectableDayPredicate: (DateTime day) {
        final DateTime checkDay = DateTime(day.year, day.month, day.day);
        if (!checkDay.isAfter(blockedUntil)) return false;
        final bool alreadySelected = _selectedDates.any(
              (date) =>
          date.year == checkDay.year &&
              date.month == checkDay.month &&
              date.day == checkDay.day,
        );
        return !alreadySelected;
      },
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColor.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDates.add(
          DateTime(picked.year, picked.month, picked.day),
        );
        _selectedDates.sort();
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        setState(() {
          _receiptImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image: $e');
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  final _scrollController = ScrollController();
  final _paymentModeKey = GlobalKey();
  final _datesKey = GlobalKey();
  final _amountKey = GlobalKey();

  void _scrollToKey(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        alignment: 0.3,
      );
    }
  }

  Future<void> _submit() async {

    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      _scrollToKey(_amountKey);
      Get.snackbar('Error', 'Amount is required',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red.shade50,
          colorText: Colors.red);
      return;
    }

    if (_selectedPaymentMode == null) {
      _scrollToKey(_paymentModeKey);
      Get.snackbar('Required', 'Please select a payment mode',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red.shade50,
          colorText: Colors.red);
      return;
    }

    final RegExp numberRegex = RegExp(r'^\d+(?:\.\d+)?$');
    if (!numberRegex.hasMatch(amountText)) {
      Get.snackbar('Error', 'Amount must be a valid number (e.g., 1000 or 1500.50)',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red.shade50,
          colorText: Colors.red);
      return;
    }

    if (_selectedDates.isEmpty) {
      _scrollToKey(_datesKey);
      Get.snackbar(
        'Dates Required',
        'Please select registration dates (max 3)',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red,
      );
      return;
    }
    if (_selectedDates.length < 3) {
      _scrollToKey(_datesKey);
      Get.snackbar(
        'Add More Dates',
        'You selected ${_selectedDates.length} date(s). Please select ${3 - _selectedDates.length} more',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange.shade50,
        colorText: Colors.orange.shade800,
      );
      return;
    }

    String paymentDetails = '';
    if (_selectedPaymentMode == 'cheque') {
      paymentDetails = 'Cheque No: ${_chequeNumberController.text.trim()}';
      if (_bankNameController.text.trim().isNotEmpty) {
        paymentDetails += ', Bank: ${_bankNameController.text.trim()}';
      }
    } else if (_selectedPaymentMode == 'dd') {
      paymentDetails = 'DD No: ${_ddNumberController.text.trim()}';
      if (_bankNameController.text.trim().isNotEmpty) {
        paymentDetails += ', Bank: ${_bankNameController.text.trim()}';
      }
    } else if (_selectedPaymentMode == 'bank_transfer') {
      paymentDetails = 'Ref: ${_transactionRefController.text.trim()}';
      if (_bankNameController.text.trim().isNotEmpty) {
        paymentDetails += ', Bank: ${_bankNameController.text.trim()}';
      }
    } else if (_selectedPaymentMode == 'others') {
      paymentDetails = _otherDetailsController.text.trim();
    }

    final formData = {
      if (widget.existingTransaction != null) 'property_id': widget.existingTransaction!.id.toString(),
      'amount': amountText,
      'payment_mode': _selectedPaymentMode,
      'other_details': paymentDetails.isNotEmpty ? paymentDetails : _otherDetailsController.text.trim(),
      'registration_date': _selectedDates
          .map((d) => DateFormat('yyyy-MM-dd').format(d))
          .toList(),
      'type': _apiTypeString,
      if (_receiptImage != null) 'image': _receiptImage,
      if (widget.existingTransaction != null) 'transaction_id': widget.existingTransaction!.id.toString(),
    };

    Navigator.pop(context);
    await widget.controller.addTransactionDetails(formData);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: EdgeInsets.only(top: 12.h, bottom: 4.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: AppColor.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(Icons.add_card_rounded, color: AppColor.primary, size: 20.sp),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.existingTransaction != null ? 'Add Purchase Details' : 'Add Transaction',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        widget.tabLabel,
                        style: TextStyle(fontSize: 11.sp, color: AppColor.primary, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: EdgeInsets.all(6.w),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close_rounded, size: 18.sp, color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey[100]),
          Flexible(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.info_outline, size: 12.sp, color: Colors.orange.shade700),
                          SizedBox(width: 5.w),
                          Text(
                            'Only Property ID, Amount & Payment Mode are mandatory',
                            style: TextStyle(fontSize: 10.sp, color: Colors.orange.shade700),
                          ),
                        ],
                      ),
                    ),
                    // SizedBox(height: 16.h),
                    //
                    // _buildLabel('Property ID *', Icons.home_work_outlined, isMandatory: true),
                    // SizedBox(height: 6.h),
                    // _buildTextField(
                    //   controller: _propertyIdController,
                    //   hint: 'Enter property ID',
                    //   keyboardType: TextInputType.number,
                    //   validator: (v) => (v == null || v.isEmpty) ? 'Property ID is required' : null,
                    // ),
                    SizedBox(height: 16.h),
                    SizedBox(key: _amountKey, height: 0),
                    _buildLabel('Amount (₹) *', Icons.currency_rupee_rounded, isMandatory: true),
                    SizedBox(height: 6.h),
                    _buildTextField(
                      controller: _amountController,
                      hint: 'Enter amount (e.g., 1000 or 1500.50)',
                      keyboardType: TextInputType.number,
                      validator: (v) => (v == null || v.isEmpty) ? 'Amount is required' : null,
                    ),
                    SizedBox(height: 16.h),
                    SizedBox(key: _paymentModeKey, height: 0),
                    _buildLabel('Payment Mode *', Icons.payment_rounded, isMandatory: true),
                    SizedBox(height: 10.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: _paymentModes.map((mode) {
                        final bool selected = _selectedPaymentMode == mode['value'];
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedPaymentMode = mode['value'] as String;
                              _chequeNumberController.clear();
                              _ddNumberController.clear();
                              _bankNameController.clear();
                              _transactionRefController.clear();
                              _otherDetailsController.clear();
                            });
                          },
                          child: Container(
                            width: (MediaQuery.of(context).size.width - 80.w) / 3,
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            decoration: BoxDecoration(
                              color: selected ? AppColor.primary : Colors.grey[50],
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: selected ? AppColor.primary : Colors.grey[200]!,
                                width: selected ? 1.5 : 1,
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  mode['icon'] as IconData,
                                  size: 20.sp,
                                  color: selected ? Colors.white : Colors.grey[600],
                                ),
                                SizedBox(height: 5.h),
                                Text(
                                  mode['label'] as String,
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w600,
                                    color: selected ? Colors.white : Colors.grey[600],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 16.h),

                    if (_selectedPaymentMode == 'cheque') ...[
                      _buildLabel('Cheque Number', Icons.description_rounded),
                      SizedBox(height: 6.h),
                      _buildTextField(
                        controller: _chequeNumberController,
                        hint: 'Enter cheque number',
                      ),
                      SizedBox(height: 12.h),
                      _buildLabel('Bank Name (Optional)', Icons.account_balance_rounded, optional: true),
                      SizedBox(height: 6.h),
                      _buildTextField(
                        controller: _bankNameController,
                        hint: 'Enter bank name',
                      ),
                      SizedBox(height: 16.h),
                    ],

                    if (_selectedPaymentMode == 'dd') ...[
                      _buildLabel('DD Number', Icons.request_quote_rounded),
                      SizedBox(height: 6.h),
                      _buildTextField(
                        controller: _ddNumberController,
                        hint: 'Enter DD number',
                      ),
                      SizedBox(height: 12.h),
                      _buildLabel('Bank Name (Optional)', Icons.account_balance_rounded, optional: true),
                      SizedBox(height: 6.h),
                      _buildTextField(
                        controller: _bankNameController,
                        hint: 'Enter bank name',
                      ),
                      SizedBox(height: 16.h),
                    ],

                    if (_selectedPaymentMode == 'bank_transfer') ...[
                      _buildLabel('Transaction Reference', Icons.receipt_rounded),
                      SizedBox(height: 6.h),
                      _buildTextField(
                        controller: _transactionRefController,
                        hint: 'Enter transaction reference/UTR',
                      ),
                      SizedBox(height: 12.h),
                      _buildLabel('Bank Name (Optional)', Icons.account_balance_rounded, optional: true),
                      SizedBox(height: 6.h),
                      _buildTextField(
                        controller: _bankNameController,
                        hint: 'Enter bank name',
                      ),
                      SizedBox(height: 16.h),
                    ],

                    if (_selectedPaymentMode == 'others') ...[
                      _buildLabel('Payment Details', Icons.edit_note_rounded),
                      SizedBox(height: 6.h),
                      _buildTextField(
                        controller: _otherDetailsController,
                        hint: 'Enter payment details',
                        maxLines: 2,
                      ),
                      SizedBox(height: 16.h),
                    ],

                    if (_selectedPaymentMode != 'others')
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Bank Details', Icons.notes_rounded, optional: true),
                          SizedBox(height: 6.h),
                          _buildTextField(
                            controller: _otherDetailsController,
                            hint: 'Any additional notes...',
                            maxLines: 2,
                          ),
                          SizedBox(height: 16.h),
                        ],
                      ),
                    Row(
                      key: _datesKey,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Registration Dates *', Icons.calendar_today_outlined, optional: false, isMandatory: true),
                            Text(
                              'Select up to 3 registration dates',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 9.sp,
                              ),
                            ),
                          ],
                        ),

                        GestureDetector(
                          onTap: _pickDate,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                            decoration: BoxDecoration(
                              color: AppColor.primary.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.add, size: 13.sp, color: AppColor.primary),
                                SizedBox(width: 3.w),
                                Text(
                                  'Add Date',
                                  style: TextStyle(fontSize: 11.sp, color: AppColor.primary, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),

                    if (_selectedDates.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Center(
                          child: Text(
                            'No dates selected',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12.sp,
                            ),
                          ),
                        ),
                      )
                    else
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: _selectedDates.asMap().entries.map((entry) {
                          final date = entry.value;

                          return Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColor.primary.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(
                                color: AppColor.primary.withOpacity(0.2),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.event_rounded,
                                  size: 12.sp,
                                  color: AppColor.primary,
                                ),
                                SizedBox(width: 5.w),

                                Text(
                                  DateFormat('dd MMM yyyy').format(date),
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: AppColor.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),

                                SizedBox(width: 6.w),

                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedDates.removeAt(entry.key);
                                    });
                                  },
                                  child: Icon(
                                    Icons.close_rounded,
                                    size: 12.sp,
                                    color: AppColor.primary,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),

                    SizedBox(height: 16.h),

                    _buildLabel('Receipt Image', Icons.image_outlined, optional: true),
                    SizedBox(height: 10.h),

                    GestureDetector(
                      onTap: _showImageSourceDialog,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: Colors.grey[200]!, width: 1.5),
                        ),
                        child: _receiptImage == null
                            ? Column(
                          children: [
                            Icon(Icons.cloud_upload_outlined, size: 32.sp, color: AppColor.primary),
                            SizedBox(height: 8.h),
                            Text(
                              'Tap to upload receipt',
                              style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                            ),
                            Text(
                              'JPG, PNG or PDF',
                              style: TextStyle(fontSize: 10.sp, color: Colors.grey[400]),
                            ),
                          ],
                        )
                            : Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.r),
                              child: Image.file(
                                _receiptImage!,
                                height: 80.h,
                                width: 80.w,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'Tap to change',
                              style: TextStyle(fontSize: 11.sp, color: AppColor.primary),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 24.h),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.primary,
                          padding: EdgeInsets.symmetric(vertical: 15.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          widget.existingTransaction != null ? 'Add Purchase' : 'Submit Transaction',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text, IconData icon, {bool optional = false, bool isMandatory = false}) {
    return Row(
      children: [
        Icon(icon, size: 13.sp, color: AppColor.primary),
        SizedBox(width: 5.w),
        Text(
          text,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: isMandatory ? Colors.red.shade700 : Colors.black87,
          ),
        ),
        if (optional) ...[
          SizedBox(width: 5.w),
          Text('(optional)', style: TextStyle(fontSize: 10.sp, color: Colors.grey[400])),
        ],
      ],
    );
  }
  Widget _fasfhasf(){
    return Container();
  }
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      inputFormatters: keyboardType == TextInputType.number
          ? [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))]
          : null,
      style: TextStyle(fontSize: 13.sp, color: Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 12.sp, color: Colors.grey[400]),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColor.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
      ),
    );
  }
}