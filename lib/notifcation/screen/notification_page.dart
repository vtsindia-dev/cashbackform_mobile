import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../common/colours.dart';
import '../controller/notification_controller.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(414, 896),
      builder: (context, child) => ChangeNotifierProvider.value(
        value: NotificationController(),
        child: const Scaffold(
          backgroundColor: AppColor.backgroundLight,
          body: _NotificationsView(),
        ),
      ),
    );
  }
}

class _NotificationsView extends StatefulWidget {
  const _NotificationsView({Key? key}) : super(key: key);

  @override
  State<_NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<_NotificationsView> {
  late NotificationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = NotificationController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _controller.init();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationController>(
      builder: (context, controller, child) {
        _controller = controller;
        return Stack(
          children: [
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: SizedBox(height: 125.h)),
                _buildSectionHeader(controller),
                _buildSwipeableGrid(controller), // Changed to swipeable grid
                SliverToBoxAdapter(child: SizedBox(height: 100.h)),
              ],
            ),
            Positioned(
              top: 45.h,
              left: 20.w,
              right: 20.w,
              child: _buildIslandBar(context, controller),
            ),
          ],
        );
      },
    );
  }

  Widget _buildIslandBar(BuildContext context, NotificationController controller) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 55.h,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: AppColor.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(30.r),
            border: Border.all(color: AppColor.white.withValues(alpha:0.3)),
            boxShadow: [
              BoxShadow(
                color: AppColor.black.withValues(alpha:0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(Icons.arrow_back_rounded, size: 22.sp, color: AppColor.black),
              ),
              SizedBox(width: 12.w),
              Text(
                "Notifications",
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18.sp, letterSpacing: -0.5),
              ),
              const Spacer(),
              if (controller.hasNotifications)
                _buildActionIcon(context, controller),
            ],
          ),
        ),
      ),
    ).animate().slideY(begin: -1, curve: Curves.easeOutExpo, duration: 900.ms);
  }

  Widget _buildActionIcon(BuildContext context, NotificationController controller) {
    return InkWell(
      onTap: () => _showClearBottomSheet(context, controller),
      child: Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: AppColor.primary.withValues(alpha:0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.cleaning_services_rounded, size: 18.sp, color: AppColor.primary),
      ),
    ).animate(onPlay: (c) => c.repeat(reverse: true))
        .shimmer(duration: 2.seconds, color: AppColor.primarylite);
  }

  Widget _buildSectionHeader(NotificationController controller) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Activity Feed",
                style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w900, color: AppColor.textMain)),
            SizedBox(height: 4.h),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(color: AppColor.primary, borderRadius: BorderRadius.circular(5.r)),
                  child: Text("${controller.unreadCount} NEW",
                      style: TextStyle(fontSize: 10.sp, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                SizedBox(width: 8.w),
                Text("Since your last visit",
                    style: TextStyle(fontSize: 12.sp, color: AppColor.textSecondary)),
              ],
            ),
          ],
        ),
      ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
    );
  }

  Widget _buildSwipeableGrid(NotificationController controller) {
    if (controller.isLoading && controller.notifications.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: CircularProgressIndicator(color: AppColor.primary),
        ),
      );
    }

    if (controller.notifications.isEmpty) {
      return SliverFillRemaining(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none, size: 64.sp, color: AppColor.grey),
            SizedBox(height: 16.h),
            Text(
              "No notifications yet",
              style: TextStyle(fontSize: 16.sp, color: AppColor.textSecondary),
            ),
          ],
        ),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
              (context, index) {
            final notification = controller.notifications[index];
            return _buildSwipeableCard(context, controller, notification, index);
          },
          childCount: controller.notifications.length,
        ),
      ),
    );
  }

  // NEW: Swipeable Card with delete on swipe
  Widget _buildSwipeableCard(
      BuildContext context,
      NotificationController controller,
      Map<String, dynamic> notification,
      int index,
      ) {
    final bool isUnread = !(notification['is_read_local'] ?? false);
    final String type = notification['type'] ?? 'default';
    final int notificationId = notification['id'];

    // Different Icons for different types
    IconData getIcon() {
      switch (type) {
        case 'payment': return Icons.account_balance_wallet_rounded;
        case 'order': return Icons.local_shipping_rounded;
        case 'plot': return Icons.landscape_rounded;
        case 'material': return Icons.inventory_2_rounded;
        case 'service': return Icons.build_circle_rounded;
        default: return Icons.notifications_rounded;
      }
    }

    return Dismissible(
      key: Key('${notification['id']}_$index'),
      direction: DismissDirection.endToStart, // Swipe from right to left
      background: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(20.r),
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.w),
        child: Icon(
          Icons.delete_rounded,
          color: Colors.white,
          size: 28.sp,
        ),
      ),
      confirmDismiss: (direction) async {
        // Show confirmation dialog before deleting
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Delete Notification'),
              content: const Text('Are you sure you want to delete this notification?'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: AppColor.grey),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) async {
        controller.softDeleteNotification(notificationId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Notification deleted'),
            action: SnackBarAction(
              label: '',
              textColor: AppColor.primary,
              onPressed: () {
                controller.refreshNotifications();
              },
            ),
            duration: const Duration(seconds: 3),
          ),
        );
        final result = await controller.deleteNotification(notificationId);

        if (!result['success'] && mounted) {
          await controller.refreshNotifications();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      child: GestureDetector(
        onTap: () => _showNotificationDetail(context, notification, controller),
        child: Container(
          margin: EdgeInsets.only(bottom: 12.h),
          decoration: BoxDecoration(
            color: AppColor.white,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: isUnread ? AppColor.primary.withValues(alpha:0.08) : Colors.black.withValues(alpha:0.03),
                blurRadius: 15,
                offset: const Offset(0, 5),
              )
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(12.r),
            child: Row(
              children: [
                Container(
                  width: 50.r,
                  height: 50.r,
                  decoration: BoxDecoration(
                    color: isUnread ? AppColor.primary.withValues(alpha:0.1) : AppColor.lightGrey.withValues(alpha:0.5),
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                  child: Icon(getIcon(), color: isUnread ? AppColor.primary : AppColor.grey, size: 24.sp),
                ),
                SizedBox(width: 15.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification['title'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 14.sp, fontWeight: isUnread ? FontWeight.w900 : FontWeight.w600),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        notification['message'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12.sp, color: AppColor.textSecondary),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(_formatDateShort(notification['created_at']),
                        style: TextStyle(fontSize: 10.sp, color: AppColor.grey, fontWeight: FontWeight.bold)),
                    if (isUnread)
                      Container(
                        margin: EdgeInsets.only(top: 8.h),
                        width: 8.r,
                        height: 8.r,
                        decoration: const BoxDecoration(color: AppColor.primary, shape: BoxShape.circle),
                      ).animate(onPlay: (c) => c.repeat()).scale(begin: const Offset(1, 1), end: const Offset(1.5, 1.5)).fadeOut(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ).animate(delay: (index * 50).ms).slideX(begin: 0.1, curve: Curves.easeOut),
    );
  }
  
  void _showNotificationDetail(BuildContext context, Map<String, dynamic> notification, NotificationController controller) {
    if (!(notification['is_read_local'] ?? false)) {
      controller.markAsRead(notification['id']);
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) => Container(
          decoration: BoxDecoration(
            color: AppColor.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(35.r)),
          ),
          child: Column(
            children: [
              SizedBox(height: 12.h),
              Container(width: 50.w, height: 5.h, decoration: BoxDecoration(color: AppColor.lightGrey, borderRadius: BorderRadius.circular(10))),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 20.h),
                  children: [
                    Center(
                      child: Container(
                        padding: EdgeInsets.all(20.r),
                        decoration: BoxDecoration(
                          color: AppColor.primary.withValues(alpha:0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.mark_email_unread_rounded, size: 40.sp, color: AppColor.primary),
                      ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
                    ),
                    SizedBox(height: 20.h),
                    Center(
                      child: Text(
                        notification['type']?.toString().toUpperCase() ?? "NOTIFICATION",
                        style: TextStyle(color: AppColor.primary, fontWeight: FontWeight.w800, fontSize: 12.sp, letterSpacing: 2),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      notification['title'],
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w900, height: 1.2),
                    ),
                    SizedBox(height: 15.h),
                    const Divider(),
                    SizedBox(height: 15.h),
                    Text(
                      notification['message'],
                      style: TextStyle(fontSize: 15.sp, color: AppColor.textMain, height: 1.6),
                    ).animate().fadeIn(delay: 300.ms),
                    SizedBox(height: 30.h),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_rounded, size: 14.sp, color: AppColor.grey),
                        SizedBox(width: 8.w),
                        Text(
                          "Received on: ${_formatDateFull(notification['created_at'])}",
                          style: TextStyle(color: AppColor.grey, fontSize: 12.sp),
                        ),
                      ],
                    ),
                    SizedBox(height: 40.h),
                    // Delete button in detail view
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.red),
                              padding: EdgeInsets.symmetric(vertical: 15.h),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
                            ),
                            onPressed: () async {
                              Navigator.pop(context);
                              final result = await controller.deleteNotification(notification['id']);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(result['message']),
                                    backgroundColor: result['success'] ? Colors.green : Colors.red,
                                  ),
                                );
                              }
                            },
                            child: Text(
                              "DELETE",
                              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 15.sp),
                            ),
                          ),
                        ),
                        // SizedBox(width: 15.w),
                        // Expanded(
                        //   child: ElevatedButton(
                        //     style: ElevatedButton.styleFrom(
                        //       backgroundColor: AppColor.primary,
                        //       padding: EdgeInsets.symmetric(vertical: 15.h),
                        //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
                        //       elevation: 0,
                        //     ),
                        //     onPressed: () {
                        //       Navigator.pop(context);
                        //       controller.navigateToNotification(context, notification);
                        //     },
                        //     child: Text("VIEW DETAILS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15.sp)),
                        //   ).animate().shimmer(delay: 1.seconds),
                        // ),
                      ],
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showClearBottomSheet(BuildContext context, NotificationController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(24.r),
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 10.h),
            Text("Clear Inbox?", style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w900)),
            SizedBox(height: 12.h),
            Text("Would you like to mark all notifications as read?", textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14.sp, color: AppColor.textSecondary)),
            SizedBox(height: 25.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColor.lightGrey),
                      padding: EdgeInsets.symmetric(vertical: 15.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text("CANCEL", style: TextStyle(color: AppColor.grey, fontWeight: FontWeight.bold)),
                  ),
                ),
                SizedBox(width: 15.w),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primary,
                      padding: EdgeInsets.symmetric(vertical: 15.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
                    ),
                    onPressed: () async {
                      await controller.markAllAsRead();
                      if (mounted) Navigator.pop(context);
                    },
                    child: const Text("CLEAR ALL", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  String _formatDateShort(String date) {
    try {
      final dt = DateTime.parse(date);
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inDays > 0) return '${diff.inDays}d';
      if (diff.inHours > 0) return '${diff.inHours}h';
      if (diff.inMinutes > 0) return '${diff.inMinutes}m';
      return 'Now';
    } catch (_) { return "Now"; }
  }

  String _formatDateFull(String date) {
    try {
      final dt = DateTime.parse(date);
      return "${dt.day}/${dt.month}/${dt.year} at ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
    } catch (_) { return date; }
  }
}