class CommonFacility {
  final int id;
  final String title;
  final String image;

  CommonFacility({
    required this.id,
    required this.title,
    required this.image,
  });

  factory CommonFacility.fromJson(Map<String, dynamic> json) {
    return CommonFacility(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      image: json['image'] as String? ?? '',
    );
  }
}

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
  final List<String> images;
  final String plotImage;
  final String work;
  final String? agentId;
  final int status;
  final int soldStatus; // ✅ Added
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
    required this.images,
    required this.plotImage,
    required this.work,
    required this.agentId,
    required this.status,
    required this.soldStatus,
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
      images: _parseImages(json['image']),
      plotImage: json['plot_image']?.toString() ?? '',
      work: json['work']?.toString() ?? '',
      agentId: json['agent_id']?.toString(),
      status: json['status'] as int? ?? 0,
      soldStatus: json['sold_status'] as int? ?? 0, // ✅
      createdAt: DateTime.parse(json['created_at']?.toString() ?? ''),
      updatedAt: DateTime.parse(json['updated_at']?.toString() ?? ''),
      propertyType: json['property_type'],
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

  bool get isSoldOut => soldStatus == 1;
  String get formattedPrice => _formatNumber(price);
  String get formattedArea => '$area sq.ft';
  String get location => '${city?.cityName ?? ''}, ${state?.stateName ?? ''}'.trim();
  String get firstImage => images.isNotEmpty ? images.first : '';
  List<String> get allImages => images;

  String _formatNumber(String number) {
    try {
      final numValue = double.tryParse(number);
      if (numValue == null) return number;
      if (numValue >= 100000) return '${(numValue / 100000).toStringAsFixed(1)}L';
      if (numValue >= 1000) return '${(numValue / 1000).toStringAsFixed(1)}K';
      return number;
    } catch (_) {
      return number;
    }
  }
}

class City {
  final int id;
  final int stateId;
  final String cityName;
  final int status;

  City({
    required this.id,
    required this.stateId,
    required this.cityName,
    required this.status,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'] as int? ?? 0,
      stateId: json['state_id'] as int? ?? 0,
      cityName: json['city_name'] as String? ?? '',
      status: json['status'] as int? ?? 0,
    );
  }
}

class AppState {
  final int id;
  final String stateName;
  final int status;

  AppState({
    required this.id,
    required this.stateName,
    required this.status,
  });

  factory AppState.fromJson(Map<String, dynamic> json) {
    return AppState(
      id: json['id'] as int? ?? 0,
      stateName: json['state_name'] as String? ?? '',
      status: json['status'] as int? ?? 0,
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
  final int soldStatus; // ✅ Added
  final String aminities;
  final String uldNo;
  final String startingPrice;
  final List<Amenity> amenities;
  final List<CommonFacility> commonFacilities; // ✅ Added
  final List<Document> documents;
  final List<Booking> bookings;
  final List<User> users;
  final String? adminBlockAmount;
  final List<NearbyLocation> nearbyLocations;
  final bool? propertyBooked;
  final bool? kycVerified;
  final int? transactionId;
  final String? youtubeLink;
  final String? share;

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
    required this.soldStatus,
    required this.aminities,
    required this.uldNo,
    required this.startingPrice,
    required this.amenities,
    required this.commonFacilities,
    required this.documents,
    required this.bookings,
    required this.users,
    this.adminBlockAmount,
    required this.nearbyLocations,
    this.propertyBooked,
    this.kycVerified,
    this.transactionId,
    this.youtubeLink,
    this.share,
  });

  factory SyndicateDetail.fromJson(Map<String, dynamic> json) {
    String safeString(dynamic v) => v?.toString() ?? '';
    int safeInt(dynamic v) =>
        (v is int) ? v : int.tryParse(v.toString()) ?? 0;
    bool safeBool(dynamic v) {
      if (v is bool) return v;
      if (v is String) return v.toLowerCase() == 'true' || v == '1';
      if (v is num) return v == 1;
      return false;
    }

    List<String> parseImages(dynamic d) {
      if (d == null) return [];
      if (d is List) return d.map((e) => e.toString()).toList();
      return [d.toString()];
    }

    return SyndicateDetail(
      id: safeInt(json['id']),
      name: safeString(json['name']),
      propertyType: json['property_type'] != null
          ? PropertyType.fromJson(json['property_type'])
          : null,
      map: safeString(json['map']),
      address: safeString(json['address']),
      lat: safeString(json['lat']),
      long: safeString(json['long']),
      city: json['city'] != null ? City.fromJson(json['city']) : null,
      state: json['state'] != null ? AppState.fromJson(json['state']) : null,
      area: safeString(json['area']),
      price: safeString(json['price']),
      description: safeString(json['description']),
      adminDocumentPrice: safeString(json['admin_document'] ?? '0'),
      isDocumentVerified: safeBool(json['document_verified'] ?? false),
      unitSpilt: safeInt(json['unit_spilt']),
      unit: safeString(json['unit'] ?? ''),
      images: parseImages(json['image']),
      plotImage: safeString(json['plot_image']),
      work: safeString(json['work']),
      agentId: safeString(json['agent_id']),
      status: safeInt(json['status']),
      soldStatus: safeInt(json['sold_status']), // ✅
      aminities: safeString(json['aminities'] ?? ''),
      share: json['share']?.toString(),
      uldNo: safeString(json['uld_no'] ?? ''),
      propertyBooked : json['property_booked'],
        kycVerified : json['kyc_verified'],
        transactionId : json['transaction_id'],
      youtubeLink: json['youtube_link']?.toString(),
      startingPrice: safeString(json['starting_price'] ?? '0'),
      amenities: (json['amenity'] is List)
          ? (json['amenity'] as List).map((e) => Amenity.fromJson(e)).toList()
          : [],
      commonFacilities: (json['commonfacility'] is List) // ✅
          ? (json['commonfacility'] as List)
          .map((e) => CommonFacility.fromJson(e))
          .toList()
          : [],
      documents: (json['documents'] is List)
          ? (json['documents'] as List).map((e) => Document.fromJson(e)).toList()
          : [],
      bookings: (json['booking'] is List)
          ? (json['booking'] as List).map((e) => Booking.fromJson(e)).toList()
          : [],
      users: (json['user'] is List)
          ? (json['user'] as List).map((e) => User.fromJson(e)).toList()
          : [],
      documentPayment: safeString(json['documentPayment'] ?? ''),
      adminBlockAmount: safeString(json['admin_block_amount'] ?? '0'),
      nearbyLocations: (json['nearbyLocations'] ?? json['nearby_locations']) is List
          ? ((json['nearbyLocations'] ?? json['nearby_locations']) as List)
          .map((e) => NearbyLocation.fromJson(e))
          .toList()
          : [],
    );
  }
  bool get isSoldOut => soldStatus == 1;
  List<double> get unitAreas {
    try {
      if (unit.isEmpty) return List.filled(unitSpilt, 0.0);
      return unit.split(',').map((e) => double.tryParse(e.trim()) ?? 0.0).toList();
    } catch (_) {
      return List.filled(unitSpilt, 0.0);
    }
  }
  double get pricePerSqFt =>
      double.tryParse(price.replaceAll(',', '')) ?? 0.0;
  double get documentPriceValue =>
      double.tryParse(adminDocumentPrice.replaceAll(',', '')) ?? 0.0;
  double get adminDocumentPriceValue => documentPriceValue;

  double get totalDocumentPrice => adminDocumentPriceValue;

  double get plotBookingPrice =>
      double.tryParse((adminBlockAmount ?? '0').replaceAll(',', '')) ?? 0.0;

  String get formattedTotalDocumentPrice =>
      '₹${totalDocumentPrice.toStringAsFixed(2)}';

  String get formattedPlotBookingPrice =>
      '₹${plotBookingPrice.toStringAsFixed(2)}';

  double calculateUnitPrice(int unitIndex) {
    if (unitIndex < 0 || unitIndex >= unitAreas.length) return 0.0;
    return unitAreas[unitIndex] * pricePerSqFt;
  }

  String getUnitArea(int unitIndex) {
    if (unitIndex < 0 || unitIndex >= unitAreas.length) return '0 sq.ft';
    return '${unitAreas[unitIndex]} sq.ft';
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

  Amenity({required this.id, required this.title, required this.image});

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
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }
}

class User {
  final int id;
  final int role;
  final String name;
  final String email;
  final String dob;
  final String avatar;
  final String pin;
  final int gender;
  final String address;
  final String phone;
  final int status;

  User({
    required this.id,
    required this.role,
    required this.name,
    required this.email,
    required this.dob,
    required this.avatar,
    required this.pin,
    required this.gender,
    required this.address,
    required this.phone,
    required this.status,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int? ?? 0,
      role: json['role'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      dob: json['dob'] as String? ?? '',
      avatar: json['avatar'] as String? ?? '',
      pin: json['pin'] as String? ?? '',
      gender: json['gender'] as int? ?? 0,
      address: json['address'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      status: json['status'] as int? ?? 0,
    );
  }
}

class NearbyLocation {
  final int id;
  final String title;
  final String image;
  final Pivot? pivot;

  NearbyLocation({
    required this.id,
    required this.title,
    required this.image,
    this.pivot,
  });

  factory NearbyLocation.fromJson(Map<String, dynamic> json) {
    return NearbyLocation(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      image: json['image'] as String? ?? '',
      pivot: json['pivot'] != null ? Pivot.fromJson(json['pivot']) : null,
    );
  }

  double get distance =>
      double.tryParse(pivot?.distance ?? '0') ?? 0.0;
}

class Pivot {
  final String distance;

  Pivot({required this.distance});

  factory Pivot.fromJson(Map<String, dynamic> json) {
    return Pivot(distance: json['distance']?.toString() ?? '0.0');
  }
}

// ──────────────────────────────────────────
// Buying-list models (unchanged)
// ──────────────────────────────────────────

class SyndicateBuyingList {
  final int id;
  final int propertyId;
  final int userId;
  final String units;
  final dynamic amount;
  final dynamic transactionId;
  final double? returnAmount;
  final DateTime? returnDate;
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
    this.returnAmount,
    this.returnDate,
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
          : null,
      returnDate: json['return_date'] != null
          ? DateTime.tryParse(json['return_date'].toString())
          : null,
      createdAt: DateTime.parse(json['created_at'] ?? ''),
      updatedAt: DateTime.parse(json['updated_at'] ?? ''),
      transaction: Transaction.fromJson(json['transaction'] ?? {}),
      property: SyndicateProperty.fromJson(json['property'] ?? {}),
    );
  }

  double get amountValue {
    if (amount is String) return double.tryParse(amount as String) ?? 0.0;
    if (amount is int) return (amount as int).toDouble();
    if (amount is double) return amount as double;
    return 0.0;
  }

  String get transactionIdString => transactionId?.toString() ?? '';
}

class SyndicateProperty {
  final int id;
  final String name;
  final dynamic type;
  final String? map;
  final String address;
  final String? area;
  final String? price;
  final int unitSpilt;
  final String? unit;
  final String? image;
  final int status;
  final int soldStatus; // ✅ Added
  final DateTime createdAt;
  final DateTime updatedAt;

  SyndicateProperty({
    required this.id,
    required this.name,
    required this.type,
    this.map,
    required this.address,
    this.area,
    this.price,
    required this.unitSpilt,
    this.unit,
    this.image,
    required this.status,
    required this.soldStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SyndicateProperty.fromJson(Map<String, dynamic> json) {
    return SyndicateProperty(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      type: json['type'],
      map: json['map'],
      address: json['address'] ?? '',
      area: json['area']?.toString(),
      price: json['price']?.toString(),
      unitSpilt: json['unit_spilt'] ?? 0,
      unit: json['unit']?.toString(),
      image: json['image']?.toString(),
      status: json['status'] ?? 0,
      soldStatus: json['sold_status'] as int? ?? 0, // ✅
      createdAt: DateTime.parse(json['created_at'] ?? ''),
      updatedAt: DateTime.parse(json['updated_at'] ?? ''),
    );
  }

  bool get isSoldOut => soldStatus == 1; // ✅
}

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
      user: json['user'] is Map
          ? Map<String, dynamic>.from(json['user'])
          : {},
    );
  }

  double get amountValue => double.tryParse(amount) ?? 0.0;
  String get userName => user['name']?.toString() ?? '';
}

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
      refundDate: json['refund_date'] != null
          ? DateTime.tryParse(json['refund_date'].toString())
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

  double get amountValue => double.tryParse(amount) ?? 0.0;

  double get refundAmountValue {
    if (refundAmount is String) return double.tryParse(refundAmount as String) ?? 0.0;
    if (refundAmount is int) return (refundAmount as int).toDouble();
    if (refundAmount is double) return refundAmount as double;
    return 0.0;
  }

  bool get canCancel => cancelStatus == 0;
  bool get isCancelled => cancelStatus == 1;
  bool get hasRefund => refundAmount != null;
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