// widgets/legal_documents_screen.dart

import 'package:cashback_farms/common/route/router.dart';
import 'package:cashback_farms/features/kyc/controller/kyc_controller.dart';
import 'package:cashback_farms/features/syndicate_plot/widget/kyc_selector_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../common/colours.dart';
import '../controller/syndicate_controller.dart';
import '../model/syndicate_model.dart';

class LegalDocumentsScreen extends StatefulWidget {

   LegalDocumentsScreen({super.key});

  @override
  State<LegalDocumentsScreen> createState() => _LegalDocumentsScreenState();
}

class _LegalDocumentsScreenState extends State<LegalDocumentsScreen> {
  final KYCController kYCController = Get.put(KYCController());


  bool isOpened = false;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SyndicatePlotController>(
      builder: (controller) {
        final detail = controller.syndicateDetail.value;
        final List<Document> documents = detail?.documents ?? [];

        final hasBookedPlots = detail?.isDocumentVerified ?? false;
        final propertyBooked = detail?.propertyBooked ?? false;
        final kycVerified = detail?.kycVerified ?? false;

        if (detail?.isSoldOut == true) {
          return _buildSoldOutDocBanner();
        }

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
                if (hasBookedPlots)
                  _buildUnlockedBanner()
                else
                  _buildLockedBanner(),

                SizedBox(height: 12.h),
                ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    return _buildDocumentCard(
                      documents[index],
                      controller,
                      hasBookedPlots,
                    )
                        .animate()
                        .fadeIn(delay: (60 * index).ms)
                        .slideY(begin: 0.1, end: 0);
                  },
                ),
                if(propertyBooked)
                  ...[
                    SizedBox(height: 10.h),
                    GestureDetector(
                      onTap: () {
                        if (kycVerified) {
                          Get.toNamed(AppRoutes.ownedSyndicatePlotList);
                        } else {
                          if (!isOpened) {
                            setState(() {
                              isOpened = true;
                            });
                          }
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: kycVerified
                              ? const Color(0xff608900)
                              : const Color(0xfffeb821),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              kycVerified
                                  ? Icons.verified
                                  : Icons.pending_actions,
                              color: kycVerified
                                  ? Colors.white
                                  : Colors.black,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              kycVerified
                                  ? 'KYC Added'
                                  : 'Proceed to KYC',
                              style: TextStyle(
                                color: kycVerified
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
                    if(isOpened)
                      ...[
                        SizedBox(height: 10.h),
                        Obx(
                              () => KYCBeneficiarySelector(
                            controller: kYCController,
                            kycList: kYCController.kycList.toList(),
                            onContinue: (selected) async {
                              final response = await kYCController.kycVerification(
                                propertyId: detail?.id.toString() ?? '',
                                transactionId: detail?.transactionId.toString() ?? '',
                                type: 'syndicate',
                              );
                              if (response['status'] == 200) {
                                controller.fetchSyndicateDetail(detail?.id??0);
                                setState(() {
                                  isOpened = false;
                                });
                              }
                            },
                            onAddNew: () {
                              Get.toNamed(AppRoutes.kycScreen);
                            },
                          ),
                        )
                      ]
                  ]
              ],
            ),
          ),
        );
      },
    );
  }

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
              'Documents are not available\nfor sold-out properties.',
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

  Widget _buildUnlockedBanner() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.verified_rounded,
              color: Colors.green.shade700, size: 20.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'Documents Unlocked! You have booked plots in this property.',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: Colors.green.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Locked banner - shown when user hasn't booked plots
  Widget _buildLockedBanner() {
    return Container(
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
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'Book a plot to unlock all legal documents',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: Colors.orange.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Document Card
  Widget _buildDocumentCard(
      Document document,
      SyndicatePlotController controller,
      bool hasBookedPlots,
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
              _docIcon(hasBookedPlots),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.doucType,
                      style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    Text(
                      hasBookedPlots
                          ? 'View and download this document'
                          : 'Book a plot to unlock this document',
                      style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey.shade600
                      ),
                    ),
                  ],
                ),
              ),
              if (!hasBookedPlots)
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h
                  ),
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
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          SizedBox(height: 14.h),

          // Action buttons - only show if user has booked plots
          if (hasBookedPlots)
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
            )
          else
          // Show disabled state
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 12.h),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Center(
                child: Text(
                  'Book a plot to unlock',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _docIcon(bool hasBookedPlots) {
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: hasBookedPlots
            ? Colors.green.shade50
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: hasBookedPlots
              ? Colors.green.shade200
              : Colors.grey.shade200,
        ),
      ),
      child: Icon(
        hasBookedPlots
            ? Icons.description_rounded
            : Icons.lock_outline_rounded,
        color: hasBookedPlots ? Colors.green.shade600 : Colors.grey.shade600,
        size: 24,
      ),
    );
  }

  Widget _actionBtn(
      String txt,
      IconData icon,
      Color color,
      VoidCallback tap
      ) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r)
        ),
        elevation: 0,
      ),
      onPressed: tap,
      icon: Icon(icon, size: 14.sp),
      label: Text(
        txt,
        style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600
        ),
      ),
    );
  }
}