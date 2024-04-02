import 'dio_client.dart';

class AuthAPI {

/*--------------------- Login --------------------- */
/*============ STORE MAP  DATA =========*/
/*  static Future<ModelName> doLogin(parameter) async {

    final response = await DioClient.client.post(
      '/api/login',
      data: {
        'email': email,
        'password': password,
        'push_token' :  pushToken
      },
    );
    if (response.isSuccess && response.data['success'] == true) {
      return UserResponseModel.fromJson(response.data['data']);
    } else {
      throw response.data;
    }
  }*/

/*============ STORE LIST DATA =========*/
/*  static Future<List<ModelName>> getCategoryListAPI() async {
    final response = await DioClient.client.get(
      '/api/get_categories_list',
    );

    if (response.isSuccess) {
      return response.data['data']
          .map<ModelName>((e) => ModelName.fromJson(e))
          .toList();
    } else {
      throw response.data;
    }
  }*/

}