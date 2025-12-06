import 'package:get/get.dart';
import 'package:flutter/material.dart';

class SnackBarHelper {
  static void showSuccess(String message, {Duration? duration}) {
    Get.snackbar(
      '',
      '',
      backgroundColor: Colors.black,
      snackPosition: SnackPosition.BOTTOM,
      duration: duration ?? const Duration(seconds: 2),
      margin: const EdgeInsets.only(left: 80, right: 80, bottom: 20),
      borderRadius: 20,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      maxWidth: 250,
      titleText: const SizedBox.shrink(),
      messageText: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 18),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.green,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  static void showError(String message, {Duration? duration}) {
    Get.snackbar(
      '',
      '',
      backgroundColor: Colors.black,
      snackPosition: SnackPosition.BOTTOM,
      duration: duration ?? const Duration(seconds: 2),
      margin: const EdgeInsets.only(left: 80, right: 80, bottom: 20),
      borderRadius: 20,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      maxWidth: 250,
      titleText: const SizedBox.shrink(),
      messageText: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cancel, color: Colors.red, size: 18),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  static void showInfo(String message, {Duration? duration}) {
    Get.snackbar(
      '',
      '',
      backgroundColor: Colors.black,
      snackPosition: SnackPosition.BOTTOM,
      duration: duration ?? const Duration(seconds: 2),
      margin: const EdgeInsets.only(left: 80, right: 80, bottom: 20),
      borderRadius: 20,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      maxWidth: 250,
      titleText: const SizedBox.shrink(),
      messageText: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.info, color: Colors.yellow, size: 18),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.yellow,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}