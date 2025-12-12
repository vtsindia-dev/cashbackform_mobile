class Service {
  final int id;
  final String serviceName;
  final int categoryId;
  final String? description;
  final String image;
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
      image: json['image'] ?? '',
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