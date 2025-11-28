class SyndicatePlot {
  final int id;
  final String name;
  final int? type;
  final String? map;
  final String address;
  final String lat;
  final String long;
  final City? city;
  final AppState? state;
  final String area;
  final String price;
  final String description;
  final int unitSplit;
  final List<String> images; // Changed from String to List<String>
  final String plotImage;
  final String work;
  final String? agentId;
  final int status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final dynamic propertyType;

  SyndicatePlot({
    required this.id,
    required this.name,
    required this.type,
    required this.map,
    required this.address,
    required this.lat,
    required this.long,
    required this.city,
    required this.state,
    required this.area,
    required this.price,
    required this.description,
    required this.unitSplit,
    required this.images, // Changed from image to images
    required this.plotImage,
    required this.work,
    required this.agentId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.propertyType,
  });

  factory SyndicatePlot.fromJson(Map<String, dynamic> json) {
    return SyndicatePlot(
      id: json['id'] as int,
      name: json['name']?.toString() ?? '',
      type: json['type'] as int?,
      map: json['map']?.toString(),
      address: json['address']?.toString() ?? '',
      lat: json['lat']?.toString() ?? '',
      long: json['long']?.toString() ?? '',
      city: json['city'] != null ? City.fromJson(json['city']) : null,
      state: json['state'] != null ? AppState.fromJson(json['state']) : null,
      area: json['area']?.toString() ?? '',
      price: json['price']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      unitSplit: json['unit_spilt'] as int? ?? 0,
      images: _parseImages(json['image']), // Updated to handle list
      plotImage: json['plot_image']?.toString() ?? '',
      work: json['work']?.toString() ?? '',
      agentId: json['agent_id']?.toString(),
      status: json['status'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at']?.toString() ?? ''),
      updatedAt: DateTime.parse(json['updated_at']?.toString() ?? ''),
      propertyType: json['property_type'],
    );
  }

  // Helper method to parse images
  static List<String> _parseImages(dynamic imageData) {
    if (imageData == null) return [];

    if (imageData is String) {
      return [imageData];
    } else if (imageData is List) {
      return imageData.map((item) => item?.toString() ?? '').where((item) => item.isNotEmpty).toList();
    }

    return [];
  }

  // Helper methods
  String get formattedPrice => '${_formatNumber(price)}';
  String get formattedArea => '$area sq.ft';
  String get location => '${city?.cityName ?? ''}, ${state?.stateName ?? ''}'.trim();

  // Get first image for thumbnail (backward compatibility)
  String get firstImage => images.isNotEmpty ? images.first : '';

  // Get all images
  List<String> get allImages => images;

  String _formatNumber(String number) {
    try {
      final numValue = double.tryParse(number);
      if (numValue == null) return number;

      if (numValue >= 100000) {
        return '${(numValue / 100000).toStringAsFixed(1)}L';
      } else if (numValue >= 1000) {
        return '${(numValue / 1000).toStringAsFixed(1)}K';
      } else {
        return number;
      }
    } catch (e) {
      return number;
    }
  }
}
class City {
  final int id;
  final int stateId;
  final String cityName;
  final int status;
  final String? createdAt;
  final String? updatedAt;

  City({
    required this.id,
    required this.stateId,
    required this.cityName,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'] as int? ?? 0,
      stateId: json['state_id'] as int? ?? 0,
      cityName: json['city_name'] as String? ?? '',
      status: json['status'] as int? ?? 0,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }
}

class AppState {
  final int id;
  final String stateName;
  final int status;
  final String? createdAt;
  final String? updatedAt;

  AppState({
    required this.id,
    required this.stateName,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory AppState.fromJson(Map<String, dynamic> json) {
    return AppState(
      id: json['id'] as int? ?? 0,
      stateName: json['state_name'] as String? ?? '',
      status: json['status'] as int? ?? 0,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }
}


class SyndicateDetail {
  final int id;
  final String name;
  final PropertyType? propertyType;
  final String? map;
  final String address;
  final String lat;
  final String long;
  final City? city;
  final AppState? state;
  final String area;
  final String price;
  final String description;
  final int unitSpilt;
  final List<String> images;
  final String plotImage;
  final String work;
  final String agentId;
  final int status;
  final String aminities;
  final String uldNo;
  final String startingPrice;
  final List<Amenity> amenities;
  final List<Document> documents;
  final List<Booking> bookings;
  final List<User> users; // Added user field

  SyndicateDetail({
    required this.id,
    required this.name,
    this.propertyType,
    this.map,
    required this.address,
    required this.lat,
    required this.long,
    this.city,
    this.state,
    required this.area,
    required this.price,
    required this.description,
    required this.unitSpilt,
    required this.images,
    required this.plotImage,
    required this.work,
    required this.agentId,
    required this.status,
    required this.aminities,
    required this.uldNo,
    required this.startingPrice,
    required this.amenities,
    required this.documents,
    required this.bookings,
    required this.users, // Added user field
  });

  factory SyndicateDetail.fromJson(Map<String, dynamic> json) {
    // Helper functions for safe parsing
    String safeString(dynamic value) => value?.toString() ?? '';
    int safeInt(dynamic value) => (value is int) ? value : int.tryParse(value.toString()) ?? 0;
    double safeDouble(dynamic value) => (value is double) ? value : double.tryParse(value.toString()) ?? 0.0;

    // Parse images
    List<String> parseImages(dynamic images) {
      if (images == null) return [];
      if (images is List) {
        return images.map((e) => e.toString()).toList();
      }
      return [];
    }

    // Parse amenities
    List<Amenity> parseAmenities(dynamic amenities) {
      if (amenities == null || amenities is! List) return [];
      return amenities.map((e) => Amenity.fromJson(e)).toList();
    }

    // Parse documents
    List<Document> parseDocuments(dynamic documents) {
      if (documents == null || documents is! List) return [];
      return documents.map((e) => Document.fromJson(e)).toList();
    }

    // Parse bookings
    List<Booking> parseBookings(dynamic bookings) {
      if (bookings == null || bookings is! List) return [];
      return bookings.map((e) => Booking.fromJson(e)).toList();
    }

    // Parse users - Added this function
    List<User> parseUsers(dynamic users) {
      if (users == null || users is! List) return [];
      return users.map((e) => User.fromJson(e)).toList();
    }

    return SyndicateDetail(
      id: safeInt(json['id']),
      name: safeString(json['name']),
      propertyType: json['property_type'] != null ? PropertyType.fromJson(json['property_type']) : null,
      map: safeString(json['map']),
      address: safeString(json['address']),
      lat: safeString(json['lat']),
      long: safeString(json['long']),
      city: json['city'] != null ? City.fromJson(json['city']) : null,
      state: json['state'] != null ? AppState.fromJson(json['state']) : null,
      area: safeString(json['area']),
      price: safeString(json['price']),
      description: safeString(json['description']),
      unitSpilt: safeInt(json['unit_spilt']),
      images: parseImages(json['image']),
      plotImage: safeString(json['plot_image']),
      work: safeString(json['work']),
      agentId: safeString(json['agent_id']),
      status: safeInt(json['status']),
      aminities: safeString(json['aminities']),
      uldNo: safeString(json['uld_no']),
      startingPrice: safeString(json['starting_price']),
      amenities: parseAmenities(json['amenity']),
      documents: parseDocuments(json['documents']),
      bookings: parseBookings(json['booking']),
      users: parseUsers(json['user']), // Added user parsing
    );
  }
}

// Add the User class
class User {
  final int id;
  final int role;
  final String name;
  final String email;
  final String? emailVerifiedAt;
  final String dob;
  final String avatar;
  final String pin;
  final int gender;
  final String address;
  final String phone;
  final int status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? fcmToken;

  User({
    required this.id,
    required this.role,
    required this.name,
    required this.email,
    this.emailVerifiedAt,
    required this.dob,
    required this.avatar,
    required this.pin,
    required this.gender,
    required this.address,
    required this.phone,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.fcmToken,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int? ?? 0,
      role: json['role'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      emailVerifiedAt: json['email_verified_at'] as String?,
      dob: json['dob'] as String? ?? '',
      avatar: json['avatar'] as String? ?? '',
      pin: json['pin'] as String? ?? '',
      gender: json['gender'] as int? ?? 0,
      address: json['address'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      status: json['status'] as int? ?? 0,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
      fcmToken: json['fcm_token'] as String?,
    );
  }

  String get genderString {
    switch (gender) {
      case 1:
        return 'Male';
      case 2:
        return 'Female';
      case 3:
        return 'Other';
      default:
        return 'Unknown';
    }
  }

  String get roleString {
    switch (role) {
      case 1:
        return 'Admin';
      case 2:
        return 'User';
      case 3:
        return 'Agent';
      default:
        return 'Unknown';
    }
  }
}
class PropertyType {
  final int id;
  final String categoryName;
  final int status;

  PropertyType({
    required this.id,
    required this.categoryName,
    required this.status,
  });

  factory PropertyType.fromJson(Map<String, dynamic> json) {
    return PropertyType(
      id: json['id'] as int? ?? 0,
      categoryName: json['category_name'] as String? ?? '',
      status: json['status'] as int? ?? 0,
    );
  }
}

class Amenity {
  final int id;
  final String title;
  final String image;

  Amenity({
    required this.id,
    required this.title,
    required this.image,
  });

  factory Amenity.fromJson(Map<String, dynamic> json) {
    return Amenity(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      image: json['image'] as String? ?? '',
    );
  }
}

class Document {
  final int id;
  final int propertyId;
  final String file;
  final String type;
  final String doucType;

  Document({
    required this.id,
    required this.propertyId,
    required this.file,
    required this.type,
    required this.doucType,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'] as int? ?? 0,
      propertyId: json['property_id'] as int? ?? 0,
      file: json['file'] as String? ?? '',
      type: json['type'] as String? ?? '',
      doucType: json['douc_type'] as String? ?? '',
    );
  }
}

class Booking {
  final int id;
  final int propertyId;
  final int userId;
  final String units;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Booking({
    required this.id,
    required this.propertyId,
    required this.userId,
    required this.units,
    this.createdAt,
    this.updatedAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as int? ?? 0,
      propertyId: json['property_id'] as int? ?? 0,
      userId: json['user_id'] as int? ?? 0,
      units: json['units'] as String? ?? '',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
    );
  }
}



