import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../common/colours.dart';
import '../controller/syndicate_controller.dart';
import '../model/syndicate_model.dart';

class LegalDocumentsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<SyndicatePlotController>(
      builder: (controller) {
        final detail = controller.syndicateDetail.value;
        final List<Document> documents = detail?.documents ?? [];
        final bool hasPaid = detail?.isDocumentVerified ?? false;
        final double documentPrice = detail?.totalDocumentPrice ?? 0.0;

        if (documents.isEmpty) {
          return Center(child: Text('No documents available', style: TextStyle(fontSize: 14.sp, color: Colors.grey)));
        }

        return PopScope(
          onPopInvokedWithResult: (didPop, result) {
            controller.isTermsAccepted.value = false;
          },
          child: SingleChildScrollView(
            padding: EdgeInsets.all(12.w),
            child: Column(
              children: [
                if (!hasPaid) ...[
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
                            "Pay ₹${documentPrice.toStringAsFixed(2)} to unlock all legal documents",
                            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: Colors.orange[800]),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ================= VERIFICATION CARD WITH BLINKING BG =================
                  Container(
                    margin: EdgeInsets.only(bottom: 24.h),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: Colors.green.shade100, width: 1),
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
                        // BLINKING/PULSING BACKGROUND LAYER
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
                                .animate(onPlay: (controller) => controller.repeat(reverse: true))
                                .tint(color: const Color(0xFFFDB913),)
                                .fadeIn(duration: 1500.ms, curve: Curves.easeInOut)
                                .fadeOut(duration: 1500.ms, curve: Curves.easeInOut),
                          ),
                        ),

                        // PATTERN LAYER
                        Positioned.fill(
                          child: Opacity(
                            opacity: 0.05,
                            child: Image.network(
                              'https://www.transparenttextures.com/patterns/cubes.png',
                              repeat: ImageRepeat.repeat,
                            ),
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "Land Document Verification",
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 16.h),
                              _bulletText("Before purchasing, ensure your land is legally verified."),
                              _bulletText("Verify the property documents for complete peace of mind."),
                              _bulletText("Pay ₹${documentPrice.toStringAsFixed(0)} for instant verification."),
                              SizedBox(height: 20.h),

                              GestureDetector(
                                onTap: () => controller.isTermsAccepted.toggle(),
                                child: Obx(() => Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      height: 24.h, width: 24.w,
                                      child: Checkbox(
                                        activeColor: AppColor.orange,
                                        value: controller.isTermsAccepted.value,
                                        onChanged: (v) => controller.isTermsAccepted.value = v!,
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Text.rich(
                                      TextSpan(
                                        text: "I agree to the ",
                                        style: TextStyle(fontSize: 13.sp, color: Colors.black87),
                                        children: const [
                                          TextSpan(
                                            text: "Terms and Conditions",
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )),
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
                                    if (controller.isTermsAccepted.value) {
                                      controller.initiateDocumentPayment(0, "ALL");
                                    } else {
                                      Get.snackbar("Notice", "Please accept the terms to proceed",
                                          snackPosition: SnackPosition.BOTTOM,
                                          backgroundColor: Colors.redAccent,
                                          colorText: Colors.white);
                                    }
                                  },
                                  child: Text(
                                    "Pay Now",
                                    style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700),
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
                    ).animate().fadeIn(delay: (60 * index).ms).slideY(begin: 0.1, end: 0);
                  },
                ),
              ],
            ),
          ),
        );
      },
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
              style: TextStyle(fontSize: 14.sp, color: Colors.black87, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentCard(Document document, SyndicatePlotController controller, bool hasPaid, double documentPrice) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _getDocumentIcon(document.doucType, hasPaid),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(document.doucType, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold)),
                    Text("View and download this document", style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
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
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r))),
                onPressed: () => controller.initiateDocumentPayment(document.id, document.doucType),
                child: const Text("Unlock", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          else
            Row(
              children: [
                Expanded(child: _actionBtn("View", Icons.visibility, AppColor.primary, () => controller.viewDocument(document.id))),
                SizedBox(width: 10.w),
                Expanded(child: _actionBtn("Download", Icons.download, AppColor.orange, () => controller.downloadDocument(document.id))),
              ],
            )
        ],
      ),
    );
  }

  Widget _actionBtn(String txt, IconData icon, Color color, VoidCallback tap) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(backgroundColor: color, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)), elevation: 0),
      onPressed: tap,
      icon: Icon(icon, size: 16.sp, color: Colors.white),
      label: Text(txt, style: TextStyle(color: Colors.white, fontSize: 12.sp)),
    );
  }

  Widget _getDocumentIcon(String type, bool hasPaid) {
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(10.r), border: Border.all(color: Colors.grey.shade200)),
      child: const Icon(Icons.description_outlined, color: Colors.black54, size: 24),
    );
  }
}