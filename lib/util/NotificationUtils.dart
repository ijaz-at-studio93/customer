import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salon_customer/controller/home_controller.dart';

// 👇 NEW
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../main.dart'; // to access flutterLocalNotificationsPlugin

final _homeController = Get.find<HomeController>();

class NotificationUtils {

  // 👇 NEW: plays custom sound on Android foreground using channel 'confirm'
  static Future<void> _showForegroundNotification(RemoteMessage msg) async {
    final title = (msg.notification?.title ?? msg.data['title'] ?? '').toString().toLowerCase();
    final body  = (msg.notification?.body  ?? msg.data['message'] ?? '').toString().toLowerCase();

    // crude but effective routing without push_type
    late final AndroidNotificationDetails androidDetails;
    if (title.contains('Confirmed')) {
      // Confirmed -> confirm channel with confirm.wav
      androidDetails = const AndroidNotificationDetails(
        'confirm',
        'Appointment Confirmed',
        channelDescription: 'Custom sound when appointment is confirmed',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('confirm'),
      );
    } else if (title.contains('Completed')) {
      // Completed -> completed_v1 channel with complete.wav
      androidDetails = const AndroidNotificationDetails(
        'complete',
        'Appointment Completed',
        channelDescription: 'Custom sound when appointment is completed',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('complete'),
      );
    } else {
      // Booked/others -> silent
      androidDetails = const AndroidNotificationDetails(
        'general_silent',
        'General (Silent)',
        channelDescription: 'General notifications without sound',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        playSound: false,
        enableVibration: false,
      );
    }

    final notifDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      msg.notification?.title ?? (msg.data['title'] as String?) ?? 'Scuts',
      msg.notification?.body ?? (msg.data['message'] as String?) ?? '',
      notifDetails,
      payload: msg.data['appointmentId'],
    );
  }

  static handleNotificationOnForeground(RemoteMessage remoteMessage) async {

    // 🔔 NEW: trigger local notification with custom sound (Android 8+)
    await _showForegroundNotification(remoteMessage);

    if (remoteMessage.notification != null) {
      String title = remoteMessage.data["title"] ?? "Notification";
      String message =
          remoteMessage.data['message'] ?? "You have a new notification";
      debugPrint('Notification $remoteMessage');
      _homeController.doGetCurrentBookingListData();
      // FlutterRingtonePlayer.playNotification();
      Get.snackbar(title, message,
          snackPosition: SnackPosition.TOP,
          icon: const Icon(Icons.notifications, color: Colors.white),
          shouldIconPulse: true,
          margin: const EdgeInsets.all(12),
          duration: const Duration(seconds: 10),
          backgroundColor: Colors.black87,
          colorText: Colors.white, onTap: (_) async {
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
