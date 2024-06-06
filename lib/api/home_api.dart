import 'package:sallon_customer/api/dio_client.dart';
import 'package:sallon_customer/model/artiest_list_model.dart';
import 'package:sallon_customer/model/artiest_portfolio_model.dart';
import 'package:sallon_customer/model/availabilities_time_sloat_model.dart';
import 'package:sallon_customer/model/blog_data_model.dart';
import 'package:sallon_customer/model/booking_history_list_model.dart';
import 'package:sallon_customer/model/cart/service_add_cart_model.dart';
import 'package:sallon_customer/model/category_service_list_model.dart';
import 'package:sallon_customer/model/create_booking_appoiment_model.dart';
import 'package:sallon_customer/model/favourite_salon_list_data_model.dart';
import 'package:sallon_customer/model/home_category_list_model.dart';
import 'package:sallon_customer/model/home_salon_list_model.dart';
import 'package:sallon_customer/model/review_list_data_model.dart';
import 'package:sallon_customer/model/review_rating_data_model.dart';
import 'package:sallon_customer/model/salon_details_artiest.dart';
import 'package:sallon_customer/model/salon_details_model.dart';
import 'package:sallon_customer/model/un_available_dates_model.dart';
import 'package:sallon_customer/model/user_booking_qr_code_model.dart';
import '../model/current_booking_list_model.dart';

class HomeAPI {
  /*---------------------- home category ------------------*/ static Future<
      HomeCategoryListModel> homeCategoryList() async {
    final response = await DioClient.client.get("user/home/category/list");
    if (response.isSuccess) {
      return HomeCategoryListModel.fromJson(response.data);
    } else {
      throw response.data;
    }
  }

  /*-------------------  get Salon  Salon -----------------*/
  static Future<HomeSalonModel> getSalonHome(
      {required int offset,
      required int size,
      required double lat,
      required double lng}) async {
    final response = await DioClient.client.get(
      '/user/home/salon/list',
      queryParameters: {
        'page': offset,
        'limit': size,
        "lat": lat == 0.0 ? 22.303894 : lat,
        "lng": lng == 0.0 ? 22.303894 : lng,
        "distanceRadius": 10000000
      },
    );
    if (response.isSuccess) {
      return HomeSalonModel.fromJson(response.data);
    } else {
      throw response.data;
    }
  }

  /*---------------------- Salon Detail --------------------*/
  static Future<HomeSalonDetailsModel> getSalonDetail(
      {required String salonId}) async {
    final response = await DioClient.client.get("user/salon/$salonId/details");
    if (response.isSuccess) {
      return HomeSalonDetailsModel.fromJson(response.data);
    } else {
      throw response.data;
    }
  }

  /*---------------- Salon  Details Category service  List ----------------*/
  static Future<CategoryServicesListModel> getSalonDetailsCategoryServiceList(
      {required String salonId}) async {
    final response =
        await DioClient.client.get("user/salon/$salonId/category/services");
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
  }) async {
    final response = await DioClient.client.post("user/booking/create",
        data: {"salonArtistId": salonArtistId, "startAt": startAt});
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

  /*------------------------------------ Current Booking List Model ----------------*/
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
  static Future<ServiceAddCartModel> serviceAddCart(
      {required String salonServiceId}) async {
    final response = await DioClient.client
        .put("user/cart/add", data: {"salonServiceId": salonServiceId});
    if (response.isSuccess) {
      return ServiceAddCartModel.fromJson(response.data);
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
      {required String productId}) async {
    final response = await DioClient.client
        .put("user/cart/add", data: {"productId": productId});
    if (response.isSuccess) {
      return ServiceAddCartModel.fromJson(response.data);
    } else {
      throw response.data;
    }
  }

  /*------------------  Remove  Cart Product ---------------------*/
  static Future<bool> removeProductCart({required String productId}) async {
    final response = await DioClient.client
        .put("user/cart/remove", data: {"productId": productId});
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
  static Future<BlogDataModel> getBlogData() async {
    final response = await DioClient.client.get("user/blog/list");
    if (response.isSuccess) {
      return BlogDataModel.fromJson(response.data);
    } else {
      throw response.data;
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
}
