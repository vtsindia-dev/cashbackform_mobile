// shared_models.dart
class AmenityModel {
  final int id;
  final String title;
  final String image;
  final DateTime createdAt;
  final DateTime updatedAt;

  AmenityModel({
    required this.id,
    required this.title,
    required this.image,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AmenityModel.fromJson(Map<String, dynamic> json) {
    return AmenityModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      title: json['title']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      createdAt: DateTime.parse(json['created_at']?.toString() ?? DateTime.now().toString()),
      updatedAt: DateTime.parse(json['updated_at']?.toString() ?? DateTime.now().toString()),
    );
  }
}

class RentalDocument {
  final int id;
  final int propertyId;
  final String file;
  final String type;
  final String? doucType;
  final DateTime createdAt;
  final DateTime updatedAt;

  RentalDocument({
    required this.id,
    required this.propertyId,
    required this.file,
    required this.type,
    this.doucType,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RentalDocument.fromJson(Map<String, dynamic> json) {
    return RentalDocument(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      propertyId: json['property_id'] is int ? json['property_id'] : int.tryParse(json['property_id'].toString()) ?? 0,
      file: json['file']?.toString() ?? '',
      type: json['type']?.toString() ?? 'rental',
      doucType: json['douc_type']?.toString(),
      createdAt: DateTime.parse(json['created_at']?.toString() ?? DateTime.now().toString()),
      updatedAt: DateTime.parse(json['updated_at']?.toString() ?? DateTime.now().toString()),
    );
  }
}

class StateModel {
  final int id;
  final String stateName;
  final int status;
  final DateTime createdAt;
  final DateTime updatedAt;

  StateModel({
    required this.id,
    required this.stateName,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StateModel.fromJson(Map<String, dynamic> json) {
    return StateModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      stateName: json['state_name']?.toString() ?? '',
      status: json['status'] is int ? json['status'] : int.tryParse(json['status'].toString() ?? '1') ?? 1,
      createdAt: DateTime.parse(json['created_at']?.toString() ?? DateTime.now().toString()),
      updatedAt: DateTime.parse(json['updated_at']?.toString() ?? DateTime.now().toString()),
    );
  }
}

class CityModel {
  final int id;
  final int stateId;
  final String cityName;
  final int status;
  final DateTime createdAt;
  final DateTime updatedAt;

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
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      stateId: json['state_id'] is int ? json['state_id'] : int.tryParse(json['state_id'].toString()) ?? 0,
      cityName: json['city_name']?.toString() ?? '',
      status: json['status'] is int ? json['status'] : int.tryParse(json['status'].toString() ?? '1') ?? 1,
      createdAt: DateTime.parse(json['created_at']?.toString() ?? DateTime.now().toString()),
      updatedAt: DateTime.parse(json['updated_at']?.toString() ?? DateTime.now().toString()),
    );
  }
}

class PropertyTypeModel {
  final int id;
  final String typeName;

  PropertyTypeModel({
    required this.id,
    required this.typeName,
  });

  factory PropertyTypeModel.fromJson(Map<String, dynamic> json) {
    return PropertyTypeModel(
      id: json['id'] ?? json['property_type_id'] ?? 0,
      typeName: json['type_name'] ?? json['property_type'] ?? '',
    );
  }
}

// Nearby Location model for LIST API
class NearbyLocationModel {
  final int? id;
  final String? title;
  final String? image;
  final PivotModel? pivot;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  NearbyLocationModel({
    this.id,
    this.title,
    this.image,
    this.pivot,
    this.createdAt,
    this.updatedAt,
  });

  factory NearbyLocationModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic dateValue) {
      if (dateValue == null) return null;
      try {
        return DateTime.parse(dateValue.toString());
      } catch (e) {
        return null;
      }
    }

    return NearbyLocationModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()),
      title: json['title']?.toString(),
      image: json['image']?.toString(),
      pivot: json['pivot'] != null ? PivotModel.fromJson(json['pivot']) : null,
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
    );
  }
}

class PivotModel {
  final int? rentalPropertyId;
  final int? nearbyLocationId;
  final String? distance;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PivotModel({
    this.rentalPropertyId,
    this.nearbyLocationId,
    this.distance,
    this.createdAt,
    this.updatedAt,
  });

  factory PivotModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic dateValue) {
      if (dateValue == null) return null;
      try {
        return DateTime.parse(dateValue.toString());
      } catch (e) {
        return null;
      }
    }

    return PivotModel(
      rentalPropertyId: json['rental_property_id'] is int ? json['rental_property_id'] : int.tryParse(json['rental_property_id'].toString()),
      nearbyLocationId: json['nearby_location_id'] is int ? json['nearby_location_id'] : int.tryParse(json['nearby_location_id'].toString()),
      distance: json['distance']?.toString(),
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
    );
  }
}

// rental_list_model.dart
class RentalListResponse {
  final int status;
  final RentalListData data;

  RentalListResponse({
    required this.status,
    required this.data,
  });

  factory RentalListResponse.fromJson(Map<String, dynamic> json) {
    return RentalListResponse(
      status: json['status'] ?? 200,
      data: RentalListData.fromJson(json['data'] ?? {}),
    );
  }
}

class RentalListData {
  final List<RentalListProperty> rentals;
  final Pagination pagination;
  final List<StateModel> stateList;
  final double priceMin;
  final double priceMax;

  RentalListData({
    required this.rentals,
    required this.pagination,
    required this.stateList,
    required this.priceMin,
    required this.priceMax,
  });

  factory RentalListData.fromJson(Map<String, dynamic> json) {
    // Parse rentals
    List<RentalListProperty> rentals = [];
    if (json['rental'] is List) {
      for (var item in json['rental']) {
        rentals.add(RentalListProperty.fromJson(item));
      }
    }

    // Parse pagination
    final pagination = Pagination.fromJson(json['pagination'] ?? {});

    // Parse state list
    List<StateModel> stateList = [];
    if (json['state_list'] is List) {
      for (var item in json['state_list']) {
        stateList.add(StateModel.fromJson(item));
      }
    }

    // Parse price range
    double priceMin = 0.0;
    double priceMax = 0.0;
    try {
      priceMin = double.tryParse(json['price_min']?.toString() ?? '0') ?? 0.0;
      priceMax = double.tryParse(json['price_max']?.toString() ?? '0') ?? 0.0;
    } catch (e) {
      print('Error parsing price range: $e');
    }

    return RentalListData(
      rentals: rentals,
      pagination: pagination,
      stateList: stateList,
      priceMin: priceMin,
      priceMax: priceMax,
    );
  }
}

class RentalListProperty {
  final int id;
  final String name;
  final String? type;
  final String address;
  final String rentAmount;
  final String? area;
  final String yieldAmount;
  final String description;
  final String? plotImage;
  final List<String> files;
  final CityModel? city;
  final StateModel? state;
  final List<AmenityModel> amenities;
  final List<RentalDocument> documents;
  final List<NearbyLocationModel> nearbyLocations;
  final List<NearbyPlace>? nearbyPlaces;
  final double? lat;
  final double? lng;
  final int status;
  final int featured;
  final int verifyStatus;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Get images list (files as images)
  List<String> get images => files;

  // Get city name
  String get cityName => city?.cityName ?? '';

  // Get state name
  String get stateName => state?.stateName ?? '';

  // Get full location
  String get fullLocation {
    final parts = [cityName, stateName].where((e) => e.isNotEmpty).toList();
    return parts.isNotEmpty ? parts.join(', ') : address;
  }

  // Get display rent
  String get displayRent {
    try {
      final amount = double.tryParse(rentAmount) ?? 0;
      if (amount >= 100000) {
        return '₹${(amount / 100000).toStringAsFixed(1)}L/month';
      } else if (amount >= 1000) {
        return '₹${(amount / 1000).toStringAsFixed(1)}K/month';
      }
      return '₹${amount.toInt()}/month';
    } catch (e) {
      return '₹$rentAmount/month';
    }
  }

  // Get rent as double
  double get rentAmountDouble {
    return double.tryParse(rentAmount) ?? 0.0;
  }

  // Get yield as double
  double get yieldAmountDouble {
    return double.tryParse(yieldAmount) ?? 0.0;
  }

  // Get area as double
  double? get areaDouble {
    if (area == null) return null;
    return double.tryParse(area!);
  }

  RentalListProperty({
    required this.id,
    required this.name,
    this.type,
    required this.address,
    required this.rentAmount,
    this.area,
    required this.yieldAmount,
    required this.description,
    this.plotImage,
    required this.files,
    this.city,
    this.state,
    required this.amenities,
    required this.documents,
    required this.nearbyLocations,
    this.nearbyPlaces,
    this.lat,
    this.lng,
    required this.status,
    required this.featured,
    required this.verifyStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RentalListProperty.fromJson(Map<String, dynamic> json) {
    // Helper functions
    double? parseDouble(dynamic value) {
      if (value == null) return null;
      try {
        if (value is double) return value;
        if (value is int) return value.toDouble();
        if (value is String) return double.tryParse(value);
        return null;
      } catch (e) {
        return null;
      }
    }

    DateTime parseDate(dynamic value) {
      try {
        if (value == null) return DateTime.now();
        return DateTime.parse(value.toString());
      } catch (e) {
        return DateTime.now();
      }
    }

    // Parse files
    List<String> files = [];
    if (json['files'] is List) {
      for (var file in json['files']) {
        if (file != null) files.add(file.toString());
      }
    }

    // Parse city
    CityModel? city;
    if (json['city'] is Map<String, dynamic>) {
      city = CityModel.fromJson(json['city']);
    }

    // Parse state
    StateModel? state;
    if (json['state'] is Map<String, dynamic>) {
      state = StateModel.fromJson(json['state']);
    }

    // Parse amenities
    List<AmenityModel> amenities = [];
    if (json['amenity'] is List) {
      for (var item in json['amenity']) {
        try {
          amenities.add(AmenityModel.fromJson(item));
        } catch (e) {
          print('Error parsing amenity: $e');
        }
      }
    }

    // Parse documents
    List<RentalDocument> documents = [];
    if (json['documents'] is List) {
      for (var item in json['documents']) {
        try {
          documents.add(RentalDocument.fromJson(item));
        } catch (e) {
          print('Error parsing document: $e');
        }
      }
    }

    // Parse nearby locations
    List<NearbyLocationModel> nearbyLocations = [];
    if (json['nearby_locations'] is List) {
      for (var item in json['nearby_locations']) {
        try {
          nearbyLocations.add(NearbyLocationModel.fromJson(item));
        } catch (e) {
          print('Error parsing nearby location: $e');
        }
      }
    }

    // Parse nearby places
    List<NearbyPlace>? nearbyPlaces;
    if (json['nearby_places'] is List) {
      nearbyPlaces = [];
      for (var item in json['nearby_places']) {
        try {
          nearbyPlaces.add(NearbyPlace.fromJson(item));
        } catch (e) {
          print('Error parsing nearby place: $e');
        }
      }
    }

    return RentalListProperty(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? 'Unnamed Property',
      type: json['type']?.toString(),
      address: json['address']?.toString() ?? 'Address not available',
      rentAmount: json['rent_amount']?.toString() ?? '0',
      area: json['area']?.toString(),
      yieldAmount: json['yield_amount']?.toString() ?? '0',
      description: json['description']?.toString() ?? 'No description',
      plotImage: json['plot_image']?.toString(),
      files: files,
      city: city,
      state: state,
      amenities: amenities,
      documents: documents,
      nearbyLocations: nearbyLocations,
      nearbyPlaces: nearbyPlaces,
      lat: parseDouble(json['lat']),
      lng: parseDouble(json['lng']),
      status: json['status'] is int ? json['status'] : int.tryParse(json['status'].toString() ?? '0') ?? 0,
      featured: json['featured'] is int ? json['featured'] : int.tryParse(json['featured'].toString() ?? '0') ?? 0,
      verifyStatus: json['verify_status'] is int ? json['verify_status'] : int.tryParse(json['verify_status'].toString() ?? '0') ?? 0,
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
    );
  }
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
      currentPage: json['current_page'] ?? 1,
      total: json['total'] ?? 0,
      perPage: json['per_page'] ?? 10,
      lastPage: json['last_page'] ?? 1,
    );
  }
}

// rental_detail_model.dart
class RentalDetailResponse {
  final bool status;
  final RentalDetailProperty data;

  RentalDetailResponse({
    required this.status,
    required this.data,
  });

  factory RentalDetailResponse.fromJson(Map<String, dynamic> json) {
    return RentalDetailResponse(
      status: json['status'] ?? false,
      data: RentalDetailProperty.fromJson(json['data'] ?? {}),
    );
  }
}

class RentalDetailProperty {
  final int id;
  final String name;
  final String? type;
  final String address;
  final String rentAmount;
  final String? area;
  final String yieldAmount;
  final String description;
  final String? plotImage;
  final List<String> files;
  final CityModel? city;
  final StateModel? state;
  final List<AmenityModel> amenities;
  final List<RentalDocument> documents;
  final List<NearbyLocationDetail> nearbyLocations;
  final List<dynamic>? nearbyPlaces;
  final double? lat;
  final double? lng;
  final int? agentId;
  final int status;
  final int featured;
  final int verifyStatus;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Special fields from details API
  final bool doucmentVerficaiton;
  final double amountPay;

  // Get images list
  List<String> get images => files;

  // Get city name
  String get cityName => city?.cityName ?? '';

  // Get state name
  String get stateName => state?.stateName ?? '';

  String get fullLocation {
    final parts = [cityName, stateName].where((e) => e.isNotEmpty).toList();
    return parts.isNotEmpty ? parts.join(', ') : address;
  }

  String get displayRent {
    try {
      final amount = double.tryParse(rentAmount) ?? 0;
      if (amount >= 100000) {
        return '₹${(amount / 100000).toStringAsFixed(1)}L/month';
      } else if (amount >= 1000) {
        return '₹${(amount / 1000).toStringAsFixed(1)}K/month';
      }
      return '₹${amount.toInt()}/month';
    } catch (e) {
      return '₹$rentAmount/month';
    }
  }
  double get rentAmountDouble {
    return double.tryParse(rentAmount) ?? 0.0;
  }
  double get yieldAmountDouble {
    return double.tryParse(yieldAmount) ?? 0.0;
  }
  bool get hasPaidForDocuments => doucmentVerficaiton;
  double get totalDocumentPrice => amountPay;

  RentalDetailProperty({
    required this.id,
    required this.name,
    this.type,
    required this.address,
    required this.rentAmount,
    this.area,
    required this.yieldAmount,
    required this.description,
    this.plotImage,
    required this.files,
    this.city,
    this.state,
    required this.amenities,
    required this.documents,
    required this.nearbyLocations,
    this.nearbyPlaces,
    this.lat,
    this.lng,
    this.agentId,
    required this.status,
    required this.featured,
    required this.verifyStatus,
    required this.createdAt,
    required this.updatedAt,
    this.doucmentVerficaiton = false,
    this.amountPay = 0.0,
  });

  factory RentalDetailProperty.fromJson(Map<String, dynamic> json) {
    double? parseDouble(dynamic value) {
      if (value == null) return null;
      try {
        if (value is double) return value;
        if (value is int) return value.toDouble();
        if (value is String) return double.tryParse(value);
        return null;
      } catch (e) {
        return null;
      }
    }

    bool parseBool(dynamic value) {
      if (value == null) return false;
      if (value is bool) return value;
      if (value is int) return value == 1;
      if (value is String) return value.toLowerCase() == 'true' || value == '1';
      return false;
    }

    DateTime parseDate(dynamic value) {
      try {
        if (value == null) return DateTime.now();
        return DateTime.parse(value.toString());
      } catch (e) {
        return DateTime.now();
      }
    }

    // Parse files
    List<String> files = [];
    if (json['files'] is List) {
      for (var file in json['files']) {
        if (file != null) files.add(file.toString());
      }
    }

    // Parse city
    CityModel? city;
    if (json['city'] is Map<String, dynamic>) {
      city = CityModel.fromJson(json['city']);
    }

    // Parse state
    StateModel? state;
    if (json['state'] is Map<String, dynamic>) {
      state = StateModel.fromJson(json['state']);
    }

    // Parse amenities
    List<AmenityModel> amenities = [];
    if (json['amenity'] is List) {
      for (var item in json['amenity']) {
        try {
          amenities.add(AmenityModel.fromJson(item));
        } catch (e) {
          print('Error parsing amenity: $e');
        }
      }
    }

    // Parse documents
    List<RentalDocument> documents = [];
    if (json['documents'] is List) {
      for (var item in json['documents']) {
        try {
          documents.add(RentalDocument.fromJson(item));
        } catch (e) {
          print('Error parsing document: $e');
        }
      }
    }

    // Parse nearby locations
    List<NearbyLocationDetail> nearbyLocations = [];
    if (json['nearbyLocations'] is List) {
      for (var item in json['nearbyLocations']) {
        try {
          nearbyLocations.add(NearbyLocationDetail.fromJson(item));
        } catch (e) {
          print('Error parsing nearby location: $e');
        }
      }
    }

    // If nearbyLocations is empty, try nearby_locations field
    if (nearbyLocations.isEmpty && json['nearby_locations'] is List) {
      for (var item in json['nearby_locations']) {
        try {
          nearbyLocations.add(NearbyLocationDetail.fromJson(item));
        } catch (e) {
          print('Error parsing nearby location from alternative field: $e');
        }
      }
    }

    return RentalDetailProperty(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? 'Unnamed Property',
      type: json['type']?.toString(),
      address: json['address']?.toString() ?? 'Address not available',
      rentAmount: json['rent_amount']?.toString() ?? '0',
      area: json['area']?.toString(),
      yieldAmount: json['yield_amount']?.toString() ?? '0',
      description: json['description']?.toString() ?? 'No description',
      plotImage: json['plot_image']?.toString(),
      files: files,
      city: city,
      state: state,
      amenities: amenities,
      documents: documents,
      nearbyLocations: nearbyLocations,
      nearbyPlaces: json['nearby_places'] is List ? json['nearby_places'] : null,
      lat: parseDouble(json['lat']),
      lng: parseDouble(json['lng']),
      agentId: json['agent_id'] is int ? json['agent_id'] : int.tryParse(json['agent_id'].toString() ?? ''),
      status: json['status'] is int ? json['status'] : int.tryParse(json['status'].toString() ?? '0') ?? 0,
      featured: json['featured'] is int ? json['featured'] : int.tryParse(json['featured'].toString() ?? '0') ?? 0,
      verifyStatus: json['verify_status'] is int ? json['verify_status'] : int.tryParse(json['verify_status'].toString() ?? '0') ?? 0,
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
      doucmentVerficaiton: parseBool(json['doucment_verficaiton']),
      amountPay: parseDouble(json['amount_pay']) ?? 0.0,
    );
  }
}

// Nearby Location detail model for DETAIL API
class NearbyLocationDetail {
  final int id;
  final String title;
  final String image;
  final DateTime createdAt;
  final DateTime updatedAt;
  final NearbyLocationPivot pivot;

  NearbyLocationDetail({
    required this.id,
    required this.title,
    required this.image,
    required this.createdAt,
    required this.updatedAt,
    required this.pivot,
  });

  factory NearbyLocationDetail.fromJson(Map<String, dynamic> json) {
    return NearbyLocationDetail(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      title: json['title']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      createdAt: DateTime.parse(json['created_at']?.toString() ?? DateTime.now().toString()),
      updatedAt: DateTime.parse(json['updated_at']?.toString() ?? DateTime.now().toString()),
      pivot: NearbyLocationPivot.fromJson(json['pivot'] ?? {}),
    );
  }

  // Get distance in km
  String get distance {
    try {
      final dist = double.tryParse(pivot.distance) ?? 0;
      return '${dist.toStringAsFixed(1)} km';
    } catch (e) {
      return '${pivot.distance} km';
    }
  }

  // Get distance as double
  double get distanceDouble {
    try {
      return double.tryParse(pivot.distance) ?? 0.0;
    } catch (e) {
      return 0.0;
    }
  }
}

class NearbyLocationPivot {
  final int rentalPropertyId;
  final int nearbyLocationId;
  final String distance;
  final DateTime createdAt;
  final DateTime updatedAt;

  NearbyLocationPivot({
    required this.rentalPropertyId,
    required this.nearbyLocationId,
    required this.distance,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NearbyLocationPivot.fromJson(Map<String, dynamic> json) {
    return NearbyLocationPivot(
      rentalPropertyId: json['rental_property_id'] is int ? json['rental_property_id'] : int.tryParse(json['rental_property_id'].toString()) ?? 0,
      nearbyLocationId: json['nearby_location_id'] is int ? json['nearby_location_id'] : int.tryParse(json['nearby_location_id'].toString()) ?? 0,
      distance: json['distance']?.toString() ?? '0',
      createdAt: DateTime.parse(json['created_at']?.toString() ?? DateTime.now().toString()),
      updatedAt: DateTime.parse(json['updated_at']?.toString() ?? DateTime.now().toString()),
    );
  }
}

// rental_enquiry_model.dart
class RentalEnquiry {
  final int id;
  final int userId;
  final int propertyId;
  final int counts;
  final DateTime createdAt;
  final DateTime updatedAt;
  final RentalEnquiryProperty? property;

  RentalEnquiry({
    required this.id,
    required this.userId,
    required this.propertyId,
    required this.counts,
    required this.createdAt,
    required this.updatedAt,
    this.property,
  });

  factory RentalEnquiry.fromJson(Map<String, dynamic> json) {
    return RentalEnquiry(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      propertyId: json['property_id'] ?? 0,
      counts: json['counts'] ?? 1,
      createdAt: DateTime.parse(json['created_at']?.toString() ?? DateTime.now().toString()),
      updatedAt: DateTime.parse(json['updated_at']?.toString() ?? DateTime.now().toString()),
      property: json['property'] != null ? RentalEnquiryProperty.fromJson(json['property']) : null,
    );
  }

  // Get enquiry status
  String get status {
    if (counts > 0) return 'Active';
    return 'Closed';
  }

  // Get formatted date
  String get formattedDate {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }
}

class RentalEnquiryProperty {
  final int id;
  final String name;
  final String? type;
  final String? lat;
  final String? lng;
  final String address;
  final int? cityId;
  final int? stateId;
  final String rentAmount;
  final String? yieldAmount;
  final String? description;
  final List<String> files;
  final List<NearbyPlace> nearbyPlaces;

  RentalEnquiryProperty({
    required this.id,
    required this.name,
    this.type,
    this.lat,
    this.lng,
    required this.address,
    this.cityId,
    this.stateId,
    required this.rentAmount,
    this.yieldAmount,
    this.description,
    required this.files,
    required this.nearbyPlaces,
  });

  factory RentalEnquiryProperty.fromJson(Map<String, dynamic> json) {
    // Parse files list
    List<String> files = [];
    if (json['files'] is List) {
      for (var file in json['files']) {
        if (file is String) {
          files.add(file);
        } else if (file != null) {
          files.add(file.toString());
        }
      }
    }

    // Parse nearby places
    List<NearbyPlace> nearbyPlaces = [];
    if (json['nearby_places'] is List) {
      for (var place in json['nearby_places']) {
        try {
          nearbyPlaces.add(NearbyPlace.fromJson(place));
        } catch (e) {
          print('Error parsing nearby place: $e');
        }
      }
    }

    return RentalEnquiryProperty(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? 'Unnamed Property',
      type: json['type']?.toString(),
      lat: json['lat']?.toString(),
      lng: json['lng']?.toString(),
      address: json['address']?.toString() ?? 'Address not available',
      cityId: _parseInt(json['city']),
      stateId: _parseInt(json['state']),
      rentAmount: json['rent_amount']?.toString() ?? '0',
      yieldAmount: json['yield_amount']?.toString(),
      description: json['description']?.toString(),
      files: files,
      nearbyPlaces: nearbyPlaces,
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is Map<String, dynamic>) {
      return value['id'] is int ? value['id'] : int.tryParse(value['id']?.toString() ?? '');
    }
    if (value is String) {
      try {
        return int.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // Get formatted rent amount
  String get formattedRent {
    try {
      final amount = double.tryParse(rentAmount) ?? 0;
      if (amount >= 10000000) {
        return '₹${(amount / 10000000).toStringAsFixed(2)} Cr';
      } else if (amount >= 100000) {
        return '₹${(amount / 100000).toStringAsFixed(2)} L';
      } else if (amount >= 1000) {
        return '₹${(amount / 1000).toStringAsFixed(1)}K/month';
      } else {
        return '₹${amount.toStringAsFixed(0)}/month';
      }
    } catch (e) {
      return '₹$rentAmount/month';
    }
  }

  // Get first image or placeholder
  String get thumbnail {
    return files.isNotEmpty ? files.first : 'https://via.placeholder.com/150';
  }

  // Get images list
  List<String> get images => files;
}

// Nearby Place Model
class NearbyPlace {
  final int placeId;
  final double distance;

  NearbyPlace({
    required this.placeId,
    required this.distance,
  });

  factory NearbyPlace.fromJson(Map<String, dynamic> json) {
    return NearbyPlace(
      placeId: json['place_id'] ?? 0,
      distance: (json['distance'] is double)
          ? json['distance']
          : (json['distance'] is int)
          ? json['distance'].toDouble()
          : double.tryParse(json['distance']?.toString() ?? '0') ?? 0.0,
    );
  }

  // Get formatted distance
  String get formattedDistance {
    return '${distance.toStringAsFixed(1)} km';
  }
}