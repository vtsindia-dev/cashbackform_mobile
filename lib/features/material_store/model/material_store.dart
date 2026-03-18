// material_models.dart

// ==================== MATERIAL MODEL ====================
class MaterialModel {
  final int id;
  final String materialName;
  final int categoryId;
  final int? subcatId;
  final int? subsubcatId;
  final dynamic brandId;
  // final int? brandId;
  final int? unitId;
  final String? description;
  final List<String> image;
  final int status;
  final int featured;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? gallery;
  final Category? category;

  // Price fields
  final double? price;
  final String? priceUnit;

  MaterialModel({
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
    this.createdAt,
    this.updatedAt,
    this.gallery,
    this.category,
    this.price,
    this.priceUnit,
  });

  factory MaterialModel.fromJson(Map<String, dynamic> json) {
    List<String> imageList = [];
    if (json['image'] != null) {
      if (json['image'] is List) {
        imageList = List<String>.from(json['image']);
      } else if (json['image'] is String) {
        imageList = [json['image']];
      }
    }

    return MaterialModel(
      id: json['id'] ?? 0,
      materialName: json['material_name'] ?? '',
      categoryId: json['category_id'] ?? 0,
      subcatId: json['subcat_id'],
      subsubcatId: json['subsubcat_id'],
      brandId: json['brand_id'],
      unitId: json['unit_id'],
      description: json['description'],
      image: imageList,
      status: json['status'] ?? 0,
      featured: json['featured'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      gallery: json['gallery'],
      category: json['category'] != null
          ? Category.fromJson(json['category'])
          : null,
      price: json['price'] != null
          ? double.tryParse(json['price'].toString())
          : (json['material_price'] != null
          ? double.tryParse(json['material_price'].toString())
          : null),
      priceUnit: json['price_unit'] ?? json['unit'] ?? json['material_unit'],
    );
  }

  String getFormattedPrice() {
    if (price != null && price! > 0) {
      return '₹${price!.toStringAsFixed(2)}${priceUnit != null ? ' / $priceUnit' : ''}';
    }

    switch (categoryId) {
      case 12:
        return '₹350 - ₹400 / Bag';
      case 13:
        return '₹60,000 - ₹65,000 / Ton';
      case 14:
        return '₹45 - ₹120 / Sq.Ft';
      case 15:
        return '₹8 - ₹12 / Piece';
      default:
        return 'Price on request';
    }
  }
}

// ==================== CATEGORY MODEL ====================
class Category {
  final int id;
  final String categoryName;
  final String? image;

  Category({
    required this.id,
    required this.categoryName,
    this.image,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? 0,
      categoryName: json['category_name'] ?? '',
      image: json['image'],
    );
  }
}

// ==================== SERVICE MODEL ====================
class ServiceModel {
  final int id;
  final String serviceName;
  final int? categoryId;
  final int? subcategoryId;
  final int? subSubcategoryId;
  final int? brandId;
  final String? description;
  final List<String> image;
  final int status;
  final int featured;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? gallery;

  ServiceModel({
    required this.id,
    required this.serviceName,
    this.categoryId,
    this.subcategoryId,
    this.subSubcategoryId,
    this.brandId,
    this.description,
    required this.image,
    required this.status,
    required this.featured,
    this.createdAt,
    this.updatedAt,
    this.gallery,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    List<String> imageList = [];
    if (json['image'] != null) {
      if (json['image'] is List) {
        imageList = List<String>.from(json['image']);
      } else if (json['image'] is String) {
        imageList = [json['image']];
      }
    }

    return ServiceModel(
      id: json['id'] ?? 0,
      serviceName: json['service_name'] ?? '',
      categoryId: json['category_id'],
      subcategoryId: json['subcategory_id'],
      subSubcategoryId: json['sub_subcategory_id'],
      brandId: json['brand_id'],
      description: json['description'],
      image: imageList,
      status: json['status'] ?? 0,
      featured: json['featured'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      gallery: json['gallery'],
    );
  }
}
// ==================== VENDOR SERVICE MODEL ====================
class VendorService {
  final int id;
  final int userId;
  final int serviceId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final ServiceModel service;

  VendorService({
    required this.id,
    required this.userId,
    required this.serviceId,
    this.createdAt,
    this.updatedAt,
    required this.service,
  });

  factory VendorService.fromJson(Map<String, dynamic> json) {
    return VendorService(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      serviceId: json['service_id'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      service: ServiceModel.fromJson(json['service'] ?? {}),
    );
  }
}
// ==================== VENDOR MATERIAL MODEL ====================
class VendorMaterial {
  final int id;
  final int userId;
  final int materialId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final MaterialModel material;

  VendorMaterial({
    required this.id,
    required this.userId,
    required this.materialId,
    this.createdAt,
    this.updatedAt,
    required this.material,
  });

  factory VendorMaterial.fromJson(Map<String, dynamic> json) {
    return VendorMaterial(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      materialId: json['material_id'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      material: MaterialModel.fromJson(json['material'] ?? {}),
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
  final String? dob;
  final String? avatar;
  final String? pin;
  final int? gender;
  final String? address;
  final String? phone;
  final int status;
  final int agentRequest;
  final int vendorRequest;
  final int serviceRequest;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? fcmToken;
  final int isDeleted;
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
    this.dob,
    this.avatar,
    this.pin,
    this.gender,
    this.address,
    this.phone,
    required this.status,
    required this.agentRequest,
    required this.vendorRequest,
    required this.serviceRequest,
    this.createdAt,
    this.updatedAt,
    this.fcmToken,
    required this.isDeleted,
    this.firstName,
    this.lastName,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      role: json['role'],
      isVendor: json['is_vendor'] ?? 0,
      isAgent: json['is_agent'] ?? 0,
      isServices: json['is_services'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      emailVerifiedAt: json['email_verified_at'],
      dob: json['dob'],
      avatar: json['avatar'],
      pin: json['pin'],
      gender: json['gender'],
      address: json['address'],
      phone: json['phone'],
      status: json['status'] ?? 0,
      agentRequest: json['agent_request'] ?? 0,
      vendorRequest: json['vendor_request'] ?? 0,
      serviceRequest: json['service_request'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      fcmToken: json['fcm_token'],
      isDeleted: json['is_deleted'] ?? 0,
      firstName: json['first_name'],
      lastName: json['last_name'],
    );
  }
}

// ==================== REVIEW MODEL ====================
class Review {
  final int id;
  final int vendorId;
  final int userId;
  final double rating;
  final String review;
  final int status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final User user;

  Review({
    required this.id,
    required this.vendorId,
    required this.userId,
    required this.rating,
    required this.review,
    required this.status,
    this.createdAt,
    this.updatedAt,
    required this.user,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] ?? 0,
      vendorId: json['vendor_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      rating: json['rating'] != null
          ? double.tryParse(json['rating'].toString()) ?? 0.0
          : 0.0,
      review: json['review'] ?? '',
      status: json['status'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      user: User.fromJson(json['user'] ?? {}),
    );
  }
}

// ==================== VENDOR MODEL ====================
class Vendor {
  final int id;
  final int userId;
  final String name;
  final String description;
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
  final dynamic city; // Can be String or Map
  final dynamic state; // Can be String or Map
  final String? postalCode;
  final String phone;
  final String email;
  final String? website;
  final String? catalog;
  final int status;
  final String? estimateDate;
  final String? taxNumber;
  final String? whatsapp;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int reviewsCount;
  final double? reviewsAvgRating;
  final List<Review> reviews;
  final List<VendorMaterial> vendorMaterials;
  final List<VendorService>? vendorServices;

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
    this.createdAt,
    this.updatedAt,
    required this.reviewsCount,
    this.reviewsAvgRating,
    required this.reviews,
    required this.vendorMaterials,
    this.vendorServices,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) {
    // Parse image list
    List<String> imageList = [];
    if (json['image'] != null) {
      if (json['image'] is List) {
        imageList = List<String>.from(json['image']);
      } else if (json['image'] is String) {
        imageList = [json['image']];
      }
    }

    // Parse reviews
    List<Review> reviewsList = [];
    if (json['reviews'] != null && json['reviews'] is List) {
      reviewsList = (json['reviews'] as List)
          .map((review) => Review.fromJson(review))
          .toList();
    }

    // Parse vendor materials
    List<VendorMaterial> vendorMaterialsList = [];
    if (json['vendor_materials'] != null && json['vendor_materials'] is List) {
      vendorMaterialsList = (json['vendor_materials'] as List)
          .map((material) => VendorMaterial.fromJson(material))
          .toList();
    }

    // Parse vendor services
    List<VendorService> vendorServicesList = [];
    if (json['vendor_services'] != null && json['vendor_services'] is List) {
      vendorServicesList = (json['vendor_services'] as List)
          .map((service) => VendorService.fromJson(service))
          .toList();
    }

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
      lat: json['lat'],
      lang: json['lang'],
      address: json['address'],
      image: imageList,
      thumbnail: json['thumbnail'],
      city: json['city'],
      state: json['state'],
      postalCode: json['postal_code'],
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      website: json['website'],
      catalog: json['catalog'],
      status: json['status'] ?? 0,
      estimateDate: json['estimate_date'],
      taxNumber: json['tax_number'],
      whatsapp: json['whatsapp'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      reviewsCount: json['reviews_count'] ?? 0,
      reviewsAvgRating: json['reviews_avg_rating'] != null
          ? double.tryParse(json['reviews_avg_rating'].toString())
          : null,
      reviews: reviewsList,
      vendorMaterials: vendorMaterialsList,
      vendorServices: vendorServicesList.isNotEmpty ? vendorServicesList : null,
    );
  }

  // Helper method to get city as string
  String getCityString() {
    if (city == null) return '';
    if (city is String) return city;
    if (city is Map) return city['city_name'] ?? '';
    return '';
  }

  // Helper method to get state as string
  String getStateString() {
    if (state == null) return '';
    if (state is String) return state;
    if (state is Map) return state['state_name'] ?? '';
    return '';
  }

  // Get full location
  String getFullLocation() {
    List<String> parts = [];
    String cityStr = getCityString();
    String stateStr = getStateString();

    if (cityStr.isNotEmpty) parts.add(cityStr);
    if (stateStr.isNotEmpty) parts.add(stateStr);
    if (postalCode != null && postalCode!.isNotEmpty) parts.add(postalCode!);

    return parts.isNotEmpty ? parts.join(', ') : 'Location not specified';
  }
}

// ==================== API RESPONSE WRAPPERS ====================

class ApiResponse<T> {
  final bool status;
  final T? data;
  final String? message;
  final dynamic meta;

  ApiResponse({
    required this.status,
    this.data,
    this.message,
    this.meta,
  });

  factory ApiResponse.fromJson(
      Map<String, dynamic> json,
      T Function(Map<String, dynamic>) fromJson,
      ) {
    return ApiResponse(
      status: json['status'] == true || json['status'] == 200 || json['status'] == 201,
      data: json['data'] != null
          ? (json['data'] is Map
          ? fromJson(json['data'])
          : null)
          : null,
      message: json['message'],
      meta: json['meta'],
    );
  }
}

class PaginatedResponse<T> {
  final List<T> items;
  final Pagination? pagination;

  PaginatedResponse({
    required this.items,
    this.pagination,
  });

  factory PaginatedResponse.fromJson(
      Map<String, dynamic> json,
      T Function(Map<String, dynamic>) fromJson,
      String dataKey,
      ) {
    List<T> items = [];
    if (json[dataKey] != null && json[dataKey] is List) {
      items = (json[dataKey] as List)
          .map((item) => fromJson(item))
          .toList();
    }

    Pagination? pagination;
    if (json['pagination'] != null) {
      pagination = Pagination.fromJson(json['pagination']);
    }

    return PaginatedResponse(
      items: items,
      pagination: pagination,
    );
  }
}

class Pagination {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final String? path;
  final String? nextPageUrl;
  final String? prevPageUrl;

  Pagination({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    this.path,
    this.nextPageUrl,
    this.prevPageUrl,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      perPage: json['per_page'] ?? 15,
      total: json['total'] ?? 0,
      path: json['path'],
      nextPageUrl: json['next_page_url'],
      prevPageUrl: json['prev_page_url'],
    );
  }

  bool get hasMore => currentPage < lastPage;
}

// ==================== REQUEST MODELS ====================

class MaterialEnquiryRequest {
  final int materialId;
  final String requirement;
  final int unitId;
  final double quantity;
  final int userId;

  MaterialEnquiryRequest({
    required this.materialId,
    required this.requirement,
    required this.unitId,
    required this.quantity,
    required this.userId,
  });

  Map<String, dynamic> toJson() {
    return {
      'material_id': materialId,
      'requirement': requirement,
      'unit_id': unitId,
      'quantity': quantity,
      'user_id': userId,
    };
  }
}

class ShopReviewRequest {
  final int vendorId;
  final int userId;
  final double rating;
  final String review;

  ShopReviewRequest({
    required this.vendorId,
    required this.userId,
    required this.rating,
    required this.review,
  });

  Map<String, dynamic> toJson() {
    return {
      'vendor_id': vendorId,
      'user_id': userId,
      'rating': rating,
      'review': review,
    };
  }
}

// ==================== EXTENSION METHODS ====================

extension IterableExtension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (T element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}