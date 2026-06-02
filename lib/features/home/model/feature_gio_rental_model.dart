import 'package:cashback_farms/features/home/model/home_model.dart';

import '../../search/model/common_search_model.dart';
class FeaturedRentalResponse {
  final List<FeaturedRentalProperty> rentalProperties;
  final FeaturedPagination pagination;

  FeaturedRentalResponse({
    required this.rentalProperties,
    required this.pagination,
  });

  factory FeaturedRentalResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rentalData = json['rental'] ?? [];
    final paginationData = json['pagination'] ?? {};

    return FeaturedRentalResponse(
      rentalProperties: rentalData
          .map((data) => FeaturedRentalProperty.fromJson(data))
          .toList(),
      pagination: FeaturedPagination.fromJson(paginationData),
    );
  }
}
class FeaturedRentalProperty {
  final int id;
  final String name;
  final String userId;
  final String lat;
  final String long;
  final String address;
  final FeaturedCity? city;
  final FeaturedState? state;
  final String area;
  final String price;
  final String description;
  final List<String> images;
  final int verifyStatus;
  final String uldNo;
  final DateTime createdAt;
  final DateTime updatedAt;
  final FeaturedPropertyType? propertyType;
  List<String>? files;
  double? rentAmount;
  double? yieldAmount;
  int? soldStatus;
  final String? totalPrice;
  final String? pricePerSqft;

  FeaturedRentalProperty({
    required this.id,
    required this.name,
    required this.userId,
    required this.lat,
    required this.long,
    required this.address,
    this.city,
    this.state,
    required this.area,
    required this.price,
    required this.description,
    required this.images,
    required this.verifyStatus,
    required this.uldNo,
    required this.createdAt,
    required this.updatedAt,
    this.propertyType,
    this.files,
    this.rentAmount,
    this.yieldAmount,
    this.soldStatus,
    this.totalPrice,
    this.pricePerSqft
  });

  factory FeaturedRentalProperty.fromJson(Map<String, dynamic> json) {
    List<String> imagesList = [];

    if (json['image'] is List) {
      imagesList = List<String>.from(json['image']);
    } else if (json['image'] is String) {
      imagesList = [json['image']];
    }

    return FeaturedRentalProperty(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      userId: json['user_id']?.toString() ?? '',
      lat: json['lat']?.toString() ?? '',
      long: json['long']?.toString() ?? '',
      address: json['address'] ?? '',
      city: json['city'] != null ? FeaturedCity.fromJson(json['city']) : null,
      state: json['state'] != null ? FeaturedState.fromJson(json['state']) : null,
      area: json['area']?.toString() ?? '',
      price: json['price']?.toString() ?? '',
      description: json['description'] ?? '',
      images: imagesList,
      soldStatus : json['sold_status'],
      verifyStatus: json['verify_status'] ?? 0,
      uldNo: json['uld_no']?.toString() ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toString()).toLocal(),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toString()).toLocal(),
      files : json['files'].cast<String>(),
        yieldAmount : parseToDouble(json['yield_amount']?.toString()),
        rentAmount : parseToDouble(json['rent_amount']?.toString()),
      propertyType: json['property_type'] != null
          ? FeaturedPropertyType.fromJson(json['property_type'])
          : null,
      totalPrice : json['total_price'],
      pricePerSqft : json['price_per_sqft'],
    );
  }

  // ✅ Helpers
  String get thumbnailImage => images.isNotEmpty ? images.first : '';

  String get formattedPrice {
    final priceValue = double.tryParse(price);
    return priceValue != null ? '₹${priceValue.toStringAsFixed(2)}' : '₹0.00';
  }

  String get location => city?.cityName ?? address;

  String get propertyTypeName => propertyType?.categoryName ?? '';
}