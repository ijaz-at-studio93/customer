class OtpVerifyModel {
  int? statusCode;
  bool? success;
  Data? data;
  String? message;

  OtpVerifyModel({this.statusCode, this.success, this.data, this.message});

  OtpVerifyModel.fromJson(Map<String, dynamic> json) {
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
  bool? isRegistered;
  bool? isVerificationCodeValid;

  Data({this.isRegistered, this.isVerificationCodeValid});

  Data.fromJson(Map<String, dynamic> json) {
    isRegistered = json['isRegistered'];
    isVerificationCodeValid = json['isVerificationCodeValid'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['isRegistered'] = isRegistered;
    data['isVerificationCodeValid'] = isVerificationCodeValid;
    return data;
  }
}
