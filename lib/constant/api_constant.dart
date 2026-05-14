import 'package:flutter/foundation.dart';

class APIConstants {
  /*---------- Staging -----------*/
  static const String _stagingBase = 'http://staging.scuts.in:5001/';

  /*---------- Live -----------*/
  static const String _liveBase = 'https://api.scuts.in/';

  static String get baseUrl =>
      kDebugMode ? '${_stagingBase}api/v1/' : '${_liveBase}api/v1/';

  static String get image => kDebugMode ? _stagingBase : _liveBase;

  //static const String baseUrl = 'http://192.168.31.62:3001/api/v1/';
  //static const String baseUrl = 'https://ee0a-2409-40f2-153-105e-d098-7eb3-3f90-585e.ngrok-free.app/api/v1/';
}
