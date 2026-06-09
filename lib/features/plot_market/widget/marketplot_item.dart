import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../model/plot_market.dart';

class MarketPlotItem extends StatefulWidget {
  final MarketPlot plot;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onVerify;
  final Future<void> Function()? onRenew;
  final bool isOwner;

  const MarketPlotItem({
    super.key,
    required this.plot,
    required this.onTap,
    this.onEdit,
    this.onDelete,
    this.onVerify,
    this.onRenew,
    this.isOwner = false,
  });

  @override
  State<MarketPlotItem> createState() => _MarketPlotItemState();
}

class _MarketPlotItemState extends State<MarketPlotItem> {

  bool _renewLoading = false;
  MarketPlot get plot => widget.plot;

  bool get isPaid => plot.documentVerification == true;
  bool get isVerified => plot.verifyStatus == 1;
  bool get showRenew => widget.isOwner && plot.status == 0;
  bool get showPayVerify => widget.isOwner && !isPaid && !isVerified;

  String get verifyBadgeText => isVerified ? "Verified ✓" : "Not Verified";
  Color get verifyBadgeColor => isVerified ? Colors.green : Colors.grey;

  Future<void> _handleRenew() async {
    if (widget.onRenew == null) return;
    setState(() => _renewLoading = true);
    await widget.onRenew!();
    if (mounted) setState(() => _renewLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: InkWell(
        borderRadius: BorderRadius.circular(20.r),
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20.r),
                    ),
                    child: SizedBox(
                      height: 180.h,
                      width: double.infinity,
                      child: plot.images.isNotEmpty
                          ? Image.network(
                        plot.images[0],
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Image.asset(
                          'assets/images/placeholder_property.jpg',
                          fit: BoxFit.cover,
                        ),
                      )
                          : Image.asset(
                        'assets/images/placeholder_property.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  if (widget.isOwner)
                    Positioned(
                      top: 10.h,
                      right: 10.w,
                      child: _menuButton(),
                    ),
                  Positioned(
                    bottom: 10.h,
                    left: 10.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Text(
                        plot.formattedPrice,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plot.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 15.sp, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      plot.location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 12.sp, color: Colors.grey.shade600),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      plot.formattedArea,
                      style: TextStyle(
                          fontSize: 12.sp, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 10.h),
                    if (widget.isOwner) ...[
                      Row(
                        children: [
                          if (showRenew) ...[
                            Expanded(child: _renewButton()),
                            SizedBox(width: 8.w),
                          ],
                          if (showPayVerify) ...[
                            Expanded(child: _verifyButton()),
                            SizedBox(width: 8.w),
                          ],
                        ],
                      ),
                      SizedBox(height: 10.h),
                    ],
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 6.h,
                      children: [
                        _badge(
                          isVerified ? Icons.check_circle : Icons.cancel,
                          verifyBadgeText,
                          verifyBadgeColor,
                        ),
                        if (isPaid)
                          _badge(Icons.verified, 'Paid', Colors.green),
                        if (plot.status == 0)
                          _badge(Icons.pause_circle_outline_rounded,
                              'Inactive', Colors.orange.shade700),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _renewButton() => GestureDetector(
        onTap: _renewLoading ? null : _handleRenew,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 9.h),
          decoration: BoxDecoration(
            color: _renewLoading
                ? const Color(0xFF1565C0).withValues(alpha: 0.6)
                : const Color(0xFF1565C0),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_renewLoading) ...[
                SizedBox(
                  width: 13.sp,
                  height: 13.sp,
                  child: const CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                ),
                SizedBox(width: 6.w),
                Text('Loading...',
                    style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ] else ...[
                Icon(Icons.autorenew_rounded,
                    size: 13.sp, color: Colors.white),
                SizedBox(width: 5.w),
                Text('Renew',
                    style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ],
            ],
          ),
        ),
      );

  Widget _verifyButton() => GestureDetector(
        onTap: widget.onVerify,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 9.h),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: Colors.orange.withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.verified, size: 13.sp, color: Colors.orange),
              SizedBox(width: 5.w),
              Text('Pay to Verify',
                  style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.orange)),
            ],
          ),
        ),
      );

  Widget _badge(IconData icon, String label, Color color) => Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12.sp, color: color),
            SizedBox(width: 4.w),
            Text(label,
                style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: color)),
          ],
        ),
      );

  Widget _menuButton() => Container(
        height: 30.w,
        width: 30.w,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
        ),
        child: PopupMenuButton<String>(
          padding: EdgeInsets.zero,
          icon: Icon(Icons.more_vert, size: 18.sp),
          onSelected: (val) {
            if (val == 'edit') widget.onEdit?.call();
            if (val == 'delete') widget.onDelete?.call();
          },
          itemBuilder: (context) => [
            _menuItem('edit', Icons.edit, 'Edit'),
            _menuItem('delete', Icons.delete, 'Delete', isRed: true),
          ],
        ),
      );

  PopupMenuItem<String> _menuItem(String val, IconData icon, String text,
      {bool isRed = false}) =>
      PopupMenuItem(
        value: val,
        child: Row(
          children: [
            Icon(icon,
                size: 16.sp, color: isRed ? Colors.red : Colors.black),
            SizedBox(width: 8.w),
            Text(text,
                style: TextStyle(
                    fontSize: 13.sp,
                    color: isRed ? Colors.red : Colors.black)),
          ],
        ),
      );
}