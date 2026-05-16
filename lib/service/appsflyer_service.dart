import 'dart:io';

import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:flutter/foundation.dart';

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

  AppsflyerSdk? _sdk;
  bool _initialized = false;

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
      if (kDebugMode) {
        debugPrint('[AppsFlyer] onInstallConversionData: $res');
      }
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

  void logEvent(String eventName, [Map<String, dynamic>? values]) {
    if (!_initialized) return;
    _sdk?.logEvent(eventName, values ?? {});
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
