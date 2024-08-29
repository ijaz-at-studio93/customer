class ServiceProductModel {
  int? statusCode;
  bool? success;
  List<Data>? data;
  String? message;

  ServiceProductModel({this.statusCode, this.success, this.data, this.message});

  ServiceProductModel.fromJson(Map<String, dynamic> json) {
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
  String? createdAt;
  String? updatedAt;
  String? serviceCategoryId;
  String? salonId;
  String? name;
  String? description;
  String? image;
  int? reviewCount;
  bool? isAddedToCart;


  Data(
      {this.price,
        this.rating,
        this.id,
        this.createdAt,
        this.updatedAt,
        this.serviceCategoryId,
        this.salonId,
        this.name,
        this.description,
        this.image,
        this.reviewCount,
        this.isAddedToCart
      });

  Data.fromJson(Map<String, dynamic> json) {
    price = json['price'];
    rating = double.parse(json['rating'].toString());
    id = json['id'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    serviceCategoryId = json['serviceCategoryId'];
    salonId = json['salonId'];
    name = json['name'];
    description = json['description'];
    image = json['image'];
    reviewCount = json['reviewCount'];
    isAddedToCart = json['isAddedToCart'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['price'] = price;
    data['rating'] = rating;
    data['id'] = id;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['serviceCategoryId'] = serviceCategoryId;
    data['salonId'] = salonId;
    data['name'] = name;
    data['description'] = description;
    data['image'] = image;
    data['reviewCount'] = reviewCount;
    data['isAddedToCart'] = isAddedToCart;
    return data;
  }
}