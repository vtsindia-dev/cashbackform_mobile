import 'package:cashback_farms/common/colours.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
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
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final List<TextEditingController> _otpControllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(6, (index) => FocusNode());
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
          child: Focus(
            onFocusChange: (hasFocus) {
              setState(() {});
            },
            child: TextField(
              controller: phoneController,
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
                    size: 16,
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
                            // Add navigation to Terms & Conditions
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
                            // Add navigation to Privacy Policy
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
              if (phoneController.text.length == 10) {
                authController.sendOtp(phoneController.text);
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (index) {
            return SizedBox(
              width: 45,
              height: 55,
              child: TextField(
                controller: _otpControllers[index],
                focusNode: _otpFocusNodes[index],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 1,
                cursorColor: AppColor.primary,
                decoration: InputDecoration(
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColor.primary, width: 2),
                  ),
                ),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                onChanged: (value) {
                  if (value.length == 1) {
                    if (index < 5) {
                      FocusScope.of(context).requestFocus(_otpFocusNodes[index + 1]);
                    } else {
                      FocusScope.of(context).unfocus();
                    }
                    _updateOtpController();
                  } else if (value.isEmpty) {
                    if (index > 0) {
                      FocusScope.of(context).requestFocus(_otpFocusNodes[index - 1]);
                    }
                    _updateOtpController();
                  }
                },
              ),
            );
          }),
        ),

        // Auto-fill OTP display
        Obx(() => authController.autoFilledOtp.value.isNotEmpty
            ? Column(
          children: [
            SizedBox(height: 15),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColor.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColor.primary),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Auto-detected OTP: ${authController.autoFilledOtp.value}',
                    style: TextStyle(
                      color: AppColor.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _fillAutoDetectedOtp(authController.autoFilledOtp.value);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primary,
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    ),
                    child: Text(
                      'Use This',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
          ],
        )
            : SizedBox()),

        SizedBox(height: 20),
        Obx(() => authController.canResend.value
            ? TextButton(
          onPressed: () {
            authController.resendOtp();
            _clearOtpBoxes();
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
              String enteredOtp = _getOtpFromBoxes();
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
            phoneController.clear();
            _clearOtpBoxes();
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
  void _updateOtpController() {
    String otp = '';
    for (int i = 0; i < 6; i++) {
      otp += _otpControllers[i].text;
    }
    otpController.text = otp;
  }

  String _getOtpFromBoxes() {
    String otp = '';
    for (int i = 0; i < 6; i++) {
      otp += _otpControllers[i].text;
    }
    return otp;
  }

  void _clearOtpBoxes() {
    for (int i = 0; i < 6; i++) {
      _otpControllers[i].clear();
    }
    otpController.clear();
    FocusScope.of(context).requestFocus(_otpFocusNodes[0]);
  }

  void _fillAutoDetectedOtp(String autoOtp) {
    if (autoOtp.length == 6) {
      for (int i = 0; i < 6; i++) {
        _otpControllers[i].text = autoOtp[i];
      }
      _updateOtpController();
      FocusScope.of(context).unfocus();
    }
  }
  @override
  void initState() {
    super.initState();
    ever(authController.isOtpSent, (value) {
      if (value == true) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          FocusScope.of(context).requestFocus(_otpFocusNodes[0]);
        });
      }
    });

    ever(authController.autoFilledOtp, (String autoOtp) {
      if (autoOtp.isNotEmpty && autoOtp.length == 6) {
        _fillAutoDetectedOtp(autoOtp);
      }
    });
  }
  @override
  void dispose() {
    phoneController.dispose();
    otpController.dispose();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _otpFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }
}