import 'dart:async';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:permission_handler/permission_handler.dart';
import 'package:sms_autofill/sms_autofill.dart';
import '../../../common/api_constant.dart';
import '../../../common/widget/api_service.dart';
import '../../../common/widget/toster.dart';

class AuthController extends GetxController {
  var phoneNumber = ''.obs;
  var isOtpSent = false.obs;
  var isLoading = false.obs;
  var countdown = 60.obs;
  var canResend = false.obs;
  var serverOtp = ''.obs;
  var autoFilledOtp = ''.obs;
  StreamSubscription<String>? _otpSubscription;
  String? _appSignature;

  @override
  void onInit() {
    super.onInit();
    _getAppSignature();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    try {
      var smsStatus = await Permission.sms.status;
      print("SMS Permission Status: $smsStatus");

      if (!smsStatus.isGranted) {
        smsStatus = await Permission.sms.request();
        print("SMS Permission after request: $smsStatus");
      }
    } catch (e) {
      print("Permission check error: $e");
    }
  }
  Future<void> _getAppSignature() async {
    try {
      _appSignature = await SmsAutoFill().getAppSignature;
      print("=== APP SIGNATURE ===");
      print(_appSignature);
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
        {"phone": phone},
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        serverOtp.value = responseData['otp']?.toString() ?? '';
        print("SERVER OTP: ${serverOtp.value}");

        isOtpSent(true);

        await _startSmsListener();

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


  Future<void> _startSmsListener() async {
    try {

      _otpSubscription?.cancel();

      print("Starting SMS listener...");

      _otpSubscription = SmsAutoFill().code.listen(
            (receivedCode) {
          print("SMS LISTENER TRIGGERED - Received code: $receivedCode");
          if (receivedCode.isNotEmpty) {
            autoFilledOtp.value = receivedCode;
            print("AUTO FILLED OTP: $receivedCode");

            if (receivedCode == serverOtp.value) {
              print("OTP MATCHED! Auto-verifying...");
              verifyOtp(receivedCode);
            } else {
              print("OTP MISMATCH: Received $receivedCode, Expected ${serverOtp.value}");
            }
          }
        },
        onError: (error) {
          print("SMS Listener Error: $error");
        },
        onDone: () {
          print("SMS Listener Done");
        },
        cancelOnError: false,
      );

      print("SMS listener started successfully");

      await _tryManualSmsRetrieval();

    } catch (e) {
      print("Error starting SMS listener: $e");
    }
  }

  Future<void> _tryManualSmsRetrieval() async {
    try {
      print("Trying manual SMS retrieval...");
      await SmsAutoFill().listenForCode;
      print("Manual SMS retrieval initiated");
    } catch (e) {
      print("Manual SMS retrieval error: $e");
    }
  }

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

        if (loginResponse.statusCode == 200) {
          SnackBarHelper.showSuccess("Login Successful!");
          cancel();
          Get.offAllNamed('/dashboard');
          reset();
        } else if (loginResponse.statusCode == 404 &&
            loginResponse.data["message"] == "User not found") {
          SnackBarHelper.showError("User not found! Redirecting...");
          cancel();
          await Future.delayed(const Duration(seconds: 1));
          Get.toNamed('/register', arguments: {"phone": phoneNumber.value});
        } else {
          SnackBarHelper.showError(
              loginResponse.data["message"] ?? "Login failed");
        }
      } else {
        SnackBarHelper.showError("Invalid OTP");
      }
    } catch (e) {
      SnackBarHelper.showError("Error verifying OTP: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> resendOtp() async {
    if (canResend.value) {
      print("Resending OTP...");
      await _startSmsListener();
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
  Future<void> manuallyCheckForSms() async {
    try {
      print("Manually checking for SMS...");
      await _tryManualSmsRetrieval();
      SnackBarHelper.showSuccess("Checking for SMS...");
    } catch (e) {
      print("Manual check error: $e");
    }
  }

  void cancel() {
    try {
      _otpSubscription?.cancel();
      SmsAutoFill().unregisterListener();
      print("SMS listeners cancelled");
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
    autoFilledOtp.value = "";
    cancel();
  }

  @override
  void onClose() {
    cancel();
    super.onClose();
  }
}