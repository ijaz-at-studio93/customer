class ReviewListModel {
  int? statusCode;
  bool? success;
  Data? data;
  String? message;

  ReviewListModel({this.statusCode, this.success, this.data, this.message});

  ReviewListModel.fromJson(Map<String, dynamic> json) {
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
  List<Artists>? artists;
  List<Products>? products;
  List<Services>? services;

  Data({this.artists, this.products, this.services});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['artists'] != null) {
      artists = <Artists>[];
      json['artists'].forEach((v) {
        artists!.add(Artists.fromJson(v));
      });
    }
    if (json['products'] != null) {
      products = <Products>[];
      json['products'].forEach((v) {
        products!.add(Products.fromJson(v));
      });
    }
    if (json['services'] != null) {
      services = <Services>[];
      json['services'].forEach((v) {
        services!.add(Services.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (artists != null) {
      data['artists'] = artists!.map((v) => v.toJson()).toList();
    }
    if (products != null) {
      data['products'] = products!.map((v) => v.toJson()).toList();
    }
    if (services != null) {
      data['services'] = services!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Artists {
  String? reviewId;
  String? id;
  String? image;
  String? name;
  bool? isReviewGiven;
  double? rating;
  String? review;
  String? salonAddress;
  String? salonName;

  Artists(
      {this.reviewId,
        this.id,
        this.image,
        this.name,
        this.isReviewGiven,
        this.rating,
        this.review,
        this.salonAddress,
        this.salonName});

  Artists.fromJson(Map<String, dynamic> json) {
    reviewId = json['reviewId'];
    id = json['id'];
    image = json['image'];
    name = json['name'];
    isReviewGiven = json['isReviewGiven'];
    rating = double.parse(json['rating'].toString());
    review = json['review'];
    salonAddress = json['salonAddress'];
    salonName = json['salonName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['reviewId'] = reviewId;
    data['id'] = id;
    data['image'] = image;
    data['name'] = name;
    data['isReviewGiven'] = isReviewGiven;
    data['rating'] = rating;
    data['review'] = review;
    data['salonAddress'] = salonAddress;
    data['salonName'] = salonName;
    return data;
  }
}

class Products {
  String? reviewId;
  String? id;
  String? image;
  String? name;
  bool? isReviewGiven;
  double? rating;
  String? review;
  String? salonAddress;
  String? salonName;
  String? serviceCategoryName;
  int? price;

  Products(
      {this.reviewId,
        this.id,
        this.image,
        this.name,
        this.isReviewGiven,
        this.rating,
        this.review,
        this.salonAddress,
        this.salonName,
        this.serviceCategoryName,
        this.price});

  Products.fromJson(Map<String, dynamic> json) {
    reviewId = json['reviewId'];
    id = json['id'];
    image = json['image'];
    name = json['name'];
    isReviewGiven = json['isReviewGiven'];
    rating = double.parse(json['rating'].toString());
    review = json['review'];
    salonAddress = json['salonAddress'];
    salonName = json['salonName'];
    serviceCategoryName = json['serviceCategoryName'];
    price = json['price'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['reviewId'] = reviewId;
    data['id'] = id;
    data['image'] = image;
    data['name'] = name;
    data['isReviewGiven'] = isReviewGiven;
    data['rating'] = rating;
    data['review'] = review;
    data['salonAddress'] = salonAddress;
    data['salonName'] = salonName;
    data['serviceCategoryName'] = serviceCategoryName;
    data['price'] = price;
    return data;
  }
}

class Services {
  String? reviewId;
  String? id;
  String? image;
  String? name;
  bool? isReviewGiven;
  double? rating;
  String? review;
  String? salonAddress;
  String? salonName;
  String? salonImage;
  int? price;
  List<String>? categoriesName;

  Services(
      {this.reviewId,
        this.id,
        this.image,
        this.name,
        this.isReviewGiven,
        this.rating,
        this.review,
        this.salonAddress,
        this.salonName,
        this.salonImage,
        this.price,
        this.categoriesName});

  Services.fromJson(Map<String, dynamic> json) {
    reviewId = json['reviewId'];
    id = json['id'];
    image = json['image'];
    name = json['name'];
    isReviewGiven = json['isReviewGiven'];
    rating = double.parse(json['rating'].toString());
    review = json['review'];
    salonAddress = json['salonAddress'];
    salonName = json['salonName'];
    salonImage = json['salonImage'];
    price = json['price'];
    categoriesName = json['categoriesName'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['reviewId'] = reviewId;
    data['id'] = id;
    data['image'] = image;
    data['name'] = name;
    data['isReviewGiven'] = isReviewGiven;
    data['rating'] = rating;
    data['review'] = review;
    data['salonAddress'] = salonAddress;
    data['salonName'] = salonName;
    data['salonImage'] = salonImage;
    data['price'] = price;
    data['categoriesName'] = categoriesName;
    return data;
  }
}