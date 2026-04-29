import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationService extends GetxService {
  static NotificationService get to => Get.find();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  @override
  void onInit() {
    super.onInit();
    _initNotifications();
  }

  Future<void> _initNotifications() async {

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("🔔 Foreground message received:");
      print("   Title: ${message.notification?.title}");
      print("   Body: ${message.notification?.body}");
      print("   Data: ${message.data}");
      _showInAppNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("🔔 Notification tapped (background): ${message.data}");
      _handleNotificationTap(message);
    });

    RemoteMessage? initialMessage =
    await _messaging.getInitialMessage();
    if (initialMessage != null) {
      print("🔔 App opened from terminated via notification");
      _handleNotificationTap(initialMessage);
    }
  }

  // ─── SHOW IN-APP SNACKBAR WHEN APP IS OPEN ──────────────────────────────────
  void _showInAppNotification(RemoteMessage message) {
    final title = message.notification?.title ?? 'Notification';
    final body = message.notification?.body ?? '';

    Get.snackbar(
      title,
      body,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.black87,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
      icon: const Icon(
        Icons.notifications,
        color: Colors.white,
      ),
      onTap: (_) {
        _handleNotificationTap(message);
      },
    );
  }

  void _handleNotificationTap(RemoteMessage message) {
    final data = message.data;
    print("🔔 Handling notification tap with data: $data");

    final String? type = data['type'];
    final String? id = data['id'];

    switch (type) {
      case 'order':
        Get.toNamed('/order-details', arguments: {'id': id});
        break;
      case 'payment':
        Get.toNamed('/payment-details', arguments: {'id': id});
        break;
      case 'dashboard':
        Get.offAllNamed('/dashboard');
        break;
      default:
      // Just go to dashboard if no specific type
        print("⚠️ Unknown notification type: $type");
        break;
    }
  }
}