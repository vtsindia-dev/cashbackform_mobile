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

class _MenuState extends State<Menu> {
  String selectedRole = "User";
  late DashboardController dashboardController;

  @override
  void initState() {
    super.initState();
    dashboardController = Get.put(DashboardController());
    dashboardController.refreshDashboard();

    // Set selected role after profile is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        selectedRole = dashboardController.profile.value?.role?.role ?? "User";
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DynamicAppBar(
        title: "Dashboard",
      ),
      backgroundColor: AppColor.backgroundLight,
      body: Obx(() {
        if (dashboardController.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColor.primary));
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              _buildHeader().animate().fade().slideY(begin: -0.2),
              SizedBox(height: 20.h),

              // Role-based buttons (uncommented)
              _buildRoleButtons(),
              SizedBox(height: 25.h),

              // Role-specific content based on selected role
              _buildRoleBasedContent(),
              SizedBox(height: 30.h),

              _buildMenuTitle(),
              SizedBox(height: 12.h),

              _buildMenuList(),
              SizedBox(height: 30.h),
            ],
          ),
        );
      }),
    );
  }

  // HEADER
  Widget _buildHeader() {
    final profile = dashboardController.profile.value;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColor.primarylite,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35.r,
            backgroundColor: AppColor.lightGrey,
            backgroundImage: profile?.avatar != null
                ? NetworkImage(profile!.avatar)
                : null,
            child: profile?.avatar == null
                ? const Icon(Icons.person, size: 30)
                : null,
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile?.name ?? "USER",
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  "Role: ${profile?.role?.role ?? "User"}",
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColor.textSecondary,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // ROLE BUTTONS - Now functional
  Widget _buildRoleButtons() {
    List<String> roles = ["User", "Agent", "Vendor"];

    return SizedBox(
      height: 45.h,
      child: Row(
        children: roles.map((role) {
          bool active = selectedRole == role;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedRole = role;
                });
                // Fetch role-specific data
                dashboardController.fetchDataForRole(role);
              },
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                decoration: BoxDecoration(
                  color: active ? AppColor.primary : AppColor.lightGrey,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                alignment: Alignment.center,
                child: Text(
                  role,
                  style: TextStyle(
                    color: active ? AppColor.white : AppColor.textMain,
                    fontWeight: FontWeight.w600,
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

  // Role-based content
  Widget _buildRoleBasedContent() {
    // Show loading indicators for role-specific data
    if (selectedRole == "Agent" && dashboardController.isLoadingAgentRequests.value) {
      return _buildLoadingShimmer();
    } else if (selectedRole == "Vendor" && dashboardController.isLoadingVendorRequests.value) {
      return _buildLoadingShimmer();
    } else if (selectedRole == "User" && dashboardController.isLoadingServiceRequests.value) {
      return _buildLoadingShimmer();
    }

    // Show role-specific content
    switch(selectedRole) {
      case "Agent":
        return _buildAgentContent();
      case "Vendor":
        return _buildVendorContent();
      default:
        return _buildUserContent();
    }
  }

  // Loading shimmer
  Widget _buildLoadingShimmer() {
    return Container(
      height: 200.h,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColor.primary),
            SizedBox(height: 16.h),
            Text(
              "Loading ${selectedRole} data...",
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColor.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // User content (existing dashboard)
  Widget _buildUserContent() {
    return Column(
      children: [
        _buildDashboardTitle(),
        SizedBox(height: 12.h),
        _buildDashboardGrid(),
      ],
    );
  }

  // Agent content
  Widget _buildAgentContent() {
    final agentRequests = dashboardController.agentRequests;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Agent Requests",
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppColor.textMain,
          ),
        ),
        SizedBox(height: 12.h),

        if (agentRequests.isEmpty)
          Container(
            height: 150.h,
            decoration: BoxDecoration(
              color: AppColor.white,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Center(
              child: Text(
                "No agent requests found",
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColor.textSecondary,
                ),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: agentRequests.length > 3 ? 3 : agentRequests.length,
            itemBuilder: (context, index) {
              final request = agentRequests[index];
              return _buildRequestCard(request, "agent");
            },
          ),

        if (agentRequests.length > 3)
          TextButton(
            onPressed: () {
              // Navigate to full agent requests page
              Get.toNamed("/agent-requests");
            },
            child: Text(
              "View All (${agentRequests.length})",
              style: TextStyle(
                color: AppColor.primary,
                fontSize: 14.sp,
              ),
            ),
          ),
      ],
    );
  }

  // Vendor content
  Widget _buildVendorContent() {
    final vendorRequests = dashboardController.vendorRequests;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Vendor Requests",
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppColor.textMain,
          ),
        ),
        SizedBox(height: 12.h),

        if (vendorRequests.isEmpty)
          Container(
            height: 150.h,
            decoration: BoxDecoration(
              color: AppColor.white,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Center(
              child: Text(
                "No vendor requests found",
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColor.textSecondary,
                ),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: vendorRequests.length > 3 ? 3 : vendorRequests.length,
            itemBuilder: (context, index) {
              final request = vendorRequests[index];
              return _buildRequestCard(request, "vendor");
            },
          ),

        if (vendorRequests.length > 3)
          TextButton(
            onPressed: () {
              // Navigate to full vendor requests page
              Get.toNamed("/vendor-requests");
            },
            child: Text(
              "View All (${vendorRequests.length})",
              style: TextStyle(
                color: AppColor.primary,
                fontSize: 14.sp,
              ),
            ),
          ),
      ],
    );
  }

  // Request card for agent/vendor
  Widget _buildRequestCard(dynamic request, String type) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColor.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: type == "agent"
                  ? AppColor.secondary.withOpacity(0.1)
                  : AppColor.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              type == "agent" ? Icons.person_outline : Icons.store_outlined,
              color: type == "agent" ? AppColor.secondary : AppColor.orange,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request['title'] ?? '${type.capitalizeFirst} Request',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'ID: ${request['id'] ?? 'N/A'}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColor.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: _getStatusColor(request['status'] ?? 'pending').withOpacity(0.1),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              request['status'] ?? 'Pending',
              style: TextStyle(
                fontSize: 10.sp,
                color: _getStatusColor(request['status'] ?? 'pending'),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch(status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'completed':
        return AppColor.primary;
      default:
        return AppColor.orange;
    }
  }

  // DASHBOARD TITLE
  Widget _buildDashboardTitle() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        "Dashboard",
        style: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
          color: AppColor.textMain,
        ),
      ),
    );
  }

  // DASHBOARD GRID
  Widget _buildDashboardGrid() {
    final controller = dashboardController;

    final List<Map<String, dynamic>> data = [
      {
        "title": "Plot Enquiries",
        "count": controller.marketEnquiryCount.value,
        "percent": controller.marketEnquiryCount.value > 0 ? 70 : 0,
        "color": AppColor.primary,
      },
      {
        "title": "Material Enquiries",
        "count": controller.materialEnquiryCount.value,
        "percent": controller.materialEnquiryCount.value > 0 ? 55 : 0,
        "color": AppColor.orange,
      },
      {
        "title": "Residential Enquiries",
        "count": controller.residentialEnquiry.value,
        "percent": controller.residentialEnquiry.value > 0 ? 40 : 0,
        "color": AppColor.secondary,
      },
      {
        "title": "My Properties",
        "count": controller.myProperties.value,
        "percent": controller.myProperties.value > 0 ? 60 : 0,
        "color": AppColor.green,
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
        childAspectRatio: 0.92,
      ),
      itemBuilder: (context, index) {
        final item = data[index];
        return _dashboardCard(
          title: item["title"],
          count: item["count"],
          percent: item["percent"],
          color: item["color"],
        ).animate().fade().scale();
      },
    );
  }

  // DASHBOARD CARD
  Widget _dashboardCard({
    required String title,
    required int count,
    required int percent,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 60.w,
            height: 60.w,
            child: CustomPaint(
              painter: DashedRingPainter(
                percent: percent / 100,
                activeColor: color,
                inactiveColor: Colors.grey.shade300,
                width: 6.w,
              ),
              child: Center(
                child: Text(
                  "$percent%",
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "$count",
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColor.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // MENU TITLE
  Widget _buildMenuTitle() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        "Menu",
        style: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
          color: AppColor.textMain,
        ),
      ),
    );
  }

  // MENU LIST
  Widget _buildMenuList() {
    return Column(
      children: [
        _menuTile(Icons.info, "About Us", () => Get.to(() => const AboutUs())),
        _menuTile(Icons.format_align_center, "Company Profile", () => Get.to(() => const VendorStoreView())),
        _menuTile(Icons.info, "Terms and Conditions", () => Get.to(() => const TermsAndConditionsScreen())),
        _menuTile(Icons.contact_emergency, "Contact Us", () => Get.toNamed("/contactus")),
        _menuTile(Icons.history, "Transaction Details", () => Get.toNamed("/transactionDeatils")),
        _menuTile(
          Icons.support_agent,
          "Support",
              () async {
            final uri = Uri.parse("https://cashback.vrikshatech.in/");
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            } else {
              debugPrint("Could not launch $uri");
            }
          },
        ),
        _menuTile(Icons.logout, "Logout", () {
          _showLogoutConfirmation(context);
        }, isLogout: true),
      ],
    );
  }

  Widget _menuTile(IconData icon, String title, VoidCallback onTap, {bool isLogout = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 12.w),
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: AppColor.grey.withOpacity(0.18),
              blurRadius: 6,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: isLogout ? AppColor.red : AppColor.primary),
            SizedBox(width: 14.w),
            Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
                color: isLogout ? AppColor.red : AppColor.textMain,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, size: 16, color: AppColor.grey),
          ],
        ),
      ),
    );
  }
}

// Logout confirmation dialog
void _showLogoutConfirmation(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: AppColor.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
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
              child: Image.asset(
                Images.logout,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Logout',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColor.primary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Are you sure you want to logout?',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 16,
                  color: AppColor.black,
                  fontWeight: FontWeight.bold
              ),
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
                        borderRadius: BorderRadius.circular(10),
                      ),
                      side: BorderSide(color: Colors.grey.shade400),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                          color: AppColor.black,
                          fontWeight: FontWeight.bold
                      ),
                    ),
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
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
      const Center(
        child: CircularProgressIndicator(),
      ),
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

// CUSTOM DASHED GAUGE
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