// import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salon_customer/controller/home_controller.dart';

// Local notifications
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../main.dart'; // for flutterLocalNotificationsPlugin

final _homeController = Get.find<HomeController>();

class NotificationUtils {
  // Build platform-specific notification details (Android/iOS)
  // static NotificationDetails _buildNotifDetails(RemoteMessage msg) {
  //   final rawTitle =
  //       (msg.notification?.title ?? msg.data['title'] ?? '').toString();
  //   final title = rawTitle.toLowerCase();

  //   // ---------- ANDROID ----------
  //   AndroidNotificationDetails? androidDetails;
  //   if (Platform.isAndroid) {
  //     if (title.contains('confirmed')) {
  //       androidDetails = const AndroidNotificationDetails(
  //         'confirm', 'Appointment Confirmed',
  //         channelDescription: 'Custom sound when appointment is confirmed',
  //         importance: Importance.max,
  //         priority: Priority.high,
  //         playSound: true,
  //         sound: RawResourceAndroidNotificationSound(
  //             'confirm'), // res/raw/confirm.wav
  //       );
  //     } else if (title.contains('completed')) {
  //       androidDetails = const AndroidNotificationDetails(
  //         'complete', 'Appointment Completed',
  //         channelDescription: 'Custom sound when appointment is completed',
  //         importance: Importance.max,
  //         priority: Priority.high,
  //         playSound: true,
  //         sound: RawResourceAndroidNotificationSound(
  //             'complete'), // res/raw/complete.wav
  //       );
  //     } else {
  //       androidDetails = const AndroidNotificationDetails(
  //         'general_silent',
  //         'General (Silent)',
  //         channelDescription: 'General notifications without sound',
  //         importance: Importance.defaultImportance,
  //         priority: Priority.defaultPriority,
  //         playSound: false,
  //         enableVibration: false,
  //       );
  //     }
  //   }

  //   // ---------- iOS (Darwin) ----------
  //   DarwinNotificationDetails? iosDetails;
  //   if (Platform.isIOS) {
  //     if (title.contains('confirmed')) {
  //       iosDetails = const DarwinNotificationDetails(
  //         sound:
  //             'confirm.wav', // file must be in ios/Runner and in Copy Bundle Resources
  //         presentAlert: true,
  //         presentBadge: true,
  //         presentSound: true,
  //       );
  //     } else if (title.contains('completed')) {
  //       iosDetails = const DarwinNotificationDetails(
  //         sound: 'complete.wav',
  //         presentAlert: true,
  //         presentBadge: true,
  //         presentSound: true,
  //       );
  //     } else {
  //       iosDetails = const DarwinNotificationDetails(
  //         presentAlert: true,
  //         presentBadge: true,
  //         presentSound: false, // silent for booked/others
  //       );
  //     }
  //   }

  //   return NotificationDetails(
  //     android: androidDetails,
  //     iOS: iosDetails,
  //   );
  // }

  // Unified foreground notifier (Android + iOS)
  // static Future<void> _showForegroundNotification(RemoteMessage msg) async {
  //   final notifDetails = _buildNotifDetails(msg);

  //   await flutterLocalNotificationsPlugin.show(
  //     0,
  //     msg.notification?.title ?? (msg.data['title'] as String?) ?? 'Scuts',
  //     msg.notification?.body ?? (msg.data['message'] as String?) ?? '',
  //     notifDetails,
  //     payload: msg.data['appointmentId'],
  //   );
  // }

  static Future<void> handleNotificationOnForeground(
      RemoteMessage remoteMessage) async {
    // Local notification with platform-appropriate sound/silence
    // await _showForegroundNotification(remoteMessage);

    if (remoteMessage.notification != null) {
      final String title = remoteMessage.data["title"] ??
          (remoteMessage.notification?.title ?? "Notification");
      final String message = remoteMessage.data['message'] ??
          (remoteMessage.notification?.body ?? "You have a new notification");

      _homeController.doGetCurrentBookingListData();

      _showOverlaySnackbar(
        title: title,
        message: message,
        onTap: () => handleNotificationNavigation(remoteMessage, false),
      );
    }
  }

  static void _showOverlaySnackbar({
    required String title,
    required String message,
    required VoidCallback onTap,
  }) {
    final overlay = navigatorKey.currentState?.overlay;
    if (overlay == null) return;

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) {
        final topPadding = MediaQuery.of(context).padding.top;
        return Positioned(
          top: topPadding + 12,
          left: 12,
          right: 12,
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: () {
                entry.remove();
                onTap();
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        'assets/icon/app-icon.png',
                        height: 45,
                        width: 45,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            message,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 2), () {
      if (entry.mounted) entry.remove();
    });
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
    } catch (_) {
      return false;
    }
  }

  static bool handleNotificationNavigation(
      RemoteMessage remoteMessage, bool isAppKilled) {
    if (remoteMessage.data.isNotEmpty) {
      final data = remoteMessage.data;
      final type = data['push_type'];
      navigateNotification(type, data);
    }
    return false;
  }

  static void navigateNotification(String type, Map<String, dynamic> data) {
    switch (type) {
      default:
        // Get.offAll(() => const SplashPage());
        break;
    }
  }
}
