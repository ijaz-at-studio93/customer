class UserProfile {
  int? statusCode;
  bool? success;
  Data? data;
  String? message;

  UserProfile({this.statusCode, this.success, this.data, this.message});

  UserProfile.fromJson(Map<String, dynamic> json) {
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
  String? userId;
  String? id;
  String? name;
  String? email;
  String? dob;
  String? countryCode;
  String? mobile;
  String? profileImage;
  int? status;
  String? gender;

  Data(
      {this.userId,
      this.id,
      this.name,
      this.email,
      this.dob,
      this.countryCode,
      this.mobile,
      this.profileImage,
      this.status,
      this.gender});

  Data.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    id = json['id'];
    name = json['name'];
    email = json['email'];
    dob = json['dob'];
    countryCode = json['countryCode'];
    mobile = json['mobile'];
    profileImage = json['profileImage'];
    status = json['status'];
    gender = json['gender'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userId'] = userId;
    data['id'] = id;
    data['name'] = name;
    data['email'] = email;
    data['dob'] = dob;
    data['countryCode'] = countryCode;
    data['mobile'] = mobile;
    data['profileImage'] = profileImage;
    data['status'] = status;
    data['gender'] = gender;
    return data;
  }
}
