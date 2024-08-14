class ArtistPopularServicesModel {
  int? statusCode;
  bool? success;
  List<Data>? data;
  String? message;

  ArtistPopularServicesModel(
      {this.statusCode, this.success, this.data, this.message});

  ArtistPopularServicesModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    success = json['success'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
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

class Data {
  int? price;
  double? rating;
  String? id;
  String? name;
  String? description;
  String? image;
  int? duration;
  String? gender;
  bool? homeService;
  int? reviewCount;
  bool?  isAddCart;
  String? artistServiceableGender;
  List<Categories>? categories;

  Data(
      {this.price,
        this.rating,
        this.id,
        this.name,
        this.description,
        this.image,
        this.duration,
        this.gender,
        this.homeService,
        this.reviewCount,
        this.isAddCart,
        this.artistServiceableGender,
        this.categories});

  Data.fromJson(Map<String, dynamic> json) {
    price = json['price'];
    rating = double.parse(json['rating'].toString());
    id = json['id'];
    name = json['name'];
    description = json['description'];
    image = json['image'];
    duration = json['duration'];
    gender = json['gender'];
    homeService = json['homeService'];
    reviewCount = json['reviewCount'];
    artistServiceableGender = json['artistServiceableGender'];
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
    data['rating'] = rating;
    data['id'] = id;
    data['name'] = name;
    data['description'] = description;
    data['image'] = image;
    data['duration'] = duration;
    data['gender'] = gender;
    data['homeService'] = homeService;
    data['reviewCount'] = reviewCount;
    data['artistServiceableGender'] = artistServiceableGender;
    if (categories != null) {
      data['categories'] = categories!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Categories {
  String? id;
  String? name;
  String? serviceableGender;

  Categories({this.id, this.name, this.serviceableGender});

  Categories.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    serviceableGender = json['serviceableGender'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['serviceableGender'] = serviceableGender;
    return data;
  }
}