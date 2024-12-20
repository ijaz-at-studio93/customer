class SearchSalonModel {
  int? statusCode;
  bool? success;
  List<SalonData>? data;
  String? message;

  SearchSalonModel({this.statusCode, this.success, this.data, this.message});

  SearchSalonModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    success = json['success'];
    if (json['data'] != null) {
      data = <SalonData>[];
      json['data'].forEach((v) {
        data!.add(SalonData.fromJson(v));
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

class SalonData {
  bool? isArtist;
  bool? isService;
  bool? isSalon;
  Service? service;
  Salon? salon;

  SalonData(
      {this.isArtist, this.isService, this.isSalon, this.service, this.salon});

  SalonData.fromJson(Map<String, dynamic> json) {
    isArtist = json['isArtist'];
    isService = json['isService'];
    isSalon = json['isSalon'];
    service =
        json['service'] != null ? Service.fromJson(json['service']) : null;
    salon = json['salon'] != null ? Salon.fromJson(json['salon']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['isArtist'] = isArtist;
    data['isService'] = isService;
    data['isSalon'] = isSalon;
    if (service != null) {
      data['service'] = service!.toJson();
    }
    if (salon != null) {
      data['salon'] = salon!.toJson();
    }
    return data;
  }
}

class Service {
  int? price;
  String? id;
  String? name;
  String? description;
  String? image;
  int? duration;
  Salon? salon;

  Service(
      {this.price,
      this.id,
      this.name,
      this.description,
      this.image,
      this.duration,
      this.salon});

  Service.fromJson(Map<String, dynamic> json) {
    price = json['price'];
    id = json['id'];
    name = json['name'];
    description = json['description'];
    image = json['image'];
    duration = json['duration'];
    salon = json['salon'] != null ? Salon.fromJson(json['salon']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['price'] = price;
    data['id'] = id;
    data['name'] = name;
    data['description'] = description;
    data['image'] = image;
    data['duration'] = duration;
    if (salon != null) {
      data['salon'] = salon!.toJson();
    }
    return data;
  }
}

class Salon {
  int? rating;
  String? id;
  String? name;
  String? address;
  int? reviewCount;
  int? distance;
  String? image;
  String? homeService;
  String? serviceGender;

  Salon(
      {this.rating,
      this.id,
      this.name,
      this.address,
      this.reviewCount,
      this.distance,
      this.image,
      this.homeService,
      this.serviceGender});

  Salon.fromJson(Map<String, dynamic> json) {
    rating = json['rating'];
    id = json['id'];
    name = json['name'];
    address = json['address'];
    reviewCount = json['reviewCount'];
    distance = json['distance'];
    image = json['image'];
    homeService = json['homeService'];
    serviceGender = json['serviceGender'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['rating'] = rating;
    data['id'] = id;
    data['name'] = name;
    data['address'] = address;
    data['reviewCount'] = reviewCount;
    data['distance'] = distance;
    data['image'] = image;
    data['homeService'] = homeService;
    data['serviceGender'] = serviceGender;
    return data;
  }
}
