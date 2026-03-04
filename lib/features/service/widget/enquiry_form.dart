// service_enquiry_form.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../common/colours.dart';
import '../../../common/widget/toster.dart';
import '../controller/service_controller.dart';

class ServiceEnquiryForm extends StatelessWidget {
  final ServiceController controller = Get.put(ServiceController());
  final String serviceName;
  final int serviceId;
  ServiceEnquiryForm({
    super.key,
    required this.serviceName,
    required this.serviceId,
  }) {
    controller.setMaterialId(serviceId);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Send Enquiry',
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColor.primary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Service: $serviceName',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColor.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Get.back(),
                icon: Icon(Icons.close, size: 24.sp, color: AppColor.textSecondary),
              ),
            ],
          ).animate().fade(duration: 300.ms).slide(begin: Offset(0, -0.1)),

          Divider(height: 30.h, color: Colors.grey.shade300),

          // Form
          _buildNameField(),
          SizedBox(height: 16.h),

          _buildPhoneField(),
          SizedBox(height: 16.h),

          _buildMessageField(),
          SizedBox(height: 24.h),

          // Error message
          Obx(() => controller.errorMessage.value.isNotEmpty
              ? _buildErrorMessage()
              : SizedBox.shrink()),

          SizedBox(height: 16.h),

          // Submit Button
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Name *',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColor.textMain,
          ),
        ),
        SizedBox(height: 6.h),
        Obx(() {
          return TextField(
            controller: controller.nameController,
            decoration: InputDecoration(
              hintText: 'Enter your full name',
              prefixIcon: Icon(Icons.person_outline, color: AppColor.primary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: controller.nameError.value.isNotEmpty
                      ? Colors.red
                      : Colors.grey.shade300,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: controller.nameError.value.isNotEmpty
                      ? Colors.red
                      : AppColor.primary,
                  width: 2,
                ),
              ),
              errorText: controller.nameError.value.isNotEmpty
                  ? controller.nameError.value
                  : null,
              errorStyle: TextStyle(fontSize: 12.sp),
            ),
            style: TextStyle(fontSize: 14.sp),
          );
        }),
      ].animate().fade(duration: 300.ms).slide(begin: Offset(0.1, 0)),
    );
  }

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Phone Number *',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColor.textMain,
          ),
        ),
        SizedBox(height: 6.h),
        Obx(() {
          return TextField(
            controller: controller.phoneController,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            decoration: InputDecoration(
              hintText: 'Enter 10-digit phone number',
              prefixIcon: Icon(Icons.phone_outlined, color: AppColor.primary),
              counterText: '',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: controller.phoneError.value.isNotEmpty
                      ? Colors.red
                      : Colors.grey.shade300,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: controller.phoneError.value.isNotEmpty
                      ? Colors.red
                      : AppColor.primary,

                  width: 2,
                ),
              ),
              errorText: controller.phoneError.value.isNotEmpty
                  ? controller.phoneError.value
                  : null,
              errorStyle: TextStyle(fontSize: 12.sp),
            ),
            style: TextStyle(fontSize: 14.sp),
          );
        }),
      ].animate().fade(duration: 300.ms).slide(begin: Offset(0.1, 0)),
    );
  }

  Widget _buildMessageField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enquiry Message *',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColor.textMain,
          ),
        ),
        SizedBox(height: 6.h),
        Obx(() {
          return TextField(
            controller: controller.quoteController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Describe your requirements or questions...',
              alignLabelWithHint: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: controller.quoteError.value.isNotEmpty
                      ? Colors.red
                      : Colors.grey.shade300,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: controller.quoteError.value.isNotEmpty
                      ? Colors.red
                      : AppColor.primary,
                  width: 2,
                ),
              ),
              errorText: controller.quoteError.value.isNotEmpty
                  ? controller.quoteError.value
                  : null,
              errorStyle: TextStyle(fontSize: 12.sp),
            ),
            style: TextStyle(fontSize: 14.sp),
          );
        }),
      ].animate().fade(duration: 300.ms).slide(begin: Offset(0.1, 0)),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, size: 20.sp, color: Colors.red),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              controller.errorMessage.value,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    ).animate().fade(duration: 300.ms).shake(duration: 300.ms);
  }

  Widget _buildSubmitButton() {
    return Obx(() {
      return ElevatedButton(
        onPressed: controller.isSubmitting.value ? null : _submitEnquiry,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.primary,
          foregroundColor: Colors.white,
          minimumSize: Size(double.infinity, 50.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 3,
          disabledBackgroundColor: AppColor.primary.withOpacity(0.5),
        ),
        child: controller.isSubmitting.value
            ? Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20.w,
              height: 20.w,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              'Submitting...',
              style: TextStyle(fontSize: 16.sp),
            ),
          ],
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.send, size: 20.sp),
            SizedBox(width: 12.w),
            Text(
              'Submit Enquiry',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ).animate().fade(duration: 300.ms).scale(begin: Offset(0.95, 0.95));
    });
  }

  Future<void> _submitEnquiry() async {
    final result = await controller.submitEnquiry();

    if (result['success'] == true) {
      Future.delayed(Duration(milliseconds: 500), () {
        Get.back();
      });
    }
  }
}