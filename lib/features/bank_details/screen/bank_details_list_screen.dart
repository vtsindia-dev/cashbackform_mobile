// view/bank_details_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../common/colours.dart';
import '../../../common/widget/appbar.dart';
import '../controller/bank_details_controller.dart';
import '../model/bank_details_model.dart';
import 'bank_details_form.dart';

class BankDetailsListScreen extends StatelessWidget {
  const BankDetailsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BankDetailsController());

    return Scaffold(
      backgroundColor: const Color(0xFFF2F5F8),
      appBar: DynamicAppBar(
        title: 'Account Details',
        showBackButton: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const _ShimmerLoader();
        }

        if (controller.allBankDetails.isEmpty) {
          return _EmptyState(
            onAdd: () => openBankDetailsForm(context, controller, isEdit: false),
          );
        }

        return RefreshIndicator(
          color: AppColor.primary,
          onRefresh: controller.fetchBankDetails,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ── Header row ────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      _CountChip(count: controller.allBankDetails.length),
                      const Spacer(),
                      _AddButton(
                        onTap: () => openBankDetailsForm(context, controller, isEdit: false),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Card list ─────────────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, i) {
                      // Using a ValueKey keeps card expansion states uniquely assigned to items
                      final item = controller.allBankDetails[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _ExpandableBankCard(
                          key: ValueKey(item.id ?? i.toString()),
                          details: item,
                          controller: controller,
                          accentIndex: i,
                        ),
                      );
                    },
                    childCount: controller.allBankDetails.length,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EXPANDABLE BANK CARD
// ─────────────────────────────────────────────────────────────────────────────
class _ExpandableBankCard extends StatefulWidget {
  final BankDetails details;
  final BankDetailsController controller;
  final int accentIndex;

  const _ExpandableBankCard({
    super.key,
    required this.details,
    required this.controller,
    required this.accentIndex,
  });

  @override
  State<_ExpandableBankCard> createState() => _ExpandableBankCardState();
}

class _ExpandableBankCardState extends State<_ExpandableBankCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _expandAnim;
  bool _isExpanded = false;

  static const _accents = [
    Color(0xFF4a7c3f),
    Color(0xFF1B6AB5),
    Color(0xFF6A5ACD),
    Color(0xFFB5451B),
    Color(0xFF2E7D8C),
  ];

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _expandAnim = CurvedAnimation(
      parent: _animCtrl,
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _isExpanded = !_isExpanded);
    _isExpanded ? _animCtrl.forward() : _animCtrl.reverse();
  }

  Color get accent => _accents[widget.accentIndex % _accents.length];

  @override
  Widget build(BuildContext context) {
    final d = widget.details;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.10),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Coloured header ────────────────────────────────────────────
          GestureDetector(
            onTap: _toggle,
            behavior: HitTestBehavior.opaque,
            child: Container(
              color: accent,
              padding: const EdgeInsets.fromLTRB(14, 13, 8, 13),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.account_balance_rounded,
                        color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Transfer',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          d.bankName?.toUpperCase() ?? 'BANK ACCOUNT',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.85),
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  _StatusPill(isActive: d.isActive),
                  const SizedBox(width: 4),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 4),
                  _CardMenu(
                    details: d,
                    controller: widget.controller,
                    iconColor: Colors.white,
                  ),
                ],
              ),
            ),
          ),

          // ── Account number bar (always visible) ────────────────────────
          GestureDetector(
            onTap: _toggle,
            behavior: HitTestBehavior.opaque,
            child: Container(
              color: accent.withValues(alpha: 0.06),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  Icon(Icons.credit_card_rounded, size: 15, color: accent),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      d.maskedAccount.isNotEmpty ? d.maskedAccount : '—— —— ——',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: accent,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  if (d.bankAccountNumber?.isNotEmpty == true)
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: d.bankAccountNumber!));
                        Get.snackbar(
                          'Copied',
                          'Account number copied to clipboard',
                          snackPosition: SnackPosition.BOTTOM,
                          duration: const Duration(seconds: 2),
                          margin: const EdgeInsets.all(16),
                          backgroundColor: Colors.black87,
                          colorText: Colors.white,
                          borderRadius: 12,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: accent.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.copy_all_rounded, size: 12, color: accent),
                            const SizedBox(width: 4),
                            Text(
                              'Copy',
                              style: TextStyle(
                                fontSize: 11,
                                color: accent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ── Expandable details ──────────────────────────────────────────
          SizeTransition(
            sizeFactor: _expandAnim,
            axisAlignment: 1.0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _SectionHeader(
                  icon: Icons.account_balance_outlined,
                  label: 'Bank Information',
                  color: accent,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 4, 14, 8),
                  child: Column(
                    children: [
                      _InfoTile(
                        icon: Icons.tag_rounded,
                        label: 'IFSC Code',
                        value: d.ifscCode ?? '—',
                        accent: accent,
                      ),
                      _InfoTile(
                        icon: Icons.person_outline_rounded,
                        label: 'Account Holder',
                        value: d.accountHolderName ?? '—',
                        accent: accent,
                      ),
                      _InfoTile(
                        icon: Icons.location_on_outlined,
                        label: 'Branch',
                        value: d.branchName ?? '—',
                        accent: accent,
                      ),
                      _InfoTile(
                        icon: Icons.phone_outlined,
                        label: 'Mobile Number',
                        value: d.phoneNumber ?? '—',
                        accent: accent,
                      ),
                    ],
                  ),
                ),
                if (d.upiId?.isNotEmpty == true || d.upiPhone?.isNotEmpty == true) ...[
                  _SectionHeader(
                    icon: Icons.qr_code_scanner_rounded,
                    label: 'UPI Details',
                    color: accent,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 4, 14, 8),
                    child: Column(
                      children: [
                        if (d.upiId?.isNotEmpty == true)
                          _InfoTile(
                            icon: Icons.alternate_email_rounded,
                            label: 'UPI ID',
                            value: d.upiId!,
                            accent: accent,
                          ),
                        if (d.upiPhone?.isNotEmpty == true)
                          _InfoTile(
                            icon: Icons.phone_android_rounded,
                            label: 'UPI Mobile',
                            value: d.upiPhone!,
                            accent: accent,
                          ),
                      ],
                    ),
                  ),
                ],
                const Divider(height: 1, thickness: 0.5),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
                  child: Row(
                    children: [
                      Expanded(
                        child: _ActionButton(
                          label: 'Edit',
                          icon: Icons.edit_rounded,
                          color: accent,
                          onTap: () {
                            widget.controller.startEdit(d);
                            openBankDetailsForm(context, widget.controller, isEdit: true);
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ActionButton(
                          label: 'Delete',
                          icon: Icons.delete_outline_rounded,
                          color: const Color(0xFFD32F2F),
                          onTap: () => widget.controller.showDeleteDialog(d.id,context),
                        ),
                      ),
                    ],
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
// SECTION HEADER
// ─────────────────────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _SectionHeader({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 10, 14, 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(icon, size: 13, color: color),
          ),
          const SizedBox(width: 7),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Divider(color: color.withValues(alpha: 0.2), height: 1),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// INFO TILE
// ─────────────────────────────────────────────────────────────────────────────
class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color accent;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 15, color: accent),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: AppColor.textSecondary),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColor.textMain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STATUS PILL
// ─────────────────────────────────────────────────────────────────────────────
class _StatusPill extends StatelessWidget {
  final bool isActive;
  const _StatusPill({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.white.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.35), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF69F0AE) : Colors.white54,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            isActive ? 'Active' : 'Inactive',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// THREE-DOT MENU
// ─────────────────────────────────────────────────────────────────────────────
class _CardMenu extends StatelessWidget {
  final BankDetails details;
  final BankDetailsController controller;
  final Color iconColor;

  const _CardMenu({
    required this.details,
    required this.controller,
    this.iconColor = const Color(0xFF666666),
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert_rounded, size: 20, color: iconColor),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 6,
      onSelected: (value) {
        if (value == 'edit') {
          controller.startEdit(details);
          openBankDetailsForm(context, controller, isEdit: true);
        } else if (value == 'delete') {
          controller.showDeleteDialog(details.id,context);
        } else if (value == 'toggle') {
          controller.toggleStatus(details);
        }
      },
      itemBuilder: (_) => [
        _menuItem(
          value: 'toggle',
          icon: details.isActive ? Icons.toggle_off_outlined : Icons.toggle_on_outlined,
          label: details.isActive ? 'Set Inactive' : 'Set Active',
          color: details.isActive ? const Color(0xFFE65100) : const Color(0xFF2E7D32),
        ),
        _menuItem(value: 'edit', icon: Icons.edit_rounded, label: 'Edit', color: AppColor.primary),
        _menuItem(value: 'delete', icon: Icons.delete_outline_rounded, label: 'Delete', color: Colors.red),
      ],
    );
  }

  PopupMenuItem<String> _menuItem({
    required String value,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ACTION BUTTON
// ─────────────────────────────────────────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// COUNT CHIP
// ─────────────────────────────────────────────────────────────────────────────
class _CountChip extends StatelessWidget {
  final int count;
  const _CountChip({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColor.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.account_balance_rounded, size: 13, color: AppColor.primary),
          const SizedBox(width: 5),
          Text(
            '$count Account${count != 1 ? 's' : ''}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColor.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ADD BUTTON
// ─────────────────────────────────────────────────────────────────────────────
class _AddButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: AppColor.primary,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: AppColor.primary.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.add_rounded, size: 16, color: Colors.white),
            SizedBox(width: 5),
            Text(
              'Add Details',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHIMMER LOADER
// ─────────────────────────────────────────────────────────────────────────────
class _ShimmerLoader extends StatefulWidget {
  const _ShimmerLoader();

  @override
  State<_ShimmerLoader> createState() => _ShimmerLoaderState();
}

class _ShimmerLoaderState extends State<_ShimmerLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.25, end: 0.6)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 3,
        itemBuilder: (_, i) => Container(
          margin: const EdgeInsets.only(bottom: 14),
          height: 80,
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: _anim.value),
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EMPTY STATE
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(26),
              decoration: BoxDecoration(
                color: AppColor.primary.withValues(alpha: 0.07),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.account_balance_outlined, size: 42, color: AppColor.primary),
            ),
            const SizedBox(height: 22),
            Text(
              'No Account Details Yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColor.textMain),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your bank or UPI details\nto receive payments easily.',
              style: TextStyle(fontSize: 13, color: AppColor.textSecondary, height: 1.6),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: onAdd,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 13),
                decoration: BoxDecoration(
                  color: AppColor.primary,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColor.primary.withValues(alpha: 0.32),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.add_rounded, size: 18, color: Colors.white),
                    SizedBox(width: 6),
                    Text(
                      'Add Bank Details',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}