class Service {
  final int id;
  final String serviceName;
  final int categoryId;
  final String? description;
  final List<String> image;
  final int status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Category category;
  Service({
    required this.id,
    required this.serviceName,
    required this.categoryId,
    this.description,
    required this.image,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.category,
  });
  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] ?? 0,
      serviceName: json['service_name'] ?? '',
      categoryId: json['category_id'] ?? 0,
      description: json['description'],
      image: json['image'] != null
          ? List<String>.from(json['image'])
          : [],
      status: json['status'] ?? 0,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toString()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toString()),
      category: Category.fromJson(json['category'] ?? {}),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service_name': serviceName,
      'category_id': categoryId,
      'description': description,
      'image': image,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'category': category.toJson(),
    };
  }
}

class MaterialEnquiryResponse {
  final int status;
  final MaterialEnquiryData data;

  MaterialEnquiryResponse({
    required this.status,
    required this.data,
  });

  factory MaterialEnquiryResponse.fromJson(Map<String, dynamic> json) {
    return MaterialEnquiryResponse(
      status: json['status'] ?? 0,
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
  // Add fields when API sends data
  // Example:
  // final int id;
  // final String name;

  MaterialEnquiry();

  factory MaterialEnquiry.fromJson(Map<String, dynamic> json) {
    return MaterialEnquiry();
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

class Category {
  final int id;
  final String categoryName;
  final int status;
  final DateTime createdAt;
  final DateTime updatedAt;
  Category({
    required this.id,
    required this.categoryName,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? 0,
      categoryName: json['category_name'] ?? '',
      status: json['status'] ?? 0,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toString()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toString()),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_name': categoryName,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}