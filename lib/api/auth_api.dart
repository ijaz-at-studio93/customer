import 'package:sallon_customer/model/user_response_model.dart';
import 'package:sallon_customer/util/SharedPrefs.dart';

import 'dio_client.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class AuthAPI {
  /*--------------------- CheckMobileNumberIsRegister  Or Not --------------------- */ static Future<
          bool>
      doCheckMobileNumberIsRegister(
          {required String mobileNo, required String countryCode}) async {
    final response = await DioClient.client.post(
        'auth/user/send/verification-code',
        data: {'mobile': mobileNo, 'countryCode': countryCode});
    if (response.statusCode == 200 || response.statusCode == 203) {
      return response.data['data']['isRegistered'];
    } else {
      throw response.data;
    }
  }

/*--------------------- signup --------------------- */
  static Future<String> signUp(
      {required String mobileNO,
      required String name,
      required String cc,
      required String email}) async {
    String? fcmToken = await FirebaseMessaging.instance.getToken();

    Map<String, dynamic> mapData = {
      "mobile": mobileNO,
      "name": name,
      "countryCode": "91",
      "fcmToken": fcmToken,
      "deviceId": SharedPrefs.readStringValue(PrefConstants.deviceId),
      "email": email
    };

    if (email == "") {
      mapData.remove("email");
    }

    final response =
        await DioClient.client.post('auth/user/signup', data: mapData);
    if (response.statusCode == 200) {
      return response.data['message'];
    } else if (response.statusCode == 409 || !response.data['success']) {
      return response.data['message'];
    } else {
      throw response.data;
    }
  }

  /*--------------- Resend OTP --------------*/
  static Future<bool> resendOtp(
      {required String mobileNo, required String cc}) async {
    final response = await DioClient.client.post(
        'auth/user/send/verification-code',
        data: {'mobile': mobileNo, 'countryCode': cc});
    if (response.isSuccess) {
      return response.data['data']['isRegistered'];
    } else {
      return response.data;
    }
  }

  /*--------------- Verify OTP ------------*/
  static Future<UserResponseModel> login(
      {required String mobile,
      required String cc,
      required String verificationCode}) async {
    String? fcmToken = await FirebaseMessaging.instance.getToken();
    final response = await DioClient.client
        .post('auth/user/login/mobile-verification-code', data: {
      "mobile": mobile,
      "countryCode": "91",
      "verificationCode": verificationCode,
      "fcmToken": fcmToken,
      "deviceId": SharedPrefs.readStringValue(PrefConstants.deviceId)
    });
    if (response.statusCode == 200) {
      return UserResponseModel.fromJson(response.data);
    } else if (response.statusCode == 400) {
      showMessage(response.data['message']);
      return response.data;
    } else {
      return response.data;
    }
  }





/*---------------  Login ---------------------*/
// String? fcmToken = await FirebaseMessaging.instance.getToken();

/*  static Future<ModelName> doLogin(parameter) async {
    final response = await DioClient.client.post(
      '/api/login',
      data: {
        'email': email,
        'password': password,
        'push_token' :  pushToken
      },
    );
    if (response.isSuccess && response.data['success'] == true) {
      return UserResponseModel.fromJson(response.data['data']);
    } else {
      throw response.data;
    }
  }*/

/*============ STORE LIST DATA =========*/
/*  static Future<List<ModelName>> getCategoryListAPI() async {
    final response = await DioClient.client.get(
      '/api/get_categories_list',
    );

    if (response.isSuccess) {
      return response.data['data']
          .map<ModelName>((e) => ModelName.fromJson(e))
          .toList();
    } else {
      throw response.data;
    }
  }*/
}
