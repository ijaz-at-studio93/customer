class HomeSalonDetailsModel {
  int? statusCode;
  bool? success;
  Data? data;
  String? message;

  HomeSalonDetailsModel(
      {this.statusCode, this.success, this.data, this.message});

  HomeSalonDetailsModel.fromJson(Map<String, dynamic> json) {
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
  double? rating;
  String? id;
  String? name;
  String? description;
  String? email;
  String? countryCode;
  String? mobile;
  String? address;
  String? image;
  GeoLocationPoint? geoLocationPoint;
  String? createdAt;
  String? updatedAt;
  int? reviewCount;
  List<ServiceCategories>? serviceCategories;
  bool? isFavourite;

  Data(
      {this.rating,
        this.id,
        this.name,
        this.description,
        this.email,
        this.countryCode,
        this.mobile,
        this.address,
        this.image,
        this.geoLocationPoint,
        this.createdAt,
        this.updatedAt,
        this.reviewCount,
        this.serviceCategories,
        this.isFavourite});

  Data.fromJson(Map<String, dynamic> json) {
    rating = double.parse(json['rating'].toString());
    id = json['id'];
    name = json['name'];
    description = json['description'];
    email = json['email'];
    countryCode = json['countryCode'];
    mobile = json['mobile'];
    address = json['address'];
    image = json['image'];
    geoLocationPoint = json['geoLocationPoint'] != null
        ? GeoLocationPoint.fromJson(json['geoLocationPoint'])
        : null;
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    reviewCount = json['reviewCount'];
    if (json['serviceCategories'] != null) {
      serviceCategories = <ServiceCategories>[];
      json['serviceCategories'].forEach((v) {
        serviceCategories!.add(ServiceCategories.fromJson(v));
      });
    }
    isFavourite = json['isFavourite'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['rating'] = rating;
    data['id'] = id;
    data['name'] = name;
    data['description'] = description;
    data['email'] = email;
    data['countryCode'] = countryCode;
    data['mobile'] = mobile;
    data['address'] = address;
    data['image'] = image;
    if (geoLocationPoint != null) {
      data['geoLocationPoint'] = geoLocationPoint!.toJson();
    }
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['reviewCount'] = reviewCount;
    if (serviceCategories != null) {
      data['serviceCategories'] =
          serviceCategories!.map((v) => v.toJson()).toList();
    }
    data['isFavourite'] = isFavourite;
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

class ServiceCategories {
  String? id;
  String? createdAt;
  String? updatedAt;
  String? deletedAt;
  String? name;
  String? description;
  String? serviceableGender;
  String? imageFemale;
  String? imageMale;

  ServiceCategories(
      {this.id,
        this.createdAt,
        this.updatedAt,
        this.deletedAt,
        this.name,
        this.description,
        this.serviceableGender,
        this.imageFemale,
        this.imageMale});

  ServiceCategories.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    deletedAt = json['deletedAt'];
    name = json['name'];
    description = json['description'];
    serviceableGender = json['serviceableGender'];
    imageFemale = json['imageFemale'];
    imageMale = json['imageMale'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['deletedAt'] = deletedAt;
    data['name'] = name;
    data['description'] = description;
    data['serviceableGender'] = serviceableGender;
    data['imageFemale'] = imageFemale;
    data['imageMale'] = imageMale;
    return data;
  }
}