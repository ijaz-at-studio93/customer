class SaveAddressModel {
  int? statusCode;
  bool? success;
  List<SaveAddressList>? data;
  String? message;

  SaveAddressModel({this.statusCode, this.success, this.data, this.message});

  SaveAddressModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    success = json['success'];
    if (json['data'] != null) {
      data = <SaveAddressList>[];
      json['data'].forEach((v) {
        data!.add(SaveAddressList.fromJson(v));
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

class SaveAddressList {
  String? id;
  String? createdAt;
  String? updatedAt;
  String? deletedAt;
  String? userId;
  String? address;
  GeoLocationPoint? geoLocationPoint;
  String? addressLabel;
  String? addressType;
  String? directions;
  String? house;

  SaveAddressList(
      {this.id,
        this.createdAt,
        this.updatedAt,
        this.deletedAt,
        this.userId,
        this.address,
        this.geoLocationPoint,
        this.addressLabel,
        this.addressType,
        this.directions,
        this.house});

  SaveAddressList.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    deletedAt = json['deletedAt'];
    userId = json['userId'];
    address = json['address'];
    geoLocationPoint = json['geoLocationPoint'] != null
        ? GeoLocationPoint.fromJson(json['geoLocationPoint'])
        : null;
    addressLabel = json['addressLabel'];
    addressType = json['addressType'];
    directions = json['directions'];
    house = json['house'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['deletedAt'] = deletedAt;
    data['userId'] = userId;
    data['address'] = address;
    if (geoLocationPoint != null) {
      data['geoLocationPoint'] = geoLocationPoint!.toJson();
    }
    data['addressLabel'] = addressLabel;
    data['addressType'] = addressType;
    data['directions'] = directions;
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