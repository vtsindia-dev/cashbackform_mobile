// lib/features/contact/view/contact_us_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../common/widget/appbar.dart';
import '../../../common/widget/toster.dart';
import '../controller/dashboard_menu_controller.dart';

class ContactUsScreen extends StatelessWidget {
  ContactUsScreen({super.key});

  final DashboardController controller = Get.put(DashboardController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DynamicAppBar(
        title: "Contact Us",
        showBackButton: true,
      ),
      backgroundColor: const Color(0xFFF9FBF9),
      body: Stack(
        children: [
          _buildBackgroundDecorations(),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  SizedBox(height: 40.h),
                  Text(
                    "Get In Touch With Us",
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2),
                  SizedBox(height: 30.h),

                  // Top Action Buttons Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _contactActionCard(
                        "Make a Call",
                        Icons.phone_in_talk,
                        const Color(0xFFFBB03B),
                        onTap: () => _makePhoneCall(),
                      ),
                      _contactActionCard(
                        "Make a Chat",
                        Icons.chat_bubble_outline,
                        const Color(0xFFFBB03B),
                        onTap: () => _openWhatsApp(),
                      ),
                      _contactActionCard(
                        "Write a Mail",
                        Icons.mail_outline,
                        const Color(0xFFFBB03B),
                        onTap: () => _sendEmail(),
                      ),
                    ],
                  ).animate().fadeIn(delay: 200.ms).scale(curve: Curves.easeOutBack),
                  SizedBox(height: 30.h),

                  // The Main Contact Form
                  _buildContactForm(),
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),
          Obx(() => controller.isLoadingContact.value
              ? Container(
            color: Colors.black.withOpacity(0.3),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          )
              : const SizedBox()),
        ],
      ),
    );
  }

  Widget _contactActionCard(String title, IconData icon, Color color, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 105.w,
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 20.sp),
            SizedBox(height: 4.h),
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactForm() {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _customFirstNameField()),
              SizedBox(width: 15.w),
              Expanded(child: _customLastNameField()),
            ],
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(child: _customEmailField()),
              SizedBox(width: 15.w),
              Expanded(child: _customPhoneField()),
            ],
          ),
          SizedBox(height: 20.h),
          _customRequirementField(),
          // SizedBox(height: 20.h),
          // _customMessageField(),
          SizedBox(height: 30.h),

          // Submit Button
          Obx(() => SizedBox(
            width: double.infinity,
            height: 50.h,
            child: ElevatedButton(
              onPressed: controller.isLoadingContact.value ? null : () => controller.submitContactForm(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8DB600),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                elevation: 0,
                disabledBackgroundColor: Colors.grey[400],
              ),
              child: controller.isLoadingContact.value
                  ? SizedBox(
                width: 20.w,
                height: 20.h,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : Text(
                "Submit",
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          )),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1);
  }

  Widget _customFirstNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "First Name",
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          onChanged: controller.updateFirstName,
          decoration: InputDecoration(
            hintText: "First Name",
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 13.sp,
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 15.w,
              vertical: 12.h,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: Color(0xFF8DB600)),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }

  Widget _customLastNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Last Name",
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          onChanged: controller.updateLastName,
          decoration: InputDecoration(
            hintText: "Last Name",
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 13.sp,
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 15.w,
              vertical: 12.h,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: Color(0xFF8DB600)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _customEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Email",
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          onChanged: controller.updateEmail,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: "Email",
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 13.sp,
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 15.w,
              vertical: 12.h,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: Color(0xFF8DB600)),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }

  Widget _customPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Phone",
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          onChanged: controller.updatePhone,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            hintText: "Phone",
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 13.sp,
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 15.w,
              vertical: 12.h,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: Color(0xFF8DB600)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _customRequirementField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Requirement (Optional)",
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          onChanged: controller.updateRequirement,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: "Type your requirements...",
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 13.sp,
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 15.w,
              vertical: 12.h,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: Color(0xFF8DB600)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _customMessageField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Message",
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          onChanged: controller.updateMessage,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: "Type your message...",
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 13.sp,
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 15.w,
              vertical: 12.h,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: Color(0xFF8DB600)),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBackgroundDecorations() {
    return Stack(
      children: [
        Positioned(
          top: -50,
          right: -50,
          child: _blob(200, const Color(0xFFE8F5E9)),
        ),
        Positioned(
          bottom: 100,
          left: -40,
          child: _blob(150, const Color(0xFFFFF3E0)),
        ),
      ],
    );
  }

  Widget _blob(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    ).animate(onPlay: (controller) => controller.repeat(reverse: true)).moveY(
      begin: 0,
      end: 20,
      curve: Curves.easeInOut,
    );
  }

  // Action methods for buttons
  Future<void> _makePhoneCall() async {
    // You can fetch the business phone from settings API
    const phoneNumber = 'tel:+9174347'; // Use business phone from settings
    if (await canLaunchUrl(Uri.parse(phoneNumber))) {
      await launchUrl(Uri.parse(phoneNumber));
    } else {
      SnackBarHelper.showError('Could not launch phone app');
    }
  }

  Future<void> _openWhatsApp() async {
    // You can fetch WhatsApp number from settings API
    const whatsappNumber = 'https://wa.me/9685741235'; // Use WhatsApp from settings
    if (await canLaunchUrl(Uri.parse(whatsappNumber))) {
      await launchUrl(Uri.parse(whatsappNumber));
    } else {
      SnackBarHelper.showError('Could not launch WhatsApp');
    }
  }

  Future<void> _sendEmail() async {
    // You can fetch business email from settings API
    final emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'Test@gmail.com', // Use business email from settings
      queryParameters: {'subject': 'Contact Inquiry'},
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      SnackBarHelper.showError('Could not launch email app');
    }
  }
}