import 'package:flutter/foundation.dart';
import 'package:salon_customer/api/dio_client.dart';

class AnalyticsAPI {
  /// Sends a tracking event to the backend for Meta CAPI relay.
  /// Called only for critical conversion events (purchase, begin_checkout).
  /// Fire-and-forget — failures are logged but never thrown.
  static Future<void> trackEvent({
    required String eventName,
    required Map<String, dynamic> payload,
  }) async {
    try {
      final response = await DioClient.client.post(
        'user/track-event', // confirm exact path with backend team
        data: payload,
      );
      if (!response.isSuccess) {
        debugPrint('[AnalyticsAPI] track-event failed (${response.statusCode}): $eventName');
      }
    } catch (e) {
      debugPrint('[AnalyticsAPI] track-event exception: $e');
    }
  }
}
