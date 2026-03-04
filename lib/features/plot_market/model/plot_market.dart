import 'package:intl/intl.dart'; // Add this import
import 'package:flutter/material.dart';
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
  final List<String> images;
  final String? plotImage;
  final String? bluePrint;
  final String? work;
  final String? agentId;
  final int status;
  final int verifyStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final PropertyType? propertyType;
  final int? verification;
  final String? uldNo;
  final String? priceperSqft;
  final List<int>? amenities;
  final List<Map<String, dynamic>>? nearbyPlaces;

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
    required this.images,
    required this.plotImage,
    this.bluePrint,
    required this.work,
    required this.agentId,
    required this.status,
    required this.verifyStatus,
    required this.createdAt,
    required this.updatedAt,
    required this.propertyType,
    this.verification,
    this.uldNo,
    this.priceperSqft,
    this.amenities,
    this.nearbyPlaces,
  });

  factory MarketPlot.fromJson(Map<String, dynamic> json) {
    // Parse amenities from string "6,15"
    List<int>? parseAmenities(String? amenitiesStr) {
      if (amenitiesStr == null || amenitiesStr.isEmpty) return null;
      try {
        return amenitiesStr.split(',').map((e) => int.tryParse(e.trim()) ?? 0).where((e) => e > 0).toList();
      } catch (e) {
        return null;
      }
    }

    // Parse nearby places
    List<Map<String, dynamic>>? parseNearbyPlaces(dynamic places) {
      if (places == null || places is! List) return null;
      return List<Map<String, dynamic>>.from(places);
    }

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
      images: _parseImages(json['image']),
      plotImage: json['plot_image']?.toString(),
      bluePrint: json['blue_print']?.toString(),
      work: json['work']?.toString(),
      agentId: json['agent_id']?.toString(),
      uldNo: json['uld_no']?.toString(),
      priceperSqft: json['price_sqft']?.toString(),
      status: json['status'] as int? ?? 0,
      verifyStatus: json['verify_status'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at']?.toString() ?? ''),
      updatedAt: DateTime.parse(json['updated_at']?.toString() ?? ''),
      propertyType: json['property_type'] != null
          ? PropertyType.fromJson(json['property_type'])
          : null,
      verification: _parseVerificationAmount(json['market_plot_amount']),
      amenities: parseAmenities(json['aminities']?.toString()),
      nearbyPlaces: parseNearbyPlaces(json['nearby_places']),
    );
  }

  static List<String> _parseImages(dynamic imageData) {
    if (imageData == null) return [];

    if (imageData is String) {
      return [imageData];
    } else if (imageData is List) {
      return imageData.map((item) => item?.toString() ?? '').where((item) => item.isNotEmpty).toList();
    }

    return [];
  }
  static int? _parseVerificationAmount(dynamic amount) {
    if (amount == null) return null;
    if (amount is int) return amount;
    if (amount is String) return int.tryParse(amount);
    if (amount is num) return amount.toInt();
    return null;
  }
  // Helper methods
  String get formattedPrice => _formatNumber(price);
  String get formattedArea => '$area sq.ft';
  String get location => '${city?.cityName ?? ''}, ${state?.stateName ?? ''}'.trim();
  bool get isVerified => verifyStatus == 1;
  bool get hasPlotImage => plotImage != null && plotImage!.isNotEmpty;

  String get firstImage => images.isNotEmpty ? images.first : '';

  String _formatNumber(String number) {
    try {
      final numValue = double.tryParse(number);
      if (numValue == null) return number;

      if (numValue >= 10000000) {
        return '₹${(numValue / 10000000).toStringAsFixed(1)}Cr';
      } else if (numValue >= 100000) {
        return '₹${(numValue / 100000).toStringAsFixed(1)}L';
      } else if (numValue >= 1000) {
        return '₹${(numValue / 1000).toStringAsFixed(1)}K';
      } else {
        return '₹$number';
      }
    } catch (e) {
      return '₹$number';
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
      id: json['id'] is int?
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      stateId: json['state_id'] is int?
          ? json['state_id']
          : int.tryParse(json['state_id']?.toString() ?? '') ?? 0,
      cityName: json['city_name']?.toString() ?? '',
      status: json['status'] is int?
          ? json['status']
          : int.tryParse(json['status']?.toString() ?? '') ?? 0,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}
class MarketPlotDetail {
  final int id;
  final String name;
  final int? type;
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
  final int unitSplit;
  final List<String> images;
  final String? plotImage;
  final String? bluePrint;
  final String? work;
  final String agentId;
  final int status;
  final int verifyStatus;
  final String? uldNo;
  final List<int>? amenities;
  final List<Amenity> amenityList;
  final List<Document> documents;
  final List<NearbyLocation> nearbyLocations;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double? marketPlotAmount;
  final bool documentVerified;
  List<CommonFacility>? commonFacility;
  int? plotCount;
  String? shareLink;
  String? threeDImage;

  MarketPlotDetail({
    required this.id,
    required this.name,
    this.type,
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
    required this.unitSplit,
    required this.images,
    this.plotImage,
    this.bluePrint,
    required this.work,
    required this.agentId,
    required this.status,
    required this.verifyStatus,
    this.uldNo,
    this.amenities,
    required this.amenityList,
    required this.documents,
    required this.nearbyLocations,
    required this.createdAt,
    required this.updatedAt,
    this.marketPlotAmount,
    required this.documentVerified,
    this.commonFacility,
    this.plotCount,
    this.shareLink,
    this.threeDImage
  });

  factory MarketPlotDetail.fromJson(Map<String, dynamic> json) {
    // Parse amenities from string "6,15"
    List<int>? parseAmenities(String? amenitiesStr) {
      if (amenitiesStr == null || amenitiesStr.isEmpty) return null;
      try {
        return amenitiesStr.split(',').map((e) => int.tryParse(e.trim()) ?? 0).where((e) => e > 0).toList();
      } catch (e) {
        return null;
      }
    }

    // Parse images
    List<String> parseImages(dynamic imageData) {
      if (imageData == null) return [];
      if (imageData is List) {
        return imageData.map((e) => e.toString()).toList();
      }
      return [];
    }

    // Parse amenity list
    List<Amenity> parseAmenityList(dynamic amenities) {
      if (amenities == null || amenities is! List) return [];
      return amenities.map((e) => Amenity.fromJson(e)).toList();
    }

    // Parse documents
    List<Document> parseDocuments(dynamic documents) {
      if (documents == null || documents is! List) return [];
      return documents.map((e) => Document.fromJson(e)).toList();
    }

    // Parse nearby locations
    List<NearbyLocation> parseNearbyLocations(dynamic locations) {
      if (locations == null || locations is! List) return [];
      return locations.map((e) => NearbyLocation.fromJson(e)).toList();
    }

    // Safely parse market plot amount (handle both string and number)
    double? parseMarketPlotAmount(dynamic amount) {
      if (amount == null) return null;
      if (amount is num) {
        return amount.toDouble();
      } else if (amount is String) {
        return double.tryParse(amount);
      }
      return null;
    }
    int safeInt(dynamic value, {int defaultValue = 0}) {
      if (value == null) return defaultValue;
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value.toString()) ?? defaultValue;
    }
    // Safely parse document verified
    bool parseDocumentVerified(dynamic verified) {
      if (verified == null) return false;
      if (verified is bool) return verified;
      if (verified is String) {
        return verified.toLowerCase() == 'true' || verified == '1';
      }
      if (verified is num) {
        return verified == 1;
      }
      return false;
    }

    return MarketPlotDetail(
      id: safeInt(json['id']),
      name: json['name']?.toString() ?? '',
      type: json['type'] != null ? safeInt(json['type']) : null,
      propertyType: json['property_type'] != null
          ? PropertyType.fromJson(json['property_type'])
          : null,
      map: json['map']?.toString(),
      address: json['address']?.toString() ?? '',
      lat: json['lat']?.toString() ?? '',
      long: json['long']?.toString() ?? '',
      city: json['city'] != null ? City.fromJson(json['city']) : null,
      state: json['state'] != null ? AppState.fromJson(json['state']) : null,
      area: json['area']?.toString() ?? '',
      price: json['price']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      unitSplit: safeInt(json['unit_spilt']),
      images: parseImages(json['image']),
      plotImage: json['plot_image']?.toString(),
      bluePrint: json['blue_print']?.toString(),
      work: json['work']?.toString() ?? '',
      agentId: json['agent_id']?.toString() ?? '',
      status: safeInt(json['status']),
      verifyStatus: safeInt(json['verify_status']),
      uldNo: json['uld_no']?.toString(),
      amenities: parseAmenities(json['aminities']?.toString()),
      amenityList: parseAmenityList(json['amenity']),
      documents: parseDocuments(json['documents']),
      nearbyLocations: parseNearbyLocations(json['nearby_locations']),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? '') ?? DateTime.now(),
      marketPlotAmount: parseMarketPlotAmount(json['market_plot_amount']),
      documentVerified: parseDocumentVerified(json['document_verified']),
        plotCount : json['plot_count'],
      threeDImage :  json['three_d_image'],
      shareLink : json['share'],
      commonFacility: json['commonfacility'] != null
          ? List<CommonFacility>.from(
        json['commonfacility'].map((v) => CommonFacility.fromJson(v)),
      )
          : [],

    );

  }

  bool get isVerified => verifyStatus == 1;
  String? get firstImage => images.isNotEmpty ? images.first : null;

  String get formattedPrice {
    try {
      final priceValue = double.tryParse(price);
      if (priceValue != null) {
        if (priceValue >= 10000000) {
          return '₹${(priceValue / 10000000).toStringAsFixed(1)}Cr';
        } else if (priceValue >= 100000) {
          return '₹${(priceValue / 100000).toStringAsFixed(1)}L';
        } else if (priceValue >= 1000) {
          return '₹${(priceValue / 1000).toStringAsFixed(1)}K';
        } else {
          return '₹${priceValue.toStringAsFixed(2)}';
        }
      }
      return '₹$price';
    } catch (e) {
      return '₹$price';
    }
  }

  String get fullAddress {
    final parts = [address];
    if (city?.cityName != null && city!.cityName.isNotEmpty) {
      parts.add(city!.cityName);
    }
    if (state?.stateName != null && state!.stateName.isNotEmpty) {
      parts.add(state!.stateName);
    }
    return parts.where((part) => part.isNotEmpty).join(', ');
  }

  String get pricePerSqft {
    try {
      final priceValue = double.tryParse(price);
      final areaValue = double.tryParse(area);
      if (priceValue != null && areaValue != null && areaValue > 0) {
        final perSqft = priceValue / areaValue;
        return '₹${perSqft.toStringAsFixed(2)} per sq.ft';
      }
      return '₹0 per sq.ft';
    } catch (e) {
      return '₹0 per sq.ft';
    }
  }
}
class Document {
  final int id;
  final int propertyId;
  final String file;
  final String type;
  final String? docType;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String downloadUrl;

  Document({
    required this.id,
    required this.propertyId,
    required this.file,
    required this.type,
    this.docType,
    required this.createdAt,
    required this.updatedAt,
    required this.downloadUrl,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'] is int?
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      propertyId: json['property_id'] is int?
          ? json['property_id']
          : int.tryParse(json['property_id']?.toString() ?? '') ?? 0,
      file: json['file']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      docType: json['douc_type']?.toString(),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? '') ?? DateTime.now(),
      downloadUrl: json['download_url']?.toString() ?? '',
    );
  }
}
class Amenity {
  final int id;
  final String title;
  final String image;
  final DateTime createdAt;
  final DateTime updatedAt;

  Amenity({
    required this.id,
    required this.title,
    required this.image,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Amenity.fromJson(Map<String, dynamic> json) {
    return Amenity(
      id: json['id'] is int?
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      title: json['title']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

class NearbyLocation {
  final int id;
  final String title;
  final String image;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Pivot? pivot;

  NearbyLocation({
    required this.id,
    required this.title,
    required this.image,
    required this.createdAt,
    required this.updatedAt,
    this.pivot,
  });

  factory NearbyLocation.fromJson(Map<String, dynamic> json) {
    return NearbyLocation(
      id: json['id'] is int?
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      title: json['title']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? '') ?? DateTime.now(),
      pivot: json['pivot'] != null ? Pivot.fromJson(json['pivot']) : null,
    );
  }
}
class Pivot {
  final int marketPropertyId;
  final int nearbyLocationId;
  final double distance;
  final DateTime createdAt;
  final DateTime updatedAt;

  Pivot({
    required this.marketPropertyId,
    required this.nearbyLocationId,
    required this.distance,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Pivot.fromJson(Map<String, dynamic> json) {
    // Helper method to safely parse distance
    double parseDistance(dynamic distance) {
      if (distance == null) return 0.0;
      if (distance is double) return distance;
      if (distance is int) return distance.toDouble();
      if (distance is num) return distance.toDouble();
      if (distance is String) {
        return double.tryParse(distance) ?? 0.0;
      }
      return 0.0;
    }

    return Pivot(
      marketPropertyId: json['market_property_id'] is int?
          ? json['market_property_id']
          : int.tryParse(json['market_property_id']?.toString() ?? '') ?? 0,
      nearbyLocationId: json['nearby_location_id'] is int?
          ? json['nearby_location_id']
          : int.tryParse(json['nearby_location_id']?.toString() ?? '') ?? 0,
      distance: parseDistance(json['distance']),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? '') ?? DateTime.now(),
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
      id: json['id'] is int?
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      stateName: json['state_name']?.toString() ?? '',
      status: json['status'] is int?
          ? json['status']
          : int.tryParse(json['status']?.toString() ?? '') ?? 0,
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
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
      id: json['id'] as int? ?? 0,
      categoryName: json['category_name'] as String? ?? '',
      status: json['status'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at']?.toString() ?? ''),
      updatedAt: DateTime.parse(json['updated_at']?.toString() ?? ''),
    );
  }
}

// Add these classes in your models section or at the top of the controller

class MarketPlotEnquiry {
  final int id;
  final int userId;
  final int? propertyId;
  final int counts;
  final DateTime createdAt;
  final DateTime updatedAt;
  final MarketPlotEnquiryProperty? property;

  MarketPlotEnquiry({
    required this.id,
    required this.userId,
    required this.propertyId,
    required this.counts,
    required this.createdAt,
    required this.updatedAt,
    this.property,
  });

  factory MarketPlotEnquiry.fromJson(Map<String, dynamic> json) {
    return MarketPlotEnquiry(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      propertyId: json['property_id'],
      counts: json['counts'] ?? 1,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toString()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toString()),
      property: json['property'] != null
          ? MarketPlotEnquiryProperty.fromJson(json['property'])
          : null,
    );
  }

  String get formattedDate {
    return DateFormat('dd MMM yyyy').format(createdAt);
  }

  String get formattedTime {
    return DateFormat('hh:mm a').format(createdAt);
  }

  String get enquiryStatus {
    if (counts >= 5) return "High Priority";
    if (counts >= 3) return "Active";
    return "New";
  }

  Color get statusColor {
    if (counts >= 5) return Colors.green;
    if (counts >= 3) return Colors.orange;
    return Colors.blue;
  }
}

class MarketPlotEnquiryProperty {
  final int id;
  final String name;
  final int? type;
  final String? lat;
  final String? long;
  final String address;
  final int? cityId;
  final int? stateId;
  final String? area;
  final String? price;
  final String? description;
  final List<String> images;
  final String? plotImage;
  final int? unitSplit;

  MarketPlotEnquiryProperty({
    required this.id,
    required this.name,
    this.type,
    this.lat,
    this.long,
    required this.address,
    this.cityId,
    this.stateId,
    this.area,
    this.price,
    this.description,
    required this.images,
    this.plotImage,
    this.unitSplit,
  });

  factory MarketPlotEnquiryProperty.fromJson(Map<String, dynamic> json) {
    // Parse images list
    List<String> images = [];
    if (json['image'] is List) {
      for (var image in json['image']) {
        if (image is String) {
          images.add(image);
        }
      }
    }


    return MarketPlotEnquiryProperty(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unnamed Property',
      type: json['type'],
      lat: json['lat']?.toString(),
      long: json['long']?.toString(),
      address: json['address'] ?? 'Address not available',
      cityId: _parseInt(json['city']),
      stateId: _parseInt(json['state']),
      area: json['area']?.toString(),
      price: json['price']?.toString(),
      description: json['description'],
      images: images,
      plotImage: json['plot_image']?.toString(),
      unitSplit: _parseInt(json['unit_spilt'] ?? json['unit_split']),
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) {
      try {
        return int.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  String get formattedPrice {
    try {
      if (price == null || price!.isEmpty) return 'Price not set';
      final amount = double.parse(price!);
      if (amount >= 10000000) {
        return '₹${(amount / 10000000).toStringAsFixed(2)} Cr';
      } else if (amount >= 100000) {
        return '₹${(amount / 100000).toStringAsFixed(2)} L';
      } else {
        return '₹${amount.toStringAsFixed(0)}';
      }
    } catch (e) {
      return '₹$price';
    }
  }

  String get formattedArea {
    if (area == null || area!.isEmpty) return 'Area not set';
    return '$area Sq.ft';
  }

  String get thumbnail {
    return images.isNotEmpty ? images.first : 'https://via.placeholder.com/150';
  }

  bool get hasProperty => id > 0;
}

class CommonFacility {
  int? id;
  String? title;
  String? image;
  String? createdAt;
  String? updatedAt;

  CommonFacility(
      {this.id, this.title, this.image, this.createdAt, this.updatedAt});

  CommonFacility.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    image = json['image'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }
}