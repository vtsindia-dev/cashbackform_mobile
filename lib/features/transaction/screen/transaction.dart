import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4,
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
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: AppColor.primary,
        elevation: 0,
        centerTitle: true,
        // This ensures the back button and all action icons are white
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
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColor.primary,
              // Subtle curve at the bottom of the App Bar
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20.r),
                bottomRight: Radius.circular(20.r),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true, // Allows tabs to breathe
              tabAlignment: TabAlignment.start,
              indicatorColor: Colors.white,
              indicatorWeight: 3.5,
              indicatorSize: TabBarIndicatorSize.label,
              indicatorPadding: EdgeInsets.only(bottom: 8.h),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withOpacity(0.6),
              labelStyle: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
              unselectedLabelStyle: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500
              ),
              dividerColor: Colors.transparent, // Removes the ugly bottom line
              tabs: const [
                Tab(text: 'Gioo'),
                Tab(text: 'Syndicate'),
                Tab(text: 'Residential'),
                Tab(text: 'Market'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTransactionList(TransactionType.gioo),
          _buildTransactionList(TransactionType.syndicate),
          _buildTransactionList(TransactionType.residential),
          _buildTransactionList(TransactionType.market),
        ],
      ),
    );
  }

  Widget _buildTransactionList(TransactionType type) {
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
        return _buildEmptyState();
      }

      return Column(
        children: [
          SizedBox(height: 10.h),
          _buildMiniSummary(transactions.length, meta.total),
          Expanded(
            child: RefreshIndicator(
              color: AppColor.primary,
              onRefresh: () => _refreshTab(type),
              child: ListView.builder(
                padding: EdgeInsets.only(bottom: 20.h, top: 5.h),
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

  Widget _buildAnimatedCard(Transaction transaction, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 400 + (index.clamp(0, 6) * 80)),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutQuart,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(
            scale: 0.95 + (0.05 * value),
            child: child,
          ),
        );
      },
      child: _buildModernCard(transaction),
    );
  }

  Widget _buildMiniSummary(int showing, int total) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(color: AppColor.primary.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Icons.analytics_outlined, size: 14.sp, color: AppColor.primary),
          ),
          SizedBox(width: 8.w),
          Text(
            "Overview: showing $showing of $total records",
            style: TextStyle(color: Colors.grey[700], fontSize: 11.sp, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildModernCard(Transaction transaction) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22.r,
                    backgroundColor: AppColor.primary.withOpacity(0.1),
                    child: Icon(_getPaymentIcon(transaction.paymentType), color: AppColor.primary, size: 20.sp),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transaction.propertyType,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp, color: Colors.black87),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          _formatDate(transaction.createdAt),
                          style: TextStyle(fontSize: 11.sp, color: Colors.grey[500], fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    "₹${transaction.amount}",
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16.sp, color: AppColor.primary),
                  ),
                ],
              ),
            ),
            // Bottom Action Bar
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: AppColor.primary.withOpacity(0.03),
                border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.1))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.person_outline, size: 14.sp, color: Colors.grey[600]),
                      SizedBox(width: 4.w),
                      Text(transaction.userName.isNotEmpty ? transaction.userName : "User",
                          style: TextStyle(fontSize: 11.sp, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                    ],
                  ),
                  InkWell(
                    onTap: () => controller.downloadInvoice(transaction.invoiceUrl),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: AppColor.primary,
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.file_download_outlined, size: 14, color: Colors.white),
                          SizedBox(width: 4.w),
                          Text("Receipt", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11.sp)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // Logic Helpers (Same as previous to ensure functionality)
  List<Transaction> _getTransactionsByType(TransactionType t) {
    if (t == TransactionType.gioo) return controller.giooTransactions;
    if (t == TransactionType.syndicate) return controller.syndicateTransactions;
    if (t == TransactionType.residential) return controller.residentialTransactions;
    return controller.marketTransactions;
  }

  bool _getLoadingByType(TransactionType t) {
    if (t == TransactionType.gioo) return controller.isLoadingGioo.value;
    if (t == TransactionType.syndicate) return controller.isLoadingSyndicate.value;
    if (t == TransactionType.residential) return controller.isLoadingResidential.value;
    return controller.isLoadingMarket.value;
  }

  TransactionMeta _getMetaByType(TransactionType t) {
    if (t == TransactionType.gioo) return controller.giooMeta.value;
    if (t == TransactionType.syndicate) return controller.syndicateMeta.value;
    if (t == TransactionType.residential) return controller.residentialMeta.value;
    return controller.marketMeta.value;
  }

  String _getErrorByType(TransactionType t) {
    if (t == TransactionType.gioo) return controller.giooErrorMessage;
    if (t == TransactionType.syndicate) return controller.syndicateErrorMessage;
    if (t == TransactionType.residential) return controller.residentialErrorMessage;
    return controller.marketErrorMessage;
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off_rounded, size: 60.sp, color: Colors.grey[300]),
          SizedBox(height: 12.h),
          Text("No transactions found", style: TextStyle(fontSize: 15.sp, color: Colors.grey[500], fontWeight: FontWeight.w600)),
        ],
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
            TextButton(onPressed: () => _refreshTab(type), child: const Text("Try Again")),
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
        child: ElevatedButton(
          onPressed: () => _loadMore(type),
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColor.primary,
              elevation: 0,
              side: BorderSide(color: AppColor.primary.withOpacity(0.5)),
              shape: StadiumBorder()
          ),
          child: Text("Load More", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp)),
        ),
      ),
    );
  }

  IconData _getPaymentIcon(String type) {
    final t = type.toLowerCase();
    if (t.contains('cash')) return Icons.account_balance_wallet_rounded;
    if (t.contains('bank')) return Icons.account_balance_rounded;
    return Icons.payment_rounded;
  }

  String _formatDate(String date) {
    try {
      return DateFormat('dd MMM yyyy • hh:mm a').format(DateTime.parse(date));
    } catch (e) {
      return date;
    }
  }

  Future<void> _refreshTab(TransactionType type) async {
    if (type == TransactionType.gioo) await controller.fetchGiooTransactions();
    if (type == TransactionType.syndicate) await controller.fetchSyndicateTransactions();
    if (type == TransactionType.residential) await controller.fetchResidentialTransactions();
    if (type == TransactionType.market) await controller.fetchMarketTransactions();
  }

  void _loadMore(TransactionType type) => controller.loadMoreTransactions(type);
}