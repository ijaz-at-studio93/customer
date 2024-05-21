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
  String? id;
  String? startsAt;
  String? endsAt;
  String? status;
  String? salonId;
  String? finalizedAt;
  String? salonServiceId;
  String? salonArtistId;
  String? completionToken;

  Data(
      {this.id,
      this.startsAt,
      this.endsAt,
      this.status,
      this.salonId,
      this.finalizedAt,
      this.salonServiceId,
      this.salonArtistId,
      this.completionToken});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    startsAt = json['startsAt'];
    endsAt = json['endsAt'];
    status = json['status'];
    salonId = json['salonId'];
    finalizedAt = json['finalizedAt'];
    salonServiceId = json['salonServiceId'];
    salonArtistId = json['salonArtistId'];
    completionToken = json['completionToken'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['startsAt'] = startsAt;
    data['endsAt'] = endsAt;
    data['status'] = status;
    data['salonId'] = salonId;
    data['finalizedAt'] = finalizedAt;
    data['salonServiceId'] = salonServiceId;
    data['salonArtistId'] = salonArtistId;
    data['completionToken'] = completionToken;
    return data;
  }
}
