class SalonDetailsArtiestModel {
  int? statusCode;
  bool? success;
  List<Data>? data;
  String? message;

  SalonDetailsArtiestModel(
      {this.statusCode, this.success, this.data, this.message});

  SalonDetailsArtiestModel.fromJson(Map<String, dynamic> json) {
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
  String? id;
  String? name;
  String? dob;
  String? profileImage;
  int? experience;
  bool? homeService;
  String? gender;

  Data(
      {this.id,
      this.name,
      this.dob,
      this.profileImage,
      this.experience,
      this.homeService,
      this.gender});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    dob = json['dob'];
    profileImage = json['profileImage'];
    experience = json['experience'];
    homeService = json['homeService'];
    gender = json['gender'];
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
    return data;
  }
}
