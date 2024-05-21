class CurrentBookingListModel {
  int? statusCode;
  bool? success;
  List<BookingData>? data;
  String? message;

  CurrentBookingListModel(
      {this.statusCode, this.success, this.data, this.message});

  CurrentBookingListModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    success = json['success'];
    if (json['data'] != null) {
      data = <BookingData>[];
      json['data'].forEach((v) {
        data!.add(BookingData.fromJson(v));
      });
    }
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['statusCode'] = statusCode;
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['message'] = message;
    return data;
  }
}

class BookingData {
  String? appointmentId;
  String? startsAt;
  String? endsAt;
  String? status;
  String? finalizedAt;
  int? price;
  Service? service;
  Salon? salon;
  Salon? artist;

  BookingData(
      {this.appointmentId,
      this.startsAt,
      this.endsAt,
      this.status,
      this.finalizedAt,
      this.price,
      this.service,
      this.salon,
      this.artist});

  BookingData.fromJson(Map<String, dynamic> json) {
    appointmentId = json['appointmentId'];
    startsAt = json['startsAt'];
    endsAt = json['endsAt'];
    status = json['status'];
    finalizedAt = json['finalizedAt'];
    price = json['price'];
    service =
        json['service'] != null ? Service.fromJson(json['service']) : null;
    salon = json['salon'] != null ? Salon.fromJson(json['salon']) : null;
    artist = json['artist'] != null ? Salon.fromJson(json['artist']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['appointmentId'] = appointmentId;
    data['startsAt'] = startsAt;
    data['endsAt'] = endsAt;
    data['status'] = status;
    data['finalizedAt'] = finalizedAt;
    data['price'] = price;
    if (service != null) {
      data['service'] = service!.toJson();
    }
    if (salon != null) {
      data['salon'] = salon!.toJson();
    }
    if (artist != null) {
      data['artist'] = artist!.toJson();
    }
    return data;
  }
}

class Service {
  String? id;
  String? name;
  int? price;

  Service({this.id, this.name, this.price});

  Service.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    price = json['price'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['price'] = price;
    return data;
  }
}

class Salon {
  String? id;
  String? name;

  Salon({this.id, this.name});

  Salon.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}
