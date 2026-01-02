import 'package:cashback_farms/common/colours.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import '../../../common/images.dart';
import '../../../common/widget/toster.dart';
import '../controller/auth_controller.dart';
import 'package:flutter/gestures.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}
class _LoginState extends State<Login> {
  final AuthController authController = Get.put(AuthController());
  bool isTermsAccepted = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(Images.loginBackground),
                  fit: BoxFit.cover
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.65,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black38,
                    blurRadius: 4,
                    spreadRadius: 2,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Obx(() => authController.isOtpSent.value
                    ? _buildOtpScreen()
                    : _buildPhoneScreen()
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildPhoneScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Column(
          children: [
            Image.asset(
              Images.logo,
              width: 110,
              height: 110,
              fit: BoxFit.contain,
            ),
          ],
        ),
        Text(
          'Enter Phone Number',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColor.primary,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'We will send you a 6-digit OTP',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        SizedBox(height: 20),
        Container(
          height: 55,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.shade300,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: authController.phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: Icon(Icons.phone, color: AppColor.primary),
                    prefixText: '+91 ',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                    labelStyle: TextStyle(color: AppColor.primary),
                    isDense: true,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ElevatedButton(
                  onPressed: () {
                    authController.getPhoneNumberHint();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary,
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Auto-fill',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10),
        Text(
          'Tap "Auto-fill" to use your device\'s phone number',
          style: TextStyle(
            fontSize: 12,
            color: Colors.black,
            fontStyle: FontStyle.italic,
          ),
        ),

        SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  isTermsAccepted = !isTermsAccepted;
                });
              },
              child: Container(
                width: 15,
                height: 15,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColor.primary,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(4),
                  color: isTermsAccepted ? AppColor.primary : Colors.white,
                ),
                child: isTermsAccepted
                    ? Align(
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.check,
                    size: 10,
                    color: Colors.white,
                  ),
                )
                    : null,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: RichText(
                  text: TextSpan(
                    text: "By continuing, you agree to our ",
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 13,
                      fontFamily: GoogleFonts.montserrat().fontFamily,
                    ),
                    children: [
                      TextSpan(
                        text: "Terms & Conditions",
                        style: TextStyle(
                          color: AppColor.primary,
                          fontWeight: FontWeight.bold,
                          fontFamily: GoogleFonts.montserrat().fontFamily,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                          },
                      ),
                      TextSpan(text: " and "),
                      TextSpan(
                        text: "Privacy Policy",
                        style: TextStyle(
                          color: AppColor.primary,
                          fontWeight: FontWeight.bold,
                          fontFamily: GoogleFonts.montserrat().fontFamily,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                          },
                      ),
                      TextSpan(text: "."),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: authController.isLoading.value
                ? null
                : () {
              if (!isTermsAccepted) {
                SnackBarHelper.showError("Please accept Terms & Conditions");
                return;
              }
              String phone = authController.phoneController.text.trim();
              if (phone.length == 10) {
                authController.sendOtp(phone);
              } else {
                SnackBarHelper.showError('Please enter valid phone number');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: authController.isLoading.value
                ? CircularProgressIndicator(color: Colors.white)
                : Text(
              'Send OTP',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
  Widget _buildOtpScreen() {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: TextStyle(
        fontSize: 20,
        color: Color.fromRGBO(30, 60, 87, 1),
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Color.fromRGBO(234, 239, 243, 1)),
        borderRadius: BorderRadius.circular(12),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: AppColor.primary),
      borderRadius: BorderRadius.circular(12),
    );
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Enter OTP',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColor.primary,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Sent to +91 ${authController.phoneNumber.value}',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        SizedBox(height: 40),
        Pinput(
          length: 6,
          controller: authController.otpController,
          defaultPinTheme: defaultPinTheme,
          focusedPinTheme: focusedPinTheme,
          showCursor: true,
          onCompleted: (pin) {
            authController.verifyOtp(pin);
          },
        ),
        SizedBox(height: 20),
        Obx(() => authController.canResend.value
            ? TextButton(
          onPressed: () {
            authController.resendOtp();
          },
          child: Text(
            'Resend OTP',
            style: TextStyle(
              color: AppColor.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        )
            : Text(
          'Resend OTP in ${authController.countdown.value}s',
          style: TextStyle(
            color: AppColor.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        ),
        SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: authController.isLoading.value
                ? null
                : () {
              String enteredOtp = authController.otpController.text;
              if (enteredOtp.length == 6) {
                authController.verifyOtp(enteredOtp);
              } else {
                SnackBarHelper.showError('Please enter 6-digit OTP');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: authController.isLoading.value
                ? CircularProgressIndicator(color: Colors.white)
                : Text(
              'Verify OTP',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(height: 20),
        TextButton(
          onPressed: () {
            authController.reset();
          },
          child: Text(
            'Change Phone Number',
            style: TextStyle(
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
  @override
  void dispose() {
    super.dispose();
  }
}