class HomeSalonModel {
  int? statusCode;
  bool? success;
  Data? data;
  String? message;

  HomeSalonModel({this.statusCode, this.success, this.data, this.message});

  HomeSalonModel.fromJson(Map<String, dynamic> json) {
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
  String? previousPage;
  String? nextPage;
  int? total;
  List<HomeSalonDataList>? rows;
  int? currentPage;
  int? timestamp;
  int? limit;

  Data(
      {this.previousPage,
        this.nextPage,
        this.total,
        this.rows,
        this.currentPage,
        this.timestamp,
        this.limit});

  Data.fromJson(Map<String, dynamic> json) {
    previousPage = json['previousPage'];
    nextPage = json['nextPage'];
    total = json['total'];
    if (json['rows'] != null) {
      rows = <HomeSalonDataList>[];
      json['rows'].forEach((v) {
        rows!.add(HomeSalonDataList.fromJson(v));
      });
    }
    currentPage = json['currentPage'];
    timestamp = json['timestamp'];
    limit = json['limit'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['previousPage'] = previousPage;
    data['nextPage'] = nextPage;
    data['total'] = total;
    if (rows != null) {
      data['rows'] = rows!.map((v) => v.toJson()).toList();
    }
    data['currentPage'] = currentPage;
    data['timestamp'] = timestamp;
    data['limit'] = limit;
    return data;
  }
}

class HomeSalonDataList {
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
  double? rating;
  int? reviewCount;
  int? distance;
  bool? homeService;
  bool? isFavourite;

  HomeSalonDataList(
      {this.id,
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
        this.rating,
        this.reviewCount,
        this.distance,
        this.homeService,
        this.isFavourite});

  HomeSalonDataList.fromJson(Map<String, dynamic> json) {
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
    rating =    double.parse(json['rating'].toString());
    reviewCount = json['reviewCount'];
    distance = json['distance'];
    homeService = json['homeService'];
    isFavourite = json['isFavourite'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
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
    data['rating'] = rating;
    data['reviewCount'] = reviewCount;
    data['distance'] = distance;
    data['homeService'] = homeService;
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