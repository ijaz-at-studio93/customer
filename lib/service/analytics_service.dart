import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:salon_customer/controller/auth_controller.dart';

/// Central analytics service for Scuts.
///
/// Phase 1: Firebase Analytics only — all 8 events.
/// Phase 2 (later): Add Meta SDK + backend /track-event for purchase & begin_checkout.
///
/// All calls are fire-and-forget via [_fire]. Analytics failures
/// NEVER crash or block the app / booking flow.
class AnalyticsService {
  AnalyticsService._();
  static final AnalyticsService instance = AnalyticsService._();

  final FirebaseAnalytics _fa = FirebaseAnalytics.instance;

  // ── Helpers ────────────────────────────────────────────────────────────────

  String get _userId {
    try {
      return Get.find<AuthController>()
              .userResponseModel
              .data
              ?.userData
              ?.userId ??
          '';
    } catch (_) {
      return '';
    }
  }

  /// Wraps an async analytics call. Swallows all errors so analytics
  /// can never crash the app.
  void _fire(Future<void> Function() fn) {
    fn().catchError((Object e) {
      debugPrint('[Analytics] error: $e');
    });
  }

  // ── 1. view_item ────────────────────────────────────────────────────────────
  /// Trigger: salon page opens (saloon_after_selecting_page.dart initState)
  void logViewItem({
    required String salonId,
    required String salonName,
  }) {
    _fire(() => _fa.logViewItem(
          items: [AnalyticsEventItem(itemId: salonId, itemName: salonName)],
          parameters: {
            'salon_id': salonId,
            'user_id': _userId,
          },
        ));
  }

  // ── 2. select_item ──────────────────────────────────────────────────────────
  /// Trigger: service added to cart (doAddCart callback)
  void logSelectItem({
    required String serviceId,
    required String serviceName,
    required String salonId,
  }) {
    _fire(() => _fa.logSelectItem(
          items: [AnalyticsEventItem(itemId: serviceId, itemName: serviceName)],
          parameters: {
            'salon_id': salonId,
            'user_id': _userId,
          },
        ));
  }

  // ── 4. select_slot ──────────────────────────────────────────────────────────
  /// Trigger: time slot picked (appointment_booking_page.dart slot tap)
  void logSelectSlot({
    required String slotTime,
    required String salonId,
  }) {
    _fire(() => _fa.logEvent(
          name: 'select_slot',
          parameters: {
            'slot_time': slotTime,
            'salon_id': salonId,
            'user_id': _userId,
          },
        ));
  }

  // ── 5. begin_checkout ───────────────────────────────────────────────────────
  /// Trigger: user taps "Book Now" → before Razorpay opens
  void logBeginCheckout({
    required String eventId,
    required double value,
    required int numberOfServices,
    required bool stylistSelected,
    required bool slotSelected,
    required String salonId,
  }) {
    _fire(() => _fa.logBeginCheckout(
          value: value,
          currency: 'INR',
          items: [],
          parameters: {
            'event_id': eventId,
            'value': value,
            'currency': 'INR',
            'number_of_services': numberOfServices,
            'stylist_selected': stylistSelected,
            'slot_selected': slotSelected,
            'salon_id': salonId,
            'user_id': _userId,
          },
        ));
  }

  // ── 6. purchase ─────────────────────────────────────────────────────────────
  /// Trigger: payment succeeds → handlePaymentSuccessResponse
  void logPurchase({
    required String bookingId,
    required double value,
    required String salonId,
    required List<String> serviceNames,
    required String stylistId,
    required String slotTime,
  }) {
    _fire(() => _fa.logPurchase(
          value: value,
          currency: 'INR',
          transactionId: bookingId,
          parameters: {
            'event_id': bookingId,
            'event_time': DateTime.now().millisecondsSinceEpoch ~/ 1000,
            'salon_id': salonId,
            'user_id': _userId,
            'stylist_id': stylistId,
            'slot_time': slotTime,
            'payment_type': 'razorpay',
            'services': serviceNames.join(','),
          },
        ));
  }

  // ── 7. booking_cancelled ────────────────────────────────────────────────────
  /// Trigger: cancel confirmed in qr_page.dart
  void logBookingCancelled({
    required String bookingId,
    required String reason,
    required int timeBeforeSlotMinutes,
  }) {
    _fire(() => _fa.logEvent(
          name: 'booking_cancelled',
          parameters: {
            'event_id': bookingId,
            'reason': reason,
            'time_before_slot_minutes': timeBeforeSlotMinutes,
            'user_id': _userId,
          },
        ));
  }

  // ── 9. book_and_pay_after_service ──────────────────────────────────────────
  /// Trigger: payment succeeds in qr_page.dart (pay-after-service flow)
  void logBookAndPayAfterService({
    required String bookingId,
    required double value,
    required String salonId,
  }) {
    _fire(() => _fa.logEvent(
          name: 'book_and_pay_after_service',
          parameters: {
            'event_id': bookingId,
            'value': value,
            'currency': 'INR',
            'salon_id': salonId,
            'user_id': _userId,
            'payment_type': 'razorpay',
          },
        ));
  }

  // ── 10. payment_successful ──────────────────────────────────────────────────
  /// Trigger: PaymentSuccessPage loads (shown after QR-flow payment)
  void logPaymentSuccessful({
    required String bookingId,
    required double value,
  }) {
    _fire(() => _fa.logEvent(
          name: 'payment_successful',
          parameters: {
            'event_id': bookingId,
            'value': value,
            'currency': 'INR',
            'user_id': _userId,
          },
        ));
  }

  // ── 8. service_completed ────────────────────────────────────────────────────
  /// Trigger: complate_booking_details_view.dart loads (service already done)
  void logServiceCompleted({
    required String bookingId,
    required double finalAmount,
    required String paymentMode,
  }) {
    _fire(() => _fa.logEvent(
          name: 'service_completed',
          parameters: {
            'event_id': bookingId,
            'final_amount': finalAmount,
            'currency': 'INR',
            'payment_mode': paymentMode,
            'user_id': _userId,
          },
        ));
  }
}
