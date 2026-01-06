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
          return Padding(
            padding: EdgeInsets.all(12.w),
            child: Center(
              child: Text(
                'No documents available',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey),
              ),
            ),
          );
        }

        return Padding(
          padding: EdgeInsets.all(12.w),
          child: Column(
            children: [
              // 🔔 PAYMENT INFO BANNER
              if (!hasPaid)
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
                      Icon(Icons.lock, color: Colors.orange),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          "Pay ₹${documentPrice.toStringAsFixed(2)} to unlock all legal documents",
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

              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: documents.length,
                itemBuilder: (context, index) {
                  return _buildDocumentCard(
                    documents[index],
                    controller,
                    hasPaid,
                    documentPrice,
                  ).animate().fadeIn(delay: (60 * index).ms);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ================= DOCUMENT CARD =================
  Widget _buildDocumentCard(
      Document document,
      SyndicatePlotController controller,
      bool hasPaid,
      double documentPrice,
      ) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ================= HEADER =================
          Row(
            children: [
              _getDocumentIcon(document.doucType, hasPaid),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.doucType,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      "Type: ${document.type}",
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              _statusBadge(hasPaid),
            ],
          ),

          SizedBox(height: 14.h),

          // ================= ACTIONS =================
          if (!hasPaid)
            Row(
              children: [
                Expanded(
                  child: _buildDisabledButton(
                    text: "View",
                    icon: Icons.remove_red_eye,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: _buildActionButton(
                    text: "Pay ₹${documentPrice.toStringAsFixed(2)}",
                    icon: Icons.lock_open,
                    color: AppColor.orange,
                    onPressed: () => controller.initiateDocumentPayment(
                      document.id,
                      document.doucType,
                    ),
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    text: "View",
                    icon: Icons.remove_red_eye,
                    color: AppColor.primary,
                    onPressed: () =>
                        controller.viewDocument(document.id),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: _buildActionButton(
                    text: "Download",
                    icon: Icons.download,
                    color: AppColor.orange,
                    onPressed: () =>
                        controller.downloadDocument(document.id),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  // ================= STATUS BADGE =================
  Widget _statusBadge(bool hasPaid) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: hasPaid ? Colors.green[50] : Colors.orange[50],
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(
            hasPaid ? Icons.check_circle : Icons.lock,
            size: 12.sp,
            color: hasPaid ? Colors.green : Colors.orange,
          ),
          SizedBox(width: 4.w),
          Text(
            hasPaid ? "Paid" : "Locked",
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: hasPaid ? Colors.green : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  // ================= BUTTONS =================
  Widget _buildDisabledButton({
    required String text,
    required IconData icon,
  }) {
    return Container(
      height: 44.h,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18.sp, color: Colors.grey),
            SizedBox(width: 6.w),
            Text(
              text,
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String text,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        height: 44.h,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18.sp, color: Colors.white),
              SizedBox(width: 6.w),
              Text(
                text,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= ICON =================
  Widget _getDocumentIcon(String type, bool hasPaid) {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: (hasPaid ? Colors.blue : Colors.grey).withOpacity(0.15),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Icon(
        Icons.description,
        size: 24.sp,
        color: hasPaid ? Colors.blue : Colors.grey,
      ),
    );
  }
}
