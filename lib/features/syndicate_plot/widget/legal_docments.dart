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
        final List<Document>? apiDocuments = controller.syndicateDetail.value?.documents;
        final documentPrice = controller.syndicateDetail.value?.documentPriceValue ?? 0;
        final propertyId = controller.syndicateDetail.value?.id ?? 0;
        // final documentPaymentStatus = controller.syndicateDetail.value?.documentPayment ?? '0';

        final documentPaymentStatus = '1';

        if (apiDocuments == null || apiDocuments.isEmpty) {
          return Padding(
            padding: EdgeInsets.all(12.w),
            child: Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 6.r,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'No documents available',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          );
        }

        return Padding(
          padding: EdgeInsets.all(12.w),
          child: Column(
            children: [
              // Show payment header only if document payment is required AND not paid
              if (documentPaymentStatus == '1')
                Container(
                  margin: EdgeInsets.only(bottom: 12.h),
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.blue[100]!),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Document Access Fee:",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[800],
                        ),
                      ),
                      Text(
                        "₹${documentPrice.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              SizedBox(
                child: ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: apiDocuments.length,
                  itemBuilder: (context, index) {
                    final document = apiDocuments[index];
                    return _buildDocumentCard(
                      document,
                      controller,
                      documentPrice,
                      propertyId,
                      documentPaymentStatus,
                    ).animate().fadeIn(delay: (50 * index).ms);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDocumentCard(
      Document document,
      SyndicatePlotController controller,
      double documentPrice,
      int propertyId,
      String documentPaymentStatus,
      ) {
    // Determine if payment is required and if user has paid
    final isPaymentRequired = documentPaymentStatus == '1';
    final hasPaid = _checkIfUserHasPaidForDocument(controller, propertyId, document.id);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _getDocumentIcon(document.doucType),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.doucType,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Type: ${document.type}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              // Payment status badge
              if (isPaymentRequired && hasPaid)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.green[100]!),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, size: 12.sp, color: Colors.green),
                      SizedBox(width: 4.w),
                      Text(
                        "Paid",
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(height: 12.h),

          // Show different buttons based on payment status
          if (isPaymentRequired)
            hasPaid
                ? _buildPaidDocumentButtons(controller, document)
                : _buildPaymentRequiredButtons(controller, document, documentPrice)
          else
            _buildFreeDocumentButtons(controller, document),
        ],
      ),
    );
  }

  // Check if user has paid for documents of this property
  bool _checkIfUserHasPaidForDocument(SyndicatePlotController controller, int propertyId, int documentId) {
    try {
      // TODO: Implement actual payment status checking
      // This could be:
      // 1. Check local storage for payment record
      // 2. Make API call to check user's document payments
      // 3. Check if this document ID is in the user's paid documents list

      // For now, check if user has any document payments for this property
      // You'll need to implement this based on your payment tracking system
      return false; // Placeholder
    } catch (e) {
      print('Error checking document payment status: $e');
      return false;
    }
  }

  // Buttons for FREE documents (no payment required)
  Widget _buildFreeDocumentButtons(SyndicatePlotController controller, Document document) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            text: 'View',
            onPressed: () => controller.viewDocument(document.id),
            color: AppColor.primary,
            icon: Icons.remove_red_eye,
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: _buildActionButton(
            text: 'Download',
            onPressed: () => controller.downloadDocument(document.id),
            color: AppColor.orange,
            icon: Icons.download,
          ),
        ),
      ],
    );
  }

  Widget _buildPaidDocumentButtons(SyndicatePlotController controller, Document document) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                text: 'View Document',
                onPressed: () => controller.viewDocument(document.id),
                color: AppColor.primary,
                icon: Icons.remove_red_eye,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _buildActionButton(
                text: 'Download',
                onPressed: () => controller.downloadDocument(document.id),
                color: AppColor.orange,
                icon: Icons.download,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Text(
          "✅ Document access granted",
          style: TextStyle(
            fontSize: 10.sp,
            color: Colors.green,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentRequiredButtons(
      SyndicatePlotController controller,
      Document document,
      double documentPrice,
      ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: _buildActionButton(
                text: 'View Sample',
                onPressed: () => controller.viewDocument(document.id),
                color: AppColor.primary,
                icon: Icons.remove_red_eye,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _buildActionButton(
                text: 'Pay & Download (₹${documentPrice.toStringAsFixed(2)})',
                onPressed: () => controller.initiateDocumentPayment(document.id, document.doucType),
                color: AppColor.orange,
                icon: Icons.lock_open,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Text(
          "*Full document access requires payment",
          style: TextStyle(
            fontSize: 10.sp,
            color: Colors.orange,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String text,
    required VoidCallback onPressed,
    required Color color,
    required IconData icon,
  }) {
    return
      SizedBox(
      height: 44.h,
      child: InkWell(
        borderRadius: BorderRadius.circular(14.r),
        onTap: onPressed,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18.sp, color: Colors.white),
              SizedBox(width: 6.w),
              Flexible(
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _getDocumentIcon(String docType) {
    IconData icon;
    Color color;

    if (docType.contains('Legal') || docType.contains('Document')) {
      icon = Icons.description;
      color = Colors.blue;
    } else if (docType.contains('Plan') || docType.contains('Map')) {
      icon = Icons.map;
      color = Colors.green;
    } else if (docType.contains('Guideline') || docType.contains('Rule')) {
      icon = Icons.rule;
      color = Colors.orange;
    } else {
      icon = Icons.insert_drive_file;
      color = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Icon(icon, color: color, size: 24.sp),
    );
  }

  String _getFileName(String fileUrl) {
    try {
      final uri = Uri.parse(fileUrl);
      final pathSegments = uri.pathSegments;
      return pathSegments.isNotEmpty ? pathSegments.last : 'Document';
    } catch (e) {
      return 'Document';
    }
  }
}