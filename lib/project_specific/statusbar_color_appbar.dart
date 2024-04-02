import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_utils/src/platform/platform.dart';

AppBar statusBarTheme(BuildContext context) {
  return AppBar(
    toolbarHeight: 0,
    backgroundColor: Colors.transparent,
    elevation: 0,
    systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: GetPlatform.isIOS
            ? Theme.of(context).brightness == Brightness.dark
                ? Brightness.dark
                : Brightness.light
            : Theme.of(context).brightness == Brightness.dark
                ? null
                : Brightness.dark,
        statusBarIconBrightness: GetPlatform.isIOS
            ? window.platformBrightness == Brightness.light
                ? Brightness.dark
                : Brightness.light
            : Theme.of(context).brightness == Brightness.dark
                ? Brightness.light
                : Brightness.dark),
  );
}
