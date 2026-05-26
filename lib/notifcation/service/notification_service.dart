import 'dart:convert';
import 'dart:math';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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

  static Future<void> display(RemoteMessage message) async {
    try {
      debugPrint("================ NOTIFICATION RECEIVED ================");
      debugPrint("Full Message:");
      debugPrint(message.toMap().toString());
      debugPrint("Title: ${message.notification?.title}");
      debugPrint("Body: ${message.notification?.body}");
      debugPrint("Data Payload: ${message.data}");
      message.data.forEach((key, value) {
        debugPrint("Key: $key  Value: $value");
      });
      debugPrint("======================================================");
      Random random = Random();
      int notificationId = random.nextInt(100000);
      String? imageUrl = message.data['image'];
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
              contentTitle: message.notification?.title ?? "",
              summaryText: message.notification?.body ?? "",
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
        message.notification?.title ?? "Notification",
        message.notification?.body ?? "",
        notificationDetails,
        payload: jsonEncode(message.data),
      );
      debugPrint("Notification Displayed Successfully ID: $notificationId");
    } catch (e) {
      debugPrint("Notification Display Error: $e");
    }
  }
}

Future<void> requestNotificationPermission() async {
  var status = await Permission.notification.status;
  if (status.isDenied) {
    final result = await Permission.notification.request();
    if (result.isGranted) {
      debugPrint("Notification permission granted!");
    } else if (result.isPermanentlyDenied) {
      openAppSettings();
    }
  } else if (status.isPermanentlyDenied) {
    openAppSettings();
  }
}

void handleNavigation(Map<String, dynamic> data) {}
