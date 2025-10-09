class BookingHistoryListModel {
  int? statusCode;
  bool? success;
  List<HistoryList>? data;
  String? message;

  BookingHistoryListModel(
      {this.statusCode, this.success, this.data, this.message});

  BookingHistoryListModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    success = json['success'];
    if (json['data'] != null) {
      data = <HistoryList>[];
      json['data'].forEach((v) {
        data!.add(HistoryList.fromJson(v));
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

class HistoryList {
  double? orderAmount;   // 🔧 changed to double
  String? bookingId;
  String? idx;
  String? finalizedAt;
  String? appointmentId;
  String? orderStatus;
  String? startsAt;
  String? endsAt;
  Salon? salon;
  Appointment? appointment;
  List<Items>? items;

  HistoryList(
      {this.orderAmount,
        this.bookingId,
        this.idx,
        this.finalizedAt,
        this.appointmentId,
        this.orderStatus,
        this.startsAt,
        this.endsAt,
        this.salon,
        this.appointment,
        this.items});

  HistoryList.fromJson(Map<String, dynamic> json) {
    orderAmount = (json['orderAmount'] as num?)?.toDouble();  // 🔧 safe cast
    bookingId = json['bookingId'];
    idx = json['idx'];
    finalizedAt = json['finalizedAt'];
    appointmentId = json['appointmentId'];
    orderStatus = json['orderStatus'];
    startsAt = json['startsAt'];
    endsAt = json['endsAt'];
    salon = json['salon'] != null ? Salon.fromJson(json['salon']) : null;
    appointment = json['appointment'] != null
        ? Appointment.fromJson(json['appointment'])
        : null;
    if (json['items'] != null) {
      items = <Items>[];
      json['items'].forEach((v) {
        items!.add(Items.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['orderAmount'] = orderAmount;
    data['bookingId'] = bookingId;
    data['idx'] = idx;
    data['finalizedAt'] = finalizedAt;
    data['appointmentId'] = appointmentId;
    data['orderStatus'] = orderStatus;
    data['startsAt'] = startsAt;
    data['endsAt'] = endsAt;
    if (salon != null) {
      data['salon'] = salon!.toJson();
    }
    if (appointment != null) {
      data['appointment'] = appointment!.toJson();
    }
    if (items != null) {
      data['items'] = items!.map((v) => v.toJson()).toList();
    }
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

class Appointment {
  String? id;
  Salon? artist;

  Appointment({this.id, this.artist});

  Appointment.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    artist = json['artist'] != null ? Salon.fromJson(json['artist']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    if (artist != null) {
      data['artist'] = artist!.toJson();
    }
    return data;
  }
}

class Items {
  String? id;
  bool? isService;
  Service? service;
  Service? product;

  Items({this.id, this.isService, this.service, this.product});

  Items.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    isService = json['isService'];
    service =
    json['service'] != null ? Service.fromJson(json['service']) : null;
    product =
    json['product'] != null ? Service.fromJson(json['product']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['isService'] = isService;
    if (service != null) {
      data['service'] = service!.toJson();
    }
    if (product != null) {
      data['product'] = product!.toJson();
    }
    return data;
  }
}

class Service {
  double? price;   // 🔧 changed to double
  String? id;
  String? name;

  Service({this.price, this.id, this.name});

  Service.fromJson(Map<String, dynamic> json) {
    price = (json['price'] as num?)?.toDouble();  // 🔧 safe cast
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['price'] = price;
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}
