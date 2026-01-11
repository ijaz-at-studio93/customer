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
  double? orderAmount;
  String? bookingId;
  String? idx;
  String? finalizedAt;
  String? appointmentId;
  String? orderStatus;
  String? paymentStatus;
  AppliedDiscount? appliedDiscount;
  String? completionToken;
  bool? isHomeService;
  bool? allowPortfolioUpload;
  String? startsAt;
  String? endsAt;
  Address? address;

  Salon? salon;
  Appointment? appointment;
  List<Items>? items;

  Data(
      {this.orderAmount,
      this.bookingId,
      this.idx,
      this.finalizedAt,
      this.appointmentId,
      this.orderStatus,
        this.paymentStatus,
        this.appliedDiscount,
      this.completionToken,
      this.isHomeService,
      this.allowPortfolioUpload,
      this.startsAt,
      this.endsAt,
      this.address,
      this.salon,
      this.appointment,
      this.items});

  Data.fromJson(Map<String, dynamic> json) {
    orderAmount = double.parse(json['orderAmount'].toString());
    bookingId = json['bookingId'];
    idx = json['idx'];
    finalizedAt = json['finalizedAt'];
    appointmentId = json['appointmentId'];
    orderStatus = json['orderStatus'];
    paymentStatus = json['paymentStatus'];
    final discountJson = json['discountDetails'];

    if (discountJson is Map<String, dynamic>) {
      discountJson.forEach((key, value) {
        if (value is Map<String, dynamic> &&
            value.containsKey('discountAmount')) {
          appliedDiscount = AppliedDiscount.fromJson(value);
        }
      });
    }
    completionToken = json['completionToken'];
    isHomeService = json['isHomeService'];
    allowPortfolioUpload = json['allowPortfolioUpload'];
    startsAt = json['startsAt'];
    endsAt = json['endsAt'];
    address =
        json['address'] != null ? Address.fromJson(json['address']) : null;

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
    data['paymentStatus'] = paymentStatus;
    if (appliedDiscount != null) {
      data['appliedDiscount'] = appliedDiscount!.toJson();
    }
    data['completionToken'] = completionToken;
    data['isHomeService'] = isHomeService;
    data['allowPortfolioUpload'] = allowPortfolioUpload;
    data['startsAt'] = startsAt;
    data['endsAt'] = endsAt;
    if (address != null) {
      data['address'] = address!.toJson();
    }

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

class AppliedDiscount {
  String? discountType;
  double? discountAmount;

  AppliedDiscount.fromJson(Map<String, dynamic> json) {
    discountType = json['discountType'];
    discountAmount = double.tryParse(json['discountAmount'].toString());
  }

  Map<String, dynamic> toJson() {
    return {
      'discountType': discountType,
      'discountAmount': discountAmount,
    };
  }
}


class Address {
  String? id;
  String? bookingOrderId;
  String? address;
  GeoLocationPoint? geoLocationPoint;
  String? addressLabel;
  String? addressType;
  String? description;
  String? house;

  Address(
      {this.id,
      this.bookingOrderId,
      this.address,
      this.geoLocationPoint,
      this.addressLabel,
      this.addressType,
      this.description,
      this.house});

  Address.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    bookingOrderId = json['bookingOrderId'];
    address = json['address'];
    geoLocationPoint = json['geoLocationPoint'] != null
        ? GeoLocationPoint.fromJson(json['geoLocationPoint'])
        : null;
    addressLabel = json['addressLabel'];
    addressType = json['addressType'];
    description = json['description'];
    house = json['house'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['bookingOrderId'] = bookingOrderId;
    data['address'] = address;
    if (geoLocationPoint != null) {
      data['geoLocationPoint'] = geoLocationPoint!.toJson();
    }
    data['addressLabel'] = addressLabel;
    data['addressType'] = addressType;
    data['description'] = description;
    data['house'] = house;
    return data;
  }
}

class GeoLocationPoint {
  Crs? crs;
  String? type;
  List<double>? coordinates;

  GeoLocationPoint({this.crs, this.type, this.coordinates});

  GeoLocationPoint.fromJson(Map<String, dynamic> json) {
    crs = json['crs'] != null ? Crs.fromJson(json['crs']) : null;
    type = json['type'];
    coordinates = json['coordinates'].cast<double>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (crs != null) {
      data['crs'] = crs!.toJson();
    }
    data['type'] = type;
    data['coordinates'] = coordinates;
    return data;
  }
}

class Crs {
  String? type;
  Properties? properties;

  Crs({this.type, this.properties});

  Crs.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    properties = json['properties'] != null
        ? Properties.fromJson(json['properties'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    if (properties != null) {
      data['properties'] = properties!.toJson();
    }
    return data;
  }
}

class Properties {
  String? name;

  Properties({this.name});

  Properties.fromJson(Map<String, dynamic> json) {
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
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

class Appointment {
  String? id;
  Artist? artist;

  Appointment({this.id, this.artist});

  Appointment.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    artist = json['artist'] != null ? Artist.fromJson(json['artist']) : null;
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

class Artist {
  String? id;
  String? name;
  String? profileImage;

  Artist({this.id, this.name, this.profileImage});

  Artist.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    profileImage = json['profileImage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['profileImage'] = profileImage;
    return data;
  }
}

class Items {
  String? id;
  bool? isService;
  Service? service;

  Items({this.id, this.isService, this.service});

  Items.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    isService = json['isService'];
    service =
        json['service'] != null ? Service.fromJson(json['service']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['isService'] = isService;
    if (service != null) {
      data['service'] = service!.toJson();
    }
    return data;
  }
}

class Service {
  int? price;
  String? id;
  String? name;
  int? duration;
  String? image;

  Service({
    this.price,
    this.id,
    this.name,
    this.duration,
    this.image,
  });

  Service.fromJson(Map<String, dynamic> json) {
    price = json['price'];
    id = json['id'];
    name = json['name'];
    duration = json['duration'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['price'] = price;
    data['id'] = id;
    data['name'] = name;
    data['duration'] = duration;
    data['image'] = image;

    return data;
  }
}

/*
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
  int? orderAmount;
  String? bookingId;
  String? finalizedAt;
  String? appointmentId;
  String? orderStatus;
  String? completionToken;
  String? startsAt;
  String? endsAt;
  Salon? salon;
  List<Items>? items;

  Data(
      {this.orderAmount,
        this.bookingId,
        this.finalizedAt,
        this.appointmentId,
        this.orderStatus,
        this.completionToken,
        this.startsAt,
        this.endsAt,
        this.salon,
        this.items});

  Data.fromJson(Map<String, dynamic> json) {
    orderAmount = json['orderAmount'];
    bookingId = json['bookingId'];
    finalizedAt = json['finalizedAt'];
    appointmentId = json['appointmentId'];
    orderStatus = json['orderStatus'];
    completionToken = json['completionToken'];
    startsAt = json['startsAt'];
    endsAt = json['endsAt'];
    salon = json['salon'] != null ? Salon.fromJson(json['salon']) : null;
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
    data['finalizedAt'] = finalizedAt;
    data['appointmentId'] = appointmentId;
    data['orderStatus'] = orderStatus;
    data['completionToken'] = completionToken;
    data['startsAt'] = startsAt;
    data['endsAt'] = endsAt;
    if (salon != null) {
      data['salon'] = salon!.toJson();
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

class Items {
  String? id;
  bool? isService;
  Service? service;
  Product? product;

  Items({this.id, this.isService, this.service, this.product});

  Items.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    isService = json['isService'];
    service =
    json['service'] != null ? Service.fromJson(json['service']) : null;
    product =
    json['product'] != null ? Product.fromJson(json['product']) : null;
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
  int? price;
  String? id;
  String? name;
  int? duration;
  String? image;
  List<Categories>? categories;

  Service(
      {this.price,
        this.id,
        this.name,
        this.duration,
        this.image,
        this.categories});

  Service.fromJson(Map<String, dynamic> json) {
    price = json['price'];
    id = json['id'];
    name = json['name'];
    duration = json['duration'];
    image = json['image'];
    if (json['categories'] != null) {
      categories = <Categories>[];
      json['categories'].forEach((v) {
        categories!.add(Categories.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['price'] = price;
    data['id'] = id;
    data['name'] = name;
    data['duration'] = duration;
    data['image'] = image;
    if (categories != null) {
      data['categories'] = categories!.map((v) => v.toJson()).toList();
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

class Product {
  int? price;
  String? id;
  String? name;

  Product({this.price, this.id, this.name});

  Product.fromJson(Map<String, dynamic> json) {
    price = json['price'];
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



class Address {
  String? id;
  String? bookingOrderId;
  String? address;
  GeoLocationPoint? geoLocationPoint;
  String? addressLabel;
  String? addressType;
  String? description;
  String? house;

  Address(
      {this.id,
        this.bookingOrderId,
        this.address,
        this.geoLocationPoint,
        this.addressLabel,
        this.addressType,
        this.description,
        this.house});

  Address.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    bookingOrderId = json['bookingOrderId'];
    address = json['address'];
    geoLocationPoint = json['geoLocationPoint'] != null
        ? GeoLocationPoint.fromJson(json['geoLocationPoint'])
        : null;
    addressLabel = json['addressLabel'];
    addressType = json['addressType'];
    description = json['description'];
    house = json['house'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['bookingOrderId'] = bookingOrderId;
    data['address'] = address;
    if (geoLocationPoint != null) {
      data['geoLocationPoint'] = geoLocationPoint!.toJson();
    }
    data['addressLabel'] = addressLabel;
    data['addressType'] = addressType;
    data['description'] = description;
    data['house'] = house;
    return data;
  }
}


class GeoLocationPoint {
  Crs? crs;
  String? type;
  List<double>? coordinates;

  GeoLocationPoint({this.crs, this.type, this.coordinates});

  GeoLocationPoint.fromJson(Map<String, dynamic> json) {
    crs = json['crs'] != null ? Crs.fromJson(json['crs']) : null;
    type = json['type'];
    coordinates = json['coordinates'].cast<double>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (crs != null) {
      data['crs'] = crs!.toJson();
    }
    data['type'] = type;
    data['coordinates'] = coordinates;
    return data;
  }
}

class Crs {
  String? type;
  Properties? properties;

  Crs({this.type, this.properties});

  Crs.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    properties = json['properties'] != null
        ? Properties.fromJson(json['properties'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    if (properties != null) {
      data['properties'] = properties!.toJson();
    }
    return data;
  }
}

class Properties {
  String? name;

  Properties({this.name});

  Properties.fromJson(Map<String, dynamic> json) {
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    return data;
  }
}


*/
