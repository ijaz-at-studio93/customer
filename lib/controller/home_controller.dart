import 'dart:ui';
import 'package:get/get.dart';
import 'package:sallon_customer/api/dio_client.dart';
import 'package:sallon_customer/api/home_api.dart';
import 'package:sallon_customer/model/artiest_list_model.dart';
import 'package:sallon_customer/model/availabilities_time_sloat_model.dart';
import 'package:sallon_customer/model/category_service_list_model.dart';
import 'package:sallon_customer/model/create_booking_appoiment_model.dart';
import 'package:sallon_customer/model/current_booking_list_model.dart';
import 'package:sallon_customer/model/home_category_list_model.dart';
import 'package:sallon_customer/model/home_salon_list_model.dart';
import 'package:sallon_customer/model/salon_details_artiest.dart';
import 'package:sallon_customer/model/salon_details_model.dart';
import 'package:sallon_customer/model/un_available_dates_model.dart';
import 'package:sallon_customer/model/user_booking_qr_code_model.dart';

class HomeController extends GetxController {
  final Rx<bool> _showProgress = false.obs;
  bool get showProgress => _showProgress.value;
  set setShowProgress(val) => _showProgress.value = val;

  /*----------------- Show Booking Progress ------------*/
  final Rx<bool> _showBookingProgress = false.obs;
  bool get showBookingProgress => _showBookingProgress.value;
  set setShowBookingProgress(val) => _showBookingProgress.value = val;

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

  /*----------------  Booking Create Data Store ---------------*/
  final Rx<CreateBookingAppointmentModel> _createBookingAppointmentModel =
      CreateBookingAppointmentModel().obs;
  CreateBookingAppointmentModel get getCreateBookingAppointmentModel =>
      _createBookingAppointmentModel.value;
  set setCreateBookingAppointmentModel(val) =>
      _createBookingAppointmentModel.value = val;

  /*----------------  Booking Qr Code Generate  Store Data ------------------*/
  final Rx<UserBookingQrCodeModel> _userBookingQrCodeModel =
      UserBookingQrCodeModel().obs;
  UserBookingQrCodeModel get getUserBookingQrCodeModel =>
      _userBookingQrCodeModel.value;
  set setUserBookingQrCodeModel(val) => _userBookingQrCodeModel.value = val;

  /*-----------------------Get Artiest -------------------*/
  final Rx<ArtistListModel> _artiestListData = ArtistListModel().obs;
  ArtistListModel get getArtiestListData => _artiestListData.value;
  set setArtiestListData(val) => _artiestListData.value = val;

  /*----------------------- Get AvailableDates -------------------- */
  final Rx<UnAvailableDatesModel> _unAvailableDatesListData =
      UnAvailableDatesModel().obs;
  UnAvailableDatesModel get getUnAvailableDatesListData =>
      _unAvailableDatesListData.value;
  set setUnAvailableDatesListData(val) => _unAvailableDatesListData.value = val;

  /*------------------------------- Get  Time Slot -----------------------------*/
  final Rx<AvailabilitiesTimeSlotModel> _availabilitiesTimeSlotModelData =
      AvailabilitiesTimeSlotModel().obs;
  AvailabilitiesTimeSlotModel get getAvailabilitiesTimeSlotModelData =>
      _availabilitiesTimeSlotModelData.value;
  set setAvailabilitiesTimeSlotModelData(val) =>
      _availabilitiesTimeSlotModelData.value = val;

  /*------------------------- Get Current Booking List Model --------------------*/
  final Rx<CurrentBookingListModel> _currentBookingListModel =
      CurrentBookingListModel().obs;
  CurrentBookingListModel get getCurrentBookingListModel =>
      _currentBookingListModel.value;
  set setCurrentBookingListModel(val) => _currentBookingListModel.value = val;

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

  double lat = 0.0;
  double lng = 0.0;

  /* ------------------------ Pagination For List ------------------------ */
  var salonList = <HomeSalonModel>[].obs;
  var isLoading = false.obs;
  var page = 1.obs;
  final int limit = 10;

  @override
  void onInit() {
    if (lat != 0.0 && lng != 0.0) {
      fetchPosts();
    }
    super.onInit();
  }

  void fetchPosts() async {
    if (isLoading.value) return;
    isLoading.value = true;
    try {
      var newList = await HomeAPI.getSalonHome(
          offset: page.value, size: limit, lat: lat, lng: lng);
      if (newList.isNotEmpty) {
        salonList.addAll(newList);
        page.value++;
      }
    } finally {
      isLoading.value = false;
    }
  }

  /* ------------------------ Pagination End ------------------------ */

  /*------------------ Get Salon Details ----------------*/
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

  /*------------------------- Do Get Home Salon List -------------*/ /*
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
  }*/

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

  /*------------------------------ DO Get Artiest List Data ------------------------------*/
  doGetArtiestListData({required String serviceId}) async {
    try {
      _showProgress.value = true;
      _artiestListData.value = await HomeAPI.getArtiest(serviceId: serviceId);
    } catch (e) {
      showError(e);
    } finally {
      _showProgress.value = false;
    }
  }

  /*------------------------ get UnAvailableDatesListData --------------------*/
  doGetUnAvailableDatesListData({
    required String salonId,
    required String serviceId,
    required String artiestId,
    required String date,
    required VoidCallback callback,
  }) async {
    try {
      _showProgress.value = true;
      _unAvailableDatesListData.value = await HomeAPI.getUnAvailableDates(
          salonId: salonId,
          serviceId: serviceId,
          artiestId: artiestId,
          date: date);

      if (_unAvailableDatesListData.value.data?.isMonthAvailable ?? false) {
        callback.call();
      }
    } catch (e) {
      showError(e);
    } finally {
      _showProgress.value = false;
    }
  }

  /*------------------------------ Get availabilities Time  Slot ------------------------------*/
  doGetAvailabilitiesTimeSlot(
      {required String salonId,
      required String serviceId,
      required String artiestId,
      required String date}) async {
    try {
      _showProgress.value = true;
      _availabilitiesTimeSlotModelData.value =
          await HomeAPI.getAvailabilitiesTimeSlot(
              salonId: salonId,
              serviceId: serviceId,
              artiestId: artiestId,
              date: date);
    } catch (e) {
      showError(e);
    } finally {
      _showProgress.value = false;
    }
  }

  /*----------------------- Create Booking  ForCustomer -----------------*/
  doCreateBooking({
    required String salonId,
    required String serviceId,
    required String salonArtistId,
    required String startAt,
    required VoidCallback callback,
  }) async {
    try {
      _showBookingProgress.value = true;
      _createBookingAppointmentModel.value = await HomeAPI.userCreateBooking(
          salonId: salonId,
          serviceId: serviceId,
          salonArtistId: salonArtistId,
          startAt: startAt);
      if (_createBookingAppointmentModel
              .value.data?.completionToken?.isNotEmpty ??
          false) {
        callback.call();
      }
    } catch (e) {
      showError(e);
    } finally {
      _showBookingProgress.value = false;
    }
  }

  /*---------------- QR Code Model -------------------*/
  doCreateQrCode({required String appointmentId}) async {
    try {
      _showProgress.value = true;
      _userBookingQrCodeModel.value =
          await HomeAPI.userBookingQrCodeDetails(appointmentId: appointmentId);
    } catch (e) {
      showError(e);
    } finally {
      _showProgress.value = false;
    }
  }

  /*------------------- Get  Current Booking List  Data --------------*/
  doGetCurrentBookingListData() async {
    try {
      _showProgress.value = true;
      _currentBookingListModel.value = await HomeAPI.currentBookingList();
    } catch (e) {
      showError(e);
    } finally {
      _showProgress.value = false;
    }
  }
}
