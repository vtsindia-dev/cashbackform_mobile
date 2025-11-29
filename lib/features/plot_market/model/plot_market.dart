class MarketPlot {
  final int id;
  final String name;
  final int? type;
  final String userId;
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
  final String? plotImage;
  final String work;
  final String? agentId;
  final int status;
  final int verifyStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final dynamic propertyType;

  MarketPlot({
    required this.id,
    required this.name,
    required this.type,
    required this.userId,
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
    required this.verifyStatus,
    required this.createdAt,
    required this.updatedAt,
    required this.propertyType,
  });

  factory MarketPlot.fromJson(Map<String, dynamic> json) {
    return MarketPlot(
      id: json['id'] as int,
      name: json['name']?.toString() ?? '',
      type: json['type'] as int?,
      userId: json['user_id']?.toString() ?? '',
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
      plotImage: json['plot_image']?.toString(),
      work: json['work']?.toString() ?? '',
      agentId: json['agent_id']?.toString(),
      status: json['status'] as int? ?? 0,
      verifyStatus: json['verify_status'] as int? ?? 0,
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
  String get formattedPrice => _formatNumber(price);
  String get formattedArea => '$area sq.ft';
  String get location => '${city?.cityName ?? ''}, ${state?.stateName ?? ''}'.trim();
  bool get isVerified => verifyStatus == 1;
  bool get hasPlotImage => plotImage != null && plotImage!.isNotEmpty;

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



class MarketPlotDetail {
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
  final String? plotImage;
  final String work;
  final String agentId;
  final int status;
  final int verifyStatus;
  final String uldNo;
  final String aminities;
  final List<Amenity> amenities;
  final List<Document> documents;
  final DateTime createdAt;
  final DateTime updatedAt;

  MarketPlotDetail({
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
    this.plotImage,
    required this.work,
    required this.agentId,
    required this.status,
    required this.verifyStatus,
    required this.uldNo,
    required this.aminities,
    required this.amenities,
    required this.documents,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MarketPlotDetail.fromJson(Map<String, dynamic> json) {
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

    // Parse datetime
    DateTime parseDateTime(dynamic dateTime) {
      if (dateTime == null) return DateTime.now();
      try {
        return DateTime.parse(dateTime.toString());
      } catch (e) {
        return DateTime.now();
      }
    }

    return MarketPlotDetail(
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
      verifyStatus: safeInt(json['verify_status']),
      uldNo: safeString(json['uld_no']),
      aminities: safeString(json['aminities']),
      amenities: parseAmenities(json['amenity']),
      documents: parseDocuments(json['documents']),
      createdAt: parseDateTime(json['created_at']),
      updatedAt: parseDateTime(json['updated_at']),
    );
  }

  // Helper method to check if property is verified
  bool get isVerified => verifyStatus == 1;

  // Helper method to get first image
  String? get firstImage => images.isNotEmpty ? images.first : null;

  // Helper method to get formatted price
  String get formattedPrice {
    try {
      final priceValue = double.tryParse(price);
      if (priceValue != null) {
        return '₹${priceValue.toStringAsFixed(2)}';
      }
      return '₹$price';
    } catch (e) {
      return '₹$price';
    }
  }

  // Helper method to get full address
  String get fullAddress {
    final parts = [address];
    if (city?.cityName != null) parts.add(city!.cityName!);
    if (state?.stateName != null) parts.add(state!.stateName!);
    return parts.where((part) => part.isNotEmpty).join(', ');
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
      doucType: json['douc_type'] as String? ?? 'Not Available',
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
