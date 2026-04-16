import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/scheduler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/* ======================== Background handler ======================== */
Future<dynamic> firebaseMessagingBackgroundHandler(
    RemoteMessage message) async {
  await Firebase.initializeApp();
  if (kDebugMode) {
    print('BG Message data: ${message.data}');
  }
  return;
}

/* ===================== Click handling (navigate) ==================== */
Future<void> handleNotification(Map<String, dynamic> data,
    {bool delay = false}) async {
  switch (data['push_type']) {
    default:
      break;
  }
}

/* =========================== Service ================================ */
class PushNotificationService {
  Future<void> setupInteractedMessage() async {
    // Firebase is already initialized in main() before this is called.
    // Tapped while app in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      handleNotification(message.data);
    });

    // Tapped when app was terminated
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      final RemoteMessage? initial =
          await FirebaseMessaging.instance.getInitialMessage();
      if (initial?.data.isNotEmpty ?? false) {
        await Future.delayed(const Duration(milliseconds: 900));
        handleNotification(initial!.data);
      }
    });

    // Permissions (Android 13+ & iOS)
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    // iOS only: when true, FCM shows a system banner in foreground *in addition to*
    // flutter_local_notifications — two notifications. Foreground UI is handled in NotificationUtils.
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: false,
      badge: false,
      sound: false,
    );

    await registerNotificationListeners();
  }

  /* ------------------ Create Android channel ------------------ */
  Future<void> registerNotificationListeners() async {
    // Create the high_importance_channel used by FCM for background/terminated
    // notifications (declared as default_notification_channel_id in AndroidManifest).
    // Foreground onMessage display is handled centrally by NotificationUtils in main.dart.
    final channel = androidNotificationChannel();
    await FlutterLocalNotificationsPlugin()
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  AndroidNotificationChannel androidNotificationChannel() =>
      const AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        description: 'This channel is used for important notifications.',
        importance: Importance.max,
      );
}
