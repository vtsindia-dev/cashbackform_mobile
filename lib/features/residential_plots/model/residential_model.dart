// ======================================================
// HELPER FUNCTIONS FOR SAFE TYPE CASTING
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

// ======================================================
// PROPERTY LIST MODELS
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
// PROPERTY DETAIL MODELS
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
  final List<NearbyPlace> nearbyPlaces;
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

  Property({
    required this.id,
    required this.propertyName,
    this.status,
    this.handoverDate,
    this.completionDate,
    required this.location,
    this.city,
    this.state,
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
      lat: json['lat'] as String?,
      lng: json['lng'] as String?,
      price: safeDoubleCast(json['price']),
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
      openSides: json['open_sides'] as String?,
      overlooking: json['overlooking'] as String?,
      categoryId: safeIntCast(json['category_id']),
      nearbyPlaces: (json['nearby_places'] as List<dynamic>? ?? [])
          .map((e) => NearbyPlace.fromJson(e as Map<String, dynamic>))
          .toList(),
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
      documents: json['documents'] as String?,
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
    );
  }

  // Helper getters
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

  // Get facilities as map for easy access
  Map<String, String> get facilitiesMap {
    final map = <String, String>{};
    for (final facility in facilities) {
      if (facility.value != null && facility.value!.isNotEmpty) {
        map[facility.name ?? 'Unknown'] = facility.value!;
      }
    }
    return map;
  }

  // Get specific facility value
  String? getFacilityValue(String facilityName) {
    for (final facility in facilities) {
      if (facility.name?.toLowerCase() == facilityName.toLowerCase()) {
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
  });

  factory PropertyCategory.fromJson(Map<String, dynamic> json) {
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

class NearbyPlace {
  final int placeId;
  final int distance;

  NearbyPlace({
    required this.placeId,
    required this.distance,
  });

  factory NearbyPlace.fromJson(Map<String, dynamic> json) {
    return NearbyPlace(
      placeId: safeIntCast(json['place_id']),
      distance: safeIntCast(json['distance']),
    );
  }
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
  });

  factory Facility.fromJson(Map<String, dynamic> json) {
    return Facility(
      id: safeIntCast(json['id']),
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? 'text',
      isRequired: safeIntCast(json['is_required']),
      value: json['value'] as String?,
      image: json['image'] as String?,
      file: json['file'] as String?,
      createdAt:
      DateTime.parse(json['created_at']?.toString() ?? '1970-01-01'),
      updatedAt:
      DateTime.parse(json['updated_at']?.toString() ?? '1970-01-01'),
    );
  }

  List<String> get dropdownValues {
    if (value == null || value!.isEmpty) return [];
    return value!.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  }

  bool get isDropdown => type == 'dropdown';
  bool get isText => type == 'text';
  bool get isRadio => type == 'radio';
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
    final int distance;
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
      distance: safeIntCast(json['distance']),
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
  final DateTime createdAt;
  final DateTime updatedAt;
  final AmenityPivot? pivot;

  AmenityItem({
    required this.id,
    required this.title,
    required this.image,
    required this.createdAt,
    required this.updatedAt,
    this.pivot,
  });

  factory AmenityItem.fromJson(Map<String, dynamic> json) {
    return AmenityItem(
      id: safeIntCast(json['id']),
      title: json['title'] as String? ?? '',
      image: json['image'] as String? ?? '',
      createdAt:
      DateTime.parse(json['created_at']?.toString() ?? '1970-01-01'),
      updatedAt:
      DateTime.parse(json['updated_at']?.toString() ?? '1970-01-01'),
      pivot: json['pivot'] != null
          ? AmenityPivot.fromJson(json['pivot'] as Map<String, dynamic>)
          : null,
    );
  }
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
// ENUMS FOR BETTER TYPE SAFETY
// ======================================================

enum PropertyType {
  independentHouse(8, 'Independent House/ Villa'),
  plotsLands(9, 'Plots/ Lands'),
  apartments(10, 'Apartments/ Flats'),
  custom(12, 'Test Category');

  final int id;
  final String displayName;

  const PropertyType(this.id, this.displayName);

  static PropertyType fromId(int id) {
    return values.firstWhere(
          (type) => type.id == id,
      orElse: () => custom,
    );
  }
}

enum PropertyStatus {
  newLaunch('New Launch'),
  underConstruction('Under Construction'),
  readyToMove('Ready to Move');

  final String displayName;

  const PropertyStatus(this.displayName);
}

enum TransactionType {
  newProperty('new'),
  resale('resale');

  final String value;

  const TransactionType(this.value);
}

enum PostedBy {
  owner('Owner'),
  builder('Builder'),
  dealer('Dealer'),
  featureDealer('Feature Dealer');

  final String value;

  const PostedBy(this.value);
}

enum FurnishingStatus {
  unfurnished('Unfurnished'),
  semiFurnished('Semi-furnished'),
  furnished('Furnished');

  final String value;

  const FurnishingStatus(this.value);
}