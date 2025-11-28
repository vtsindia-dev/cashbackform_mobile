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
        // Get the documents list from API only
        final List<Document>? apiDocuments = controller.syndicateDetail.value?.documents;

        // Check if documents are null or empty
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
          child: SizedBox(
            child: ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: apiDocuments.length,
              itemBuilder: (context, index) {
                final document = apiDocuments[index];
                return _buildDocumentCard(document, controller)
                    .animate()
                    .fadeIn(delay: (50 * index).ms)
                    .scale(
                  begin: const Offset(0.95, 0.95),
                  end: const Offset(1, 1),
                  duration: 300.ms,
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildDocumentCard(Document document, SyndicatePlotController controller) {
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
                child: Text(
                  document.doucType,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.only(left: 32.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Type: ${document.type}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.black54,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'File: ${_getFileName(document.file)}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.black54,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          Row(
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
          ),
        ],
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

  Widget _buildActionButton({
    required String text,
    required VoidCallback onPressed,
    required Color color,
    required IconData icon,
  }) {
    return SizedBox(
      height: 40.h,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18.sp),
        label: Text(
          text,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}