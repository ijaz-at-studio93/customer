class ArtistListModel {
  int? statusCode;
  bool? success;
  List<Artiest>? data;
  String? message;

  ArtistListModel({this.statusCode, this.success, this.data, this.message});

  factory ArtistListModel.fromJson(Map<String, dynamic> json) {
    final model = ArtistListModel(
      statusCode: json['statusCode'] as int?,
      success: json['success'] as bool?,
      message: json['message'] as String?,
    );

    final payload = json['data'];

    // ─────────────────────────────────────────────────────────────
    // ✅ NEW SHAPE → data: { hairDressers: [...], beauticians: [...] }
    // ─────────────────────────────────────────────────────────────
    if (payload is Map<String, dynamic>) {
      final hair = (payload['hairDressers'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(Artiest.fromJson);
      final beauty = (payload['beauticians'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(Artiest.fromJson);

      model.data = [...hair, ...beauty];
      return model;
    }

    // ─────────────────────────────────────────────────────────────
    // ✅ OLD SHAPE → data: [ {artist}, {artist} ]
    // (kept for backward compatibility)
    // ─────────────────────────────────────────────────────────────

    /* OLD CODE (replaced by robust parsing below)
    if (json['data'] != null) {
      data = <Artiest>[];
      json['data'].forEach((v) {
        data!.add(Artiest.fromJson(v));
      });
    }
    */

    if (payload is List) {
      model.data = payload
          .whereType<Map<String, dynamic>>()
          .map(Artiest.fromJson)
          .toList();
    } else {
      model.data = <Artiest>[];
    }

    return model;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> out = <String, dynamic>{};
    out['statusCode'] = statusCode;
    out['success'] = success;
    out['data'] = data?.map((v) => v.toJson()).toList();
    out['message'] = message;
    return out;
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
