class CommonSearchModel {
  int? id;
  String? name;
  String? type;
  String? address;
  String? rentAmount;
  double? price;
  String? yieldAmount;
  String? description;
  List<String>? image;
  String? plotImage;
  String? bluePrint;
  String? unit;
  int? startingPrice;
  String? area;
  PropertyType? propertyType;
  String? location;
  String? propertyName;
  String? areaSqft;
  double? areaSqftPrice;


  CommonSearchModel({
    this.id,
    this.name,
    this.type,
    this.address,
    this.rentAmount,
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
    this.areaSqftPrice
  });

  CommonSearchModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    area = json['area']?.toString();
    type = json['type']?.toString();
    address = json['address'];
    rentAmount = json['rent_amount']?.toString();
    price = parseToDouble(json['price']);
    yieldAmount = json['yield_amount']?.toString();
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