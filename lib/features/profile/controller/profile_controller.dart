// profile_controller.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../common/api_constant.dart';
import '../../../common/widget/api_service.dart';
import '../../../common/widget/sessionhandler.dart';
import '../../../common/widget/toster.dart';
import '../../auth/models/location_model.dart';
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
  var selectedGender = 0.obs;
  final ImagePicker _picker = ImagePicker();
  var profileImage = Rxn<File>();
  var profileImageUrl = ''.obs;
  final referralCodeController = TextEditingController();
  var isReferralCodeEditable = true.obs;
  List<CountryModel> countries = [];
  List<StateModel> states = [];
  List<CityModel> cities = [];
  bool isstateLoading = false;
  bool isCityoading = false;

  CountryModel? selectedCountry;
  StateModel? selectedState;
  CityModel? selectedCity;

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
    referralCodeController.dispose(); // Add this line
    super.onClose();
  }

  final RxBool isRemovingImage = false.obs;

  Future<void> removeProfileImage() async {
    if (isRemovingImage.value) return;

    try {
      isRemovingImage(true);

      final token = await SessionManager.getToken();

      final response = await dio.Dio().post(
        "http://admincashback.vrikshatech.in/public/api/v2/profile-image-remove",
        options: dio.Options(
          headers: {
            "Accept": "application/json",
            if (token != null && token.isNotEmpty)
              "Authorization": "Bearer $token",
          },
        ),
      );

      if (response.statusCode == 200 &&
          response.data?['status'] == 200) {

        final message =
            response.data?['message'] ?? 'Profile image removed';

        SnackBarHelper.showSuccess(message);
        await fetchProfile();

        // Optional: refresh profile data
        update();
      } else {
        final errorMessage =
            response.data?['message'] ?? 'Failed to remove profile image';
        SnackBarHelper.showError(errorMessage);
      }
    } catch (e) {
      SnackBarHelper.showError('Network error. Please try again.');
      print('❌ Remove profile image error: $e');
    } finally {
      isRemovingImage(false);
    }
  }

  Future<void> loadEditProfile(ProfileModel profile) async {

    /// Countries
    await fetchCountries();

    selectedCountry =
        countries.firstWhereOrNull((c) => c.id == profile.countryId);

    update();

    /// States
    if (profile.countryId != null) {
      await fetchStates(profile.countryId!);

      selectedState =
          states.firstWhereOrNull((s) => s.id == profile.stateId);

      update();
    }

    /// Cities
    if (profile.stateId != null) {
      await fetchCity(profile.stateId!);

      selectedCity =
          cities.firstWhereOrNull((c) => c.id == profile.cityId);

      update();
    }
  }

  Future<void> fetchCountries() async {
    final countryresponse = await ApiService.getRequest(ApiUrl.countryUrl);

    if (countryresponse.statusCode == 200) {
      CountryResponse response =
      CountryResponse.fromJson(countryresponse.data);

      countries = response.data;
      update();
    } else {
      SnackBarHelper.showError("Failed to fetch countries");
    }
  }

  Future<void> fetchStates(int countryId) async {
    isstateLoading = true;
    update();

    final stateResponse =
    await ApiService.getRequest("${ApiUrl.stateUrl}?country_id=$countryId");

    print("state -- $stateResponse");

    if (stateResponse.statusCode == 200) {
      StateResponse response = StateResponse.fromJson(stateResponse.data);
      states = response.data;
    } else {
      states = [];
    }

    isstateLoading = false;
    update();
  }

  Future<void> fetchCity(int stateId) async {

    isCityoading = true;
    update();

    final cityRespose =
    await ApiService.getRequest("${ApiUrl.cityUrl}?state_id=$stateId");

    if (cityRespose.statusCode == 200) {
      CityResponse response = CityResponse.fromJson(cityRespose.data);
      cities = response.data;
    } else {
      cities = [];
    }

    isCityoading = false;
    update();
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
        print(responseData);
        if (responseData != null && responseData['data'] != null) {
          profile.value = ProfileModel.fromJson(responseData['data']);
          loadEditProfile(profile.value!);
          _prefillFormData();
          print('✅ Profile data loaded successfully');
          print(responseData);
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
        'country_id': selectedCountry?.id,
        'state_id': selectedState?.id,
        'city_id': selectedCity?.id,
      };

      if (isReferralCodeEditable.value && referralCodeController.text.trim().isNotEmpty) {
        formData['reference_id'] = referralCodeController.text.trim().toUpperCase();
      }
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
  }  Future<void> pickProfileImage() async {
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
  void _prefillFormData() {
    if (profile.value == null) return;
    final p = profile.value!;

    Future.microtask(() {
      firstNameController.text = p.firstName;
      lastNameController.text = p.lastName;
      emailController.text = p.email;
      phoneController.text = p.phone;
      selectedGender.value = p.gender;
      dobController.text = p.dob ?? '';
      pinCodeController.text = p.pinCode ?? '';
      addressController.text = p.address ?? '';
      profileImageUrl.value = p.profileImage ?? '';

      referralCodeController.text = ''; // always blank — user types fresh

      // Editable only when not referred by a real user
      final refId = p.referenceId;
      final referId = p.refer?.id;
      final isNotReferred =
          (refId == null || refId == 1) && (referId == null || referId == 1);
      isReferralCodeEditable.value = isNotReferred;
    });
  }  // void _prefillFormData() {
  //   if (profile.value != null) {
  //     final p = profile.value!;
  //     firstNameController.text = p.firstName;
  //     lastNameController.text = p.lastName;
  //     emailController.text = p.email;
  //     phoneController.text = p.phone;
  //     selectedGender.value = p.gender;
  //     dobController.text = p.dob ?? '';
  //     pinCodeController.text = p.pinCode ?? '';
  //     addressController.text = p.address ?? '';
  //     profileImageUrl.value = p.profileImage ?? '';
  //   }
  // }

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
    if (dobController.text.trim().isEmpty) {
      SnackBarHelper.showError('Please enter date of birth');
      return false;
    }
    if(selectedCountry == null)
      {
        SnackBarHelper.showError('Please select country');
        return false;
      }
    if(selectedState == null)
      {
        SnackBarHelper.showError('Please select state');
        return false;
      }
    if(selectedCity == null)
      {
        SnackBarHelper.showError('Please select city');
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
      'Date of Birth': p.dob ?? 'Not set',
      'PIN Code': p.pinCode ?? 'Not set',
      'Address': p.address ?? 'Not set',
      'Email Verified': p.isEmailVerifiedBool ? 'Yes' : 'No',
      'Phone Verified': p.isPhoneVerifiedBool ? 'Yes' : 'No',
    };
  }
}