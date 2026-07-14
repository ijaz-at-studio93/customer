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
  String? userAppIOSMinimumVersion;
  String? userAppIOSLatestVersion;
  String? salonAppLatestVersion;
  String? userAppMinimumVersion;
  String? salonAppMinimumVersion;
  String? paymentDemoVideo;
  PersonOfTheYear? personOfTheYear;

  Data(
      {this.maintenanceMode,
        this.forceUpdateUserApp,
        this.forceUpdateSalonApp,
        this.userAppLatestVersion,
        this.userAppIOSMinimumVersion,
        this.userAppIOSLatestVersion,
        this.salonAppLatestVersion,
        this.userAppMinimumVersion,
        this.salonAppMinimumVersion,
        this.paymentDemoVideo,
        this.personOfTheYear});

  Data.fromJson(Map<String, dynamic> json) {
    maintenanceMode = json['maintenanceMode'];
    forceUpdateUserApp = json['forceUpdateUserApp'];
    forceUpdateSalonApp = json['forceUpdateSalonApp'];
    userAppLatestVersion = json['userAppLatestVersion'];
    userAppIOSLatestVersion = json['userAppIOSLatestVersion'];
    userAppIOSMinimumVersion = json['userAppIOSMinimumVersion'];
    salonAppLatestVersion = json['salonAppLatestVersion'];
    userAppMinimumVersion = json['userAppMinimumVersion'];
    salonAppMinimumVersion = json['salonAppMinimumVersion'];
    paymentDemoVideo = json['paymentDemoVideo'];
    personOfTheYear = json['personOfTheYear'] != null
        ? PersonOfTheYear.fromJson(json['personOfTheYear'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['maintenanceMode'] = maintenanceMode;
    data['forceUpdateUserApp'] = forceUpdateUserApp;
    data['forceUpdateSalonApp'] = forceUpdateSalonApp;
    data['userAppLatestVersion'] = userAppLatestVersion;
    data['userAppIOSMinimumVersion'] = userAppIOSMinimumVersion;
    data['userAppIOSLatestVersion'] = userAppIOSLatestVersion;
    data['salonAppLatestVersion'] = salonAppLatestVersion;
    data['userAppMinimumVersion'] = userAppMinimumVersion;
    data['salonAppMinimumVersion'] = salonAppMinimumVersion;
    data['paymentDemoVideo'] = paymentDemoVideo;
    if (personOfTheYear != null) {
      data['personOfTheYear'] = personOfTheYear!.toJson();
    }
    return data;
  }
}
class PersonOfTheYear {
  bool? enabled;

  PersonOfTheYear({this.enabled});

  PersonOfTheYear.fromJson(Map<String, dynamic> json) {
    enabled = json['enabled'];
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
    };
  }
}