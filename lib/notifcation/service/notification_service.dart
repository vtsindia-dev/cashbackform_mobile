import 'dart:convert';
import 'dart:math';
import 'package:cashback_farms/common/route/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin
  _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> initialize(BuildContext context) async {
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings("@mipmap/ic_launcher");
    const InitializationSettings initializationSettings =
        InitializationSettings(android: androidInitializationSettings);
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) async {
            try {
              String? payload = notificationResponse.payload;
              debugPrint(
                "================ NOTIFICATION CLICKED ================",
              );
              debugPrint("Raw Payload: $payload");
              if (payload != null && payload.isNotEmpty) {
                Map<String, dynamic> data = jsonDecode(payload);
                handleNavigation(data);
                debugPrint("Decoded Payload: $data");
                data.forEach((key, value) {
                  debugPrint("Key: $key  Value: $value");
                });
              }
              debugPrint(
                "======================================================",
              );
            } catch (e) {
              debugPrint("Notification Click Error: $e");
            }
          },
    );
  }

  static Future<void> display({
    required String? title,
    required String? body,
    Map<String, dynamic>? data,
  }) async {
    try {
      debugPrint("================ NOTIFICATION RECEIVED ================");
      debugPrint("Title: $title");
      debugPrint("Body: $body");
      debugPrint("Data Payload: $data");
      debugPrint("======================================================");
      Random random = Random();
      int notificationId = random.nextInt(100000);
      String? imageUrl = data?['image'];
      BigPictureStyleInformation? bigPictureStyleInformation;
      if (imageUrl != null && imageUrl.isNotEmpty) {
        try {
          final http.Response response = await http.get(Uri.parse(imageUrl));

          debugPrint("Image Status Code: ${response.statusCode}");

          if (response.statusCode == 200) {
            final ByteArrayAndroidBitmap bigPicture =
                ByteArrayAndroidBitmap.fromBase64String(
                  base64Encode(response.bodyBytes),
                );
            bigPictureStyleInformation = BigPictureStyleInformation(
              bigPicture,
              largeIcon: bigPicture,
              contentTitle: title ?? "",
              summaryText: body ?? "",
            );

            debugPrint("Big Image Loaded Successfully");
          }
        } catch (e) {
          debugPrint("Image Loading Error: $e");
        }
      }
      final AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
            "mychannel",
            "My Channel",
            channelDescription: "This is notification channel",
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
            ticker: "ticker",
            icon: '@mipmap/ic_launcher',
            styleInformation: bigPictureStyleInformation,
          );
      final NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
      );
      await _flutterLocalNotificationsPlugin.show(
        notificationId,
        title ?? "Notification",
        body ?? "",
        notificationDetails,
        payload: data != null ? jsonEncode(data) : null,
      );
      debugPrint("Notification Displayed Successfully ID: $notificationId");
    } catch (e) {
      debugPrint("Notification Display Error: $e");
    }
  }
}

Future<void> requestNotificationPermission() async {
  var status = await Permission.notification.status;

  if (status.isDenied || status.isRestricted) {
    status = await Permission.notification.request();
  }

  if (status.isPermanentlyDenied) {
    _showNotificationSettingsDialog();
    return;
  }

  if (status.isGranted) {
    debugPrint("Notification permission granted!");
  } else {
    debugPrint("Notification permission denied by user.");
  }
}

void _showNotificationSettingsDialog() {
  if (Get.context == null) return;

  Get.dialog(
    AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 5,
      titlePadding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 0),
      contentPadding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 24.0),
      actionsPadding: const EdgeInsets.fromLTRB(0, 0, 16.0, 16.0),
      title: Row(
        children: [
          Icon(
            Icons.notifications_rounded,
            color: Theme.of(Get.context!).primaryColor,
            size: 28,
          ),
          const SizedBox(width: 12),
          const Text(
            'Notification Permission',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: const Text(
        'Notification permission is required to receive important updates. Please enable it in your device settings.',
        style: TextStyle(
          fontSize: 15,
          color: Colors.black87,
          height: 1.4,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            foregroundColor: Colors.grey[600],
          ),
          child: const Text(
            'Cancel',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Get.back();
            openAppSettings();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(Get.context!).primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          child: const Text(
            'Open Settings',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ),
    barrierDismissible: false,
  );
}

void handleNavigation(Map<String, dynamic> data) {
  try {
    debugPrint('handleNavigation: navigating to notifications');
    Get.toNamed(AppRoutes.notification);
  } catch (e) {
    debugPrint('handleNavigation error: $e');
  }
}
