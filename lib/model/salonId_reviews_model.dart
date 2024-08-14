class SalonIdReviewsModel {
  int? statusCode;
  bool? success;
  List<Data>? data;
  String? message;

  SalonIdReviewsModel({this.statusCode, this.success, this.data, this.message});

  SalonIdReviewsModel.fromJson(Map<String, dynamic> json) {
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
  double? rating;
  String? reviewId;
  String? review;
  User? user;
  Service? service;
  bool? isArtist;
  bool? isServices;
  User? artist;

  Data(
      {this.rating,
        this.reviewId,
        this.review,
        this.user,
        this.service,
        this.isArtist,
        this.isServices,
        this.artist});

  Data.fromJson(Map<String, dynamic> json) {
    rating = double.parse(json['rating'].toString());
    reviewId = json['reviewId'];
    review = json['review'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    service =
    json['service'] != null ? Service.fromJson(json['service']) : null;
    isArtist = json['isArtist'];
    isServices = json['isServices'];
    artist = json['artist'] != null ? User.fromJson(json['artist']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['rating'] = rating;
    data['reviewId'] = reviewId;
    data['review'] = review;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    if (service != null) {
      data['service'] = service!.toJson();
    }
    data['isArtist'] = isArtist;
    data['isServices'] = isServices;
    if (artist != null) {
      data['artist'] = artist!.toJson();
    }
    return data;
  }
}

class User {
  String? id;
  String? name;
  String? profileImage;

  User({this.id, this.name, this.profileImage});

  User.fromJson(Map<String, dynamic> json) {
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

class Service {
  String? id;
  String? name;

  Service({this.id, this.name});

  Service.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}