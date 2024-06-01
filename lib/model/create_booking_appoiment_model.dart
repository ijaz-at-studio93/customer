class CreateBookingAppointmentModel {
  int? statusCode;
  bool? success;
  Data? data;
  String? message;

  CreateBookingAppointmentModel(
      {this.statusCode, this.success, this.data, this.message});

  CreateBookingAppointmentModel.fromJson(Map<String, dynamic> json) {
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
  int? orderAmount;
  String? createdAt;
  String? updatedAt;
  String? id;
  String? deletedAt;
  String? completionToken;
  String? orderStatus;
  String? paymentStatus;
  String? salonAppointmentId;
  String? salonId;
  String? userId;
  String? finalizedAt;
  String? idx;

  Data(
      {this.orderAmount,
        this.createdAt,
        this.updatedAt,
        this.id,
        this.deletedAt,
        this.completionToken,
        this.orderStatus,
        this.paymentStatus,
        this.salonAppointmentId,
        this.salonId,
        this.userId,
        this.finalizedAt,
        this.idx});

  Data.fromJson(Map<String, dynamic> json) {
    orderAmount = json['orderAmount'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    id = json['id'];
    deletedAt = json['deletedAt'];
    completionToken = json['completionToken'];
    orderStatus = json['orderStatus'];
    paymentStatus = json['paymentStatus'];
    salonAppointmentId = json['salonAppointmentId'];
    salonId = json['salonId'];
    userId = json['userId'];
    finalizedAt = json['finalizedAt'];
    idx = json['idx'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['orderAmount'] = orderAmount;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['id'] = id;
    data['deletedAt'] = deletedAt;
    data['completionToken'] = completionToken;
    data['orderStatus'] = orderStatus;
    data['paymentStatus'] = paymentStatus;
    data['salonAppointmentId'] = salonAppointmentId;
    data['salonId'] = salonId;
    data['userId'] = userId;
    data['finalizedAt'] = finalizedAt;
    data['idx'] = idx;
    return data;
  }
}