// models/gioo_plot.dart

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
  final dynamic unitSplit; // Changed from int to dynamic to match JSON
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
    required this.images,
    required this.plotImage,
    required this.work,
    required this.agentId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.propertyType,
  });

  factory GiooPlot.fromJson(Map<String, dynamic> json) {
    // Helper method to parse images
    List<String> parseImages(dynamic imageData) {
      if (imageData == null) return [];
      if (imageData is String) {
        return [imageData];
      } else if (imageData is List) {
        return imageData.map((item) => item?.toString() ?? '').where((item) => item.isNotEmpty).toList();
      }
      return [];
    }

    return GiooPlot(
      id: json['id'] ?? 0,
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
      unitSplit: json['unit_spilt'],
      images: parseImages(json['image']),
      plotImage: json['plot_image']?.toString() ?? '',
      work: json['work']?.toString() ?? '',
      agentId: json['agent_id']?.toString(),
      status: json['status'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at']?.toString() ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at']?.toString() ?? DateTime.now().toIso8601String()),
      propertyType: json['property_type'] != null ? PropertyType.fromJson(json['property_type']) : null,
    );
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
      id: json['id'] ?? 0,
      categoryName: json['category_name']?.toString() ?? '',
      status: json['status'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at']?.toString() ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at']?.toString() ?? DateTime.now().toIso8601String()),
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
      id: json['id'] ?? 0,
      stateId: json['state_id'] ?? 0,
      cityName: json['city_name']?.toString() ?? '',
      status: json['status'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at']?.toString() ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at']?.toString() ?? DateTime.now().toIso8601String()),
    );
  }
}

class AppState {
  final int id;
  final String stateName;
  final int status;
  final DateTime createdAt;
  final DateTime updatedAt;

  AppState({
    required this.id,
    required this.stateName,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AppState.fromJson(Map<String, dynamic> json) {
    return AppState(
      id: json['id'] ?? 0,
      stateName: json['state_name']?.toString() ?? '',
      status: json['status'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at']?.toString() ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at']?.toString() ?? DateTime.now().toIso8601String()),
    );
  }
}

// UPDATED Property model for GiooBuyingList
class Property {
  final int id;
  final String name;
  final int type;
  final String? map;
  final String lat;
  final String long;
  final String address;
  final City? city; // Updated from String to City?
  final AppState? state; // Updated from String to AppState?
  final String area;
  final String price;
  final String description;
  final dynamic unitSpilt;
  final List<String> images; // Updated from String to List<String>
  final String? plotImage;
  final String work;
  final String agentId;
  final int status;
  final int featured;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String aminities;
  final String? bluePrint;
  final String totalPrice;
  final String uldNo;
  final int adminBlock;
  final List<NearbyPlace> nearbyPlaces;
  final int soldStatus;

  Property({
    required this.id,
    required this.name,
    required this.type,
    this.map,
    required this.lat,
    required this.long,
    required this.address,
    required this.city,
    required this.state,
    required this.area,
    required this.price,
    required this.description,
    required this.unitSpilt,
    required this.images,
    this.plotImage,
    required this.work,
    required this.agentId,
    required this.status,
    required this.featured,
    required this.createdAt,
    required this.updatedAt,
    required this.aminities,
    this.bluePrint,
    required this.totalPrice,
    required this.uldNo,
    required this.adminBlock,
    required this.nearbyPlaces,
    required this.soldStatus,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    // Helper method to parse images
    List<String> parseImages(dynamic imageData) {
      if (imageData == null) return [];
      if (imageData is String) {
        return [imageData];
      } else if (imageData is List) {
        return imageData.map((item) => item?.toString() ?? '').where((item) => item.isNotEmpty).toList();
      }
      return [];
    }

    // Helper method to parse city and state
    City? parseCity(dynamic cityData) {
      if (cityData == null) return null;
      if (cityData is Map<String, dynamic>) {
        return City.fromJson(cityData);
      } else if (cityData is String) {
        // If city is just a string name, create a minimal City object
        return City(
          id: 0,
          stateId: 0,
          cityName: cityData,
          status: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }
      return null;
    }

    AppState? parseState(dynamic stateData) {
      if (stateData == null) return null;
      if (stateData is Map<String, dynamic>) {
        return AppState.fromJson(stateData);
      } else if (stateData is String) {
        // If state is just a string name, create a minimal AppState object
        return AppState(
          id: 0,
          stateName: stateData,
          status: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }
      return null;
    }

    return Property(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      type: json['type'] ?? 0,
      map: json['map'],
      lat: json['lat'] ?? '',
      long: json['long'] ?? '',
      address: json['address'] ?? '',
      city: parseCity(json['city']),
      state: parseState(json['state']),
      area: json['area'] ?? '',
      price: json['price'] ?? '',
      description: json['description'] ?? '',
      unitSpilt: json['unit_spilt'],
      images: parseImages(json['image']),
      plotImage: json['plot_image'],
      work: json['work'] ?? '',
      agentId: json['agent_id']?.toString() ?? '',
      status: json['status'] ?? 0,
      featured: json['featured'] ?? 0,
      createdAt: DateTime.parse(json['created_at']?.toString() ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at']?.toString() ?? DateTime.now().toIso8601String()),
      aminities: json['aminities'] ?? '',
      bluePrint: json['blue_print'],
      totalPrice: json['total_price'] ?? '0',
      uldNo: json['uld_no'] ?? '',
      adminBlock: json['admin_block'] ?? 0,
      nearbyPlaces: (json['nearby_places'] as List<dynamic>?)
          ?.map((place) => NearbyPlace.fromJson(place))
          .toList() ?? [],
      soldStatus: json['sold_status'] ?? 0,
    );
  }

  // Get city name as string for backward compatibility
  String get cityName => city?.cityName ?? '';

  // Get state name as string for backward compatibility
  String get stateName => state?.stateName ?? '';

  // Get first image for backward compatibility
  String get firstImage => images.isNotEmpty ? images.first : '';
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
      placeId: json['place_id'] ?? 0,
      distance: json['distance'] ?? 0,
    );
  }
}

class User {
  final int id;
  final int role;
  final int isVendor;
  final int isAgent;
  final int isServices;
  final String name;
  final String email;
  final DateTime? emailVerifiedAt;
  final String dob;
  final String avatar;
  final String pin;
  final int gender;
  final String address;
  final String phone;
  final int status;
  final int agentRequest;
  final int vendorRequest;
  final int serviceRequest;
  final DateTime createdAt;
  final DateTime updatedAt;
  final dynamic fcmToken;

  User({
    required this.id,
    required this.role,
    required this.isVendor,
    required this.isAgent,
    required this.isServices,
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
    required this.agentRequest,
    required this.vendorRequest,
    required this.serviceRequest,
    required this.createdAt,
    required this.updatedAt,
    required this.fcmToken,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      role: json['role'] ?? 0,
      isVendor: json['is_vendor'] ?? 0,
      isAgent: json['is_agent'] ?? 0,
      isServices: json['is_services'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      emailVerifiedAt: json['email_verified_at'] != null
          ? DateTime.parse(json['email_verified_at'])
          : null,
      dob: json['dob'] ?? '',
      avatar: json['avatar'] ?? '',
      pin: json['pin'] ?? '',
      gender: json['gender'] ?? 0,
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      status: json['status'] ?? 0,
      agentRequest: json['agent_request'] ?? 0,
      vendorRequest: json['vendor_request'] ?? 0,
      serviceRequest: json['service_request'] ?? 0,
      createdAt: DateTime.parse(json['created_at']?.toString() ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at']?.toString() ?? DateTime.now().toIso8601String()),
      fcmToken: json['fcm_token'],
    );
  }
}

// Add these new models for the JSON response
class WeeklyGraph {
  final String day;
  final int total;

  WeeklyGraph({
    required this.day,
    required this.total,
  });

  factory WeeklyGraph.fromJson(Map<String, dynamic> json) {
    return WeeklyGraph(
      day: json['day'] ?? '',
      total: json['total'] ?? 0,
    );
  }
}

class MonthlyGraph {
  final String month;
  final int total;

  MonthlyGraph({
    required this.month,
    required this.total,
  });

  factory MonthlyGraph.fromJson(Map<String, dynamic> json) {
    return MonthlyGraph(
      month: json['month'] ?? '',
      total: json['total'] ?? 0,
    );
  }
}

// In your model file (gioo_plot.dart)

class OverallBooked {
  final int totalBookedUnits;
  final double growth; // Changed from int to double

  OverallBooked({
    required this.totalBookedUnits,
    required this.growth,
  });

  factory OverallBooked.fromJson(Map<String, dynamic> json) {
    return OverallBooked(
      totalBookedUnits: json['total_booked_units'] ?? 0,
      growth: (json['growth'] as num?)?.toDouble() ?? 0.0, // Convert to double
    );
  }
}

class WeeklyBooked {
  final String weeklyProfit;
  final int unitsBooked;
  final double growth; // Changed from int to double
  final double profitMargin; // Changed from int to double

  WeeklyBooked({
    required this.weeklyProfit,
    required this.unitsBooked,
    required this.growth,
    required this.profitMargin,
  });

  factory WeeklyBooked.fromJson(Map<String, dynamic> json) {
    return WeeklyBooked(
      weeklyProfit: json['weekly_profit']?.toString() ?? '0',
      unitsBooked: json['units_booked'] ?? 0,
      growth: (json['growth'] as num?)?.toDouble() ?? 0.0, // Convert to double
      profitMargin: (json['profit_margin'] as num?)?.toDouble() ?? 0.0, // Convert to double
    );
  }
}

class NearbyLocation {
  final int id;
  final String title;
  final String image;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Pivot pivot;

  NearbyLocation({
    required this.id,
    required this.title,
    required this.image,
    required this.createdAt,
    required this.updatedAt,
    required this.pivot,
  });

  factory NearbyLocation.fromJson(Map<String, dynamic> json) {
    return NearbyLocation(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      image: json['image'] ?? '',
      createdAt: DateTime.parse(json['created_at']?.toString() ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at']?.toString() ?? DateTime.now().toIso8601String()),
      pivot: Pivot.fromJson(json['pivot'] ?? {}),
    );
  }
}

class Pivot {
  final int geoPropertyId;
  final int nearbyLocationId;
  final int distance;
  final DateTime createdAt;
  final DateTime updatedAt;

  Pivot({
    required this.geoPropertyId,
    required this.nearbyLocationId,
    required this.distance,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Pivot.fromJson(Map<String, dynamic> json) {
    return Pivot(
      geoPropertyId: json['geo_property_id'] ?? 0,
      nearbyLocationId: json['nearby_location_id'] ?? 0,
      distance: json['distance'] ?? 0,
      createdAt: DateTime.parse(json['created_at']?.toString() ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at']?.toString() ?? DateTime.now().toIso8601String()),
    );
  }
}

// Complete GiooPlotDetail model
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
  final dynamic unitSpilt;
  final List<String> images;
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
  final List<User> users;
  final List<WeeklyGraph> weeklyGraph;
  final List<MonthlyGraph> monthlyGraph;
  final OverallBooked? overallBooked;
  final WeeklyBooked? weeklyBooked;
  final List<Amenity> amenity;
  final List<NearbyLocation> nearbyLocations;
  final List<Document> documents;
  final List<Booking> bookings;
  final List<NearbyLocation> nearby_locations;
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
    required this.images,
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
    required this.users,
    required this.weeklyGraph,
    required this.monthlyGraph,
    this.overallBooked,
    this.weeklyBooked,
    required this.amenity,
    required this.nearbyLocations,
    required this.documents,
    required this.bookings,
    required this.nearby_locations,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GiooPlotDetail.fromJson(Map<String, dynamic> json) {
    // Helper methods for parsing
    List<String> parseImages(dynamic imageData) {
      if (imageData == null) return [];
      if (imageData is String) return [imageData];
      if (imageData is List) return imageData.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
      return [];
    }

    List<User> parseUsers(dynamic users) {
      if (users == null || users is! List) return [];
      return users.map((e) => User.fromJson(e)).toList();
    }

    List<WeeklyGraph> parseWeeklyGraph(dynamic graph) {
      if (graph == null || graph is! List) return [];
      return graph.map((e) => WeeklyGraph.fromJson(e)).toList();
    }

    List<MonthlyGraph> parseMonthlyGraph(dynamic graph) {
      if (graph == null || graph is! List) return [];
      return graph.map((e) => MonthlyGraph.fromJson(e)).toList();
    }

    List<Amenity> parseAmenities(dynamic amenities) {
      if (amenities == null || amenities is! List) return [];
      return amenities.map((e) => Amenity.fromJson(e)).toList();
    }

    List<NearbyLocation> parseNearbyLocations(dynamic locations) {
      if (locations == null || locations is! List) return [];
      return locations.map((e) => NearbyLocation.fromJson(e)).toList();
    }

    List<Booking> parseBookings(dynamic bookings) {
      if (bookings == null || bookings is! List) return [];
      return bookings.map((e) => Booking.fromJson(e)).toList();
    }

    List<Document> parseDocuments(dynamic documents) {
      if (documents == null || documents is! List) return [];
      return documents.map((e) => Document.fromJson(e)).toList();
    }

    return GiooPlotDetail(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
      propertyType: json['property_type'] != null ? PropertyType.fromJson(json['property_type']) : null,
      map: json['map']?.toString(),
      address: json['address']?.toString() ?? '',
      lat: json['lat']?.toString() ?? '',
      long: json['long']?.toString() ?? '',
      city: json['city'] != null ? City.fromJson(json['city']) : null,
      state: json['state'] != null ? AppState.fromJson(json['state']) : null,
      area: json['area']?.toString() ?? '',
      price: json['price']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      unitSpilt: json['unit_spilt'],
      images: parseImages(json['image']),
      plotImage: json['plot_image']?.toString() ?? '',
      work: json['work']?.toString() ?? '',
      agentId: json['agent_id']?.toString() ?? '',
      status: json['status'] as int? ?? 0,
      featured: json['featured'] as int? ?? 0,
      aminities: json['aminities']?.toString(),
      bluePrint: json['blue_print']?.toString(),
      totalPrice: json['total_price']?.toString(),
      uldNo: json['uld_no']?.toString() ?? '',
      adminBlock: json['admin_block'] as int? ?? 0,
      adminblock: json['adminblock'] != null ? AdminBlock.fromJson(json['adminblock']) : null,
      users: parseUsers(json['user']),
      weeklyGraph: parseWeeklyGraph(json['weeklyGraph']),
      monthlyGraph: parseMonthlyGraph(json['monthlyGraph']),
      overallBooked: json['overall_booked'] != null ? OverallBooked.fromJson(json['overall_booked']) : null,
      weeklyBooked: json['weakly_booked'] != null ? WeeklyBooked.fromJson(json['weakly_booked']) : null,
      amenity: parseAmenities(json['amenity']),
      nearbyLocations: parseNearbyLocations(json['nearbyLocations']),
      documents: parseDocuments(json['documents']),
      bookings: parseBookings(json['booking']),
      nearby_locations: parseNearbyLocations(json['nearby_locations']),
      createdAt: DateTime.parse(json['created_at']?.toString() ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at']?.toString() ?? DateTime.now().toIso8601String()),
    );
  }
}

// The rest of your models remain the same...
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


// models/gioo_buying_model.dart
class GiooBuyingList {
  final int id;
  final int propertyId;
  final int userId;
  final String units;
  final double amount;
  final int transactionId;
  final double? returnAmount;
  final DateTime? returnDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Transaction transaction;
  final Property property;

  GiooBuyingList({
    required this.id,
    required this.propertyId,
    required this.userId,
    required this.units,
    required this.amount,
    required this.transactionId,
    this.returnAmount,
    this.returnDate,
    required this.createdAt,
    required this.updatedAt,
    required this.transaction,
    required this.property,
  });

  factory GiooBuyingList.fromJson(Map<String, dynamic> json) {
    return GiooBuyingList(
      id: json['id'] ?? 0,
      propertyId: json['property_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      units: json['units'] ?? '',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      transactionId: json['transaction_id'] ?? 0,
      returnAmount: json['return_amount'] != null
          ? double.tryParse(json['return_amount'].toString())
          : null,
      returnDate: json['return_date'] != null
          ? DateTime.parse(json['return_date'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      transaction: Transaction.fromJson(json['transaction']),
      property: Property.fromJson(json['property']),
    );
  }
}

class Transaction {
  final int id;
  final String transactionId;
  final String paymentMode;
  final String transactionDetails;
  final double amount;
  final dynamic isCompleted;
  final String status;
  final int propertyId;
  final int userId;
  final String type;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User user;

  Transaction({
    required this.id,
    required this.transactionId,
    required this.paymentMode,
    required this.transactionDetails,
    required this.amount,
    required this.isCompleted,
    required this.status,
    required this.propertyId,
    required this.userId,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] ?? 0,
      transactionId: json['transaction_id'] ?? '',
      paymentMode: json['payment_mode'] ?? '',
      transactionDetails: json['transaction_details'] ?? '',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      isCompleted: json['is_completed'],
      status: json['status'] ?? '',
      propertyId: json['property_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      type: json['type'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      user: User.fromJson(json['user']),
    );
  }
}


// Models for buying details
class GiooBuyingDetail {
  final int id;
  final int transactionId;
  final int propertyId;
  final int unit;
  final int cancelStatus;
  final DateTime? refundDate;
  final int refundStatus;
  final double amount;
  final double? refundAmount;
  final int returnStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Transaction transaction;
  final Property property;

  GiooBuyingDetail({
    required this.id,
    required this.transactionId,
    required this.propertyId,
    required this.unit,
    required this.cancelStatus,
    this.refundDate,
    required this.refundStatus,
    required this.amount,
    this.refundAmount,
    required this.returnStatus,
    required this.createdAt,
    required this.updatedAt,
    required this.transaction,
    required this.property,
  });

  factory GiooBuyingDetail.fromJson(Map<String, dynamic> json) {
    return GiooBuyingDetail(
      id: json['id'] ?? 0,
      transactionId: json['transaction_id'] ?? 0,
      propertyId: json['property_id'] ?? 0,
      unit: json['unit'] ?? 0,
      cancelStatus: json['cancel_status'] ?? 0,
      refundDate: json['refund_date'] != null
          ? DateTime.parse(json['refund_date'])
          : null,
      refundStatus: json['refund_status'] ?? 0,
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      refundAmount: json['refund_amount'] != null
          ? double.tryParse(json['refund_amount'].toString())
          : null,
      returnStatus: json['return_status'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      transaction: Transaction.fromJson(json['transaction']),
      property: Property.fromJson(json['property']),
    );
  }
}

// Response models
class GiooBuyingListResponse {
  final bool status;
  final List<GiooBuyingList> data;
  final Pagination pagination;

  GiooBuyingListResponse({
    required this.status,
    required this.data,
    required this.pagination,
  });

  factory GiooBuyingListResponse.fromJson(Map<String, dynamic> json) {
    return GiooBuyingListResponse(
      status: json['status'] ?? false,
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => GiooBuyingList.fromJson(item))
          .toList() ?? [],
      pagination: Pagination.fromJson(json['pagination']),
    );
  }
}

class GiooBuyingDetailResponse {
  final bool status;
  final List<GiooBuyingDetail> data;
  final Pagination pagination;

  GiooBuyingDetailResponse({
    required this.status,
    required this.data,
    required this.pagination,
  });

  factory GiooBuyingDetailResponse.fromJson(Map<String, dynamic> json) {
    return GiooBuyingDetailResponse(
      status: json['status'] ?? false,
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => GiooBuyingDetail.fromJson(item))
          .toList() ?? [],
      pagination: Pagination.fromJson(json['pagination']),
    );
  }
}

class Pagination {
  final int currentPage;
  final int perPage;
  final int total;
  final int lastPage;

  Pagination({
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.lastPage,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: json['current_page'] ?? 1,
      perPage: json['per_page'] ?? 10,
      total: json['total'] ?? 0,
      lastPage: json['last_page'] ?? 1,
    );
  }
}
