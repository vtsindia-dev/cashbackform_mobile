// profile_controller.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../common/api_constant.dart';
import '../../../common/widget/api_service.dart';
import '../../../common/widget/sessionhandler.dart';
import '../../../common/widget/toster.dart';
import '../model/profle_model.dart';

class ProfileController extends GetxController {
  var isLoading = false.obs;
  var isUpdating = false.obs;
  var profile = Rxn<ProfileModel>();
  var errorMessage = ''.obs;
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final dobController = TextEditingController();
  final pinCodeController = TextEditingController();
  final addressController = TextEditingController();
  var selectedGender = 0.obs; // 0 = not selected, 1 = male, 2 = female, 3 = other
  final ImagePicker _picker = ImagePicker();
  var profileImage = Rxn<File>();
  var profileImageUrl = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    dobController.dispose();
    pinCodeController.dispose();
    addressController.dispose();
    super.onClose();
  }

  Future<void> fetchProfile() async {
    try {
      isLoading(true);
      errorMessage('');
      final token = await SessionManager.getToken();
      if (token == null || token.isEmpty) {
        errorMessage('Please login to view profile');
        SnackBarHelper.showError('Please login to view profile');
        isLoading(false);
        return;
      }
      print('🔐 Authentication token present');
      final response = await ApiService.getProfile(token);
      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData != null && responseData['data'] != null) {
          profile.value = ProfileModel.fromJson(responseData['data']);
          _prefillFormData();
          print('✅ Profile data loaded successfully');
        } else {
          errorMessage('Invalid response format from server');
          SnackBarHelper.showError('Failed to load profile data');
        }
      } else if (response.statusCode == 401) {
        errorMessage('Session expired. Please login again.');
        SnackBarHelper.showError('Session expired');
        await SessionManager.clearSession();
        Get.offAllNamed('/login');
      } else {
        final errorMsg = response.data?['message'] ?? 'Failed to fetch profile';
        errorMessage(errorMsg);
        SnackBarHelper.showError(errorMsg);
      }
    } catch (e) {
      errorMessage('Network error occurred');
      SnackBarHelper.showError('Network error occurred');
      debugPrint('Profile fetch error: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }
  Future<Map<String, dynamic>> updateProfile() async {
    try {
      isUpdating(true);
      errorMessage('');
      if (!_validateForm()) {
        isUpdating(false);
        return {'status': 400, 'message': 'Please fill all required fields'};
      }
      final token = await SessionManager.getToken();
      if (token == null || token.isEmpty) {
        isUpdating(false);
        return {'status': 401, 'message': 'Please login to update profile'};
      }

      // Prepare form data
      final formData = {
        'first_name': firstNameController.text.trim(),
        'last_name': lastNameController.text.trim(),
        'phone': phoneController.text.trim(),
        'gender': selectedGender.value,
        'dob': dobController.text.trim(),
        'pin_code': pinCodeController.text.trim(),
        'address': addressController.text.trim(),
        'email': emailController.text.trim(),
      };
      print('📤 Updating profile with data: $formData');
      final response = await ApiService.updateProfile(
        data: formData,
        token: token,
        profileImage: profileImage.value,
      );
      print('📥 Update response: ${response.statusCode}');
      print('📥 Update data: ${response.data}');
      if (response.statusCode == 200) {
        await fetchProfile();
        return {
          'status': 200,
          'message': response.data?['message'] ?? 'Profile updated successfully',
          'data': response.data?['data'],
        };
      } else {
        final errorMsg = response.data?['message'] ?? 'Failed to update profile';
        return {'status': response.statusCode ?? 500, 'message': errorMsg};
      }
    } catch (e) {
      print('❌ Update profile error: $e');
      return {'status': 500, 'message': 'Network error: $e'};
    } finally {
      isUpdating(false);
    }
  }

  // Pick profile image from gallery
  Future<void> pickProfileImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (image != null) {
        profileImage.value = File(image.path);
      }
    } catch (e) {
      print('❌ Image pick error: $e');
      SnackBarHelper.showError('Failed to pick image: $e');
    }
  }

  // Take profile photo with camera
  Future<void> takeProfilePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (image != null) {
        profileImage.value = File(image.path);
      }
    } catch (e) {
      print('❌ Camera error: $e');
      SnackBarHelper.showError('Failed to take photo: $e');
    }
  }

  // Prefill form data from profile
  void _prefillFormData() {
    if (profile.value != null) {
      final p = profile.value!;
      firstNameController.text = p.firstName;
      lastNameController.text = p.lastName;
      emailController.text = p.email;
      phoneController.text = p.phone;
      selectedGender.value = p.gender;
      dobController.text = p.dob ?? '';
      pinCodeController.text = p.pinCode ?? '';
      addressController.text = p.address ?? '';
      profileImageUrl.value = p.profileImage ?? '';
    }
  }

  // Validate form
  bool _validateForm() {
    if (firstNameController.text.trim().isEmpty) {
      SnackBarHelper.showError('Please enter first name');
      return false;
    }
    if (lastNameController.text.trim().isEmpty) {
      SnackBarHelper.showError('Please enter last name');
      return false;
    }
    if (emailController.text.trim().isEmpty) {
      SnackBarHelper.showError('Please enter email');
      return false;
    }
    if (phoneController.text.trim().isEmpty) {
      SnackBarHelper.showError('Please enter phone number');
      return false;
    }
    if (selectedGender.value == 0) {
      SnackBarHelper.showError('Please select gender');
      return false;
    }
    return true;
  }

  // Clear profile image selection
  void clearProfileImage() {
    profileImage.value = null;
  }

  // Get profile image for display
  String get displayProfileImage {
    if (profileImage.value != null) {
      return profileImage.value!.path;
    }
    if (profileImageUrl.value.isNotEmpty) {
      return profileImageUrl.value;
    }
    return 'https://i.pravatar.cc/300?img=12';
  }

  // Check if profile is loaded
  bool get hasProfile => profile.value != null;

  // Get formatted profile data for display
  Map<String, String> get formattedProfileData {
    if (profile.value == null) return {};

    final p = profile.value!;
    return {
      'Name': p.fullName,
      'Email': p.email,
      'Phone': p.phone,
      'Gender': p.formattedGender,
      'Date of Birth': p.formattedDob ?? 'Not set',
      'PIN Code': p.pinCode ?? 'Not set',
      'Address': p.address ?? 'Not set',
      'Email Verified': p.isEmailVerifiedBool ? 'Yes' : 'No',
      'Phone Verified': p.isPhoneVerifiedBool ? 'Yes' : 'No',
    };
  }
}