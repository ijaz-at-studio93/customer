import 'package:get_storage/get_storage.dart';

class SharedPrefs {
  static Future<void> writeValue(String key, dynamic value) async {
    await GetStorage().write(key, value);
  }

  static T read<T>(String key) {
    return GetStorage().read(key);
  }

  static String readStringValue(String key) {
    return GetStorage().read(key) ?? "";
  }

  static bool readBoolValue(String key) {
    return GetStorage().read(key) ?? false;
  }

  static Future<void> clearAll() async {
    await GetStorage().erase();
    return;
  }

  static Future<void> remove(String key) async {
    return await GetStorage().remove(key);
  }
}

class PrefConstants {
  static const String token = "token";

  // static const String accessToken = "accessToken";
  static const String fcmToken = 'FCMToken';
  static const String isUserLogin = "isLogin";
  static const String userModel = "userModel";
  static const String isFirstTime = 'isFirstTime';
  static const String isSocialLogin = 'socialLogin';
  static const String themeMode = 'themeMode';
  static const String lightMode = 'lightMode';
  static const String darkMode = 'darkMode';
  static const String autoMode = 'autoMode';
  static const String userId = "userId";
  static const String isRemember = "isRemember";
}
