import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../common/colours.dart';
import '../controller/plot_market_controller.dart';
import '../model/plot_market.dart';

class LegalDocumentsScreen extends StatefulWidget {
  const LegalDocumentsScreen({super.key});

  @override
  State<LegalDocumentsScreen> createState() => _LegalDocumentsScreenState();
}

class _LegalDocumentsScreenState extends State<LegalDocumentsScreen> {
  bool _showAllDocuments = false;
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PlotMarketController>(
      builder: (controller) {
        // Get the documents list from API only
        final List<Document>? apiDocuments = controller.marketDetail.value?.documents;

        // Check if documents are null or empty
        if (apiDocuments == null || apiDocuments.isEmpty) {
          return _buildNoDocumentsView();
        }

        // Determine which documents to show
        final documentsToShow = _showAllDocuments
            ? apiDocuments
            : apiDocuments.take(2).toList();
        final hasMoreDocuments = apiDocuments.length > 2;

        return Padding(
          padding: EdgeInsets.all(12.w),
          child: Column(
            children: [
              // Documents List with fixed height for scrolling
              Container(
                constraints: BoxConstraints(
                  maxHeight: _showAllDocuments ? 400.h : 300.h,
                ),
                child: Scrollbar(
                  controller: _scrollController,
                  child: ListView.builder(
                    controller: _scrollController,
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemCount: documentsToShow.length,
                    itemBuilder: (context, index) {
                      final document = documentsToShow[index];
                      return _buildDocumentCard(document, controller, index)
                          .animate()
                          .fadeIn(delay: (50 * index).ms)
                          .slideY(
                        begin: 0.1,
                        end: 0,
                        duration: 300.ms,
                        curve: Curves.easeOut,
                      );
                    },
                  ),
                ),
              ),

              // Show More/Less Button
              if (hasMoreDocuments) ...[
                SizedBox(height: 16.h),
                _buildToggleButton(),
                SizedBox(height: 8.h),
              ],

              // Document Count Indicator
              if (apiDocuments.isNotEmpty)
                _buildDocumentCountIndicator(apiDocuments.length),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNoDocumentsView() {
    return Padding(
      padding: EdgeInsets.all(12.w),
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8.r,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open_outlined,
              size: 50.sp,
              color: Colors.grey.withOpacity(0.5),
            ),
            SizedBox(height: 16.h),
            Text(
              'No Documents Available',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Legal documents will appear here when available',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 300.ms).scale(
        begin: const Offset(0.95, 0.95),
        end: const Offset(1, 1),
        duration: 400.ms,
      ),
    );
  }

  Widget _buildDocumentCard(Document document, PlotMarketController controller, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8.r,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: Colors.grey.shade100,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon and title
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: AppColor.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  _getDocumentIcon(document.docType),
                  color: AppColor.primary,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _getDocumentTypeName(document.docType),
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: _getDocumentTypeColor(document.type)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            document.type.toUpperCase(),
                            style: TextStyle(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w700,
                              color: _getDocumentTypeColor(document.type),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      _getFileName(document.file),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade600,
                        overflow: TextOverflow.ellipsis,
                      ),
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),

          // File details
          Padding(
            padding: EdgeInsets.only(left: 44.w, top: 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (document.createdAt != null)
                  _buildDetailRow(
                    icon: Icons.calendar_today,
                    text: 'Created: ${_formatDate(document.createdAt!)}',
                  ),
                if (document.updatedAt != null)
                  _buildDetailRow(
                    icon: Icons.update,
                    text: 'Updated: ${_formatDate(document.updatedAt!)}',
                  ),
                if (document.docType?.isNotEmpty == true)
                  _buildDetailRow(
                    icon: Icons.category,
                    text: 'Category: ${document.docType}',
                  ),
              ],
            ),
          ),

          // Action buttons
          SizedBox(height: 16.h),
          Row(
            children: [
              // Expanded(
              //   child: _buildActionButton(
              //     text: 'Preview',
              //     onPressed: () => controller.viewDocument(document.id),
              //     color: AppColor.primary,
              //     icon: Icons.remove_red_eye_outlined,
              //     isPrimary: true,
              //   ),
              // ),
              // SizedBox(width: 12.w),
              Expanded(
                child: _buildActionButton(
                  text: 'Download',
                  onPressed: () => controller.downloadDocument(document.id),
                  color: Colors.green,
                  icon: Icons.download_outlined,
                  isPrimary: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({required IconData icon, required String text}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        children: [
          Icon(
            icon,
            size: 14.sp,
            color: Colors.grey.shade500,
          ),
          SizedBox(width: 6.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 11.sp,
                color: Colors.grey.shade600,
                overflow: TextOverflow.ellipsis,
              ),
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String text,
    required VoidCallback onPressed,
    required Color color,
    required IconData icon,
    required bool isPrimary,
  }) {
    return SizedBox(
      height: 40.h,
      child: isPrimary
          ? ElevatedButton.icon(
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
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 0,
        ),
      )
          : OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18.sp, color: color),
        label: Text(
          text,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showAllDocuments = !_showAllDocuments;
        });
        // Scroll to top when showing all
        if (_showAllDocuments) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          });
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: AppColor.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: AppColor.primary.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _showAllDocuments ? 'Show Less' : 'Show More Documents',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColor.primary,
              ),
            ),
            SizedBox(width: 8.w),
            Icon(
              _showAllDocuments
                  ? Icons.expand_less_rounded
                  : Icons.expand_more_rounded,
              size: 20.sp,
              color: AppColor.primary,
            ),
          ],
        ),
      ).animate(onPlay: (controller) => controller.repeat()).shimmer(
        duration: 1000.ms,
        color: Colors.white.withOpacity(0.3),
      ),
    );
  }

  Widget _buildDocumentCountIndicator(int totalCount) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.insert_drive_file,
            size: 14.sp,
            color: Colors.grey.shade600,
          ),
          SizedBox(width: 6.w),
          Text(
            '$totalCount document${totalCount > 1 ? 's' : ''} available',
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  IconData _getDocumentIcon(String? docType) {
    if (docType == null || docType.isEmpty) {
      return Icons.insert_drive_file;
    }

    final type = docType.toLowerCase();
    if (type.contains('legal') || type.contains('agreement')) {
      return Icons.gavel;
    } else if (type.contains('map') || type.contains('plan')) {
      return Icons.map_outlined;
    } else if (type.contains('certificate') || type.contains('license')) {
      return Icons.verified_outlined;
    } else if (type.contains('permit') || type.contains('approval')) {
      return Icons.check_circle_outline;
    } else if (type.contains('tax') || type.contains('receipt')) {
      return Icons.receipt_long;
    } else if (type.contains('survey') || type.contains('measurement')) {
      return Icons.square_foot;
    } else {
      return Icons.insert_drive_file;
    }
  }

  String _getDocumentTypeName(String? docType) {
    if (docType == null || docType.isEmpty) return 'Document';

    // Capitalize first letter of each word
    return docType.split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  Color _getDocumentTypeColor(String type) {
    final typeLower = type.toLowerCase();
    if (typeLower.contains('legal')) {
      return Colors.blue;
    } else if (typeLower.contains('market')) {
      return Colors.green;
    } else if (typeLower.contains('plot')) {
      return Colors.orange;
    } else if (typeLower.contains('property')) {
      return Colors.purple;
    } else {
      return AppColor.primary;
    }
  }

  String _getFileName(String fileUrl) {
    try {
      final uri = Uri.parse(fileUrl);
      final pathSegments = uri.pathSegments;
      if (pathSegments.isNotEmpty) {
        final fileName = pathSegments.last;
        // Remove query parameters if any
        return fileName.split('?').first;
      }
      return 'Document';
    } catch (e) {
      return 'Document';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}