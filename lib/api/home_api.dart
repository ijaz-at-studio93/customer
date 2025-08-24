import 'package:dio/dio.dart';
import 'package:salon_customer/api/dio_client.dart';
import 'package:salon_customer/model/artiest_list_model.dart';
import 'package:salon_customer/model/artiest_popular_service_model.dart';
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
import 'package:salon_customer/model/favourite_salon_list_data_model.dart';
import 'package:salon_customer/model/home_category_list_model.dart';
import 'package:salon_customer/model/home_salon_list_model.dart';
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
import '../model/current_booking_list_model.dart';
import '../model/promo_code/promocode_model.dart';

class HomeAPI {
  /*---------------------- home category ------------------*/ static Future<
      HomeCategoryListModel> homeCategoryList({required String gender}) async {
    final response = await DioClient.client
        .get("user/home/category/list", queryParameters: {"gender": gender});
    if (response.isSuccess) {
      return HomeCategoryListModel.fromJson(response.data);
    } else {
      throw response.data;
    }
  }

  /*--------------- Make Package Data Get ---------------------- */
  static Future<HomeCategoryListModel> makePackageDataGet() async {
    final response =
        await DioClient.client.get("user/home/get-last-make-your-own-package");
    if (response.isSuccess) {
      return HomeCategoryListModel.fromJson(response.data);
    } else {
      throw response.data;
    }
  }

  /*---------------  crate Package Package Category --------------*/
  static Future<bool> createOwnPackage(
      {required List<String> serviceCategoryIds}) async {
    final formData = FormData.fromMap({});

    if (serviceCategoryIds.isNotEmpty) {
      for (int i = 0; i < serviceCategoryIds.length; i++) {
        formData.fields
            .add(MapEntry("serviceCategoryIds[]", serviceCategoryIds[i]));
      }
    }
    logger.e(formData);
    final response = await DioClient.client
        .patch("user/home/make-your-own-package-add-service", data: formData);
    if (response.isSuccess) {
      return true;
    } else {
      throw response.data;
    }
  }

  /*----------------------  remove Package Category -----------------*/
  static Future<bool> removePackageCategory(
      {required List<String> serviceCategoryIds}) async {
    final formData = FormData.fromMap({});
    if (serviceCategoryIds.isNotEmpty) {
      for (int i = 0; i < serviceCategoryIds.length; i++) {
        formData.fields
            .add(MapEntry("serviceCategoryIds[]", serviceCategoryIds[i]));
      }
    }
    final response = await DioClient.client.patch(
        "user/home/make-your-own-package-remove-service",
        data: formData);
    if (response.isSuccess) {
      return true;
    } else {
      throw response.data;
    }
  }

  /*-------------------  get Salon  Salon -----------------*/
  static Future<HomeSalonModel> getSalonHome(
      {required int offset,
      required int size,
      required double lat,
      required double lng,
      required String orderBy,
      required String serviceGender,
      required bool nearest,
      required bool fourPlusRating,
      required bool homeService}) async {
    final formData = FormData.fromMap({
      'page': offset,
      'limit': size,
      "lat": lat == 0.0 ? 00.00 : lat,
      "lng": lng == 0.0 ? 00.00 : lng,
      "distanceRadius": 50000,
      "homeService": homeService,
      "orderDirection": orderBy == "name" ? "ASC" : "DESC",
      "nearest": nearest,
      "fourPlusRating": fourPlusRating,
      "serviceGender": serviceGender,
    });

    if (orderBy.isNotEmpty) {
      formData.fields.add(MapEntry("orderBy", orderBy));
    }

    final response = await DioClient.client
        .post('user/home/salon/list-post', data: formData);
    if (response.isSuccess) {
      return HomeSalonModel.fromJson(response.data);
    } else {
      throw response.data;
    }
  }

  /*---------------------- Salon Detail --------------------*/
  static Future<HomeSalonDetailsModel> getSalonDetail({
    required String salonId,
    required String lat,
    required String lng,
    required String serviceGender,
  }) async {
    final response = await DioClient.client.get("user/salon/$salonId/details",
        queryParameters: {
          "lat": lat,
          "lng": lng,
          "serviceGender": serviceGender
        });
    if (response.isSuccess) {
      return HomeSalonDetailsModel.fromJson(response.data);
    } else {
      throw response.data;
    }
  }

  /*---------------- Salon  Details Category service  List ----------------*/
  static Future<CategoryServicesListModel> getSalonDetailsCategoryServiceList(
      {required String salonId,required String serviceGender}) async {
    final response = await DioClient.client
        .get("user/salon/$salonId/category/services-with-selected-categories",
    queryParameters: {
      "serviceGender": serviceGender
    }
    );
    if (response.isSuccess) {
      return CategoryServicesListModel.fromJson(response.data);
    } else {
      throw response.data;
    }
  }

  /*------------- Salon Details Artiest List ------------*/
  static Future<SalonDetailsArtiestModel> salonDetailsArtiest(
      {required String salonId}) async {
    final response = await DioClient.client.get("user/salon/$salonId/artist");
    if (response.isSuccess) {
      return SalonDetailsArtiestModel.fromJson(response.data);
    } else {
      throw response.data;
    }
  }

  /*----------------- Get Artiest ------------*/
  static Future<ArtistListModel> getArtiest() async {
    final response =
        await DioClient.client.get("user/cart/artists-by-cart-services");
    if (response.isSuccess) {
      return ArtistListModel.fromJson(response.data);
    } else {
      throw response.data;
    }
  }

  /* --------------------------- Get UnAvailableDates --------------------------- */
  static Future<UnAvailableDatesModel> getUnAvailableDates(
      {required String artiestId, required String date}) async {
    final response = await DioClient.client
        .get("user/cart/artist/$artiestId/unavailable-dates", queryParameters: {
      "date": date,
    });
    if (response.isSuccess) {
      return UnAvailableDatesModel.fromJson(response.data);
    } else {
      throw response.data;
    }
  }

  /*---------------------------------- Get availabilities Time  Slot ------------------------------------------------*/
  static Future<AvailabilitiesTimeSlotModel> getAvailabilitiesTimeSlot(
      {required String artiestId, required String date}) async {
    final response = await DioClient.client
        .get("user/cart/artist/$artiestId/availability", queryParameters: {
      "date": date,
    });
    if (response.isSuccess) {
      return AvailabilitiesTimeSlotModel.fromJson(response.data);
    } else {
      throw response.data;
    }
  }

  /*--------------------------- User Booking Create --------------------------*/
  static Future<CreateBookingAppointmentModel> userCreateBooking({
    required String salonArtistId,
    required String startAt,
    required bool isHomeService,
    required String userAddressId,
  }) async {
    final response = await DioClient.client.post("user/booking/create", data: {
      "salonArtistId": salonArtistId,
      "startAt": startAt,
      "isHomeService": isHomeService,
      "userAddressId": userAddressId,
    });
    if (response.isSuccess) {
      return CreateBookingAppointmentModel.fromJson(response.data);
    } else {
      throw response.data;
    }
  }

  /*---------------------Get Booking Qr Code Details ------------------*/
  static Future<UserBookingQrCodeModel> userBookingQrCodeDetails({
    required String appointmentId,
  }) async {
    final response =
        await DioClient.client.get("user/booking/appointments/$appointmentId");
    if (response.statusCode == 200) {
      return UserBookingQrCodeModel.fromJson(response.data);
    } else {
      return response.data;
    }
  }

  /*------------------------------------ Current Booking List Model -----------------------*/
  static Future<CurrentBookingListModel> currentBookingList() async {
    final response =
        await DioClient.client.get("user/booking/current-booking/list");
    if (response.isSuccess) {
      return CurrentBookingListModel.fromJson(response.data);
    } else {
      throw response.data;
    }
  }

  /*--------------------- Add Favourite Salon ------------------ */
  static Future<bool> addFavouriteSalon({required String salonId}) async {
    final response =
        await DioClient.client.put("user/salon/favourite/add", data: {
      "salonId": salonId,
    });
    if (response.isSuccess) {
      return true;
    } else {
      throw response.data;
    }
  }

  /*--------------------- Remove Favourite Salon ------------------ */
  static Future<bool> removeFavouriteSalon({required String salonId}) async {
    final response =
        await DioClient.client.delete("user/salon/favourite/remove", data: {
      "salonId": salonId,
    });
    if (response.isSuccess) {
      return true;
    } else {
      throw response.data;
    }
  }

  /*----------------  Get Favourite  Salon ------------------*/
  static Future<FavouriteSalonModel> getFavouriteSalon() async {
    final response = await DioClient.client.get("user/salon/favourite/");
    if (response.isSuccess) {
      return FavouriteSalonModel.fromJson(response.data);
    } else {
      throw response.data;
    }
  }

  /*>>>>>>>>>>>>>>>>>>>>> CART ADD <<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

  /*----------- Add Cart ------------*/
  static Future<bool> serviceAddCart(
      {required String salonServiceId, required bool isHomeService}) async {
    final response = await DioClient.client.put("user/cart/add", data: {
      "salonServiceId": salonServiceId,
      "isHomeService": isHomeService
    });
    if (response.isSuccess) {
      return true;
    } else {
      throw response.data;
    }
  }

  /*------------ get Service Product -----------------*/
  static Future<ServiceProductModel> getServiceProduct(String serviceId) async {
    final response =
        await DioClient.client.get("user/salon/service/$serviceId/products");
    if (response.isSuccess) {
      return ServiceProductModel.fromJson(response.data);
    } else {
      throw response.data;
    }
  }

  /*------------------ Remove Cart -------------------*/
  static Future<bool> serviceRemoveAddCart(
      {required String salonServiceId}) async {
    final response = await DioClient.client
        .put("user/cart/remove", data: {"salonServiceId": salonServiceId});
    if (response.isSuccess) {
      return true;
    } else {
      throw response.data;
    }
  }

  /*------------- Get User Cart  Data -------------*/
  static Future<ServiceAddCartModel> getUserCart() async {
    final response = await DioClient.client.get("user/cart");
    if (response.isSuccess) {
      return ServiceAddCartModel.fromJson(response.data);
    } else {
      throw response.data;
    }
  }

  /*------------------- Clear Cart ---------------*/
  static Future<bool> removeCart() async {
    final response = await DioClient.client.delete("user/cart/clear");
    if (response.isSuccess) {
      return true;
    } else {
      throw response.data;
    }
  }

  /*------------------ Add cart Product ---------------------*/
  static Future<ServiceAddCartModel> addProductCart(
      {required String productId,
      required String productSelectedServiceId,
      required bool isHomeService}) async {
    final response = await DioClient.client.put("user/cart/add", data: {
      "productId": productId,
      "productSelectedServiceId": productSelectedServiceId,
      "isHomeService": isHomeService
    });
    if (response.isSuccess) {
      return ServiceAddCartModel.fromJson(response.data);
    } else {
      throw response.data;
    }
  }

  /*------------------  Remove Cart Product ---------------------*/
  static Future<bool> removeProductCart(
      {required String productId,
      required String productSelectedServiceId}) async {
    final response = await DioClient.client.put("user/cart/remove", data: {
      "productId": productId,
      "productSelectedServiceId": productSelectedServiceId
    });
    if (response.isSuccess) {
      return true;
    } else {
      throw response.data;
    }
  }

  /*-------------------  Booking History List Data Get ------------------- */
  static Future<BookingHistoryListModel> bookingHistory() async {
    final response =
        await DioClient.client.get("user/booking/history-booking/list");
    if (response.isSuccess) {
      return BookingHistoryListModel.fromJson(response.data);
    } else {
      throw response.data;
    }
  }

  /*---------------------- Allow PortFolio Upload ------------------------*/
  static Future<bool> portFolioUpload(
      {required String appointmentId, required bool isUpload}) async {
    final response = await DioClient.client.put(
        "user/booking/appointments/$appointmentId/allow-portfolio-upload",
        data: {"allowPortfolioUpload": isUpload});
    if (response.isSuccess) {
      return true;
    } else {
      throw response.data;
    }
  }

  /*------------------------ Review List Data API  --------------------*/
  static Future<ReviewListModel> reviewListDataGet(
      {required String appointmentId}) async {
    final response =
        await DioClient.client.get("user/booking/$appointmentId/review");
    if (response.isSuccess) {
      return ReviewListModel.fromJson(response.data);
    } else {
      throw response.data;
    }
  }

  /*----------------- Appointment Service Review ------------------ */
  static Future<bool> addAppointmentServiceReview(
      {required String appointmentId,
      required double rate,
      required String salonServiceId,
      required String review}) async {
    final response = await DioClient.client
        .put("user/booking/$appointmentId/review", data: {
      "rating": rate,
      "salonServiceId": salonServiceId,
      "review": review
    });
    if (response.isSuccess) {
      return true;
    } else {
      throw response.data;
    }
  }

/*----------------- Appointment product Review ------------------ */
  static Future<bool> addAppointmentProductReview(
      {required String appointmentId,
      required double rate,
      required String salonProductId,
      required String review}) async {
    final response = await DioClient.client
        .put("user/booking/$appointmentId/review", data: {
      "rating": rate,
      "salonProductId": salonProductId,
      "review": review
    });
    if (response.isSuccess) {
      return true;
    } else {
      throw response.data;
    }
  }

/*----------------- Appointment Artiest Review ------------------ */
  static Future<bool> addAppointmentArtiestReview(
      {required String appointmentId,
      required double rate,
      required String salonArtistId,
      required String review}) async {
    final response = await DioClient.client
        .put("user/booking/$appointmentId/review", data: {
      "rating": rate,
      "salonArtistId": salonArtistId,
      "review": review
    });
    if (response.isSuccess) {
      return true;
    } else {
      throw response.data;
    }
  }

  /*------------- Get ArtiestPortfolio ----------------------------*/
  static Future<ArtiestPortfolio> getArtiestPortfolio(
      {required String artistId}) async {
    final response =
        await DioClient.client.get("user/salon/artist/$artistId/portfolio");

    if (response.isSuccess) {
      return ArtiestPortfolio.fromJson(response.data);
    } else {
      throw response.data;
    }
  }

  /*------------------  Get Blog Data ---------------*/
  static Future<BlogDataModel> getBlogData(
      {required double lat, required double lng}) async {
    final response = await DioClient.client.get("user/blog/list",
        queryParameters: {"lat": lat, "lng": lng, "distanceRadius": 100000000});
    if (response.isSuccess) {
      return BlogDataModel.fromJson(response.data);
    } else {
      throw response.data;
    }
  }

  /*-----------------  Get Fav BlogData ------------*/
  static Future<BlogDataModel> getFavBlogData() async {
    final response = await DioClient.client.get("user/blog/save");
    if (response.isSuccess) {
      return BlogDataModel.fromJson(response.data);
    } else {
      throw response.data;
    }
  }

  /*----------------  Add Fav Blog ----------------*/
  static Future<bool> addFavBlog(String blogId) async {
    final response = await DioClient.client
        .put("user/blog/save/add", data: {"blogId": blogId});
    if (response.isSuccess) {
      return true;
    } else {
      return response.data;
    }
  }

  /*----------------- Remove Blog ---------------------*/
  static Future<bool> removeBlog(String blogId) async {
    final response = await DioClient.client
        .delete("/user/blog/save/remove", data: {"blogId": blogId});
    if (response.isSuccess) {
      return true;
    } else {
      return response.data;
    }
  }

  /*------------------- Review & Rating ------------------*/
  static Future<ReviewRatingUserModel> getReviewRating() async {
    final response = await DioClient.client.get("user/review/list");
    if (response.isSuccess) {
      return ReviewRatingUserModel.fromJson(response.data);
    } else {
      throw response.data;
    }
  }

  /*--------------------- Search -------------------------- */
  static Future<SearchSalonModel> searchForSalon(
      {required String query, required String lat, required String lng}) async {
    if(query.isEmpty){
      return SearchSalonModel();}
    final response = await DioClient.client.get("user/home/search",
        queryParameters: {
          "q": query,
          "lat": lat,
          "lng": lng,
          "limit": 10,
          "distanceRadius": 50000
        });
    if (response.isSuccess) {
      return SearchSalonModel.fromJson(response.data);
    } else {
      throw response.data;
    }
  }

  /*------------------ Save Address For User ---------------------------- */
  static Future<bool> saveAddressUser({
    required String geolocationLat,
    required String geolocationLng,
    required String address,
    required String directions,
    required String house,
  }) async {
    final response = await DioClient.client.post("user/address/create", data: {
      "geolocationLat": geolocationLat,
      "geolocationLng": geolocationLng,
      "address": address,
      "addressLabel": "Home",
      "directions": directions,
      "house": house
    });
    if (response.isSuccess) {
      return true;
    } else {
      throw response.data;
    }
  }

  /*----------------- Save  Edit  Address For user ------------*/
  static Future<bool> saveEditAddressUser({
    required String geolocationLat,
    required String geolocationLng,
    required String address,
    required String addressID,
    required String directions,
    required String house,
  }) async {
    final response =
        await DioClient.client.patch("user/address/$addressID/update", data: {
      "geolocationLat": geolocationLat,
      "geolocationLng": geolocationLng,
      "address": address,
      "addressLabel": "Home",
      "directions": directions,
      "house": house
    });
    if (response.isSuccess) {
      return true;
    } else {
      throw response.data;
    }
  }

  /*----------------  Get Save Address ------------------*/
  static Future<SaveAddressModel> getSaveAddressUser() async {
    final response = await DioClient.client.get("user/address/list");
    if (response.isSuccess) {
      return SaveAddressModel.fromJson(response.data);
    } else {
      throw response.data;
    }
  }

  /*----------------  Artiest  Search -------------*/
  static Future<ArtistSearchModel> searchArtiest(
      {required String salonId, required String q}) async {
    final response = await DioClient.client
        .get("user/salon/$salonId/artist/search", queryParameters: {
      "q": q,
    });
    if (response.isSuccess) {
      return ArtistSearchModel.fromJson(response.data);
    } else {
      throw response.data;
    }
  }

  /*-------------- get  Order Id  -----------*/
  static Future<OrderIdModel> orderIdGet() async {
    final response = await DioClient.client.get("user/cart/razorpay/orderId");
    if (response.isSuccess) {
      return OrderIdModel.fromJson(response.data);
    } else {
      throw response.data;
    }
  }

  /*----------------------------- Delete Save Address ---------------- */
  static Future<bool> deleteSaveAddressUser({required String id}) async {
    final response = await DioClient.client.delete("user/address/$id/delete");
    if (response.isSuccess) {
      return true;
    } else {
      throw response.data;
    }
  }

  /*------------------------ Popular Service By Your Stylist  ----------------------*/

  static Future<ArtistPopularServicesModel> getPopularServiceByYourStylist(
      String artistId) async {
    final response = await DioClient.client
        .get("user/cart/artist/$artistId/popular-services");
    if (response.isSuccess) {
      return ArtistPopularServicesModel.fromJson(response.data);
    } else {
      throw response.data;
    }
  }

  /*------------------  Blog View Count ----------------------*/
  static Future<bool> addBlogView(String blogId) async {
    final response =
        await DioClient.client.get("user/blog/$blogId/increase-view");
    if (response.isSuccess) {
      return true;
    } else {
      throw response.data;
    }
  }

  /*-------------------  SalonId Reviews  --------------------*/
  static Future<SalonIdReviewsModel> salonIdToReview(
      {required String salonId}) async {
    final response = await DioClient.client.get("user/salon/$salonId/reviews");
    if (response.isSuccess) {
      return SalonIdReviewsModel.fromJson(response.data);
    } else {
      throw response.data;
    }
  }

  /*--------------------------  Get PromoCode ----------------------------*/
  static Future<PromoCodeModel> getPromoCode(
      {required double lat,
      required double lng,
      required String orderBy,
      required String serviceGender,
      required bool nearest,
      required bool fourPlusRating,
      required bool homeService}) async {
    final response =
        await DioClient.client.get("user/home/discount-list", queryParameters: {
      'lat': lat,
      'lng': lng,
      "distanceRadius": 50000,
      "homeService": homeService,
      "orderDirection": orderBy == "name" ? "ASC" : "DESC",
      "nearest": nearest,
      "fourPlusRating": fourPlusRating,
      "serviceGender": serviceGender,
    });
    if (response.isSuccess) {
      return PromoCodeModel.fromJson(response.data);
    } else {
      throw response.data;
    }
  }

  /*----------------------- Get PromoCode  For ------------------------ */
  static Future<PromoCodeModel> getPromoCodeList() async {
    final response =
        await DioClient.client.get("user/cart/discounts-by-user-cart");
    if (response.isSuccess) {
      return PromoCodeModel.fromJson(response.data);
    } else {
      throw response.data;
    }
  }

  /*----------------------- Apply  PromoCode --------------------*/
  static Future<bool> applyPromoCode({required Map data}) async {
    final response =
        await DioClient.client.put("user/cart/apply-discount", data: data);
    if (response.isSuccess) {
      return true;
    } else {
      throw response.data;
    }
  }

  /*---------------- Remove PromoCode --------------------*/
  static Future<bool> promoCodeRemove() async {
    final response = await DioClient.client.delete("user/cart/remove-discount");
    if (response.isSuccess) {
      return true;
    } else {
      throw response.data;
    }
  }

  /*----------------------  Delete Package ---------------------*/
  static Future<bool> deletePackage() async {
    final response =
        await DioClient.client.delete("user/home/make-your-own-package");
    if (response.isSuccess) {
      return true;
    } else {
      throw response.data;
    }
  }

  static Future<bool> approveBooking({
    required String bookingId,
    required String artistId,
    required String status,
  }) async {
    final response = await DioClient.client.put(
      "user/booking/$bookingId/status",
      data: {
        "salonArtistId": artistId,
        "status": status,
      },
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      return true;
    } else {
      throw Exception(response.data['message'] ?? 'Failed to cancel booking');
    }
  }

  static Future<bool> reScheduleBooking({
    required String appointmentId,
    required String newTime
  }) async {
    final response = await DioClient.client.put(
      "user/booking/$appointmentId/reSchedule",
      data: {
        "newDateTime": newTime
      },
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      return true;
    } else {
      throw Exception(response.data['message'] ?? 'Failed to re schedule booking');
    }
  }
}
