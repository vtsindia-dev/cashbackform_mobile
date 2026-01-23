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
// property_type.dart

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
  final String? documentPayment;
  final String? map;
  final String address;
  final String lat;
  final String long;
  final City? city;
  final AppState? state;
  final String area;
  final String price;
  final String description;
  final String adminDocumentPrice;
  final bool isDocumentVerified;
  final int unitSpilt;
  final String unit;
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
  final List<User> users;
  final String? adminBlockAmount;
  SyndicateDetail({
    required this.id,
    required this.name,
    this.propertyType,
    this.map,
    this.documentPayment,
    required this.address,
    required this.lat,
    required this.long,
    this.city,
    this.state,
    required this.area,
    required this.price,
    required this.description,
    required this.adminDocumentPrice,
    required this.isDocumentVerified,
    required this.unitSpilt,
    required this.unit,
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
    required this.users,
    this.adminBlockAmount,
  });

  factory SyndicateDetail.fromJson(Map<String, dynamic> json) {
    // Helper functions for safe parsing
    String safeString(dynamic value) => value?.toString() ?? '';
    int safeInt(dynamic value) => (value is int) ? value : int.tryParse(value.toString()) ?? 0;
    double safeDouble(dynamic value) => (value is num) ? value.toDouble() : double.tryParse(value.toString()) ?? 0.0;
    bool safeBool(dynamic value) {
      if (value is bool) return value;
      if (value is String) return value.toLowerCase() == 'true' || value == '1';
      if (value is num) return value == 1;
      return false;
    }

    // Parse images
    List<String> parseImages(dynamic images) {
      if (images == null) return [];
      if (images is List) {
        return images.map((e) => e.toString()).toList();
      }
      return [images.toString()];
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

    // Parse users
    List<User> parseUsers(dynamic users) {
      if (users == null || users is! List) return [];
      return users.map((e) => User.fromJson(e)).toList();
    }

    // Extract admin document price and verification status
    final adminDocumentPrice = safeString(json['admin_document'] ?? '0');
    final isDocumentVerified = safeBool(json['document_verified'] ?? false);

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
      adminDocumentPrice: adminDocumentPrice,
      isDocumentVerified: isDocumentVerified,
      unitSpilt: safeInt(json['unit_spilt']),
      unit: safeString(json['unit'] ?? ''),
      images: parseImages(json['image']),
      plotImage: safeString(json['plot_image']),
      work: safeString(json['work']),
      agentId: safeString(json['agent_id']),
      status: safeInt(json['status']),
      aminities: safeString(json['aminities'] ?? ''),
      uldNo: safeString(json['uld_no'] ?? ''),
      startingPrice: safeString(json['starting_price'] ?? '0'),
      amenities: parseAmenities(json['amenity']),
      documents: parseDocuments(json['documents']),
      bookings: parseBookings(json['booking']),
      users: parseUsers(json['user']),
      documentPayment: safeString(json['documentPayment'] ?? ''),
      adminBlockAmount: safeString(json['admin_block_amount'] ?? '0'),
    );
  }

  // Get unit areas in sq.ft
  List<double> get unitAreas {
    try {
      if (unit.isEmpty) return List.filled(unitSpilt, 0.0);
      return unit.split(',').map((e) => double.tryParse(e.trim()) ?? 0.0).toList();
    } catch (e) {
      return List.filled(unitSpilt, 0.0);
    }
  }

  // Get price per sq.ft
  double get pricePerSqFt {
    try {
      return double.tryParse(price.replaceAll(',', '')) ?? 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  double get documentPriceValue {
    try {
      return double.tryParse(adminDocumentPrice.replaceAll(',', '')) ?? 0.0;
    } catch (e) {
      return 0.0;
    }
  }

// Get admin document price
  double get adminDocumentPriceValue {
    try {
      return double.tryParse(adminDocumentPrice.replaceAll(',', '')) ?? 0.0;
    } catch (e) {
      return 0.0;
    }
  }

// ✅ TOTAL = admin_document + admin_block_amount
  double get totalDocumentPrice {
    return adminDocumentPriceValue;
  }

// Get formatted total document price
  String get formattedTotalDocumentPrice {
    return "₹${totalDocumentPrice.toStringAsFixed(2)}";
  }


  // Calculate price for a specific unit
  double calculateUnitPrice(int unitIndex) {
    if (unitIndex < 0 || unitIndex >= unitAreas.length) return 0.0;
    return unitAreas[unitIndex] * pricePerSqFt;
  }

  // Get area of a specific unit
  String getUnitArea(int unitIndex) {
    if (unitIndex < 0 || unitIndex >= unitAreas.length) return "0 sq.ft";
    return "${unitAreas[unitIndex]} sq.ft";
  }

  // Get total price for a specific unit including documents
  double calculateTotalUnitPrice(int unitIndex) {
    final unitPrice = calculateUnitPrice(unitIndex);
    return unitPrice + totalDocumentPrice;
  }

  String get formattedPricePerSqFt {
    return "₹${pricePerSqFt.toStringAsFixed(2)}/sq.ft";
  }
}
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

// syndicate_buying_models.dart

// Update your SyndicateBuyingList model to match API response

class SyndicateBuyingList {
  final int id;
  final int propertyId;
  final int userId;
  final String units;
  final dynamic amount;
  final dynamic transactionId;
  final double? returnAmount; // Add this
  final DateTime? returnDate; // Add this
  final DateTime createdAt;
  final DateTime updatedAt;
  final Transaction transaction;
  final SyndicateProperty property;

  SyndicateBuyingList({
    required this.id,
    required this.propertyId,
    required this.userId,
    required this.units,
    required this.amount,
    required this.transactionId,
    this.returnAmount, // Add this
    this.returnDate, // Add this
    required this.createdAt,
    required this.updatedAt,
    required this.transaction,
    required this.property,
  });

  factory SyndicateBuyingList.fromJson(Map<String, dynamic> json) {
    return SyndicateBuyingList(
      id: json['id'] ?? 0,
      propertyId: json['property_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      units: json['units']?.toString() ?? '',
      amount: json['amount'],
      transactionId: json['transaction_id'],
      returnAmount: json['return_amount'] != null
          ? double.tryParse(json['return_amount'].toString())
          : null, // Add this
      returnDate: json['return_date'] != null
          ? DateTime.tryParse(json['return_date'].toString())
          : null, // Add this
      createdAt: DateTime.parse(json['created_at'] ?? ''),
      updatedAt: DateTime.parse(json['updated_at'] ?? ''),
      transaction: Transaction.fromJson(json['transaction'] ?? {}),
      property: SyndicateProperty.fromJson(json['property'] ?? {}),
    );
  }

  // Helper getters
  double get amountValue {
    if (amount is String) {
      return double.tryParse(amount as String) ?? 0.0;
    } else if (amount is int) {
      return (amount as int).toDouble();
    } else if (amount is double) {
      return amount as double;
    }
    return 0.0;
  }

  String get transactionIdString {
    return transactionId?.toString() ?? '';
  }
}
// Update SyndicateProperty model based on API response
class SyndicateProperty {
  final int id;
  final String name;
  final dynamic type;
  final String? map;
  final String address;
  final String? lat;
  final String? long;
  final String? city;
  final String? state;
  final String? area;
  final String? price;
  final String? description;
  final int unitSpilt;
  final String? unit;
  final String? image;
  final String? plotImage;
  final String? work;
  final String? agentId;
  final int status;
  final int featured;
  final DateTime createdAt;
  final DateTime updatedAt;
  final dynamic aminities;
  final String? uldNo;
  final String? startingPrice;
  final List<dynamic> nearbyPlaces;
  final int soldStatus;

  SyndicateProperty({
    required this.id,
    required this.name,
    required this.type,
    this.map,
    required this.address,
    this.lat,
    this.long,
    this.city,
    this.state,
    this.area,
    this.price,
    this.description,
    required this.unitSpilt,
    this.unit,
    this.image,
    this.plotImage,
    this.work,
    this.agentId,
    required this.status,
    required this.featured,
    required this.createdAt,
    required this.updatedAt,
    this.aminities,
    this.uldNo,
    this.startingPrice,
    required this.nearbyPlaces,
    required this.soldStatus,
  });

  factory SyndicateProperty.fromJson(Map<String, dynamic> json) {
    return SyndicateProperty(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      type: json['type'],
      map: json['map'],
      address: json['address'] ?? '',
      lat: json['lat'],
      long: json['long'],
      city: json['city']?.toString(),
      state: json['state']?.toString(),
      area: json['area']?.toString(),
      price: json['price']?.toString(),
      description: json['description']?.toString(),
      unitSpilt: json['unit_spilt'] ?? 0,
      unit: json['unit']?.toString(),
      image: json['image']?.toString(),
      plotImage: json['plot_image']?.toString(),
      work: json['work']?.toString(),
      agentId: json['agent_id']?.toString(),
      status: json['status'] ?? 0,
      featured: json['featured'] ?? 0,
      createdAt: DateTime.parse(json['created_at'] ?? ''),
      updatedAt: DateTime.parse(json['updated_at'] ?? ''),
      aminities: json['aminities'],
      uldNo: json['uld_no']?.toString(),
      startingPrice: json['starting_price']?.toString(),
      nearbyPlaces: json['nearby_places'] is List ? json['nearby_places'] : [],
      soldStatus: json['sold_status'] ?? 0,
    );
  }

  // Helper to get first image
  String? get firstImage {
    if (image == null) return null;
    final images = image!.split(',');
    return images.isNotEmpty ? images.first : null;
  }

  // Helper to parse unit areas
  List<double> get unitAreas {
    if (unit == null || unit!.isEmpty) return [];
    try {
      return unit!.split(',').map((e) => double.tryParse(e.trim()) ?? 0.0).toList();
    } catch (e) {
      return [];
    }
  }
}

// Update Transaction model based on API
class Transaction {
  final int id;
  final String transactionId;
  final String paymentMode;
  final String transactionDetails;
  final String amount;
  final dynamic isCompleted;
  final String status;
  final int propertyId;
  final int userId;
  final String type;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> user;

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
      transactionId: json['transaction_id']?.toString() ?? '',
      paymentMode: json['payment_mode']?.toString() ?? '',
      transactionDetails: json['transaction_details']?.toString() ?? '',
      amount: json['amount']?.toString() ?? '0',
      isCompleted: json['is_completed'],
      status: json['status']?.toString() ?? '',
      propertyId: json['property_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      type: json['type']?.toString() ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? ''),
      updatedAt: DateTime.parse(json['updated_at'] ?? ''),
      user: json['user'] is Map ? Map<String, dynamic>.from(json['user']) : {},
    );
  }

  // Helper to get amount as double
  double get amountValue {
    return double.tryParse(amount) ?? 0.0;
  }

  // Helper to get user name
  String get userName {
    return user['name']?.toString() ?? '';
  }
}

class SyndicateBuyingListResponse {
  final bool status;
  final String message;
  final List<SyndicateBuyingList> data;
  final Pagination pagination;

  SyndicateBuyingListResponse({
    required this.status,
    required this.message,
    required this.data,
    required this.pagination,
  });

  factory SyndicateBuyingListResponse.fromJson(Map<String, dynamic> json) {
    return SyndicateBuyingListResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List? ?? [])
          .map((item) => SyndicateBuyingList.fromJson(item))
          .toList(),
      pagination: Pagination.fromJson(json['pagination'] ?? {}),
    );
  }
}

// Update your SyndicateBuyingDetail model in syndicate_model.dart
class SyndicateBuyingDetail {
  final int id;
  final int transactionId;
  final int propertyId;
  final String unit;
  final int cancelStatus;
  final DateTime? refundDate;
  final int refundStatus;
  final String amount;
  final dynamic refundAmount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Transaction transaction;
  final SyndicateProperty property;

  SyndicateBuyingDetail({
    required this.id,
    required this.transactionId,
    required this.propertyId,
    required this.unit,
    required this.cancelStatus,
    this.refundDate,
    required this.refundStatus,
    required this.amount,
    this.refundAmount,
    required this.createdAt,
    required this.updatedAt,
    required this.transaction,
    required this.property,
  });

  factory SyndicateBuyingDetail.fromJson(Map<String, dynamic> json) {
    return SyndicateBuyingDetail(
      id: json['id'] ?? 0,
      transactionId: json['transaction_id'] ?? 0,
      propertyId: json['property_id'] ?? 0,
      unit: json['unit']?.toString() ?? '',
      cancelStatus: json['cancel_status'] ?? 0,
      refundDate: json['refund_date'] != null && json['refund_date'] is String
          ? DateTime.tryParse(json['refund_date'] as String)
          : null,
      refundStatus: json['refund_status'] ?? 0,
      amount: json['amount']?.toString() ?? '0',
      refundAmount: json['refund_amount'],
      createdAt: DateTime.parse(json['created_at'] ?? ''),
      updatedAt: DateTime.parse(json['updated_at'] ?? ''),
      transaction: Transaction.fromJson(json['transaction'] ?? {}),
      property: SyndicateProperty.fromJson(json['property'] ?? {}),
    );
  }

  // Helper getters
  double get amountValue {
    return double.tryParse(amount) ?? 0.0;
  }

  double get refundAmountValue {
    if (refundAmount is String) {
      return double.tryParse(refundAmount as String) ?? 0.0;
    } else if (refundAmount is int) {
      return (refundAmount as int).toDouble();
    } else if (refundAmount is double) {
      return refundAmount as double;
    }
    return 0.0;
  }

  bool get canCancel => cancelStatus == 0;
  bool get isCancelled => cancelStatus == 1;
  bool get hasRefund => refundAmount != null;
}

class SyndicateBuyingDetailResponse {
  final bool status;
  final String message;
  final List<SyndicateBuyingDetail> data;
  final Pagination pagination;

  SyndicateBuyingDetailResponse({
    required this.status,
    required this.message,
    required this.data,
    required this.pagination,
  });

  factory SyndicateBuyingDetailResponse.fromJson(Map<String, dynamic> json) {
    return SyndicateBuyingDetailResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List? ?? [])
          .map((item) => SyndicateBuyingDetail.fromJson(item))
          .toList(),
      pagination: Pagination.fromJson(json['pagination'] ?? {}),
    );
  }
}
// Reuse Transaction class from your existing code

class Pagination {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  Pagination({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      perPage: json['per_page'] ?? 10,
      total: json['total'] ?? 0,
    );
  }
}
