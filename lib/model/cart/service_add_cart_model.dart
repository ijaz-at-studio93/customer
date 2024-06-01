class ServiceAddCartModel {
  int? statusCode;
  bool? success;
  Data? data;
  String? message;

  ServiceAddCartModel({this.statusCode, this.success, this.data, this.message});

  ServiceAddCartModel.fromJson(Map<String, dynamic> json) {
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
  String? cartId;
  String? salonId;
  List<Items>? items;
  int? price;
  List<String>? previewImages;
  List<ServicesAvailableProductList>? servicesAvailableProductList;

  Data(
      {this.cartId,
      this.salonId,
      this.items,
      this.price,
      this.previewImages,
      this.servicesAvailableProductList});

  Data.fromJson(Map<String, dynamic> json) {
    cartId = json['cartId'];
    salonId = json['salonId'];
    if (json['items'] != null) {
      items = <Items>[];
      json['items'].forEach((v) {
        items!.add(Items.fromJson(v));
      });
    }
    price = json['price'];
    if(json['previewImages'] !=  null){
      previewImages = json['previewImages'].cast<String>();
    }
    if (json['servicesAvailableProductList'] != null) {
      servicesAvailableProductList = <ServicesAvailableProductList>[];
      json['servicesAvailableProductList'].forEach((v) {
        servicesAvailableProductList!
            .add(ServicesAvailableProductList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['cartId'] = cartId;
    data['salonId'] = salonId;
    if (items != null) {
      data['items'] = items!.map((v) => v.toJson()).toList();
    }
    data['price'] = price;
    data['previewImages'] = previewImages;
    if (servicesAvailableProductList != null) {
      data['servicesAvailableProductList'] =
          servicesAvailableProductList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Items {
  String? cartItemId;
  bool? isService;
  Service? service;
  Product? product;

  Items({this.cartItemId, this.isService, this.service, this.product});

  Items.fromJson(Map<String, dynamic> json) {
    cartItemId = json['cartItemId'];
    isService = json['isService'];
    service =
        json['service'] != null ? Service.fromJson(json['service']) : null;
    product =
        json['product'] != null ? Product.fromJson(json['product']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['cartItemId'] = cartItemId;
    data['isService'] = isService;
    if (service != null) {
      data['service'] = service!.toJson();
    }
    if (product != null) {
      data['product'] = product!.toJson();
    }
    return data;
  }
}

class Service {
  int? price;
  int? rating;
  String? id;
  String? createdAt;
  String? updatedAt;
  String? deletedAt;
  String? description;
  int? duration;
  String? gender;
  String? image;
  String? name;
  String? salonId;
  String? status;
  bool? homeService;
  int? reviewCount;

  Service(
      {this.price,
      this.rating,
      this.id,
      this.createdAt,
      this.updatedAt,
      this.deletedAt,
      this.description,
      this.duration,
      this.gender,
      this.image,
      this.name,
      this.salonId,
      this.status,
      this.homeService,
      this.reviewCount});

  Service.fromJson(Map<String, dynamic> json) {
    price = json['price'];
    rating = json['rating'];
    id = json['id'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    deletedAt = json['deletedAt'];
    description = json['description'];
    duration = json['duration'];
    gender = json['gender'];
    image = json['image'];
    name = json['name'];
    salonId = json['salonId'];
    status = json['status'];
    homeService = json['homeService'];
    reviewCount = json['reviewCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['price'] = price;
    data['rating'] = rating;
    data['id'] = id;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['deletedAt'] = deletedAt;
    data['description'] = description;
    data['duration'] = duration;
    data['gender'] = gender;
    data['image'] = image;
    data['name'] = name;
    data['salonId'] = salonId;
    data['status'] = status;
    data['homeService'] = homeService;
    data['reviewCount'] = reviewCount;
    return data;
  }
}

class Product {
  int? price;
  int? rating;
  String? id;
  String? createdAt;
  String? updatedAt;
  String? deletedAt;
  String? salonId;
  String? serviceCategoryId;
  String? name;
  String? description;
  String? image;
  int? reviewCount;

  Product(
      {this.price,
      this.rating,
      this.id,
      this.createdAt,
      this.updatedAt,
      this.deletedAt,
      this.salonId,
      this.serviceCategoryId,
      this.name,
      this.description,
      this.image,
      this.reviewCount});

  Product.fromJson(Map<String, dynamic> json) {
    price = json['price'];
    rating = json['rating'];
    id = json['id'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    deletedAt = json['deletedAt'];
    salonId = json['salonId'];
    serviceCategoryId = json['serviceCategoryId'];
    name = json['name'];
    description = json['description'];
    image = json['image'];
    reviewCount = json['reviewCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['price'] = price;
    data['rating'] = rating;
    data['id'] = id;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['deletedAt'] = deletedAt;
    data['salonId'] = salonId;
    data['serviceCategoryId'] = serviceCategoryId;
    data['name'] = name;
    data['description'] = description;
    data['image'] = image;
    data['reviewCount'] = reviewCount;
    return data;
  }
}

class ServicesAvailableProductList {
  String? id;
  String? createdAt;
  String? updatedAt;
  String? serviceCategoryId;
  String? salonId;
  String? name;
  String? description;
  String? image;
  int? price;
  bool? isAdded;
  int? count;

  ServicesAvailableProductList(
      {this.id,
      this.createdAt,
      this.updatedAt,
      this.serviceCategoryId,
      this.salonId,
      this.name,
      this.description,
      this.image,
      this.price,
      this.isAdded,
      this.count});

  ServicesAvailableProductList.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    serviceCategoryId = json['serviceCategoryId'];
    salonId = json['salonId'];
    name = json['name'];
    description = json['description'];
    image = json['image'];
    price = json['price'];
    isAdded = json['isAdded'];
    count = json['count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['serviceCategoryId'] = serviceCategoryId;
    data['salonId'] = salonId;
    data['name'] = name;
    data['description'] = description;
    data['image'] = image;
    data['price'] = price;
    data['isAdded'] = isAdded;
    data['count'] = count;
    return data;
  }
}
