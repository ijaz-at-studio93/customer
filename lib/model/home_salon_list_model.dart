class HomeSalonModel {
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
  int? distance;
  bool? isFav;

  HomeSalonModel(
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
      this.distance,
      this.isFav});

  HomeSalonModel.fromJson(Map<String, dynamic> json) {
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
    distance = json['distance'];
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
    data['distance'] = distance;
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
