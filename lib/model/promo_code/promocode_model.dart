class PromoCodeModel {
  int? statusCode;
  bool? success;
  List<PromoCode>? data;
  String? message;

  PromoCodeModel({this.statusCode, this.success, this.data, this.message});

  PromoCodeModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    success = json['success'];
    if (json['data'] != null) {
      data = <PromoCode>[];
      json['data'].forEach((v) {
        data!.add(PromoCode.fromJson(v));
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

class PromoCode {
  int? amount;
  String? maxDiscount;
  String? minOrder;
  String? id;
  String? title;
  String? description;
  String? image;
  String? startsAt;
  String? endsAt;
  String? code;
  String? type;
  Salon? salon;

  PromoCode(
      {this.amount,
      this.maxDiscount,
      this.minOrder,
      this.id,
      this.title,
      this.description,
      this.image,
      this.startsAt,
      this.endsAt,
      this.code,
      this.type,
      this.salon});

  PromoCode.fromJson(Map<String, dynamic> json) {
    amount = json['amount'];
    maxDiscount = json['maxDiscount'].toString();
    minOrder = json['minOrder'].toString();
    id = json['id'];
    title = json['title'];
    description = json['description'];
    image = json['image'];
    startsAt = json['startsAt'];
    endsAt = json['endsAt'];
    code = json['code'];
    type = json['type'];
    salon = json['salon'] != null ? Salon.fromJson(json['salon']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['amount'] = amount;
    data['maxDiscount'] = maxDiscount;
    data['minOrder'] = minOrder;
    data['id'] = id;
    data['title'] = title;
    data['description'] = description;
    data['image'] = image;
    data['startsAt'] = startsAt;
    data['endsAt'] = endsAt;
    data['code'] = code;
    data['type'] = type;
    if (salon != null) {
      data['salon'] = salon!.toJson();
    }
    return data;
  }
}

class Salon {
  String? id;
  String? name;
  String? address;
  GeoLocationPoint? geoLocationPoint;
  int? distance;

  Salon(
      {this.id, this.name, this.address, this.geoLocationPoint, this.distance});

  Salon.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    address = json['address'];
    geoLocationPoint = json['geoLocationPoint'] != null
        ? GeoLocationPoint.fromJson(json['geoLocationPoint'])
        : null;
    distance = json['distance'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['address'] = address;
    if (geoLocationPoint != null) {
      data['geoLocationPoint'] = geoLocationPoint!.toJson();
    }
    data['distance'] = distance;
    return data;
  }
}

class GeoLocationPoint {
  String? type;
  List<double>? coordinates;

  GeoLocationPoint({this.type, this.coordinates});

  GeoLocationPoint.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    coordinates = json['coordinates'].cast<double>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['coordinates'] = coordinates;
    return data;
  }
}
