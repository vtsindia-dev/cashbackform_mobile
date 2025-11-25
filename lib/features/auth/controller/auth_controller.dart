import 'dart:async';
import 'package:get/get.dart';
import '../../../common/widget/toster.dart';

class AuthController extends GetxController {
  var phoneNumber = ''.obs;
  var otp = ''.obs;
  var isOtpSent = false.obs;
  var isLoading = false.obs;
  var countdown = 60.obs;
  var canResend = false.obs;

  Future<void> sendOtp(String phone) async {
    try {
      isLoading(true);
      phoneNumber.value = phone;
      await Future.delayed(Duration(seconds: 2));

      isOtpSent(true);
      startResendTimer();

      SnackBarHelper.showSuccess('OTP sent successfully');
    } finally {
      isLoading(false);
    }
  }

  Future<void> verifyOtp(String enteredOtp) async {
    try {
      isLoading(true);
      await Future.delayed(Duration(seconds: 2));

      if (enteredOtp == '123456') {
        SnackBarHelper.showSuccess('OTP verified successfully');
        await Future.delayed(Duration(milliseconds: 500)); // Small delay for toast
        Get.offAllNamed('/dashboard'); // Navigate to dashboard
        reset();
      } else {
        SnackBarHelper.showError('Invalid OTP');
      }
    } catch (e) {
      SnackBarHelper.showError('OTP verification failed');
    } finally {
      isLoading(false);
    }
  }

  Future<void> resendOtp() async {
    if (canResend.value) {
      await sendOtp(phoneNumber.value);
    }
  }

  void startResendTimer() {
    countdown.value = 60;
    canResend(false);

    Timer.periodic(Duration(seconds: 1), (timer) {
      if (countdown.value > 0) {
        countdown.value--;
      } else {
        canResend(true);
        timer.cancel();
      }
    });
  }

  void reset() {
    phoneNumber.value = '';
    otp.value = '';
    isOtpSent.value = false;
    isLoading.value = false;
    countdown.value = 60;
    canResend.value = false;
  }
}