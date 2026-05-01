import 'package:flutter/services.dart';

class AppIconHelper {
  static const _channel = MethodChannel('app_icon');

  static Future<void> change(String iconName) async {
    try {
      await _channel.invokeMethod('changeIcon', {
        "icon": iconName,
      });
    } catch (e) {
      print("Icon change failed: $e");
    }
  }

  static Future<void> updateCustomerAppIcon(DateTime? bookingDate) async {
    if (bookingDate == null) {
      await change("CustomerOpen");
      return;
    }

    final weeks = DateTime.now().difference(bookingDate).inDays ~/ 7;

    if (weeks >= 4) {
      await change("Customer4Weeks");
    } else if (weeks >= 3) {
      await change("Customer3Weeks");
    } else {
      await change("CustomerBook");
    }
  }
}