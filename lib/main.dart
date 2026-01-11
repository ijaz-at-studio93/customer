import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:salon_customer/api/dio_client.dart';
import 'package:salon_customer/controller/auth_controller.dart';
import 'package:salon_customer/controller/home_controller.dart';
import 'package:salon_customer/page/splash_page.dart';
import 'package:salon_customer/util/NotificationUtils.dart';
import 'package:salon_customer/util/SharedPrefs.dart';
import 'package:salon_customer/util/notification_service.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

Future<void> _setupAndroidChannels() async {
  // Confirm (sound)
  const AndroidNotificationChannel confirm = AndroidNotificationChannel(
    'confirm',
    'Appointment Confirmed',
    description: 'Custom sound when appointment is confirmed',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
    sound: RawResourceAndroidNotificationSound('confirm'), // res/raw/confirm.wav
  );

  // Completed (sound)
  const AndroidNotificationChannel completed = AndroidNotificationChannel(
    'complete',
    'Appointment Completed',
    description: 'Custom sound when appointment is completed',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
    sound: RawResourceAndroidNotificationSound('complete'), // res/raw/complete.wav
  );

  // General/Silent (for booked)
  const AndroidNotificationChannel generalSilent = AndroidNotificationChannel(
    'general_silent',
    'General (Silent)',
    description: 'General notifications without sound',
    importance: Importance.defaultImportance,
    playSound: false, // 👈 silent
    enableVibration: false,
  );

  final impl = flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

  await impl?.createNotificationChannel(confirm);
  await impl?.createNotificationChannel(completed);
  await impl?.createNotificationChannel(generalSilent);
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DioClient.init();
  await Firebase.initializeApp();
  // 👇 NEW: initialize local notifications plugin (safe on iOS too)
  const AndroidInitializationSettings androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initSettings = InitializationSettings(android: androidInit);
  await flutterLocalNotificationsPlugin.initialize(initSettings);

  // 👇 NEW: create the channel BEFORE receiving any notifications
  if (Platform.isAndroid) {
    await _setupAndroidChannels();
  }
  Get.put(AuthController());
  Get.put(HomeController());
  await GetStorage.init();
  await Get.find<AuthController>().initUserData();
  await FirebaseMessaging.instance.setAutoInitEnabled(true);
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await PushNotificationService().setupInteractedMessage();
  await Permission.notification.isDenied.then((value) {
    if (value) {
      Permission.notification.request();
    }
  });
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initFCM();
    initNotification();
  }

  initFCM() async {
    String? fcmToken = await FirebaseMessaging.instance.getToken();
    debugPrint(fcmToken);
    await SharedPrefs.writeValue(PrefConstants.fcmToken, fcmToken);
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      SharedPrefs.writeValue(PrefConstants.fcmToken, fcmToken);
    });
  }

  getFCMToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    await SharedPrefs.writeValue(PrefConstants.fcmToken, token);
  }

  initNotification() async {
    String? token = Platform.isAndroid
        ? await FirebaseMessaging.instance.getToken()
        : await FirebaseMessaging.instance.getAPNSToken();

    await SharedPrefs.writeValue(PrefConstants.fcmToken, token);

    FirebaseMessaging.instance.onTokenRefresh.listen((token) async {
      await SharedPrefs.writeValue(PrefConstants.fcmToken, token);
      debugPrint('FirebaseToken: $token');
    });

    FirebaseMessaging.onMessage.listen(
      (event) {
        NotificationUtils.handleNotificationOnForeground(event);
      },
    );

    FirebaseMessaging.onMessageOpenedApp.listen(
      (event) {
        NotificationUtils.handleNotificationOnAppOpened(remoteMessage: event);
      },
    );
    SchedulerBinding.instance.addPostFrameCallback(
      (_) {
        NotificationUtils.handleNotificationOnAppOpened();
      },
    );
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      NotificationUtils.handleNotificationOnAppOpened(
          remoteMessage: message, isAppKilled: true);
    });
    debugPrint(
        'GetFirebaseToken1: ${SharedPrefs.readStringValue(PrefConstants.fcmToken)}');
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Scuts',
      theme: ThemeData(
        fontFamily: "Roboto",
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: false,
      ),
      initialRoute: "/",
      getPages: [GetPage(name: "/", page: () => const SplashPage())],
    );
  }
}
