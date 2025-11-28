class MarketPlot {
  final int id;
  final String name;
  final int? type;
  final String userId;
  final String? map;
  final String address;
  final String lat;
  final String long;
  final City? city;
  final State? state;
  final String area;
  final String price;
  final String description;
  final int unitSplit;
  final List<String> images; // Changed from String to List<String>
  final String? plotImage;
  final String work;
  final String? agentId;
  final int status;
  final int verifyStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final dynamic propertyType;

  MarketPlot({
    required this.id,
    required this.name,
    required this.type,
    required this.userId,
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
    required this.verifyStatus,
    required this.createdAt,
    required this.updatedAt,
    required this.propertyType,
  });

  factory MarketPlot.fromJson(Map<String, dynamic> json) {
    return MarketPlot(
      id: json['id'] as int,
      name: json['name']?.toString() ?? '',
      type: json['type'] as int?,
      userId: json['user_id']?.toString() ?? '',
      map: json['map']?.toString(),
      address: json['address']?.toString() ?? '',
      lat: json['lat']?.toString() ?? '',
      long: json['long']?.toString() ?? '',
      city: json['city'] != null ? City.fromJson(json['city']) : null,
      state: json['state'] != null ? State.fromJson(json['state']) : null,
      area: json['area']?.toString() ?? '',
      price: json['price']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      unitSplit: json['unit_spilt'] as int? ?? 0,
      images: _parseImages(json['image']), // Updated to handle list
      plotImage: json['plot_image']?.toString(),
      work: json['work']?.toString() ?? '',
      agentId: json['agent_id']?.toString(),
      status: json['status'] as int? ?? 0,
      verifyStatus: json['verify_status'] as int? ?? 0,
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
  String get formattedPrice => _formatNumber(price);
  String get formattedArea => '$area sq.ft';
  String get location => '${city?.cityName ?? ''}, ${state?.stateName ?? ''}'.trim();
  bool get isVerified => verifyStatus == 1;
  bool get hasPlotImage => plotImage != null && plotImage!.isNotEmpty;

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
      id: json['id'] as int,
      stateId: json['state_id'] as int,
      cityName: json['city_name']?.toString() ?? '',
      status: json['status'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at']?.toString() ?? ''),
      updatedAt: DateTime.parse(json['updated_at']?.toString() ?? ''),
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
      id: json['id'] as int,
      stateName: json['state_name']?.toString() ?? '',
      status: json['status'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at']?.toString() ?? ''),
      updatedAt: DateTime.parse(json['updated_at']?.toString() ?? ''),
    );
  }
}