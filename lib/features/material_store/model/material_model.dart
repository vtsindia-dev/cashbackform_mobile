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
    this.fax
  });

  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      gst: json['gst'],
      pan: json['pan'],
      instagram: json['instagram'],
      x: json['x'],
      youtube: json['youtube'],
      lat: json['lat']?.toString(),
      lang: json['lang']?.toString(),
      address: json['address'],
      image: json['image'] != null ? List<String>.from(json['image']) : [],
      thumbnail: json['thumbnail'],
      city: json['city'] != null ? City.fromJson(json['city']) : null,
      state: json['state'] != null ? State.fromJson(json['state']) : null,
      postalCode: json['postal_code'],
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      website: json['website'],
      catalog: json['catalog'],
      status: json['status'] ?? 0,
      estimateDate: json['estimate_date'],
      taxNumber: json['tax_number'],
      whatsapp: json['whatsapp'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toString()).toLocal(),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toString()).toLocal(),
      reviewsCount: json['reviews_count'] ?? 0,
      reviewsAvgRating: json['reviews_avg_rating']?.toString(),
      fax: json['fax'],
      reviews: json['reviews'] != null
          ? (json['reviews'] as List).map((e) => Review.fromJson(e)).toList()
          : null,
      vendorMaterials: json['vendor_materials'] != null
          ? (json['vendor_materials'] as List).map((e) => VendorMaterial.fromJson(e)).toList()
          : null,
      vendorServices: json['vendor_services'] != null
          ? (json['vendor_services'] as List).map((e) => VendorService.fromJson(e)).toList()
          : null,
    );
  }
}

class Brand {
  int? id;
  String? name;
  String? logo;

  Brand({this.id, this.name, this.logo});

  Brand.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    logo = json['logo'];
  }
}

// lib/features/service/models/service_category_model.dart
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
      id: json['id'] ?? 0,
      serviceName: json['service_name'] ?? '',
      categoryId: json['category_id'] ?? 0,
      subcategoryId: json['subcategory_id'],
      subSubcategoryId: json['sub_subcategory_id'],
      brandId: json['brand_id'],
      description: json['description'],
      image: json['image'] != null ? List<String>.from(json['image']) : [],
      gallery: json['gallery'],
      status: json['status'] ?? 0,
      featured: json['featured'] ?? 0,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toString()).toLocal(),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toString()).toLocal(),
    );
  }
}

// lib/features/service/models/review_model.dart
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
      id: json['id'] ?? 0,
      vendorId: json['vendor_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      rating: json['rating']?.toString() ?? '0',
      review: json['review'] ?? '',
      status: json['status'] ?? 0,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toString()).toLocal(),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toString()).toLocal(),
      user: ReviewUser.fromJson(json['user'] ?? {}),
    );
  }
}

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
      id: json['id'] ?? 0,
      role: json['role'],
      isVendor: json['is_vendor'] ?? 0,
      isAgent: json['is_agent'] ?? 0,
      isServices: json['is_services'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      dob: json['dob'],
      avatar: json['avatar'] ?? '',
      pin: json['pin'],
      gender: json['gender'],
      address: json['address'],
      phone: json['phone'] ?? '',
      status: json['status'] ?? 0,
    );
  }
}

// lib/features/service/models/vendor_material_model.dart
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
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      materialId: json['material_id'] ?? 0,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toString()).toLocal(),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toString()).toLocal(),
      material: Material.fromJson(json['material'] ?? {}),
    );
  }
}

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
  final int featured;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? gallery;

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
    required this.featured,
    required this.createdAt,
    required this.updatedAt,
    this.gallery,
  });

  factory Material.fromJson(Map<String, dynamic> json) {
    return Material(
      id: json['id'] ?? 0,
      materialName: json['material_name'] ?? '',
      categoryId: json['category_id'] ?? 0,
      subcatId: json['subcat_id'],
      subsubcatId: json['subsubcat_id'],
      brandId: json['brand_id']?.toString(),
      unitId: json['unit_id'],
      description: json['description'],
      image: json['image'] != null ? List<String>.from(json['image']) : [],
      status: json['status'] ?? 0,
      featured: json['featured'] ?? 0,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toString()).toLocal(),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toString()).toLocal(),
      gallery: json['gallery'],
    );
  }
}

// lib/features/service/models/vendor_service_model.dart
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
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      serviceId: json['service_id'] ?? 0,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toString()).toLocal(),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toString()).toLocal(),
      service: ServiceCategory.fromJson(json['service'] ?? {}),
    );
  }
}

// lib/features/service/models/material_enquiry_model.dart
class MaterialEnquiryResponse {
  final bool status;
  final MaterialEnquiryData data;

  MaterialEnquiryResponse({
    required this.status,
    required this.data,
  });

  factory MaterialEnquiryResponse.fromJson(Map<String, dynamic> json) {
    return MaterialEnquiryResponse(
      status: json['status'] ?? false,
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
  final int userId;
  final int materialId;
  final String requirement;
  final int? unitId;
  final int? quantity;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Material? material;
  final User? user;

  MaterialEnquiry({
    required this.id,
    required this.userId,
    required this.materialId,
    required this.requirement,
    this.unitId,
    this.quantity,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.material,
    this.user,
  });

  factory MaterialEnquiry.fromJson(Map<String, dynamic> json) {
    return MaterialEnquiry(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      materialId: json['material_id'] ?? 0,
      requirement: json['requirement'] ?? '',
      unitId: json['unit_id'],
      quantity: json['quantity'],
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toString()).toLocal(),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toString()).toLocal(),
      material: json['material'] != null ? Material.fromJson(json['material']) : null,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }
}

// lib/features/service/models/service_enquiry_model.dart
class ServiceEnquiry {
  final int id;
  final int userId;
  final int serviceId;
  final String quote;
  final String datePreference;
  final String timePreference;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ServiceCategory? service;
  final User? user;

  ServiceEnquiry({
    required this.id,
    required this.userId,
    required this.serviceId,
    required this.quote,
    required this.datePreference,
    required this.timePreference,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.service,
    this.user,
  });

  factory ServiceEnquiry.fromJson(Map<String, dynamic> json) {
    return ServiceEnquiry(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      serviceId: json['service_id'] ?? 0,
      quote: json['quote'] ?? '',
      datePreference: json['date_preference'] ?? '',
      timePreference: json['time_preference'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toString()).toLocal(),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toString()).toLocal(),
      service: json['service'] != null ? ServiceCategory.fromJson(json['service']) : null,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }
}

class ServiceEnquiryResponse {
  final bool status;
  final ServiceEnquiryData data;

  ServiceEnquiryResponse({
    required this.status,
    required this.data,
  });

  factory ServiceEnquiryResponse.fromJson(Map<String, dynamic> json) {
    return ServiceEnquiryResponse(
      status: json['status'] ?? false,
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
      serviceEnquiry: (json['service_enquiry'] as List<dynamic>? ?? [])
          .map((e) => ServiceEnquiry.fromJson(e))
          .toList(),
      pagination: Pagination.fromJson(json['pagination'] ?? {}),
    );
  }
}

// lib/features/service/models/user_model.dart
class User {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String? avatar;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.avatar,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      avatar: json['avatar'],
    );
  }
}

// lib/features/service/models/location_model.dart
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
      cityName: json['city_name'] ?? '',
      status: json['status'] ?? 0,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toString()).toLocal(),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toString()).toLocal(),
    );
  }
}

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
      id: json['id'] ?? 0,
      stateName: json['state_name'] ?? '',
      status: json['status'] ?? 0,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toString()).toLocal(),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toString()).toLocal(),
    );
  }
}

// lib/features/service/models/pagination_model.dart
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

// lib/features/service/models/enquiry_payload_model.dart
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

// lib/features/service/models/review_payload_model.dart
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