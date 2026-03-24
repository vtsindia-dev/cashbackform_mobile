import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../common/colours.dart';
import '../../../common/widget/appbar.dart';
import '../../../common/widget/toster.dart';
import '../controller/wallet_controller.dart';
import '../model/wallet_model.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final WalletController controller = Get.put(WalletController());
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100) {
      controller.loadMoreTransactions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundLight,
      appBar: DynamicAppBar(
        title: "My Wallet",
        showBackButton: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.transactions.isEmpty) {
          return _buildLoadingShimmer();
        }

        return RefreshIndicator(
          color: AppColor.primary,
          onRefresh: () => controller.refreshTransactions(),
          child: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              // --- Premium Animated Balance Card ---
              SliverToBoxAdapter(
                child: _buildBalanceCard()
                    .animate()
                    .fadeIn(duration: 500.ms)
                    .slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),
              ),

              // --- Recent Activity Header ---
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(24.w, 10.h, 24.w, 15.h),
                  child: Text(
                    "Recent Activity",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColor.textMain,
                    ),
                  ),
                ),
              ),

              // --- Transaction List ---
              _buildTransactionList(),

              if (controller.hasMore.value)
                SliverToBoxAdapter(child: _buildLoadingMoreIndicator()),

              const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      margin: EdgeInsets.all(20.w),
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32.r),
        gradient: const LinearGradient(
          colors: [AppColor.grey, AppColor.primary], // Your Green to Purple
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColor.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Available Balance",
                    style: TextStyle(
                      color: AppColor.white.withOpacity(0.7),
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    "₹${controller.walletBalance.value.toStringAsFixed(2)}",
                    style: TextStyle(
                      color: AppColor.white,
                      fontSize: 32.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              CircleAvatar(
                backgroundColor: AppColor.white.withOpacity(0.2),
                child: Icon(Icons.wallet, color: AppColor.white, size: 20.sp),
              ),
            ],
          ),
          SizedBox(height: 25.h),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColor.black.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: AppColor.white.withOpacity(0.1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem("Income", controller.transactions.fold(0.0, (s, i) => s + i.credit), AppColor.primarylite, Icons.arrow_downward),
                Container(width: 1, height: 25.h, color: AppColor.white.withOpacity(0.2)),
                _buildStatItem("Spent", controller.transactions.fold(0.0, (s, i) => s + i.debit), AppColor.orangeAccent, Icons.arrow_upward),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, double amount, Color color, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: color, size: 14.sp),
        SizedBox(width: 8.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: AppColor.white.withOpacity(0.6), fontSize: 10.sp)),
            Text("₹${amount.toStringAsFixed(0)}", style: TextStyle(color: AppColor.white, fontWeight: FontWeight.bold, fontSize: 14.sp)),
          ],
        ),
      ],
    );
  }

  Widget _buildTransactionList() {
    if (controller.transactions.isEmpty) {
      return SliverFillRemaining(
        child: Center(child: Text("No transactions yet", style: TextStyle(color: AppColor.grey))),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
              (context, index) {
            final tx = controller.transactions[index];
            final bool isCredit = tx.credit > 0;

            return Container(
              margin: EdgeInsets.only(bottom: 16.h),
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColor.white,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(color: AppColor.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(
                          color: (isCredit ? AppColor.green : AppColor.red).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(tx.transactionIcon, color: isCredit ? AppColor.green : AppColor.red, size: 20.sp),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(tx.formattedTransactionType, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp, color: AppColor.textMain)),
                            Text(_formatDate(tx.createdAt), style: TextStyle(color: AppColor.textSecondary, fontSize: 11.sp)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            tx.formattedAmount,
                            style: TextStyle(fontWeight: FontWeight.w900, color: isCredit ? AppColor.green : AppColor.red, fontSize: 16.sp),
                          ),
                          Text("Bal: ₹${tx.balance.toStringAsFixed(2)}", style: TextStyle(fontSize: 10.sp, color: AppColor.textSecondary)),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 24, thickness: 0.5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: tx.transactionId));
                          SnackBarHelper.showSuccess("ID Copied");
                        },
                        child: Row(
                          children: [
                            Text("ID: ${tx.transactionId.substring(0, 8)}...", style: TextStyle(fontSize: 10.sp, color: AppColor.grey)),
                            SizedBox(width: 4.w),
                            Icon(Icons.copy_rounded, size: 12.sp, color: AppColor.grey),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                        decoration: BoxDecoration(color: AppColor.lightGrey, borderRadius: BorderRadius.circular(6.r)),
                        child: Text(tx.transactionType, style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.bold, color: AppColor.textSecondary)),
                      ),
                    ],
                  ),
                ],
              ),
            )
                .animate(delay: (index * 50).ms)
                .fadeIn(duration: 400.ms)
                .slideX(begin: 0.1, end: 0);
          },
          childCount: controller.transactions.length,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (now.day == date.day && now.month == date.month) return "Today";
    return "${date.day}/${date.month}";
  }

  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: AppColor.lightGrey,
      highlightColor: AppColor.white,
      child: ListView.builder(itemCount: 5, itemBuilder: (_, __) => Container(height: 120.h, margin: EdgeInsets.all(20), decoration: BoxDecoration(color: AppColor.white, borderRadius: BorderRadius.circular(20)))),
    );
  }

  Widget _buildLoadingMoreIndicator() {
    return Center(child: Padding(padding: EdgeInsets.all(20.w), child: CircularProgressIndicator(color: AppColor.primary)));
  }
}