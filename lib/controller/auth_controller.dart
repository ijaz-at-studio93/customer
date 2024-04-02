import 'package:get/get.dart';

class AuthController extends GetxController {
  final Rx<bool> _showProgress = false.obs;
  bool get showProgress => _showProgress.value;
  set setShowProgress(val) => _showProgress.value = val;

  final Rx<bool> _isDialogShow = true.obs;
  bool get isDialogShow => _isDialogShow.value;
  set setIsDialogShow(val) => _isDialogShow.value = val;


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
      *//*Route Here*//*
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
  }*/

  /*------------------ init User Data ------------------ */
  /*initUserData() async {
    try {
      _socialLoginProgress.value = true;
      if (SharedPrefs.readBoolValue(PrefConstants.isUserLogin)) {
        *//*user Profile Model*//*
        _userResponseModel.value = await AuthAPI.getProfile();
        userDataStoreToSharedPrefs(_userResponseModel.value);
        await getCategoryList();
        *//*without Profile  api*//*
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
