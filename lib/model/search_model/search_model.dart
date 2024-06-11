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
  SalonListData? salon;

  SalonData({this.isArtist, this.isService, this.isSalon, this.salon});

  SalonData.fromJson(Map<String, dynamic> json) {
    isArtist = json['isArtist'];
    isService = json['isService'];
    isSalon = json['isSalon'];
    salon = json['salon'] != null ? SalonListData.fromJson(json['salon']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['isArtist'] = isArtist;
    data['isService'] = isService;
    data['isSalon'] = isSalon;
    if (salon != null) {
      data['salon'] = salon!.toJson();
    }
    return data;
  }
}

class SalonListData {
  String? address;
  String? id;
  String? image;
  String? name;
  double? rating;
  int? reviewCount;

  SalonListData(
      {this.address,
        this.id,
        this.image,
        this.name,
        this.rating,
        this.reviewCount});

  SalonListData.fromJson(Map<String, dynamic> json) {
    address = json['address'];
    id = json['id'];
    image = json['image'];
    name = json['name'];
    rating = json['rating'];
    reviewCount = json['reviewCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['address'] = address;
    data['id'] = id;
    data['image'] = image;
    data['name'] = name;
    data['rating'] = rating;
    data['reviewCount'] = reviewCount;
    return data;
  }
}