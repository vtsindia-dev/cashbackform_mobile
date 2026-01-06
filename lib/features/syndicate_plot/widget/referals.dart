import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import '../../../common/colours.dart';
import '../../../common/widget/toster.dart';
import '../controller/syndicate_controller.dart';
import '../model/syndicate_model.dart';

class Referrals extends StatefulWidget {
  const Referrals({super.key, required this.reservePlotsKey});

  @override
  State<Referrals> createState() => _ReferralsState();

  final GlobalKey reservePlotsKey;
}

class _ReferralsState extends State<Referrals> {
  final TextEditingController _referralEmailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  var _isLoading = false.obs;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SyndicatePlotController>();
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 15.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildReferralSection(),
          SizedBox(height: 12.h),
          Obx(() => _buildBookedSlotsSection(controller)),
        ],
      ),
    );
  }

  Widget _buildReferralSection() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Refer Friends & Join the Scheme Group",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 19.sp,
              color: AppColor.black,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            "Invite your friends or family to join this scheme and purchase plots together. "
                "When your reference successfully reserves a plot, both of you get exclusive benefits "
                "and can join the private group chat to discuss the project, updates, and progress.",
            style: TextStyle(fontSize: 12.sp, color: AppColor.black),
          ),
          SizedBox(height: 10.h),

          // Email Input Field ONLY
          _buildEmailInputField(),
        ],
      ),
    );
  }

  Widget _buildEmailInputField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Friend's Email",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
        ),
        SizedBox(height: 6.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 0.h),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: TextFormField(
            controller: _referralEmailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: "Enter friend's email address",
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 16.h),
              prefixIcon: Icon(Icons.email, size: 18.sp, color: Colors.grey[600]),
            ),
            style: TextStyle(fontSize: 12.sp),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter email address';
              }
              if (!GetUtils.isEmail(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
        ),
        SizedBox(height: 6.h),
        Obx(() => _isLoading.value
            ? Center(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: CircularProgressIndicator(
              strokeWidth: 2.w,
              valueColor: AlwaysStoppedAnimation<Color>(AppColor.primary),
            ),
          ),
        )
            : GestureDetector(
          onTap: _sendReferralInvite,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColor.primary, AppColor.primarylite],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4.r,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.send, size: 16.sp, color: Colors.black),
                SizedBox(width: 8.w),
                Text(
                  "Send Referral Invite",
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
        ),
      ],
    );
  }

  Future<void> _sendReferralInvite() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final controller = Get.find<SyndicatePlotController>();
    final detail = controller.syndicateDetail.value;

    if (detail == null) {
      SnackBarHelper.showError('Property details not available');
      return;
    }

    _isLoading.value = true;

    try {
      // Call the controller method with friend's email and property ID
      final result = await controller.fetchStoreReferral(
        _referralEmailController.text.trim(),
        detail.id,
      );

      if (result['success'] == true) {
        // Controller already shows success message
        _referralEmailController.clear();
      } else {
        // Controller already shows error message
        print('Referral failed: ${result['message']}');
      }
    } catch (e) {
      // Fallback error handling
      SnackBarHelper.showError('Error: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  // The rest of your existing methods remain EXACTLY THE SAME...
  Widget _buildBookedSlotsSection(SyndicatePlotController controller) {
    final detail = controller.syndicateDetail.value;
    final totalPlots = detail?.unitSpilt ?? 0;
    final bookedPlots = controller.countStatus("booked");
    final uniqueUsers = _getUniqueUsersFromBookings(controller);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10.h),
        _buildArrowButton(controller),
        SizedBox(height: 10.h),
        _buildBookedSlots(controller, totalPlots, bookedPlots, uniqueUsers),
      ],
    );
  }

  Widget _buildArrowButton(SyndicatePlotController controller) {
    return GestureDetector(
      onTap: controller.refralExpansion,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColor.primary, AppColor.primarylite],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              controller.isExpandedrefral.value ? 'Hide Booked List' : 'View Booked List',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
            ),
            SizedBox(width: 6.w),
            Icon(
              controller.isExpandedrefral.value ? Icons.arrow_upward : Icons.arrow_downward,
              size: 18.sp,
              color: Colors.black,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookedSlots(
      SyndicatePlotController controller,
      int totalPlots,
      int bookedPlots,
      List<Map<String, dynamic>> uniqueUsers
      ) {
    return AnimatedContainer(
      duration: 400.ms,
      height: controller.isExpandedrefral.value ? null : 0,
      child: controller.isExpandedrefral.value
          ? Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Slots Filled ($bookedPlots/$totalPlots) - Already Booked List",
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.h),
          _buildProgressBar(bookedPlots, totalPlots),
          SizedBox(height: 12.h),
          _buildStatsRow(controller, totalPlots, bookedPlots),
          SizedBox(height: 16.h),
          if (uniqueUsers.isNotEmpty) ...[
            Text(
              "Booked Users (${uniqueUsers.length})",
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 10.h),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: (uniqueUsers.length / 2).ceil(),
              itemBuilder: (context, rowIndex) {
                final int firstIndex = rowIndex * 2;
                final int secondIndex = firstIndex + 1;
                return Padding(
                  padding: EdgeInsets.only(bottom: 10.h),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildUserCard(
                          uniqueUsers[firstIndex]['name'] ?? 'Unknown User',
                          uniqueUsers[firstIndex]['email'] ?? 'No email',
                          uniqueUsers[firstIndex]['plots'] ?? 0,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      if (secondIndex < uniqueUsers.length)
                        Expanded(
                          child: _buildUserCard(
                            uniqueUsers[secondIndex]['name'] ?? 'Unknown User',
                            uniqueUsers[secondIndex]['email'] ?? 'No email',
                            uniqueUsers[secondIndex]['plots'] ?? 0,
                          ),
                        )
                      else
                        Expanded(child: Container()),
                    ],
                  ),
                );
              },
            ),
          ] else ...[
            Center(child: _buildNoUsersPlaceholder()),
          ],
        ],
      )
          : const SizedBox(),
    );
  }

  Widget _buildProgressBar(int bookedPlots, int totalPlots) {
    final progress = totalPlots > 0 ? bookedPlots / totalPlots : 0.0;

    return Container(
      height: 8.h,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
          AnimatedContainer(
            duration: 500.ms,
            width: MediaQuery.of(Get.context!).size.width * 0.7 * progress,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3B711A), Color(0xFF5A9C2E)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(SyndicatePlotController controller, int totalPlots, int bookedPlots) {
    final selectedPlots = controller.selectedPlots.length;
    final availablePlots = totalPlots - bookedPlots - selectedPlots;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem("Total", "$totalPlots", Icons.grid_view, Colors.blue),
        _buildStatItem("Booked", "$bookedPlots", Icons.check_circle, Colors.green),
        _buildStatItem("Available", "$availablePlots", Icons.circle_outlined, Colors.orange),
        _buildStatItem("Selected", "$selectedPlots", Icons.bookmark, Colors.purple),
      ],
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, size: 16.sp, color: color),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 10.sp,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildUserCard(String name, String email, int plotsCount) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16.r,
            backgroundColor: Colors.green[200],
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : "?",
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  email,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (plotsCount > 0) ...[
                  SizedBox(height: 2.h),
                  Text(
                    "$plotsCount plot${plotsCount > 1 ? 's' : ''} booked",
                    style: TextStyle(
                      fontSize: 9.sp,
                      color: Colors.green[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(
      begin: 0.2,
      end: 0,
      curve: Curves.easeOut,
    );
  }

  Widget _buildNoUsersPlaceholder() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey[50]!,
            Colors.grey[100]!,
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6B7280), Color(0xFF9CA3AF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey[400]!.withOpacity(0.3),
                  blurRadius: 8.r,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              Icons.people_alt_outlined,
              size: 32.sp,
              color: Colors.white,
            ),
          )
              .animate(onPlay: (controller) => controller.repeat())
              .shimmer(
            duration: 2000.ms,
            curve: Curves.easeInOut,
          )
              .scale(
            begin: const Offset(0.9, 0.9),
            end: const Offset(1.0, 1.0),
            duration: 1500.ms,
          ),

          SizedBox(height: 20.h),

          Text(
            "No Bookings Yet",
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: Colors.grey[700],
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 8.h),

          Text(
            "This scheme is waiting for its first investors.\nBe the pioneer and book your plot today!",
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w400,
              color: Colors.grey[600],
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 20.h),

          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColor.primary, AppColor.primarylite],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: AppColor.primary.withOpacity(0.3),
                  blurRadius: 8.r,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12.r),
              child: InkWell(
                onTap: () {
                  _scrollToReservePlots();
                },
                borderRadius: BorderRadius.circular(12.r),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.add_circle_outline,
                        size: 18.sp,
                        color: Colors.black,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        "Book First Plot",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
              .animate()
              .fadeIn(delay: 300.ms)
              .slideY(
            begin: 0.3,
            end: 0,
            duration: 500.ms,
            curve: Curves.easeOut,
          ),

          SizedBox(height: 12.h),

          Text(
            "Join early and get exclusive benefits!",
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey[500],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  void _scrollToReservePlots() {
    final context = widget.reservePlotsKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeInOut,
        alignment: 0.7,
      );
    }
  }

  List<Map<String, dynamic>> _getUniqueUsersFromBookings(SyndicatePlotController controller) {
    final detail = controller.syndicateDetail.value;
    if (detail == null) return [];

    final Map<int, Map<String, dynamic>> userMap = {};

    for (final booking in detail.bookings) {
      final userId = booking.userId;
      final user = detail.users.firstWhere(
            (u) => u.id == userId,
        orElse: () => User(
          id: userId,
          role: 0,
          name: 'Unknown User',
          email: 'No email',
          dob: '',
          avatar: '',
          pin: '',
          gender: 0,
          address: '',
          phone: '',
          status: 0,
        ),
      );

      if (!userMap.containsKey(userId)) {
        userMap[userId] = {
          'name': user.name,
          'email': user.email,
          'plots': 0,
        };
      }

      final plotIds = _parseUnitIds(booking.units);
      userMap[userId]!['plots'] = (userMap[userId]!['plots'] as int) + plotIds.length;
    }

    return userMap.values.toList();
  }

  Set<int> _parseUnitIds(String unitsString) {
    final Set<int> unitIds = <int>{};
    try {
      final parts = unitsString.split(',');
      for (final part in parts) {
        final id = int.tryParse(part.trim());
        if (id != null) {
          unitIds.add(id);
        }
      }
    } catch (e) {
      print('Error parsing unit IDs: $e');
    }
    return unitIds;
  }
}