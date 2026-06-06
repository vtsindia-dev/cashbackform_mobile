import 'dart:math';
import 'package:cashback_farms/features/bank_details/screen/bank_details_form.dart';
import 'package:cashback_farms/features/material_store/screens/add_materials_screen.dart';
import 'package:cashback_farms/features/service/screen/add_service_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import '../../../common/colours.dart';
import '../../../common/images.dart';
import '../../../common/route/router.dart';
import '../../../common/widget/appbar.dart';
import '../../../common/widget/sessionhandler.dart';
import '../../../common/widget/toster.dart';
import '../../bank_details/screen/bank_details_list_screen.dart';
import '../../gift_coupon_and_encashment/screen/encashment_screen.dart';
import '../../gift_coupon_and_encashment/screen/gift_screen.dart';
import '../../menu/screens/about_us.dart';
import '../../menu/controller/dashboard_menu_controller.dart';
import '../../menu/screens/terms_&_conditions.dart';
import '../../company_profile/screen/add_company_profile.dart';
import '../../service/screen/my_received_enquiries_screen.dart';

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> with SingleTickerProviderStateMixin {
  late DashboardController dashboardController;
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    dashboardController = Get.put(DashboardController());
    dashboardController.refreshDashboard();

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _progressController.forward();
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundLight,
      appBar: DynamicAppBar(title: "Dashboard"),
      body: Obx(() {
        if (dashboardController.isLoading.value) {
          return const Center(
              child: CircularProgressIndicator(color: AppColor.primary));
        }

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader()
                  .animate()
                  .fade(duration: 400.ms)
                  .slideY(begin: -0.15),
              SizedBox(height: 14.h),
              _buildRoleChips()
                  .animate()
                  .fade(duration: 420.ms, delay: 20.ms),
              if (_shouldShowReferralCard())
               ...[
                 SizedBox(height: 12.h),
                 _buildReferralCodeCard()
                     .animate()
                     .fade(duration: 430.ms, delay: 30.ms),
               ],
              SizedBox(height: 12.h),
              _buildWalletCard()
                  .animate()
                  .fade(duration: 430.ms, delay: 60.ms),
              SizedBox(height: 14.h),
              _buildCumulativeDashboardCard()
                  .animate()
                  .fade(duration: 430.ms, delay: 120.ms),
              SizedBox(height: 20.h),
              _buildSectionLabel("Menu"),
              SizedBox(height: 10.h),
              _buildMenuList()
                  .animate()
                  .fade(duration: 400.ms, delay: 300.ms),
              SizedBox(height: 30.h),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildRoleChips() {
    final profile = dashboardController.profile.value;
    if (profile == null) return const SizedBox.shrink();

    final bool isAgent   = profile.isAgent    == 1;
    final bool isVendor  = profile.isVendor   == 1;
    final bool isService = profile.isServices == 1;

    final int agentRequest   = profile.agentRequest   ?? 0;
    final int vendorRequest  = profile.vendorRequest  ?? 0;
    final int serviceRequest = profile.serviceRequest ?? 0;

    _RoleChipData resolveChip({
      required bool isApproved,
      required int requestStatus,
      required String roleName,
      required String icon,
      required RoleType roleType,
    }) {
      if (isApproved) {
        return _RoleChipData(
          label: "You're a\n$roleName",
          icon: icon,
          color: const Color(0xFF16A34A),
          status: RoleStatus.approved,
          roleType: roleType,
          isTappable: false,
        );
      } else if (requestStatus == 1) {
        return _RoleChipData(
          label: "$roleName Request\nPending",
          icon: icon,
          color: const Color(0xFFD97706),
          status: RoleStatus.pending,
          roleType: roleType,
          isTappable: false,
        );
      } else if (requestStatus == 2) {
        return _RoleChipData(
          // label: "RE-APPLY AS\n$roleName",
          label: "Join as\n$roleName",
          icon: icon,
          color: const Color(0xFFDC2626),
          status: RoleStatus.rejected,
          roleType: roleType,
          isTappable: true,
        );
      } else {
        return _RoleChipData(
          label: "Join as\n$roleName",
          icon: icon,
          color: AppColor.primary,
          status: RoleStatus.joinNow,
          roleType: roleType,
          isTappable: true,
        );
      }
    }

    final List<_RoleChipData> chips = [
      resolveChip(
        isApproved:    isAgent,
        requestStatus: agentRequest,
        roleName:      "Agent",
        icon:          "assets/images/join_agent.png",
        roleType:      RoleType.agent,
      ),
      resolveChip(
        isApproved:    isVendor,
        requestStatus: vendorRequest,
        roleName:      "Builder/Promoters",
        icon:          "assets/images/join_vendor.png",
        roleType:      RoleType.vendor,
      ),
      resolveChip(
        isApproved:    isService,
        requestStatus: serviceRequest,
        roleName:      "Material/Service Provider",
        icon:          "assets/images/service_provider.png",
        roleType:      RoleType.service,
      ),
    ];

    return Row(
      children: chips
          .map((chip) => Expanded(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: _buildRoleCard(chip),
        ),
      ))
          .toList(),
    );
  }

  Widget _buildRoleCard(_RoleChipData chip) {
    return Obx(() {
      final isLoading = dashboardController.roleLoadingMap[chip.roleType] == true;

      return GestureDetector(
        onTap: chip.isTappable && !isLoading
            ? () => _handleRoleRequest(chip)
            : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 80.h,
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: chip.color.withValues(alpha: chip.isTappable ? 0.35 : 0.18),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              isLoading
                  ? Padding(
                padding: EdgeInsets.all(8.w),
                child: CircularProgressIndicator(
                  strokeWidth: 1.8,
                  color: chip.color,
                ),
              )
                  : Image.asset(chip.icon,height: 22,),

              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chip.label,
                      style: TextStyle(
                        fontSize: 9.sp,
                        color: chip.color,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                        height: 1.4,
                      ),
                    ),
                    if (chip.isTappable) ...[
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Text(
                            "Tap to apply",
                            style: TextStyle(
                              fontSize:6.sp,
                              color: chip.color.withValues(alpha: 0.7),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 7.sp,
                            color: chip.color.withValues(alpha: 0.7),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  void _handleRoleRequest(_RoleChipData chip) {
    final title = chip.status == RoleStatus.rejected
        ? "Re-apply as ${chip.roleType.name.toUpperCase()}"
        : "Join as ${chip.roleType.name.toUpperCase()}";

    final message = chip.status == RoleStatus.rejected
        ? "Your previous request was rejected. Would you like to re-apply?"
        : "Would you like to send a request to join as ${chip.roleType.name}?";

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text(
          title,
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700),
        ),
        content: Text(
          message,
          style: TextStyle(fontSize: 11.sp, color: AppColor.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              "Cancel",
              style: TextStyle(color: AppColor.textSecondary, fontSize: 12.sp),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: chip.color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            ),
            onPressed: () {
              Get.back();
              _submitRoleRequest(chip);
            },
            child: Text(
              chip.status == RoleStatus.rejected ? "Re-Apply" : "Apply",
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _submitRoleRequest(_RoleChipData chip) {
    switch (chip.roleType) {
      case RoleType.agent:
        dashboardController.applyForRole(RoleType.agent);
        break;
      case RoleType.vendor:
        dashboardController.applyForRole(RoleType.vendor);
        break;
      case RoleType.service:
        dashboardController.applyForRole(RoleType.service);
        break;
    }
  }


  Widget _buildReferralCodeCard() {
    final profile = dashboardController.profile.value;
    if (profile == null) return const SizedBox.shrink();


    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColor.primary.withValues(alpha:0.13),
            AppColor.primarylite.withValues(alpha:0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColor.primary.withValues(alpha:0.25), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColor.primary.withValues(alpha:0.07),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColor.primary.withValues(alpha:0.15),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Icons.card_giftcard_rounded,
                    color: AppColor.primary, size: 18.sp),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  'Your Referral Code',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColor.textMain,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                  color: AppColor.primary.withValues(alpha:0.18), width: 1),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 4.w,
                        children: (profile.code ?? '')
                            .split('')
                            .map((char) {
                          return Container(
                            width: 24.w,
                            height: 30.h,
                            decoration: BoxDecoration(
                              color: AppColor.primary.withValues(alpha: 0.07),
                              borderRadius: BorderRadius.circular(6.r),
                              border: Border.all(
                                color: AppColor.primary.withValues(alpha: 0.22),
                                width: 1,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              char,
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w800,
                                color: AppColor.primary,
                              ),
                            ),
                          );
                        }).toList(),
                      ),                    ],
                  ),
                ),
                SizedBox(width: 10.w),
                Column(
                  children: [
                    _buildCopyButton(profile.code ?? ''),
                    SizedBox(height: 6.h),
                    _buildShareButton(profile.code ?? ''),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _shouldShowReferralCard() {
    final profile = dashboardController.profile.value;

    if (profile == null) return false;

    final bool isAgent = profile.isAgent == 1;
    final bool isVendor = profile.isVendor == 1;
    final bool isService = profile.isServices == 1;

    if (!isAgent && !isVendor && !isService) {
      return false;
    }

    if (isService && !isAgent && !isVendor) {
      return false;
    }

    return true;
  }
  Widget _buildCopyButton(String code) {
    return GestureDetector(
      onTap: () {
        Clipboard.setData(ClipboardData(text: code));
        SnackBarHelper.showSuccess(
          "Referral code copied!",
          duration: const Duration(seconds: 2),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: AppColor.primary.withValues(alpha:0.1),
          borderRadius: BorderRadius.circular(10.r),
          border:
          Border.all(color: AppColor.primary.withValues(alpha:0.2), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.copy_rounded, size: 13.sp, color: AppColor.primary),
            SizedBox(width: 4.w),
            Text(
              "Copy",
              style: TextStyle(
                  fontSize: 11.sp,
                  color: AppColor.primary,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareButton(String code) {
    return GestureDetector(
      onTap: () async {
        try {
          final profile = dashboardController.profile.value;
          final role = profile?.role?.role ?? "User";
          await Share.share(_getShareMessage(code, role));
        } catch (_) {}
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: AppColor.primary,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.share_rounded, size: 13.sp, color: Colors.white),
            SizedBox(width: 4.w),
            Text(
              "Share",
              style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  String _getShareMessage(String code, String role) {
    return "Join me on Cashback Farms! Use my referral code: $code to get started as a $role and earn exciting rewards! 🚀\n\nDownload the app now!";
  }

  Widget _buildHeader() {
    final profile = dashboardController.profile.value;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6B8B3E),
            AppColor.primary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: AppColor.primary.withValues(alpha:0.32),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border:
              Border.all(color: Colors.white.withValues(alpha:0.55), width: 2),
            ),
            child: CircleAvatar(
              radius: 32.r,
              backgroundColor: Colors.white24,
              backgroundImage: (profile?.avatar?.isNotEmpty ?? false)
                  ? NetworkImage(profile!.avatar!)
                  : null,
              child: !(profile?.avatar?.isNotEmpty ?? false)
                  ? Icon(
                Icons.person_rounded,
                size: 28.sp,
                color: Colors.white,
              )
                  : null,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile?.name ?? "USER",
                  style: TextStyle(
                    fontSize: 19.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 6.h),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha:0.15),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Icons.verified_user_rounded,
                color: Colors.white, size: 20.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletCard() {
    final walletBalance = double.tryParse(
        dashboardController.profile.value?.walletBalance ?? "0") ??
        0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColor.primary.withValues(alpha:0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54.w,
            height: 54.w,
            decoration: BoxDecoration(
              color: AppColor.primary.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Icon(Icons.account_balance_wallet_rounded,
                color: AppColor.primary, size: 26.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Wallet Balance",
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColor.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  "₹${walletBalance.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColor.textMain,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppColor.primary.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              "Available",
              style: TextStyle(
                fontSize: 11.sp,
                color: AppColor.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCumulativeDashboardCard() {
    final settings = dashboardController.businessSettings.value;
    final cumulativeAmount = double.tryParse(
        dashboardController.profile.value?.cumulativeAmount ?? "0") ??
        0;

    final double milestone = settings?.cumulativeMaxCostValue ?? 5000.0;
    final double walletCredit = settings?.walletCreditAmount ?? 500.0;
    final double progressRaw =
    milestone > 0 ? (cumulativeAmount % milestone) / milestone : 0;
    final double progress =
    cumulativeAmount == 0 ? 0 : progressRaw.clamp(0.0, 1.0);
    final int completedMilestones =
    milestone > 0 ? (cumulativeAmount / milestone).floor() : 0;
    final double totalEarned =
        settings?.calculateTotalWalletCredit(cumulativeAmount) ??
            (completedMilestones * 500.0);
    final double remaining =
        settings?.calculateRemainingForReward(cumulativeAmount) ??
            (milestone - (cumulativeAmount % milestone));
    final double nextMilestone =
        settings?.calculateNextRewardMilestone(cumulativeAmount) ??
            ((completedMilestones + 1) * milestone);

    return Container(
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: AppColor.primary.withValues(alpha:0.08),
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(18.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _progressController,
                  builder: (context, _) {
                    final animated = _progressController.value * progress;
                    return SizedBox(
                      width: 96.w,
                      height: 96.w,
                      child: CustomPaint(
                        painter: _SmoothRingPainter(
                          progress: animated,
                          activeColor: AppColor.primary,
                          trackColor: AppColor.primarylite.withValues(alpha:0.4),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "${(progress * 100).toStringAsFixed(0)}%",
                                style: TextStyle(
                                  fontSize: 19.sp,
                                  fontWeight: FontWeight.w800,
                                  color: AppColor.primary,
                                ),
                              ),
                              Text(
                                "done",
                                style: TextStyle(
                                    fontSize: 10.sp, color: AppColor.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(width: 18.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Gioo Nano Plots",
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColor.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        "₹${cumulativeAmount.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColor.textMain,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Row(
                        children: [
                          _statChip(
                            "$completedMilestones",
                            "Milestones",
                            AppColor.primary.withValues(alpha:0.1),
                            AppColor.primary,
                          ),
                          SizedBox(width: 8.w),
                          _statChip(
                            "₹${totalEarned.toStringAsFixed(0)}",
                            "Earned",
                            AppColor.orange.withValues(alpha:0.12),
                            AppColor.orange,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Next: ₹${nextMilestone.toStringAsFixed(0)}",
                      style: TextStyle(
                          fontSize: 11.sp, color: AppColor.textSecondary),
                    ),
                    Text(
                      "₹${remaining.toStringAsFixed(0)} left",
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColor.orange,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 7.h),
                AnimatedBuilder(
                  animation: _progressController,
                  builder: (context, _) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(10.r),
                      child: LinearProgressIndicator(
                        value: _progressController.value * progress,
                        minHeight: 11.h,
                        backgroundColor:
                        AppColor.primarylite.withValues(alpha:0.35),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColor.primary),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          Divider(height: 1, color: AppColor.lightGrey),
          _buildCumulativeDescription(settings, walletCredit, milestone),
        ],
      ),
    );
  }

  Widget _statChip(
      String value, String label, Color bgColor, Color textColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: textColor)),
          Text(label,
              style:
              TextStyle(fontSize: 9.sp, color: AppColor.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildCumulativeDescription(
      dynamic settings, double walletCredit, double milestone) {
    final String rawDesc = settings?.cumulativeDescription ?? "";
    List<_DescItem> items;

    if (rawDesc.isNotEmpty) {
      items = _parseCumulativeDescription(rawDesc);
    } else {
      items = [
        _DescItem(
          icon: Icons.block_rounded,
          color: AppColor.red,
          title: "Exclusion",
          body:
          "The reward will not be applicable if the Gioo Nano plots is ₹${milestone.toStringAsFixed(0)} or more.",
        ),
        _DescItem(
          icon: Icons.account_balance_wallet_rounded,
          color: AppColor.primary,
          title: "Wallet Credit",
          body:
          "Each time your total Gioo Nano plots reaches ₹${milestone.toStringAsFixed(0)}, you will receive ₹${walletCredit.toStringAsFixed(0)} credited to your wallet.",
        ),
        _DescItem(
          icon: Icons.stars_rounded,
          color: AppColor.orange,
          title: "Reward Eligibility",
          body:
          "The reward is applicable only if the Gioo Nano plots is less than ₹${milestone.toStringAsFixed(0)}.",
        ),
      ];
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(18.w, 14.h, 18.w, 18.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4.w,
                height: 17.h,
                decoration: BoxDecoration(
                  color: AppColor.primary,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                "Reward Program Details",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColor.textMain,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          ...items.map((item) => _buildDescRow(item)),
        ],
      ),
    );
  }

  List<_DescItem> _parseCumulativeDescription(String raw) {
    final Map<String, Map<String, dynamic>> keywordMap = {
      "Exclusion": {
        "icon": Icons.block_rounded,
        "color": AppColor.red,
      },
      "Wallet Credit": {
        "icon": Icons.account_balance_wallet_rounded,
        "color": AppColor.primary,
      },
      "Reward Eligibility": {
        "icon": Icons.stars_rounded,
        "color": AppColor.orange,
      },
    };

    final sections = raw.split(RegExp(r'\r?\n\r?\n'));
    final List<_DescItem> items = [];

    for (final section in sections) {
      final trimmed = section.trim();
      if (trimmed.isEmpty) continue;

      String matchedKey = "";
      String body = trimmed;

      for (final key in keywordMap.keys) {
        if (trimmed.startsWith(key)) {
          matchedKey = key;
          body = trimmed
              .substring(key.length)
              .replaceFirst(RegExp(r'^:\s*'), '')
              .trim();
          break;
        }
      }

      if (matchedKey.isNotEmpty) {
        items.add(_DescItem(
          icon: keywordMap[matchedKey]!["icon"] as IconData,
          color: keywordMap[matchedKey]!["color"] as Color,
          title: matchedKey,
          body: body,
        ));
      } else {
        items.add(_DescItem(
          icon: Icons.info_outline_rounded,
          color: AppColor.info,
          title: "Note",
          body: trimmed,
        ));
      }
    }

    return items.isNotEmpty
        ? items
        : [
      _DescItem(
        icon: Icons.info_outline_rounded,
        color: AppColor.primary,
        title: "Program Info",
        body: raw,
      )
    ];
  }

  Widget _buildDescRow(_DescItem item) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: item.color.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(item.icon, color: item.color, size: 16.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColor.textMain,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  item.body,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColor.textSecondary,
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildSectionLabel(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 17.sp,
        fontWeight: FontWeight.w800,
        color: AppColor.textMain,
        letterSpacing: 0.2,
      ),
    );
  }
  bool isCompanyExpanded = false;


  Widget _buildMenuList() {
    return Column(
      children: [
        _menuTile(Icons.wallet, "My Wallet",
                () => Get.toNamed("/walletScreen")),
        _menuTile(
            Icons.verified_user, "KYC", () => Get.toNamed("/kycScreen")),
        _menuTile(
            Icons.account_balance, "Bank Details", () => Get.to(()=> BankDetailsListScreen())),
        _menuTile(Icons.notification_add_outlined, "Notification",
                () => Get.toNamed("/NotificationsPage")),
        _menuTile(Icons.card_giftcard, "Gift/Payment Coupon",
                () => Get.to(() => const GiftScreen())),
        _menuTile(Icons.currency_exchange, "Encashment",
                () => Get.to(() => const EnCashMentScreen())),
        _buildCompanyDropdown(),
        _menuTile(Icons.info_outline_rounded, "About Us",
                () => Get.to(() => const AboutUs())),
        _menuTile(Icons.gavel_rounded, "Terms and Conditions",
                () => Get.to(() => const TermsAndConditionsScreen())),
        _menuTile(Icons.headset_mic_rounded, "Contact Us",
                () => Get.toNamed("/contactus")),
        _menuTile(Icons.receipt_long, "Transaction Details",
                () => Get.toNamed("/transactionDeatils")),
        _menuTile(
          Icons.logout_rounded,
          "Logout",
              () => _showLogoutConfirmation(context),
          isLogout: true,
        ),
      ],
    );
  }

  Widget _buildCompanyDropdown() {
    final profile = dashboardController.profile.value;

    final bool isAgent = profile?.isAgent == 1;
    final bool isVendor = profile?.isVendor == 1;
    final bool isService = profile?.isServices == 1;

    final bool isNormalUser = !isAgent && !isVendor && !isService;

    final bool shouldHideCompanySection =
        (isAgent && !isVendor && !isService) ||
            isNormalUser;

    final bool showCompanyProfile = isVendor || isService;

    if (shouldHideCompanySection) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                isCompanyExpanded = !isCompanyExpanded;
              });
            },
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: 14.h,
                horizontal: 16.w,
              ),
              child: Row(
                children: [
                  Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      color: AppColor.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.business_center_rounded,
                      color: AppColor.primary,
                      size: 18.sp,
                    ),
                  ),
                  SizedBox(width: 14.w),

                  Expanded(
                    child: Text(
                      "Company Profile",
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: AppColor.textMain,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  AnimatedRotation(
                    turns: isCompanyExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 22.sp,
                      color: AppColor.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (isCompanyExpanded)
            Padding(
              padding: EdgeInsets.only(
                left: 20.w,
                right: 10.w,
                bottom: 10.h,
              ),
              child: Column(
                children: [
                  /// Vendor OR Service
                  if (showCompanyProfile)
                    _subMenuTile(
                      Icons.apartment_rounded,
                      "My Company Profile",
                          () => Get.to(() => const VendorStoreView()),
                      "assets/images/company-vision.png",
                    ),

                  /// Service only
                  if (isService)
                    _subMenuTile(
                      Icons.miscellaneous_services_rounded,
                      "My Service",
                          () => Get.to(() => const AddServiceScreen()),
                      "assets/images/support1.png",
                    ),

                  /// Vendor only
                  if (isVendor)
                    _subMenuTile(
                      Icons.settings_input_component_rounded,
                      "My Material",
                          () => Get.to(() => const AddMaterialsScreen()),
                      "assets/images/technical-support.png",
                    ),

                  /// Enquiries received on my services/materials
                  if (isService)
                    _subMenuTile(
                      Icons.inbox_rounded,
                      "My Service Enquiries",
                      () => Get.to(() => const MyReceivedEnquiriesScreen(
                            showServiceTab: true,
                            showMaterialTab: false,
                          )),
                      "assets/images/support1.png",
                    ),

                  if (isVendor)
                    _subMenuTile(
                      Icons.inbox_rounded,
                      "My Material Enquiries",
                      () => Get.to(() => const MyReceivedEnquiriesScreen(
                            showServiceTab: false,
                            showMaterialTab: true,
                          )),
                      "assets/images/technical-support.png",
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _subMenuTile(
      IconData icon,
      String title,
      VoidCallback onTap,
      String image,
      ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        child: Row(
          children: [
            Image.asset(image,height: 20.h,),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColor.textMain,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuTile(IconData icon, String title, VoidCallback onTap,
      {bool isLogout = false}) {
    final Color tileColor = isLogout ? AppColor.red : AppColor.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha:0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: tileColor.withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: tileColor, size: 18.sp),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15.sp,
                  color: isLogout ? AppColor.red : AppColor.textMain,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 14.sp, color: AppColor.grey),
          ],
        ),
      ),
    );
  }
}



enum RoleStatus { joinNow, pending, approved, rejected }
enum RoleType   { agent, vendor, service }

class _RoleChipData {
  final String    label;
  final String  icon;
  final Color     color;
  final RoleStatus status;
  final RoleType  roleType;
  final bool      isTappable;

  _RoleChipData({
    required this.label,
    required this.icon,
    required this.color,
    required this.status,
    required this.roleType,
    required this.isTappable,
  });
}

class _DescItem {
  final IconData icon;
  final Color color;
  final String title;
  final String body;
  const _DescItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
  });
}


void _showLogoutConfirmation(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: AppColor.white,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColor.primary.withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Image.asset(Images.logout, fit: BoxFit.contain),
            ),
            const SizedBox(height: 20),
            Text(
              'Logout',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColor.primary),
            ),
            const SizedBox(height: 10),
            const Text(
              'Are you sure you want to logout?',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 16,
                  color: AppColor.black,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 25),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      side: const BorderSide(color: AppColor.grey),
                    ),
                    child: const Text('Cancel',
                        style: TextStyle(
                            color: AppColor.black,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      await _performLogout();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Logout',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

Future<void> _performLogout() async {
  try {
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );
    await SessionManager.clearSession();
    Get.offAllNamed(AppRoutes.login);
    SnackBarHelper.showSuccess("You have been successfully logged out");
  } catch (e) {
    Get.back();
    SnackBarHelper.showError("Failed to logout: $e");
  }
}


class DashedRingPainter extends CustomPainter {
  final double percent;
  final Color activeColor;
  final Color inactiveColor;
  final double width;

  const DashedRingPainter({
    required this.percent,
    required this.activeColor,
    required this.inactiveColor,
    required this.width,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - width) / 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;

    const int dashCount = 40;
    const double startAngle = -pi / 2;
    const double sweepAngle = 2 * pi;
    final double dashAngle = sweepAngle / dashCount;
    const double gapRatio = 0.25;
    final double segmentAngle = dashAngle * (1 - gapRatio);
    final int activeDashes = (dashCount * percent).round();

    for (int i = 0; i < dashCount; i++) {
      paint.color = i < activeDashes ? activeColor : inactiveColor;
      final double angle = startAngle + i * dashAngle;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        angle,
        segmentAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}


class _SmoothRingPainter extends CustomPainter {
  final double progress;
  final Color activeColor;
  final Color trackColor;

  const _SmoothRingPainter({
    required this.progress,
    required this.activeColor,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 11) / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 11
      ..strokeCap = StrokeCap.round;

    final activePaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 11
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        2 * pi * progress,
        false,
        activePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SmoothRingPainter old) =>
      old.progress != progress;
}


extension StringExtension on String {
  String get capitalizeFirst {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}