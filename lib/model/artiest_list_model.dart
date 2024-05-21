class ArtistListModel {
  int? statusCode;
  bool? success;
  List<Artiest>? data;
  String? message;

  ArtistListModel({this.statusCode, this.success, this.data, this.message});

  ArtistListModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    success = json['success'];
    if (json['data'] != null) {
      data = <Artiest>[];
      json['data'].forEach((v) {
        data!.add(Artiest.fromJson(v));
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

class Artiest {
  String? id;
  String? name;
  String? dob;
  String? profileImage;
  int? experience;
  bool? homeService;
  String? gender;
  String? artistServiceableGender;
  bool? isSelectArtist;

  Artiest(
      {this.id,
      this.name,
      this.dob,
      this.profileImage,
      this.experience,
      this.homeService,
      this.gender,
      this.artistServiceableGender,
      this.isSelectArtist});

  Artiest.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    dob = json['dob'];
    profileImage = json['profileImage'];
    experience = json['experience'];
    homeService = json['homeService'];
    gender = json['gender'];
    artistServiceableGender = json['artistServiceableGender'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['dob'] = dob;
    data['profileImage'] = profileImage;
    data['experience'] = experience;
    data['homeService'] = homeService;
    data['gender'] = gender;
    data['artistServiceableGender'] = artistServiceableGender;
    return data;
  }
}
