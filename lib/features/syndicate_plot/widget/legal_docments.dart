// widgets/legal_documents_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../common/colours.dart';
import '../controller/syndicate_controller.dart';
import '../model/syndicate_model.dart';

class LegalDocumentsScreen extends StatelessWidget {
  const LegalDocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SyndicatePlotController>(
      builder: (controller) {
        final detail = controller.syndicateDetail.value;
        final List<Document> documents = detail?.documents ?? [];

        // ✅ SOLD OUT — block document payment too
        if (detail?.isSoldOut == true) {
          return _buildSoldOutDocBanner();
        }

        final bool hasPaid = detail?.isDocumentVerified ?? false;

        // ✅ Document payment uses admin_document ONLY
        final double documentPrice = detail?.totalDocumentPrice ?? 0.0;

        if (documents.isEmpty) {
          return Center(
            child: Text(
              'No documents available',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey),
            ),
          );
        }

        return PopScope(
          onPopInvokedWithResult: (didPop, result) {
            controller.isTermsAccepted.value = false;
          },
          child: SingleChildScrollView(
            padding: EdgeInsets.all(12.w),
            child: Column(
              children: [
                // ✅ Payment type clarification banner (always visible)
                _buildDocPaymentInfoBanner(documentPrice, hasPaid),
                SizedBox(height: 12.h),

                if (!hasPaid) ...[
                  // ── Lock notice ──
                  Container(
                    margin: EdgeInsets.only(bottom: 12.h),
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.lock_outline_rounded,
                            color: Colors.orange.shade700, size: 20.sp),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            'Pay ₹${documentPrice.toStringAsFixed(2)} to unlock all legal documents',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.orange.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Verification card ──
                  _buildVerificationCard(controller, documentPrice),
                ],

                // ── Document list ──
                ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    return _buildDocumentCard(
                      documents[index],
                      controller,
                      hasPaid,
                      documentPrice,
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
      },
    );
  }

  // ────────────────────────────────────────
  // ✅ Sold-out banner for documents tab
  // ────────────────────────────────────────
  Widget _buildSoldOutDocBanner() {
    return Center(
      child: Container(
        margin: EdgeInsets.all(24.w),
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.block_rounded,
                color: Colors.red.shade600, size: 48.sp),
            SizedBox(height: 14.h),
            Text(
              'Property Sold Out',
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w800,
                color: Colors.red.shade700,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Document purchases are not available\nfor sold-out properties.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.red.shade400,
                height: 1.5,
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms),
    );
  }

  // ────────────────────────────────────────
  // ✅ Banner clarifying document payment is separate
  // ────────────────────────────────────────
  Widget _buildDocPaymentInfoBanner(double price, bool hasPaid) {
    if (hasPaid) {
      return Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.verified_rounded,
                color: Colors.green.shade700, size: 18.sp),
            SizedBox(width: 8.w),
            Text(
              'Documents unlocked — you have paid for verification.',
              style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.green.shade800,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded,
              color: Colors.blue.shade700, size: 18.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.blue.shade800,
                    height: 1.4),
                children: [
                  const TextSpan(
                    text: 'Document Verification Payment: ',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(
                    text:
                    '₹${price.toStringAsFixed(2)} (one-time fee). This is separate from plot booking.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────
  Widget _buildVerificationCard(
      SyndicatePlotController controller, double documentPrice) {
    return Container(
      margin: EdgeInsets.only(bottom: 24.h),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.green.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Pulsing background
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFFDB913).withOpacity(0.15),
                      Colors.transparent,
                    ],
                    radius: 1.2,
                  ),
                ),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .tint(color: const Color(0xFFFDB913))
                  .fadeIn(duration: 1500.ms, curve: Curves.easeInOut)
                  .fadeOut(duration: 1500.ms, curve: Curves.easeInOut),
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Land Document Verification',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 16.h),
                _bulletText(
                    'Before purchasing, ensure your land is legally verified.'),
                _bulletText(
                    'Verify property documents for complete peace of mind.'),
                _bulletText(
                    'One-time fee of ₹${documentPrice.toStringAsFixed(0)} — separate from plot booking.'),
                SizedBox(height: 20.h),

                // Terms checkbox
                GestureDetector(
                  onTap: () => controller.isTermsAccepted.toggle(),
                  child: Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 24.h,
                        width: 24.w,
                        child: Checkbox(
                          activeColor: AppColor.orange,
                          value: controller.isTermsAccepted.value,
                          onChanged: (v) =>
                          controller.isTermsAccepted.value = v!,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text.rich(
                        TextSpan(
                          text: 'I agree to the ',
                          style: TextStyle(
                              fontSize: 13.sp, color: Colors.black87),
                          children: const [
                            TextSpan(
                              text: 'Terms and Conditions',
                              style:
                              TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )),
                ),
                SizedBox(height: 20.h),

                // Pay button
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
                      if (controller.isTermsAccepted.value) {
                        // ✅ Calls document payment only — passes document price
                        controller.initiateDocumentPayment(0, 'ALL');
                      } else {
                        Get.snackbar(
                          'Notice',
                          'Please accept the terms to proceed',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.redAccent,
                          colorText: Colors.white,
                        );
                      }
                    },
                    child: Text(
                      'Pay ₹${documentPrice.toStringAsFixed(2)}',
                      style: TextStyle(
                          fontSize: 15.sp, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────
  Widget _buildDocumentCard(
      Document document,
      SyndicatePlotController controller,
      bool hasPaid,
      double documentPrice,
      ) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              _docIcon(hasPaid),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.doucType,
                      style: TextStyle(
                          fontSize: 15.sp, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'View and download this document',
                      style: TextStyle(
                          fontSize: 12.sp, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              if (!hasPaid)
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.lock_rounded,
                          size: 11.sp, color: Colors.red.shade600),
                      SizedBox(width: 4.w),
                      Text(
                        'Locked',
                        style: TextStyle(
                            fontSize: 10.sp,
                            color: Colors.red.shade600,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(height: 14.h),
          if (!hasPaid)
            SizedBox(
              width: double.infinity,
              height: 40.h,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r)),
                ),
                // ✅ Each document unlock triggers document-only payment
                onPressed: () => controller.initiateDocumentPayment(
                    document.id, document.doucType),
                icon: Icon(Icons.lock_open_rounded, size: 14.sp),
                label: Text(
                  'Unlock — ₹${documentPrice.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: _actionBtn(
                    'View',
                    Icons.visibility_rounded,
                    AppColor.primary,
                        () => controller.viewDocument(document.id),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: _actionBtn(
                    'Download',
                    Icons.download_rounded,
                    AppColor.orange,
                        () => controller.downloadDocument(document.id),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────
  Widget _docIcon(bool hasPaid) {
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: hasPaid
            ? Colors.green.shade50
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: hasPaid
              ? Colors.green.shade200
              : Colors.grey.shade200,
        ),
      ),
      child: Icon(
        hasPaid
            ? Icons.description_rounded
            : Icons.description_outlined,
        color: hasPaid ? Colors.green.shade600 : Colors.black54,
        size: 24,
      ),
    );
  }

  Widget _actionBtn(
      String txt, IconData icon, Color color, VoidCallback tap) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r)),
        elevation: 0,
      ),
      onPressed: tap,
      icon: Icon(icon, size: 14.sp),
      label: Text(txt,
          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600)),
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
                  fontSize: 14.sp, color: Colors.black87, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}