import 'dart:math';
import 'package:cashback_farms/features/menu/screens/about_us.dart';
import 'package:cashback_farms/features/menu/controller/dashboard_menu_controller.dart';
import 'package:cashback_farms/features/menu/screens/terms_&_conditions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../common/colours.dart';
import '../../../common/images.dart';
import '../../../common/route/router.dart';
import '../../../common/widget/appbar.dart';
import '../../../common/widget/sessionhandler.dart';
import '../../../common/widget/toster.dart';
import '../../company_profile/screen/add_company_profile.dart';

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> with SingleTickerProviderStateMixin {
  String selectedRole = "User";
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
      setState(() {
        selectedRole =
            dashboardController.profile.value?.role?.role ?? "User";
      });
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
              SizedBox(height: 16.h),
              _buildWalletCard()
                  .animate()
                  .fade(duration: 430.ms, delay: 60.ms),
              SizedBox(height: 14.h),
              _buildCumulativeDashboardCard()
                  .animate()
                  .fade(duration: 430.ms, delay: 120.ms),
              SizedBox(height: 20.h),
              _buildRoleSection(),
              SizedBox(height: 24.h),
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

  // ─── HEADER ────────────────────────────────────────────────────────────────

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
            color: AppColor.primary.withOpacity(0.32),
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
              border: Border.all(
                  color: Colors.white.withOpacity(0.55), width: 2),
            ),
            child: CircleAvatar(
              radius: 32.r,
              backgroundColor: Colors.white24,
              backgroundImage:
              (profile?.avatar != null && profile!.avatar.isNotEmpty)
                  ? NetworkImage(profile.avatar)
                  : null,
              child:
              (profile?.avatar == null || profile!.avatar.isEmpty)
                  ? Icon(Icons.person_rounded,
                  size: 28.sp, color: Colors.white)
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
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 10.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    profile?.role?.role ?? "User",
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Icons.verified_user_rounded,
                color: Colors.white, size: 20.sp),
          ),
        ],
      ),
    );
  }

  // ─── WALLET CARD ────────────────────────────────────────────────────────────

  Widget _buildWalletCard() {
    final walletBalance = double.tryParse(dashboardController.profile.value?.walletBalance ?? "0") ?? 0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColor.primary.withOpacity(0.08),
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
              color: AppColor.primary.withOpacity(0.1),
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
            padding:
            EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppColor.primary.withOpacity(0.1),
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

  // ─── CUMULATIVE DASHBOARD CARD ──────────────────────────────────────────────

  Widget _buildCumulativeDashboardCard() {
    final settings = dashboardController.businessSettings.value;
    final cumulativeAmount = double.tryParse(
        dashboardController.profile.value?.cumulativeAmount ?? "0") ??
        0;

    // Use BusinessSettings helper methods — all dynamic from API
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
            color: AppColor.primary.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top: ring + stats
          Padding(
            padding: EdgeInsets.all(18.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _progressController,
                  builder: (context, _) {
                    final animated =
                        _progressController.value * progress;
                    return SizedBox(
                      width: 96.w,
                      height: 96.w,
                      child: CustomPaint(
                        painter: _SmoothRingPainter(
                          progress: animated,
                          activeColor: AppColor.primary,
                          trackColor:
                          AppColor.primarylite.withOpacity(0.4),
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
                                  fontSize: 10.sp,
                                  color: AppColor.grey,
                                ),
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
                            AppColor.primary.withOpacity(0.1),
                            AppColor.primary,
                          ),
                          SizedBox(width: 8.w),
                          _statChip(
                            "₹${totalEarned.toStringAsFixed(0)}",
                            "Earned",
                            AppColor.orange.withOpacity(0.12),
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

          // Progress bar
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
                          fontSize: 11.sp,
                          color: AppColor.textSecondary),
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
                        AppColor.primarylite.withOpacity(0.35),
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

          // Dynamic description from BusinessSettings.cumulativeDescription
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
              style: TextStyle(
                  fontSize: 9.sp, color: AppColor.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildCumulativeDescription(
      dynamic settings, double walletCredit, double milestone) {
    // Pull directly from BusinessSettings.cumulativeDescription (API field)
    final String rawDesc = settings?.cumulativeDescription ?? "";

    List<_DescItem> items;

    if (rawDesc.isNotEmpty) {
      items = _parseCumulativeDescription(rawDesc);
    } else {
      // Fallback with computed values from settings helpers
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

  /// Parses the cumulative_description string into structured items.
  /// Sections are separated by double newlines; each starts with a keyword label.
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
              color: item.color.withOpacity(0.1),
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

  // ─── ROLE SECTION ───────────────────────────────────────────────────────────

  Widget _buildRoleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRoleButtons(),
        SizedBox(height: 14.h),
        _buildRoleBasedContent(),
      ],
    );
  }

  Widget _buildRoleButtons() {
    final List<String> roles = ["User", "Agent", "Vendor"];
    return Container(
      height: 46.h,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: roles.map((role) {
          final bool active = selectedRole == role;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => selectedRole = role);
                dashboardController.fetchDataForRole(role);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeInOut,
                margin: EdgeInsets.symmetric(horizontal: 2.w),
                decoration: BoxDecoration(
                  color: active ? AppColor.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(11.r),
                ),
                alignment: Alignment.center,
                child: Text(
                  role,
                  style: TextStyle(
                    color: active ? AppColor.white : AppColor.grey,
                    fontWeight:
                    active ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRoleBasedContent() {
    if (selectedRole == "Agent" &&
        dashboardController.isLoadingAgentRequests.value) {
      return _buildLoadingShimmer();
    } else if (selectedRole == "Vendor" &&
        dashboardController.isLoadingVendorRequests.value) {
      return _buildLoadingShimmer();
    } else if (selectedRole == "User" &&
        dashboardController.isLoadingServiceRequests.value) {
      return _buildLoadingShimmer();
    }

    switch (selectedRole) {
      case "Agent":
        return _buildAgentContent();
      case "Vendor":
        return _buildVendorContent();
      default:
        return _buildUserContent();
    }
  }

  Widget _buildLoadingShimmer() {
    return Container(
      height: 130.h,
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
                color: AppColor.primary, strokeWidth: 2.5),
            SizedBox(height: 10.h),
            Text(
              "Loading $selectedRole data...",
              style: TextStyle(
                  fontSize: 13.sp, color: AppColor.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  // ─── USER CONTENT ───────────────────────────────────────────────────────────

  Widget _buildUserContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel("Overview"),
        SizedBox(height: 12.h),
        _buildDashboardGrid(),
      ],
    );
  }

  Widget _buildDashboardGrid() {
    final c = dashboardController;
    final List<Map<String, dynamic>> data = [
      {
        "title": "Plot Enquiries",
        "count": c.marketEnquiryCount.value,
        "percent": c.marketEnquiryCount.value > 0 ? 70 : 0,
        "color": AppColor.primary,
        "icon": Icons.landscape_rounded,
      },
      {
        "title": "Material Enquiries",
        "count": c.materialEnquiryCount.value,
        "percent": c.materialEnquiryCount.value > 0 ? 55 : 0,
        "color": AppColor.orange,
        "icon": Icons.inventory_2_rounded,
      },
      {
        "title": "Residential",
        "count": c.residentialEnquiry.value,
        "percent": c.residentialEnquiry.value > 0 ? 40 : 0,
        "color": AppColor.info,
        "icon": Icons.home_rounded,
      },
      {
        "title": "My Properties",
        "count": c.myProperties.value,
        "percent": c.myProperties.value > 0 ? 60 : 0,
        "color": AppColor.accent,
        "icon": Icons.villa_rounded,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: data.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 0.94,
      ),
      itemBuilder: (context, index) {
        final item = data[index];
        return _dashboardCard(
          title: item["title"],
          count: item["count"],
          percent: item["percent"],
          color: item["color"],
          icon: item["icon"],
        ).animate(delay: (index * 55).ms).fade().scale(
            begin: const Offset(0.93, 0.93));
      },
    );
  }

  Widget _dashboardCard({
    required String title,
    required int count,
    required int percent,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.13),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 68.w,
            height: 68.w,
            child: CustomPaint(
              painter: DashedRingPainter(
                percent: percent / 100,
                activeColor: color,
                inactiveColor: color.withOpacity(0.12),
                width: 6.w,
              ),
              child: Center(
                child: Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 19.sp),
                ),
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            "$count",
            style: TextStyle(
              fontSize: 23.sp,
              fontWeight: FontWeight.w800,
              color: AppColor.textMain,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.sp,
              color: AppColor.textSecondary,
              height: 1.3,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            "$percent%",
            style: TextStyle(
              fontSize: 10.sp,
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ─── AGENT CONTENT ──────────────────────────────────────────────────────────

  Widget _buildAgentContent() {
    final agentRequests = dashboardController.agentRequests;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel("Agent Requests"),
        SizedBox(height: 12.h),
        agentRequests.isEmpty
            ? _buildEmptyState(
            "No agent requests found",
            Icons.person_search_rounded)
            : ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount:
          agentRequests.length > 3 ? 3 : agentRequests.length,
          itemBuilder: (context, index) =>
              _buildRequestCard(agentRequests[index], "agent"),
        ),
        if (agentRequests.length > 3)
          _buildViewAllButton(
              "View All (${agentRequests.length})", "/agent-requests"),
      ],
    );
  }

  // ─── VENDOR CONTENT ─────────────────────────────────────────────────────────

  Widget _buildVendorContent() {
    final vendorRequests = dashboardController.vendorRequests;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel("Vendor Requests"),
        SizedBox(height: 12.h),
        vendorRequests.isEmpty
            ? _buildEmptyState(
            "No vendor requests found",
            Icons.store_mall_directory_rounded)
            : ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount:
          vendorRequests.length > 3 ? 3 : vendorRequests.length,
          itemBuilder: (context, index) =>
              _buildRequestCard(vendorRequests[index], "vendor"),
        ),
        if (vendorRequests.length > 3)
          _buildViewAllButton(
              "View All (${vendorRequests.length})", "/vendor-requests"),
      ],
    );
  }

  Widget _buildEmptyState(String text, IconData icon) {
    return Container(
      height: 110.h,
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28.sp, color: AppColor.lightGrey),
            SizedBox(height: 8.h),
            Text(text,
                style: TextStyle(
                    fontSize: 13.sp, color: AppColor.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildViewAllButton(String label, String route) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () => Get.toNamed(route),
        child: Text(
          label,
          style: TextStyle(
              color: AppColor.primary,
              fontSize: 13.sp,
              fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildRequestCard(dynamic request, String type) {
    final Color typeColor =
    type == "agent" ? AppColor.primary : AppColor.orange;
    final IconData typeIcon = type == "agent"
        ? Icons.person_outline_rounded
        : Icons.store_outlined;

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: typeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(typeIcon, color: typeColor, size: 20.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request['title'] ??
                      '${type.capitalizeFirst} Request',
                  style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColor.textMain),
                ),
                SizedBox(height: 3.h),
                Text(
                  'ID: ${request['id'] ?? 'N/A'}',
                  style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColor.textSecondary),
                ),
              ],
            ),
          ),
          Container(
            padding:
            EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: _getStatusColor(request['status'] ?? 'pending')
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              request['status'] ?? 'Pending',
              style: TextStyle(
                fontSize: 10.sp,
                color: _getStatusColor(request['status'] ?? 'pending'),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return AppColor.success;
      case 'rejected':
        return AppColor.error;
      case 'completed':
        return AppColor.primary;
      default:
        return AppColor.warning;
    }
  }

  // ─── HELPERS ────────────────────────────────────────────────────────────────

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

  // ─── MENU LIST ──────────────────────────────────────────────────────────────

  Widget _buildMenuList() {
    return Column(
      children: [
        _menuTile(Icons.wallet, "My Wallet", () => Get.toNamed("/walletScreen")),
        _menuTile(Icons.wallet, "Kyc", () => Get.toNamed("/kycScreen")),
        _menuTile(Icons.info_outline_rounded, "About Us", () => Get.to(() => const AboutUs())),
        _menuTile(Icons.business_center_rounded, "Company Profile", () => Get.to(() => const VendorStoreView())),
        _menuTile(Icons.gavel_rounded, "Terms and Conditions", () => Get.to(() => const TermsAndConditionsScreen())),
        _menuTile(Icons.headset_mic_rounded, "Contact Us", () => Get.toNamed("/contactus")),
        _menuTile(Icons.receipt_long_rounded, "Transaction Details", () => Get.toNamed("/transactionDeatils")),
        _menuTile(Icons.support_agent_rounded, "Support",
              () async {
            final uri = Uri.parse("https://cashback.vrikshatech.in/");
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri,
                  mode: LaunchMode.externalApplication);
            }
          },
        ),
        _menuTile(
          Icons.logout_rounded,
          "Logout",
              () => _showLogoutConfirmation(context),
          isLogout: true,
        ),
      ],
    );
  }

  Widget _menuTile(IconData icon, String title, VoidCallback onTap,
      {bool isLogout = false}) {
    final Color tileColor = isLogout ? AppColor.red : AppColor.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding:
        EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
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
                color: tileColor.withOpacity(0.1),
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
                  color:
                  isLogout ? AppColor.red : AppColor.textMain,
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

// ─── DESC ITEM MODEL ─────────────────────────────────────────────────────────

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

// ─── LOGOUT DIALOG ───────────────────────────────────────────────────────────

void _showLogoutConfirmation(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: AppColor.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(35)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColor.primary.withOpacity(0.1),
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
                      padding:
                      const EdgeInsets.symmetric(vertical: 12),
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
                      padding:
                      const EdgeInsets.symmetric(vertical: 12),
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

// ─── DASHED RING PAINTER (original, unchanged) ───────────────────────────────

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

// ─── SMOOTH RING PAINTER (cumulative progress) ────────────────────────────────

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