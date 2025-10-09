import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart'; // <-- add in pubspec.yaml

/* ======================== Background handler ======================== */
Future<dynamic> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (kDebugMode) {
    print('BG Message data: ${message.data}');
  }
  return;
}

/* ===================== Click handling (navigate) ==================== */
Future<void> handleNotification(Map<String, dynamic> data, {bool delay = false}) async {
  switch (data['push_type']) {
    default:
      break;
  }
}

/* =========================== Service ================================ */
class PushNotificationService {
  dynamic message;

  Future<void> setupInteractedMessage() async {
    await Firebase.initializeApp();

    // Tapped while app in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      this.message = message.data;
      handleNotification(message.data);
    });

    // Tapped when app was terminated
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      final RemoteMessage? initial = await FirebaseMessaging.instance.getInitialMessage();
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

    FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: false,
      sound: true,
    );

    await registerNotificationListeners();
  }

  /* ------------------ Foreground listeners + channel ------------------ */
  Future<void> registerNotificationListeners() async {
    final channel = androidNotificationChannel();

    final FlutterLocalNotificationsPlugin fln = FlutterLocalNotificationsPlugin();
    await fln
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    const androidSettings = AndroidInitializationSettings('@drawable/customer_notification');
    const iOSSettings = DarwinInitializationSettings(
      requestSoundPermission: false,
      requestAlertPermission: false,
    );
    final initSettings = const InitializationSettings(android: androidSettings, iOS: iOSSettings);

    await fln.initialize(initSettings, onDidReceiveNotificationResponse: onDidReceiveNotificationResponse);

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen((RemoteMessage? message) async {
      if (message == null) return;

      final RemoteNotification? notification = message.notification;
      final AndroidNotification? android = notification?.android;

      if (message.data.isEmpty) return;

      this.message = message.data;

      if (!Platform.isAndroid) {
        // iOS handling can go here if needed
        return;
      }

      // Prefer data keys; fallback to Android's imageUrl if present
      final String? imageUrl =
          message.data['image'] ??
              message.data['imageUrl'] ??
              android?.imageUrl;

      // Build common android details (used in both styles)
      AndroidNotificationDetails _baseAndroidDetails({StyleInformation? style}) {
        return AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          icon: android?.smallIcon ?? '@drawable/customer_notification',
          playSound: true,
          styleInformation: style,
        );
      }

      // If we have an image, try BigPicture
      if (imageUrl != null && imageUrl.isNotEmpty) {
        final String? path = await _downloadImageToFile(imageUrl);
        if (path != null) {
          await fln.show(
            notification.hashCode,
            notification?.title,
            notification?.body,
            NotificationDetails(
              android: _baseAndroidDetails(
                style: BigPictureStyleInformation(
                  FilePathAndroidBitmap(path),
                  largeIcon: const DrawableResourceAndroidBitmap('customer_notification'),
                  contentTitle: notification?.title,
                  summaryText: notification?.body,
                  hideExpandedLargeIcon: false,
                ),
              ),
            ),
            payload: jsonEncode(message.data),
          );
          return;
        }
      }

      // Fallback to normal style
      await fln.show(
        notification.hashCode,
        notification?.title,
        notification?.body,
        NotificationDetails(android: _baseAndroidDetails()),
        payload: jsonEncode(message.data),
      );
    });
  }

  AndroidNotificationChannel androidNotificationChannel() => const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description: 'This channel is used for important notifications.',
    importance: Importance.max,
  );

  Future onDidReceiveNotificationResponse(NotificationResponse? notificationResponse) async {
    if (message != null) {
      handleNotification(message);
    }
  }

  /* -------------------- Helpers -------------------- */

  // BigPicture needs a local file path
  Future<String?> _downloadImageToFile(String url) async {
    try {
      final httpClient = HttpClient();
      final req = await httpClient.getUrl(Uri.parse(url));
      final res = await req.close();
      if (res.statusCode != 200) return null;

      final bytes = await res.fold<List<int>>([], (b, d) => b..addAll(d));
      final dir = await getTemporaryDirectory();
      final f = File('${dir.path}/notif_${DateTime.now().microsecondsSinceEpoch}.jpg');
      await f.writeAsBytes(bytes, flush: true);
      return f.path;
    } catch (e) {
      if (kDebugMode) {
        print('Image download failed: $e');
      }
      return null;
    }
  }
}
