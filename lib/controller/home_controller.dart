import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:salon_customer/api/dio_client.dart';
import 'package:salon_customer/constant/api_constant.dart';
import 'package:salon_customer/util/SharedPrefs.dart';
import 'package:socket_io_client/socket_io_client.dart' as socket_io;
import 'package:salon_customer/api/home_api.dart';
import 'package:salon_customer/constant/variable_constant.dart';
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
import '../model/cart/salon_service_add_cart_model.dart';

class HomeController extends GetxController {
  /*>>>>>>>>>>>>>>>>>>>> Loader <<<<<<<<<<<<<<<<<<<<<*/
  final Rx<bool> _showProgress = false.obs;

  Rxn<dynamic> pendingBooking = Rxn();
  final Rxn<BookingData> payNowBooking = Rxn<BookingData>();

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

  /// Persistent serviceId -> categoryName cache. Populated every time a salon's
  /// service list loads (for ANY gender), so category names survive a gender
  /// switch even though salonDetailsListData is replaced with the new gender.
  final Map<String, String> _serviceCategoryCache = {};

  /// Persistent serviceId -> categoryId cache (Row 39). Lets us resolve the
  /// category of a booked cart service without the cart payload carrying the
  /// id, so category-scoped coupons can gate against the current cart.
  final Map<String, String> _serviceCategoryIdCache = {};

  /// Persistent categoryId -> categoryName cache (Row 39), for showing the
  /// human-readable category names on a coupon tile.
  final Map<String, String> _categoryNameById = {};

  /// Folds the currently-loaded salon service list into the persistent cache.
  void cacheServiceCategories() {
    final data = _salonDetailsListData.value.data;
    if (data == null) return;
    void addAll(List cats) {
      for (final cat in cats) {
        final name = cat.name ?? "";
        if (name.isEmpty) continue;
        final catId = cat.id ?? "";
        if (catId.isNotEmpty) _categoryNameById[catId] = name;
        for (final s in cat.services ?? const []) {
          final id = s.id ?? "";
          if (id.isEmpty) continue;
          _serviceCategoryCache[id] = name;
          if (catId.isNotEmpty) _serviceCategoryIdCache[id] = catId;
        }
      }
    }

    addAll(data.selectedCategories ?? const []);
    addAll(data.recommendedCategories ?? const []);
  }

  /// Resolves a service's category name. Used as a fallback when the cart
  /// response doesn't include serviceCategoryName. Reads from the persistent
  /// cache (which accumulates across gender loads).
  String categoryNameForService(String? serviceId) {
    if (serviceId == null || serviceId.isEmpty) return "";
    // Fold in whatever is currently loaded, then look up.
    cacheServiceCategories();
    return _serviceCategoryCache[serviceId] ?? "";
  }

  /// Resolves a service's category id (Row 39). Same accumulate-then-lookup
  /// pattern as [categoryNameForService].
  String categoryIdForService(String? serviceId) {
    if (serviceId == null || serviceId.isEmpty) return "";
    cacheServiceCategories();
    return _serviceCategoryIdCache[serviceId] ?? "";
  }

  /// Resolves a category name from its id (Row 39) for coupon-tile display.
  String categoryNameById(String? categoryId) {
    if (categoryId == null || categoryId.isEmpty) return "";
    return _categoryNameById[categoryId] ?? "";
  }

  /// Category ids present in the current cart (Row 39). Derived from the booked
  /// services so a category-scoped coupon can be gated against the cart.
  Set<String> cartCategoryIds() {
    final data = getServiceAddCartModel.data;
    final ids = <String>{};
    if (data == null) return ids;
    for (final s in data.servicesWithProduct ?? const []) {
      final cid = categoryIdForService(s.serviceId);
      if (cid.isNotEmpty) ids.add(cid);
    }
    for (final it in data.items ?? const []) {
      if (it.isService == true) {
        final cid = categoryIdForService(it.service?.id);
        if (cid.isNotEmpty) ids.add(cid);
      }
    }
    return ids;
  }

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

  /// Reactive reference for listeners (e.g. redirect when cart empties).
  Rx<ServiceAddCartModel> get serviceAddCartModelRx => _serviceAddCartModel;

  set setServiceAddCartModel(val) => _serviceAddCartModel.value = val;

  final Rx<SalonServiceAddCartModel> _salonServiceAddCartModel =
      SalonServiceAddCartModel().obs;

  SalonServiceAddCartModel get getSalonServiceAddCartModel =>
      _salonServiceAddCartModel.value;

  set setSalonServiceAddCartModel(val) => _salonServiceAddCartModel.value = val;

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

  /*--------------- Salon PromoCode Model ------------------*/
  final Rx<PromoCodeModel> _salonPromoCodeModel = PromoCodeModel().obs;

  PromoCodeModel get getSalonPromoCodeModel => _salonPromoCodeModel.value;

  set setSalonPromoCodeModel(val) => _salonPromoCodeModel.value = val;

  /*--------------------  Get  PromoCode List ------------------------*/
  final Rx<PromoCodeModel> _promoCodeModelList = PromoCodeModel().obs;

  PromoCodeModel get getPromoCodeModelList => _promoCodeModelList.value;

  set setPromoCodeModelList(val) => _promoCodeModelList.value = val;

  /*-------------  category Id  -----------------*/
  final RxList categoryId = [].obs;

  /*---------------- getHomeCategory ----------*/
  Future<void> doGetHomeCategory({required String gender}) async {
    try {
      _showProgress.value = true;
      _homeCategoryListModel.value =
          await HomeAPI.homeCategoryList(gender: gender);
      //_homeCategoryListModel.refresh();
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
  Future<void> doGetMakePackageData() async {
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
  Future<void> doGetProductData({required String serviceId}) async {
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
  Future<void> doAddPackageOneData({
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
  Future<void> doRemovePackageData({
    required List<String> serviceCategoryIds,
    required VoidCallback callback,
  }) async {
    try {
      debugPrint("\n🔴 [API START → RemovePackage]");
      debugPrint("IDs → $serviceCategoryIds");
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
  Future<void> doGetHomeSalonDetails({
    required String salonId,
    required String lat,
    required String lng,
    required String serviceGender,
    bool useGlobalLoader = true,
  }) async {
    try {
      if (useGlobalLoader) _showProgress.value = true;
      _homeSalonDetailsData.value = await HomeAPI.getSalonDetail(
          salonId: salonId, lng: lng, lat: lat, serviceGender: serviceGender);
    } catch (e) {
      showError(e);
      if (kDebugMode) {
        print("GetHomeSalonDetails $e");
      }
    } finally {
      if (useGlobalLoader) _showProgress.value = false;
    }
  }

  /*------------------- Get Salon Details Service ---------------- */
  Future<void> doGetSalonDetailsService({
    required String salonId,
    required String serviceGender,
    bool useGlobalLoader = true,
  }) async {
    try {
      if (useGlobalLoader) _showProgress.value = true;
      _salonDetailsListData.value =
          await HomeAPI.getSalonDetailsCategoryServiceList(
              salonId: salonId, serviceGender: serviceGender);
      // Remember this gender's service→category mapping so it survives a
      // later gender switch (Row 38).
      cacheServiceCategories();
    } catch (e) {
      showError(e);
      if (kDebugMode) {
        print("DO Get Artiest List Data $e");
      }
    } finally {
      if (useGlobalLoader) _showProgress.value = false;
    }
  }

  /*------------------------- Do Get Home Salon List -------------*/
  Future<void> doGetHomeSalonList({
    required int offset,
    required int size,
    required double lat,
    required double lng,
    required String orderBy,
    required String serviceGender,
    required bool nearest,
    required bool fourPlusRating,
    required bool homeService,
    bool useGlobalLoader = true,
  }) async {
    try {
      if (useGlobalLoader) _showProgress.value = true;
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
      if (useGlobalLoader) _showProgress.value = false;
    }
  }

  /*--------------- Do Get Salon Artiest ---------------*/
  Future<void> doGetSalonArtiestListData(
      {required String salonId, bool useGlobalLoader = true}) async {
    try {
      if (useGlobalLoader) _showProgress.value = true;
      _salonDetailsArtiestData.value =
          await HomeAPI.salonDetailsArtiest(salonId: salonId);
    } catch (e) {
      showError(e);
      if (kDebugMode) {
        print("Do Get Salon Artiest $e");
      }
    } finally {
      if (useGlobalLoader) _showProgress.value = false;
    }
  }

  /*------------------------------ DO Get Artiest List Data ------------------------------*/
  Future<void> doGetArtiestListData() async {
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
  Future<void> doGetUnAvailableDatesListData({
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
  Future<void> doGetAvailabilitiesTimeSlot(
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

  final Rxn<dynamic> _salonAvailability = Rxn();

  dynamic get salonAvailability => _salonAvailability.value;

  set setSalonAvailability(val) => _salonAvailability.value = val;

  Future<void> doGetSalonAvailability({
    required String salonId,
  }) async {
    try {
      _showProgress.value = true;

      final data = await HomeAPI.getSalonAvailability(
        salonId: salonId,
      );

      _salonAvailability.value = data;
    } catch (e) {
      showError(e);
    } finally {
      _showProgress.value = false;
    }
  }

  var salonProducts = [].obs;
  var isProductsLoading = false.obs;

  Future<void> doGetSalonProducts({required String salonId}) async {
    try {
      isProductsLoading.value = true;

      final res = await DioClient.client.get(
        "/user/salon/$salonId/products",
      );

      salonProducts.value = res.data['data'] ?? [];
    } catch (e) {
      salonProducts.value = [];
    } finally {
      isProductsLoading.value = false;
    }
  }

  /*----------------------- Create Booking  ForCustomer -----------------*/
  // doCreateBooking({
  //   required String salonArtistId,
  //   required Map<String, String> serviceArtistMap,
  //   required String startAt,
  //   required bool isHomeService,
  //   required String userAddressId,
  //   required VoidCallback callback,
  // }) async {
  //   try {
  //     _showBookingProgress.value = true;
  //     _createBookingAppointmentModel.value = await HomeAPI.userCreateBooking(
  //         salonArtistId: salonArtistId,
  //         serviceArtistMap: serviceArtistMap,
  //         startAt: startAt,
  //         isHomeService: isHomeService,
  //         userAddressId: userAddressId);
  //     if (_createBookingAppointmentModel
  //         .value.data?.completionToken?.isNotEmpty ??
  //         false) {
  //       callback.call();
  //     }
  //   } catch (e) {
  //     showError(e);
  //     if (kDebugMode) {
  //       print("Create Booking  ForCustomer $e");
  //     }
  //   } finally {
  //     _showBookingProgress.value = false;
  //   }
  // }

  Future<void> doCreateBooking({
    required List<String> stylistIds,
    required List<String> selectedSlots,
    required bool isHomeService,
    required String userAddressId,
    required VoidCallback callback,
  }) async {
    try {
      _showBookingProgress.value = true;

      _createBookingAppointmentModel.value = await HomeAPI.userCreateBooking(
        stylistIds: stylistIds,
        selectedSlots: selectedSlots,
        isHomeService: isHomeService,
        userAddressId: userAddressId,
      );

      if (_createBookingAppointmentModel
              .value.data?.completionToken?.isNotEmpty ??
          false) {
        callback.call();
      }
    } catch (e) {
      showError(e);
      if (kDebugMode) {
        print("Create Booking ForCustomer $e");
      }
    } finally {
      _showBookingProgress.value = false;
    }
  }

  Future<CreateBookingAppointmentModel?> createNonMandatoryBooking({
    required String salonId,
  }) async {
    try {
      _showBookingProgress.value = true;

      final res = await HomeAPI.userCreateNonMandatoryBooking(
        salonId: salonId,
      );

      return res;
    } catch (e) {
      showError(e);
      if (kDebugMode) {
        print("Create Non Mandatory Booking $e");
      }
      return null;
    } finally {
      _showBookingProgress.value = false;
    }
  }

  Future<dynamic>? fetchBookingByRazorpayOrderId({
    required String razorpayOrderId,
  }) async {
    _createBookingAppointmentModel.value =
        await HomeAPI.getBookingByRazorpayOrderId(
            razorpayOrderId: razorpayOrderId);
    return _createBookingAppointmentModel.value.data;
  }

  Future<void> doCreateBookingIntent({
    required String salonArtistId,
    required String startAt,
    required bool isHomeService,
    required String userAddressId,
  }) async {
    //_showBookingProgress.value = true;
    await HomeAPI.createBookingIntent(
        salonArtistId: salonArtistId,
        startAt: startAt,
        isHomeService: isHomeService,
        userAddressId: userAddressId);
  }

  /*---------------- QR Code Model -------------------*/
  Future<void> doCreateQrCode({required String appointmentId}) async {
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

  // /*------------------- Get  Current Booking List  Data --------------*/
  // doGetCurrentBookingListData() async {
  //   try {
  //     _showProgress.value = true;
  //     _currentBookingListModel.value = await HomeAPI.currentBookingList();
  //   } catch (e) {
  //     showError(e);
  //     if (kDebugMode) {
  //       print("Current Booking List  Data $e");
  //     }
  //   } finally {
  //     _showProgress.value = false;
  //   }
  // }

  Future<void> doGetCurrentBookingListData() async {
    try {
      _showProgress.value = true;

      _currentBookingListModel.value = await HomeAPI.currentBookingList();

      final bookings = _currentBookingListModel.value.data ?? [];

      /// Find booking where payment is pending
      try {
        pendingBooking.value = bookings.firstWhere(
          (b) =>
              b.paymentStatus == "pending" &&
              (b.orderStatus == "pending" || b.orderStatus == "confirmed"),
        );
      } catch (e) {
        pendingBooking.value = null;
      }
    } catch (e) {
      showError(e);
      if (kDebugMode) {
        print("Current Booking List Data $e");
      }
    } finally {
      _showProgress.value = false;
    }
  }

  Future<void> findPayNowBooking(String salonId) async {
    final bookings = _currentBookingListModel.value.data ?? [];

    try {
      payNowBooking.value = bookings.firstWhere((b) =>
          b.salon?.id == salonId &&
          b.paymentStatus == "pending" &&
          (b.orderAmount ?? 0) == 0);
    } catch (e) {
      payNowBooking.value = null;
    }
  }

  /*-----------------  Add  Favourite Salon ---------------*/
  Future<void> doAddFavouriteSalon({required String salonId}) async {
    try {
      _showAddProgress.value = true;
      bool result = await HomeAPI.addFavouriteSalon(salonId: salonId);
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
  Future<void> doRemoveFavouriteSalon(
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
  Future<void> doGetFavouriteSalon() async {
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
  Future<void> doAddCart(
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
      /* showError(e);*/
      if (kDebugMode) {
        print("Add Cart $e");
      }
    } finally {
      _showProgress.value = false;
    }
  }

  /*-------------------  Remove Cart ------------------*/
  Future<void> doRemoveCart(
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

  final RxBool _skipNextGetCart = false.obs;
  /*---------------- Get Cart ---------------*/
  Future<void> doGetCart({bool useGlobalLoader = true}) async {
    // keep your one-shot skip if you added it
    if (_skipNextGetCart.value) {
      _skipNextGetCart.value = false;
      return;
    }

    try {
      if (useGlobalLoader) _showProgress.value = true; // changed
      _serviceAddCartModel.value = await HomeAPI.getUserCart();
      tempQty.clear(); // 👈 ADD THIS
      if (_serviceAddCartModel.value.data?.items?.isEmpty ?? false) {
        stylistId.value = "";
      }
    } catch (e) {
      if (e.toString().contains("Cart not found")) {
        _serviceAddCartModel.value = ServiceAddCartModel(); // empty state
        return;
      }
      showError(e);
      if (kDebugMode) print("Get Cart XXXXXXXXXXXXXXXXXXX $e");
    } finally {
      if (useGlobalLoader) _showProgress.value = false; // changed
    }
  }

  Future<void> doGetSalonCart(
      {bool useGlobalLoader = true,
      required String salonId,
      VoidCallback? callback}) async {
    // keep your one-shot skip if you added it
    if (_skipNextGetCart.value) {
      _skipNextGetCart.value = false;
      callback?.call();
      return;
    }

    try {
      if (useGlobalLoader) _showProgress.value = true; // changed
      _salonServiceAddCartModel.value =
          await HomeAPI.getUserSalonCart(salonId: salonId);
      tempQty.clear(); // 👈 ADD THIS
      if (_salonServiceAddCartModel.value.data?.items?.isEmpty ?? false) {
        stylistId.value = "";
      }
      // update(); // or refresh()
      // callback?.call();
    } catch (e) {
      if (e.toString().contains("Cart not found")) {
        _serviceAddCartModel.value = ServiceAddCartModel(); // empty state
        return;
      }
      showError(e);
      if (kDebugMode) print("Get Cart SSSSSSSSSSSSSSSS $e");
    } finally {
      if (useGlobalLoader) _showProgress.value = false; // changed
    }
  }

  final RxMap<String, int> tempQty = <String, int>{}.obs;

  int getQuantity(String serviceId) {
    /// 🔥 TEMP UI LAYER FIRST
    if (tempQty.containsKey(serviceId)) {
      return tempQty[serviceId]!;
    }

    /// 🔥 BACKEND FALLBACK
    final services = getServiceAddCartModel.data?.servicesWithProduct ?? [];

    final item = services.firstWhere(
      (e) => e.serviceId == serviceId,
      orElse: () => ServicesWithProduct(quantity: 0),
    );

    return item.quantity ?? 0;
  }

  Future<void> doSendSalonRequest(String message) async {
    try {
      _showProgress.value = true;

      await HomeAPI.sendSalonRequest(message);
    } catch (e) {
      showError(e);
      if (kDebugMode) print("Salon Request Error $e");
    } finally {
      _showProgress.value = false;
    }
  }

  int getTotalItems() {
    final services = getServiceAddCartModel.data?.servicesWithProduct ?? [];

    int total = 0;

    for (var s in services) {
      final id = s.serviceId ?? "";

      if (tempQty.containsKey(id)) {
        total += tempQty[id]!;
      } else {
        total += s.quantity ?? 0;
      }
    }

    return total;
  }

  /// When the cart salon is not GST-registered, service GST is not applied.
  /// If `isGSTRegistered` is absent (null), GST is included for backward compatibility.
  bool get isCartSalonGstRegistered =>
      getServiceAddCartModel.data?.salon?.isGSTRegistered ?? true;

  double getTotalPrice() {
    final data = getServiceAddCartModel.data;

    final double subtotal =
        (data?.taxAbleTotal ?? 0).toDouble(); // after discount
    final double gst = (data?.cartTaxDetails?.totalTaxAmount ?? 0).toDouble();
    final double platformFee = (data?.platformFee ?? 0).toDouble();

    return subtotal + (isCartSalonGstRegistered ? gst : 0.0) + platformFee;
  }

  double getPriceNoGST() {
    final data = getServiceAddCartModel.data;

    final double subtotal =
        (data?.taxAbleTotal ?? 0).toDouble(); // after discount

    return subtotal;
  }

  /*---------- Clear Cart --------------*/
  Future<void> doClearCart({required VoidCallback callback}) async {
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

  Future<void> doAddProductCart(
      {required String productId,
      required String productSelectedServiceId,
      required bool isHomeService,
      required VoidCallback callback}) async {
    try {
      _showProgress.value = true;
      _serviceAddCartModel.value = await HomeAPI.addProductCart(
          productId: productId,
          productSelectedServiceId: productSelectedServiceId,
          isHomeService: isHomeService);
      if (_serviceAddCartModel.value.success ?? false) {
        callback.call();
      }
    } catch (e) {
      showError(e);
      if (kDebugMode) {
        print("Add Cart product $e");
      }
    } finally {
      _showProgress.value = false;
    }
  }

  /*----------------- Remove Cart in  Product ------------------*/
  Future<void> doRemoveProductCart(
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
  Future<void> doGetBookingHistory() async {
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

  /// Fetches booking history silently (no progress loader). Returns the most
  /// recent completed appointment's [finalizedAt], or null if none exists.
  Future<DateTime?> fetchLatestCompletedBookingDate() async {
    try {
      _bookingHistoryListModel.value = await HomeAPI.bookingHistory();
      final completed = _bookingHistoryListModel.value.data
          ?.where((h) => h.orderStatus == "completed")
          .toList();
      if (completed == null || completed.isEmpty) return null;
      completed.sort((a, b) => (b.finalizedAt ?? "").compareTo(a.finalizedAt ?? ""));
      return DateTime.tryParse(completed.first.finalizedAt ?? "");
    } catch (e) {
      if (kDebugMode) print("fetchLatestCompletedBookingDate error: $e");
      return null;
    }
  }

  /*-------------  Get Order Id Model ---------------*/
  final RxBool _skipNextGetOrderId = false.obs;

  Future<void> doGetOrderId({bool useGlobalLoader = true}) async {
    if (_skipNextGetOrderId.value) {
      _skipNextGetOrderId.value = false;
      return;
    }
    try {
      if (useGlobalLoader) _showProgress.value = true;
      _orderIdModel.value = await HomeAPI.orderIdGet();
    } catch (e) {
      showError(e);
      if (kDebugMode) print("Get Order Id $e");
    } finally {
      if (useGlobalLoader) _showProgress.value = false;
    }
  }

  Future<void> createPaymentOrder({
    required String? bookingOrderId,
    required int billAmount,
    required int payableAmount,
    bool useGlobalLoader = true,
  }) async {
    try {
      if (useGlobalLoader) _showProgress.value = true;

      _orderIdModel.value = await HomeAPI.createPaymentOrder(
        bookingOrderId: bookingOrderId,
        billAmount: billAmount,
        payableAmount: payableAmount,
      );
    } catch (e) {
      showError(e);
      if (kDebugMode) print("Create Payment Order $e");
    } finally {
      if (useGlobalLoader) _showProgress.value = false;
    }
  }

  /*----------------------------  Upload PortFolio --------------------*/
  Future<void> doUploadPortFolio({
    required String appointmentId,
    required bool isUpload,
    String? name,
    String? phone,
  }) async {
    try {
      _showProgress.value = true;

      bool result = await HomeAPI.portFolioUpload(
        appointmentId: appointmentId,
        isUpload: isUpload,
        name: name,
        phone: phone,
      );

      if (result) {
        //showMessage("Portfolio Request Sent Successfully");
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

  Future<void> doUploadImage(
      {required String appointmentId,
      required List<String> multiplePath,
      required List<String> multiplePathVideo,
      required VoidCallback callback}) async {
    try {
      _showProgress.value = true;
      String result = await HomeAPI.uploadImage(
          appointmentId: appointmentId,
          multiplePath: multiplePath,
          multipleVideo: multiplePathVideo);
      if (result != "") {
        callback.call();
      }
    } catch (e) {
      showError(e);
      print("Error Data Show new ${e.toString()}");
    } finally {
      _showProgress.value = false;
    }
  }

  /*---------------------  Get Review Data List Model ----------------*/
  Future<void> doGetReviewDataList({required String appointmentId}) async {
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

  final RxBool hasPendingReview = false.obs;
  final RxString pendingReviewBookingId = "".obs;
  final RxString pendingReviewsalonId = "".obs;
  RxBool isSubmittingReview = false.obs;

  Future<void> doCheckPendingReview() async {
    try {
      _showProgress.value = true;

      final data = await HomeAPI.getPendingReview();

      if (data["hasPendingReview"] == true) {
        hasPendingReview.value = true;
        pendingReviewBookingId.value = data["bookingId"];
        pendingReviewsalonId.value = data["salonId"];
      } else {
        hasPendingReview.value = false;
      }
    } catch (e) {
      showError(e);
      if (kDebugMode) {
        print("Pending Review Error $e");
      }
    } finally {
      _showProgress.value = false;
    }
  }

  /*>>>>>>>>>>>>>>>>>>>>>> Add Review <<<<<<<<<<<<<<<<<<<<<<<*/
  /*============= Service ================*/
  // doAddServiceReview({
  //   required String appointmentId,
  //   required double rate,
  //   required String salonServiceId,
  //   required String review,
  //   required VoidCallback callback,
  // }) async {
  //   try {
  //     _showAddProgress.value = true;
  //     bool result = await HomeAPI.addAppointmentServiceReview(
  //         appointmentId: appointmentId,
  //         rate: rate,
  //         salonServiceId: salonServiceId,
  //         review: review);
  //     if (result) {
  //       callback.call();
  //     }
  //   } catch (e) {
  //     showError(e);
  //     if (kDebugMode) {
  //       print("Add Service Review$e");
  //     }
  //   } finally {
  //     _showAddProgress.value = false;
  //   }
  // }

  Future<bool> doAddServiceReview({
    required String appointmentId,
    required double rate,
    required String salonServiceId,
    required String review,
  }) async {
    try {
      _showAddProgress.value = true;

      return await HomeAPI.addAppointmentServiceReview(
        appointmentId: appointmentId,
        rate: rate,
        salonServiceId: salonServiceId,
        review: review,
      );
    } catch (e) {
      showError(e);
      return false;
    } finally {
      _showAddProgress.value = false;
    }
  }

  /*================ Product ==================*/
  Future<void> doAddProductReview({
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
  // doAddArtiestReview({
  //   required String appointmentId,
  //   required double rate,
  //   required String salonArtistId,
  //   required String review,
  //   required VoidCallback callback,
  // }) async {
  //   try {
  //     _showAddProgress.value = true;
  //     bool result = await HomeAPI.addAppointmentArtiestReview(
  //         appointmentId: appointmentId,
  //         rate: rate,
  //         salonArtistId: salonArtistId,
  //         review: review);
  //     if (result) {
  //       callback.call();
  //     }
  //   } catch (e) {
  //     showError(e);
  //     if (kDebugMode) {
  //       print("Add Artiest Review $e");
  //     }
  //   } finally {
  //     _showAddProgress.value = false;
  //   }
  // }

  Future<bool> doAddArtistReview({
    required String appointmentId,
    required double rate,
    required String salonArtistId,
    required String review,
  }) async {
    try {
      _showAddProgress.value = true;

      return await HomeAPI.addAppointmentArtiestReview(
        appointmentId: appointmentId,
        rate: rate,
        salonArtistId: salonArtistId,
        review: review,
      );
    } catch (e) {
      showError(e);
      return false;
    } finally {
      _showAddProgress.value = false;
    }
  }

  /*--------------------------  Artiest Portfolio -----------------*/
  Future<void> doGetArtiestPortfolio({required String artistId}) async {
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
  Future<void> doGetBlogData({required double lat, required double lng}) async {
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
  Future<void> doAddFavBlog(
      {required String blogId, required VoidCallback callback}) async {
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
  Future<void> doRemoveBlog(
      {required String blogId, required VoidCallback callback}) async {
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
  Future<void> doGetFavBlogData() async {
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
  Future<void> doReviewRating() async {
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
  Future<void> doSalonSearch(
      {required String query,
      required String lat,
      required String lng,
      String searchBy = "salon"}) async {
    try {
      _showProgress.value = true;
      _searchSalonModel.value = await HomeAPI.searchForSalon(
          query: query, lat: lat, lng: lng, searchBy: searchBy);
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
  Future<void> doSaveAddress(
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
  Future<void> doSaveEditAddress(
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
  Future<void> doGetSaveAddress() async {
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
  Future<void> doGetSearchArtiest(
      {required String salonId, required String q}) async {
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
  Future<void> doDeleteSaveAddress(
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
  Future<void> doGetPopularServiceByYourStylist(
      {required String stylistId}) async {
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
  Future<void> doAddViewForBlogSection({required String blogID}) async {
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
  Future<void> doGetSalonReview({required String salonId}) async {
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
  Future<void> doGetPromoCode(
      {required double lat,
      required double lng,
      required String orderBy,
      required String serviceGender,
      required bool nearest,
      required bool fourPlusRating,
      required bool homeService}) async {
    try {
      _showProgress.value = true;
      _promoCodeModel.value = await HomeAPI.getPromoCode(
          lat: lat,
          lng: lng,
          fourPlusRating: fourPlusRating,
          homeService: homeService,
          nearest: nearest,
          orderBy: orderBy,
          serviceGender: serviceGender);
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
  Future<void> doGetListPromoCode() async {
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

  Map<String, dynamic>? getBestDiscount(int amount) {
    final promos = getSalonPromoCodeModel.data ?? [];

    int bestDiscount = 0;
    dynamic bestPromo;

    final now = DateTime.now();

    for (var promo in promos) {
      DateTime? startDate;
      DateTime? endDate;

      if (promo.startsAt != null) {
        startDate = DateTime.parse(promo.startsAt!.replaceAll(" ", "T"));
      }

      if (promo.endsAt != null) {
        endDate = DateTime.parse(promo.endsAt!.replaceAll(" ", "T"));
      }

      if (startDate != null && now.isBefore(startDate)) continue;
      if (endDate != null && now.isAfter(endDate)) continue;

      final today = now.weekday % 7; // convert 1–7 → 0–6

      final applicableDays = promo.applicableDays;

      final bool isDayValid = applicableDays == null ||
          applicableDays.isEmpty ||
          applicableDays.contains(today);

      if (!isDayValid) continue;

      int minOrder = int.tryParse(promo.minOrder?.toString() ?? '0') ?? 0;
      if (amount < minOrder) continue;

      double promoAmount =
          double.tryParse(promo.amount?.toString() ?? '0') ?? 0;

      int maxDiscount = int.tryParse(promo.maxDiscount?.toString() ?? '0') ?? 0;

      int discount = 0;

      if (promo.type == "percentage") {
        discount = ((amount * promoAmount) / 100).floor();

        if (maxDiscount > 0 && discount > maxDiscount) {
          discount = maxDiscount;
        }
      } else {
        discount = promoAmount.toInt();
      }

      if (discount > bestDiscount) {
        bestDiscount = discount;
        bestPromo = promo;
      }
    }

    if (bestPromo == null) return null;

    return {
      "discount": bestDiscount,
      "promo": bestPromo,
    };
  }

  /*-------------------  Get PromoCode List  ----------------------*/
  Future<void> doGetSalonPromoCode(
      {required String salonId, bool useGlobalLoader = true}) async {
    try {
      if (useGlobalLoader) _showProgress.value = true;
      _salonPromoCodeModel.value =
          await HomeAPI.getSalonPromoCodeList(salonId: salonId);
    } catch (e) {
      if (kDebugMode) {
        print("GetListPromoCode $e");
      }
      showError(e);
    } finally {
      if (useGlobalLoader) _showProgress.value = false;
    }
  }

  /*-------------------- Add Apply  PromoCode -----------------*/
  Future<void> doApplyPromoCode(
      {required Map data, required VoidCallback callback}) async {
    try {
      _showProgress.value = true; // one loader for the whole sequence

      final bool ok = await HomeAPI.applyPromoCode(data: data);
      if (!ok) return;

      // Fetch both without toggling the loader again
      await doGetCart(useGlobalLoader: false);
      // Commenting because of Pay after Service.
      //await doGetOrderId(useGlobalLoader: false);

      // Make the page's immediate doGetCart() a no-op if you added the guard earlier
      _skipNextGetCart.value = true;
      _skipNextGetOrderId.value = true;

      callback.call();
    } catch (e) {
      if (kDebugMode) print("doApplyPromoCode $e");
      showError(e);
    } finally {
      _showProgress.value = false; // end the single loader
    }
  }

  /*------------------  Remove PromoCode ----------------*/
  Future<void> doRemovePromoCode({required VoidCallback callback}) async {
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

  /*------------------  Delete package ------------------------*/
  Future<void> doDeletePackage({required VoidCallback callback}) async {
    try {
      _showProgress.value = false;
      bool result = await HomeAPI.deletePackage();
      if (result) {
        callback.call();
      }
    } catch (e) {
      if (kDebugMode) {
        print("delete package  $e");
      }
      showError(e);
    } finally {
      _showProgress.value = false;
    }
  }

  Future<StandardResponse> cancelBooking({
    required String bookingId,
    //required String artistId,
    required String status,
    //required VoidCallback callback,
    required String cancellationReasonId,
    required String? cancellationRemark,
  }) async {
    try {
      //_showProgress.value = true;
      bool result = await HomeAPI.approveBooking(
          bookingId: bookingId,
          //artistId: artistId,
          status: status,
          cancellationReasonId: cancellationReasonId,
          cancellationRemark: cancellationRemark);

      if (result) {
        return StandardResponse(
            success: true, message: "Cancelled successfully");
      } else {
        return StandardResponse(success: false, message: "Failed to cancel");
      }
    } catch (e) {
      showError(e);
      return StandardResponse(success: false, message: e.toString());
    } finally {
      _showProgress.value = false;
    }
  }

  Future<StandardResponse> reScheduledBooking({
    required String appointmentId,
    required String newTime,
    required VoidCallback callback,
  }) async {
    try {
      _showProgress.value = true;
      bool result = await HomeAPI.reScheduleBooking(
          appointmentId: appointmentId, newTime: newTime);

      if (result) {
        callback.call();
        return StandardResponse(
            success: true, message: "Re scheduled successfully");
      } else {
        return StandardResponse(
            success: false, message: "Failed to re schedule");
      }
    } catch (e) {
      showError(e);
      return StandardResponse(success: false, message: e.toString());
    } finally {
      _showProgress.value = false;
    }
  }

  /*-------------- Customer Booking-Confirmed Socket --------------*/

  socket_io.Socket? _bookingConfirmedSocket;
  String? _bookingConfirmedSocketUserId;
  DateTime? _lastBookingConfirmedRefresh;

  void _logBookingSocket(String msg) {
    if (kDebugMode) print('[CustomerSocket] $msg');
  }

  void debugSocketState() {
    final s = _bookingConfirmedSocket;
    print('========= SOCKET DEBUG =========');
    print('instance hashCode : ${s?.hashCode}');
    print('connected         : ${s?.connected}');
    print('socket id         : ${s?.id}');
    print('userId joined     : $_bookingConfirmedSocketUserId');
    print('================================');
  }

  void ensureBookingConfirmedSocket({
    required String appointmentId,
  }) {
    final userId = SharedPrefs.readStringValue(PrefConstants.userId);
    if (userId.isEmpty || appointmentId.isEmpty) return;
    if (_bookingConfirmedSocket != null &&
        _bookingConfirmedSocketUserId == userId &&
        _bookingConfirmedSocket!.connected) {
      _logBookingSocket('already connected for userId=$userId');
      return;
    }

    unbindBookingConfirmedSocket();

    final refreshToken =
        SharedPrefs.readStringValue(PrefConstants.refreshToken);
    if (refreshToken.isEmpty) {
      _logBookingSocket('no refreshToken, skipping socket');
      return;
    }

    final socket = socket_io.io(
      APIConstants.socketUrl,
      socket_io.OptionBuilder()
          .setTransports(['websocket'])
          .setPath('/socket.io')
          .disableAutoConnect()
          .setTimeout(20000)
          .setAuth({'refreshToken': refreshToken})
          .build(),
    );

    _logBookingSocket('socket instance: ${socket.hashCode}');

    socket.onConnect((_) {
      _logBookingSocket(
          'connected id=${socket.id} hashCode=${socket.hashCode} → emit join userId=$userId');
      socket.emit('join', userId);
    });

    socket.onConnectError((dynamic data) {
      _logBookingSocket('connect_error: $data');
    });

    socket.onDisconnect((dynamic reason) {
      _logBookingSocket('disconnect: $reason');
    });

    socket.onError((dynamic data) {
      _logBookingSocket('error: $data');
    });

    socket.onAny((event, data) {
      _logBookingSocket('onAny → event=$event data=$data');
      // Row 36: any booking-status change (accept/cancel/reject/reschedule)
      // silently refreshes the lists so Bookings/Home reflect it instantly,
      // regardless of the exact event name the backend uses.
      final e = event.toString().toLowerCase();
      if (e.contains('booking') ||
          e.contains('appointment') ||
          e.contains('order') ||
          e.contains('cancel') ||
          e.contains('reject') ||
          e.contains('confirm')) {
        refreshBookingListsSilent();
      }
    });

    socket.on('booking_confirmed', (dynamic data) {
      _logBookingSocket('booking_confirmed received: $data');
      final incomingAppointmentId =
          data is Map ? data['appointmentId']?.toString() : null;
      if (incomingAppointmentId != null &&
          incomingAppointmentId != appointmentId) {
        _logBookingSocket(
            'booking_confirmed ignored (different appointmentId)');
        return;
      }
      final now = DateTime.now();
      final last = _lastBookingConfirmedRefresh;
      if (last != null && now.difference(last).inMilliseconds < 400) {
        _logBookingSocket('booking_confirmed ignored (debounced)');
        return;
      }
      _lastBookingConfirmedRefresh = now;
      _logBookingSocket(
          'booking_confirmed → refresh QR for appointmentId=$appointmentId');
      _refreshQrCodeSilent(appointmentId);
    });

    socket.connect();
    _logBookingSocket('connect() invoked...');

    _bookingConfirmedSocket = socket;
    _bookingConfirmedSocketUserId = userId;
  }

  Future<void> _refreshQrCodeSilent(String appointmentId) async {
    try {
      _userBookingQrCodeModel.value =
          await HomeAPI.userBookingQrCodeDetails(appointmentId: appointmentId);
    } catch (e) {
      if (kDebugMode) {
        print('[CustomerSocket] _refreshQrCodeSilent error: $e');
      }
    }
  }

  DateTime? _lastBookingListRefresh;

  /// Row 36: silently refresh the booking lists (current + history) and the
  /// pending-booking pointer so Bookings/Home reflect an accept/cancel without
  /// a manual refresh. Debounced and does NOT toggle the global loader.
  Future<void> refreshBookingListsSilent() async {
    final now = DateTime.now();
    final last = _lastBookingListRefresh;
    if (last != null && now.difference(last).inMilliseconds < 500) return;
    _lastBookingListRefresh = now;

    try {
      _currentBookingListModel.value = await HomeAPI.currentBookingList();
      final bookings = _currentBookingListModel.value.data ?? [];
      try {
        pendingBooking.value = bookings.firstWhere(
          (b) =>
              b.paymentStatus == "pending" &&
              (b.orderStatus == "pending" || b.orderStatus == "confirmed"),
        );
      } catch (_) {
        pendingBooking.value = null;
      }
    } catch (e) {
      if (kDebugMode) print('[CustomerSocket] refresh current error: $e');
    }

    try {
      _bookingHistoryListModel.value = await HomeAPI.bookingHistory();
    } catch (e) {
      if (kDebugMode) print('[CustomerSocket] refresh history error: $e');
    }
  }

  void unbindBookingConfirmedSocket() {
    if (_bookingConfirmedSocket != null) {
      _logBookingSocket(
          'disposing socket (userId=$_bookingConfirmedSocketUserId)');
    }
    _bookingConfirmedSocket?.dispose();
    _bookingConfirmedSocket = null;
    _bookingConfirmedSocketUserId = null;
    _lastBookingConfirmedRefresh = null;
  }

  @override
  void onClose() {
    unbindBookingConfirmedSocket();
    super.onClose();
  }

/*-------------------------  -------------------------*/
}

class StandardResponse {
  final bool success;
  final String? message;

  StandardResponse({required this.success, this.message});
}
