class UnAvailableDatesModel {
  int? statusCode;
  bool? success;
  Data? data;
  String? message;

  UnAvailableDatesModel(
      {this.statusCode, this.success, this.data, this.message});

  UnAvailableDatesModel.fromJson(Map<String, dynamic> json) {
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
  bool? isMonthAvailable;
  List<UnavailableDates>? unavailableDates;

  Data({this.isMonthAvailable, this.unavailableDates});

  Data.fromJson(Map<String, dynamic> json) {
    isMonthAvailable = json['isMonthAvailable'];
    if (json['unavailableDates'] != null) {
      unavailableDates = <UnavailableDates>[];
      json['unavailableDates'].forEach((v) {
        unavailableDates!.add(UnavailableDates.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['isMonthAvailable'] = isMonthAvailable;
    if (unavailableDates != null) {
      data['unavailableDates'] =
          unavailableDates!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class UnavailableDates {
  String? date;

  UnavailableDates({this.date});

  UnavailableDates.fromJson(Map<String, dynamic> json) {
    date = json['date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['date'] = date;
    return data;
  }
}
