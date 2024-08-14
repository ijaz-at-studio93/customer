class CategoryServicesListModel {
  int? statusCode;
  bool? success;
  Data? data;
  String? message;

  CategoryServicesListModel(
      {this.statusCode, this.success, this.data, this.message});

  CategoryServicesListModel.fromJson(Map<String, dynamic> json) {
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
  List<SelectedCategories>? selectedCategories;
  List<RecommendedCategories>? recommendedCategories;

  Data({this.selectedCategories, this.recommendedCategories});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['selectedCategories'] != null) {
      selectedCategories = <SelectedCategories>[];
      json['selectedCategories'].forEach((v) {
        selectedCategories!.add(SelectedCategories.fromJson(v));
      });
    }
    if (json['recommendedCategories'] != null) {
      recommendedCategories = <RecommendedCategories>[];
      json['recommendedCategories'].forEach((v) {
        recommendedCategories!.add(RecommendedCategories.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (selectedCategories != null) {
      data['selectedCategories'] =
          selectedCategories!.map((v) => v.toJson()).toList();
    }
    if (recommendedCategories != null) {
      data['recommendedCategories'] =
          recommendedCategories!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SelectedCategories {
  String? id;
  String? name;
  String? serviceableGender;
  List<Services>? services;

  SelectedCategories(
      {this.id, this.name, this.serviceableGender, this.services});

  SelectedCategories.fromJson(Map<String, dynamic> json) {
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

class RecommendedCategories {
  String? id;
  String? name;
  String? serviceableGender;
  List<Services>? services;

  RecommendedCategories(
      {this.id, this.name, this.serviceableGender, this.services});

  RecommendedCategories.fromJson(Map<String, dynamic> json) {
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
  double? rating;
  int? price;
  int? duration;
  String? gender;
  bool? homeService;
  bool? isAddedToCart;

  Services({
    this.id,
    this.name,
    this.description,
    this.image,
    this.rating,
    this.price,
    this.duration,
    this.gender,
    this.homeService,
    this.isAddedToCart,
  });

  Services.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    image = json['image'];
    rating = double.parse(json['rating'].toString());
    price = json['price'];
    duration = json['duration'];
    gender = json['gender'];
    homeService = json['homeService'];
    isAddedToCart = json['isAddedToCart'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['description'] = description;
    data['image'] = image;
    data['rating'] = rating;
    data['price'] = price;
    data['duration'] = duration;
    data['gender'] = gender;
    data['homeService'] = homeService;
    data['isAddedToCart'] = isAddedToCart;
    return data;
  }
}

/*class CategoryServicesListModel {
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
  double ? rating;
  int? price;
  int? duration;
  String? gender;
  bool? homeService;
  bool? isAddedToCart;


  Services({
    this.id,
    this.name,
    this.description,
    this.image,
    this.rating,
    this.price,
    this.duration,
    this.gender,
    this.homeService,
    this.isAddedToCart,
  });

  Services.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    image = json['image'];
    rating = double.parse(json['rating'].toString());
    price = json['price'];
    duration = json['duration'];
    gender = json['gender'];
    homeService = json['homeService'];
    isAddedToCart = json['isAddedToCart'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['description'] = description;
    data['image'] = image;
    data['rating'] = rating;
    data['price'] = price;
    data['duration'] = duration;
    data['gender'] = gender;
    data['homeService'] = homeService;
    data['isAddedToCart'] = isAddedToCart;
    return data;
  }
}*/
