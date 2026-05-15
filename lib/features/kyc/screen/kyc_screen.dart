// screens/kyc_list_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import '../../../common/colours.dart';
import '../controller/kyc_controller.dart';
import '../model/kyc_model.dart';
import 'add_kyc.dart';

class KYCListScreen extends StatelessWidget {
  final KYCController controller = Get.put(KYCController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundLight,
      appBar: _buildAppBar(context),
      body: Obx(() => _buildBody(context)),
      floatingActionButton: _buildFAB(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColor.primary,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColor.white),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'KYC Documents',
            style: TextStyle(
              color: AppColor.white,
              fontWeight: FontWeight.w700,
              fontSize: 18,
              letterSpacing: 0.4,
            ),
          ),
          Obx(() => Text(
            '${controller.kycList.length} record${controller.kycList.length == 1 ? '' : 's'}',
            style: TextStyle(
              color: AppColor.white.withOpacity(0.75),
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          )),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.share_rounded),
          onPressed: () => _shareAllKYC(),
          tooltip: 'Share all KYC',
        ),
      ],
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(4),
        child: Container(
          height: 4,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColor.primary, AppColor.primarylite],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFAB(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _showAddKYCDialog(context),
      backgroundColor: AppColor.primary,
      foregroundColor: AppColor.white,
      elevation: 6,
      icon: Icon(Icons.add_rounded),
      label: Text('Add KYC', style: TextStyle(fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (controller.isLoading.value) {
      return _buildLoadingState();
    }
    if (controller.errorMessage.value.isNotEmpty) {
      return _buildErrorState();
    }
    if (controller.kycList.isEmpty) {
      return _buildEmptyState(context);
    }
    return _buildKYCList();
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColor.primary),
            strokeWidth: 3,
          ),
          SizedBox(height: 16),
          Text(
            'Fetching KYC records...',
            style: TextStyle(color: AppColor.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColor.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.wifi_off_rounded, size: 48, color: AppColor.error),
            ),
            SizedBox(height: 20),
            Text(
              'Something went wrong',
              style: TextStyle(
                color: AppColor.textMain,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8),
            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColor.textSecondary, fontSize: 14, height: 1.5),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: controller.fetchKYCList,
              icon: Icon(Icons.refresh_rounded),
              label: Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primary,
                foregroundColor: AppColor.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColor.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.shield_outlined, size: 56, color: AppColor.primary),
          ),
          SizedBox(height: 20),
          Text(
            'No KYC Records Yet',
            style: TextStyle(
              color: AppColor.textMain,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Add your first KYC document\nto get started',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColor.textSecondary, fontSize: 14, height: 1.6),
          ),
          SizedBox(height: 28),
          ElevatedButton.icon(
            onPressed: () => _showAddKYCDialog(context),
            icon: Icon(Icons.add_rounded),
            label: Text('Add KYC Document'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primary,
              foregroundColor: AppColor.white,
              padding: EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKYCList() {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: controller.kycList.length,
      itemBuilder: (context, index) {
        return _buildKYCCard(controller.kycList[index], index);
      },
    );
  }

  Widget _buildKYCCard(KYCDocument kyc, int index) {
    final colors = [AppColor.primary, AppColor.accent, AppColor.orange];
    final avatarColor = colors[index % colors.length];

    return Container(
      margin: EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColor.black.withOpacity(0.06),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: EdgeInsets.zero,
          leading: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: avatarColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '${ index + 1 }',
                style: TextStyle(
                  color: avatarColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          title: Text(
            kyc.name,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColor.textMain,
              fontSize: 15,
            ),
          ),
          subtitle: Padding(
            padding: EdgeInsets.only(top: 2),
            child: Row(
              children: [
                Icon(Icons.credit_card_rounded, size: 12, color: AppColor.textSecondary),
                SizedBox(width: 4),
                Text(
                  kyc.panNo,
                  style: TextStyle(
                    color: AppColor.textSecondary,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.share_rounded, size: 20, color: AppColor.primary),
                onPressed: () => _shareSingleKYC(kyc),
                tooltip: 'Share KYC details',
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColor.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Verified',
                  style: TextStyle(
                    color: AppColor.success,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          children: [
            Divider(height: 1, color: AppColor.lightGrey),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoChip(Icons.fingerprint_rounded, 'Aadhar', kyc.aadharNo),
                  SizedBox(height: 10),
                  _buildInfoChip(Icons.calendar_today_rounded, 'Submitted', _formatDate(kyc.createdAt)),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'DOCUMENTS',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColor.grey,
                          letterSpacing: 1.2,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.share_rounded, size: 18, color: AppColor.grey),
                        onPressed: () => _shareKYCWithDocuments(kyc),
                        tooltip: 'Share all documents',
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      _buildDocumentChip('PAN', Icons.badge_rounded, kyc.panDoc, kyc),
                      SizedBox(width: 8),
                      _buildDocumentChip('Aadhar', Icons.credit_card_rounded, kyc.aadharDoc, kyc),
                      SizedBox(width: 8),
                      _buildDocumentChip('Sign', Icons.draw_rounded, kyc.signDoc, kyc),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColor.primary),
        SizedBox(width: 8),
        Text('$label: ', style: TextStyle(color: AppColor.textSecondary, fontSize: 13)),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: AppColor.textMain,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentChip(String label, IconData icon, String url, KYCDocument kyc) {
    final hasDoc = url.isNotEmpty;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (hasDoc) {
            Get.to(() => DocumentPreviewScreen(imageUrl: url));
          } else {
            Get.snackbar(
              'Unavailable',
              'No $label document on record',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: AppColor.warning,
              colorText: AppColor.white,
            );
          }
        },
        onLongPress: () {
          if (hasDoc) {
            _shareDocument(url, label);
          }
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: hasDoc ? AppColor.primary.withOpacity(0.08) : AppColor.lightGrey,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: hasDoc ? AppColor.primary.withOpacity(0.25) : AppColor.lightGrey,
            ),
          ),
          child: Column(
            children: [
              Icon(
                hasDoc ? icon : Icons.cloud_off_rounded,
                size: 18,
                color: hasDoc ? AppColor.primary : AppColor.grey,
              ),
              SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: hasDoc ? AppColor.primary : AppColor.grey,
                ),
              ),
              if (hasDoc)
                Text(
                  'Long press to share',
                  style: TextStyle(
                    fontSize: 8,
                    color: AppColor.grey,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _showAddKYCDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (context) => KYCDocumentForm(controller: controller),
    );
  }

  // ==================== SHARE FUNCTIONALITY ====================

  // Share all KYC records
  Future<void> _shareAllKYC() async {
    if (controller.kycList.isEmpty) {
      Get.snackbar(
        'No Data',
        'No KYC records to share',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColor.warning,
        colorText: AppColor.white,
      );
      return;
    }

    String shareText = "🏢 KYC DOCUMENTS SUMMARY\n";
    shareText += "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n";
    shareText += "Total Records: ${controller.kycList.length}\n";
    shareText += "Generated: ${_formatDate(DateTime.now())}\n\n";
    shareText += "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n";

    for (int i = 0; i < controller.kycList.length; i++) {
      final kyc = controller.kycList[i];
      shareText += "📄 RECORD ${i + 1}\n";
      shareText += "────────────────────────────────────────\n";
      shareText += "👤 Name: ${kyc.name}\n";
      shareText += "🪪 PAN: ${kyc.panNo}\n";
      shareText += "🆔 Aadhar: ${kyc.aadharNo}\n";
      shareText += "📅 Submitted: ${_formatDate(kyc.createdAt)}\n";
      shareText += "✅ Status: Verified\n\n";
    }

    shareText += "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n";
    shareText += "🔒 This is an official KYC document summary.\n";
    shareText += "📱 Generated via KYC Management App\n";

    await Share.share(shareText, subject: 'KYC Documents Summary');
  }

  // Share single KYC details
  Future<void> _shareSingleKYC(KYCDocument kyc) async {
    String shareText = "🏢 KYC DOCUMENT DETAILS\n";
    shareText += "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n";
    shareText += "👤 Full Name: ${kyc.name}\n";
    shareText += "🪪 PAN Number: ${kyc.panNo}\n";
    shareText += "🆔 Aadhar Number: ${kyc.aadharNo}\n";
    shareText += "📅 Submitted Date: ${_formatDate(kyc.createdAt)}\n";
    shareText += "✅ Verification Status: Verified\n\n";

    shareText += "📄 DOCUMENTS INCLUDED:\n";
    shareText += "────────────────────────────────────────\n";
    if (kyc.panDoc.isNotEmpty) shareText += "✓ PAN Card Image: Available\n";
    if (kyc.aadharDoc.isNotEmpty) shareText += "✓ Aadhar Card Image: Available\n";
    if (kyc.signDoc.isNotEmpty) shareText += "✓ Signature Image: Available\n";

    shareText += "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n";
    shareText += "🔒 Official KYC Record\n";
    shareText += "📱 Generated via KYC Management App\n";

    await Share.share(shareText, subject: 'KYC Details - ${kyc.name}');
  }

  // Share KYC with all documents
  Future<void> _shareKYCWithDocuments(KYCDocument kyc) async {
    showModalBottomSheet(
      context: Get.context!,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Share ${kyc.name}\'s KYC',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColor.textMain,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Choose what to share',
                style: TextStyle(color: AppColor.textSecondary, fontSize: 14),
              ),
              SizedBox(height: 20),
              _buildShareOption(
                icon: Icons.text_snippet_rounded,
                title: 'Share as Text',
                subtitle: 'Share KYC details as text message',
                onTap: () {
                  Get.back();
                  _shareSingleKYC(kyc);
                },
                color: AppColor.primary,
              ),
              Divider(height: 1, color: AppColor.lightGrey),
              _buildShareOption(
                icon: Icons.image_rounded,
                title: 'Share PAN Card',
                subtitle: 'Share PAN document image',
                onTap: () {
                  Get.back();
                  if (kyc.panDoc.isNotEmpty) {
                    _shareDocument(kyc.panDoc, 'PAN Card');
                  } else {
                    _showNoDocumentError('PAN Card');
                  }
                },
                color: Colors.orange,
                enabled: kyc.panDoc.isNotEmpty,
              ),
              Divider(height: 1, color: AppColor.lightGrey),
              _buildShareOption(
                icon: Icons.credit_card_rounded,
                title: 'Share Aadhar Card',
                subtitle: 'Share Aadhar document image',
                onTap: () {
                  Get.back();
                  if (kyc.aadharDoc.isNotEmpty) {
                    _shareDocument(kyc.aadharDoc, 'Aadhar Card');
                  } else {
                    _showNoDocumentError('Aadhar Card');
                  }
                },
                color: Colors.green,
                enabled: kyc.aadharDoc.isNotEmpty,
              ),
              Divider(height: 1, color: AppColor.lightGrey),
              _buildShareOption(
                icon: Icons.draw_rounded,
                title: 'Share Signature',
                subtitle: 'Share signature image',
                onTap: () {
                  Get.back();
                  if (kyc.signDoc.isNotEmpty) {
                    _shareDocument(kyc.signDoc, 'Signature');
                  } else {
                    _showNoDocumentError('Signature');
                  }
                },
                color: Colors.purple,
                enabled: kyc.signDoc.isNotEmpty,
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Get.back(),
                  child: Text('Cancel'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShareOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
    bool enabled = true,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: enabled ? color : AppColor.grey),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: enabled ? AppColor.textMain : AppColor.grey,
        ),
      ),
      subtitle: Text(subtitle, style: TextStyle(color: AppColor.textSecondary, fontSize: 12)),
      enabled: enabled,
      onTap: onTap,
    );
  }

  // Share a single document
// Share a single document
  Future<void> _shareDocument(String imageUrl, String documentType) async {
    try {
      // Show loading
      Get.dialog(
        Center(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColor.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColor.primary),
                ),
                SizedBox(height: 16),
                Text(
                  'Preparing $documentType...',
                  style: TextStyle(color: AppColor.textMain),
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );

      // Download image to temporary file
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final directory = await getTemporaryDirectory();
        // Fixed: Use string interpolation correctly
        final fileName = '${documentType.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final filePath = '${directory.path}/$fileName';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        // Close loading dialog
        Get.back();

        // Share the file
        await Share.shareXFiles(
          [XFile(filePath)],
          text: '📄 $documentType for KYC verification\nShared via KYC Management App',
          subject: '$documentType Document',
        );

        // Clean up temp file after sharing
        await file.delete();
      } else {
        Get.back();
        _showError('Failed to download $documentType');
      }
    } catch (e) {
      Get.back();
      _showError('Error sharing $documentType: $e');
    }
  }
  void _showNoDocumentError(String documentType) {
    Get.snackbar(
      'No Document',
      '$documentType not available for this KYC',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColor.warning,
      colorText: AppColor.white,
    );
  }

  void _showError(String message) {
    Get.snackbar(
      'Share Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColor.error,
      colorText: AppColor.white,
      duration: Duration(seconds: 3),
    );
  }
}

// ────────────────────────────────────────────
// Document Preview Screen with Share Option
// ────────────────────────────────────────────
class DocumentPreviewScreen extends StatelessWidget {
  final String imageUrl;
  const DocumentPreviewScreen({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text('Document Preview', style: TextStyle(color: AppColor.white)),
        iconTheme: IconThemeData(color: AppColor.white),
        actions: [
          IconButton(
            icon: Icon(Icons.share_rounded, color: AppColor.white),
            onPressed: () => _shareCurrentDocument(context),
            tooltip: 'Share document',
          ),
          IconButton(
            icon: Icon(Icons.download_rounded, color: AppColor.white),
            onPressed: () => _downloadDocument(),
            tooltip: 'Download document',
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 5.0,
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            placeholder: (_, __) => Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColor.primary),
              ),
            ),
            errorWidget: (_, __, ___) => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.broken_image_rounded, size: 64, color: AppColor.grey),
                SizedBox(height: 12),
                Text('Failed to load document', style: TextStyle(color: AppColor.grey)),
                SizedBox(height: 16),
                TextButton(
                  onPressed: () => Get.back(),
                  child: Text('Go Back', style: TextStyle(color: AppColor.primarylite)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _shareCurrentDocument(BuildContext context) async {
    try {
      Get.dialog(
        Center(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColor.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColor.primary),
                ),
                SizedBox(height: 16),
                Text(
                  'Preparing document...',
                  style: TextStyle(color: AppColor.textMain),
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );

      // Download image to temporary file
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final directory = await getTemporaryDirectory();
        final filePath = '${directory.path}/document_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        // Close loading dialog
        Get.back();

        // Share the file
        await Share.shareXFiles(
          [XFile(filePath)],
          text: '📄 KYC Document\nShared via KYC Management App',
          subject: 'KYC Document',
        );

        // Clean up temp file after sharing
        await file.delete();
      } else {
        Get.back();
        _showError('Failed to download document');
      }
    } catch (e) {
      Get.back();
      _showError('Error sharing document: $e');
    }
  }

  Future<void> _downloadDocument() async {
    try {
      // Show loading
      Get.dialog(
        Center(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColor.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColor.primary),
                ),
                SizedBox(height: 16),
                Text(
                  'Downloading...',
                  style: TextStyle(color: AppColor.textMain),
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );

      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final directory = await getDownloadsDirectory() ?? await getTemporaryDirectory();
        final filePath = '${directory.path}/KYC_Document_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        Get.back();

        Get.snackbar(
          'Download Complete',
          'Document saved to ${file.path}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColor.success,
          colorText: AppColor.white,
          duration: Duration(seconds: 4),
        );
      } else {
        Get.back();
        _showError('Failed to download document');
      }
    } catch (e) {
      Get.back();
      _showError('Error downloading document: $e');
    }
  }

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColor.error,
      colorText: AppColor.white,
    );
  }
}