import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_app_icon_changer/flutter_app_icon_changer.dart';

// CustomerOpen = primary/default icon (AppIcon on iOS, MainActivityDefault alias on Android).
// CustomerBook / Customer3Weeks / Customer4Weeks = alternates selected by booking recency.

class _DefaultIcon extends AppIcon {
  _DefaultIcon()
      : super(
          iOSIcon: 'AppIcon',
          androidIcon: 'MainActivityDefault',
          isDefaultIcon: true,
        );
}

class _CustomerBookIcon extends AppIcon {
  _CustomerBookIcon()
      : super(
          iOSIcon: 'CustomerBook',
          androidIcon: 'MainActivityCustomerBook',
          isDefaultIcon: false,
        );
}

class _Customer3WeeksIcon extends AppIcon {
  _Customer3WeeksIcon()
      : super(
          iOSIcon: 'Customer3Weeks',
          androidIcon: 'MainActivityCustomer3Weeks',
          isDefaultIcon: false,
        );
}

class _Customer4WeeksIcon extends AppIcon {
  _Customer4WeeksIcon()
      : super(
          iOSIcon: 'Customer4Weeks',
          androidIcon: 'MainActivityCustomer4Weeks',
          isDefaultIcon: false,
        );
}

class AppIconHelper {
  static final _defaultIcon = _DefaultIcon();
  static final _customerBookIcon = _CustomerBookIcon();
  static final _customer3WeeksIcon = _Customer3WeeksIcon();
  static final _customer4WeeksIcon = _Customer4WeeksIcon();

  static final _plugin = FlutterAppIconChangerPlugin(iconsSet: [
    _defaultIcon,
    _customerBookIcon,
    _customer3WeeksIcon,
    _customer4WeeksIcon,
  ]);

  static Future<void> _change(AppIcon icon) async {
    final supported = await _plugin.isSupported();
    if (!supported) return;
    try {
      // On iOS, isDefaultIcon resets to the primary icon via setAlternateIconName(nil).
      final name = (icon.isDefaultIcon && Platform.isIOS) ? null : icon.currentIcon;
      final currentIcon = await _plugin.getCurrentIcon();

      // iOS default icon returns null
      if (currentIcon == name) {
        return; // 🚀 prevent unnecessary change → no popup
      }
      await _plugin.changeIcon(name);
    } catch (e) {
      debugPrint('Icon change failed: $e');
    }
  }

  static Future<void> updateCustomerAppIcon(DateTime? bookingDate) async {
    if (bookingDate == null) {
      await _change(_defaultIcon);
      return;
    }
    final weeks = DateTime.now().difference(bookingDate).inDays ~/ 7;
    if (weeks >= 4) {
      await _change(_customer4WeeksIcon);
    } else if (weeks >= 3) {
      await _change(_customer3WeeksIcon);
    } else {
      await _change(_customerBookIcon);
    }
  }
}
