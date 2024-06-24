class OrderIdModel {
  int? statusCode;
  bool? success;
  Data? data;
  String? message;

  OrderIdModel({this.statusCode, this.success, this.data, this.message});

  OrderIdModel.fromJson(Map<String, dynamic> json) {
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
  String? orderId;
  String? razorpayKey;

  Data({this.orderId, this.razorpayKey});

  Data.fromJson(Map<String, dynamic> json) {
    orderId = json['orderId'];
    razorpayKey = json['razorpayKey'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['orderId'] = orderId;
    data['razorpayKey'] = razorpayKey;
    return data;
  }
}
