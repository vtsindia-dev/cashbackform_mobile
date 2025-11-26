class SyndicatePlot {
  final int id;
  final String name;
  final int? type;
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
  final String image;
  final String plotImage;
  final String work;
  final String? agentId;
  final int status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final dynamic propertyType;

  SyndicatePlot({
    required this.id,
    required this.name,
    required this.type,
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
    required this.image,
    required this.plotImage,
    required this.work,
    required this.agentId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.propertyType,
  });

  factory SyndicatePlot.fromJson(Map<String, dynamic> json) {
    return SyndicatePlot(
      id: json['id'] as int,
      name: json['name']?.toString() ?? '',
      type: json['type'] as int?,
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
      image: json['image']?.toString() ?? '',
      plotImage: json['plot_image']?.toString() ?? '',
      work: json['work']?.toString() ?? '',
      agentId: json['agent_id']?.toString(),
      status: json['status'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at']?.toString() ?? ''),
      updatedAt: DateTime.parse(json['updated_at']?.toString() ?? ''),
      propertyType: json['property_type'],
    );
  }

  // Helper methods
  String get formattedPrice => '${_formatNumber(price)}';
  String get formattedArea => '$area sq.ft';
  String get location => '${city?.cityName ?? ''}, ${state?.stateName ?? ''}'.trim();

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
  final String? createdAt;
  final String? updatedAt;

  City({
    required this.id,
    required this.stateId,
    required this.cityName,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'] as int? ?? 0,
      stateId: json['state_id'] as int? ?? 0,
      cityName: json['city_name'] as String? ?? '',
      status: json['status'] as int? ?? 0,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }
}

class State {
  final int id;
  final String stateName;
  final int status;
  final String? createdAt;
  final String? updatedAt;

  State({
    required this.id,
    required this.stateName,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory State.fromJson(Map<String, dynamic> json) {
    return State(
      id: json['id'] as int? ?? 0,
      stateName: json['state_name'] as String? ?? '',
      status: json['status'] as int? ?? 0,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }
}


class SyndicateDetail {
  final int id;
  final String name;
  final String? type;
  final String? map;
  final String address;
  final String lat;
  final String long;
  final City? city;
  final State? state;
  final String area;
  final String price;
  final String description;
  final int unitSpilt;
  final String image;
  final String plotImage;
  final String work;
  final String agentId;
  final int status;
  final String? propertyType;

  SyndicateDetail({
    required this.id,
    required this.name,
    this.type,
    this.map,
    required this.address,
    required this.lat,
    required this.long,
    this.city,
    this.state,
    required this.area,
    required this.price,
    required this.description,
    required this.unitSpilt,
    required this.image,
    required this.plotImage,
    required this.work,
    required this.agentId,
    required this.status,
    this.propertyType,
  });

  factory SyndicateDetail.fromJson(Map<String, dynamic> json) {
    // Helper function to safely parse values with null handling
    String safeString(dynamic value) {
      if (value == null) return '';
      return value.toString();
    }

    int safeInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      return int.tryParse(value.toString()) ?? 0;
    }

    return SyndicateDetail(
      id: safeInt(json['id']),
      name: safeString(json['name']),
      type: json['type'] != null ? safeString(json['type']) : null,
      map: json['map'] != null ? safeString(json['map']) : null,
      address: safeString(json['address']),
      lat: safeString(json['lat']),
      long: safeString(json['long']),
      city: json['city'] != null ? City.fromJson(json['city']) : null,
      state: json['state'] != null ? State.fromJson(json['state']) : null,
      area: safeString(json['area']),
      price: safeString(json['price']),
      description: safeString(json['description']),
      unitSpilt: safeInt(json['unit_spilt']),
      image: safeString(json['image']),
      plotImage: safeString(json['plot_image']),
      work: safeString(json['work']),
      agentId: safeString(json['agent_id']),
      status: safeInt(json['status']),
      propertyType: json['property_type'] != null ? safeString(json['property_type']) : null,
    );
  }
}