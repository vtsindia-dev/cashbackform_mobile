// widgets/kyc_beneficiary_selector.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../common/colours.dart';
import '../../kyc/controller/kyc_controller.dart';
import '../../kyc/model/kyc_model.dart';

class KYCBeneficiarySelector extends StatelessWidget {
  final List<KYCDocument> kycList;
  final KYCController controller;
  final void Function(List<KYCDocument> selected) onContinue;
  final VoidCallback onAddNew;

  const KYCBeneficiarySelector({
    Key? key,
    required this.kycList,
    required this.controller,
    required this.onContinue,
    required this.onAddNew,
  }) : super(key: key);

  static const _avatarPalette = [
    (bg: Color(0xFFC0DD97), fg: Color(0xFF27500A)),
    (bg: Color(0xFFB5D4F4), fg: Color(0xFF0C447C)),
    (bg: Color(0xFFFAEEDA), fg: Color(0xFF854F0B)),
    (bg: Color(0xFFF4C0D1), fg: Color(0xFF72243E)),
    (bg: Color(0xFFCECBF6), fg: Color(0xFF3C3489)),
  ];

  ({Color bg, Color fg}) _avatarColor(int index) =>
      _avatarPalette[index % _avatarPalette.length];

  String _initials(String name) {
    if (name.trim().isEmpty) return '--';

    final parts = name.trim().split(' ');

    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }

    return parts[0]
        .substring(0, parts[0].length > 2 ? 2 : parts[0].length)
        .toUpperCase();
  }

  void _openDetail(
      BuildContext context,
      KYCDocument kyc,
      int index,
      ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (_) => Obx(
            () {
              final isSelected = controller.selectedPans.contains(
                kyc.id.toString(),
              );

          return _KYCDetailSheet(
            kyc: kyc,
            avatarColor: _avatarColor(index),
            initials: _initials(kyc.name),
            isSelected: isSelected,
            onToggleSelect: () {
              controller.toggleBeneficiary(kyc);
              Get.back();
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
          () {
        final selected = controller.selectedBeneficiaries;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
              child: Text(
                'Select KYC Beneficiary',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColor.primary,
                ),
              ),
            ),

            /// GRID
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Wrap(
                spacing: 10.w,
                runSpacing: 10.h,
                children: [
                  ...kycList.asMap().entries.map((e) {
                    final index = e.key;
                    final kyc = e.value;

                    final isSelected = controller.selectedPans.contains(
                      kyc.id.toString(),
                    );

                    return _KYCCard(
                      kyc: kyc,
                      isSelected: isSelected,
                      avatarColor: _avatarColor(index),
                      initials: _initials(kyc.name),
                      onTap: () => _openDetail(context, kyc, index),
                      onLongPress: () =>
                          controller.toggleBeneficiary(kyc),
                    )
                        .animate()
                        .fadeIn(delay: (50 * index).ms)
                        .slideY(begin: 0.08, end: 0);
                  }),

                  _AddNewCard(onTap: onAddNew)
                      .animate()
                      .fadeIn(delay: (50 * kycList.length).ms),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            /// BUTTON
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                children: [
                  if (selected.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: Text(
                        selected.length == 1
                            ? '${selected.first.name} selected'
                            : '${selected.length} beneficiaries selected',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColor.textSecondary,
                        ),
                      ),
                    ),

                  Obx(
                        () => SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: controller.isSubmitting.value
                            ? null
                            : selected.isEmpty
                            ? null
                            : () => onContinue(selected),

                        icon: controller.isSubmitting.value
                            ? SizedBox(
                          width: 18.w,
                          height: 18.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                            : const Icon(
                          Icons.arrow_forward_rounded,
                          size: 18,
                        ),

                        label: Text(
                          controller.isSubmitting.value
                              ? 'Please wait...'
                              : 'KYC Verification',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                          Colors.grey.shade200,
                          disabledForegroundColor:
                          Colors.grey.shade500,
                          padding: EdgeInsets.symmetric(
                            vertical: 14.h,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(100.r),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),

            SizedBox(height: 16.h),
          ],
        );
      },
    );
  }
}

/// CARD

class _KYCCard extends StatelessWidget {
  final KYCDocument kyc;
  final bool isSelected;
  final ({Color bg, Color fg}) avatarColor;
  final String initials;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _KYCCard({
    required this.kyc,
    required this.isSelected,
    required this.avatarColor,
    required this.initials,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 150.w,
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFEAF3DE)
              : Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isSelected
                ? AppColor.primary
                : Colors.grey.shade200,
            width: isSelected ? 2 : 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20.r,
                  backgroundColor: avatarColor.bg,
                  child: Text(
                    initials,
                    style: TextStyle(
                      color: avatarColor.fg,
                      fontWeight: FontWeight.w700,
                      fontSize: 13.sp,
                    ),
                  ),
                ),

                const Spacer(),

                if (isSelected)
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppColor.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 13,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),

            SizedBox(height: 10.h),

            Text(
              kyc.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: AppColor.textMain,
              ),
            ),

            SizedBox(height: 3.h),

            Text(
              'PAN: ${kyc.panNo}',
              style: TextStyle(
                fontSize: 10.sp,
                color: AppColor.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ADD NEW CARD

class _AddNewCard extends StatelessWidget {
  final VoidCallback onTap;

  const _AddNewCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150.w,
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: AppColor.primary,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 8.h),

            Icon(
              Icons.add_circle_outline_rounded,
              color: AppColor.primary,
              size: 28.sp,
            ),

            SizedBox(height: 8.h),

            Text(
              'Add New\nBeneficiary',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColor.primary,
              ),
            ),

            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }
}

class _KYCDetailSheet extends StatelessWidget {
  final KYCDocument kyc;
  final ({Color bg, Color fg}) avatarColor;
  final String initials;
  final bool isSelected;
  final VoidCallback onToggleSelect;

  const _KYCDetailSheet({
    required this.kyc,
    required this.avatarColor,
    required this.initials,
    required this.isSelected,
    required this.onToggleSelect,
  });

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // drag handle
          Container(
            margin: EdgeInsets.only(top: 12.h, bottom: 16.h),
            width: 36.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),

          // ── header ──
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26.r,
                  backgroundColor: avatarColor.bg,
                  child: Text(
                    initials,
                    style: TextStyle(
                      color: avatarColor.fg,
                      fontWeight: FontWeight.w700,
                      fontSize: 18.sp,
                    ),
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        kyc.name,
                        style: TextStyle(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColor.textMain,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        kyc.panNo,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColor.textSecondary,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
                // verified badge
                Container(
                  padding:
                  EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF3DE),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.verified_rounded,
                          size: 12.sp, color: AppColor.primary),
                      SizedBox(width: 4.w),
                      Text(
                        'Verified',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColor.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: Colors.grey.shade100),

          // ── detail rows ──
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              children: [
                _DetailRow(
                  icon: Icons.fingerprint_rounded,
                  label: 'Aadhar number',
                  value: kyc.aadharNo,
                ),
                SizedBox(height: 14.h),
                _DetailRow(
                  icon: Icons.credit_card_rounded,
                  label: 'PAN number',
                  value: kyc.panNo,
                ),
                SizedBox(height: 14.h),
                _DetailRow(
                  icon: Icons.calendar_today_rounded,
                  label: 'Submitted on',
                  value: _formatDate(kyc.createdAt),
                ),

                SizedBox(height: 20.h),

                // ── documents ──
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Documents',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColor.textSecondary,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    _DocChip(
                      label: 'PAN',
                      icon: Icons.badge_rounded,
                      hasDoc: kyc.panDoc.isNotEmpty,
                    ),
                    SizedBox(width: 8.w),
                    _DocChip(
                      label: 'Aadhar',
                      icon: Icons.credit_card_rounded,
                      hasDoc: kyc.aadharDoc.isNotEmpty,
                    ),
                    SizedBox(width: 8.w),
                    _DocChip(
                      label: 'Signature',
                      icon: Icons.draw_rounded,
                      hasDoc: kyc.signDoc?.isNotEmpty ?? false,
                    ),
                  ],
                ),
              ],
            ),
          ),

          Divider(height: 1, color: Colors.grey.shade100),

          // ── action buttons ──
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 24.h),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300),
                      padding: EdgeInsets.symmetric(vertical: 13.h),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r)),
                    ),
                    child: Text(
                      'Close',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColor.textMain,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: onToggleSelect,
                    icon: Icon(
                      isSelected
                          ? Icons.remove_circle_outline_rounded
                          : Icons.check_circle_outline_rounded,
                      size: 18,
                    ),
                    label: Text(
                      isSelected ? 'Deselect' : 'Select this KYC',
                      style: TextStyle(
                          fontSize: 14.sp, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSelected
                          ? Colors.orange.shade700
                          : AppColor.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 13.h),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r)),
                      elevation: 0,
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
}

// ─────────────────────────────────────────────────────────────────────────────
// HELPER WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: AppColor.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, size: 16.sp, color: AppColor.primary),
        ),
        SizedBox(width: 12.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                color: AppColor.textSecondary,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColor.textMain,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DocChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool hasDoc;

  const _DocChip({
    required this.label,
    required this.icon,
    required this.hasDoc,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          color: hasDoc
              ? AppColor.primary.withOpacity(0.07)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: hasDoc
                ? AppColor.primary.withOpacity(0.3)
                : Colors.grey.shade200,
          ),
        ),
        child: Column(
          children: [
            Icon(
              hasDoc ? icon : Icons.cloud_off_rounded,
              size: 18.sp,
              color: hasDoc ? AppColor.primary : Colors.grey,
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: hasDoc ? AppColor.primary : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}