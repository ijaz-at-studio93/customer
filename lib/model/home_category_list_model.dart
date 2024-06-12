class HomeCategoryListModel {
  int? statusCode;
  bool? success;
  List<CategoryListData>? data;
  String? message;

  HomeCategoryListModel(
      {this.statusCode, this.success, this.data, this.message});

  HomeCategoryListModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    success = json['success'];
    if (json['data'] != null) {
      data = <CategoryListData>[];
      json['data'].forEach((v) {
        data!.add(CategoryListData.fromJson(v));
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

class CategoryListData {
  String? id;
  String? createdAt;
  String? updatedAt;
  String? deletedAt;
  String? name;
  String? description;
  String? serviceableGender;
  String? imageFemale;
  String? imageMale;
  bool? isSelectCategory;

  CategoryListData(
      {this.id,
      this.createdAt,
      this.updatedAt,
      this.deletedAt,
      this.name,
      this.description,
      this.serviceableGender,
      this.imageFemale,
      this.imageMale,
      this.isSelectCategory});

  CategoryListData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    deletedAt = json['deletedAt'];
    name = json['name'];
    description = json['description'];
    serviceableGender = json['serviceableGender'];
    imageFemale = json['imageFemale'];
    imageMale = json['imageMale'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['deletedAt'] = deletedAt;
    data['name'] = name;
    data['description'] = description;
    data['serviceableGender'] = serviceableGender;
    data['imageFemale'] = imageFemale;
    data['imageMale'] = imageMale;
    return data;
  }
}
