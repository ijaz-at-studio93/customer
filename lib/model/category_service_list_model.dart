class CategoryServicesListModel {
  int? statusCode;
  bool? success;
  List<Data>? data;
  String? message;

  CategoryServicesListModel(
      {this.statusCode, this.success, this.data, this.message});

  CategoryServicesListModel.fromJson(Map<String, dynamic> json) {
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
  String? serviceableGender;
  List<Services>? services;

  Data({this.id, this.name, this.serviceableGender, this.services});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    serviceableGender = json['serviceableGender'];
    if (json['services'] != null) {
      services = <Services>[];
      json['services'].forEach((v) {
        services!.add(Services.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['serviceableGender'] = serviceableGender;
    if (services != null) {
      data['services'] = services!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Services {
  String? id;
  String? name;
  String? description;
  String? image;
  int? price;
  int? duration;
  String? gender;
  bool? homeService;

  Services(
      {this.id,
      this.name,
      this.description,
      this.image,
      this.price,
      this.duration,
      this.gender,
      this.homeService});

  Services.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    image = json['image'];
    price = json['price'];
    duration = json['duration'];
    gender = json['gender'];
    homeService = json['homeService'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['description'] = description;
    data['image'] = image;
    data['price'] = price;
    data['duration'] = duration;
    data['gender'] = gender;
    data['homeService'] = homeService;
    return data;
  }
}
