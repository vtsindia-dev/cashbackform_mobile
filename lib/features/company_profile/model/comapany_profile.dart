class VendorStoreModel {
  final int? id;
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
  final String? thumbnail;
  final List<String>? images;
  final String? createdAt;
  final String? updatedAt;

  VendorStoreModel({
    this.id,
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
    this.thumbnail,
    this.images,
    this.createdAt,
    this.updatedAt,
  });

  factory VendorStoreModel.fromJson(Map<String, dynamic> json) {
    return VendorStoreModel(
      id: json['id'],
      userId: json['user_id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      countryId: json['country_id'],
      stateId: json['state_id'],
      cityId: json['city_id'],
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      postalCode: json['postal_code'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      website: json['website'],
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lang: (json['lang'] as num?)?.toDouble() ?? 0.0,
      address: json['address'] ?? '',
      instagram: json['instagram'],
      facebook: json['facebook'],
      whatsapp: json['whatsapp'],
      thumbnail: json['thumbnail'],
      images: json['images'] != null
          ? List<String>.from(json['images'])
          : null,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
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
      'thumbnail': thumbnail,
      'images': images,
    };
  }

  // Computed properties
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

  // Get full image URLs with base URL if needed
  List<String> get fullImageUrls {
    if (images == null) return [];
    // Add base URL if your API returns relative paths
    // return images!.map((path) => 'https://your-base-url.com/$path').toList();
    return images!;
  }

  String? get fullThumbnailUrl {
    if (thumbnail == null) return null;
    // Add base URL if your API returns relative paths
    // return 'https://your-base-url.com/$thumbnail';
    return thumbnail;
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


