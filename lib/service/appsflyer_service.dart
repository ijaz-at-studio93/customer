import 'dart:io';

import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:flutter/foundation.dart';
import 'package:salon_customer/api/analytics_api.dart';
import 'package:salon_customer/util/SharedPrefs.dart';

/// AppsFlyer attribution and OneLink deep linking.
///
/// Deep link callbacks log payload only; in-app navigation is added later.
class AppsFlyerService {
  AppsFlyerService._();
  static final AppsFlyerService instance = AppsFlyerService._();

  static const String _afDevKey = 'hMDxmwzSTzacYFDh4BRtGP';
  static const String _iosAppId = '6744817165';
  static const String oneLinkHost = 'scuts.onelink.me';
  static const String oneLinkPathPrefix = '/prSS';

  static const List<String> _attributionKeys = [
    'af_status',
    'media_source',
    'campaign',
    'campaign_id',
    'adset',
    'adset_id',
    'ad',
    'ad_id',
    'channel',
  ];

  AppsflyerSdk? _sdk;
  bool _initialized = false;
  Map<String, dynamic>? _pendingAttribution;
  String? _pendingAppsflyerId;

  AppsflyerSdk get sdk {
    final s = _sdk;
    if (s == null) {
      throw StateError('AppsFlyerService.init() must be called first');
    }
    return s;
  }

  Future<void> init() async {
    if (_initialized) return;

    final options = AppsFlyerOptions(
      afDevKey: _afDevKey,
      appId: Platform.isIOS ? _iosAppId : '',
      showDebug: kDebugMode,
      timeToWaitForATTUserAuthorization: 50,
    );

    _sdk = AppsflyerSdk(options);

    _sdk!.onInstallConversionData((dynamic res) {
      _handleInstallConversionData(res);
    });

    _sdk!.onDeepLinking((DeepLinkResult result) {
      _handleDeepLink(result);
    });

    await _sdk!.initSdk(
      registerConversionDataCallback: true,
      registerOnDeepLinkingCallback: true,
    );

    _initialized = true;
    if (kDebugMode) {
      debugPrint('[AppsFlyer] SDK initialized');
    }
  }

  void setCustomerUserId(String userId) {
    if (!_initialized || userId.isEmpty) return;
    _sdk?.setCustomerUserId(userId);
    if (kDebugMode) {
      debugPrint('[AppsFlyer] setCustomerUserId: $userId');
    }
  }

  /// Call after login/signup so deferred attribution can be sent.
  Future<void> onUserAuthenticated() async {
    await _sendAttribution(
      appsflyerId: _pendingAppsflyerId,
      attribution: _pendingAttribution,
    );
  }

  void logEvent(String eventName, [Map<String, dynamic>? values]) {
    if (!_initialized) return;
    _sdk?.logEvent(eventName, values ?? {});
    if (kDebugMode) {
      debugPrint('[AppsFlyer] logEvent: $eventName $values');
    }
  }

  // ── Business events ────────────────────────────────────────────────────────

  /// Trigger: user completes sign-up (auth_controller.doSignUp).
  void logRegistration({String method = 'mobile'}) {
    logEvent('af_complete_registration', {
      'af_registration_method': method,
    });
  }

  /// Trigger: appointment booked before any payment (home_controller.doCreateBooking).
  void logBookingWithoutPayment({
    required String bookingId,
    required String salonId,
    double? amount,
  }) {
    logEvent('af_booking_created', {
      'af_content_id': bookingId,
      'salon_id': salonId,
      if (amount != null) 'af_price': amount,
      'af_currency': 'INR',
    });
  }

  /// Trigger: user pays after the service is done (qr_page._handlePaymentSuccess).
  void logPayAfterService({
    required String bookingId,
    required double amount,
    required String salonId,
  }) {
    logEvent('af_purchase', {
      'af_revenue': amount,
      'af_currency': 'INR',
      'af_order_id': bookingId,
      'af_content_id': bookingId,
      'salon_id': salonId,
    });
  }

  Future<void> _handleInstallConversionData(dynamic res) async {
    if (kDebugMode) {
      debugPrint('[AppsFlyer] onInstallConversionData: $res');
    }

    if (SharedPrefs.readBoolValue(PrefConstants.appsflyerAttributionSent)) {
      return;
    }

    final payload = _extractPayload(res);
    if (payload == null) return;

    final attribution = _mapAttribution(payload);
    final appsflyerId = await _sdk?.getAppsFlyerUID();

    await _sendAttribution(
      appsflyerId: appsflyerId,
      attribution: attribution,
    );
  }

  Map<String, dynamic>? _extractPayload(dynamic res) {
    if (res is! Map) return null;

    final payload = res['payload'];
    if (payload is Map) {
      return Map<String, dynamic>.from(payload);
    }
    return Map<String, dynamic>.from(res);
  }

  Map<String, dynamic> _mapAttribution(Map<String, dynamic> payload) {
    final attribution = <String, dynamic>{};
    for (final key in _attributionKeys) {
      final value = payload[key];
      if (value != null && value.toString().isNotEmpty) {
        attribution[key] = value.toString();
      }
    }
    return attribution;
  }

  Future<void> _sendAttribution({
    String? appsflyerId,
    Map<String, dynamic>? attribution,
  }) async {
    if (attribution == null || attribution.isEmpty) return;
    if (SharedPrefs.readBoolValue(PrefConstants.appsflyerAttributionSent)) {
      return;
    }

    if (!SharedPrefs.readBoolValue(PrefConstants.isUserLogin)) {
      _pendingAppsflyerId = appsflyerId;
      _pendingAttribution = attribution;
      return;
    }

    final sent = await AnalyticsAPI.saveAppsFlyerAttribution(
      appsflyerId: appsflyerId,
      attribution: attribution,
    );
    if (sent) {
      await SharedPrefs.writeValue(
          PrefConstants.appsflyerAttributionSent, true);
      _pendingAppsflyerId = null;
      _pendingAttribution = null;
      if (kDebugMode) {
        debugPrint('[AppsFlyer] attribution saved to backend');
      }
    }
  }

  void _handleDeepLink(DeepLinkResult result) {
    switch (result.status) {
      case Status.FOUND:
        final link = result.deepLink;
        if (kDebugMode) {
          debugPrint(
            '[AppsFlyer] deep link found — value: ${link?.deepLinkValue}, '
            'mediaSource: ${link?.mediaSource}, campaign: ${link?.campaign}, '
            'isDeferred: ${link?.isDeferred}, clickEvent: ${link?.clickEvent}',
          );
        }
        break;
      case Status.NOT_FOUND:
        if (kDebugMode) {
          debugPrint('[AppsFlyer] deep link not found');
        }
        break;
      case Status.ERROR:
        if (kDebugMode) {
          debugPrint('[AppsFlyer] deep link error: ${result.error}');
        }
        break;
      case Status.PARSE_ERROR:
        if (kDebugMode) {
          debugPrint('[AppsFlyer] deep link parse error');
        }
        break;
    }
  }
}
