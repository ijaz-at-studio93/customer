import 'package:sallon_customer/api/dio_client.dart';
import 'package:sallon_customer/model/category_service_list_model.dart';
import 'package:sallon_customer/model/home_category_list_model.dart';
import 'package:sallon_customer/model/home_salon_list_model.dart';
import 'package:sallon_customer/model/salon_details_artiest.dart';
import 'package:sallon_customer/model/salon_details_model.dart';


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
        'limit': 100,
        "lat": lat,
        "lng": lng,
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
}
