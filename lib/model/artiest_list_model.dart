class ArtistListModel {
  int? statusCode;
  bool? success;

  List<Artiest>? maleHairArtists;
  List<Artiest>? femaleHairArtists;
  List<Artiest>? maleBeautyArtists;
  List<Artiest>? femaleBeautyArtists;

  ServiceMeta? serviceMeta;
  String? message;

  /// ✅ ADD THIS
  ArtistListModel({
    this.statusCode,
    this.success,
    this.maleHairArtists,
    this.femaleHairArtists,
    this.maleBeautyArtists,
    this.femaleBeautyArtists,
    this.serviceMeta,
    this.message,
  });

  factory ArtistListModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];

    return ArtistListModel(
      statusCode: json['statusCode'],
      success: json['success'],
      message: json['message'],

      maleHairArtists: (data['maleHairArtists'] as List? ?? [])
          .map((e) => Artiest.fromJson(e))
          .toList(),

      femaleHairArtists: (data['femaleHairArtists'] as List? ?? [])
          .map((e) => Artiest.fromJson(e))
          .toList(),

      maleBeautyArtists: (data['maleBeautyArtists'] as List? ?? [])
          .map((e) => Artiest.fromJson(e))
          .toList(),

      femaleBeautyArtists: (data['femaleBeautyArtists'] as List? ?? [])
          .map((e) => Artiest.fromJson(e))
          .toList(),

      serviceMeta: data['serviceMeta'] != null
          ? ServiceMeta.fromJson(data['serviceMeta'])
          : null,
    );
  }
}

class Artiest {
  double? rating;
  String? id;
  String? name;
  String? dob;
  String? profileImage;
  int? experience;
  bool? homeService;
  String? gender;
  int? reviewCount;
  bool? isSelectArtist;

  Artiest({
    this.rating,
    this.id,
    this.name,
    this.dob,
    this.profileImage,
    this.experience,
    this.homeService,
    this.gender,
    this.reviewCount,
    this.isSelectArtist,
  });

  factory Artiest.fromJson(Map<String, dynamic> json) {
    // Safe rating parsing (handles null / int / double / string)
    double? parseRating(dynamic r) {
      if (r == null) return null;
      if (r is num) return r.toDouble();
      return double.tryParse(r.toString());
    }

    return Artiest(
      rating: parseRating(json['rating']),
      id: json['id']?.toString(),
      name: json['name'] as String?,
      dob: json['dob'] as String?,
      profileImage: json['profileImage'] as String?,
      experience: (json['experience'] as num?)?.toInt(),
      homeService: json['homeService'] as bool?,
      gender: json['gender'] as String?,
      reviewCount: (json['reviewCount'] as num?)?.toInt(),
      isSelectArtist: false, // UI toggles this
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rating': rating,
      'id': id,
      'name': name,
      'dob': dob,
      'profileImage': profileImage,
      'experience': experience,
      'homeService': homeService,
      'gender': gender,
      'reviewCount': reviewCount,
    };
  }
}

class ServiceMeta {
  final bool hasMaleServices;
  final bool hasFemaleServices;

  final bool hasMaleHair;
  final bool hasMaleBeauty;

  final bool hasFemaleHair;
  final bool hasFemaleBeauty;

  ServiceMeta({
    required this.hasMaleServices,
    required this.hasFemaleServices,
    required this.hasMaleHair,
    required this.hasMaleBeauty,
    required this.hasFemaleHair,
    required this.hasFemaleBeauty,
  });

  factory ServiceMeta.fromJson(Map<String, dynamic> json) {
    return ServiceMeta(
      hasMaleServices: json['hasMaleServices'] ?? false,
      hasFemaleServices: json['hasFemaleServices'] ?? false,
      hasMaleHair: json['hasMaleHair'] ?? false,
      hasMaleBeauty: json['hasMaleBeauty'] ?? false,
      hasFemaleHair: json['hasFemaleHair'] ?? false,
      hasFemaleBeauty: json['hasFemaleBeauty'] ?? false,
    );
  }
}