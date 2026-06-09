import 'dart:convert';

class VendorStoreModel {
  final int? id;
  final int? userId;
  final String? name;
  final String? description;
  final int? countryId;
  City? city;
  State? state;
  final String? postalCode;
  final String? phone;
  final String? email;
  final String? website;
  final double? lat;
  final double? lang;
  final String? address;
  final String? instagram;
  final String? facebook;
  final String? whatsapp;
  final String? x;
  final String? youtube;
  final String? thumbnail;
  final List<String>? images;
  final String? createdAt;
  final String? updatedAt;
  final String? fax;
  final String? tax;
  final String? gst;
  final int? establishedYear;

  VendorStoreModel({
    this.id,
    this.userId,
    this.name,
    this.description,
    this.countryId,
    this.city,
    this.state,
    this.postalCode,
    this.phone,
    this.email,
    this.website,
    this.lat,
    this.lang,
    this.address,
    this.instagram,
    this.facebook,
    this.whatsapp,
    this.x,
    this.youtube,
    this.thumbnail,
    this.images,
    this.createdAt,
    this.updatedAt,
    this.fax,
    this.tax,
    this.gst,
    this.establishedYear,
  });

  factory VendorStoreModel.fromJson(Map<String, dynamic> json) {
    return VendorStoreModel(
      id: _parseInt(json['id']),
      userId: _parseInt(json['user_id']) ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      countryId: _parseInt(json['country']),
        city : json['city'] != null ? City.fromJson(json['city']) : null,
        state : json['state'] != null ? State.fromJson(json['state']) : null,
      postalCode: json['postal_code']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      website: json['website']?.toString(),
      lat: _parseDouble(json['lat']) ?? 0.0,
      lang: _parseDouble(json['lang']) ?? 0.0,
      address: json['address']?.toString() ?? '',
      instagram: json['instagram']?.toString(),
      facebook: json['facebook']?.toString(),
      whatsapp: json['whatsapp']?.toString(),
      x: json['x']?.toString(),
      youtube: json['youtube']?.toString(),
      thumbnail: json['thumbnail']?.toString(),
      images: json['image'] != null
          ? _parseImages(json['image'])
          : null,
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      fax: json['fax']?.toString(),
      tax: json['tax_number']?.toString(),
      gst: json['gst']?.toString(),
      establishedYear: _parseInt(json['estimate_date']),
    );
  }


  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is double) return value.toInt();
    return null;
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static List<String>? _parseImages(dynamic images) {
    if (images == null) return null;
    if (images is String) {
      try {

        final decoded = json.decode(images);
        if (decoded is List) {
          return decoded.map((e) => e.toString()).toList();
        }
      } catch (e) {

        return [images];
      }
    }
    if (images is List) {
      return images.map((e) => e.toString()).toList();
    }

    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'description': description,
      'country_id': countryId,
      'city': city,
      'state': state,
      'postal_code': postalCode,
      'phone': phone,
      'email': email,
      'website': website,
      'lat': lat,
      'lang': lang,
      'address': address,
      'instagram': instagram,
      'facebook': facebook,
      'whatsapp': whatsapp,
      'x': x,
      'youtube': youtube,
      'thumbnail': thumbnail,
      'images': images,
      'fax': fax,
      'tax_number': tax,
      'gst': gst,
      'estimate_date': establishedYear,
    };
  }

  String get fullAddress {
    return '$address, $city, $state - $postalCode';
  }

  String get locationCoordinates {
    return '$lat, $lang';
  }

  bool get hasImages {
    return images != null && images!.isNotEmpty;
  }

  bool get hasThumbnail {
    return thumbnail != null && thumbnail!.isNotEmpty;
  }

  List<String> get fullImageUrls {
    if (images == null) return [];
    return images!;
  }

  String? get fullThumbnailUrl {
    if (thumbnail == null) return null;
    return thumbnail;
  }
}

class City {
  int? id;
  int? stateId;
  String? cityName;
  int? status;
  String? createdAt;
  String? updatedAt;

  City(
      {this.id,
        this.stateId,
        this.cityName,
        this.status,
        this.createdAt,
        this.updatedAt});

  City.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    stateId = json['state_id'];
    cityName = json['city_name'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

}

class State {
  int? id;
  int? countryId;
  String? stateName;
  int? status;
  String? createdAt;
  String? updatedAt;

  State(
      {this.id,
        this.countryId,
        this.stateName,
        this.status,
        this.createdAt,
        this.updatedAt});

  State.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    countryId = json['country_id'];
    stateName = json['state_name'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }
}
// Request Model for creating store
class CreateStoreRequest {
  final int userId;
  final String name;
  final String description;
  final int? countryId;
  final int? stateId;
  final int? cityId;
  final String city;
  final String state;
  final String postalCode;
  final String phone;
  final String email;
  final String? website;
  final double lat;
  final double lang;
  final String address;
  final String? instagram;
  final String? facebook;
  final String? whatsapp;

  CreateStoreRequest({
    required this.userId,
    required this.name,
    required this.description,
    this.countryId,
    this.stateId,
    this.cityId,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.phone,
    required this.email,
    this.website,
    required this.lat,
    required this.lang,
    required this.address,
    this.instagram,
    this.facebook,
    this.whatsapp,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'description': description,
      'country_id': countryId,
      'state_id': stateId,
      'city_id': cityId,
      'city': city,
      'state': state,
      'postal_code': postalCode,
      'phone': phone,
      'email': email,
      'website': website,
      'lat': lat,
      'lang': lang,
      'address': address,
      'instagram': instagram,
      'facebook': facebook,
      'whatsapp': whatsapp,
    };
  }
}

// Response Model for API
class VendorStoreResponse {
  final int status;
  final String message;
  final VendorStoreModel? data;

  VendorStoreResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory VendorStoreResponse.fromJson(Map<String, dynamic> json) {
    return VendorStoreResponse(
      status: json['status'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? VendorStoreModel.fromJson(json['data'])
          : null,
    );
  }
}

// List Response Model
class VendorStoreListResponse {
  final int status;
  final String message;
  final List<VendorStoreModel> data;

  VendorStoreListResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory VendorStoreListResponse.fromJson(Map<String, dynamic> json) {
    return VendorStoreListResponse(
      status: json['status'] ?? 0,
      message: json['message'] ?? '',
      data: (json['data'] as List? ?? [])
          .map((item) => VendorStoreModel.fromJson(item))
          .toList(),
    );
  }
}

class CountryModel {
  final int id;
  final String countryName;
  final int status;
  final String createdAt;
  final String updatedAt;

  CountryModel({
    required this.id,
    required this.countryName,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    return CountryModel(
      id: json['id'] ?? 0,
      countryName: json['country_name'] ?? '',
      status: json['status'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'country_name': countryName,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  @override
  String toString() => countryName;
}

class StateModel {
  final int id;
  final int countryId;
  final String stateName;
  final int status;
  final String createdAt;
  final String updatedAt;

  StateModel({
    required this.id,
    required this.countryId,
    required this.stateName,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StateModel.fromJson(Map<String, dynamic> json) {
    return StateModel(
      id: json['id'] ?? 0,
      countryId: json['country_id'] ?? 0,
      stateName: json['state_name'] ?? '',
      status: json['status'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'country_id': countryId,
      'state_name': stateName,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  @override
  String toString() => stateName;
}

class CityModel {
  final int id;
  final int stateId;
  final String cityName;
  final int status;
  final String createdAt;
  final String updatedAt;

  CityModel({
    required this.id,
    required this.stateId,
    required this.cityName,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      id: json['id'] ?? 0,
      stateId: json['state_id'] ?? 0,
      cityName: json['city_name'] ?? '',
      status: json['status'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'state_id': stateId,
      'city_name': cityName,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  @override
  String toString() => cityName;
}

// Response Models for API
class CountryResponse {
  final int status;
  final String message;
  final List<CountryModel> data;

  CountryResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory CountryResponse.fromJson(Map<String, dynamic> json) {
    return CountryResponse(
      status: json['status'] ?? 0,
      message: json['message'] ?? '',
      data: (json['data'] as List? ?? [])
          .map((item) => CountryModel.fromJson(item))
          .toList(),
    );
  }
}

class StateResponse {
  final int status;
  final String message;
  final List<StateModel> data;

  StateResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory StateResponse.fromJson(Map<String, dynamic> json) {
    return StateResponse(
      status: json['status'] ?? 0,
      message: json['message'] ?? '',
      data: (json['data'] as List? ?? [])
          .map((item) => StateModel.fromJson(item))
          .toList(),
    );
  }
}

class CityResponse {
  final int status;
  final String message;
  final List<CityModel> data;

  CityResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory CityResponse.fromJson(Map<String, dynamic> json) {
    return CityResponse(
      status: json['status'] ?? 0,
      message: json['message'] ?? '',
      data: (json['data'] as List? ?? [])
          .map((item) => CityModel.fromJson(item))
          .toList(),
    );
  }
}


