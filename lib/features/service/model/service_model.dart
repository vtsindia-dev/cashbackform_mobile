// ==================== HELPER EXTENSION ====================
extension SafeParse on dynamic {
  int? toInt() {
    if (this == null) return null;
    if (this is int) return this;
    if (this is String) return int.tryParse(this);
    if (this is double) return this.toInt();
    return null;
  }

  double? toDouble() {
    if (this == null) return null;
    if (this is double) return this;
    if (this is int) return this.toDouble();
    if (this is String) return double.tryParse(this);
    return null;
  }

  String? toStringValue() {
    if (this == null) return null;
    return toString();
  }
}

// ==================== VENDOR MODEL ====================
class Vendor {
  final int id;
  final int userId;
  final String name;
  final String? description;
  final String? gst;
  final String? pan;
  final String? instagram;
  final String? x;
  final String? youtube;
  final String? lat;
  final String? lang;
  final String? address;
  final List<String> image;
  final String? thumbnail;
  final City? city;
  final State? state;
  final String? postalCode;
  final String phone;
  final String email;
  final String? website;
  final String? catalog;
  final int status;
  final String? estimateDate;
  final String? taxNumber;
  final String? whatsapp;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int reviewsCount;
  final String? reviewsAvgRating;
  final List<Review>? reviews;
  final List<VendorMaterial>? vendorMaterials;
  final List<VendorService>? vendorServices;
  final String? fax;

  Vendor({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    this.gst,
    this.pan,
    this.instagram,
    this.x,
    this.youtube,
    this.lat,
    this.lang,
    this.address,
    required this.image,
    this.thumbnail,
    this.city,
    this.state,
    this.postalCode,
    required this.phone,
    required this.email,
    this.website,
    this.catalog,
    required this.status,
    this.estimateDate,
    this.taxNumber,
    this.whatsapp,
    required this.createdAt,
    required this.updatedAt,
    required this.reviewsCount,
    this.reviewsAvgRating,
    this.reviews,
    this.vendorMaterials,
    this.vendorServices,
    this.fax,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      id: json['id']?.toInt() ?? 0,
      userId: json['user_id']?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      gst: json['gst']?.toString(),
      pan: json['pan']?.toString(),
      instagram: json['instagram']?.toString(),
      x: json['x']?.toString(),
      youtube: json['youtube']?.toString(),
      lat: json['lat']?.toString(),
      lang: json['lang']?.toString(),
      address: json['address']?.toString(),
      image: json['image'] != null ? List<String>.from(json['image']) : [],
      thumbnail: json['thumbnail']?.toString(),
      city: json['city'] != null ? City.fromJson(json['city']) : null,
      state: json['state'] != null ? State.fromJson(json['state']) : null,
      postalCode: json['postal_code']?.toString(),
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      website: json['website']?.toString(),
      catalog: json['catalog']?.toString(),
      status: json['status']?.toInt() ?? 0,
      estimateDate: json['estimate_date']?.toString(),
      taxNumber: json['tax_number']?.toString(),
      whatsapp: json['whatsapp']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at']).toLocal()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at']).toLocal()
          : DateTime.now(),
      reviewsCount: json['reviews_count']?.toInt() ?? 0,
      reviewsAvgRating: json['reviews_avg_rating']?.toString(),
      fax: json['fax']?.toString(),
      reviews: json['reviews'] != null
          ? (json['reviews'] as List).map((e) => Review.fromJson(e)).toList()
          : null,
      vendorMaterials: json['vendor_materials'] != null
          ? (json['vendor_materials'] as List)
          .map((e) => VendorMaterial.fromJson(e))
          .toList()
          : null,
      vendorServices: json['vendor_services'] != null
          ? (json['vendor_services'] as List)
          .map((e) => VendorService.fromJson(e))
          .toList()
          : null,
    );
  }
}

// ==================== BRAND MODEL ====================
class Brand {
  int? id;
  String? name;
  String? logo;

  Brand({this.id, this.name, this.logo});

  Brand.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toInt();
    name = json['name']?.toString();
    logo = json['logo']?.toString();
  }
}

// ==================== SERVICE CATEGORY MODEL ====================
class ServiceCategory {
  final int id;
  final String serviceName;
  final int categoryId;
  final int? subcategoryId;
  final int? subSubcategoryId;
  final int? brandId;
  final String? description;
  final List<String> image;
  final String? gallery;
  final int status;
  final int featured;
  final DateTime createdAt;
  final DateTime updatedAt;

  ServiceCategory({
    required this.id,
    required this.serviceName,
    required this.categoryId,
    this.subcategoryId,
    this.subSubcategoryId,
    this.brandId,
    this.description,
    required this.image,
    this.gallery,
    required this.status,
    required this.featured,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ServiceCategory.fromJson(Map<String, dynamic> json) {
    return ServiceCategory(
      id: json['id']?.toInt() ?? 0,
      serviceName: json['service_name']?.toString() ?? '',
      categoryId: json['category_id']?.toInt() ?? 0,
      subcategoryId: json['subcategory_id']?.toInt(),
      subSubcategoryId: json['sub_subcategory_id']?.toInt(),
      brandId: json['brand_id']?.toInt(),
      description: json['description']?.toString(),
      image: json['image'] != null ? List<String>.from(json['image']) : [],
      gallery: json['gallery']?.toString(),
      status: json['status']?.toInt() ?? 0,
      featured: json['featured']?.toInt() ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at']).toLocal()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at']).toLocal()
          : DateTime.now(),
    );
  }
}

// ==================== REVIEW MODEL ====================
class Review {
  final int id;
  final int vendorId;
  final int userId;
  final String rating;
  final String review;
  final int status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ReviewUser user;

  Review({
    required this.id,
    required this.vendorId,
    required this.userId,
    required this.rating,
    required this.review,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id']?.toInt() ?? 0,
      vendorId: json['vendor_id']?.toInt() ?? 0,
      userId: json['user_id']?.toInt() ?? 0,
      rating: json['rating']?.toString() ?? '0',
      review: json['review']?.toString() ?? '',
      status: json['status']?.toInt() ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at']).toLocal()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at']).toLocal()
          : DateTime.now(),
      user: ReviewUser.fromJson(json['user'] ?? {}),
    );
  }
}

// ==================== REVIEW USER MODEL ====================
class ReviewUser {
  final int id;
  final int? role;
  final int isVendor;
  final int isAgent;
  final int isServices;
  final String name;
  final String email;
  final String? dob;
  final String avatar;
  final String? pin;
  final int? gender;
  final String? address;
  final String phone;
  final int status;

  ReviewUser({
    required this.id,
    this.role,
    required this.isVendor,
    required this.isAgent,
    required this.isServices,
    required this.name,
    required this.email,
    this.dob,
    required this.avatar,
    this.pin,
    this.gender,
    this.address,
    required this.phone,
    required this.status,
  });

  factory ReviewUser.fromJson(Map<String, dynamic> json) {
    return ReviewUser(
      id: json['id']?.toInt() ?? 0,
      role: json['role']?.toInt(),
      isVendor: json['is_vendor']?.toInt() ?? 0,
      isAgent: json['is_agent']?.toInt() ?? 0,
      isServices: json['is_services']?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      dob: json['dob']?.toString(),
      avatar: json['avatar']?.toString() ?? '',
      pin: json['pin']?.toString(),
      gender: json['gender']?.toInt(),
      address: json['address']?.toString(),
      phone: json['phone']?.toString() ?? '',
      status: json['status']?.toInt() ?? 0,
    );
  }
}

// ==================== VENDOR MATERIAL MODEL ====================
class VendorMaterial {
  final int id;
  final int userId;
  final int materialId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Material material;

  VendorMaterial({
    required this.id,
    required this.userId,
    required this.materialId,
    required this.createdAt,
    required this.updatedAt,
    required this.material,
  });

  factory VendorMaterial.fromJson(Map<String, dynamic> json) {
    return VendorMaterial(
      id: json['id']?.toInt() ?? 0,
      userId: json['user_id']?.toInt() ?? 0,
      materialId: json['material_id']?.toInt() ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at']).toLocal()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at']).toLocal()
          : DateTime.now(),
      material: Material.fromJson(json['material'] ?? {}),
    );
  }
}

// ==================== MATERIAL MODEL ====================
class Material {
  final int id;
  final String materialName;
  final int categoryId;
  final int? subcatId;
  final int? subsubcatId;
  final String? brandId;
  final int? unitId;
  final String? description;
  final List<String> image;
  final int status;
  final int isDeleted;
  final int featured;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? gallery;
  final int? countryId;
  final int? stateId;
  final int? cityId;

  Material({
    required this.id,
    required this.materialName,
    required this.categoryId,
    this.subcatId,
    this.subsubcatId,
    this.brandId,
    this.unitId,
    this.description,
    required this.image,
    required this.status,
    required this.isDeleted,
    required this.featured,
    required this.createdAt,
    required this.updatedAt,
    this.gallery,
    this.countryId,
    this.stateId,
    this.cityId,
  });

  factory Material.fromJson(Map<String, dynamic> json) {
    return Material(
      id: json['id']?.toInt() ?? 0,
      materialName: json['material_name']?.toString() ?? '',
      categoryId: json['category_id']?.toInt() ?? 0,
      subcatId: json['subcat_id']?.toInt(),
      subsubcatId: json['subsubcat_id']?.toInt(),
      brandId: json['brand_id']?.toString(),
      unitId: json['unit_id']?.toInt(),
      description: json['description']?.toString(),
      image: json['image'] != null ? List<String>.from(json['image']) : [],
      status: json['status']?.toInt() ?? 0,
      isDeleted: json['is_deleted']?.toInt() ?? 0,
      featured: json['featured']?.toInt() ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at']).toLocal()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at']).toLocal()
          : DateTime.now(),
      gallery: json['gallery']?.toString(),
      countryId: json['country_id']?.toInt(),
      stateId: json['state_id']?.toInt(),
      cityId: json['city_id']?.toInt(),
    );
  }
}

// ==================== VENDOR SERVICE MODEL ====================
class VendorService {
  final int id;
  final int userId;
  final int serviceId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ServiceCategory service;

  VendorService({
    required this.id,
    required this.userId,
    required this.serviceId,
    required this.createdAt,
    required this.updatedAt,
    required this.service,
  });

  factory VendorService.fromJson(Map<String, dynamic> json) {
    return VendorService(
      id: json['id']?.toInt() ?? 0,
      userId: json['user_id']?.toInt() ?? 0,
      serviceId: json['service_id']?.toInt() ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at']).toLocal()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at']).toLocal()
          : DateTime.now(),
      service: ServiceCategory.fromJson(json['service'] ?? {}),
    );
  }
}

// ==================== MATERIAL ENQUIRY MODELS ====================
class MaterialEnquiryResponse {
  final int status;
  final MaterialEnquiryData data;

  MaterialEnquiryResponse({
    required this.status,
    required this.data,
  });

  factory MaterialEnquiryResponse.fromJson(Map<String, dynamic> json) {
    return MaterialEnquiryResponse(
      status: json['status']?.toInt() ?? 200,
      data: MaterialEnquiryData.fromJson(json['data'] ?? {}),
    );
  }
}

class MaterialEnquiryData {
  final List<MaterialEnquiry> materialEnquiry;
  final Pagination pagination;

  MaterialEnquiryData({
    required this.materialEnquiry,
    required this.pagination,
  });

  factory MaterialEnquiryData.fromJson(Map<String, dynamic> json) {
    return MaterialEnquiryData(
      materialEnquiry: (json['material_enquiry'] as List<dynamic>? ?? [])
          .map((e) => MaterialEnquiry.fromJson(e))
          .toList(),
      pagination: Pagination.fromJson(json['pagination'] ?? {}),
    );
  }
}

class MaterialEnquiry {
  final int id;
  final int? materialId;
  final int? userId;
  final String? name;
  final String? email;
  final String? phone;
  final String quote;
  final int? unitId;
  final int? quantity;
  final int? assignedVendor;
  final int accepted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String agentname;
  final String shopName;
  final Material? material;
  final User? user;

  MaterialEnquiry({
    required this.id,
    this.materialId,
    this.userId,
    this.name,
    this.email,
    this.phone,
    required this.quote,
    this.unitId,
    this.quantity,
    this.assignedVendor,
    required this.accepted,
    required this.createdAt,
    required this.updatedAt,
    required this.agentname,
    required this.shopName,
    this.material,
    this.user,
  });

  String get enquiryStatus {
    if (accepted == 1) return 'Accepted';
    if (assignedVendor != null && assignedVendor! > 0) return 'Assigned';
    return 'Pending';
  }

  factory MaterialEnquiry.fromJson(Map<String, dynamic> json) {
    return MaterialEnquiry(
      id: json['id']?.toInt() ?? 0,
      materialId: json['material_id']?.toInt(),
      userId: json['user_id']?.toInt(),
      name: json['name']?.toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      quote: json['quote']?.toString() ?? '',
      unitId: json['unit_id']?.toInt(),
      quantity: json['quantity']?.toInt(),
      assignedVendor: json['assigned_vendor']?.toInt(),
      accepted: json['accepted']?.toInt() ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at']).toLocal()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at']).toLocal()
          : DateTime.now(),
      agentname: json['agentname']?.toString() ?? '',
      shopName: json['shop_name']?.toString() ?? '',
      material: json['material'] != null ? Material.fromJson(json['material']) : null,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }
}

// ==================== SERVICE ENQUIRY MODELS ====================
class ServiceEnquiryResponse {
  final int status;
  final ServiceEnquiryData data;

  ServiceEnquiryResponse({
    required this.status,
    required this.data,
  });

  factory ServiceEnquiryResponse.fromJson(Map<String, dynamic> json) {
    return ServiceEnquiryResponse(
      status: json['status']?.toInt() ?? 200,
      data: ServiceEnquiryData.fromJson(json['data'] ?? {}),
    );
  }
}

class ServiceEnquiryData {
  final List<ServiceEnquiry> serviceEnquiry;
  final Pagination pagination;

  ServiceEnquiryData({
    required this.serviceEnquiry,
    required this.pagination,
  });

  factory ServiceEnquiryData.fromJson(Map<String, dynamic> json) {
    return ServiceEnquiryData(
      serviceEnquiry: (json['material_enquiry'] as List<dynamic>? ?? [])
          .map((e) => ServiceEnquiry.fromJson(e))
          .toList(),
      pagination: Pagination.fromJson(json['pagination'] ?? {}),
    );
  }
}

class ServiceEnquiry {
  final int id;
  final int? serviceId;
  final int? userId;
  final String? name;
  final String? email;
  final String? phone;
  final String? assignedVendor;
  final int accepted;
  final String quote;
  final int? quantity;
  final String? status;
  final String? datePreference;
  final String? timePreference;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String agentname;
  final String shopName;
  final ServiceCategory? service;
  final User? user;

  ServiceEnquiry({
    required this.id,
    this.serviceId,
    this.userId,
    this.name,
    this.email,
    this.phone,
    this.assignedVendor,
    required this.accepted,
    required this.quote,
    this.quantity,
    this.status,
    this.datePreference,
    this.timePreference,
    required this.createdAt,
    required this.updatedAt,
    required this.agentname,
    required this.shopName,
    this.service,
    this.user,
  });

  String get enquiryStatus {
    if (accepted == 1) return 'Accepted';
    if (assignedVendor != null && assignedVendor!.isNotEmpty && assignedVendor != "0") return 'Assigned';
    return 'Pending';
  }

  factory ServiceEnquiry.fromJson(Map<String, dynamic> json) {
    return ServiceEnquiry(
      id: json['id']?.toInt() ?? 0,
      serviceId: json['service_id']?.toInt(),
      userId: json['user_id']?.toInt(),
      name: json['name']?.toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      assignedVendor: json['assigned_vendor']?.toString(),
      accepted: json['accepted']?.toInt() ?? 0,
      quote: json['quote']?.toString() ?? '',
      quantity: json['quantity']?.toInt(),
      status: json['status']?.toString(),
      datePreference: json['date_preference']?.toString(),
      timePreference: json['time_preference']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at']).toLocal()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at']).toLocal()
          : DateTime.now(),
      agentname: json['agentname']?.toString() ?? '',
      shopName: json['shop_name']?.toString() ?? '',
      service: json['service'] != null ? ServiceCategory.fromJson(json['service']) : null,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }
}

// ==================== USER MODEL ====================
class User {
  final int id;
  final int? role;
  final int isVendor;
  final int isAgent;
  final int isServices;
  final String name;
  final String email;
  final String? emailVerifiedAt;
  final int? referenceId;
  final String? code;
  final String? dob;
  final String? avatar;
  final String? pin;
  final int? gender;
  final String? address;
  final String phone;
  final int status;
  final int? agentRequest;
  final int? vendorRequest;
  final int? serviceRequest;
  final String? fcmToken;
  final int isDeleted;
  final String? walletBalance;
  final int? countryId;
  final int? stateId;
  final int? cityId;
  final String? cumulativeAmount;
  final String? firstName;
  final String? lastName;

  User({
    required this.id,
    this.role,
    required this.isVendor,
    required this.isAgent,
    required this.isServices,
    required this.name,
    required this.email,
    this.emailVerifiedAt,
    this.referenceId,
    this.code,
    this.dob,
    this.avatar,
    this.pin,
    this.gender,
    this.address,
    required this.phone,
    required this.status,
    this.agentRequest,
    this.vendorRequest,
    this.serviceRequest,
    this.fcmToken,
    required this.isDeleted,
    this.walletBalance,
    this.countryId,
    this.stateId,
    this.cityId,
    this.cumulativeAmount,
    this.firstName,
    this.lastName,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toInt() ?? 0,
      role: json['role']?.toInt(),
      isVendor: json['is_vendor']?.toInt() ?? 0,
      isAgent: json['is_agent']?.toInt() ?? 0,
      isServices: json['is_services']?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      emailVerifiedAt: json['email_verified_at']?.toString(),
      referenceId: json['reference_id']?.toInt(),
      code: json['code']?.toString(),
      dob: json['dob']?.toString(),
      avatar: json['avatar']?.toString(),
      pin: json['pin']?.toString(),
      gender: json['gender']?.toInt(),
      address: json['address']?.toString(),
      phone: json['phone']?.toString() ?? '',
      status: json['status']?.toInt() ?? 0,
      agentRequest: json['agent_request']?.toInt(),
      vendorRequest: json['vendor_request']?.toInt(),
      serviceRequest: json['service_request']?.toInt(),
      fcmToken: json['fcm_token']?.toString(),
      isDeleted: json['is_deleted']?.toInt() ?? 0,
      walletBalance: json['wallet_balance']?.toString(),
      countryId: json['country_id']?.toInt(),
      stateId: json['state_id']?.toInt(),
      cityId: json['city_id']?.toInt(),
      cumulativeAmount: json['cumulative_amount']?.toString(),
      firstName: json['first_name']?.toString(),
      lastName: json['last_name']?.toString(),
    );
  }
}

// ==================== CITY MODEL ====================
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
      id: json['id']?.toInt() ?? 0,
      stateId: json['state_id']?.toInt() ?? 0,
      cityName: json['city_name']?.toString() ?? '',
      status: json['status']?.toInt() ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at']).toLocal()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at']).toLocal()
          : DateTime.now(),
    );
  }
}

// ==================== STATE MODEL ====================
class State {
  final int id;
  final String stateName;
  final int status;
  final DateTime createdAt;
  final DateTime updatedAt;

  State({
    required this.id,
    required this.stateName,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory State.fromJson(Map<String, dynamic> json) {
    return State(
      id: json['id']?.toInt() ?? 0,
      stateName: json['state_name']?.toString() ?? '',
      status: json['status']?.toInt() ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at']).toLocal()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at']).toLocal()
          : DateTime.now(),
    );
  }
}

// ==================== PAGINATION MODEL ====================
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
      currentPage: json['current_page']?.toInt() ?? 1,
      total: json['total']?.toInt() ?? 0,
      perPage: json['per_page']?.toInt() ?? 10,
      lastPage: json['last_page']?.toInt() ?? 1,
    );
  }
}

// ==================== ENQUIRY PAYLOAD MODELS ====================
class MaterialEnquiryPayload {
  final int materialId;
  final String requirement;
  final int? unitId;
  final int? quantity;
  final int userId;

  MaterialEnquiryPayload({
    required this.materialId,
    required this.requirement,
    this.unitId,
    this.quantity,
    required this.userId,
  });

  Map<String, dynamic> toJson() {
    return {
      'material_id': materialId,
      'requirement': requirement,
      if (unitId != null) 'unit_id': unitId,
      if (quantity != null) 'quantity': quantity,
      'user_id': userId,
    };
  }
}

class ServiceEnquiryPayload {
  final int serviceId;
  final String quote;
  final String datePreference;
  final String timePreference;
  final int userId;

  ServiceEnquiryPayload({
    required this.serviceId,
    required this.quote,
    required this.datePreference,
    required this.timePreference,
    required this.userId,
  });

  Map<String, dynamic> toJson() {
    return {
      'service_id': serviceId,
      'quote': quote,
      'date_preference': datePreference,
      'time_preference': timePreference,
      'user_id': userId,
    };
  }
}

// ==================== REVIEW PAYLOAD MODEL ====================
class ReviewPayload {
  final int vendorId;
  final String rating;
  final String review;
  final int userId;

  ReviewPayload({
    required this.vendorId,
    required this.rating,
    required this.review,
    required this.userId,
  });

  Map<String, dynamic> toJson() {
    return {
      'vendor_id': vendorId,
      'rating': rating,
      'review': review,
      'user_id': userId,
    };
  }
}