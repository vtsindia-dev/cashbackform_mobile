import 'dart:convert';

import 'package:intl/intl.dart';
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
  int? plotCount;
  String? threeDImage;
  final bool documentVerification;
  final String? youtubeLink;
  final List<String> commonFacilityIds;
  final int? soldStatus;

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
    this.plotCount,
    this.threeDImage,
    this.youtubeLink,
    this.soldStatus,
    required this.documentVerification,
    this.commonFacilityIds = const [],
  });

  factory MarketPlot.fromJson(Map<String, dynamic> json) {
    List<int>? parseAmenities(String? amenitiesStr) {
      if (amenitiesStr == null || amenitiesStr.isEmpty) return null;
      try {
        if (amenitiesStr.startsWith('[')) {
          final list = jsonDecode(amenitiesStr) as List;
          return list
              .map((e) => int.tryParse(e.toString()) ?? 0)
              .where((e) => e > 0)
              .toList();
        } else {
          return amenitiesStr
              .split(',')
              .map((e) => int.tryParse(e.trim()) ?? 0)
              .where((e) => e > 0)
              .toList();
        }
      } catch (e) {
        return null;
      }
    }

    List<Map<String, dynamic>>? parseNearbyPlaces(dynamic places) {
      if (places == null || places is! List) return null;
      return List<Map<String, dynamic>>.from(places);
    }

    bool parseDocumentVerification(dynamic value) {
      if (value == null) return false;
      if (value is bool) return value;
      if (value is int) return value == 1;
      if (value is String) {
        return value.toLowerCase() == 'true' || value == '1';
      }
      return false;
    }

    // ── FIX: parse commonfacility list (comes as ["17","16","15"]) ──
    List<String> parseCommonFacilityIds(dynamic raw) {
      if (raw == null) return [];
      if (raw is List) {
        return raw.map((e) => e.toString()).toList();
      }
      if (raw is String && raw.isNotEmpty) {
        // fallback: comma-separated string
        return raw.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      }
      return [];
    }

    return MarketPlot(
      id: json['id'] as int,
      name: json['name']?.toString() ?? '',
      type: json['type'] != null
          ? (json['type'] is int
          ? json['type'] as int
          : int.tryParse(json['type'].toString()))
          : null,
      userId: json['user_id']?.toString() ?? '',
      map: json['map']?.toString(),
      address: json['address']?.toString() ?? '',
      lat: json['lat']?.toString() ?? '',
      long: json['long']?.toString() ?? '',
      city: json['city'] != null && json['city'] is Map
          ? City.fromJson(json['city'])
          : null,
      state: json['state'] != null && json['state'] is Map
          ? AppState.fromJson(json['state'])
          : null,
      area: json['area']?.toString() ?? '',
      price: json['price']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      unitSplit: json['unit_spilt'] != null
          ? (json['unit_spilt'] is int
          ? json['unit_spilt'] as int
          : int.tryParse(json['unit_spilt'].toString()) ?? 0)
          : 0,
      images: _parseImages(json['image']),
      plotImage: json['plot_image']?.toString(),
      bluePrint: json['blue_print']?.toString(),
      work: json['work']?.toString(),
        soldStatus : json['sold_status'],
      agentId: json['agent_id']?.toString(),
      uldNo: json['uld_no']?.toString(),
        youtubeLink :  json['youtube_link']?.toString(),
      priceperSqft: json['price_sqft']?.toString(),
      status: json['status'] != null
          ? (json['status'] is int
          ? json['status'] as int
          : int.tryParse(json['status'].toString()) ?? 0)
          : 0,
      verifyStatus: json['verify_status'] != null
          ? (json['verify_status'] is int
          ? json['verify_status'] as int
          : int.tryParse(json['verify_status'].toString()) ?? 0)
          : 0,
      createdAt: DateTime.tryParse(
          json['created_at']?.toString() ?? '')?.toLocal() ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(
          json['updated_at']?.toString() ?? '')?.toLocal() ??
          DateTime.now(),
      threeDImage: json['three_d_image']?.toString(),
      propertyType: json['property_type'] != null && json['property_type'] is Map
          ? PropertyType.fromJson(json['property_type'])
          : null,
      verification: _parseVerificationAmount(json['market_plot_amount']),
      amenities: parseAmenities(json['aminities']?.toString()),
      nearbyPlaces: parseNearbyPlaces(json['nearby_places']),
      plotCount: json['plot_count'] != null
          ? (json['plot_count'] is int
          ? json['plot_count'] as int
          : int.tryParse(json['plot_count'].toString()))
          : null,
      documentVerification:
      parseDocumentVerification(json['doucment_verficaiton']),
      commonFacilityIds: parseCommonFacilityIds(json['commonfacility']),
    );
  }

  static List<String> _parseImages(dynamic imageData) {
    if (imageData == null) return [];
    if (imageData is String) return [imageData];
    if (imageData is List) {
      return imageData
          .map((item) => item?.toString() ?? '')
          .where((item) => item.isNotEmpty)
          .toList();
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

  String get formattedPrice => _formatNumber(price);
  String get formattedArea => '$area sq.ft';
  String get location =>
      '${city?.cityName ?? ''}, ${state?.stateName ?? ''}'.trim();

  bool get isVerified => verifyStatus == 1;
  bool get hasPlotImage => plotImage != null && plotImage!.isNotEmpty;
  String get firstImage => images.isNotEmpty ? images.first : '';

  String get verificationStatusText =>
      documentVerification ? 'Paid' : 'Verify Land';

  Color get verificationStatusColor =>
      documentVerification ? Colors.green : Colors.orange;

  IconData get verificationStatusIcon =>
      documentVerification ? Icons.paid : Icons.verified_outlined;

  String get verifyBadgeText =>
      verifyStatus == 1 ? 'Verified ✓' : 'Not Verified';

  Color get verifyBadgeColor =>
      verifyStatus == 1 ? Colors.green : Colors.grey;

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

// ─────────────────────────────────────────────────────────────────────────────
// City
// ─────────────────────────────────────────────────────────────────────────────

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
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      stateId: json['state_id'] is int
          ? json['state_id']
          : int.tryParse(json['state_id']?.toString() ?? '') ?? 0,
      cityName: json['city_name']?.toString() ?? '',
      status: json['status'] is int
          ? json['status']
          : int.tryParse(json['status']?.toString() ?? '') ?? 0,
      createdAt:
      DateTime.tryParse(json['created_at']?.toString() ?? '')?.toLocal() ??
          DateTime.now(),
      updatedAt:
      DateTime.tryParse(json['updated_at']?.toString() ?? '')?.toLocal() ??
          DateTime.now(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MarketPlotDetail
// ─────────────────────────────────────────────────────────────────────────────

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
  final int? soldout;
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
  final List<CommonFacility>? commonFacility;
  final int? plotCount;
  final String? shareLink;
  final String? threeDImage;
  final List<MapSet>? mapSet;
  final String? youtubeLink;

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
    this.soldout,
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
    this.threeDImage,
    this.mapSet,
    this.youtubeLink
  });

  factory MarketPlotDetail.fromJson(Map<String, dynamic> json) {
    List<int>? parseAmenities(String? amenitiesStr) {
      if (amenitiesStr == null || amenitiesStr.isEmpty) return null;
      try {
        return amenitiesStr
            .split(',')
            .map((e) => int.tryParse(e.trim()) ?? 0)
            .where((e) => e > 0)
            .toList();
      } catch (e) {
        return null;
      }
    }

    List<String> parseImages(dynamic imageData) {
      if (imageData == null) return [];
      if (imageData is List) {
        return imageData.map((e) => e.toString()).toList();
      }
      return [];
    }

    List<Amenity> parseAmenityList(dynamic amenities) {
      if (amenities == null || amenities is! List) return [];
      return amenities.map((e) => Amenity.fromJson(e)).toList();
    }

    List<Document> parseDocuments(dynamic documents) {
      if (documents == null || documents is! List) return [];
      return documents.map((e) => Document.fromJson(e)).toList();
    }

    List<NearbyLocation> parseNearbyLocations(dynamic locations) {
      if (locations == null || locations is! List) return [];
      return locations.map((e) => NearbyLocation.fromJson(e)).toList();
    }

    List<MapSet> parseMapSet(dynamic mapSetData) {
      if (mapSetData == null || mapSetData is! List) return [];
      return mapSetData.map((e) => MapSet.fromJson(e)).toList();
    }

    double? parseMarketPlotAmount(dynamic amount) {
      if (amount == null) return null;
      if (amount is num) return amount.toDouble();
      if (amount is String) return double.tryParse(amount);
      return null;
    }

    int safeInt(dynamic value, {int defaultValue = 0}) {
      if (value == null) return defaultValue;
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value.toString()) ?? defaultValue;
    }

    bool parseDocumentVerified(dynamic verified) {
      if (verified == null) return false;
      if (verified is bool) return verified;
      if (verified is String) {
        return verified.toLowerCase() == 'true' || verified == '1';
      }
      if (verified is num) return verified == 1;
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
      city: json['city'] != null && json['city'] is Map
          ? City.fromJson(json['city'])
          : null,
      state: json['state'] != null && json['state'] is Map
          ? AppState.fromJson(json['state'])
          : null,
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
      soldout: safeInt(json['sold_status']),
      verifyStatus: safeInt(json['verify_status']),
      uldNo: json['uld_no']?.toString(),
      amenities: parseAmenities(json['aminities']?.toString()),
      amenityList: parseAmenityList(json['amenity']),
      documents: parseDocuments(json['documents']),
      nearbyLocations: parseNearbyLocations(json['nearby_locations']),
      createdAt:
      DateTime.tryParse(json['created_at']?.toString() ?? '')?.toLocal() ??
          DateTime.now(),
      updatedAt:
      DateTime.tryParse(json['updated_at']?.toString() ?? '')?.toLocal() ??
          DateTime.now(),
      marketPlotAmount: parseMarketPlotAmount(json['market_plot_amount']),
      documentVerified: parseDocumentVerified(json['document_verified']),
      plotCount: json['plot_count'] != null
          ? (json['plot_count'] is int
          ? json['plot_count'] as int
          : int.tryParse(json['plot_count'].toString()))
          : null,
      threeDImage: json['three_d_image']?.toString(),
      shareLink: json['share']?.toString(),
      commonFacility: json['commonfacility'] != null
          ? List<CommonFacility>.from(
          json['commonfacility'].map((v) => CommonFacility.fromJson(v)))
          : [],
      mapSet: parseMapSet(json['map_set']),
        youtubeLink : json['youtube_link']
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
        return '₹${perSqft.toStringAsFixed(2)}';
      }
      return '₹0';
    } catch (e) {
      return '₹0';
    }
  }

  String get pricePerSqftWithUnit {
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

  String get verifyStatusText {
    switch (verifyStatus) {
      case 0:
        return 'Pending';
      case 1:
        return 'Verified ✓';
      case 2:
        return 'Rejected';
      case 3:
        return 'Under Review';
      default:
        return 'Not Defined';
    }
  }

  Color get verifyStatusColor {
    switch (verifyStatus) {
      case 0:
        return Colors.orange;
      case 1:
        return Colors.green;
      case 2:
        return Colors.red;
      case 3:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String get formattedCreatedDate =>
      DateFormat('dd/MM/yyyy').format(createdAt.toLocal());
  String get formattedUpdatedDate =>
      DateFormat('dd/MM/yyyy').format(updatedAt.toLocal());
}

// ─────────────────────────────────────────────────────────────────────────────
// MapSet
// ─────────────────────────────────────────────────────────────────────────────

class MapSet {
  final int id;
  final String name;
  final String lat;
  final String long;
  final List<String> image;
  final String distance;

  MapSet({
    required this.id,
    required this.name,
    required this.lat,
    required this.long,
    required this.image,
    required this.distance,
  });

  factory MapSet.fromJson(Map<String, dynamic> json) {
    List<String> parseImages(dynamic imageData) {
      if (imageData == null) return [];
      if (imageData is List) {
        return imageData.map((e) => e.toString()).toList();
      }
      return [];
    }

    return MapSet(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      lat: json['lat']?.toString() ?? '',
      long: json['long']?.toString() ?? '',
      image: parseImages(json['image']),
      distance: json['distance']?.toString() ?? '0 KM',
    );
  }

  String get firstImage => image.isNotEmpty ? image.first : '';
  double get distanceValue {
    try {
      return double.tryParse(distance.replaceAll(' KM', '')) ?? 0.0;
    } catch (e) {
      return 0.0;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Document
// ─────────────────────────────────────────────────────────────────────────────

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
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      propertyId: json['property_id'] is int
          ? json['property_id']
          : int.tryParse(json['property_id']?.toString() ?? '') ?? 0,
      file: json['file']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      docType: json['douc_type']?.toString(),
      createdAt:
      DateTime.tryParse(json['created_at']?.toString() ?? '')?.toLocal() ??
          DateTime.now(),
      updatedAt:
      DateTime.tryParse(json['updated_at']?.toString() ?? '')?.toLocal() ??
          DateTime.now(),
      downloadUrl: json['download_url']?.toString() ?? '',
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Amenity
// ─────────────────────────────────────────────────────────────────────────────

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
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      title: json['title']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      createdAt:
      DateTime.tryParse(json['created_at']?.toString() ?? '')?.toLocal() ??
          DateTime.now(),
      updatedAt:
      DateTime.tryParse(json['updated_at']?.toString() ?? '')?.toLocal() ??
          DateTime.now(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NearbyLocation
// ─────────────────────────────────────────────────────────────────────────────

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
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      title: json['title']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      createdAt:
      DateTime.tryParse(json['created_at']?.toString() ?? '')?.toLocal() ??
          DateTime.now(),
      updatedAt:
      DateTime.tryParse(json['updated_at']?.toString() ?? '')?.toLocal() ??
          DateTime.now(),
      pivot: json['pivot'] != null ? Pivot.fromJson(json['pivot']) : null,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Pivot
// ─────────────────────────────────────────────────────────────────────────────

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
    double parseDistance(dynamic distance) {
      if (distance == null) return 0.0;
      if (distance is double) return distance;
      if (distance is int) return distance.toDouble();
      if (distance is num) return distance.toDouble();
      if (distance is String) return double.tryParse(distance) ?? 0.0;
      return 0.0;
    }

    return Pivot(
      marketPropertyId: json['market_property_id'] is int
          ? json['market_property_id']
          : int.tryParse(json['market_property_id']?.toString() ?? '') ?? 0,
      nearbyLocationId: json['nearby_location_id'] is int
          ? json['nearby_location_id']
          : int.tryParse(json['nearby_location_id']?.toString() ?? '') ?? 0,
      distance: parseDistance(json['distance']),
      createdAt:
      DateTime.tryParse(json['created_at']?.toString() ?? '')?.toLocal() ??
          DateTime.now(),
      updatedAt:
      DateTime.tryParse(json['updated_at']?.toString() ?? '')?.toLocal() ??
          DateTime.now(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AppState
// ─────────────────────────────────────────────────────────────────────────────

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
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      stateName: json['state_name']?.toString() ?? '',
      status: json['status'] is int
          ? json['status']
          : int.tryParse(json['status']?.toString() ?? '') ?? 0,
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PropertyType
// ─────────────────────────────────────────────────────────────────────────────

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
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      categoryName: json['category_name']?.toString() ?? '',
      status: json['status'] is int
          ? json['status']
          : int.tryParse(json['status']?.toString() ?? '') ?? 0,
      createdAt:
      DateTime.tryParse(json['created_at']?.toString() ?? '')?.toLocal() ??
          DateTime.now(),
      updatedAt:
      DateTime.tryParse(json['updated_at']?.toString() ?? '')?.toLocal() ??
          DateTime.now(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MarketPlotEnquiry
// ─────────────────────────────────────────────────────────────────────────────

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
      createdAt: DateTime.tryParse(
          json['created_at']?.toString() ?? '')?.toLocal() ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(
          json['updated_at']?.toString() ?? '')?.toLocal() ??
          DateTime.now(),
      property: json['property'] != null
          ? MarketPlotEnquiryProperty.fromJson(json['property'])
          : null,
    );
  }

  String get formattedDate => DateFormat('dd MMM yyyy').format(createdAt.toLocal());
  String get formattedTime => DateFormat('hh:mm a').format(createdAt.toLocal());
  String get enquiryStatus {
    if (counts >= 5) return 'High Priority';
    if (counts >= 3) return 'Active';
    return 'New';
  }

  Color get statusColor {
    if (counts >= 5) return Colors.green;
    if (counts >= 3) return Colors.orange;
    return Colors.blue;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MarketPlotEnquiryProperty
// ─────────────────────────────────────────────────────────────────────────────

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
    List<String> images = [];
    if (json['image'] is List) {
      for (var image in json['image']) {
        if (image is String) images.add(image);
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

  String get thumbnail =>
      images.isNotEmpty ? images.first : 'https://via.placeholder.com/150';

  bool get hasProperty => id > 0;
}

class CommonFacility {
  int? id;
  String? title;
  String? image;
  String? createdAt;
  String? updatedAt;

  CommonFacility({
    this.id,
    this.title,
    this.image,
    this.createdAt,
    this.updatedAt,
  });

  CommonFacility.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    image = json['image'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }
}