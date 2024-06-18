class AppUpdateModel {
  int? statusCode;
  bool? success;
  Data? data;
  String? message;

  AppUpdateModel({this.statusCode, this.success, this.data, this.message});

  AppUpdateModel.fromJson(Map<String, dynamic> json) {
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
  bool? maintenanceMode;
  bool? forceUpdateUserApp;
  bool? forceUpdateSalonApp;
  String? userAppLatestVersion;
  String? salonAppLatestVersion;
  String? userAppMinimumVersion;
  String? salonAppMinimumVersion;

  Data(
      {this.maintenanceMode,
        this.forceUpdateUserApp,
        this.forceUpdateSalonApp,
        this.userAppLatestVersion,
        this.salonAppLatestVersion,
        this.userAppMinimumVersion,
        this.salonAppMinimumVersion});

  Data.fromJson(Map<String, dynamic> json) {
    maintenanceMode = json['maintenanceMode'];
    forceUpdateUserApp = json['forceUpdateUserApp'];
    forceUpdateSalonApp = json['forceUpdateSalonApp'];
    userAppLatestVersion = json['userAppLatestVersion'];
    salonAppLatestVersion = json['salonAppLatestVersion'];
    userAppMinimumVersion = json['userAppMinimumVersion'];
    salonAppMinimumVersion = json['salonAppMinimumVersion'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['maintenanceMode'] = maintenanceMode;
    data['forceUpdateUserApp'] = forceUpdateUserApp;
    data['forceUpdateSalonApp'] = forceUpdateSalonApp;
    data['userAppLatestVersion'] = userAppLatestVersion;
    data['salonAppLatestVersion'] = salonAppLatestVersion;
    data['userAppMinimumVersion'] = userAppMinimumVersion;
    data['salonAppMinimumVersion'] = salonAppMinimumVersion;
    return data;
  }
}