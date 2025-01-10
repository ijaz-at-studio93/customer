import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:salon_customer/api/dio_client.dart';
import 'package:salon_customer/api/home_api.dart';
import 'package:salon_customer/model/artiest_list_model.dart';
import 'package:salon_customer/model/artiest_portfolio_model.dart';
import 'package:salon_customer/model/artist_search_model.dart';
import 'package:salon_customer/model/availabilities_time_sloat_model.dart';
import 'package:salon_customer/model/blog_data_model.dart';
import 'package:salon_customer/model/booking_history_list_model.dart';
import 'package:salon_customer/model/cart/get_product_model.dart';
import 'package:salon_customer/model/cart/order_id_model.dart';
import 'package:salon_customer/model/cart/service_add_cart_model.dart';
import 'package:salon_customer/model/category_service_list_model.dart';
import 'package:salon_customer/model/create_booking_appoiment_model.dart';
import 'package:salon_customer/model/current_booking_list_model.dart';
import 'package:salon_customer/model/favourite_salon_list_data_model.dart';
import 'package:salon_customer/model/home_category_list_model.dart';
import 'package:salon_customer/model/home_salon_list_model.dart';
import 'package:salon_customer/model/promo_code/promocode_model.dart';
import 'package:salon_customer/model/review_list_data_model.dart';
import 'package:salon_customer/model/review_rating_data_model.dart';
import 'package:salon_customer/model/salonId_reviews_model.dart';
import 'package:salon_customer/model/salon_details_artiest.dart';
import 'package:salon_customer/model/salon_details_model.dart';
import 'package:salon_customer/model/save_address_model.dart';
import 'package:salon_customer/model/search_model/search_model.dart';
import 'package:salon_customer/model/un_available_dates_model.dart';
import 'package:salon_customer/model/user_booking_qr_code_model.dart';
import 'package:salon_customer/util/logger.dart';
import '../model/artiest_popular_service_model.dart';

class HomeController extends GetxController {
  /*>>>>>>>>>>>>>>>>>>>> Loader <<<<<<<<<<<<<<<<<<<<<*/
  final Rx<bool> _showProgress = false.obs;
  bool get showProgress => _showProgress.value;
  set setShowProgress(val) => _showProgress.value = val;

  final Rx<bool> _showAddProgress = false.obs;
  bool get gteShowAddProgress => _showAddProgress.value;
  set setShowAddProgress(val) => _showAddProgress.value = val;

  /*----------------- Show Booking Progress ------------*/
  final Rx<bool> _showBookingProgress = false.obs;
  bool get showBookingProgress => _showBookingProgress.value;
  set setShowBookingProgress(val) => _showBookingProgress.value = val;

  /*------------------------- category All Data Get Home Category ----------------*/
  final Rx<HomeCategoryListModel> _homeCategoryListModel =
      HomeCategoryListModel().obs;
  HomeCategoryListModel get homeCategoryListResponseModel =>
      _homeCategoryListModel.value;
  set setCategory(val) => _homeCategoryListModel.value = val;

  /*------------------ Add  Category  Make Package Data get ---------*/
  final Rx<HomeCategoryListModel> _getLastMakeYourOwnPackage =
      HomeCategoryListModel().obs;
  HomeCategoryListModel get getLastMakeYourOwnPackageModel =>
      _getLastMakeYourOwnPackage.value;
  set getLastMakeYourOwnPackageModel(val) =>
      _getLastMakeYourOwnPackage.value = val;

  /*------------------ Store Salon Details  Data ------------*/
  final Rx<HomeSalonDetailsModel> _homeSalonDetailsData =
      HomeSalonDetailsModel().obs;
  HomeSalonDetailsModel get homeSalonDetailsData => _homeSalonDetailsData.value;
  set setSalonDetails(val) => _homeSalonDetailsData.value = val;

  /*----------------------  Store Data Salon Details Service Data -----------------*/
  final Rx<CategoryServicesListModel> _salonDetailsListData =
      CategoryServicesListModel().obs;
  CategoryServicesListModel get salonDetailsListData =>
      _salonDetailsListData.value;
  set setSalonDetailsListData(val) => _salonDetailsListData.value = val;

  /*-----------------  Home Salon List Widget Get -------------------*/
  final Rx<HomeSalonModel> _homeSalonList = HomeSalonModel().obs;
  HomeSalonModel get getHomeSalonList => _homeSalonList.value;
  set setHomeSalonList(val) => _homeSalonList.value = val;

/*--------------------  Fav Salon  List  Model  Data Get -------------------*/
  final Rx<FavouriteSalonModel> _favSalonList = FavouriteSalonModel().obs;
  FavouriteSalonModel get getFavSalonList => _favSalonList.value;
  set setFavSalonList(val) => _favSalonList.value = val;

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

  /*-------------------  Booking History List Model --------------------*/
  final Rx<BookingHistoryListModel> _bookingHistoryListModel =
      BookingHistoryListModel().obs;
  BookingHistoryListModel get getBookingHistoryListModel =>
      _bookingHistoryListModel.value;
  set setBookingHistoryListModel(val) => _bookingHistoryListModel.value = val;

  /*------------------- Review Data List API Get Model ----------------*/
  final Rx<ReviewListModel> _reviewDataListModel = ReviewListModel().obs;
  ReviewListModel get getReviewDataListModel => _reviewDataListModel.value;
  set setReviewDataListModel(val) => _reviewDataListModel.value = val;

  /*------------------- ArtiestPortfolio --------------------*/
  final Rx<ArtiestPortfolio> _artiestDetailsModel = ArtiestPortfolio().obs;
  ArtiestPortfolio get getArtiestDetailsModel => _artiestDetailsModel.value;
  set setArtiestDetailsModel(val) => _artiestDetailsModel.value = val;

  /*>>>>>>>>>>>>>>>>>>>>>>>>>> CART PART <<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/
  /*---------------- Add Cart -------------------*/
  final Rx<ServiceAddCartModel> _serviceAddCartModel =
      ServiceAddCartModel().obs;
  ServiceAddCartModel get getServiceAddCartModel => _serviceAddCartModel.value;
  set setServiceAddCartModel(val) => _serviceAddCartModel.value = val;

  /*--------------- Product  List Data Get  -------------*/
  final Rx<ServiceProductModel> _serviceProductModel =
      ServiceProductModel().obs;
  ServiceProductModel get getServiceProductModel => _serviceProductModel.value;
  set setServiceProductModel(val) => _serviceProductModel.value = val;

  /*--------------------  BlogDataModel  -----------------*/
  final Rx<BlogDataModel> _blogDataModel = BlogDataModel().obs;
  BlogDataModel get getBlogDataModel => _blogDataModel.value;
  set setBlogDataModel(val) => _blogDataModel.value = val;

  /*----------------- Fav Blog Data ----------------------*/
  final Rx<BlogDataModel> _favBlogDataModel = BlogDataModel().obs;
  BlogDataModel get getFavBlogDataModel => _favBlogDataModel.value;
  set getFavBlogDataModel(val) => _favBlogDataModel.value = val;

  /*--------------------  Rating  & Review Model  -----------------*/
  final Rx<ReviewRatingUserModel> _reviewRatingUserModel =
      ReviewRatingUserModel().obs;
  ReviewRatingUserModel get getReviewRatingUserModel =>
      _reviewRatingUserModel.value;
  set setReviewRatingUserModel(val) => _reviewRatingUserModel.value = val;

  /*-------------- Search  Model  -------------------------*/
  final Rx<SearchSalonModel> _searchSalonModel = SearchSalonModel().obs;
  SearchSalonModel get getSearchSalonModel => _searchSalonModel.value;
  set setSearchSalonModel(val) => _searchSalonModel.value = val;

  /*-------------- Save Address Model  -------------------------*/
  final Rx<SaveAddressModel> _saveAddressModel = SaveAddressModel().obs;
  SaveAddressModel get getSaveAddressModel => _saveAddressModel.value;
  set setSaveAddressModel(val) => _saveAddressModel.value = val;

  /*----------------  Artiest  Search ---------------*/
  final Rx<ArtistSearchModel> _artistSearchModel = ArtistSearchModel().obs;
  ArtistSearchModel get getArtistSearchModel => _artistSearchModel.value;
  set setArtistSearchModel(val) => _artistSearchModel.value = val;

  /*--------------  get  Order Id -----------*/
  final Rx<OrderIdModel> _orderIdModel = OrderIdModel().obs;
  OrderIdModel get getOrderIdModel => _orderIdModel.value;
  set setOrderIdModel(val) => _orderIdModel.value = val;

  /*------------------- Artiest  Popular Service -------------*/
  final Rx<ArtistPopularServicesModel> _artistPopularServicesModel =
      ArtistPopularServicesModel().obs;
  ArtistPopularServicesModel get getArtistPopularServicesModel =>
      _artistPopularServicesModel.value;
  set setArtistPopularServicesModel(val) =>
      _artistPopularServicesModel.value = val;

  /*------------------------ Salon Review For Customer ----------------*/
  final Rx<SalonIdReviewsModel> _salonIdReviewsModel =
      SalonIdReviewsModel().obs;
  SalonIdReviewsModel get getSalonIdReviewsModel => _salonIdReviewsModel.value;
  set setSalonIdReviewsModel(val) => _salonIdReviewsModel.value = val;

  /*--------------- PromoCode Model ------------------*/
  final Rx<PromoCodeModel> _promoCodeModel = PromoCodeModel().obs;
  PromoCodeModel get getPromoCodeModel => _promoCodeModel.value;
  set setPromoCodeModel(val) => _promoCodeModel.value = val;

  /*--------------------  Get  PromoCode List ------------------------*/
  final Rx<PromoCodeModel> _promoCodeModelList = PromoCodeModel().obs;
  PromoCodeModel get getPromoCodeModelList => _promoCodeModelList.value;
  set setPromoCodeModelList(val) => _promoCodeModelList.value = val;

  /*-------------  category Id  -----------------*/
  final RxList categoryId = [].obs;

  /*---------------- getHomeCategory ----------*/
  doGetHomeCategory({required String gender}) async {
    try {
      _showProgress.value = true;
      _homeCategoryListModel.value =
          await HomeAPI.homeCategoryList(gender: gender);
    } catch (e) {
      showError(e);
      if (kDebugMode) {
        print("GetHomeCategory $e");
      }
    } finally {
      _showProgress.value = false;
    }
  }

  /*------------------ Get Make Package Data  ------------*/
  doGetMakePackageData() async {
    try {
      _showProgress.value = true;
      _getLastMakeYourOwnPackage.value = await HomeAPI.makePackageDataGet();
    } catch (e) {
      showError(e);
      if (kDebugMode) {
        print("GetMakePackageData $e");
      }
    } finally {
      _showProgress.value = false;
    }
  }

  /*--------------  Get Product For Service ----------------*/
  doGetProductData({required String serviceId}) async {
    try {
      _showProgress.value = true;
      _serviceProductModel.value = await HomeAPI.getServiceProduct(serviceId);
    } catch (e) {
      showError(e);
      if (kDebugMode) {
        print("GetProductData $e");
      }
    } finally {
      _showProgress.value = false;
    }
  }

  /*----------------------  Add One Package Data  ------------*/
  doAddPackageOneData({
    required List<String> serviceCategoryIds,
    required VoidCallback callback,
  }) async {
    try {
      _showProgress.value = true;
      bool result = await HomeAPI.createOwnPackage(
          serviceCategoryIds: serviceCategoryIds);
      if (result) {
        callback.call();
      }
    } catch (e) {
      showError(e);
      if (kDebugMode) {
        print("AddPackageOneData $e");
      }
    } finally {
      _showProgress.value = false;
    }
  }

  /*----------------------  Remove One Category Data --------------*/
  doRemovePackageData({
    required List<String> serviceCategoryIds,
    required VoidCallback callback,
  }) async {
    try {
      _showProgress.value = true;
      bool result = await HomeAPI.removePackageCategory(
          serviceCategoryIds: serviceCategoryIds);
      if (result) {
        callback.call();
      }
    } catch (e) {
      if (kDebugMode) {
        print("Remove Package Data $e");
      }
      showError(e);
    } finally {
      _showProgress.value = false;
    }
  }

/*  double lat = 0.0;
  double lng = 0.0;

  */ /* ------------------------ Pagination For List ------------------------ */ /*
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
  }*/

  /* ------------------------ Pagination End ------------------------ */

  /*------------------ Get Salon Details ----------------*/
  doGetHomeSalonDetails({
    required String salonId,
    required String lat,
    required String lng,
  }) async {
    try {
      _showProgress.value = true;
      _homeSalonDetailsData.value =
          await HomeAPI.getSalonDetail(salonId: salonId, lng: lng, lat: lat);
    } catch (e) {
      showError(e);
      if (kDebugMode) {
        print("GetHomeSalonDetails $e");
      }
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
      if (kDebugMode) {
        print("DO Get Artiest List Data $e");
      }

    } finally {
      _showProgress.value = false;
    }
  }

  /*------------------------- Do Get Home Salon List -------------*/
  doGetHomeSalonList({
    required int offset,
    required int size,
    required double lat,
    required double lng,
    required String orderBy,
    required String serviceGender,
    required bool nearest,
    required bool fourPlusRating,
    required bool homeService,
  }) async {
    try {
      _showProgress.value = true;
      _homeSalonList.value = await HomeAPI.getSalonHome(
          offset: offset,
          size: size,
          lat: lat,
          lng: lng,
          homeService: homeService,
          serviceGender: serviceGender,
          fourPlusRating: fourPlusRating,
          nearest: nearest,
          orderBy: orderBy);
    } catch (e) {
      showError(e);
      if (kDebugMode) {
        print("Do Get Home Salon List $e");
      }
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
      if (kDebugMode) {
        print("Do Get Salon Artiest $e");
      }

    } finally {
      _showProgress.value = false;
    }
  }

  /*------------------------------ DO Get Artiest List Data ------------------------------*/
  doGetArtiestListData() async {
    try {
      _showProgress.value = true;
      _artiestListData.value = await HomeAPI.getArtiest();
    } catch (e) {
      showError(e);
      if (kDebugMode) {
        print("DO Get Artiest List Data $e");
      }

    } finally {
      _showProgress.value = false;
    }
  }

  /*------------------------ get UnAvailableDatesListData --------------------*/
  doGetUnAvailableDatesListData({
    required String artiestId,
    required String date,
    required VoidCallback callback,
  }) async {
    try {
      _showProgress.value = true;
      _unAvailableDatesListData.value =
          await HomeAPI.getUnAvailableDates(artiestId: artiestId, date: date);

      if (_unAvailableDatesListData.value.data?.isMonthAvailable ?? false) {
        callback.call();
      }
    } catch (e) {
      showError(e);
      if (kDebugMode) {
        print("UnAvailableDatesListData $e");
      }

    } finally {
      _showProgress.value = false;
    }
  }

  /*------------------------------ Get availabilities Time  Slot ------------------------------*/
  doGetAvailabilitiesTimeSlot(
      {required String artiestId, required String date}) async {
    try {
      _showProgress.value = true;
      _availabilitiesTimeSlotModelData.value =
          await HomeAPI.getAvailabilitiesTimeSlot(
              artiestId: artiestId, date: date);
    } catch (e) {
      showError(e);
      if (kDebugMode) {
        print("Availabilities Time  Slot $e");
      }
    } finally {
      _showProgress.value = false;
    }
  }

  /*----------------------- Create Booking  ForCustomer -----------------*/
  doCreateBooking({
    required String salonArtistId,
    required String startAt,
    required bool isHomeService,
    required String userAddressId,
    required VoidCallback callback,
  }) async {
    try {
      _showBookingProgress.value = true;
      _createBookingAppointmentModel.value = await HomeAPI.userCreateBooking(
          salonArtistId: salonArtistId,
          startAt: startAt,
          isHomeService: isHomeService,
          userAddressId: userAddressId);
      if (_createBookingAppointmentModel
              .value.data?.completionToken?.isNotEmpty ??
          false) {
        callback.call();
      }
    } catch (e) {
      showError(e);
      if (kDebugMode) {
        print("Create Booking  ForCustomer $e");
      }
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
      if (kDebugMode) {
        print("QR Code $e");
      }
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
      if (kDebugMode) {
        print("Current Booking List  Data $e");
      }
    } finally {
      _showProgress.value = false;
    }
  }

  /*-----------------  Add  Favourite Salon ---------------*/
  doAddFavouriteSalon({required String salonId}) async {
    try {
      _showAddProgress.value = true;
      bool result = await HomeAPI.addFavouriteSalon(salonId: salonId);
      print(result);
    } catch (e) {
      showError(e);
      if (kDebugMode) {
        print("Favourite Salon $e");
      }
    } finally {
      _showAddProgress.value = false;
    }
  }

  /*-----------------  remove  Favourite Salon ---------------*/
  doRemoveFavouriteSalon(
      {required String salonId, required VoidCallback callback}) async {
    try {
      _showAddProgress.value = true;
      bool result = await HomeAPI.removeFavouriteSalon(salonId: salonId);
      if (result) {
        callback.call();
      }
    } catch (e) {
      showError(e);
      if (kDebugMode) {
        print("Remove Favourite Salon$e");
      }
    } finally {
      _showAddProgress.value = false;
    }
  }

  /*----------------  Fav Salon List -------------------*/
  doGetFavouriteSalon() async {
    try {
      _showProgress.value = true;
      _favSalonList.value = await HomeAPI.getFavouriteSalon();
    } catch (e) {
      showError(e);
      if (kDebugMode) {
        print("Fav Salon List $e");
      }
    } finally {
      _showProgress.value = false;
    }
  }

  /*>>>>>>>>>>>>>>>>>>>  CART <<<<<<<<<<<<<<<<<<<<<<<*/
  /*------------------------ Add Cart ----------------*/
  doAddCart(
      {required String salonServiceId,
      required bool isHomeService,
      required VoidCallback callback}) async {
    try {
      _showProgress.value = true;
      bool result = await HomeAPI.serviceAddCart(
          salonServiceId: salonServiceId, isHomeService: isHomeService);
      if (result) {
        callback.call();
      }
    } catch (e) {
      showError(e);
      if (kDebugMode) {
        print("Add Cart $e");
      }
    } finally {
      _showProgress.value = false;
    }
  }

  /*-------------------  Remove Cart ------------------*/
  doRemoveCart(
      {required String salonServiceId, required VoidCallback callback}) async {
    try {
      _showProgress.value = true;
      bool result =
          await HomeAPI.serviceRemoveAddCart(salonServiceId: salonServiceId);
      if (result) {
        callback.call();
      }
    } catch (e) {
      showError(e);
      if (kDebugMode) {
        print("Remove Cart $e");
      }

    } finally {
      _showProgress.value = false;
    }
  }

  /*---------------- Get Cart ---------------*/
  doGetCart() async {
    try {
      _showProgress.value = true;
      _serviceAddCartModel.value = await HomeAPI.getUserCart();
    } catch (e) {
      showError(e);
      if (kDebugMode) {
        print("Get Cart $e");
      }
    } finally {
      _showProgress.value = false;
    }
  }

  /*---------- Clear Cart --------------*/
  doClearCart({required VoidCallback callback}) async {
    try {
      _showProgress.value = true;
      bool result = await HomeAPI.removeCart();
      if (result) {
        callback.call();
      }
    } catch (e) {
      showError(e);
      if (kDebugMode) {
        print("Clear Cart $e");
      }
    } finally {
      _showProgress.value = false;
    }
  }

  /*----------------- Add Cart in  Product ------------------*/

  doAddProductCart(
      {required String productId,
      required String productSelectedServiceId,
      required bool  isHomeService,
      required VoidCallback callback}) async {
    try {
      _showProgress.value = true;
      _serviceAddCartModel.value = await HomeAPI.addProductCart(
          productId: productId,
          productSelectedServiceId: productSelectedServiceId,
          isHomeService: isHomeService
      );
      if (_serviceAddCartModel.value.success ?? false) {
        callback.call();
      }
    } catch (e) {
      showError(e);
      if (kDebugMode) {
        print("Add Cart $e");
      }
    } finally {
      _showProgress.value = false;
    }
  }

  /*----------------- Remove Cart in  Product ------------------*/
  doRemoveProductCart(
      {required String productId,
      required String productSelectedServiceId,
      required VoidCallback callback}) async {
    try {
      _showProgress.value = true;
      bool result = await HomeAPI.removeProductCart(
          productId: productId,
          productSelectedServiceId: productSelectedServiceId);
      if (result) {
        callback.call();
      }
    } catch (e) {
      showError(e);
      if (kDebugMode) {
        print("Remove Product Cart $e");
      }

    } finally {
      _showProgress.value = false;
    }
  }

  /*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Cart Part End <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

  /*----------------------------- Do Get Booking History Data List -----------------------*/
  doGetBookingHistory() async {
    try {
      _showProgress.value = true;
      _bookingHistoryListModel.value = await HomeAPI.bookingHistory();
    } catch (e) {
      showError(e);
      if (kDebugMode) {
        print("Get Booking History $e");
      }
    } finally {
      _showProgress.value = false;
    }
  }

  /*-------------  Get Order Id Model ---------------*/
  doGetOrderId() async {
    try {
      _showProgress.value = true;
      _orderIdModel.value = await HomeAPI.orderIdGet();
    } catch (e) {
      showError(e);
      if (kDebugMode) {
        print("Get Order Id $e");
      }
    } finally {
      _showProgress.value = false;
    }
  }

  /*----------------------------  Upload PortFolio --------------------*/
  doUploadPortFolio(
      {required String appointmentId, required bool isUpload}) async {
    try {
      _showProgress.value = true;
      bool result = await HomeAPI.portFolioUpload(
          appointmentId: appointmentId, isUpload: isUpload);
      if (result) {
        showMessage("Portfolio Request Sent Successfully");
      }
    } catch (e) {
      showError(e);
      if (kDebugMode) {
        print("Upload Port Folio $e");
      }
    } finally {
      _showProgress.value = false;
    }
  }

  /*---------------------  Get Review Data List Model ----------------*/
  doGetReviewDataList({required String appointmentId}) async {
    try {
      _showProgress.value = true;
      _reviewDataListModel.value =
          await HomeAPI.reviewListDataGet(appointmentId: appointmentId);
    } catch (e) {
      showError(e);
      if (kDebugMode) {
        print("Get Review Data List $e");
      }
      logger.d(e);
    } finally {
      _showProgress.value = false;
    }
  }

  /*>>>>>>>>>>>>>>>>>>>>>> Add Review <<<<<<<<<<<<<<<<<<<<<<<*/
  /*============= Service ================*/
  doAddServiceReview({
    required String appointmentId,
    required double rate,
    required String salonServiceId,
    required String review,
    required VoidCallback callback,
  }) async {
    try {
      _showAddProgress.value = true;
      bool result = await HomeAPI.addAppointmentServiceReview(
          appointmentId: appointmentId,
          rate: rate,
          salonServiceId: salonServiceId,
          review: review);
      if (result) {
        callback.call();
      }
    } catch (e) {
      showError(e);
      if (kDebugMode) {
        print("Add Service Review$e");
      }
    } finally {
      _showAddProgress.value = false;
    }
  }

  /*================ Product ==================*/
  doAddProductReview({
    required String appointmentId,
    required double rate,
    required String salonProductId,
    required String review,
    required VoidCallback callback,
  }) async {
    try {
      _showAddProgress.value = true;
      bool result = await HomeAPI.addAppointmentProductReview(
          appointmentId: appointmentId,
          rate: rate,
          salonProductId: salonProductId,
          review: review);
      if (result) {
        callback.call();
      }
    } catch (e) {
      showError(e);
      if (kDebugMode) {
        print("Add Product Review $e");
      }
    } finally {
      _showAddProgress.value = false;
    }
  }

/*================ Artiest ==================*/
  doAddArtiestReview({
    required String appointmentId,
    required double rate,
    required String salonArtistId,
    required String review,
    required VoidCallback callback,
  }) async {
    try {
      _showAddProgress.value = true;
      bool result = await HomeAPI.addAppointmentArtiestReview(
          appointmentId: appointmentId,
          rate: rate,
          salonArtistId: salonArtistId,
          review: review);
      if (result) {
        callback.call();
      }
    } catch (e) {
      showError(e);
      if (kDebugMode) {
        print("Add Artiest Review $e");
      }
    } finally {
      _showAddProgress.value = false;
    }
  }

  /*--------------------------  Artiest Portfolio -----------------*/
  doGetArtiestPortfolio({required String artistId}) async {
    try {
      _showProgress.value = true;
      _artiestDetailsModel.value =
          await HomeAPI.getArtiestPortfolio(artistId: artistId);
    } catch (e) {
      showError(e);
      if (kDebugMode) {
        print("Get Artiest Portfolio1 $e");
      }
    } finally {
      _showProgress.value = false;
    }
  }

  /*---------------- Get Blog Data ----------------*/
  doGetBlogData({required double lat, required double lng}) async {
    try {
      _showProgress.value = true;
      _blogDataModel.value = await HomeAPI.getBlogData(lat: lat, lng: lng);
    } catch (e) {
      showError(e);
      if (kDebugMode) {
        print("Get Blog Data$e");
      }
    } finally {
      _showProgress.value = false;
    }
  }

  /*------------------- Add Fav Blog -----------------*/
  doAddFavBlog({required String blogId, required VoidCallback callback}) async {
    try {
      _showProgress.value = true;
      bool result = await HomeAPI.addFavBlog(blogId);
      if (result) {
        callback.call();
      }
    } catch (e) {
      showError(e);
      if (kDebugMode) {
        print("Add Fav Blog  $e");
      }
    } finally {
      _showProgress.value = false;
    }
  }

  /*--------------------- Remove Fav Blog --------------------*/
  doRemoveBlog({required String blogId, required VoidCallback callback}) async {
    try {
      _showProgress.value = true;
      bool result = await HomeAPI.removeBlog(blogId);
      if (result) {
        callback.call();
      }
    } catch (e) {
      showError(e);
      if (kDebugMode) {
        print("Remove Blog  $e");
      }
    } finally {
      _showProgress.value = false;
    }
  }

  /*---------------------- get Fav Blog Data  ----------------*/
  doGetFavBlogData() async {
    try {
      _showProgress.value = true;
      _favBlogDataModel.value = await HomeAPI.getFavBlogData();
    } catch (e) {
      showError(e);
      if (kDebugMode) {
        print("Get Fav Blog Data $e");
      }
    } finally {
      _showProgress.value = false;
    }
  }

  /*------------------ Get Review Rating -----------------*/
  doReviewRating() async {
    try {
      _showProgress.value = true;
      _reviewRatingUserModel.value = await HomeAPI.getReviewRating();
    } catch (e) {
      showError(e);
      if (kDebugMode) {
        print("Do Review $e");
      }
    } finally {
      _showProgress.value = false;
    }
  }

  /*-------------  Get Salon Search ---------------*/
  doSalonSearch(
      {required String query, required String lat, required String lng}) async {
    try {
      _showProgress.value = true;
      _searchSalonModel.value =
          await HomeAPI.searchForSalon(query: query, lat: lat, lng: lng);
    } catch (e) {
      showError(e);
      if (kDebugMode) {
        print("Search Data Error $e");
      }
    } finally {
      _showProgress.value = false;
    }
  }

  /*--------------------  Save Address For User ---------------*/
  doSaveAddress(
      {required String geolocationLat,
      required String geolocationLng,
      required String address,
      required String directions,
      required String house,
      required VoidCallback callback}) async {
    try {
      _showProgress.value = true;
      bool result = await HomeAPI.saveAddressUser(
          geolocationLat: geolocationLat,
          geolocationLng: geolocationLng,
          address: address,
          directions: directions,
          house: house);
      if (result) {
        callback.call();
      }
    } catch (e) {
      if (kDebugMode) {
        print("Get Saved Address $e");
      }
      showError(e);
    } finally {
      _showProgress.value = false;
    }
  }

  /*----------------  Edit  Save Address For User --------------*/
  doSaveEditAddress(
      {required String geolocationLat,
      required String geolocationLng,
      required String address,
      required String addressID,
      required String directions,
      required String house,
      required VoidCallback callback}) async {
    try {
      _showProgress.value = true;
      bool result = await HomeAPI.saveEditAddressUser(
          addressID: addressID,
          geolocationLat: geolocationLat,
          geolocationLng: geolocationLng,
          address: address,
          directions: directions,
          house: house);
      if (result) {
        callback.call();
      }
    } catch (e) {
      if (kDebugMode) {
        print("Get Saved Edit Address $e");
      }
      showError(e);
    } finally {
      _showProgress.value = false;
    }
  }

  /*--------------- Save Get Address ------------*/
  doGetSaveAddress() async {
    try {
      _showProgress.value = true;
      _saveAddressModel.value = await HomeAPI.getSaveAddressUser();
    } catch (e) {
      if (kDebugMode) {
        print("Get Saved Address $e");
      }
      showError(e);
    } finally {
      _showProgress.value = false;
    }
  }

  /*------------------ Search  Artiest ------------------*/
  doGetSearchArtiest({required String salonId, required String q}) async {
    try {
      _showProgress.value = true;
      _artistSearchModel.value =
          await HomeAPI.searchArtiest(salonId: salonId, q: q);
    } catch (e) {
      if (kDebugMode) {
        print("Get Search Artiest $e");
      }
      showError(e);
    } finally {
      _showProgress.value = false;
    }
  }

  /*----------  Do Delete Save Address ------------*/
  doDeleteSaveAddress(
      {required String id, required VoidCallback callback}) async {
    try {
      _showProgress.value = true;
      bool result = await HomeAPI.deleteSaveAddressUser(id: id);
      if (result) {
        callback.call();
      }
    } catch (e) {
      if (kDebugMode) {
        print("Delete Address $e");
      }
      showError(e);
    } finally {
      _showProgress.value = false;
    }
  }

  /*-------------------------  Do Get PopularServiceByYourStylist ---------------*/
  doGetPopularServiceByYourStylist({required String stylistId}) async {
    try {
      _showProgress.value = true;
      _artistPopularServicesModel.value =
          await HomeAPI.getPopularServiceByYourStylist(stylistId);
    } catch (e) {
      if (kDebugMode) {
        print("Get Popular Service $e");
      }
      showError(e);
    } finally {
      _showProgress.value = false;
    }
  }

  /*----------------------- Do Add View For Blog Section ----------------*/
  doAddViewForBlogSection({required String blogID}) async {
    try {
      _showProgress.value = true;
      bool result = await HomeAPI.addBlogView(blogID);
      if (result) {
        if (kDebugMode) {
          print(result);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Add View For Blog Section $e");
      }
      showError(e);
    } finally {
      _showProgress.value = false;
    }
  }

  /*---------------  Salon Id to  review get ----------------*/
  doGetSalonReview({required String salonId}) async {
    try {
      _showProgress.value = true;
      _salonIdReviewsModel.value =
          await HomeAPI.salonIdToReview(salonId: salonId);
    } catch (e) {
      if (kDebugMode) {
        print("Get Salon Review $e");
      }
      showError(e);
    } finally {
      _showProgress.value = false;
    }
  }

  /*--------------------------- Get  PromoCode -------------------------*/
  doGetPromoCode({required double lat, required double lng,

    required String orderBy,
    required String serviceGender,
    required bool nearest,
    required bool fourPlusRating,
    required bool homeService}) async {
    try {
      _showProgress.value = true;
      _promoCodeModel.value = await HomeAPI.getPromoCode(lat: lat, lng: lng,
      fourPlusRating:fourPlusRating,homeService:homeService ,nearest:nearest ,orderBy: orderBy,serviceGender:serviceGender
      );
    } catch (e) {
      if (kDebugMode) {
        print("GET PROMO-CODE $e");
      }
      showError(e);
    } finally {
      _showProgress.value = false;
    }
  }

  /*-------------------  Get PromoCode List  ----------------------*/
  doGetListPromoCode() async {
    try {
      _showProgress.value = true;
      _promoCodeModelList.value = await HomeAPI.getPromoCodeList();
    } catch (e) {
      if (kDebugMode) {
        print("GetListPromoCode $e");
      }
      showError(e);
    } finally {
      _showProgress.value = false;
    }
  }

  /*-------------------- Add Apply  PromoCode -----------------*/
  doApplyPromoCode({required Map data, required VoidCallback callback}) async {
    try {
      _showProgress.value = true;
      bool result = await HomeAPI.applyPromoCode(data: data);
      if (result) {
        callback.call();
      }
    } catch (e) {
      if (kDebugMode) {
        print("doApplyPromoCode $e");
      }
      showError(e);
    } finally {
      _showProgress.value = false;
    }
  }

  /*------------------  Remove PromoCode ----------------*/
  doRemovePromoCode({required VoidCallback callback}) async {
    try {
      _showProgress.value = false;
      bool result = await HomeAPI.promoCodeRemove();
      if (result) {
        callback.call();
      }
    } catch (e) {
      if (kDebugMode) {
        print("doRemovePromoCode $e");
      }
      showError(e);
    } finally {
      _showProgress.value = false;
    }
  }
}
