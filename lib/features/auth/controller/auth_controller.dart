import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:permission_handler/permission_handler.dart';
import 'package:sms_autofill/sms_autofill.dart';
import '../../../common/api_constant.dart';
import '../../../common/route/router.dart';
import '../../../common/widget/api_service.dart';
import '../../../common/widget/sessionhandler.dart';
import '../../../common/widget/toster.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
class AuthController extends GetxController with CodeAutoFill {
  var phoneNumber = ''.obs;
  var isOtpSent = false.obs;
  var isLoading = false.obs;
  var countdown = 60.obs;
  var canResend = false.obs;
  var serverOtp = ''.obs;
  var selectedGender = 1.obs;
  var selectedRole = 1.obs;
  var selectedImage = Rxn<File>();
  var hoveredGender = (-1).obs;
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController pinCodeController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  String? appSignature;
  String? code;
  RxBool hasShownPhoneHint = false.obs;
  final ImagePicker _picker = ImagePicker();
  @override
  void onInit() {
    super.onInit();
    _getAppSignature();
    _checkPermissions();
    listenForCode();
  }
  @override
  void codeUpdated() {
    code = this.code;
    print("CODE UPDATED: $code");
    if (code != null && code!.length == 6) {
      print("Auto-filling OTP: $code");
      otpController.text = code!;
      if (code == serverOtp.value) {
        verifyOtp(code!);
      }
    }
  }
  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );
      if (image != null) {
        selectedImage.value = File(image.path);
      }
    } catch (e) {
      SnackBarHelper.showError("Failed to pick image: $e");
    }
  }
  Future<void> getPhoneNumberHint() async {
    try {
      print('Requesting phone number hint...');

      // Check phone permission
      var phoneStatus = await Permission.phone.status;
      if (!phoneStatus.isGranted) {
        phoneStatus = await Permission.phone.request();
        if (!phoneStatus.isGranted) {
          SnackBarHelper.showError("Phone permission required for auto-fill");
          return;
        }
      }

      // Request phone number hint
      String? phoneNumber = await SmsAutoFill().hint;
      print('Phone hint result: $phoneNumber');

      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        String processedNumber = _processPhoneNumber(phoneNumber);
        if (processedNumber.isNotEmpty) {
          phoneController.text = processedNumber;
          SnackBarHelper.showSuccess("Phone number auto-filled!");
          print('Auto-filled phone number: $processedNumber');
        } else {
          SnackBarHelper.showInfo("Could not extract valid phone number");
        }
      } else {
        SnackBarHelper.showInfo("No phone number found for auto-fill");
      }
    } catch (e) {
      debugPrint("Failed to get phone hint: $e");
      SnackBarHelper.showError("Auto-fill not available");
    }
  }  String _processPhoneNumber(String phoneHint) {
    try {
      print('Raw phone hint: $phoneHint');
      String digitsOnly = phoneHint.replaceAll(RegExp(r'[^\d+]'), '');
      print('Digits only: $digitsOnly');
      if (digitsOnly.startsWith('+91')) {
        String number = digitsOnly.substring(3);
        return number.length == 10 ? number : '';
      } else if (digitsOnly.startsWith('91') && digitsOnly.length > 10) {
        String number = digitsOnly.substring(2);
        return number.length == 10 ? number : '';
      } else if (digitsOnly.length == 10) {
        return digitsOnly;
      } else if (digitsOnly.length > 10) {
        return digitsOnly.substring(digitsOnly.length - 10);
      }
      return '';
    } catch (e) {
      print('Error processing phone number: $e');
      return '';
    }
  }
  Future<void> _checkPermissions() async {
    try {
      var smsStatus = await Permission.sms.status;
      print("SMS Permission Status: $smsStatus");

      if (!smsStatus.isGranted) {
        smsStatus = await Permission.sms.request();
        print("SMS Permission after request: $smsStatus");
      }
      var phoneStatus = await Permission.phone.status;
      print("Phone Permission Status: $phoneStatus");

    } catch (e) {
      print("Permission check error: $e");
    }
  }
  Future<void> _getAppSignature() async {
    try {
      appSignature = await SmsAutoFill().getAppSignature;
      print("=== APP SIGNATURE ===");
      print(appSignature);
      print("=== END SIGNATURE ===");
    } catch (e) {
      print("Error getting app signature: $e");
    }
  }
  Future<void> sendOtp(String phone) async {
    try {
      isLoading(true);
      phoneNumber.value = phone;

      final response = await ApiService.postRequest(
        ApiUrl.otp,
        {
          "phone": phone,
          "key_id": appSignature ?? '',
        },
      );
      if (response.statusCode == 200) {
        final responseData = response.data;
        serverOtp.value = responseData['otp']?.toString() ?? '';
        print("SERVER OTP: ${serverOtp.value}");

        isOtpSent(true);
        startResendTimer();
        SnackBarHelper.showSuccess("OTP sent successfully");
      } else {
        SnackBarHelper.showError("Failed to send OTP");
      }
    } catch (e) {
      SnackBarHelper.showError("Error: $e");
    } finally {
      isLoading(false);
    }
  }
// In your AuthController verifyOtp method
  Future<void> verifyOtp(String otp) async {
    try {
      isLoading(true);
      print("Verifying OTP: $otp");

      if (otp == serverOtp.value) {
        SnackBarHelper.showSuccess("OTP verified successfully!");

        final loginResponse = await ApiService.postRequest(
          ApiUrl.login,
          {
            "phone": phoneNumber.value,
            "otp": otp,
          },
        );

        print("=== FULL LOGIN RESPONSE ===");
        print("Status: ${loginResponse.statusCode}");
        print("Data: ${loginResponse.data}");
        print("=== END RESPONSE ===");

        if (loginResponse.statusCode == 200) {
          final responseData = loginResponse.data;

          // Check different possible response structures
          Map<String, dynamic>? userData;
          String? token;

          if (responseData['data'] != null) {
            // Structure: {data: {user: {...}, token: '...'}}
            userData = responseData['data']['user'];
            token = responseData['data']['token'];
          } else {
            // Structure: {user: {...}, token: '...'}
            userData = responseData['user'];
            token = responseData['token'];
          }

          // Alternative token field names
          token ??= responseData['access_token'];
          token ??= responseData['auth_token'];

          if (userData == null || token == null) {
            print('❌ ERROR: Could not extract user data or token');
            print('   Available keys: ${responseData.keys}');
            SnackBarHelper.showError("Invalid response from server");
            return;
          }

          print('✅ Extracted user data: $userData');
          print('✅ Extracted token: ${token.substring(0, min(token.length, 20))}...');

          // Save session
          await SessionManager.saveUserSession(userData, token: token);

          // Verify token was saved
          final savedToken = await SessionManager.getToken();
          if (savedToken != null && savedToken.isNotEmpty) {
            SnackBarHelper.showSuccess("Login Successful!");
            await cancel();
            Get.offAllNamed('/dashboard');
            reset();
          } else {
            print('❌ ERROR: Token was not saved!');
            SnackBarHelper.showError("Failed to save session");
          }
        } else if (loginResponse.statusCode == 404) {
          SnackBarHelper.showInfo("New user! Redirecting to registration...");
          await cancel();
          Get.toNamed('/register', arguments: {"phone": phoneNumber .value});
        } else {
          SnackBarHelper.showError("Login failed");
        }
      } else {
        SnackBarHelper.showError("Invalid OTP");
      }
    } catch (e) {
      SnackBarHelper.showError("Error verifying OTP: $e");
      print('OTP verification error: $e');
    } finally {
      isLoading(false);
    }
  }  Future<void> register() async {
    try {
      if (!_validateForm()) return;

      isLoading(true);

      var formData = dio.FormData.fromMap({
        'first_name': firstNameController.text.trim(),
        'last_name': lastNameController.text.trim(),
        'phone': phoneController.text.trim(),
        'email': emailController.text.trim(),
        'gender': selectedGender.value,
        'role': selectedRole.value,
        'dob': dobController.text.trim(),
        'pin_code': pinCodeController.text.trim(),
        'address': addressController.text.trim(),
      });

      if (selectedImage.value != null) {
        formData.files.add(MapEntry(
          'image',
          await dio.MultipartFile.fromFile(
            selectedImage.value!.path,
            filename: 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
          ),
        ));
      }

      final response = await ApiService.postMultipart(
        ApiUrl.register,
        formData,
      );

      print('Registration Response Status: ${response.statusCode}');
      print('Registration Response Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        SnackBarHelper.showSuccess("Registration successful!");

        final userData = response.data['data']['user'];
        final token = response.data['data']['token'];

        print('Extracted User Data: $userData');
        print('Token: $token');

        await SessionManager.saveUserSession(userData, token: token);

        final isLoggedIn = await SessionManager.isLoggedIn();
        print('After registration - isLoggedIn: $isLoggedIn');

        if (isLoggedIn) {
          Get.offAllNamed(AppRoutes.dashboard);
        } else {
          SnackBarHelper.showError("Session not saved properly");
          Get.offAllNamed(AppRoutes.login);
        }
      } else {
        SnackBarHelper.showError(
            response.data["message"] ?? "Registration failed");
      }
    } catch (e) {
      SnackBarHelper.showError("Error during registration: $e");
      print('Registration error: $e');
    } finally {
      isLoading(false);
    }
  }

  bool _validateForm() {
    if (firstNameController.text.isEmpty) {
      SnackBarHelper.showError("Please enter first name");
      return false;
    }
    if (lastNameController.text.isEmpty) {
      SnackBarHelper.showError("Please enter last name");
      return false;
    }
    if (phoneController.text.length != 10) {
      SnackBarHelper.showError("Please enter valid 10-digit phone number");
      return false;
    }
    if (emailController.text.isEmpty || !emailController.text.contains('@')) {
      SnackBarHelper.showError("Please enter valid email");
      return false;
    }
    if (dobController.text.isEmpty) {
      SnackBarHelper.showError("Please select date of birth");
      return false;
    }
    if (pinCodeController.text.length != 6) {
      SnackBarHelper.showError("Please enter valid 6-digit PIN code");
      return false;
    }
    if (addressController.text.isEmpty) {
      SnackBarHelper.showError("Please enter address");
      return false;
    }
    if (selectedImage.value == null) {
      SnackBarHelper.showError("Please select a profile image");
      return false;
    }
    return true;
  }
  Future<void> resendOtp() async {
    if (canResend.value) {
      print("Resending OTP...");
      await sendOtp(phoneNumber.value);
    }
  }

  void startResendTimer() {
    countdown.value = 60;
    canResend(false);

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown.value > 0) {
        countdown.value--;
      } else {
        canResend(true);
        timer.cancel();
      }
    });
  }

  @override
  Future<void> cancel() async {
    try {
      await SmsAutoFill().unregisterListener();
      print("SMS listener cancelled");
    } catch (e) {
      print("Error during cleanup: $e");
    }
  }

  void reset() {
    phoneNumber.value = "";
    isOtpSent.value = false;
    countdown.value = 60;
    canResend.value = false;
    serverOtp.value = "";
    code = null;
    phoneController.clear();
    otpController.clear();
    hasShownPhoneHint.value = false;
  }
  void setDateOfBirth(DateTime date) {
    dobController.text = "${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}";
  }
  @override
  void onClose() {
    cancel();
    phoneController.dispose();
    otpController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    pinCodeController.dispose();
    addressController.dispose();
    dobController.dispose();
    super.onClose();
  }
}