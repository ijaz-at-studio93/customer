import 'dart:async';
import 'dart:io';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
import 'package:salon_customer/constant/variable_constant.dart';
import 'package:salon_customer/util/notification_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:salon_customer/service/appsflyer_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final facebookAppEvents = FacebookAppEvents();

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _setupAndroidChannels() async {
  const AndroidNotificationChannel confirm = AndroidNotificationChannel(
    'confirm',
    'Appointment Confirmed',
    description: 'Custom sound when appointment is confirmed',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
    sound: RawResourceAndroidNotificationSound('confirm'),
  );

  const AndroidNotificationChannel completed = AndroidNotificationChannel(
    'complete',
    'Appointment Completed',
    description: 'Custom sound when appointment is completed',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
    sound: RawResourceAndroidNotificationSound('complete'),
  );

  const AndroidNotificationChannel generalSilent = AndroidNotificationChannel(
    'general_silent',
    'General (Silent)',
    description: 'General notifications without sound',
    importance: Importance.defaultImportance,
    playSound: false,
    enableVibration: false,
  );

  final impl =
      flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  await impl?.createNotificationChannel(confirm);
  await impl?.createNotificationChannel(completed);
  await impl?.createNotificationChannel(generalSilent);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SentryFlutter.init(
    (options) {
      options.dsn =
          'https://26c4ac3e31eb89df4c1676c207817fae@o4511365659230208.ingest.de.sentry.io/4511365676335184';
      //   // Adds request headers and IP for users, for more info visit:
      //   // https://docs.sentry.io/platforms/dart/guides/flutter/data-management/data-collected/
      options.sendDefaultPii = true;
      options.tracesSampleRate = 0.1;
      options.attachScreenshot = true;
      options.enableAutoNativeBreadcrumbs = true;
      options.enableAutoSessionTracking = true;
      options.enableAutoPerformanceTracing = true;
      options.enableWatchdogTerminationTracking = true;
      options.attachStacktrace = true;
      options.enablePrintBreadcrumbs = true;
      options.debug = kDebugMode;
      options.appHangTimeoutInterval = const Duration(seconds: 5);
      options.beforeSend = (event, hint) {
        final t = event.throwable;
        if (t is SocketException ||
            t is TimeoutException ||
            t is HttpException) {
          return null;
        }

        return event;
      };
    },
  );
  DioClient.init();
  await Firebase.initializeApp();
  await AppsFlyerService.instance.init();
  // ---------------- iOS additions begin ----------------
  // init flutter_local_notifications for iOS (and Android stays as-is)
  const AndroidInitializationSettings androidInit =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const DarwinInitializationSettings iosInit = DarwinInitializationSettings();
  const InitializationSettings initSettings =
      InitializationSettings(android: androidInit, iOS: iosInit);

  await flutterLocalNotificationsPlugin.initialize(
    initSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      final payload = response.payload;
      if (payload != null && payload.isNotEmpty) {
        // Payload is appointmentId — extend here when navigation is implemented
      }
    },
  );

  if (Platform.isIOS) {
    // Ask iOS for alert/badge/sound permission (once)
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    // Foreground banners: do NOT enable FCM's native presentation here — it would
    // duplicate flutter_local_notifications in NotificationUtils.handleNotificationOnForeground.
    // PushNotificationService sets presentation options to false for iOS.
  }
  // ---------------- iOS additions end ------------------

  // Android channels (unchanged)
  if (Platform.isAndroid) {
    await _setupAndroidChannels();
  }
  Get.put(AuthController());
  Get.put(HomeController());
  await GetStorage.init();

  // Row 20: seed the gender toggle from the persisted pref before first paint,
  // so "Men" doesn't briefly render with the female (pink) theme on launch when
  // the last session was female.
  selectedGender.value =
      SharedPrefs.readStringValue(PrefConstants.gender) == "1" ? 1 : 0;

  await Get.find<AuthController>().initUserData();

  // Set Firebase Analytics user ID once auth is loaded
  try {
    final userId =
        Get.find<AuthController>().userResponseModel.data?.userData?.userId;
    if (userId != null && userId.isNotEmpty) {
      await FirebaseAnalytics.instance.setUserId(id: userId);
      AppsFlyerService.instance.setCustomerUserId(userId);
      await AppsFlyerService.instance.onUserAuthenticated();
    }
  } catch (_) {}

  await FirebaseMessaging.instance.setAutoInitEnabled(true);
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await PushNotificationService().setupInteractedMessage();
  if (Platform.isAndroid) {
    final status = await Permission.notification.status;
    if (!status.isGranted) {
      await Permission.notification.request();
    }
  }
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await facebookAppEvents.setAutoLogAppEventsEnabled(true);
  await facebookAppEvents.setAdvertiserTracking(enabled: true);

  runApp(SentryWidget(child: const MyApp()));
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

  Future<void> initFCM() async {
    // Single listener for token rotation.
    // TODO: also call your backend update-fcm-token endpoint here so the
    // server always has the latest token after FCM rotates it.
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      await SharedPrefs.writeValue(PrefConstants.fcmToken, newToken);
      print('FCM Token (refresh): $newToken');
    });

    try {
      if (Platform.isIOS) {
        final settings =
            await FirebaseMessaging.instance.getNotificationSettings();
        if (settings.authorizationStatus == AuthorizationStatus.notDetermined) {
          await FirebaseMessaging.instance.requestPermission(
            alert: true,
            badge: true,
            sound: true,
          );
        }
        // Without Push capability + aps-environment, APNS stays null and FCM token never resolves.
        String? apns = await FirebaseMessaging.instance.getAPNSToken();
        if (apns == null) {
          for (var i = 0; i < 15; i++) {
            await Future<void>.delayed(const Duration(milliseconds: 400));
            apns = await FirebaseMessaging.instance.getAPNSToken();
            if (apns != null) break;
          }
        }
        if (kDebugMode) {
          debugPrint('APNS TOKEN => $apns');
        }
      }

      try {
        final token = await FirebaseMessaging.instance.getToken();
        if (token != null) {
          await SharedPrefs.writeValue(PrefConstants.fcmToken, token);
          print('FCM Token: $token');
        } else {
          debugPrint(
            'FCM Token: null — iOS: enable Push Notifications + upload APNs key in '
            'Firebase Console; use a real device or simulator with push support; '
            'Android: use an emulator image with Google Play.',
          );
        }
      } catch (e) {}
    } catch (e, st) {
      debugPrint('FCM getToken failed: $e');
      debugPrint('$st');
    }

    if (kDebugMode) {
      final s = await FirebaseMessaging.instance.getNotificationSettings();
      debugPrint('AUTH STATUS => ${s.authorizationStatus}');
      debugPrint('PROJECT => ${Firebase.app().options.projectId}');
    }
  }

  Future<void> initNotification() async {
    // Foreground: show local notification + snackbar via NotificationUtils.
    // Background tap + terminated tap are handled by PushNotificationService
    // (setupInteractedMessage) which is called in main() before runApp.
    FirebaseMessaging.onMessage.listen((event) {
      NotificationUtils.handleNotificationOnForeground(event);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Scuts',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
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
