class UserResponseModel {
  int? statusCode;
  bool? success;
  Data? data;
  String? message;

  UserResponseModel({this.statusCode, this.success, this.data, this.message});

  UserResponseModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    success = json['success'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['statusCode'] = statusCode;
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['message'] = message;
    return data;
  }
}

class Data {
  String? id;
  String? accessToken;
  String? accessTokenValidTill;
  String? refreshToken;
  String? refreshTokenValidTill;
  UserData? userData;

  Data(
      {this.id,
      this.accessToken,
      this.accessTokenValidTill,
      this.refreshToken,
      this.refreshTokenValidTill,
      this.userData});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    accessToken = json['accessToken'];
    accessTokenValidTill = json['accessTokenValidTill'];
    refreshToken = json['refreshToken'];
    refreshTokenValidTill = json['refreshTokenValidTill'];
    userData =
        json['userData'] != null ? UserData.fromJson(json['userData']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['accessToken'] = accessToken;
    data['accessTokenValidTill'] = accessTokenValidTill;
    data['refreshToken'] = refreshToken;
    data['refreshTokenValidTill'] = refreshTokenValidTill;
    if (userData != null) {
      data['userData'] = userData!.toJson();
    }
    return data;
  }
}

class UserData {
  String? userId;
  String? name;
  String? email;
  String? dob;
  String? countryCode;
  String? mobile;
  String? profileImage;
  int? status;

  UserData(
      {this.userId,
      this.name,
      this.email,
      this.dob,
      this.countryCode,
      this.mobile,
      this.profileImage,
      this.status});

  UserData.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    name = json['name'];
    email = json['email'];
    dob = json['dob'];
    countryCode = json['countryCode'];
    mobile = json['mobile'];
    profileImage = json['profileImage'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userId'] = userId;
    data['name'] = name;
    data['email'] = email;
    data['dob'] = dob;
    data['countryCode'] = countryCode;
    data['mobile'] = mobile;
    data['profileImage'] = profileImage;
    data['status'] = status;
    return data;
  }
}
