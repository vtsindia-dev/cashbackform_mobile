class MaterialUnitModel {
  int? id;
  String? name;
  String? abbreviation;
  String? createdAt;
  String? updatedAt;

  MaterialUnitModel({this.id, this.name, this.abbreviation, this.createdAt, this.updatedAt});

  MaterialUnitModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    abbreviation = json['abbreviation'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }
}