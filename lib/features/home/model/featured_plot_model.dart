class FeaturedPlotProperty {
  int? status;
  Data? data;

  FeaturedPlotProperty({this.status, this.data});

  FeaturedPlotProperty.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }
}

class Data {
  List<Syndicate>? syndicate;
  Pagination? pagination;

  Data({this.syndicate, this.pagination});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['syndicate'] != null) {
      syndicate = <Syndicate>[];
      json['syndicate'].forEach((v) {
        syndicate!.add(Syndicate.fromJson(v));
      });
    }
    pagination = json['pagination'] != null
        ? Pagination.fromJson(json['pagination'])
        : null;
  }
}

class Syndicate {
  int? id;
  int? country;
  String? propertyName;
  String? location;
  String? lat;
  String? lng;
  String? price;
  int? areaSqft;
  String? areaSqftPrice;
  bool? gated;
  int? categoryId;
  String? transactionType;
  bool? boundaryWall;
  String? aboutProperty;
  String? landApproval;
  String? constructionGuidelines;
  String? sitePlan;
  String? threeDImage;
  List<String>? galleryImages;
  String? thumbnail;
  int? verifyStatus;
  String? userType;
  int? customerId;
  bool? isActive;
  int? soldStatus;
  String? soldAmount;
  int? featured;
  String? createdAt;
  String? updatedAt;
  String? blueprint;
  int? plotCount;
  String? youtubeLink;

  Syndicate({
    this.id,
    this.country,
    this.propertyName,
    this.location,
    this.lat,
    this.lng,
    this.price,
    this.areaSqft,
    this.areaSqftPrice,
    this.gated,
    this.categoryId,
    this.transactionType,
    this.boundaryWall,
    this.aboutProperty,
    this.landApproval,
    this.constructionGuidelines,
    this.sitePlan,
    this.threeDImage,
    this.galleryImages,
    this.thumbnail,
    this.verifyStatus,
    this.userType,
    this.customerId,
    this.isActive,
    this.soldStatus,
    this.soldAmount,
    this.featured,
    this.createdAt,
    this.updatedAt,
    this.blueprint,
    this.plotCount,
    this.youtubeLink,
  });

  Syndicate.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    country = json['country'];
    propertyName = json['property_name'];
    location = json['location'];
    lat = json['lat'];
    lng = json['lng'];
    price = json['price'];
    areaSqft = json['area_sqft'];
    areaSqftPrice = json['area_sqft_price'];
    gated = json['gated'];
    categoryId = json['category_id'];
    transactionType = json['transaction_type'];
    boundaryWall = json['boundary_wall'];
    aboutProperty = json['about_property'];
    landApproval = json['land_approval'];
    constructionGuidelines = json['construction_guidelines'];
    sitePlan = json['site_plan'];
    threeDImage = json['three_d_image'];
    galleryImages = json['gallery_images'] != null
        ? (json['gallery_images'] as List).map((e) => e.toString()).toList()
        : [];
    thumbnail = json['thumbnail'];
    verifyStatus = json['verify_status'];
    userType = json['user_type'];
    customerId = json['customer_id'];
    isActive = json['is_active'];
    soldStatus = json['sold_status'];
    soldAmount = json['sold_amount'];
    featured = json['featured'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    blueprint = json['blueprint'];
    plotCount = json['plot_count'];
    youtubeLink = json['youtube_link'];
  }
}


class Facilities {
  int? id;
  String? value;
  int? facilityId;
  int? plotId;
  String? createdAt;
  String? updatedAt;
  String? images;
  String? name;
  List<Fac>? fac;

  Facilities({
    this.id,
    this.value,
    this.facilityId,
    this.plotId,
    this.createdAt,
    this.updatedAt,
    this.images,
    this.name,
    this.fac,
  });

  Facilities.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    value = json['value'];
    facilityId = json['facility_id'];
    plotId = json['plot_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    images = json['images'];
    name = json['name'];
    if (json['fac'] != null) {
      fac = <Fac>[];
      json['fac'].forEach((v) {
        fac!.add(Fac.fromJson(v));
      });
    }
  }
}

class Fac {
  int? id;
  String? name;
  String? type;
  int? isRequired;
  String? value;
  String? image;
  int? isDeleted;
  String? createdAt;
  String? updatedAt;

  Fac({
    this.id,
    this.name,
    this.type,
    this.isRequired,
    this.value,
    this.image,
    this.isDeleted,
    this.createdAt,
    this.updatedAt,
  });

  Fac.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    type = json['type'];
    isRequired = json['is_required'];
    value = json['value'];
    image = json['image'];
    isDeleted = json['is_deleted'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }
}

class NearbyLocations {
  int? id;
  String? title;
  String? image;
  String? createdAt;
  String? updatedAt;
  Pivot? pivot;

  NearbyLocations({
    this.id,
    this.title,
    this.image,
    this.createdAt,
    this.updatedAt,
    this.pivot,
  });

  NearbyLocations.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    image = json['image'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    pivot = json['pivot'] != null ? Pivot.fromJson(json['pivot']) : null;
  }
}

class Pivot {
  int? plotId;
  int? nearbyLocationId;
  String? distance;
  String? createdAt;
  String? updatedAt;

  Pivot({
    this.plotId,
    this.nearbyLocationId,
    this.distance,
    this.createdAt,
    this.updatedAt,
  });

  Pivot.fromJson(Map<String, dynamic> json) {
    plotId = json['plot_id'];
    nearbyLocationId = json['nearby_location_id'];
    distance = json['distance'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }
}


class Pagination {
  int? currentPage;
  int? total;
  int? perPage;
  int? lastPage;

  Pagination({
    this.currentPage,
    this.total,
    this.perPage,
    this.lastPage,
  });

  Pagination.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    total = json['total'];
    perPage = json['per_page'];
    lastPage = json['last_page'];
  }
}