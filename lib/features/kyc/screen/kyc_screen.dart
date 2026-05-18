import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../../../common/colours.dart';
import '../controller/kyc_controller.dart';
import '../model/kyc_model.dart';
import 'add_kyc.dart';
import 'package:http/http.dart' as http;

class KYCListScreen extends StatelessWidget {
  final KYCController controller = Get.put(KYCController());

  KYCListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            sliver: Obx(() => _buildSliverBody(context)),
          ),
        ],
      ),
      floatingActionButton: _buildFAB(context),
    );
  }

  // ── Sliver App Bar ──────────────────────────────────────────────────────────

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 130,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColor.primary,
      iconTheme: const IconThemeData(color: Colors.white),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColor.primary,
                AppColor.primary.withOpacity(0.85),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    'KYC Documents',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Obx(() => Text(
                    '${controller.kycList.length} verification record${controller.kycList.length == 1 ? '' : 's'}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.75),
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  )),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
        collapseMode: CollapseMode.parallax,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share_rounded, color: Colors.white),
          onPressed: _shareAllKYC,
          tooltip: 'Share all KYC',
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildFAB(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _showAddKYCDialog(context),
      backgroundColor: AppColor.primary,
      foregroundColor: Colors.white,
      elevation: 4,
      icon: const Icon(Icons.add_rounded),
      label: const Text('Add KYC', style: TextStyle(fontWeight: FontWeight.w700)),
    );
  }

  // ── Sliver Body ─────────────────────────────────────────────────────────────

  Widget _buildSliverBody(BuildContext context) {
    if (controller.isLoading.value) {
      return SliverFillRemaining(child: _buildLoadingState());
    }
    if (controller.errorMessage.value.isNotEmpty && controller.kycList.isEmpty) {
      return SliverFillRemaining(child: _buildErrorState());
    }
    if (controller.kycList.isEmpty) {
      return SliverFillRemaining(child: _buildEmptyState(context));
    }
    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) => _buildKYCCard(context, controller.kycList[index], index),
        childCount: controller.kycList.length,
      ),
    );
  }

  // ── States ──────────────────────────────────────────────────────────────────

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColor.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColor.primary),
                strokeWidth: 3,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Fetching KYC records...',
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColor.error.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.wifi_off_rounded, size: 48, color: AppColor.error),
            ),
            const SizedBox(height: 20),
            const Text(
              'Something went wrong',
              style: TextStyle(
                color: Color(0xFF1A1D2E),
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF6B7280), fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: controller.fetchKYCList,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppColor.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.shield_outlined, size: 56, color: AppColor.primary),
            ),
            const SizedBox(height: 24),
            const Text(
              'No KYC Records Yet',
              style: TextStyle(
                color: Color(0xFF1A1D2E),
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Add your first KYC document\nto get started',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 14, height: 1.6),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _showAddKYCDialog(context),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add KYC Document'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── KYC Card ────────────────────────────────────────────────────────────────

  Widget _buildKYCCard(BuildContext context, KYCDocument kyc, int index) {
    final List<Color> accentColors = [
      const Color(0xFF6366F1),
      const Color(0xFF0EA5E9),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFFEF4444),
    ];
    final accentColor = accentColors[index % accentColors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            // ── Card Header ─────────────────────────────────────────────────
            _buildCardHeader(context, kyc, index, accentColor),
            // ── Expandable Content ──────────────────────────────────────────
            _buildExpandableContent(context, kyc, accentColor),
          ],
        ),
      ),
    );
  }

  Widget _buildCardHeader(
      BuildContext context, KYCDocument kyc, int index, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                kyc.name.isNotEmpty ? kyc.name[0].toUpperCase() : '?',
                style: TextStyle(
                  color: accentColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Name & PAN
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  kyc.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1D2E),
                    fontSize: 15,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(Icons.credit_card_rounded,
                        size: 12, color: accentColor.withOpacity(0.7)),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        kyc.panNo,
                        style: TextStyle(
                          color: accentColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Action buttons
          _buildActionButtons(context, kyc),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, KYCDocument kyc) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildIconBtn(
          icon: Icons.share_rounded,
          color: AppColor.primary,
          onTap: () => _shareSingleKYC(kyc),
        ),
        const SizedBox(width: 4),
        _buildIconBtn(
          icon: Icons.edit_rounded,
          color: const Color(0xFF0EA5E9),
          onTap: () => _showEditKYCDialog(context, kyc),
        ),
        const SizedBox(width: 4),
        Obx(() {
          final isDeleting = controller.deletingIds.contains(kyc.id);
          return isDeleting
              ? Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColor.error.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColor.error),
                ),
              ),
            ),
          )
              : _buildIconBtn(
            icon: Icons.delete_outline_rounded,
            color: AppColor.error,
            onTap: () => controller.showDeleteConfirmDialog(kyc),
          );
        }),
      ],
    );
  }

  Widget _buildIconBtn({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 17, color: color),
      ),
    );
  }

  Widget _buildExpandableContent(
      BuildContext context, KYCDocument kyc, Color accentColor) {
    return Theme(
      data: ThemeData().copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        childrenPadding: EdgeInsets.zero,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: accentColor.withOpacity(0.2)),
              ),
              child: Text(
                'View Details',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: accentColor,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        ),
        trailing: Icon(Icons.keyboard_arrow_down_rounded,
            color: const Color(0xFF9CA3AF)),
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFF0F0F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info chips
                _buildInfoRow(Icons.fingerprint_rounded, 'Aadhar', kyc.aadharNo),
                const SizedBox(height: 10),
                _buildInfoRow(
                    Icons.calendar_today_rounded, 'Submitted', _formatDate(kyc.createdAt)),
                const SizedBox(height: 16),

                // Documents label + share
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'DOCUMENTS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF9CA3AF),
                        letterSpacing: 1.2,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _shareKYCWithDocuments(kyc),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColor.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.share_rounded,
                                size: 12, color: AppColor.primary),
                            const SizedBox(width: 4),
                            Text(
                              'Share All',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColor.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Document chips — IntrinsicHeight prevents overflow
                IntrinsicHeight(
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildDocumentTile(
                          'PAN Card',
                          Icons.badge_rounded,
                          kyc.panDoc,
                          const Color(0xFFF59E0B),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildDocumentTile(
                          'Aadhar',
                          Icons.credit_card_rounded,
                          kyc.aadharDoc,
                          const Color(0xFF10B981),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildDocumentTile(
                          'Signature',
                          Icons.draw_rounded,
                          kyc.signDoc ?? '',
                          const Color(0xFF6366F1),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Edit / Delete row
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showEditKYCDialog(context, kyc),
                        icon: const Icon(Icons.edit_rounded, size: 15),
                        label: const Text('Edit'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF0EA5E9),
                          side: const BorderSide(color: Color(0xFF0EA5E9)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          textStyle: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Obx(() {
                        final isDeleting = controller.deletingIds.contains(kyc.id);
                        return isDeleting
                            ? OutlinedButton(
                          onPressed: null,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColor.error,
                            side: BorderSide(
                                color: AppColor.error.withOpacity(0.4)),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 11),
                          ),
                          child: SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                              AlwaysStoppedAnimation<Color>(AppColor.error),
                            ),
                          ),
                        )
                            : OutlinedButton.icon(
                          onPressed: () =>
                              controller.showDeleteConfirmDialog(kyc),
                          icon: const Icon(Icons.delete_outline_rounded,
                              size: 15),
                          label: const Text('Delete'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColor.error,
                            side: BorderSide(color: AppColor.error),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            textStyle: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColor.primary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF1A1D2E),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentTile(
      String label, IconData icon, String url, Color color) {
    final hasDoc = url.isNotEmpty;
    return GestureDetector(
      onTap: () {
        if (hasDoc) {
          Get.to(() => DocumentPreviewScreen(imageUrl: url));
        } else {
          Get.snackbar(
            'Unavailable',
            'No $label document on record',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
        }
      },
      onLongPress: () {
        if (hasDoc) _shareDocument(url, label);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: hasDoc ? color.withOpacity(0.07) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasDoc ? color.withOpacity(0.25) : const Color(0xFFE5E7EB),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: hasDoc ? color.withOpacity(0.12) : const Color(0xFFE5E7EB),
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasDoc ? icon : Icons.cloud_off_rounded,
                size: 17,
                color: hasDoc ? color : const Color(0xFF9CA3AF),
              ),
            ),
            const SizedBox(height: 7),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: hasDoc ? color : const Color(0xFF9CA3AF),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              hasDoc ? 'Tap to view' : 'Not added',
              style: TextStyle(
                fontSize: 8,
                color: hasDoc ? color.withOpacity(0.7) : const Color(0xFFD1D5DB),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ── Dialogs ─────────────────────────────────────────────────────────────────

  void _showAddKYCDialog(BuildContext context) {
    controller.clearForm();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (context) => KYCDocumentForm(controller: controller),
    );
  }

  void _showEditKYCDialog(BuildContext context, KYCDocument kyc) {
    controller.startEdit(kyc);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (context) => KYCDocumentForm(controller: controller, isEditMode: true),
    );
  }

  // ── Share Helpers ───────────────────────────────────────────────────────────

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _shareAllKYC() async {
    if (controller.kycList.isEmpty) {
      Get.snackbar('No Data', 'No KYC records to share',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white);
      return;
    }
    String text = "🏢 KYC DOCUMENTS SUMMARY\n━━━━━━━━━━━━━━━━━━━━━━\n\n";
    text += "Total: ${controller.kycList.length} record(s)\n";
    text += "Date: ${_formatDate(DateTime.now())}\n\n";
    for (int i = 0; i < controller.kycList.length; i++) {
      final kyc = controller.kycList[i];
      text += "📄 #${i + 1} ${kyc.name}\n";
      text += "PAN: ${kyc.panNo} | Aadhar: ${kyc.aadharNo}\n\n";
    }
    await Share.share(text, subject: 'KYC Summary');
  }

  Future<void> _shareSingleKYC(KYCDocument kyc) async {
    String text = "🏢 KYC DETAILS\n━━━━━━━━━━━━━━━━━━━━━━\n\n";
    text += "👤 Name: ${kyc.name}\n";
    text += "🪪 PAN: ${kyc.panNo}\n";
    text += "🆔 Aadhar: ${kyc.aadharNo}\n";
    text += "📅 Submitted: ${_formatDate(kyc.createdAt)}\n\n";
    if (kyc.panDoc.isNotEmpty) text += "✓ PAN Card: Available\n";
    if (kyc.aadharDoc.isNotEmpty) text += "✓ Aadhar Card: Available\n";
    if (kyc.signDoc != null && kyc.signDoc!.isNotEmpty)
      text += "✓ Signature: Available\n";
    await Share.share(text, subject: 'KYC - ${kyc.name}');
  }

  Future<void> _shareKYCWithDocuments(KYCDocument kyc) async {
    showModalBottomSheet(
      context: Get.context!,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Share ${kyc.name}\'s KYC',
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1D2E)),
            ),
            const SizedBox(height: 4),
            const Text('Choose what to share',
                style: TextStyle(color: Color(0xFF6B7280), fontSize: 13)),
            const SizedBox(height: 16),
            _shareOptionTile(
              icon: Icons.text_snippet_rounded,
              title: 'Share as Text',
              subtitle: 'KYC info as text message',
              color: AppColor.primary,
              enabled: true,
              onTap: () { Get.back(); _shareSingleKYC(kyc); },
            ),
            _shareOptionTile(
              icon: Icons.badge_rounded,
              title: 'Share PAN Card',
              subtitle: 'PAN document image',
              color: const Color(0xFFF59E0B),
              enabled: kyc.panDoc.isNotEmpty,
              onTap: () {
                Get.back();
                kyc.panDoc.isNotEmpty
                    ? _shareDocument(kyc.panDoc, 'PAN Card')
                    : _showNoDocError('PAN Card');
              },
            ),
            _shareOptionTile(
              icon: Icons.credit_card_rounded,
              title: 'Share Aadhar Card',
              subtitle: 'Aadhar document image',
              color: const Color(0xFF10B981),
              enabled: kyc.aadharDoc.isNotEmpty,
              onTap: () {
                Get.back();
                kyc.aadharDoc.isNotEmpty
                    ? _shareDocument(kyc.aadharDoc, 'Aadhar Card')
                    : _showNoDocError('Aadhar Card');
              },
            ),
            _shareOptionTile(
              icon: Icons.draw_rounded,
              title: 'Share Signature',
              subtitle: 'Signature image',
              color: const Color(0xFF6366F1),
              enabled: kyc.signDoc != null && kyc.signDoc!.isNotEmpty,
              onTap: () {
                Get.back();
                (kyc.signDoc != null && kyc.signDoc!.isNotEmpty)
                    ? _shareDocument(kyc.signDoc!, 'Signature')
                    : _showNoDocError('Signature');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _shareOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: enabled ? color.withOpacity(0.1) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon,
            size: 20, color: enabled ? color : const Color(0xFF9CA3AF)),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: enabled ? const Color(0xFF1A1D2E) : const Color(0xFF9CA3AF),
        ),
      ),
      subtitle: Text(subtitle,
          style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
      enabled: enabled,
      onTap: onTap,
    );
  }

  Future<void> _shareDocument(String imageUrl, String documentType) async {
    try {
      Get.dialog(
        Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.symmetric(horizontal: 40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                    valueColor:
                    AlwaysStoppedAnimation<Color>(AppColor.primary)),
                const SizedBox(height: 16),
                Text('Preparing $documentType...',
                    style: const TextStyle(
                        color: Color(0xFF1A1D2E), fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final directory = await getTemporaryDirectory();
        final fileName =
            '${documentType.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final file = File('${directory.path}/$fileName');
        await file.writeAsBytes(response.bodyBytes);
        Get.back();
        await Share.shareXFiles([XFile(file.path)],
            text: '📄 $documentType — KYC Verification',
            subject: '$documentType Document');
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

  void _showNoDocError(String documentType) {
    Get.snackbar('Not Available', '$documentType not uploaded for this KYC',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white);
  }

  void _showError(String message) {
    Get.snackbar('Error', message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColor.error,
        colorText: Colors.white,
        duration: const Duration(seconds: 3));
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Document Preview Screen
// ────────────────────────────────────────────────────────────────────────────

class DocumentPreviewScreen extends StatelessWidget {
  final String imageUrl;
  const DocumentPreviewScreen({Key? key, required this.imageUrl})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text('Document Preview',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded, color: Colors.white),
            onPressed: () => _shareCurrentDocument(context),
          ),
          IconButton(
            icon: const Icon(Icons.download_rounded, color: Colors.white),
            onPressed: _downloadDocument,
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 5.0,
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            placeholder: (_, __) => const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
            errorWidget: (_, __, ___) => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.broken_image_rounded,
                    size: 64, color: Colors.grey),
                const SizedBox(height: 12),
                const Text('Failed to load document',
                    style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('Go Back',
                      style: TextStyle(color: Colors.white70)),
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
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.symmetric(horizontal: 40),
            decoration:
            BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Preparing document...'),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final directory = await getTemporaryDirectory();
        final file = File(
            '${directory.path}/document_${DateTime.now().millisecondsSinceEpoch}.jpg');
        await file.writeAsBytes(response.bodyBytes);
        Get.back();
        await Share.shareXFiles([XFile(file.path)],
            text: '📄 KYC Document', subject: 'KYC Document');
        await file.delete();
      } else {
        Get.back();
      }
    } catch (e) {
      Get.back();
    }
  }

  Future<void> _downloadDocument() async {
    try {
      Get.dialog(
        Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.symmetric(horizontal: 40),
            decoration:
            BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Downloading...'),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final directory =
            await getDownloadsDirectory() ?? await getTemporaryDirectory();
        final file = File(
            '${directory.path}/KYC_${DateTime.now().millisecondsSinceEpoch}.jpg');
        await file.writeAsBytes(response.bodyBytes);
        Get.back();
        Get.snackbar('Downloaded', 'Saved to ${file.path}',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 4));
      } else {
        Get.back();
      }
    } catch (e) {
      Get.back();
    }
  }
}