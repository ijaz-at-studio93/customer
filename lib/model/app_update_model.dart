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
  PersonOfTheYear? personOfTheYear;

  Data(
      {this.maintenanceMode,
        this.forceUpdateUserApp,
        this.forceUpdateSalonApp,
        this.userAppLatestVersion,
        this.salonAppLatestVersion,
        this.userAppMinimumVersion,
        this.salonAppMinimumVersion,
        this.personOfTheYear});

  Data.fromJson(Map<String, dynamic> json) {
    maintenanceMode = json['maintenanceMode'];
    forceUpdateUserApp = json['forceUpdateUserApp'];
    forceUpdateSalonApp = json['forceUpdateSalonApp'];
    userAppLatestVersion = json['userAppLatestVersion'];
    salonAppLatestVersion = json['salonAppLatestVersion'];
    userAppMinimumVersion = json['userAppMinimumVersion'];
    salonAppMinimumVersion = json['salonAppMinimumVersion'];
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
    data['salonAppLatestVersion'] = salonAppLatestVersion;
    data['userAppMinimumVersion'] = userAppMinimumVersion;
    data['salonAppMinimumVersion'] = salonAppMinimumVersion;
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
