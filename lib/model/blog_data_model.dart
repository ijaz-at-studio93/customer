class BlogDataModel {
  int? statusCode;
  bool? success;
  List<BlogData>? data;
  String? message;

  BlogDataModel({this.statusCode, this.success, this.data, this.message});

  BlogDataModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    success = json['success'];
    if (json['data'] != null) {
      data = <BlogData>[];
      json['data'].forEach((v) {
        data!.add(BlogData.fromJson(v));
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

class BlogData {
  String? id;
  String? title;
  String? description;
  String? image;
  String? video;
  String? createdAt;
  String? body;
  String? externalLink;
  int? viewCount;
  Artist? artist;
  bool?  isFavourite;

  BlogData(
      {this.id,
      this.title,
      this.description,
      this.image,
      this.video,
      this.createdAt,
      this.body,
      this.externalLink,
      this.viewCount,
      this.artist,
      this.isFavourite
      });

  BlogData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    image = json['image'];
    video = json['video'];
    createdAt = json['createdAt'];
    body = json['body'];
    externalLink = json['externalLink'];
    viewCount = json['viewCount'];
    isFavourite =  json['isFavourite'];
    artist = json['artist'] != null ? Artist.fromJson(json['artist']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['description'] = description;
    data['image'] = image;
    data['video'] = video;
    data['createdAt'] = createdAt;
    data['body'] = body;
    data['externalLink'] = externalLink;
    data['viewCount'] = viewCount;
    data['isFavourite'] = isFavourite;
    if (artist != null) {
      data['artist'] = artist!.toJson();
    }
    return data;
  }
}

class Artist {
  String? id;
  String? name;
  String? profileImage;
  Salon? salon;

  Artist({this.id, this.name, this.profileImage, this.salon});

  Artist.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    profileImage = json['profileImage'];
    salon = json['salon'] != null ? Salon.fromJson(json['salon']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['profileImage'] = profileImage;
    if (salon != null) {
      data['salon'] = salon!.toJson();
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
