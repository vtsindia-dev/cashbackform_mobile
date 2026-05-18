import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';

// ======================================================
// SAFE TYPE CAST HELPERS
// ======================================================

int safeIntCast(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

int? safeNullableIntCast(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) {
    final parsed = int.tryParse(value);
    return parsed;
  }
  return null;
}

double safeDoubleCast(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

double? safeNullableDoubleCast(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

bool safeBoolCast(dynamic value) {
  if (value == null) return false;
  if (value is bool) return value;
  if (value is int) return value == 1;
  if (value is double) return value == 1.0;
  if (value is String) {
    final lower = value.toLowerCase();
    return lower == 'true' || lower == '1' || lower == 'yes';
  }
  return false;
}

// Returns the value as String only when it actually IS a String.
// Returns null for List, Map, int, bool, or any other non-String type.
// Needed because the API returns `"documents": []` (a List) when empty,
// but a String path when a document exists.
String? _safeStringFromJson(dynamic value) {
  if (value == null) return null;
  if (value is String) return value.isEmpty ? null : value;
  return null;
}

// ======================================================
// PROPERTY LIST RESPONSE
// ======================================================

class PropertyListResponse {
  final bool status;
  final PropertyListData data;

  PropertyListResponse({
    required this.status,
    required this.data,
  });

  factory PropertyListResponse.fromJson(Map<String, dynamic> json) {
    return PropertyListResponse(
      status: safeBoolCast(json['status']),
      data: PropertyListData.fromJson(json['data'] ?? {}),
    );
  }
}

class PropertyListData {
  final List<Property> plots;
  final List<PropertyCategory> propertyCategories;
  final List<StateList> stateList;
  final PriceRange priceRange;
  final Pagination pagination;

  PropertyListData({
    required this.plots,
    required this.propertyCategories,
    required this.stateList,
    required this.priceRange,
    required this.pagination,
  });

  factory PropertyListData.fromJson(Map<String, dynamic> json) {
    return PropertyListData(
      plots: (json['plots'] as List<dynamic>? ?? [])
          .map((item) => Property.fromJson(item as Map<String, dynamic>))
          .toList(),
      propertyCategories: (json['property_category'] as List<dynamic>? ?? [])
          .map((item) => PropertyCategory.fromJson(item as Map<String, dynamic>))
          .toList(),
      stateList: (json['state_list'] as List<dynamic>? ?? [])
          .map((item) => StateList.fromJson(item as Map<String, dynamic>))
          .toList(),
      priceRange: PriceRange.fromJson({
        'price_min': json['price_min'],
        'price_max': json['price_max'],
        'sqft_min': json['sqft_min'],
        'sqft_max': json['sqft_max'],
      }),
      pagination: Pagination.fromJson(json['pagination'] ?? {}),
    );
  }
}

// ======================================================
// PROPERTY DETAIL RESPONSE
// ======================================================

class PropertyDetailResponse {
  final bool status;
  final Property data;

  PropertyDetailResponse({
    required this.status,
    required this.data,
  });

  factory PropertyDetailResponse.fromJson(Map<String, dynamic> json) {
    return PropertyDetailResponse(
      status: safeBoolCast(json['status']),
      data: Property.fromJson(json['data'] ?? {}),
    );
  }
}

// ======================================================
// MAIN PROPERTY MODEL
// ======================================================

class Property {
  final int id;
  final String propertyName;
  final String? status;
  final DateTime? handoverDate;
  final DateTime? completionDate;
  final String location;
  final int? city;
  final int? state;
  final int? country; // FIX: Added country field (present in API response)
  final int? plotCount;
  final int? subCategoryId;
  final String? lat;
  final String? lng;
  final double price;
  final int areaSqft;
  final double? areaSqftPrice;
  final String? highlights;
  final String? overview;
  final String? dimensions;
  final String? facing;
  final List<String> amenities;
  final bool gated;
  final String? openSides;
  final String? overlooking;
  final int categoryId;
  List<Map<String, dynamic>>? nearbyPlaces;
  final String transactionType;
  final String? ownership;
  final String? roadWidth;
  final bool boundaryWall;
  final String? features;
  final String aboutProperty;
  final String landApproval;
  final String constructionGuidelines;
  final String sitePlan;
  final String threeDImage;
  final List<String> galleryImages;
  final String thumbnail;
  final int verifyStatus;
  final String userType;
  final int? customerId;
  final String? documents;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<FacilityValue> facilities;
  final List<NearbyLocation> nearbyLocations;
  final List<AmenityItem> amenitiesAll;
  final PropertyCategory? category;

  // FIX: Added sold_status and sold_amount fields from API response
  final int soldStatus;
  final double? soldAmount;

  // FIX: Added blueprint field (API returns 'blueprint' key)
  final String? blueprint;

  // FIX: Added featured field
  final int featured;

  // FIX: Added map_set field for nearby properties on map
  final List<MapSetItem> mapSet;

  // API key: 'doucment_verficaiton' (typo in API) — true means docs verified
  final bool documentVerification;

  Property({
    required this.id,
    required this.propertyName,
    this.status,
    this.handoverDate,
    this.completionDate,
    required this.location,
    this.city,
    this.plotCount,
    this.state,
    this.country,
    this.lat,
    this.lng,
    required this.price,
    required this.areaSqft,
    this.areaSqftPrice,
    this.highlights,
    this.overview,
    this.dimensions,
    this.facing,
    required this.amenities,
    required this.gated,
    this.openSides,
    this.overlooking,
    required this.categoryId,
    required this.nearbyPlaces,
    required this.transactionType,
    this.ownership,
    this.roadWidth,
    required this.boundaryWall,
    this.features,
    this.subCategoryId,
    required this.aboutProperty,
    required this.landApproval,
    required this.constructionGuidelines,
    required this.sitePlan,
    required this.threeDImage,
    required this.galleryImages,
    required this.thumbnail,
    required this.verifyStatus,
    required this.userType,
    this.customerId,
    this.documents,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.facilities,
    required this.nearbyLocations,
    required this.amenitiesAll,
    this.category,
    this.soldStatus = 0,
    this.soldAmount,
    this.blueprint,
    this.featured = 0,
    this.mapSet = const [],
    this.documentVerification = false,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: safeIntCast(json['id']),
      propertyName: json['property_name'] as String? ?? '',
      status: json['status'] as String?,
      handoverDate: json['handover_date'] != null
          ? DateTime.tryParse(json['handover_date'].toString())
          : null,
      completionDate: json['completion_date'] != null
          ? DateTime.tryParse(json['completion_date'].toString())
          : null,
      location: json['location'] as String? ?? '',
      city: safeNullableIntCast(json['city']),
      state: safeNullableIntCast(json['state']),
      // FIX: Parse country from API response
      country: safeNullableIntCast(json['country']),
      lat: json['lat'] as String?,
      lng: json['lng'] as String?,
      price: safeDoubleCast(json['price']),
      // FIX: was 'plot_count' key, now correctly mapped
      plotCount: safeNullableIntCast(json['plot_count']),
      areaSqft: safeIntCast(json['area_sqft']),
      areaSqftPrice: safeNullableDoubleCast(json['area_sqft_price']),
      highlights: json['highlights'] as String?,
      overview: json['overview'] as String?,
      dimensions: json['dimensions'] as String?,
      facing: json['facing'] as String?,
      amenities: (json['amenities'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      gated: safeBoolCast(json['gated']),
      subCategoryId: safeNullableIntCast(json['sub_category_id']),
      openSides: json['open_sides'] as String?,
      overlooking: json['overlooking'] as String?,
      categoryId: safeIntCast(json['category_id']),
      nearbyPlaces: json['nearby_places'] != null
          ? List<Map<String, dynamic>>.from(json['nearby_places'])
          : null,
      transactionType: json['transaction_type'] as String? ?? 'new',
      ownership: json['ownership'] as String?,
      roadWidth: json['road_width'] as String?,
      boundaryWall: safeBoolCast(json['boundary_wall']),
      features: json['features'] as String?,
      aboutProperty: json['about_property'] as String? ?? '',
      landApproval: json['land_approval'] as String? ?? '',
      constructionGuidelines: json['construction_guidelines'] as String? ?? '',
      sitePlan: json['site_plan'] as String? ?? '',
      threeDImage: json['three_d_image'] as String? ?? '',
      galleryImages: (json['gallery_images'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      thumbnail: json['thumbnail'] as String? ?? '',
      verifyStatus: safeIntCast(json['verify_status']),
      userType: json['user_type'] as String? ?? 'customer',
      customerId: safeNullableIntCast(json['customer_id']),
      // API has a typo 'docuents'; also 'documents' may be a List<dynamic>
      // when empty ([]) — never cast directly, always guard with is-check.
      documents: _safeStringFromJson(json['docuents']) ??
          _safeStringFromJson(json['documents']),
      isActive: safeBoolCast(json['is_active']),
      createdAt: DateTime.parse(json['created_at']?.toString() ?? '1970-01-01'),
      updatedAt: DateTime.parse(json['updated_at']?.toString() ?? '1970-01-01'),
      facilities: (json['facilities'] as List<dynamic>? ?? [])
          .map((e) => FacilityValue.fromJson(e as Map<String, dynamic>))
          .toList(),
      nearbyLocations: (json['nearbyLocations'] as List<dynamic>? ?? [])
          .map((e) => NearbyLocation.fromJson(e as Map<String, dynamic>))
          .toList(),
      amenitiesAll: (json['amenitiesall'] as List<dynamic>? ?? [])
          .map((e) => AmenityItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      category: json['cate'] != null
          ? PropertyCategory.fromJson(json['cate'] as Map<String, dynamic>)
          : null,
      // FIX: Parse sold_status and sold_amount from API
      soldStatus: safeIntCast(json['sold_status']),
      soldAmount: safeNullableDoubleCast(json['sold_amount']),
      // FIX: Parse blueprint — API returns relative path, not full URL
      blueprint: json['blueprint'] as String?,
      featured: safeIntCast(json['featured']),
      // FIX: Parse map_set array
      mapSet: (json['map_set'] as List<dynamic>? ?? [])
          .map((e) => MapSetItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      // API key has a typo: 'doucment_verficaiton'
      documentVerification: safeBoolCast(json['doucment_verficaiton']),
    );
  }

  // ---- Computed getters ----

  String get formattedPrice {
    if (price >= 10000000) {
      return '₹${(price / 10000000).toStringAsFixed(2)} Cr';
    } else if (price >= 100000) {
      return '₹${(price / 100000).toStringAsFixed(2)} L';
    } else {
      return '₹${price.toStringAsFixed(2)}';
    }
  }

  String get formattedArea => '$areaSqft sq.ft';

  String get formattedPricePerSqft {
    if (areaSqftPrice != null) {
      return '₹${areaSqftPrice!.toStringAsFixed(2)}/sq.ft';
    }
    return 'Price on request';
  }

  bool get isVerified => verifyStatus == 1;
  bool get isAdminPosted => userType == 'admin';
  bool get isCustomerPosted => userType == 'customer';

  /// FIX: isSoldOut based on sold_status from API (1 = sold out)
  bool get isSoldOut => soldStatus == 1;

  /// FIX: Country label for list page location indicator
  /// country 3 = Dubai (based on API), else India
  /// Adjust the country IDs to match your backend's actual values


  /// Returns true if this property is in Dubai
  bool get isIndia => country == 1;

  /// FIX: Full blueprint URL helper
  /// API returns relative path like 'storage/plots/filename.jpeg'
  /// Pass your base URL when building the widget, or use this helper
  String blueprintUrl(String baseUrl) {
    if (blueprint == null || blueprint!.isEmpty) return '';
    if (blueprint!.startsWith('http')) return blueprint!;
    // Remove trailing slash from base, add leading slash to path if missing
    final base = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';
    final path = blueprint!.startsWith('/') ? blueprint!.substring(1) : blueprint!;
    return '$base$path';
  }

  // Get facilities as map for easy access
  Map<String, String> get facilitiesMap {
    final map = <String, String>{};
    for (final facility in facilities) {
      if (facility.value != null && facility.value!.isNotEmpty) {
        final facilityName = facility.fac.isNotEmpty
            ? facility.fac.first.name
            : facility.name ?? 'Unknown';
        map[facilityName] = facility.value!;
      }
    }
    return map;
  }

  // Get specific facility value
  String? getFacilityValue(String facilityName) {
    for (final facility in facilities) {
      final currentFacilityName = facility.fac.isNotEmpty
          ? facility.fac.first.name
          : facility.name;
      if (currentFacilityName?.toLowerCase() == facilityName.toLowerCase()) {
        return facility.value;
      }
    }
    return null;
  }

  // Get amenities with images
  List<Map<String, String>> get amenitiesWithImages {
    return amenitiesAll
        .map((amenity) => {
      'title': amenity.title,
      'image': amenity.image,
    })
        .toList();
  }

  // Get nearby locations with distance
  List<Map<String, dynamic>> get nearbyLocationsWithDistance {
    return nearbyLocations
        .map((location) => {
      'title': location.title,
      'image': location.image,
      'distance': location.pivot?.distance ?? 0,
    })
        .toList();
  }

  // Get gallery images excluding thumbnail
  List<String> get additionalGalleryImages {
    return galleryImages.where((image) => image != thumbnail).toList();
  }

  // Get first image for display
  String get displayImage =>
      galleryImages.isNotEmpty ? galleryImages.first : thumbnail;
}

// ======================================================
// MAP SET ITEM — for nearby properties on map
// ======================================================

class MapSetItem {
  final int id;
  final String? propertyName;
  final String? lat;
  final String? lng;
  final double price;
  final int areaSqft;
  final String? thumbnail;
  final int soldStatus;

  MapSetItem({
    required this.id,
    this.propertyName,
    this.lat,
    this.lng,
    required this.price,
    required this.areaSqft,
    this.thumbnail,
    this.soldStatus = 0,
  });

  factory MapSetItem.fromJson(Map<String, dynamic> json) {
    return MapSetItem(
      id: safeIntCast(json['id']),
      propertyName: json['property_name'] as String?,
      lat: json['lat'] as String?,
      lng: json['lng'] as String?,
      price: safeDoubleCast(json['price']),
      areaSqft: safeIntCast(json['area_sqft']),
      thumbnail: json['thumbnail'] as String?,
      soldStatus: safeIntCast(json['sold_status']),
    );
  }

  bool get isSoldOut => soldStatus == 1;

  String get formattedPrice {
    if (price >= 10000000) {
      return '₹${(price / 10000000).toStringAsFixed(2)} Cr';
    } else if (price >= 100000) {
      return '₹${(price / 100000).toStringAsFixed(2)} L';
    } else {
      return '₹${price.toStringAsFixed(2)}';
    }
  }
}

// ======================================================
// SUPPORTING MODELS
// ======================================================

class PropertyCategory {
  final int id;
  final String categoryName;
  final String slug;
  final String? facilities;
  final String? documents;
  final int status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final List<PropertySubCategory>? subCategories;

  PropertyCategory({
    required this.id,
    required this.categoryName,
    required this.slug,
    this.facilities,
    this.documents,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.subCategories,
  });

  factory PropertyCategory.fromJson(Map<String, dynamic> json) {
    List<PropertySubCategory>? subCategories;
    if (json['sub_categories'] != null && json['sub_categories'] is List) {
      subCategories = (json['sub_categories'] as List)
          .map((item) =>
          PropertySubCategory.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return PropertyCategory(
      id: safeIntCast(json['id']),
      categoryName: json['category_name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      facilities: json['facilities'] as String?,
      documents: json['documents'] as String?,
      status: safeIntCast(json['status']),
      createdAt:
      DateTime.parse(json['created_at']?.toString() ?? '1970-01-01'),
      updatedAt:
      DateTime.parse(json['updated_at']?.toString() ?? '1970-01-01'),
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'].toString())
          : null,
      subCategories: subCategories,
    );
  }

  List<int> get facilityIds {
    if (facilities == null || facilities!.isEmpty) return [];
    return facilities!
        .split(',')
        .map((e) => int.tryParse(e.trim()) ?? 0)
        .where((id) => id > 0)
        .toList();
  }

  List<int> get documentIds {
    if (documents == null || documents!.isEmpty) return [];
    return documents!
        .split(',')
        .map((e) => int.tryParse(e.trim()) ?? 0)
        .where((id) => id > 0)
        .toList();
  }

  bool get isActive => status == 1;
}

class PropertySubCategory {
  final int id;
  final String name;
  final String? icon;
  final int? categoryId;

  PropertySubCategory({
    required this.id,
    required this.name,
    this.icon,
    this.categoryId,
  });

  factory PropertySubCategory.fromJson(Map<String, dynamic> json) {
    return PropertySubCategory(
      id: safeIntCast(json['id']),
      name: json['name'] as String? ?? '',
      icon: json['icon'] as String?,
      categoryId: safeNullableIntCast(json['category_id']),
    );
  }
}

class StateList {
  final int id;
  final String stateName;
  final int status;
  final DateTime createdAt;
  final DateTime updatedAt;

  StateList({
    required this.id,
    required this.stateName,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StateList.fromJson(Map<String, dynamic> json) {
    return StateList(
      id: safeIntCast(json['id']),
      stateName: json['state_name'] as String? ?? '',
      status: safeIntCast(json['status']),
      createdAt:
      DateTime.parse(json['created_at']?.toString() ?? '1970-01-01'),
      updatedAt:
      DateTime.parse(json['updated_at']?.toString() ?? '1970-01-01'),
    );
  }

  bool get isActive => status == 1;
}

class PriceRange {
  final double priceMin;
  final double priceMax;
  final int sqftMin;
  final int sqftMax;

  PriceRange({
    required this.priceMin,
    required this.priceMax,
    required this.sqftMin,
    required this.sqftMax,
  });

  factory PriceRange.fromJson(Map<String, dynamic> json) {
    return PriceRange(
      priceMin: safeDoubleCast(json['price_min']),
      priceMax: safeDoubleCast(json['price_max']),
      sqftMin: safeIntCast(json['sqft_min']),
      sqftMax: safeIntCast(json['sqft_max']),
    );
  }

  String get priceRangeText =>
      '₹${priceMin.toStringAsFixed(0)} - ₹${priceMax.toStringAsFixed(0)}';
  String get areaRangeText => '$sqftMin - $sqftMax sq.ft';
}

class Pagination {
  final int currentPage;
  final int total;
  final int perPage;
  final int lastPage;

  Pagination({
    required this.currentPage,
    required this.total,
    required this.perPage,
    required this.lastPage,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: safeIntCast(json['current_page']),
      total: safeIntCast(json['total']),
      perPage: safeIntCast(json['per_page']),
      lastPage: safeIntCast(json['last_page']),
    );
  }

  bool get hasNextPage => currentPage < lastPage;
  bool get hasPreviousPage => currentPage > 1;
  int get totalPages => lastPage;
}

class FacilityValue {
  final int id;
  final String? value;
  final int facilityId;
  final int plotId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String images;
  final String? name;
  final List<Facility> fac;

  FacilityValue({
    required this.id,
    this.value,
    required this.facilityId,
    required this.plotId,
    required this.createdAt,
    required this.updatedAt,
    required this.images,
    this.name,
    required this.fac,
  });

  factory FacilityValue.fromJson(Map<String, dynamic> json) {
    return FacilityValue(
      id: safeIntCast(json['id']),
      value: json['value'] as String?,
      facilityId: safeIntCast(json['facility_id']),
      plotId: safeIntCast(json['plot_id']),
      createdAt:
      DateTime.parse(json['created_at']?.toString() ?? '1970-01-01'),
      updatedAt:
      DateTime.parse(json['updated_at']?.toString() ?? '1970-01-01'),
      images: json['images'] as String? ?? '',
      name: json['name'] as String?,
      fac: (json['fac'] as List<dynamic>? ?? [])
          .map((e) => Facility.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  String? get facilityName => fac.isNotEmpty ? fac.first.name : name;
  String? get facilityImage => fac.isNotEmpty ? fac.first.image : images;
}

class Facility {
  final int id;
  final String name;
  final String type;
  final int isRequired;
  final String? value;
  final String? image;
  final String? file;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<FacilityOption>? options;

  Facility({
    required this.id,
    required this.name,
    required this.type,
    required this.isRequired,
    this.value,
    this.image,
    this.file,
    required this.createdAt,
    required this.updatedAt,
    this.options,
  });

  factory Facility.fromJson(Map<String, dynamic> json) {
    List<FacilityOption>? options;

    if (json['facility_options'] != null && json['facility_options'] is List) {
      options = (json['facility_options'] as List)
          .map((item) =>
          FacilityOption.fromJson(item as Map<String, dynamic>))
          .toList();
    } else if (json['value'] != null &&
        (json['type'] == 'dropdown' || json['type'] == 'radio')) {
      final valueStr = json['value'].toString();
      final values = valueStr
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      options = values.asMap().entries.map((entry) {
        return FacilityOption(
          id: entry.key,
          value: entry.value,
          label: entry.value,
        );
      }).toList();
    }

    return Facility(
      id: safeIntCast(json['id']),
      name: json['name'] as String? ?? '',
      type: (json['type'] as String? ?? 'text').toLowerCase(),
      isRequired: safeIntCast(json['is_required']),
      value: json['value'] as String?,
      image: json['image'] as String?,
      file: json['file'] as String?,
      createdAt:
      DateTime.parse(json['created_at']?.toString() ?? '1970-01-01'),
      updatedAt:
      DateTime.parse(json['updated_at']?.toString() ?? '1970-01-01'),
      options: options,
    );
  }

  List<String> get dropdownValues {
    if (options != null && options!.isNotEmpty) {
      return options!.map((opt) => opt.label).toList();
    }
    if (value == null || value!.isEmpty) return [];
    return value!
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  List<FacilityOption> get radioOptions => options ?? [];

  bool get isDropdown => type == 'dropdown';
  bool get isText => type == 'text';
  bool get isRadio => type == 'radio';
  bool get isCheckbox => type == 'checkbox';
  bool get isNumber => type == 'number';
  bool get isDate => type == 'date';
}

class FacilityOption {
  final int id;
  final String value;
  final String label;

  FacilityOption({
    required this.id,
    required this.value,
    required this.label,
  });

  factory FacilityOption.fromJson(Map<String, dynamic> json) {
    return FacilityOption(
      id: safeIntCast(json['id']),
      value: json['value']?.toString() ?? '',
      label: json['label'] ?? json['value']?.toString() ?? '',
    );
  }
}

class NearbyLocation {
  final int id;
  final String title;
  final String image;
  final DateTime createdAt;
  final DateTime updatedAt;
  final LocationPivot? pivot;

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
      id: safeIntCast(json['id']),
      title: json['title'] as String? ?? '',
      image: json['image'] as String? ?? '',
      createdAt:
      DateTime.parse(json['created_at']?.toString() ?? '1970-01-01'),
      updatedAt:
      DateTime.parse(json['updated_at']?.toString() ?? '1970-01-01'),
      pivot: json['pivot'] != null
          ? LocationPivot.fromJson(json['pivot'] as Map<String, dynamic>)
          : null,
    );
  }
}

class LocationPivot {
  final int plotId;
  final int nearbyLocationId;
  // FIX: distance comes as String "2.0" in API, not int
  final double distance;
  final DateTime createdAt;
  final DateTime updatedAt;

  LocationPivot({
    required this.plotId,
    required this.nearbyLocationId,
    required this.distance,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LocationPivot.fromJson(Map<String, dynamic> json) {
    return LocationPivot(
      plotId: safeIntCast(json['plot_id']),
      nearbyLocationId: safeIntCast(json['nearby_location_id']),
      // FIX: was safeIntCast — API returns "2.0" string, use double
      distance: safeDoubleCast(json['distance']),
      createdAt:
      DateTime.parse(json['created_at']?.toString() ?? '1970-01-01'),
      updatedAt:
      DateTime.parse(json['updated_at']?.toString() ?? '1970-01-01'),
    );
  }
}

class AmenityItem {
  final int id;
  final String title;
  final String image;
  final String? type;
  final DateTime createdAt;
  final DateTime updatedAt;
  final AmenityPivot? pivot;

  AmenityItem({
    required this.id,
    required this.title,
    required this.image,
    this.type,
    required this.createdAt,
    required this.updatedAt,
    this.pivot,
  });

  factory AmenityItem.fromJson(Map<String, dynamic> json) {
    return AmenityItem(
      id: safeIntCast(json['id']),
      title: json['title'] as String? ?? '',
      image: json['image'] as String? ?? '',
      type: json['type'] as String?,
      createdAt:
      DateTime.parse(json['created_at']?.toString() ?? '1970-01-01'),
      updatedAt:
      DateTime.parse(json['updated_at']?.toString() ?? '1970-01-01'),
      pivot: json['pivot'] != null
          ? AmenityPivot.fromJson(json['pivot'] as Map<String, dynamic>)
          : null,
    );
  }

  bool get isDocument =>
      (type?.toLowerCase() == 'file' || type?.toLowerCase() == 'document');
}

class AmenityPivot {
  final int plotId;
  final int amenityId;
  final DateTime createdAt;
  final DateTime updatedAt;

  AmenityPivot({
    required this.plotId,
    required this.amenityId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AmenityPivot.fromJson(Map<String, dynamic> json) {
    return AmenityPivot(
      plotId: safeIntCast(json['plot_id']),
      amenityId: safeIntCast(json['amenity_id']),
      createdAt:
      DateTime.parse(json['created_at']?.toString() ?? '1970-01-01'),
      updatedAt:
      DateTime.parse(json['updated_at']?.toString() ?? '1970-01-01'),
    );
  }
}

// ======================================================
// FORM BUILDER MODELS
// ======================================================

class CityModel {
  final int id;
  final String name;
  final int stateId;

  CityModel({
    required this.id,
    required this.name,
    required this.stateId,
  });

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      id: safeIntCast(json['id']),
      name: json['name'] ?? json['city_name'] ?? '',
      stateId: safeIntCast(json['state_id']),
    );
  }
}

class Document {
  final int id;
  final String name;
  final String? file;
  final String type;
  final int status;
  final String createdAt;
  final String updatedAt;
  final String? description;
  final String? helpText;
  final List<String>? allowedFormats;
  final int? maxSize;
  final int isRequired;

  Document({
    required this.id,
    required this.name,
    this.file,
    required this.type,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.helpText,
    this.allowedFormats,
    this.maxSize,
    required this.isRequired,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unnamed Document',
      file: json['file'],
      type: json['type'] ?? 'file',
      status: json['status'] ?? 1,
      createdAt: json['created_at'] ?? DateTime.now().toIso8601String(),
      updatedAt: json['updated_at'] ?? DateTime.now().toIso8601String(),
      description: json['description'],
      helpText: json['help_text'],
      allowedFormats: json['allowed_formats'] != null
          ? (json['allowed_formats'] as String)
          .split(',')
          .map((e) => e.trim())
          .toList()
          : ['pdf', 'jpg', 'png', 'jpeg', 'doc', 'docx'],
      maxSize: json['max_size'] ?? 2048,
      isRequired: json['is_required'] ?? 1,
    );
  }
}

class Place {
  final Coordinates coordinates;
  final String name;
  final String address;
  final String? placeId;

  Place({
    required this.coordinates,
    required this.name,
    required this.address,
    this.placeId,
  });

  factory Place.fromGeocoding(Placemark placemark, double lat, double lng) {
    return Place(
      coordinates: Coordinates(lat, lng),
      name: placemark.street ?? placemark.locality ?? 'Unknown',
      address: _buildAddress(placemark),
    );
  }

  factory Place.fromSearch(Map<String, dynamic> json) {
    return Place(
      coordinates: Coordinates(
        json['geometry']['location']['lat'],
        json['geometry']['location']['lng'],
      ),
      name: json['name'] ?? '',
      address: json['formatted_address'] ?? json['vicinity'] ?? '',
      placeId: json['place_id'],
    );
  }

  static String _buildAddress(Placemark placemark) {
    List<String> parts = [];
    if (placemark.street != null && placemark.street!.isNotEmpty) {
      parts.add(placemark.street!);
    }
    if (placemark.locality != null && placemark.locality!.isNotEmpty) {
      parts.add(placemark.locality!);
    }
    if (placemark.administrativeArea != null &&
        placemark.administrativeArea!.isNotEmpty) {
      parts.add(placemark.administrativeArea!);
    }
    if (placemark.postalCode != null && placemark.postalCode!.isNotEmpty) {
      parts.add(placemark.postalCode!);
    }
    if (placemark.country != null && placemark.country!.isNotEmpty) {
      parts.add(placemark.country!);
    }
    return parts.join(', ');
  }
}

class Coordinates {
  final double latitude;
  final double longitude;

  Coordinates(this.latitude, this.longitude);

  LatLng toLatLng() => LatLng(latitude, longitude);
}

// ======================================================
// API RESPONSE MODELS
// ======================================================

class CategoryResponse {
  final bool status;
  final List<PropertyCategory> data;

  CategoryResponse({
    required this.status,
    required this.data,
  });

  factory CategoryResponse.fromJson(Map<String, dynamic> json) {
    return CategoryResponse(
      status: safeBoolCast(json['status']),
      data: (json['data'] as List<dynamic>? ?? [])
          .map((item) =>
          PropertyCategory.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class FacilitiesResponse {
  final bool status;
  final String message;
  final List<Facility> data;

  FacilitiesResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory FacilitiesResponse.fromJson(Map<String, dynamic> json) {
    return FacilitiesResponse(
      status: safeBoolCast(json['status']),
      message: json['message'] as String? ?? '',
      data: (json['data'] as List<dynamic>? ?? [])
          .map((item) => Facility.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class DocumentsResponse {
  final bool status;
  final String message;
  final List<Document> data;

  DocumentsResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory DocumentsResponse.fromJson(Map<String, dynamic> json) {
    return DocumentsResponse(
      status: safeBoolCast(json['status']),
      message: json['message'] as String? ?? '',
      data: (json['data'] as List<dynamic>? ?? [])
          .map((item) => Document.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class AmenitiesResponse {
  final int status;
  final List<AmenityItem> data;

  AmenitiesResponse({
    required this.status,
    required this.data,
  });

  factory AmenitiesResponse.fromJson(Map<String, dynamic> json) {
    return AmenitiesResponse(
      status: safeIntCast(json['status']),
      data: (json['data']['amenities'] as List<dynamic>? ?? [])
          .map((item) => AmenityItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class StatesResponse {
  final bool status;
  final List<StateList> data;

  StatesResponse({
    required this.status,
    required this.data,
  });

  factory StatesResponse.fromJson(Map<String, dynamic> json) {
    return StatesResponse(
      status: safeBoolCast(json['status']),
      data: (json['data'] as List<dynamic>? ?? [])
          .map((item) => StateList.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class CitiesResponse {
  final bool status;
  final List<CityModel> data;

  CitiesResponse({
    required this.status,
    required this.data,
  });

  factory CitiesResponse.fromJson(Map<String, dynamic> json) {
    return CitiesResponse(
      status: safeBoolCast(json['status']),
      data: (json['data'] as List<dynamic>? ?? [])
          .map((item) => CityModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class FormSubmissionResponse {
  final bool status;
  final String message;
  final Map<String, dynamic>? data;

  FormSubmissionResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory FormSubmissionResponse.fromJson(Map<String, dynamic> json) {
    return FormSubmissionResponse(
      status: safeBoolCast(json['status']),
      message: json['message'] as String? ?? '',
      data: json['data'] as Map<String, dynamic>?,
    );
  }
}

// ======================================================
// FORM DATA MODEL
// ======================================================

class PropertyFormData {
  final String propertyName;
  final int categoryId;
  final String location;
  final double lat;
  final double lng;
  final double price;
  final String aboutProperty;
  final int areaSqft;
  final String userType;
  final int? state;
  final int? city;
  final int? subCategoryId;
  final List<int> amenities;
  final Map<String, dynamic> facilities;
  final List<String>? galleryImages;
  final Map<String, dynamic>? documents;

  PropertyFormData({
    required this.propertyName,
    required this.categoryId,
    required this.location,
    required this.lat,
    required this.lng,
    required this.price,
    required this.aboutProperty,
    required this.areaSqft,
    required this.userType,
    this.state,
    this.city,
    this.subCategoryId,
    required this.amenities,
    required this.facilities,
    this.galleryImages,
    this.documents,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['property_name'] = propertyName;
    data['category_id'] = categoryId;
    data['location'] = location;
    data['lat'] = lat.toString();
    data['lng'] = lng.toString();
    data['price'] = price;
    data['about_property'] = aboutProperty;
    data['area_sqft'] = areaSqft;
    data['user_type'] = userType;

    if (state != null && state! > 0) data['state'] = state;
    if (city != null && city! > 0) data['city'] = city;
    if (subCategoryId != null && subCategoryId! > 0) {
      data['sub_category_id'] = subCategoryId;
    }

    if (amenities.isNotEmpty) {
      data['amenities'] = amenities.join(',');
    }

    if (facilities.isNotEmpty) {
      final facilityMap = <String, dynamic>{};
      for (var entry in facilities.entries) {
        facilityMap[entry.key] = entry.value;
      }
      data['facilities'] = facilityMap;
    }

    if (galleryImages != null && galleryImages!.isNotEmpty) {
      data['gallery_images'] = galleryImages;
    }

    if (documents != null && documents!.isNotEmpty) {
      data['documents'] = documents;
    }

    return data;
  }
}

class NearbyPlace {
  final int id;
  final String title;
  final String image;
  final String createdAt;
  final String updatedAt;

  NearbyPlace({
    required this.id,
    required this.title,
    required this.image,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NearbyPlace.fromJson(Map<String, dynamic> json) {
    return NearbyPlace(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      image: json['image'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}