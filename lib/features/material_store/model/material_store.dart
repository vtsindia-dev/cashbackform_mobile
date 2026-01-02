// In your Material model (material_store.dart)
class Material {
  final int id;
  final String materialName;
  final int categoryId;
  final String description;
  final List<String> image;
  final int status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Category? category;
  // Add price fields if your API provides them
  final double? minPrice;
  final double? maxPrice;
  final String? unit;
  final String? priceRange;

  Material({
    required this.id,
    required this.materialName,
    required this.categoryId,
    required this.description,
    required this.image,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.category,
    this.minPrice,
    this.maxPrice,
    this.unit,
    this.priceRange,
  });

  factory Material.fromJson(Map<String, dynamic> json) {
    // Check if price fields exist in the API response
    final hasPriceData = json.containsKey('min_price') ||
        json.containsKey('max_price') ||
        json.containsKey('price_range') ||
        json.containsKey('unit');

    return Material(
      id: json['id'] ?? 0,
      materialName: json['material_name'] ?? '',
      categoryId: json['category_id'] ?? 0,
      description: json['description'] ?? '',
      image: json['image'] != null ? List<String>.from(json['image']) : [],
      status: json['status'] ?? 0,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
      category: json['category'] != null ? Category.fromJson(json['category']) : null,
      minPrice: json['min_price'] != null ? double.tryParse(json['min_price'].toString()) : null,
      maxPrice: json['max_price'] != null ? double.tryParse(json['max_price'].toString()) : null,
      unit: json['unit'] ?? '',
      priceRange: json['price_range'] ?? '',
    );
  }
  String getFormattedPrice() {
    if (priceRange != null && priceRange!.isNotEmpty) {
      return priceRange!;
    }
    if (minPrice != null && maxPrice != null) {
      return "₹${_formatNumber(minPrice!)} - ₹${_formatNumber(maxPrice!)}${unit != null && unit!.isNotEmpty ? '/ $unit' : ''}";
    }
    if (minPrice != null) {
      return "Starting from ₹${_formatNumber(minPrice!)}${unit != null && unit!.isNotEmpty ? '/ $unit' : ''}";
    }
    if (maxPrice != null) {
      return "Up to ₹${_formatNumber(maxPrice!)}${unit != null && unit!.isNotEmpty ? '/ $unit' : ''}";
    }
    return _getDefaultPriceByCategory();
  }

  String _formatNumber(double value) {
    if (value >= 100000) {
      return '${(value / 100000).toStringAsFixed(1)}L';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    } else {
      return value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2);
    }
  }

  String _getDefaultPriceByCategory() {
    switch (categoryId) {
      case 12:
        return "Contact for Price (Cement)";
      case 13:
        return "Contact for Price (Steel)";
      case 14:
        return "Contact for Price (Tiles)";
      default:
        return "Contact for Price";
    }
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
