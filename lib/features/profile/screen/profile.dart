// profile_form.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
      appBar: DynamicAppBar(
        title: "My Profile",
        showBackButton: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: GifLoader(message: "Loading...", size: 100),
          );
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 10.h),
              _buildProfileImageSection(controller),
              SizedBox(height: 24.h),
              _buildFormFields(controller),
              SizedBox(height: 30.h),
              _buildUpdateButton(controller),
              SizedBox(height: 15.h),
            ],
          ),
        );
      }),
    );
  }


  Widget _buildProfileImageSection(ProfileController controller) {
    return Column(
      children: [
        // Profile Image Container
        GestureDetector(
          onTap: () => _showImagePickerOptions(controller),
          child: Container(
            width: 120.w,
            height: 120.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColor.primary,
                width: 3.w,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColor.primary.withOpacity(0.2),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Stack(
              children: [
                // Profile Image
                Obx(() {
                  return Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColor.backgroundLight,
                      image: controller.profileImage.value != null
                          ? DecorationImage(
                        image: FileImage(controller.profileImage.value!),
                        fit: BoxFit.cover,
                      )
                          : (controller.profileImageUrl.value.isNotEmpty
                          ? DecorationImage(
                        image: NetworkImage(controller.profileImageUrl.value),
                        fit: BoxFit.cover,
                      )
                          : null),
                    ),
                    child: controller.profileImage.value == null &&
                        controller.profileImageUrl.value.isEmpty
                        ? Center(
                      child: Icon(
                        Icons.person,
                        size: 50.sp,
                        color: AppColor.primary.withOpacity(0.5),
                      ),
                    )
                        : null,
                  );
                }),

                // Edit Icon Overlay
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 36.w,
                    height: 36.w,
                    decoration: BoxDecoration(
                      color: AppColor.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 3.w,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.edit,
                        size: 18.sp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
              .animate()
              .scale(begin: Offset(0.8, 0.8), duration: 500.ms)
              .fade(duration: 500.ms)
              .shake(duration: 800.ms, delay: 1000.ms),
        ),

        SizedBox(height: 12.h),

        // Profile Image Text
        Text(
          'Tap to update photo',
          style: TextStyle(
            fontSize: 12.sp,
            color: AppColor.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ).animate().fade(duration: 300.ms),
      ],
    );
  }

  Widget _buildFormFields(ProfileController controller) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Personal Information Header
          _buildSectionHeader(
            icon: Icons.person_outline,
            title: 'Personal Information',
          ),
          SizedBox(height: 16.h),

          // Name Row
          Row(
            children: [
              Expanded(
                child: _buildAnimatedTextField(
                  controller: controller.firstNameController,
                  label: 'First Name',
                  hint: 'John',
                  isRequired: true,
                  index: 0,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildAnimatedTextField(
                  controller: controller.lastNameController,
                  label: 'Last Name',
                  hint: 'Doe',
                  isRequired: true,
                  index: 1,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Email
          _buildAnimatedTextField(
            controller: controller.emailController,
            label: 'Email Address',
            hint: 'john.doe@email.com',
            icon: Icons.email_outlined,
            isRequired: true,
            index: 2,
          ),
          SizedBox(height: 16.h),

          // Phone
          _buildAnimatedTextField(
            controller: controller.phoneController,
            label: 'Phone Number',
            hint: '+1 234 567 8900',
            isPhoneNumber: true,
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            isRequired: true,
            index: 3,
          ),
          SizedBox(height: 20.h),

          // Additional Information Header
          _buildSectionHeader(
            icon: Icons.info_outline,
            title: 'Additional Information',
          ),
          SizedBox(height: 16.h),

          // Gender
          _buildGenderSelector(controller),
          SizedBox(height: 16.h),

          // Date of Birth
          _buildDatePicker(controller),
          SizedBox(height: 16.h),

          // Address Section
          _buildSectionHeader(
            icon: Icons.location_on_outlined,
            title: 'Address Details',
          ),
          SizedBox(height: 16.h),

          // PIN Code
          _buildAnimatedTextField(
            controller: controller.pinCodeController,
            label: 'PIN Code',
            hint: '123456',
            icon: Icons.pin_outlined,
            keyboardType: TextInputType.number,
            index: 4,
          ),
          SizedBox(height: 16.h),

          // Address
          _buildAddressField(controller),
          SizedBox(height: 16.h),

          Align(
            alignment: Alignment.centerLeft,
            child: Text("Country"),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColor.primarylite,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColor.primary.withOpacity(0.2),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
              color: Colors.white,
            ),
            child: DropdownButtonFormField<CountryModel>(
              value: controller.selectedCountry,
              items: controller.countries.map((country) {
                return DropdownMenuItem(
                  value: country,
                  child: Text(country.countryName),
                );
              }).toList(),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: "Select Country",
              ),
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
              onChanged: (value) {
                controller.selectedCountry = value;
                controller.selectedState = null;
                controller.selectedCity = null;

                if (value != null) {
                  controller.fetchStates(value.id);
                }

                controller.update();
              },
            ),
          ),

          const SizedBox(height: 20),

          Align(
            alignment: Alignment.centerLeft,
            child: Text("State"),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColor.primarylite,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColor.primary.withOpacity(0.2),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
              color: Colors.white,
            ),
            child: GetBuilder<ProfileController>(
              builder: (profilecontrollr) {

                if (profilecontrollr.isstateLoading) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: LinearProgressIndicator(
                      color: AppColor.primary,
                    ),
                  );
                }

                return DropdownButtonFormField<StateModel>(
                  value: profilecontrollr.states.contains(controller.selectedState)
                      ? controller.selectedState
                      : null,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Select State",
                  ),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                  items: profilecontrollr.states.map((state) {
                    return DropdownMenuItem<StateModel>(
                      value: state, // ✅ FIXED
                      child: Text(state.stateName),
                    );
                  }).toList(),
                  onTap: () {
                    if (profilecontrollr.states.isEmpty) {
                      SnackBarHelper.showError("Please select country first");
                    }
                  },
                  onChanged: (value) {

                    controller.selectedState = value;
                    controller.selectedCity = null;

                    if (value != null) {
                      controller.fetchCity(value.id);
                    }

                    controller.update(); // important for GetBuilder
                  },
                );
              },
            ),
          ),


          const SizedBox(height: 20),

          Align(
            alignment: Alignment.centerLeft,
            child: const Text("City"),
          ),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColor.primarylite,
                width: 1.5,
              ),
              color: Colors.white,
            ),
            child: GetBuilder<ProfileController>(
              builder: (profilecontrollr) {

                if (profilecontrollr.isCityoading) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: LinearProgressIndicator(
                      color: AppColor.primary,
                    ),
                  );
                }

                return DropdownButtonFormField<CityModel>(
                  value: profilecontrollr.cities.contains(controller.selectedCity)
                      ? controller.selectedCity
                      : null,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Select City",
                  ),
                  items: profilecontrollr.cities.map((city) {
                    return DropdownMenuItem<CityModel>(
                      value: city, // ✅ FIXED
                      child: Text(city.cityName),
                    );
                  }).toList(),
                  onTap: () {
                    if (profilecontrollr.cities.isEmpty) {
                      SnackBarHelper.showError("Please select state first");
                    }
                  },
                  onChanged: (value) {
                    controller.selectedCity = value;
                    controller.update();
                  },
                );
              },
            ),
          ),
          SizedBox(height: 20,),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({required IconData icon, required String title}) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: AppColor.primarylite.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(
            icon,
            size: 18.sp,
            color: AppColor.primary,
          ),
        ),
        SizedBox(width: 12.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: AppColor.textMain,
          ),
        ),
      ],
    ).animate().fade(duration: 300.ms).slide(begin: Offset(-0.1, 0));
  }

  Widget _buildAnimatedTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
    bool isRequired = false,
    bool enabled = true,
    required int index,
    bool isPhoneNumber = false, // Add this parameter
  }) {
    bool isFieldEnabled = enabled && !isPhoneNumber; // Phone number is always read-only

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColor.textMain,
              ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        SizedBox(height: 6.h),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            enabled: isFieldEnabled,
            readOnly: isPhoneNumber, // Set read-only for phone number
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                fontSize: 13.sp,
                color: AppColor.textSecondary.withOpacity(0.7),
              ),
              prefixIcon: icon != null
                  ? Icon(
                icon,
                color: AppColor.primary.withOpacity(0.7),
                size: 20.sp,
              )
                  : null,
              filled: true,
              fillColor: isFieldEnabled ? Colors.white : AppColor.backgroundLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: AppColor.primarylite,
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: AppColor.primary,
                  width: 2,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 16.h,
              ),
              suffixIcon: !isFieldEnabled
                  ? Icon(
                Icons.lock_outline,
                size: 16.sp,
                color: AppColor.textSecondary.withOpacity(0.5),
              )
                  : null,
            ),
            keyboardType: keyboardType,
            style: TextStyle(
              fontSize: 14.sp,
              color: isFieldEnabled ? AppColor.textMain : AppColor.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ]
          .animate()
          .fade(duration: 300.ms)
          .slide(begin: Offset(0, 0.1))
          .then(delay: (index * 50).ms),
    );
  }
  Widget _buildGenderSelector(ProfileController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Gender',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColor.textMain,
              ),
            ),
            Text(
              ' *',
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Obx(() {
          return Row(
            children: [
              Expanded(
                child: _buildGenderOption(
                  controller: controller,
                  icon: Icons.male,
                  label: 'Male',
                  value: 1,
                  isSelected: controller.selectedGender.value == 1,
                  color: Colors.blue.shade100,
                  iconColor: Colors.blue,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildGenderOption(
                  controller: controller,
                  icon: Icons.female,
                  label: 'Female',
                  value: 2,
                  isSelected: controller.selectedGender.value == 2,
                  color: Colors.pink.shade100,
                  iconColor: Colors.pink,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildGenderOption(
                  controller: controller,
                  icon: Icons.transgender,
                  label: 'Other',
                  value: 3,
                  isSelected: controller.selectedGender.value == 3,
                  color: Colors.purple.shade100,
                  iconColor: Colors.purple,
                ),
              ),
            ].animate(interval: 50.ms).fade(duration: 300.ms).slide(begin: Offset(0, 0.1)),
          );
        }),
      ],
    );
  }

  Widget _buildGenderOption({
    required ProfileController controller,
    required IconData icon,
    required String label,
    required int value,
    required bool isSelected,
    required Color color,
    required Color iconColor,
  }) {
    return GestureDetector(
      onTap: () => controller.selectedGender.value = value,
      child: AnimatedContainer(
        duration: 300.ms,
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: isSelected ? color : AppColor.backgroundLight,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? iconColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1.5,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: iconColor.withOpacity(0.2),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 22.sp,
              color: isSelected ? iconColor : Colors.grey.shade600,
            ),
            SizedBox(height: 6.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: isSelected ? iconColor : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker(ProfileController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date of Birth',
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: AppColor.textMain,
          ),
        ),
        SizedBox(height: 6.h),
        GestureDetector(
          onTap: () => _selectDate(controller),
          child: AbsorbPointer(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: controller.dobController,
                decoration: InputDecoration(
                  hintText: 'Select your date of birth',
                  hintStyle: TextStyle(
                    fontSize: 13.sp,
                    color: AppColor.textSecondary.withOpacity(0.7),
                  ),
                  prefixIcon: Icon(
                    Icons.calendar_today_outlined,
                    color: AppColor.primary.withOpacity(0.7),
                    size: 20.sp,
                  ),
                  suffixIcon: Icon(
                    Icons.arrow_drop_down,
                    color: AppColor.primary,
                    size: 24.sp,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(
                      color: AppColor.primarylite,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(
                      color: AppColor.primary,
                      width: 2,
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 16.h,
                  ),
                ),
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColor.textMain,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ].animate().fade(duration: 300.ms).slide(begin: Offset(0, 0.1)),
    );
  }

  Widget _buildAddressField(ProfileController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Full Address',
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: AppColor.textMain,
          ),
        ),
        SizedBox(height: 6.h),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: controller.addressController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Enter your complete address',
              hintStyle: TextStyle(
                fontSize: 13.sp,
                color: AppColor.textSecondary.withOpacity(0.7),
              ),
              prefixIcon: Padding(
                padding: EdgeInsets.only(bottom: 30.h),
                child: Icon(
                  Icons.home_outlined,
                  color: AppColor.primary.withOpacity(0.7),
                  size: 20.sp,
                ),
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: AppColor.primarylite,
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: AppColor.primary,
                  width: 2,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 16.h,
              ),
            ),
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColor.textMain,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ].animate().fade(duration: 300.ms).slide(begin: Offset(0, 0.1)),
    );
  }

  Widget _buildUpdateButton(ProfileController controller) {
    return Obx(() {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.r),
            boxShadow: [
              BoxShadow(
                color: AppColor.primary.withOpacity(0.3),
                blurRadius: 15,
                spreadRadius: 2,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: controller.isUpdating.value ? null : () => _updateProfile(controller),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primary,
              foregroundColor: Colors.white,
              minimumSize: Size(double.infinity, 54.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.r),
              ),
              disabledBackgroundColor: AppColor.primary.withOpacity(0.5),
              elevation: 0,
              padding: EdgeInsets.symmetric(horizontal: 40.w),
            ),
            child: controller.isUpdating.value
                ? SizedBox(
              width: 24.w,
              height: 24.w,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.white,
              ),
            )
                : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline, size: 20.sp),
                SizedBox(width: 12.w),
                Text(
                  'Update Profile',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ).animate().fade(duration: 400.ms).scale(begin: Offset(0.9, 0.9)),
      );
    });
  }

  void _showImagePickerOptions(ProfileController controller) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'Update Profile Photo',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColor.textMain,
              ),
            ),
            SizedBox(height: 20.h),
            _buildImageOption(
              icon: Icons.photo_library,
              title: 'Choose from Gallery',
              color: Colors.blue,
              onTap: () {
                Get.back();
                controller.pickProfileImage();
              },
            ),
            SizedBox(height: 12.h),
            _buildImageOption(
              icon: Icons.camera_alt,
              title: 'Take Photo',
              color: Colors.green,
              onTap: () {
                Get.back();
                controller.takeProfilePhoto();
              },
            ),
            SizedBox(height: 12.h),
            // if (controller.profileImage.value != null ||
            //     controller.profileImageUrl.value.isNotEmpty)
            //   _buildImageOption(
            //     icon: Icons.delete_outline,
            //     title: 'Remove Photo',
            //     color: Colors.red,
            //     onTap: () async {
            //       Get.back();
            //       await controller.removeProfileImage();
            //     },
            //   ),
            // SizedBox(height: 16.h),
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColor.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageOption({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: color.withOpacity(0.2), width: 1),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20.sp),
              ),
              SizedBox(width: 16.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15.sp,
                  color: AppColor.textMain,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Spacer(),
              Icon(
                Icons.arrow_forward_ios,
                size: 16.sp,
                color: AppColor.textSecondary.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(ProfileController controller) async {
    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.year,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColor.primary,
              onPrimary: Colors.white,
              onSurface: AppColor.textMain,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColor.primary,
              ),
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formattedDate =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      controller.dobController.text = formattedDate;
    }
  }
  Future<void> _updateProfile(ProfileController controller) async {
    final result = await controller.updateProfile();

    if (result['status'] == 200) {
      SnackBarHelper.showSuccess(
        result['message'] ?? 'Profile updated successfully!',
        duration: const Duration(seconds: 2),
      );
    } else {
      SnackBarHelper.showError(
        result['message'] ?? 'Failed to update profile',
        duration: const Duration(seconds: 3),
      );
    }
  }}