import 'package:cashback_farms/common/route/router.dart';
import 'package:cashback_farms/features/kyc/controller/kyc_controller.dart';
import 'package:cashback_farms/features/syndicate_plot/widget/kyc_selector_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../common/colours.dart';
import '../../payment/controller/razorpay_controller.dart';
import '../controller/rental_yield_controller.dart';
import '../model/rental_yeild_model.dart';

class RentalLegalDocumentsScreen extends StatefulWidget {
  final RentalDetailProperty? rentalDetailProperty;
  final int propertyId;
  final String propertyName;
  final double documentPrice;
  final List<RentalDocument> documents;
  final bool hasPaid;
  final bool isOpened;
  final VoidCallback? openedFunction;

  RentalLegalDocumentsScreen({
    super.key,
    required this.propertyId,
    required this.propertyName,
    required this.documentPrice,
    required this.documents,
    required this.hasPaid,
    this.rentalDetailProperty,
    required this.isOpened,
    this.openedFunction,
  });

  @override
  State<RentalLegalDocumentsScreen> createState() =>
      _RentalLegalDocumentsScreenState();
}

class _RentalLegalDocumentsScreenState
    extends State<RentalLegalDocumentsScreen> {
  final KYCController kYCController = Get.put(KYCController());

  @override
  Widget build(BuildContext context) {
    final rentalController = Get.put(RentalYieldController());

    if (widget.documents.isEmpty) {
      return Center(
        child: Text(
          'No documents available',
          style: TextStyle(fontSize: 14.sp, color: Colors.grey),
        ),
      );
    }

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        rentalController.isTermsAccepted.value = false;
      },
      child: SingleChildScrollView(
        padding: EdgeInsets.all(12.w),
        child: Column(
          children: [
            if (!widget.hasPaid) ...[
              Container(
                margin: EdgeInsets.only(bottom: 12.h),
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lock, color: Colors.orange, size: 20.sp),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        "Pay ₹${widget.documentPrice.toStringAsFixed(2)} to unlock all legal documents",
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 24.h),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: Colors.green.shade100, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16.r),
                        child:
                            Container(
                                  decoration: BoxDecoration(
                                    gradient: RadialGradient(
                                      colors: [
                                        const Color(
                                          0xFFFDB913,
                                        ).withValues(alpha: 0.15),
                                        Colors.transparent,
                                      ],
                                      radius: 1.2,
                                    ),
                                  ),
                                )
                                .animate(
                                  onPlay: (controller) =>
                                      controller.repeat(reverse: true),
                                )
                                .tint(color: const Color(0xFFFDB913))
                                .fadeIn(
                                  duration: 1500.ms,
                                  curve: Curves.easeInOut,
                                )
                                .fadeOut(
                                  duration: 1500.ms,
                                  curve: Curves.easeInOut,
                                ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 24.h,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Rental Document Verification",
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 16.h),
                          _bulletText(
                            "Before proceeding, ensure rental documents are legally verified.",
                          ),
                          _bulletText(
                            "Verify property documents for complete peace of mind.",
                          ),
                          _bulletText(
                            "Pay ₹${widget.documentPrice.toStringAsFixed(0)} for instant verification.",
                          ),
                          SizedBox(height: 20.h),
                          GestureDetector(
                            onTap: () {
                              rentalController.isTermsAccepted.toggle();
                              final razorpayController =
                                  Get.find<RazorpayController>();
                              razorpayController.isTermsAccepted.value =
                                  rentalController.isTermsAccepted.value;
                            },
                            child: Obx(
                              () => Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 24.h,
                                    width: 24.w,
                                    child: Checkbox(
                                      activeColor: AppColor.orange,
                                      value: rentalController
                                          .isTermsAccepted
                                          .value,
                                      onChanged: (v) {
                                        if (v != null) {
                                          rentalController
                                                  .isTermsAccepted
                                                  .value =
                                              v;
                                          final razorpayController =
                                              Get.find<RazorpayController>();
                                          razorpayController
                                                  .isTermsAccepted
                                                  .value =
                                              v;
                                        }
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  GestureDetector(
                                    onTap: () => _showTermsAndConditions(),
                                    child: Text.rich(
                                      TextSpan(
                                        text: "I agree to the ",
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          color: Colors.black87,
                                        ),
                                        children: const [
                                          TextSpan(
                                            text: "Terms and Conditions",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 20.h),
                          SizedBox(
                            width: 220.w,
                            height: 48.h,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFDB913),
                                foregroundColor: Colors.black,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                              onPressed: () {
                                if (rentalController.isTermsAccepted.value) {
                                  rentalController.initiateDocumentPayment(
                                    0,
                                    "ALL",
                                    customAmount: widget.documentPrice,
                                  );
                                } else {
                                  Get.snackbar(
                                    "Notice",
                                    "Please accept the terms to proceed",
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.redAccent,
                                    colorText: Colors.white,
                                  );
                                }
                              },
                              child: Text(
                                "Pay Now",
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (widget.rentalDetailProperty?.booked == true) ...[
              GestureDetector(
                onTap: () {
                  if (widget.rentalDetailProperty?.kycVerified == true) {
                    Get.toNamed(AppRoutes.rentalEnquiry);
                  } else {
                    if (!widget.isOpened) {
                      widget.openedFunction?.call();
                    }
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: widget.rentalDetailProperty?.kycVerified == true
                        ? const Color(0xff608900)
                        : const Color(0xfffeb821),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        widget.rentalDetailProperty?.kycVerified == true
                            ? Icons.verified
                            : Icons.pending_actions,
                        color: widget.rentalDetailProperty?.kycVerified == true
                            ? Colors.white
                            : Colors.black,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.rentalDetailProperty?.kycVerified == true
                            ? 'KYC Added'
                            : 'Proceed to KYC',
                        style: TextStyle(
                          color:
                              widget.rentalDetailProperty?.kycVerified == true
                              ? Colors.white
                              : Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (widget.isOpened) ...[
                SizedBox(height: 10.h),
                Obx(
                  () => KYCBeneficiarySelector(
                    controller: kYCController,
                    kycList: kYCController.kycList.toList(),
                    onContinue: (selected) async {
                      final response = await kYCController.kycVerification(
                        propertyId:
                            widget.rentalDetailProperty?.id.toString() ?? '',
                        transactionId:
                            widget.rentalDetailProperty?.transactionId
                                .toString() ??
                            '',
                        type: 'rental',
                      );
                      if (response['status'] == true) {
                        rentalController.getPropertyDetails(
                          widget.rentalDetailProperty?.id ?? 0,
                        );
                      }
                    },
                    onAddNew: () {
                      Get.toNamed(AppRoutes.kycScreen);
                    },
                  ),
                ),
              ],
            ],
            ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.documents.length,
              itemBuilder: (context, index) {
                return _buildDocumentCard(
                      widget.documents[index],
                      rentalController,
                      widget.hasPaid,
                      widget.documentPrice,
                    )
                    .animate()
                    .fadeIn(delay: (60 * index).ms)
                    .slideY(begin: 0.1, end: 0);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _bulletText(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 6.h),
            child: Icon(Icons.circle, size: 6.sp, color: Colors.black87),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentCard(
    RentalDocument document,
    RentalYieldController controller,
    bool hasPaid,
    double documentPrice,
  ) {
    String documentName =
        document.doucType ??
        _getFileNameFromUrl(document.file) ??
        "Property Document";

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _getDocumentIcon(documentName, hasPaid),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      documentName,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "View and download this document",
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          if (!hasPaid)
            SizedBox(
              width: double.infinity,
              height: 40.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                onPressed: () => controller.initiateDocumentPayment(
                  document.id,
                  document.doucType ?? "Document",
                  customAmount: documentPrice,
                ),
                child: const Text(
                  "Unlock",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: _actionBtn(
                    "Download",
                    Icons.download,
                    AppColor.orange,
                    () {
                      if (document.file.isNotEmpty) {
                        controller.downloadDocument(document.id, document.file);
                      } else {
                        Get.snackbar(
                          "Error",
                          "Document URL not available",
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _actionBtn(String txt, IconData icon, Color color, VoidCallback tap) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        elevation: 0,
      ),
      onPressed: tap,
      icon: Icon(icon, size: 16.sp, color: Colors.white),
      label: Text(
        txt,
        style: TextStyle(color: Colors.white, fontSize: 12.sp),
      ),
    );
  }

  Widget _getDocumentIcon(String type, bool hasPaid) {
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: const Icon(
        Icons.description_outlined,
        color: Colors.black54,
        size: 24,
      ),
    );
  }

  String? _getFileNameFromUrl(String url) {
    if (url.isEmpty) return null;
    try {
      final uri = Uri.parse(url);
      final path = uri.path;
      final segments = path.split('/');
      if (segments.isNotEmpty) {
        String fileName = segments.last;
        fileName = fileName.replaceAll(RegExp(r'^\d+_'), '');
        fileName = fileName.replaceAll(RegExp(r'\.[^.]+$'), '');
        fileName = fileName.replaceAll('_', ' ');
        fileName = fileName
            .split(' ')
            .map((word) {
              if (word.isEmpty) return '';
              return word[0].toUpperCase() + word.substring(1).toLowerCase();
            })
            .join(' ');
        return fileName;
      }
    } catch (e) {
      debugPrint('❌ Error parsing filename: $e');
    }
    return null;
  }

  void _showTermsAndConditions() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.gavel, color: AppColor.orange, size: 24.sp),
                  SizedBox(width: 10.w),
                  Text(
                    "Terms & Conditions",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTermItem(
                        "1. Service Purpose",
                        "Provides verified rental documents for transparency.",
                      ),
                      _buildTermItem(
                        "2. Payment",
                        "One-time fee for lifetime access to all documents.",
                      ),
                      _buildTermItem(
                        "3. Access Rights",
                        "Unlimited viewing and downloading rights.",
                      ),
                      _buildTermItem(
                        "4. Verification",
                        "All documents verified by legal experts.",
                      ),
                      _buildTermItem(
                        "5. Non-Refundable",
                        "Payments are non-refundable.",
                      ),
                      SizedBox(height: 16.h),
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          "By accepting, you agree to comply with legal requirements.",
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[700],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                  child: Text(
                    "Close",
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTermItem(String title, String description) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            description,
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
