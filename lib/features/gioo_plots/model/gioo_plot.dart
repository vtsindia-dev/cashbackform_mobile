class GiooPlot {
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
  final List<String> images;
  final String plotImage;
  final String work;
  final String? agentId;
  final int status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final PropertyType? propertyType;


  GiooPlot({
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

  factory GiooPlot.fromJson(Map<String, dynamic> json) {
    return GiooPlot(
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
      propertyType: json['property_type'] != null ? PropertyType.fromJson(json['property_type']) : null,
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
  String get formattedPrice => _formatNumber(price);
  String get formattedArea => '$area sq.ft';
  String get location => '${city?.cityName ?? ''}, ${state?.stateName ?? ''}'.trim();
  String get propertyTypeName => propertyType?.categoryName ?? 'Gioo Plot';

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

class PropertyType {
  final int id;
  final String categoryName;
  final int status;
  final DateTime createdAt;
  final DateTime updatedAt;

  PropertyType({
    required this.id,
    required this.categoryName,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PropertyType.fromJson(Map<String, dynamic> json) {
    return PropertyType(
      id: json['id'] as int,
      categoryName: json['category_name']?.toString() ?? '',
      status: json['status'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at']?.toString() ?? ''),
      updatedAt: DateTime.parse(json['updated_at']?.toString() ?? ''),
    );
  }
}
class City {
  final int id;
  final int stateId;
  final String cityName;
  final int status;
  final DateTime createdAt;
  final DateTime updatedAt;
  City({
    required this.id,
    required this.stateId,
    required this.cityName,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });
  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'] as int,
      stateId: json['state_id'] as int,
      cityName: json['city_name']?.toString() ?? '',
      status: json['status'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at']?.toString() ?? ''),
      updatedAt: DateTime.parse(json['updated_at']?.toString() ?? ''),
    );
  }
}
class GiooPlotDetail {
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
  final List<String> image;
  final String plotImage;
  final String work;
  final String agentId;
  final int status;
  final int featured;
  final String? aminities;
  final String? bluePrint;
  final String? totalPrice;
  final String uldNo;
  final int adminBlock;
  final AdminBlock? adminblock;
  final List<dynamic> user;
  final List<Amenity> amenity;
  final List<Document> documents;
  final List<Booking> bookings;
  final DateTime createdAt;
  final DateTime updatedAt;

  GiooPlotDetail({
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
    required this.image,
    required this.plotImage,
    required this.work,
    required this.agentId,
    required this.status,
    required this.featured,
    this.aminities,
    this.bluePrint,
    this.totalPrice,
    required this.uldNo,
    required this.adminBlock,
    this.adminblock,
    required this.user,
    required this.amenity,
    required this.documents,
    required this.bookings,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GiooPlotDetail.fromJson(Map<String, dynamic> json) {
    String safeString(dynamic value) => value?.toString() ?? '';
    int safeInt(dynamic value) => (value is int) ? value : int.tryParse(value.toString()) ?? 0;
    List<String> parseImages(dynamic images) {
      if (images == null) return [];
      if (images is List) {
        return images.map((e) => e.toString()).toList();
      }
      return [];
    }
    List<Amenity> parseAmenities(dynamic amenities) {
      if (amenities == null || amenities is! List) return [];
      return amenities.map((e) => Amenity.fromJson(e)).toList();
    }
    List<Booking> parseBookings(dynamic bookings) {
      if (bookings == null || bookings is! List) return [];
      return bookings.map((e) => Booking.fromJson(e)).toList();
    }
    List<Document> parseDocuments(dynamic documents) {
      if (documents == null || documents is! List) return [];
      return documents.map((e) => Document.fromJson(e)).toList();
    }
    List<dynamic> parseUser(dynamic users) {
      if (users == null || users is! List) return [];
      return users;
    }
    DateTime parseDateTime(dynamic dateTime) {
      if (dateTime == null) return DateTime.now();
      try {
        return DateTime.parse(dateTime.toString());
      } catch (e) {
        return DateTime.now();
      }
    }
    return GiooPlotDetail(
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
      image: parseImages(json['image']),
      plotImage: safeString(json['plot_image']),
      work: safeString(json['work']),
      agentId: safeString(json['agent_id']),
      status: safeInt(json['status']),
      featured: safeInt(json['featured'] ?? 0), // Added
      aminities: safeString(json['aminities']),
      bluePrint: safeString(json['blue_print']),
      totalPrice: safeString(json['total_price']),
      uldNo: safeString(json['uld_no']),
      adminBlock: safeInt(json['admin_block']), // Added
      adminblock: json['adminblock'] != null ? AdminBlock.fromJson(json['adminblock']) : null, // Added
      user: parseUser(json['user']), // Added
      amenity: parseAmenities(json['amenity']),
      bookings: parseBookings(json['booking']),
      documents: parseDocuments(json['documents']),
      createdAt: parseDateTime(json['created_at']),
      updatedAt: parseDateTime(json['updated_at']),
    );
  }
}
class AdminBlock {
  final String units;
  AdminBlock({
    required this.units,
  });
  factory AdminBlock.fromJson(Map<String, dynamic> json) {
    return AdminBlock(
      units: json['units'] as String? ?? '',
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

class Amenity {
  final int id;
  final String title;
  final String image;
  final String subtitle;
  final String distance;
  final String time;
  Amenity({
    required this.id,
    required this.title,
    required this.image,
    required this.subtitle,
    required this.distance,
    required this.time,
  });

  factory Amenity.fromJson(Map<String, dynamic> json) {
    return Amenity(
      id: json["id"] ?? 0,
      title: json["title"] ?? "",
      image: json["image"] ?? "",
      subtitle: json["subtitle"] ?? "",
      distance: json["distance"] ?? "",
      time: json["time"] ?? "",
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
