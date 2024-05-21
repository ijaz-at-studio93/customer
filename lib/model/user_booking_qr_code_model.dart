class UserBookingQrCodeModel {
  int? statusCode;
  bool? success;
  Data? data;
  String? message;

  UserBookingQrCodeModel(
      {this.statusCode, this.success, this.data, this.message});

  UserBookingQrCodeModel.fromJson(Map<String, dynamic> json) {
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
  String? appointmentId;
  String? completionToken;
  String? startsAt;
  String? endsAt;
  String? status;
  String? finalizedAt;
  String? salonServiceId;
  Service? service;
  Artist? artist;
  Salon? salon;

  Data(
      {this.appointmentId,
      this.completionToken,
      this.startsAt,
      this.endsAt,
      this.status,
      this.finalizedAt,
      this.salonServiceId,
      this.service,
      this.artist,
      this.salon});

  Data.fromJson(Map<String, dynamic> json) {
    appointmentId = json['appointmentId'];
    completionToken = json['completionToken'];
    startsAt = json['startsAt'];
    endsAt = json['endsAt'];
    status = json['status'];
    finalizedAt = json['finalizedAt'];
    salonServiceId = json['salonServiceId'];
    service =
        json['service'] != null ? Service.fromJson(json['service']) : null;
    artist = json['artist'] != null ? Artist.fromJson(json['artist']) : null;
    salon = json['salon'] != null ? Salon.fromJson(json['salon']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['appointmentId'] = appointmentId;
    data['completionToken'] = completionToken;
    data['startsAt'] = startsAt;
    data['endsAt'] = endsAt;
    data['status'] = status;
    data['finalizedAt'] = finalizedAt;
    data['salonServiceId'] = salonServiceId;
    if (service != null) {
      data['service'] = service!.toJson();
    }
    if (artist != null) {
      data['artist'] = artist!.toJson();
    }
    if (salon != null) {
      data['salon'] = salon!.toJson();
    }
    return data;
  }
}

class Service {
  String? id;
  String? name;
  int? price;
  int? duration;
  String? image;
  List<Categories>? categories;
  List<Products>? products;

  Service(
      {this.id,
      this.name,
      this.price,
      this.duration,
      this.image,
      this.categories,
      this.products});

  Service.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    price = json['price'];
    duration = json['duration'];
    image = json['image'];
    if (json['categories'] != null) {
      categories = <Categories>[];
      json['categories'].forEach((v) {
        categories!.add(Categories.fromJson(v));
      });
    }
    if (json['products'] != null) {
      products = <Products>[];
      json['products'].forEach((v) {
        products!.add(Products.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['price'] = price;
    data['duration'] = duration;
    data['image'] = image;
    if (categories != null) {
      data['categories'] = categories!.map((v) => v.toJson()).toList();
    }
    if (products != null) {
      data['products'] = products!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Categories {
  String? name;

  Categories({this.name});

  Categories.fromJson(Map<String, dynamic> json) {
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    return data;
  }
}

class Artist {
  String? id;
  String? name;

  Artist({this.id, this.name});

  Artist.fromJson(Map<String, dynamic> json) {
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

class Products {
  String? name;
  int? price;
  String? image;

  Products({this.name, this.price, this.image});

  Products.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    price = json['price'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['price'] = price;
    data['image'] = image;
    return data;
  }
}

class Salon {
  String? id;
  String? name;
  String? address;
  String? countryCode;
  String? mobile;
  String? email;
  String? image;

  Salon(
      {this.id,
      this.name,
      this.address,
      this.countryCode,
      this.mobile,
      this.email,
      this.image});

  Salon.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    address = json['address'];
    countryCode = json['countryCode'];
    mobile = json['mobile'];
    email = json['email'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['address'] = address;
    data['countryCode'] = countryCode;
    data['mobile'] = mobile;
    data['email'] = email;
    data['image'] = image;
    return data;
  }
}
