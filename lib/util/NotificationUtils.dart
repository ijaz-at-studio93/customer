import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class NotificationUtils {
  static handleNotificationOnForeground(RemoteMessage remoteMessage) {
    if (remoteMessage.notification != null) {
      String title = remoteMessage.data["title"] ?? "Notification";
      String message =
          remoteMessage.data['message'] ?? "You have a new notification";
      debugPrint('Notification $remoteMessage');
      // FlutterRingtonePlayer.playNotification();
      Get.snackbar(title, message,
          snackPosition: SnackPosition.TOP,
          icon: const Icon(Icons.notifications, color: Colors.white),
          shouldIconPulse: true,
          margin: const EdgeInsets.all(12),
          duration: const Duration(seconds: 10),
          backgroundColor: Colors.black87,
          colorText: Colors.white, onTap: (_) {
        Get.back();
        handleNotificationNavigation(remoteMessage, false);
      });
    }
  }

  static Future<bool> handleNotificationOnAppOpened(
      {RemoteMessage? remoteMessage, bool isAppKilled = false}) async {
    try {
      remoteMessage ??= await FirebaseMessaging.instance.getInitialMessage();
      if (remoteMessage != null && remoteMessage.notification != null) {
        handleNotificationNavigation(remoteMessage, isAppKilled);
        return true;
      }
      return false;
    } catch (ex) {
      return false;
    }
  }

  static bool handleNotificationNavigation(
      RemoteMessage remoteMessage, bool isAppKilled) {
    if (remoteMessage.data.isNotEmpty) {
      var data = remoteMessage.data;
      var type = data['push_type'];

      /*if (isAppKilled) {
        Get.to(() => SplashPage(remoteMessage: remoteMessage));
      } else {*/
        navigateNotification(type, data);
      // }
    }
    return false;
  }

  static void navigateNotification(String type, Map<String, dynamic> data) {
    switch (type) {
     /* case '5':
        Get.to(() => const ReferAndEarnPage(isNotificationClick: true));
        break;
      case '6':
        Get.to(() => const ReferAndEarnPage(isNotificationClick: true));
        break;*/
      default:
        // Get.offAll(() => const SplashPage());
        break;
    }
  }
}
