import 'dart:io';
import 'package:mime/mime.dart';
import 'package:dio/dio.dart';
import 'package:salon_customer/model/app_update_model.dart';
import 'package:salon_customer/model/user_profile.dart';
import 'package:salon_customer/model/user_response_model.dart';
import 'package:salon_customer/util/SharedPrefs.dart';
import 'package:http_parser/http_parser.dart';
import '../model/otp_verify_model.dart';
import 'dio_client.dart';


class AuthAPI {
  /*--------------------- CheckMobileNumberIsRegister  Or Not --------------------- */
  static Future<bool>
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

  /*------------------  Get  Profile ----------------*/
  static Future<UserProfile> getUserProfile() async {
    final response = await DioClient.client.get('user/profile/me');
    if (response.isSuccess) {
      return UserProfile.fromJson(response.data);
    } else {
      throw response.data;
    }
  }

  /*--------------  App  Update ----------------*/
  static Future<AppUpdateModel> appUpdate() async {
    final response = await DioClient.client.get(
      "common/app/config",
    );

    if (response.isSuccess) {
      return AppUpdateModel.fromJson(response.data);
    } else {
      throw response.data;
    }
  }

/*--------------------- signup --------------------- */
  static Future<String> signUp({required String mobileNO,
    required String name,
    required String cc,
    required String gender,
    required String email}) async {
    Map<String, dynamic> mapData = {
      "mobile": mobileNO,
      "name": name,
      "countryCode": "91",
      "fcmToken": SharedPrefs.readStringValue(PrefConstants.fcmToken),
      "deviceId": SharedPrefs.readStringValue(PrefConstants.deviceId),
      "gender": gender,
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
  static Future<UserResponseModel> login({required String mobile,
    required String cc,
    required String verificationCode}) async {
    final response = await DioClient.client
        .post('auth/user/login/mobile-verification-code', data: {
      "mobile": mobile,
      "countryCode": "91",
      "verificationCode": verificationCode,
      "fcmToken": SharedPrefs.readStringValue(PrefConstants.fcmToken),
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

  /*================= Send Verification Code ================*/
  static Future<bool> sendVerificationCode(
      {required String mobileNo, required String cc}) async {
    final response = await DioClient.client.post(
      "auth/user/send/verification-code",
      data: {
        "mobile": mobileNo,
        "countryCode": cc,
      },
    );
    if (response.statusCode == 200 || response.statusCode == 203) {
      return response.data['data']['isRegistered'];
    } else {
      throw response.data;
    }
  }

  /*=================  Verify OTP ================*/
  static Future<OtpVerifyModel> otpVerify({required String mobileNo,
    required String cc,
    required String verificationCode}) async {
    final response = await DioClient.client
        .post("auth/user/verify/verification-code", data: {
      "mobile": mobileNo,
      "countryCode": cc,
      "verificationCode": verificationCode
    });

    if (response.isSuccess) {
      return OtpVerifyModel.fromJson(response.data);
    } else {
      throw response.data;
    }
  }

  /*--------------- Edit Profile --------------*/
  /*--------------- Verify OTP ------------*/
  static Future<UserResponseModel> editProFile({required String name,
    required String email,
    required String mobile,
    required String cc,
    required String verificationCode,
    required File image}) async {
    final formData = FormData.fromMap({
      "name": name,
      "email": email,
    });

    if (mobile != "") {
      formData.fields.add(MapEntry('mobile', mobile));
      formData.fields.add(MapEntry('countryCode', cc));
      formData.fields.add(MapEntry('verificationCode', verificationCode));
    }

    if (image.path.isNotEmpty) {
      final mimeTypeData =
      lookupMimeType(image.path, headerBytes: [0xFF, 0xD8])?.split('/');
      final multipartFile = await MultipartFile.fromFile(image.path,
          contentType: MediaType(mimeTypeData![0], mimeTypeData[1]));
      formData.files.add(MapEntry('image', multipartFile));
    }

    final response =
    await DioClient.client.patch('user/profile', data: formData);
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
