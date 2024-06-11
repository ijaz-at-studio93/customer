import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:sallon_customer/api/auth_api.dart';
import 'package:sallon_customer/api/dio_client.dart';
import 'package:sallon_customer/model/otp_verify_model.dart';
import 'package:sallon_customer/model/user_response_model.dart';
import 'package:sallon_customer/page/auth/login_page.dart';

import '../page/auth/create_profile_page.dart';
import '../util/SharedPrefs.dart';

class AuthController extends GetxController {
  final Rx<bool> _showProgress = false.obs;
  bool get showProgress => _showProgress.value;
  set setShowProgress(val) => _showProgress.value = val;

  final Rx<bool> _googleMapProgress = false.obs;
  bool get googleMapProgress => _googleMapProgress.value;
  set googleMapProgress(apiCallAssign) => _googleMapProgress.value = apiCallAssign;

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
        Get.to(() => const CreateProfilePage());
      }
    } catch (e) {
      showError(e);
    } finally {
      _showProgress.value = false;
    }
  }

  /*------------ Do check Mobile Number registration--------*/
  doSignUp(
      {required String mobileNO,
      required String name,
      required String cc,
      required String email,
      required VoidCallback callback}) async {
    try {
      _showProgress.value = true;
      _userMessage.value = await AuthAPI.signUp(
          mobileNO: mobileNO, name: name, cc: cc, email: email);
      if (_userMessage.value == "Verification code sent") {
        callback.call();
      } else {
        showMessage(_userMessage.value);
      }
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
      if (_userResponseModel.value.data?.id != null) {
        callback.call();
      }
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
    await SharedPrefs.writeValue(PrefConstants.userModel, model.toJson());
    await SharedPrefs.writeValue(
        PrefConstants.userId, model.data?.id.toString());
    await SharedPrefs.writeValue(PrefConstants.isUserLogin, true);
  }

  /*---------------  init User Data -----------*/
  initUserData() async {
    try {
      _showProgress.value = true;
      if (SharedPrefs.readBoolValue(PrefConstants.isUserLogin)) {
        _userResponseModel.value = UserResponseModel.fromJson(
            SharedPrefs.read(PrefConstants.userModel));
        userDataStoreToSharedPrefs(_userResponseModel.value);
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
      if (_userResponseModel.value.data?.id != null) {
        callback.call();
      }
    } catch (e) {
      showError(e);
    } finally {
      _showProgress.value = false;
    }
  }

  /*-------------  Reset App ---------------*/
  resetApp() async {
    await SharedPrefs.writeValue(PrefConstants.gender, "0");
    await SharedPrefs.writeValue(PrefConstants.isUserLogin, false);
    await SharedPrefs.writeValue(PrefConstants.isFirstTime, true);
    Get.offAll(() => const LoginPage(splashPage: false));
  }

/*------ Store Map ------*/
/*  final Rx<ModelName> _userResponseModel = ModelName().obs;
  UserResponseModel get userResponseModel => _userResponseModel.value;
  set setUser(usr) => _userResponseModel.value = usr;*/

/*------ Store List ------*/
/*final RxList<ModelName> _getCategoryList =
      <ModelName>[].obs;
  List<ModelName> get categoryList => _getCategoryList;*/

/*Login API Calling and store user data SharedPrefs*/
/* login(
      {required String email,
      required String password,
      required VoidCallback callback}) async {
    try {
      _showProgress.value = true;
      _userResponseModel.value = await AuthAPI.doLogin(email, password);
      await userDataStoreToSharedPrefs(_userResponseModel.value);
      await getCategoryList();
      */ /*Route Here*/ /*
      if (_userResponseModel.value.emailAddress != "") {
        callback.call();
      }
    } catch (e) {
      showError(e);
    } finally {
      _showProgress.value = false;
    }
  }*/

/*Store userDataStoreToSharedPrefs Data*/
/*Future<void> userDataStoreToSharedPrefs(UserResponseModel model) async {
    _userResponseModel.value = model;
    debugPrint(model.toString());
    if (model.token != null) {
      debugPrint("AccessTOKEN1:${model.token ?? ''}");

      await SharedPrefs.writeValue(PrefConstants.token, model.token);
    }
    await SharedPrefs.writeValue(PrefConstants.userModel, model.toJson());
    await SharedPrefs.writeValue(PrefConstants.userId, model.id.toString());
    await SharedPrefs.writeValue(PrefConstants.isUserLogin, true);
  }
  */

/*------------------ init User Data ------------------ */
/*initUserData() async {
    try {
      _socialLoginProgress.value = true;
      if (SharedPrefs.readBoolValue(PrefConstants.isUserLogin)) {
        */ /*user Profile Model*/ /*
        _userResponseModel.value = await AuthAPI.getProfile();
        userDataStoreToSharedPrefs(_userResponseModel.value);
        await getCategoryList();
        */ /*without Profile  api*/ /*
        // debugPrint(_userResponseModel.value.token);
        // _userResponseModel.value = UserResponseModel.fromJson(SharedPrefs.read(PrefConstants.userModel));
        // userDataStoreToSharedPrefs(_userResponseModel.value);
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      _socialLoginProgress.value = false;
    }
  }*/

/*------------------- RestAPP --------------*/
/* resetApp() async {
    await SharedPrefs.writeValue(PrefConstants.isUserLogin, false);
    await SharedPrefs.writeValue(PrefConstants.isSocialLogin, false);
    await SharedPrefs.writeValue(PrefConstants.isFirstTime, true);
    await SharedPrefs.writeValue(PrefConstants.isRemember, false);
    Get.offAll(() => const LoginPage());
  }*/
}
