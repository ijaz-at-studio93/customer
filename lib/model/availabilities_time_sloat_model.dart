class AvailabilitiesTimeSlotModel {
  int? statusCode;
  bool? success;
  List<TimeSlot>? data;
  String? message;

  AvailabilitiesTimeSlotModel(
      {this.statusCode, this.success, this.data, this.message});

  AvailabilitiesTimeSlotModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    success = json['success'];
    if (json['data'] != null) {
      data = <TimeSlot>[];
      json['data'].forEach((v) {
        data!.add(TimeSlot.fromJson(v));
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

class TimeSlot {
  String? time;

  TimeSlot({this.time});

  TimeSlot.fromJson(Map<String, dynamic> json) {
    time = json['time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['time'] = time;
    return data;
  }
}
