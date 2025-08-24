import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';



/*background notification handler*/
Future<dynamic> firebaseMessagingBackgroundHandler(
    RemoteMessage message) async {
  await Firebase.initializeApp();


  if (kDebugMode) {
    print('Message: ${message.data}');
  }
  if (message.notification != null) {}
  return;
}

/*Handle the clicked notification.*/
Future<void> handleNotification(Map<String, dynamic> data,
    {bool delay = false}) async {
  switch (data['push_type']) {
    /*  case '5':
      Get.to(() => const ReferAndEarnPage(isNotificationClick: true));
      break;
    case '6':
      Get.to(() => const ReferAndEarnPage(isNotificationClick: true));
      break;*/
    default:
      break;
  }
}

class PushNotificationService {
  dynamic message;

  /*It is assumed that all messages contain a data field with the key 'type'*/
  Future<void> setupInteractedMessage() async {
    await Firebase.initializeApp();

    /*This function is called when the app is in the background and user clicks on the notification*/
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      this.message = message.data;
      handleNotification(message.data);
    });

    SchedulerBinding.instance.addPostFrameCallback(
      (_) async {
        await FirebaseMessaging.instance
            .getInitialMessage()
            .then((RemoteMessage? message) {
          // this.message = message?.data;
          if (message?.data.isNotEmpty ?? false) {
            Future.delayed(const Duration(milliseconds: 900))
                .then((value) => handleNotification(message!.data));
          }
        });
      },
    );

    FirebaseMessaging.instance.requestPermission(
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

  registerNotificationListeners() async {
    AndroidNotificationChannel channel = androidNotificationChannel();
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
    var androidSettings = const AndroidInitializationSettings(
      '@drawable/customer_notification',
    );
    var iOSSettings = const DarwinInitializationSettings(
      requestSoundPermission: false,
      requestAlertPermission: false,
    );
    var initSettings =
        InitializationSettings(android: androidSettings, iOS: iOSSettings);
    flutterLocalNotificationsPlugin.initialize(initSettings,
        onDidReceiveNotificationResponse: onDidReceiveNotificationResponse);
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen((RemoteMessage? message) {
      RemoteNotification? notification = message!.notification;
      AndroidNotification? android = message.notification?.android;
      /*print(notification?.title);
      print(notification?.body);*/
      if (message.data.isNotEmpty) {
        this.message = message.data;
        if (Platform.isAndroid) {
          flutterLocalNotificationsPlugin.show(
              notification.hashCode,
              notification?.title,
              notification?.body,
              NotificationDetails(
                android: AndroidNotificationDetails(
                  channel.id,
                  channel.name,
                  channelDescription: channel.description,
                  icon: android?.smallIcon,
                  /* sound:   const RawResourceAndroidNotificationSound("assets/notification_sound.mp3")*/
                  playSound: true,
                ),
              ),
              payload: jsonEncode(message.data));
        }
      }
    });
  }

  androidNotificationChannel() => const AndroidNotificationChannel(
        'high_importance_channel', // id
        'High Importance Notifications', // title
        description: 'This channel is used for important notifications.',
        // description
        importance: Importance.max,
      );

  Future onDidReceiveNotificationResponse(
      NotificationResponse? notificationResponse) async {
    if (message != null) {
      handleNotification(message);
    }
  }

  /* Handle the clicked notification.*/
  Future<void> handleNotification(Map<String, dynamic> data,
      {bool delay = false}) async {
    message = data;
    switch (message['push_type']) {
      /* case '5':
        Get.to(() => const ReferAndEarnPage(isNotificationClick: true));
        if (tabController != null) {
          tabController?.animateTo(1);
        }
        break;
      case '6':
        Get.to(() => const ReferAndEarnPage(isNotificationClick: true));
        if (tabController != null) {
          tabController?.animateTo(1);
        }
        break;*/
      default:
        break;
    }
  }
}
