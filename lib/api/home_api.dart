import 'package:sallon_customer/api/dio_client.dart';
import 'package:sallon_customer/model/artiest_list_model.dart';
import 'package:sallon_customer/model/availabilities_time_sloat_model.dart';
import 'package:sallon_customer/model/category_service_list_model.dart';
import 'package:sallon_customer/model/create_booking_appoiment_model.dart';
import 'package:sallon_customer/model/home_category_list_model.dart';
import 'package:sallon_customer/model/home_salon_list_model.dart';
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
  static Future<List<HomeSalonModel>> getSalonHome(
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
      return response.data['data']['rows']
          .map<HomeSalonModel>((e) => HomeSalonModel.fromJson(e))
          .toList();
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
  static Future<ArtistListModel> getArtiest({required String serviceId}) async {
    final response =
        await DioClient.client.get("user/salon/service/$serviceId/artist");
    if (response.isSuccess) {
      return ArtistListModel.fromJson(response.data);
    } else {
      throw response.data;
    }
  }

  /* --------------------------- Get UnAvailableDates --------------------------- */
  static Future<UnAvailableDatesModel> getUnAvailableDates(
      {required String salonId,
      required String serviceId,
      required String artiestId,
      required String date}) async {
    final response = await DioClient.client.get(
        "user/salon/$salonId/services/$serviceId/artist/$artiestId/unavailable-dates",
        queryParameters: {
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
      {required String salonId,
      required String serviceId,
      required String artiestId,
      required String date}) async {
    final response = await DioClient.client.get(
        "user/salon/$salonId/services/$serviceId/artist/$artiestId/availabilities",
        queryParameters: {
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
    required String salonId,
    required String serviceId,
    required String salonArtistId,
    required String startAt,
  }) async {
    final response = await DioClient.client.post("user/booking/create", data: {
      "salonId": salonId,
      "serviceId": serviceId,
      "salonArtistId": salonArtistId,
      "startAt": startAt
    });
    if (response.isSuccess) {
      return CreateBookingAppointmentModel.fromJson(response.data);
    } else {
      return response.data;
    }
  }

  /*---------------------Get Booking Qr Code Details ------------------*/
  static Future<UserBookingQrCodeModel> userBookingQrCodeDetails({
    required String appointmentId,
  }) async {
    final response =
        await DioClient.client.get("user/booking/appointments/$appointmentId");
    if (response.isSuccess) {
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
      return response.data;
    }
  }


}
