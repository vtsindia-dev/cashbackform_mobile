import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../api_constant.dart';
import '../colours.dart';
import '../widget/api_service.dart';
import '../widget/sessionhandler.dart';
import '../widget/toster.dart';

void showGeneralEnquirySheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _GeneralEnquirySheet(),
  );
}

class _GeneralEnquirySheet extends StatefulWidget {
  const _GeneralEnquirySheet();

  @override
  State<_GeneralEnquirySheet> createState() => _GeneralEnquirySheetState();
}

class _GeneralEnquirySheetState extends State<_GeneralEnquirySheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final token = await SessionManager.getToken();
      if (token == null || token.isEmpty) {
        SnackBarHelper.showError('Session expired. Please login again.');
        return;
      }
      final response = await ApiService.postRequestWithToken(
        ApiUrl.submitGeneralEnquiry,
        token: token,
        data: {
          'full_name': _nameCtrl.text.trim(),
          'phone_number': _phoneCtrl.text.trim(),
          'enquiry': _messageCtrl.text.trim(),
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.back();
        SnackBarHelper.showSuccess('Request submitted successfully!');
      } else {
        final msg = response.data['message'] ?? 'Submission failed. Please try again.';
        SnackBarHelper.showError(msg.toString());
      }
    } catch (e) {
      SnackBarHelper.showError('Error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Handle ───────────────────────────────────────────────
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),

            // ── Gradient header ───────────────────────────────────────
            Container(
              width: double.infinity,
              margin: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColor.primary, AppColor.primarylite],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.primary.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.search_rounded, color: Colors.white, size: 20),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, color: Colors.white, size: 16),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    "What You're Looking For?",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    "Tell Us Your Real Estate Needs",
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.white.withValues(alpha: 0.85),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0),

            // ── Form ──────────────────────────────────────────────────
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Section label ──────────────────────────────
                      Row(
                        children: [
                          Container(
                            width: 3.w,
                            height: 16.h,
                            decoration: BoxDecoration(
                              color: AppColor.primary,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Customer Details',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColor.textMain,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 14.h),

                      // ── Full Name ──────────────────────────────────
                      _field(
                        controller: _nameCtrl,
                        label: 'Full Name *',
                        hint: 'Enter your full name',
                        icon: Icons.person_outline_rounded,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Please enter your name'
                            : null,
                      ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.05, end: 0),
                      SizedBox(height: 12.h),

                      // ── Phone Number ───────────────────────────────
                      _field(
                        controller: _phoneCtrl,
                        label: 'Phone Number *',
                        hint: 'Enter your phone number',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Please enter phone number';
                          if (v.trim().length < 10) return 'Enter a valid phone number';
                          return null;
                        },
                      ).animate().fadeIn(delay: 160.ms).slideX(begin: -0.05, end: 0),
                      SizedBox(height: 12.h),

                      // ── Message / Comments ─────────────────────────
                      _field(
                        controller: _messageCtrl,
                        label: 'Requirement / Message / Comments *',
                        hint: 'Describe what you\'re looking for...',
                        icon: Icons.chat_bubble_outline_rounded,
                        maxLines: 4,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Please describe your requirement';
                          if (v.trim().length < 10) return 'Must be at least 10 characters';
                          return null;
                        },
                      ).animate().fadeIn(delay: 220.ms).slideX(begin: -0.05, end: 0),
                      SizedBox(height: 20.h),

                      // ── Submit button ──────────────────────────────
                      GestureDetector(
                        onTap: _loading ? null : _submit,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 15.h),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: _loading
                                  ? [Colors.grey.shade400, Colors.grey.shade300]
                                  : [AppColor.primary, AppColor.primarylite],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(14.r),
                            boxShadow: _loading
                                ? []
                                : [
                                    BoxShadow(
                                      color: AppColor.primary.withValues(alpha: 0.35),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                          ),
                          child: _loading
                              ? const Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                                    SizedBox(width: 8.w),
                                    Text(
                                      'Submit Request',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ).animate().fadeIn(delay: 280.ms).slideY(begin: 0.1, end: 0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: AppColor.textMain,
          ),
        ),
        SizedBox(height: 6.h),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          style: TextStyle(fontSize: 13.sp, color: AppColor.textMain),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontSize: 12.sp, color: Colors.grey.shade400),
            prefixIcon: maxLines == 1
                ? Icon(icon, size: 18.sp, color: AppColor.primary.withValues(alpha: 0.7))
                : null,
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 14.w,
              vertical: maxLines > 1 ? 14.h : 0,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColor.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}