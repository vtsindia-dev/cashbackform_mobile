class CommonSearchModel {
  int? id;
  String? name;
  String? type;
  String? address;
  double? price;
  String? description;
  List<String>? image;
  String? plotImage;
  String? bluePrint;
  String? unit;
  int? startingPrice;
  String? area;
  String? location;
  String? propertyName;
  String? areaSqft;
  double? areaSqftPrice;
  City? city;
  PropertyType? propertyType;
  double? rentAmount;
  double? yieldAmount;
  int? soldStatus;


  CommonSearchModel({
    this.id,
    this.name,
    this.type,
    this.address,
    this.price,
    this.yieldAmount,
    this.description,
    this.image,
    this.plotImage,
    this.bluePrint,
    this.unit,
    this.startingPrice,
    this.area,
    this.propertyType,
    this.location,
    this.propertyName,
    this.areaSqft,
    this.areaSqftPrice,
    this.city,
    this.rentAmount,
    this.soldStatus
  });

  CommonSearchModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    area = json['area']?.toString();
    type = json['type']?.toString();
    address = json['address'];
    soldStatus = json['sold_status'];
    price = parseToDouble(json['price']);
    yieldAmount = parseToDouble(json['yield_amount']?.toString());
    rentAmount = parseToDouble(json['rent_amount']?.toString());
    description = json['description'];
    image = json['image'] != null ? List<String>.from(json['image']) : [];
    plotImage = json['plot_image'];
    bluePrint = json['blue_print'];
    location = json['location'];
    unit = json['unit']?.toString();
    propertyName = json['property_name'];
    startingPrice = parseToDouble(json['starting_price'])?.toInt();
    areaSqft = json['area_sqft']?.toString();
    areaSqftPrice = parseToDouble(json['area_sqft_price']);
    propertyType = json['property_type'] != null
        ? PropertyType.fromJson(json['property_type'])
        : null;
    city = json['city'] != null ? City.fromJson(json['city']) : null;
  }
}


class City {
  int? id;
  int? stateId;
  String? cityName;

  City(
      {this.id,
        this.stateId,
        this.cityName,
      });

  City.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    stateId = json['state_id'];
    cityName = json['city_name'];
  }
}


class PropertyType {
  int? id;
  String? categoryName;

  PropertyType.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    categoryName = json['category_name'];
  }
}


double? parseToDouble(dynamic value) {
  if (value == null) return null;

  if (value is double) return value;
  if (value is int) return value.toDouble();

  return double.tryParse(value.toString());
}