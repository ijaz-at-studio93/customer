import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SnackbarUtil {
  static void show(
      String title,
      String message, {
        Widget? messageText,
        SnackPosition snackPosition = SnackPosition.BOTTOM,
        Color backgroundColor = Colors.black,
        Color colorText = Colors.white,
        Widget? icon,
        EdgeInsets? margin,
        double borderRadius = 8,
        Duration duration = const Duration(seconds: 3),
        Curve forwardAnimationCurve = Curves.easeOut,
        bool isDismissible = true,
      }) {
    try {
      if (Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
      }

      Future.microtask(() {
        Get.snackbar(
          title,
          message,
          messageText: messageText,
          snackPosition: snackPosition,
          backgroundColor: backgroundColor,
          colorText: colorText,
          icon: icon,
          margin: margin,
          borderRadius: borderRadius,
          duration: duration,
          isDismissible: isDismissible,
          forwardAnimationCurve: forwardAnimationCurve,
        );
      });
    } catch (e) {
      print("Snackbar error: $e");
    }
  }
}