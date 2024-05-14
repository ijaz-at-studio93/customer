import 'package:get/get.dart';
import 'package:sallon_customer/api/dio_client.dart';
import 'package:sallon_customer/api/home_api.dart';
import 'package:sallon_customer/model/category_service_list_model.dart';
import 'package:sallon_customer/model/home_category_list_model.dart';
import 'package:sallon_customer/model/home_salon_list_model.dart';
import 'package:sallon_customer/model/salon_details_artiest.dart';
import 'package:sallon_customer/model/salon_details_model.dart';

class HomeController extends GetxController {
  final Rx<bool> _showProgress = false.obs;
  bool get showProgress => _showProgress.value;
  set setShowProgress(val) => _showProgress.value = val;

  /*------------------------- Store Data Home Category ----------------*/
  final Rx<HomeCategoryListModel> _homeCategoryListModel =
      HomeCategoryListModel().obs;
  HomeCategoryListModel get homeCategoryListResponseModel =>
      _homeCategoryListModel.value;
  set setCategory(val) => _homeCategoryListModel.value = val;

  /*------------------ Store Salon Details  Data ------------*/

  final Rx<HomeSalonDetailsModel> _homeSalonDetailsData =
      HomeSalonDetailsModel().obs;
  HomeSalonDetailsModel get homeSalonDetailsData => _homeSalonDetailsData.value;
  set setSalonDetails(val) => _homeCategoryListModel.value = val;

  /*----------------------  Store Data Salon Details Service  Data-----------------*/
  /*CategoryServicesListModel*/

  final Rx<CategoryServicesListModel> _salonDetailsListData =
      CategoryServicesListModel().obs;
  CategoryServicesListModel get salonDetailsListData =>
      _salonDetailsListData.value;
  set setSalonDetailsListData(val) => _salonDetailsListData.value = val;

  /*-----------------  Home Salon List Widget Get -------------------*/
  final RxList<HomeSalonModel> _homeSalonList = <HomeSalonModel>[].obs;
  List<HomeSalonModel> get homeSalonList => _homeSalonList;

  /*--------------------- Salon artiest -------------*/
  final Rx<SalonDetailsArtiestModel> _salonDetailsArtiestData =
      SalonDetailsArtiestModel().obs;
  SalonDetailsArtiestModel get getSalonDetailsArtiestData =>
      _salonDetailsArtiestData.value;
  set setSalonDetailsArtiestData(val) => _salonDetailsArtiestData.value = val;

  /*---------------- getHomeCategory ----------*/
  doGetHomeCategory() async {
    try {
      _showProgress.value = true;
      _homeCategoryListModel.value = await HomeAPI.homeCategoryList();
    } catch (e) {
      showError(e);
    } finally {
      _showProgress.value = false;
    }
  }

  /*------------ Get Salon Details -------------*/
  doGetHomeSalonDetails({required String salonId}) async {
    try {
      _showProgress.value = true;
      _homeSalonDetailsData.value =
          await HomeAPI.getSalonDetail(salonId: salonId);
    } catch (e) {
      showError(e);
    } finally {
      _showProgress.value = false;
    }
  }

  /*------------------- Get Salon Details Service ---------------- */
  doGetSalonDetailsService({required String salonId}) async {
    try {
      _showProgress.value = true;
      _salonDetailsListData.value =
          await HomeAPI.getSalonDetailsCategoryServiceList(salonId: salonId);
    } catch (e) {
      showError(e);
    } finally {
      _showProgress.value = false;
    }
  }

  /*------------------------- Do Get Home Salon List -------------*/
  doGetHomeSalonList(
      {required int offset,
      required int size,
      required double lat,
      required double lng}) async {
    try {
      _showProgress.value = true;
      _homeSalonList.value = await HomeAPI.getSalonHome(
          offset: offset, size: size, lat: lat, lng: lng);
    } catch (e) {
      showError(e);
    } finally {
      _showProgress.value = false;
    }
  }

  /*--------------- Do Get Salon Artiest ---------------*/

  doGetSalonArtiestListData({required String salonId}) async {
    try {
      _showProgress.value = true;
      _salonDetailsArtiestData.value =
          await HomeAPI.salonDetailsArtiest(salonId: salonId);
    } catch (e) {
      showError(e);
    } finally {
      _showProgress.value = false;
    }
  }
}
