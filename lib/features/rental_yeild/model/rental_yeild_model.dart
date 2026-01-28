// rental_yield_model.dart

class RentalYieldModel {
  final int id;
  final String name;
  final String? type;
  final String address;
  final double price; // Property price
  final double rentAmount; // Monthly rent in original currency
  final double yieldAmount; // Annual yield amount
  final double? area;
  final String? unitSplit;
  final String? propertyType;
  final int? bedrooms;
  final int? bathrooms;
  final String? furnishingStatus;
  final String? propertyAge;
  final int? cityId;
  final String? cityName;
  final int? stateId;
  final String? stateName;
  final List<String> images;
  final List<String> files;
  final String plotImage;
  final String description;
  final List<AmenityModel> amenities;
  final List<NearbyLocationModel> nearbyLocations;
  final double lat;
  final double lng;
  final int? agentId;
  final int status;
  final int featured;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Calculated properties
  double get monthlyRent => rentAmount; // Already in original amount
  double get annualYield {
    if (price > 0) {
      return (yieldAmount / (price * 100000)) * 100; // Calculate percentage
    }
    return 0.0;
  }

  String get formattedPrice {
    if (price >= 100) {
      return '₹${(price / 100).toStringAsFixed(1)}Cr';
    } else {
      return '₹${price.toStringAsFixed(1)}L';
    }
  }

  String get formattedRent {
    if (rentAmount >= 100000) {
      return '₹${(rentAmount / 100000).toStringAsFixed(1)}L';
    } else if (rentAmount >= 1000) {
      return '₹${(rentAmount / 1000).toStringAsFixed(1)}K';
    } else {
      return '₹${rentAmount.toStringAsFixed(1)}';
    }
  }

  RentalYieldModel({
    required this.id,
    required this.name,
    this.type,
    required this.address,
    required this.price,
    required this.rentAmount,
    required this.yieldAmount,
    this.area,
    this.unitSplit,
    this.propertyType,
    this.bedrooms,
    this.bathrooms,
    this.furnishingStatus,
    this.propertyAge,
    this.cityId,
    this.cityName,
    this.stateId,
    this.stateName,
    required this.images,
    required this.files,
    required this.plotImage,
    required this.description,
    required this.amenities,
    required this.nearbyLocations,
    required this.lat,
    required this.lng,
    this.agentId,
    required this.status,
    required this.featured,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RentalYieldModel.fromJson(Map<String, dynamic> json) {
    // Parse price - API returns null, so we need to calculate or use default
    double calculatePrice() {
      // If price is provided, use it
      if (json['price'] != null) {
        return double.parse(json['price'].toString());
      }

      // Calculate approximate price based on rent and typical yield
      // Assuming typical 4-6% yield for Indian real estate
      double annualRent = double.parse(json['rent_amount'].toString()) * 12;
      double typicalYield = 5.0; // 5% typical yield
      return (annualRent / typicalYield) * 100;
    }

    return RentalYieldModel(
      id: json['id'],
      name: json['name'] ?? 'Unnamed Property',
      type: json['type'],
      address: json['address'] ?? 'No address provided',
      price: calculatePrice(),
      rentAmount: double.parse(json['rent_amount'].toString()),
      yieldAmount: double.parse(json['yield_amount'].toString()),
      area: json['area'] != null ? double.parse(json['area'].toString()) : null,
      unitSplit: json['unit_split'],
      propertyType: json['type'],
      bedrooms: 0, // Not provided in API
      bathrooms: 0, // Not provided in API
      furnishingStatus: 'Not Specified', // Not provided in API
      propertyAge: 'Not Specified', // Not provided in API
      cityId: json['city']?['id'],
      cityName: json['city']?['city_name'],
      stateId: json['state']?['id'],
      stateName: json['state']?['state_name'],
      images: List<String>.from(json['files'] ?? []),
      files: List<String>.from(json['files'] ?? []),
      plotImage: json['plot_image'] ?? '',
      description: json['description'] ?? 'No description available',
      amenities: (json['amenity'] as List<dynamic>?)
          ?.map((a) => AmenityModel.fromJson(a))
          .toList() ?? [],
      nearbyLocations: (json['nearby_locations'] as List<dynamic>?)
          ?.map((n) => NearbyLocationModel.fromJson(n))
          .toList() ?? [],
      lat: double.parse(json['lat'].toString()),
      lng: double.parse(json['lng'].toString()),
      agentId: json['agent_id'],
      status: json['status'] ?? 0,
      featured: json['featured'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

class AmenityModel {
  final int id;
  final String title;
  final String image;
  final DateTime createdAt;
  final DateTime updatedAt;

  AmenityModel({
    required this.id,
    required this.title,
    required this.image,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AmenityModel.fromJson(Map<String, dynamic> json) {
    return AmenityModel(
      id: json['id'],
      title: json['title'] ?? '',
      image: json['image'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

class NearbyLocationModel {
  final int id;
  final String title;
  final String image;
  final double? distance;
  final DateTime createdAt;
  final DateTime updatedAt;

  NearbyLocationModel({
    required this.id,
    required this.title,
    required this.image,
    this.distance,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NearbyLocationModel.fromJson(Map<String, dynamic> json) {
    return NearbyLocationModel(
      id: json['id'],
      title: json['title'] ?? '',
      image: json['image'] ?? '',
      distance: json['pivot']?['distance'] != null
          ? double.parse(json['pivot']['distance'].toString())
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
class StateModel {
  final int id;
  final String stateName;
  final int status;
  final DateTime createdAt;
  final DateTime updatedAt;

  StateModel({
    required this.id,
    required this.stateName,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StateModel.fromJson(Map<String, dynamic> json) {
    return StateModel(
      id: json['id'],
      stateName: json['state_name'],
      status: json['status'] ?? 1,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

class CityModel {
  final int id;
  final int stateId;
  final String cityName;
  final int status;
  final DateTime createdAt;
  final DateTime updatedAt;

  CityModel({
    required this.id,
    required this.stateId,
    required this.cityName,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      id: json['id'],
      stateId: json['state_id'],
      cityName: json['city_name'],
      status: json['status'] ?? 1,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}