import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:salon_customer/api/auth_api.dart';
import 'package:salon_customer/api/dio_client.dart';
import 'package:salon_customer/controller/home_controller.dart';
import 'package:salon_customer/model/app_update_model.dart';
import 'package:salon_customer/model/otp_verify_model.dart';
import 'package:salon_customer/model/user_profile.dart';
import 'package:salon_customer/model/user_response_model.dart';
import 'package:salon_customer/page/auth/login_page.dart';
import 'package:salon_customer/service/appsflyer_service.dart';
import '../page/auth/create_profile_page.dart';
import '../page/auth/otp_screen_page.dart';
import '../util/SharedPrefs.dart';

class AuthController extends GetxController {
  final Rx<bool> _showProgress = false.obs;
  bool get showProgress => _showProgress.value;
  set setShowProgress(val) => _showProgress.value = val;

  final Rx<bool> _googleMapProgress = false.obs;
  bool get googleMapProgress => _googleMapProgress.value;
  set googleMapProgress(apiCallAssign) =>
      _googleMapProgress.value = apiCallAssign;

  final Rx<bool> _isDialogShow = true.obs;
  bool get isDialogShow => _isDialogShow.value;
  set setIsDialogShow(val) => _isDialogShow.value = val;

  /*------------------ Home Page Saloon Card Add For Favourite ---------------------*/
  final Rx<int> _isFavSelected = 0.obs;
  int get isFavSelected => _isFavSelected.value;
  set setFavSelected(val) => _isFavSelected.value = val;

  final Rx<bool> _isSelectMenu = false.obs;
  bool get isSelectMenu => _isSelectMenu.value;
  set isSelectMenu(val) => _isSelectMenu.value = val;

  final Rx<bool> _isInsightsFav = false.obs;
  bool get isInsightsFav => _isInsightsFav.value;
  set isInsightsFavSelect(val) => _isInsightsFav.value = val;

  /*-----------  Register Message ----------*/
  final Rx<String> _userMessage = "".obs;
  String get userMessage => _userMessage.value;

  /*-------------------  User Response Model -------------------*/
  final Rx<UserResponseModel> _userResponseModel = UserResponseModel().obs;
  UserResponseModel get userResponseModel => _userResponseModel.value;
  set setUser(usr) => _userResponseModel.value = usr;

  /*--------------  Location Data  For User --------------*/
  final Rx<String> _userCurrentAddress = "".obs;
  String get userCurrentLocation => _userCurrentAddress.value;
  set userCurrentLocation(location) => _userCurrentAddress.value = location;

  /*------------------ City -------------------*/
  final Rx<String> _userCity = "".obs;
  String get userCity => _userCity.value;
  set userCity(city) => _userCity.value = city;

  /*------ Store OTP Model Data ------*/
  final Rx<OtpVerifyModel> _otpVerifyModelResponseModel = OtpVerifyModel().obs;
  OtpVerifyModel get otpVerifyModelResponseModel =>
      _otpVerifyModelResponseModel.value;
  set setOtpVerifyModelResponseModel(val) =>
      _otpVerifyModelResponseModel.value = val;

  /*-------------  App  Update -------------*/
  final Rx<AppUpdateModel> _appUpdateModel = AppUpdateModel().obs;
  AppUpdateModel get getAppUpdateModel => _appUpdateModel.value;
  set setAppUpdateModel(val) => _appUpdateModel.value = val;

  /*--------------  User Profile ---------------------*/
  final Rx<UserProfile> _userProfile = UserProfile().obs;
  UserProfile get getUserProfile => _userProfile.value;
  set setUserProfile(val) => _userProfile.value = val;

  /*--------------  User Profile -------------------*/
  doGetProfile({required VoidCallback callback}) async {
    try {
      _showProgress.value = true;
      _userProfile.value = await AuthAPI.getUserProfile();

      if (_userProfile.value.data?.id?.isNotEmpty ?? false) {
        callback.call();
      }
    } catch (e) {
      showError(e);
    } finally {
      _showProgress.value = false;
    }
  }

  /*------------ Do check Mobile Number registration--------*/
  doCheckMobileNumberRegistration(
      {required String mobileNo,
      required String countryCode,
      required VoidCallback callback}) async {
    try {
      _showProgress.value = true;
      bool isRegister = await AuthAPI.doCheckMobileNumberIsRegister(
          mobileNo: mobileNo, countryCode: countryCode);
      if (isRegister) {
        callback.call();
      } else {
        Get.to(() => CreateProfilePage(
              mobileNo: mobileNo,
            )
        );
      }
    } catch (e) {
      showError(e);
    } finally {
      _showProgress.value = false;
    }
  }

  /*------------ Do check Mobile Number registration--------*/
  // doSignUp(
  //     {required String mobileNO,
  //     required String name,
  //     required String cc,
  //     required String email,
  //     required String gender,
  //     required VoidCallback callback}) async {
  //   try {
  //     _showProgress.value = true;
  //     _userResponseModel.value = await AuthAPI.signUp(
  //         mobileNO: mobileNO, name: name, cc: cc, email: email, gender: gender);
  //     if (_userMessage.value == "Verification code sent") {
  //       callback.call();
  //     } else {
  //       showMessage(_userMessage.value);
  //     }
  //   } catch (e) {
  //     showError(e);
  //   } finally {
  //     _showProgress.value = false;
  //   }
  // }

  doSignUp({
    required String mobileNO,
    required String name,
    required String cc,
    required String email,
    required String gender,
    required VoidCallback callback,
  }) async {
    try {
      _showProgress.value = true;

      _userResponseModel.value = await AuthAPI.signUp(
        mobileNO: mobileNO,
        name: name,
        cc: cc,
        email: email,
        gender: gender,
      );

      // ✅ STORE TOKENS
      await userDataStoreToSharedPrefs(_userResponseModel.value);

      // 📊 AppsFlyer: user registration
      AppsFlyerService.instance.logRegistration();

      // ✅ ALWAYS CALL CALLBACK ON SUCCESS
      callback.call();

    } catch (e) {
      showError(e);
    } finally {
      _showProgress.value = false;
    }
  }

  Future<void> sendOtpAndGoToOtp({
    required String mobileNo,
    required String countryCode,
  }) async {
    try {
      _showProgress.value = true;

      await AuthAPI.sendVerificationCode(
        mobileNo: mobileNo,
        cc: countryCode,
      );

      // ✅ ALWAYS go to OTP screen
      Get.to(() => OtpScreenPage(
        mobileNumber: mobileNo,
        isLogin: true,
      ));
    } catch (e) {
      showError(e);
    } finally {
      _showProgress.value = false;
    }
  }

  /*------------------ Resend OTP ---------------*/
  doResendOTP({required String mobileNo, required String cc}) async {
    try {
      _showProgress.value = true;
      bool result = await AuthAPI.resendOtp(mobileNo: mobileNo, cc: cc);
      if (result) {
        showMessage("Verification code sent");
      }
    } catch (e) {
      showError(e);
    } finally {
      _showProgress.value = false;
    }
  }

  /*-------------------- Verification OTP -------------*/
  doLogin(
      {required String mobile,
      required String cc,
      required String verificationCode,
      required VoidCallback callback}) async {
    try {
      _showProgress.value = true;
      _userResponseModel.value = await AuthAPI.login(
          mobile: mobile, cc: cc, verificationCode: verificationCode);
      await userDataStoreToSharedPrefs(_userResponseModel.value);
      // if (_userResponseModel.value.data?.id != null) {
      //   callback.call();
      // }
      callback.call();
    } catch (e) {
      showError(e);
    } finally {
      _showProgress.value = false;
    }
  }

  /*------------------ User Data Store pref --------------*/
  Future<void> userDataStoreToSharedPrefs(UserResponseModel model) async {
    _userResponseModel.value = model;
    debugPrint(model.toString());
    if (model.data?.accessToken != null) {
      debugPrint("AccessTOKEN1:${model.data?.accessToken ?? ''}");
      await SharedPrefs.writeValue(
          PrefConstants.token, model.data?.accessToken);
    }
    // ADD THIS ↓
    if (model.data?.refreshToken != null) {
      await SharedPrefs.writeValue(PrefConstants.refreshToken, model.data?.refreshToken);
    }
    await SharedPrefs.writeValue(PrefConstants.userModel, model.toJson());
    await SharedPrefs.writeValue(
        PrefConstants.userId, model.data?.id.toString());
    await SharedPrefs.writeValue(PrefConstants.isUserLogin, true);

    // A live session exists again — re-arm the logout guard so a future genuine
    // expiry can tear down the session.
    DioClient.markSessionActive();

    // The login/signup payload carries whatever FCM token existed at call
    // time, which may have been empty if FCM had not resolved yet. Push the
    // current token now that we are authenticated so the backend is never
    // left without a token for a freshly logged-in user.
    final fcmToken = SharedPrefs.readStringValue(PrefConstants.fcmToken);
    if (fcmToken.isNotEmpty) {
      await AuthAPI.updateFcmToken(fcmToken);
    }

    final userId = model.data?.userData?.userId;
    if (userId != null && userId.isNotEmpty) {
      AppsFlyerService.instance.setCustomerUserId(userId);
    }
    await AppsFlyerService.instance.onUserAuthenticated();

    // Bring up the real-time booking socket for the fresh session so
    // accept/cancel/reschedule events reflect instantly across the app.
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().ensureBookingConfirmedSocket();
    }
  }

  /*---------------  init User Data -----------*/
  initUserData() async {
    try {
      _showProgress.value = true;
      if (SharedPrefs.readBoolValue(PrefConstants.isUserLogin)) {
        _userResponseModel.value = UserResponseModel.fromJson(
            SharedPrefs.read(PrefConstants.userModel));
        //userDataStoreToSharedPrefs(_userResponseModel.value);
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      _showProgress.value = false;
    }
  }

  /*==========================  Verification Code =================*/
  doVerifyOtp(
      {required String mobileNO,
      required String cc,
      required String verificationCode}) async {
    try {
      _showProgress.value = true;
      _otpVerifyModelResponseModel.value = await AuthAPI.otpVerify(
          mobileNo: mobileNO, cc: cc, verificationCode: verificationCode);
      if (_otpVerifyModelResponseModel.value.data?.isVerificationCodeValid ??
          false) {
        showMessage(_otpVerifyModelResponseModel.value.message ?? "");
      } else {
        showMessage(_otpVerifyModelResponseModel.value.message ?? "");
      }
    } catch (e) {
      showError(e);
    } finally {
      _showProgress.value = false;
    }
  }

  /*================ Send OTP  Code ===============*/
  doSendOTP({required String mobileNo, required String cc}) async {
    try {
      _showProgress.value = true;
      bool result =
          await AuthAPI.sendVerificationCode(mobileNo: mobileNo, cc: cc);
      if (!result) {
        showMessage("Verification Code Send Success");
      }
    } catch (e) {
      showError(e);
    } finally {
      _showProgress.value = false;
    }
  }

  /*---------------- Edit Profile----------------*/

  doEditProfile(
      {required String name,
      required String email,
      required String mobile,
      required String cc,
      required String verificationCode,
      required File image,
      required VoidCallback callback}) async {
    try {
      _showProgress.value = true;
      _userResponseModel.value = await AuthAPI.editProFile(
          name: name,
          email: email,
          mobile: mobile,
          cc: cc,
          verificationCode: verificationCode,
          image: image);
      await userDataStoreToSharedPrefs(_userResponseModel.value);
      if (_userResponseModel.value.data?.userData?.userId != null) {
        initUserData();
        callback.call();
      }
    } catch (e) {
      showError(e);
    } finally {
      _showProgress.value = false;
    }
  }

  /*------------  App  Update ------------------*/
  doAppUpdate({
    required VoidCallback callback,
    VoidCallback? onError,
  }) async {
    try {
      _showProgress.value = true;
      _appUpdateModel.value = await AuthAPI.appUpdate();
      if (_appUpdateModel.value.statusCode == 200) {
        callback.call();
      } else {
        onError?.call();
      }
    } catch (e) {
      showError(e);
      onError?.call();
    } finally {
      _showProgress.value = false;
    }
  }

  /*-------------  Reset App ---------------*/
  resetApp() async {
    // Drop the real-time booking socket for the outgoing session.
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().unbindBookingConfirmedSocket();
    }
    await SharedPrefs.remove(PrefConstants.token);
    await SharedPrefs.remove(PrefConstants.refreshToken);
    await SharedPrefs.remove(PrefConstants.userModel);
    await SharedPrefs.writeValue(PrefConstants.isUserLogin, false);
    await SharedPrefs.writeValue(PrefConstants.gender, "0");
    await SharedPrefs.writeValue(PrefConstants.isFirstTime, false);
    await SharedPrefs.remove(PrefConstants.resumePayBillAppointmentId);
    Get.offAll(() => const LoginPage(splashPage: false));
  }
}
