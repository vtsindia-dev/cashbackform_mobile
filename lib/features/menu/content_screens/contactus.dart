import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../common/widget/appbar.dart';
import '../../../common/widget/toster.dart';
import '../controller/dashboard_menu_controller.dart';
import '../model/dashboard_model.dart';

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
                  Obx(() => Text(
                    "Contact ${controller.businessSettings.value?.businessName ?? 'Geo Rental Farms'}",
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  )).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2),
                  SizedBox(height: 30.h),

                  // Top Action Buttons Row
                  Obx(() {
                    final settings = controller.businessSettings.value;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _contactActionCard(
                          "Make a Call",
                          Icons.phone_in_talk,
                          const Color(0xFFFBB03B),
                          onTap: () => _makePhoneCall(settings),
                          value: settings?.businessPhone?.isNotEmpty == true
                              ? settings?.businessPhone!
                              : "Not available",
                        ),
                        _contactActionCard(
                          "Make a Chat",
                          Icons.chat_bubble_outline,
                          const Color(0xFFFBB03B),
                          onTap: () => _openWhatsApp(settings),
                          value: settings?.whatsapp?.isNotEmpty == true
                              ? settings?.whatsapp!
                              : "Not available",
                        ),
                        _contactActionCard(
                          "Write a Mail",
                          Icons.mail_outline,
                          const Color(0xFFFBB03B),
                          onTap: () => _sendEmail(settings),
                          value: settings?.businessEmail?.isNotEmpty == true
                              ? settings?.businessEmail!
                              : "Not available",
                        ),
                      ],
                    );
                  }).animate().fadeIn(delay: 200.ms).scale(curve: Curves.easeOutBack),

                  SizedBox(height: 30.h),

                  // Business Info Card
                  _buildBusinessInfoCard(),
                  SizedBox(height: 30.h),

                  // The Main Contact Form
                  _buildContactForm(),
                  SizedBox(height: 40.h),

                  // Social Media Links
                  _buildSocialMediaSection(),
                  SizedBox(height: 20.h),
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
          Obx(() => controller.isLoadingSettings.value
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

  // ===============================
  // HELPER METHODS FOR CONTACT ACTIONS
  // ===============================
  Future<void> _makePhoneCall(BusinessSettings? settings) async {
    if (settings?.businessPhone == null || settings!.businessPhone!.isEmpty) {
      SnackBarHelper.showError('Phone number not available');
      return;
    }

    // Clean the phone number
    String phoneNumber = settings.businessPhone!.replaceAll(' ', '');

    // Ensure it has the correct format
    if (!phoneNumber.startsWith('+')) {
      if (phoneNumber.startsWith('91') && phoneNumber.length > 2) {
        phoneNumber = '+$phoneNumber';
      } else {
        phoneNumber = '+91$phoneNumber';
      }
    }

    final phoneUrl = 'tel:$phoneNumber';

    try {
      print('📞 Making call to: $phoneUrl');
      if (await canLaunchUrl(Uri.parse(phoneUrl))) {
        await launchUrl(Uri.parse(phoneUrl));
      } else {
        SnackBarHelper.showError('Could not launch phone app');
      }
    } catch (e) {
      print('❌ Phone call error: $e');
      SnackBarHelper.showError('Unable to make call');
    }
  }

  Future<void> _openWhatsApp(BusinessSettings? settings) async {
    if (settings?.whatsapp == null || settings!.whatsapp!.isEmpty) {
      SnackBarHelper.showError('WhatsApp number not available');
      return;
    }

    // Clean the WhatsApp number
    String whatsapp = settings.whatsapp!.replaceAll(' ', '');

    // Remove any + signs
    if (whatsapp.startsWith('+')) {
      whatsapp = whatsapp.substring(1);
    }

    // Remove any leading 0
    if (whatsapp.startsWith('0')) {
      whatsapp = whatsapp.substring(1);
    }

    final businessName = settings.businessName ?? 'Geo Rental Farms';
    final whatsappUrl = 'https://wa.me/$whatsapp?text=Hello%20${Uri.encodeComponent(businessName)}';

    try {
      print('💬 Opening WhatsApp: $whatsappUrl');
      if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
        await launchUrl(Uri.parse(whatsappUrl));
      } else {
        SnackBarHelper.showError('Could not launch WhatsApp');
      }
    } catch (e) {
      print('❌ WhatsApp error: $e');
      SnackBarHelper.showError('Unable to open WhatsApp');
    }
  }

  Future<void> _sendEmail(BusinessSettings? settings) async {
    if (settings?.businessEmail == null || settings!.businessEmail!.isEmpty) {
      SnackBarHelper.showError('Email address not available');
      return;
    }

    final businessName = settings.businessName ?? 'Geo Rental Farms';
    final emailUrl = Uri(
      scheme: 'mailto',
      path: settings.businessEmail!,
      queryParameters: {
        'subject': 'Contact Inquiry - $businessName',
        'body': 'Hello $businessName,\n\nI would like to inquire about...',
      },
    ).toString();

    try {
      print('📧 Sending email to: ${settings.businessEmail}');
      if (await canLaunchUrl(Uri.parse(emailUrl))) {
        await launchUrl(Uri.parse(emailUrl));
      } else {
        SnackBarHelper.showError('Could not launch email app');
      }
    } catch (e) {
      print('❌ Email error: $e');
      SnackBarHelper.showError('Unable to send email');
    }
  }

  Future<void> _openInstagram(BusinessSettings? settings) async {
    if (settings?.instagram == null || settings!.instagram!.isEmpty) {
      SnackBarHelper.showError('Instagram link not available');
      return;
    }

    try {
      print('📸 Opening Instagram: ${settings.instagram}');
      if (await canLaunchUrl(Uri.parse(settings.instagram!))) {
        await launchUrl(Uri.parse(settings.instagram!));
      } else {
        SnackBarHelper.showError('Could not launch Instagram');
      }
    } catch (e) {
      print('❌ Instagram error: $e');
      SnackBarHelper.showError('Unable to open Instagram');
    }
  }

  Future<void> _openYouTube(BusinessSettings? settings) async {
    if (settings?.youtube == null || settings!.youtube!.isEmpty) {
      SnackBarHelper.showError('YouTube link not available');
      return;
    }

    try {
      print('▶️ Opening YouTube: ${settings.youtube}');
      if (await canLaunchUrl(Uri.parse(settings.youtube!))) {
        await launchUrl(Uri.parse(settings.youtube!));
      } else {
        SnackBarHelper.showError('Could not launch YouTube');
      }
    } catch (e) {
      print('❌ YouTube error: $e');
      SnackBarHelper.showError('Unable to open YouTube');
    }
  }

  // ===============================
  // WIDGET BUILDERS
  // ===============================
  Widget _contactActionCard(
      String title,
      IconData icon,
      Color color, {
        required VoidCallback onTap,
        String? value,
      }) {
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
            if (value != null && value.isNotEmpty) ...[
              SizedBox(height: 4.h),
              Text(
                value,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessInfoCard() {
    return Obx(() {
      final settings = controller.businessSettings.value;

      return Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.business, color: const Color(0xFF8DB600), size: 20.sp),
                SizedBox(width: 8.w),
                Text(
                  "Business Information",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // Logo if available
            if (settings?.logo != null && settings!.logo!.isNotEmpty)
              Column(
                children: [
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: Image.network(
                        settings.fullLogoUrl,
                        width: 80.w,
                        height: 80.h,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 80.w,
                            height: 80.h,
                            color: Colors.grey.shade200,
                            child: Icon(Icons.business, size: 40.sp),
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                ],
              ),

            if (settings?.businessName?.isNotEmpty == true)
              _infoRow("Business", settings!.businessName!),
            if (settings?.businessAddress?.isNotEmpty == true)
              _infoRow("Address", settings!.businessAddress!),
            if (settings?.businessEmail?.isNotEmpty == true)
              _infoRow("Email", settings!.businessEmail!),
            if (settings?.businessPhone?.isNotEmpty == true)
              _infoRow("Phone", settings!.businessPhone!),

          ],
        ),
      );
    });
  }

  Widget _buildSocialMediaSection() {
    return Obx(() {
      final settings = controller.businessSettings.value;
      final hasInstagram = settings?.instagram?.isNotEmpty == true;
      final hasYouTube = settings?.youtube?.isNotEmpty == true;

      if (!hasInstagram && !hasYouTube) return SizedBox();

      return Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.share, color: const Color(0xFF8DB600), size: 20.sp),
                SizedBox(width: 8.w),
                Text(
                  "Follow Us",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (hasInstagram)
                  _socialMediaButton(
                    icon: Icons.account_circle,
                    color: Colors.pink,
                    label: "Instagram",
                    onTap: () => _openInstagram(settings),
                  ),
                if (hasYouTube && hasInstagram) SizedBox(width: 20.w),
                if (hasYouTube)
                  _socialMediaButton(
                    icon: Icons.play_circle_fill,
                    color: Colors.red,
                    label: "YouTube",
                    onTap: () => _openYouTube(settings),
                  ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _socialMediaButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 50.w,
            height: 50.h,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25.r),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Icon(icon, color: color, size: 24.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80.w,
            child: Text(
              "$label:",
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: Colors.black87,
              ),
            ),
          ),
        ],
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
          Text(
            "Send us a Message",
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(child: _customNameField()),
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
          _customMessageField(),
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
                "Submit Message",
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

  Widget _customNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Name*",
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: controller.firstNameController,
          onChanged: controller.updateFirstName,
          decoration: InputDecoration(
            hintText: "Enter your name",
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

  Widget _customEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Email*",
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: controller.emailController,
          onChanged: controller.updateEmail,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: "Enter your email",
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
          "Phone (Optional)",
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: controller.phoneController,
          onChanged: controller.updatePhone,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            hintText: "Enter your phone number",
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
          "Message*",
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: controller.requirementController,
          onChanged: controller.updateRequirement,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: "Type your message here...",
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
}