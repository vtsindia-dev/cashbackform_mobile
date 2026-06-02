// Featured Banner Model
class FeaturedBanner {
  final int id;
  final String image;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? redirectUrl;


  FeaturedBanner({
    required this.id,
    required this.image,
    required this.createdAt,
    required this.updatedAt,
    this.redirectUrl
  });

  factory FeaturedBanner.fromJson(Map<String, dynamic> json) {
    return FeaturedBanner(
      id: json['id'] ?? 0,
      image: json['image'] ?? '',
      redirectUrl: json['redirect_url'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toString()).toLocal(),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toString()).toLocal(),
    );
  }
}

// Featured City Model
class FeaturedCity {
  final int id;
  final int stateId;
  final String cityName;
  final int status;
  final DateTime createdAt;
  final DateTime updatedAt;

  FeaturedCity({
    required this.id,
    required this.stateId,
    required this.cityName,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FeaturedCity.fromJson(Map<String, dynamic> json) {
    return FeaturedCity(
      id: json['id'] ?? 0,
      stateId: json['state_id'] ?? 0,
      cityName: json['city_name'] ?? '',
      status: json['status'] ?? 0,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toString()).toLocal(),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toString()).toLocal(),
    );
  }
}

// Featured State Model
class FeaturedState {
  final int id;
  final String stateName;
  final int status;
  final DateTime createdAt;
  final DateTime updatedAt;

  FeaturedState({
    required this.id,
    required this.stateName,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FeaturedState.fromJson(Map<String, dynamic> json) {
    return FeaturedState(
      id: json['id'] ?? 0,
      stateName: json['state_name'] ?? '',
      status: json['status'] ?? 0,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toString()).toLocal(),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toString()).toLocal(),
    );
  }
}

// Featured Property Type Model
class FeaturedPropertyType {
  final int id;
  final String categoryName;
  final int status;
  final DateTime createdAt;
  final DateTime updatedAt;

  FeaturedPropertyType({
    required this.id,
    required this.categoryName,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FeaturedPropertyType.fromJson(Map<String, dynamic> json) {
    return FeaturedPropertyType(
      id: json['id'] ?? 0,
      categoryName: json['category_name'] ?? '',
      status: json['status'] ?? 0,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toString()).toLocal(),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toString()).toLocal(),
    );
  }
}

// Featured Syndicate Model
class FeaturedSyndicate {
  final int id;
  final String name;
  final int type;
  final String address;
  final String lat;
  final String long;
  final FeaturedCity? city;
  final FeaturedState? state;
  final String area;
  final String price;
  final String description;
  final int unitSpilt;
  final List<String> images;
  final String? plotImage;
  final String? work;
  final DateTime createdAt;
  final DateTime updatedAt;
  final FeaturedPropertyType propertyType;
  final int? soldStatus;

  FeaturedSyndicate({
    required this.id,
    required this.name,
    required this.type,
    required this.address,
    required this.lat,
    required this.long,
    this.city,
    this.state,
    required this.area,
    required this.price,
    required this.description,
    required this.unitSpilt,
    required this.images,
    this.plotImage,
    this.work,
    required this.createdAt,
    required this.updatedAt,
    required this.propertyType,
    this.soldStatus
  });

  factory FeaturedSyndicate.fromJson(Map<String, dynamic> json) {
    // Parse images array
    List<String> imagesList = [];
    if (json['image'] is List) {
      imagesList = List<String>.from(json['image']);
    } else if (json['image'] is String) {
      imagesList = [json['image']];
    }

    return FeaturedSyndicate(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      type: json['type'] ?? 0,
      address: json['address'] ?? '',
      lat: json['lat']?.toString() ?? '',
      long: json['long']?.toString() ?? '',
      city: json['city'] != null ? FeaturedCity.fromJson(json['city']) : null,
      state: json['state'] != null ? FeaturedState.fromJson(json['state']) : null,
      area: json['area']?.toString() ?? '',
      price: json['price']?.toString() ?? '',
      description: json['description'] ?? '',
      unitSpilt: json['unit_spilt'] ?? 0,
      images: imagesList,
      plotImage: json['plot_image'],
      soldStatus : json['sold_status'],
      work: json['work'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toString()).toLocal(),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toString()).toLocal(),
      propertyType: FeaturedPropertyType.fromJson(json['property_type'] ?? {}),
    );
  }

  // Helper methods
  String get thumbnailImage => images.isNotEmpty ? images.first : (plotImage ?? '');

  String get formattedPrice {
    try {
      final priceValue = double.tryParse(price);
      return priceValue != null ? '₹${priceValue.toStringAsFixed(2)}' : '₹0.00';
    } catch (e) {
      return '₹0.00';
    }
  }

  String get formattedArea => '$area sq. ft';

  String get location => city?.cityName ?? address;

  String get propertyTypeName => propertyType.categoryName;
}

class FeaturedMarketProperty {
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
  final int? soldStatus;


  FeaturedMarketProperty({
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
    this.soldStatus

  });

  factory FeaturedMarketProperty.fromJson(Map<String, dynamic> json) {
    // Parse images array
    List<String> imagesList = [];
    if (json['image'] is List) {
      imagesList = List<String>.from(json['image']);
    } else if (json['image'] is String) {
      imagesList = [json['image']];
    }

    return FeaturedMarketProperty(
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
      soldStatus : json['sold_status'],
      description: json['description'] ?? '',
      images: imagesList,
      verifyStatus: json['verify_status'] ?? 0,
      uldNo: json['uld_no']?.toString() ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toString()).toLocal(),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toString()).toLocal(),
      propertyType: json['property_type'] != null
          ? FeaturedPropertyType.fromJson(json['property_type'])
          : null,
    );
  }

  String get thumbnailImage => images.isNotEmpty ? images.first : '';

  String get formattedPrice {
    try {
      final priceValue = double.tryParse(price);
      return priceValue != null ? '₹${priceValue.toStringAsFixed(2)}' : '₹0.00';
    } catch (e) {
      return '₹0.00';
    }
  }

  String get formattedArea => '$area sq. ft';

  bool get isVerified => verifyStatus == 1;

  String get cityName => city?.cityName ?? 'Not specified';

  String get stateName => state?.stateName ?? 'Not specified';

  String get propertyTypeName => propertyType?.categoryName ?? 'Not specified';
}

class FeaturedPagination {
  final int currentPage;
  final int total;
  final int perPage;
  final int lastPage;

  FeaturedPagination({
    required this.currentPage,
    required this.total,
    required this.perPage,
    required this.lastPage,
  });

  factory FeaturedPagination.fromJson(Map<String, dynamic> json) {
    return FeaturedPagination(
      currentPage: json['current_page'] ?? 1,
      total: json['total'] ?? 0,
      perPage: json['per_page'] ?? 10,
      lastPage: json['last_page'] ?? 1,
    );
  }

  bool get hasMorePages => currentPage < lastPage;
  bool get isFirstPage => currentPage == 1;
  bool get isLastPage => currentPage == lastPage;
}

class FeaturedBannerResponse {
  final List<FeaturedBanner> banners;

  FeaturedBannerResponse({required this.banners});

  factory FeaturedBannerResponse.fromJson(List<dynamic> json) {
    return FeaturedBannerResponse(
      banners: json.map((banner) => FeaturedBanner.fromJson(banner)).toList(),
    );
  }
}

class FeaturedSyndicateResponse {
  final List<FeaturedSyndicate> syndicates;
  final FeaturedPagination pagination;

  FeaturedSyndicateResponse({
    required this.syndicates,
    required this.pagination,
  });

  factory FeaturedSyndicateResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> syndicatesData = json['syndicate'] ?? [];
    final paginationData = json['pagination'] ?? {};

    return FeaturedSyndicateResponse(
      syndicates: syndicatesData
          .map((data) => FeaturedSyndicate.fromJson(data))
          .toList(),
      pagination: FeaturedPagination.fromJson(paginationData),
    );
  }
}

class FeaturedMarketResponse {
  final List<FeaturedMarketProperty> marketProperties;
  final FeaturedPagination pagination;

  FeaturedMarketResponse({
    required this.marketProperties,
    required this.pagination,
  });

  factory FeaturedMarketResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> marketData = json['market'] ?? [];
    final paginationData = json['pagination'] ?? {};

    return FeaturedMarketResponse(
      marketProperties: marketData
          .map((data) => FeaturedMarketProperty.fromJson(data))
          .toList(),
      pagination: FeaturedPagination.fromJson(paginationData),
    );
  }
}
class GiooPlot {
  final int id;
  final String name;
  final int type;
  final String lat;
  final String long;
  final String address;
  final FeaturedCity? city;
  final FeaturedState? state;
  final String area;
  final String price;
  final String description;
  final int unitSpilt;
  final List<String> images;
  final String plotImage;
  final String work;
  final String? agentId;
  final int status;
  final int featured;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String aminities;
  final String? bluePrint;
  final String totalPrice;
  final String uldNo;
  final int adminBlock;
  final FeaturedPropertyType propertyType;
  final int? soldStatus;

  GiooPlot({
    required this.id,
    required this.name,
    required this.type,
    required this.lat,
    required this.long,
    required this.address,
    this.city,
    this.state,
    required this.area,
    required this.price,
    required this.description,
    required this.unitSpilt,
    required this.images,
    required this.plotImage,
    required this.work,
    this.agentId,
    required this.status,
    required this.featured,
    required this.createdAt,
    required this.updatedAt,
    required this.aminities,
    this.bluePrint,
    required this.totalPrice,
    required this.uldNo,
    required this.adminBlock,
    required this.propertyType,
    this.soldStatus
  });

  factory GiooPlot.fromJson(Map<String, dynamic> json) {
    List<String> imagesList = [];
    if (json['image'] is List) {
      imagesList = List<String>.from(json['image']);
    } else if (json['image'] is String) {
      imagesList = [json['image']];
    }
    return GiooPlot(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      type: json['type'] ?? 0,
      lat: json['lat']?.toString() ?? '',
      long: json['long']?.toString() ?? '',
      address: json['address'] ?? '',
      city: json['city'] != null ? FeaturedCity.fromJson(json['city']) : null,
      state: json['state'] != null ? FeaturedState.fromJson(json['state']) : null,
      area: json['area']?.toString() ?? '',
      price: json['price']?.toString() ?? '',
      description: json['description'] ?? '',
      unitSpilt: json['unit_spilt'] ?? 0,
      images: imagesList,
      plotImage: json['plot_image'] ?? '',
      work: json['work'] ?? '',
      agentId: json['agent_id']?.toString(),
      status: json['status'] ?? 0,
      featured: json['featured'] ?? 0,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toString()).toLocal(),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toString()).toLocal(),
      aminities: json['aminities']?.toString() ?? '',
      bluePrint: json['blue_print'],
      soldStatus : json['sold_status'],
      totalPrice: json['total_price']?.toString() ?? '',
      uldNo: json['uld_no']?.toString() ?? '',
      adminBlock: json['admin_block'] ?? 0,
      propertyType: FeaturedPropertyType.fromJson(json['property_type'] ?? {}),
    );
  }
  String get thumbnailImage => images.isNotEmpty ? images.first : plotImage;
  String get formattedPrice {
    try {
      final priceValue = double.tryParse(totalPrice.isNotEmpty ? totalPrice : price);
      return priceValue != null ? '₹${priceValue.toStringAsFixed(2)}' : '₹0.00';
    } catch (e) {
      return '₹0.00';
    }
  }

  String get formattedArea => '$area sq. ft';

  String get location => city?.cityName ?? address;

  String get propertyTypeName => propertyType.categoryName;

  bool get isFeatured => featured == 1;
}

// GIOO Response Model
class GiooResponse {
  final List<GiooPlot> giooPlots;
  final FeaturedPagination pagination;

  GiooResponse({
    required this.giooPlots,
    required this.pagination,
  });

  factory GiooResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> giooData = json['geo'] ?? [];
    final paginationData = json['pagination'] ?? {};

    return GiooResponse(
      giooPlots: giooData
          .map((data) => GiooPlot.fromJson(data))
          .toList(),
      pagination: FeaturedPagination.fromJson(paginationData),
    );
  }
}