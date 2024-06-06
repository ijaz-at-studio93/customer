class ReviewRatingUserModel {
  int? statusCode;
  bool? success;
  Data? data;
  String? message;

  ReviewRatingUserModel(
      {this.statusCode, this.success, this.data, this.message});

  ReviewRatingUserModel.fromJson(Map<String, dynamic> json) {
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

  Data({this.artists});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['artists'] != null) {
      artists = <Artists>[];
      json['artists'].forEach((v) {
        artists!.add(Artists.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (artists != null) {
      data['artists'] = artists!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Artists {
  double? rating;
  String? id;
  String? createdAt;
  String? updatedAt;
  String? deletedAt;
  String? salonId;
  String? userId;
  String? bookingOrderId;
  String? review;
  String? salonArtistId;
  String? status;
  Salon? salon;
  Artist? artist;

  Artists(
      {this.rating,
      this.id,
      this.createdAt,
      this.updatedAt,
      this.deletedAt,
      this.salonId,
      this.userId,
      this.bookingOrderId,
      this.review,
      this.salonArtistId,
      this.status,
      this.salon,
      this.artist});

  Artists.fromJson(Map<String, dynamic> json) {
    rating = double.parse(json['rating'].toString());
    id = json['id'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    deletedAt = json['deletedAt'];
    salonId = json['salonId'];
    userId = json['userId'];
    bookingOrderId = json['bookingOrderId'];
    review = json['review'];
    salonArtistId = json['salonArtistId'];
    status = json['status'];
    salon = json['salon'] != null ? Salon.fromJson(json['salon']) : null;
    artist = json['artist'] != null ? Artist.fromJson(json['artist']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['rating'] = rating;
    data['id'] = id;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['deletedAt'] = deletedAt;
    data['salonId'] = salonId;
    data['userId'] = userId;
    data['bookingOrderId'] = bookingOrderId;
    data['review'] = review;
    data['salonArtistId'] = salonArtistId;
    data['status'] = status;
    if (salon != null) {
      data['salon'] = salon!.toJson();
    }
    if (artist != null) {
      data['artist'] = artist!.toJson();
    }
    return data;
  }
}

class Salon {
  String? id;
  String? name;
  String? image;

  Salon({this.id, this.name, this.image});

  Salon.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['image'] = image;
    return data;
  }
}

class Artist {
  String? id;
  String? name;
  String? profileImage;

  Artist({this.id, this.name, this.profileImage});

  Artist.fromJson(Map<String, dynamic> json) {
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
