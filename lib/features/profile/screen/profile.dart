// profile_form.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../common/colours.dart';
import '../../../common/widget/appbar.dart';
import '../../../common/widget/loader.dart';
import '../../../common/widget/toster.dart';
import '../../auth/models/location_model.dart';
import '../controller/profile_controller.dart';

class ProfileForm extends StatelessWidget {
  const ProfileForm({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.put(ProfileController());

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: GifLoader(message: "Loading profile...", size: 100));
        }
        return CustomScrollView(
          slivers: [
            _buildSliverHeader(controller),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  SizedBox(height: 16.h),
                  _buildAvatarCard(controller),
                  SizedBox(height: 16.h),
                  _buildPersonalSection(controller),
                  SizedBox(height: 16.h),
                  _buildAdditionalSection(controller),
                  SizedBox(height: 16.h),
                  _buildAddressSection(controller),
                  SizedBox(height: 16.h),
                  _buildReferralSection(controller),
                  SizedBox(height: 16.h),
                  _buildUpdateButton(controller),
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  // ── Compact Sliver Header ───────────────────────────────────────────────────

  Widget _buildSliverHeader(ProfileController controller) {
    return SliverAppBar(
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded,
            size: 18.sp, color: const Color(0xFF1A1D2E)),
        onPressed: () => Get.back(),
      ),
      title: Text(
        'My Profile',
        style: TextStyle(
          color: const Color(0xFF1A1D2E),
          fontSize: 17.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(height: 1, color: Colors.grey.shade100),
      ),
      // Compact avatar row inside the appbar bottom area
      flexibleSpace: FlexibleSpaceBar(
        expandedTitleScale: 1,
        background: Container(color: Colors.white),
      ),
    );
  }

  // ── Avatar card shown just below appbar ─────────────────────────────────────

  Widget _buildAvatarCard(ProfileController controller) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          GestureDetector(
            onTap: () => _showImagePickerOptions(controller),
            child: Obx(() => Stack(
              children: [
                Container(
                  width: 64.w,
                  height: 64.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: AppColor.primary.withOpacity(0.3), width: 2.w),
                  ),
                  child: ClipOval(
                    child: controller.profileImage.value != null
                        ? Image.file(controller.profileImage.value!,
                        fit: BoxFit.cover)
                        : controller.profileImageUrl.value.isNotEmpty
                        ? CachedNetworkImage(
                      imageUrl: controller.profileImageUrl.value,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        color: AppColor.primary.withOpacity(0.08),
                        child: Icon(Icons.person,
                            size: 28.sp,
                            color: AppColor.primary.withOpacity(0.4)),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: AppColor.primary.withOpacity(0.08),
                        child: Icon(Icons.person,
                            size: 28.sp,
                            color: AppColor.primary.withOpacity(0.4)),
                      ),
                    )
                        : Container(
                      color: AppColor.primary.withOpacity(0.08),
                      child: Icon(Icons.person,
                          size: 28.sp,
                          color: AppColor.primary.withOpacity(0.4)),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 22.w,
                    height: 22.w,
                    decoration: BoxDecoration(
                      color: AppColor.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(Icons.camera_alt_rounded,
                        size: 11.sp, color: Colors.white),
                  ),
                ),
              ],
            )),
          ),
          SizedBox(width: 14.w),
          // Name + email
          Expanded(
            child: Obx(() {
              final p = controller.profile.value;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p?.fullName.isNotEmpty == true ? p!.fullName : 'Your Name',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1D2E),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    p?.email ?? '',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF6B7280),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      if (p?.isEmailVerifiedBool == true)
                        _verifiedChip('Email'),
                      if (p?.isPhoneVerifiedBool == true) ...[
                        SizedBox(width: 6.w),
                        _verifiedChip('Phone'),
                      ],
                    ],
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    )
        .animate()
        .fade(duration: 350.ms)
        .slideY(begin: 0.06, end: 0, duration: 350.ms);
  }

  Widget _verifiedChip(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_rounded,
              size: 10.sp, color: const Color(0xFF10B981)),
          SizedBox(width: 3.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 9.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF10B981),
            ),
          ),
        ],
      ),
    );
  }

  // ── Section Card wrapper ────────────────────────────────────────────────────

  Widget _sectionCard({
    required IconData icon,
    required String title,
    required Color iconColor,
    required List<Widget> children,
    int animDelay = 0,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
            child: Row(
              children: [
                Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(icon, size: 18.sp, color: iconColor),
                ),
                SizedBox(width: 10.w),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1D2E),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fade(duration: 400.ms, delay: Duration(milliseconds: animDelay))
        .slideY(begin: 0.08, end: 0, duration: 400.ms, delay: Duration(milliseconds: animDelay));
  }

  // ── Personal Section ────────────────────────────────────────────────────────

  Widget _buildPersonalSection(ProfileController controller) {
    return _sectionCard(
      icon: Icons.person_outline_rounded,
      title: 'Personal Information',
      iconColor: AppColor.primary,
      animDelay: 0,
      children: [
        Row(
          children: [
            Expanded(
              child: _field(
                label: 'First Name',
                controller: controller.firstNameController,
                hint: 'First name',
                required: true,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _field(
                label: 'Last Name',
                controller: controller.lastNameController,
                hint: 'Last name',
                required: true,
              ),
            ),
          ],
        ),
        SizedBox(height: 14.h),
        _field(
          label: 'Email Address',
          controller: controller.emailController,
          hint: 'you@email.com',
          icon: Icons.email_outlined,
          required: true,
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(height: 14.h),
        _field(
          label: 'Phone Number',
          controller: controller.phoneController,
          hint: '+91 00000 00000',
          icon: Icons.phone_outlined,
          required: true,
          readOnly: true,
        ),
      ],
    );
  }

  // ── Additional Section ──────────────────────────────────────────────────────

  Widget _buildAdditionalSection(ProfileController controller) {
    return _sectionCard(
      icon: Icons.info_outline_rounded,
      title: 'Additional Info',
      iconColor: const Color(0xFF0EA5E9),
      animDelay: 80,
      children: [
        _genderSelector(controller),
        SizedBox(height: 14.h),
        _datePicker(controller),
      ],
    );
  }

  // ── Address Section ─────────────────────────────────────────────────────────

  Widget _buildAddressSection(ProfileController controller) {
    return _sectionCard(
      icon: Icons.location_on_outlined,
      title: 'Address Details',
      iconColor: const Color(0xFF10B981),
      animDelay: 160,
      children: [
        _field(
          label: 'PIN Code',
          controller: controller.pinCodeController,
          hint: '600001',
          icon: Icons.pin_outlined,
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: 14.h),
        _multilineField(
          label: 'Full Address',
          controller: controller.addressController,
          hint: 'Enter your complete address...',
        ),
        SizedBox(height: 14.h),
        _dropdownLabel('Country'),
        SizedBox(height: 6.h),
        GetBuilder<ProfileController>(
          builder: (c) => _styledDropdown<CountryModel>(
            value: c.selectedCountry,
            hint: 'Select Country',
            items: c.countries
                .map((e) => DropdownMenuItem(value: e, child: Text(e.countryName)))
                .toList(),
            onChanged: (v) {
              c.selectedCountry = v;
              c.selectedState = null;
              c.selectedCity = null;
              if (v != null) c.fetchStates(v.id);
              c.update();
            },
          ),
        ),
        SizedBox(height: 14.h),
        _dropdownLabel('State'),
        SizedBox(height: 6.h),
        GetBuilder<ProfileController>(
          builder: (c) => c.isstateLoading
              ? _loadingBar()
              : _styledDropdown<StateModel>(
            value: c.states.contains(c.selectedState) ? c.selectedState : null,
            hint: 'Select State',
            items: c.states
                .map((e) => DropdownMenuItem(value: e, child: Text(e.stateName)))
                .toList(),
            onChanged: (v) {
              c.selectedState = v;
              c.selectedCity = null;
              if (v != null) c.fetchCity(v.id);
              c.update();
            },
          ),
        ),
        SizedBox(height: 14.h),
        _dropdownLabel('City'),
        SizedBox(height: 6.h),
        GetBuilder<ProfileController>(
          builder: (c) => c.isCityoading
              ? _loadingBar()
              : _styledDropdown<CityModel>(
            value: c.cities.contains(c.selectedCity) ? c.selectedCity : null,
            hint: 'Select City',
            items: c.cities
                .map((e) => DropdownMenuItem(value: e, child: Text(e.cityName)))
                .toList(),
            onChanged: (v) {
              c.selectedCity = v;
              c.update();
            },
          ),
        ),
      ],
    );
  }

  // ── Referral Section ────────────────────────────────────────────────────────

  Widget _buildReferralSection(ProfileController controller) {
    return Obx(() {
      final profile = controller.profile.value;
      // refer.id == 1 = admin default, not a real referral
      final hasRefer = profile?.refer != null && profile!.refer!.id != 1;
      final hasOwnCode = profile?.code != null && profile!.code!.isNotEmpty;

      // reference_id == null or 1 means referred by admin/no one — allow input
      final refId = profile?.referenceId;
      final isNotReferred = refId == null || refId == 1;
      final showInput = isNotReferred && !hasRefer;

      return _sectionCard(
        icon: Icons.card_giftcard_rounded,
        title: 'Referral',
        iconColor: const Color(0xFFF59E0B),
        animDelay: 240,
        children: [
          // ── Referred by someone ────────────────────────────────────────
          if (hasRefer) ...[
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Row(
                children: [
                  ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: profile!.refer!.profileImage ?? '',
                      width: 44.w,
                      height: 44.w,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Container(
                        width: 44.w,
                        height: 44.w,
                        color: const Color(0xFFFDE68A),
                        child: Icon(Icons.person,
                            size: 22.sp, color: const Color(0xFFF59E0B)),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Referred by',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: const Color(0xFF92400E),
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          profile.refer!.fullName,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF78350F),
                          ),
                        ),
                        if (profile.refer!.code != null &&
                            profile.refer!.code!.isNotEmpty)
                          Text(
                            profile.refer!.code!,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: const Color(0xFFF59E0B),
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.8,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Icon(Icons.verified_rounded,
                      size: 20.sp, color: const Color(0xFFF59E0B)),
                ],
              ),
            ),
          ],

          // ── User's own referral code ───────────────────────────────────
          if (hasOwnCode) ...[
            if (hasRefer) SizedBox(height: 14.h),
            Text(
              'Your Referral Code',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF6B7280),
              ),
            ),
            SizedBox(height: 8.h),
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: profile!.code!));
                SnackBarHelper.showSuccess('Code copied!');
              },
              child: Container(
                padding:
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                decoration: BoxDecoration(
                  color: AppColor.primary.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12.r),
                  border:
                  Border.all(color: AppColor.primary.withOpacity(0.25)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.qr_code_rounded,
                        size: 20.sp, color: AppColor.primary),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        profile!.code!,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColor.primary,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: AppColor.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(Icons.copy_rounded,
                          size: 15.sp, color: AppColor.primary),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Tap to copy · Share and earn rewards',
              style: TextStyle(
                  fontSize: 11.sp, color: const Color(0xFF9CA3AF)),
            ),
          ],

          // ── No referral at all — show input ───────────────────────────
          if (showInput) ...[
            Text(
              'Have a referral code? Enter it to unlock benefits.',
              style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFF6B7280),
                  height: 1.4),
            ),
            SizedBox(height: 12.h),
            _field(
              label: 'Referral Code',
              controller: controller.referralCodeController,
              hint: 'e.g. BALA0403179',
              icon: Icons.card_giftcard_outlined,
              textCapitalization: TextCapitalization.characters,
            ),
            SizedBox(height: 10.h),
            Container(
              padding:
              EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      size: 13.sp, color: Colors.amber.shade700),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'Can only be added once during profile update',
                      style: TextStyle(
                          fontSize: 11.sp, color: Colors.amber.shade800),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      );
    });
  }

  // ── Update Button ───────────────────────────────────────────────────────────

  Widget _buildUpdateButton(ProfileController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Obx(() => ElevatedButton(
        onPressed: controller.isUpdating.value
            ? null
            : () async {
          final result = await controller.updateProfile();
          if (result['status'] == 200) {
            SnackBarHelper.showSuccess(
                result['message'] ?? 'Profile updated!');
          } else {
            SnackBarHelper.showError(
                result['message'] ?? 'Failed to update profile');
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.primary,
          foregroundColor: Colors.white,
          minimumSize: Size(double.infinity, 52.h),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.r)),
          elevation: 0,
          shadowColor: Colors.transparent,
          disabledBackgroundColor: AppColor.primary.withOpacity(0.5),
        ),
        child: controller.isUpdating.value
            ? SizedBox(
          width: 22.w,
          height: 22.w,
          child: const CircularProgressIndicator(
              strokeWidth: 2.5, color: Colors.white),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline_rounded, size: 18.sp),
            SizedBox(width: 10.w),
            Text(
              'Update Profile',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ))
          .animate()
          .fade(duration: 400.ms, delay: 320.ms)
          .slideY(begin: 0.1, end: 0, duration: 400.ms, delay: 320.ms),
    );
  }

  // ── Shared field widgets ────────────────────────────────────────────────────

  Widget _field({
    required String label,
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
    bool required = false,
    bool readOnly = false,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF374151),
              ),
            ),
            if (required)
              Text(' *',
                  style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.red,
                      fontWeight: FontWeight.bold)),
          ],
        ),
        SizedBox(height: 6.h),
        TextField(
          controller: controller,
          readOnly: readOnly,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          style: TextStyle(
            fontSize: 13.sp,
            color: readOnly
                ? const Color(0xFF9CA3AF)
                : const Color(0xFF1A1D2E),
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
                fontSize: 13.sp, color: const Color(0xFFD1D5DB)),
            prefixIcon: icon != null
                ? Icon(icon, size: 18.sp, color: AppColor.primary.withOpacity(0.6))
                : null,
            suffixIcon: readOnly
                ? Icon(Icons.lock_outline_rounded,
                size: 15.sp, color: const Color(0xFFD1D5DB))
                : null,
            filled: true,
            fillColor: readOnly
                ? const Color(0xFFF9FAFB)
                : Colors.white,
            contentPadding:
            EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: AppColor.primary, width: 1.8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _multilineField({
    required String label,
    required TextEditingController controller,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF374151))),
        SizedBox(height: 6.h),
        TextField(
          controller: controller,
          maxLines: 3,
          style: TextStyle(
              fontSize: 13.sp,
              color: const Color(0xFF1A1D2E),
              fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
            TextStyle(fontSize: 13.sp, color: const Color(0xFFD1D5DB)),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
            EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: AppColor.primary, width: 1.8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _dropdownLabel(String label) {
    return Text(
      label,
      style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF374151)),
    );
  }

  Widget _styledDropdown<T>({
    required T? value,
    required String hint,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF9CA3AF)),
          hint: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            child: Text(hint,
                style: TextStyle(
                    fontSize: 13.sp, color: const Color(0xFFD1D5DB))),
          ),
          items: items,
          onChanged: onChanged,
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 2.h),
          style: TextStyle(
              fontSize: 13.sp,
              color: const Color(0xFF1A1D2E),
              fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _loadingBar() {
    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: const Center(
        child: LinearProgressIndicator(color: AppColor.primary),
      ),
    );
  }

  Widget _genderSelector(ProfileController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Gender',
                style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF374151))),
            Text(' *',
                style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.red,
                    fontWeight: FontWeight.bold)),
          ],
        ),
        SizedBox(height: 8.h),
        Obx(() => Row(
          children: [
            _genderChip(controller, 'Male', Icons.male_rounded, 1,
                const Color(0xFF3B82F6)),
            SizedBox(width: 10.w),
            _genderChip(controller, 'Female', Icons.female_rounded, 2,
                const Color(0xFFEC4899)),
            SizedBox(width: 10.w),
            _genderChip(controller, 'Other', Icons.transgender_rounded, 3,
                const Color(0xFF8B5CF6)),
          ],
        )),
      ],
    );
  }

  Widget _genderChip(ProfileController controller, String label,
      IconData icon, int value, Color color) {
    final isSelected = controller.selectedGender.value == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.selectedGender.value = value,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.1) : const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: isSelected ? color : const Color(0xFFE5E7EB),
              width: isSelected ? 1.8 : 1.2,
            ),
          ),
          child: Column(
            children: [
              Icon(icon,
                  size: 20.sp,
                  color: isSelected ? color : const Color(0xFF9CA3AF)),
              SizedBox(height: 4.h),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? color : const Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _datePicker(ProfileController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Date of Birth',
            style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF374151))),
        SizedBox(height: 6.h),
        GestureDetector(
          onTap: () => _selectDate(controller),
          child: AbsorbPointer(
            child: TextField(
              controller: controller.dobController,
              style: TextStyle(
                  fontSize: 13.sp,
                  color: const Color(0xFF1A1D2E),
                  fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                hintText: 'YYYY-MM-DD',
                hintStyle:
                TextStyle(fontSize: 13.sp, color: const Color(0xFFD1D5DB)),
                prefixIcon: Icon(Icons.calendar_today_outlined,
                    size: 18.sp, color: AppColor.primary.withOpacity(0.6)),
                suffixIcon: Icon(Icons.keyboard_arrow_down_rounded,
                    color: AppColor.primary),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide:
                  const BorderSide(color: Color(0xFFE5E7EB), width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: BorderSide(color: AppColor.primary, width: 1.8),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  void _showImagePickerOptions(ProfileController controller) {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 28.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 16.h),
            Text('Update Photo',
                style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1D2E))),
            SizedBox(height: 16.h),
            _imageOption(
              icon: Icons.photo_library_rounded,
              title: 'Choose from Gallery',
              color: Colors.blue,
              onTap: () {
                Get.back();
                Future.delayed(const Duration(milliseconds: 300), () {
                  controller.pickProfileImage();
                });
              },
            ),
            SizedBox(height: 10.h),
            _imageOption(
              icon: Icons.camera_alt_rounded,
              title: 'Take a Photo',
              color: Colors.green,
              onTap: () {
                Get.back();
                Future.delayed(const Duration(milliseconds: 300), () {
                  controller.takeProfilePhoto();
                });
              },
            ),
            SizedBox(height: 10.h),
            TextButton(
              onPressed: () => Get.back(),
              child: Text('Cancel',
                  style: TextStyle(
                      fontSize: 14.sp, color: const Color(0xFF9CA3AF))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageOption({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 18.sp, color: color),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Text(title,
                  style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1D2E))),
            ),
            Icon(Icons.chevron_right_rounded,
                size: 18.sp, color: const Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(ProfileController controller) async {
    final picked = await showDatePicker(
      context: Get.context!,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.year,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppColor.primary,
            onPrimary: Colors.white,
            onSurface: const Color(0xFF1A1D2E),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      controller.dobController.text =
      '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }
}