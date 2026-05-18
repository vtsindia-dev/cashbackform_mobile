
class AddedMaterialsListModel {
  int? id;
  int? userId;
  int? materialId;
  String? brandId;
  String? createdAt;
  String? updatedAt;
  int? isDeleted;
  Material? material;

  AddedMaterialsListModel(
      {this.id,
        this.userId,
        this.materialId,
        this.brandId,
        this.createdAt,
        this.updatedAt,
        this.isDeleted,
        this.material});

  AddedMaterialsListModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    materialId = json['material_id'];
    brandId = json['brand_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    isDeleted = json['is_deleted'];
    material = json['material'] != null
        ? new Material.fromJson(json['material'])
        : null;
  }
}

class Material {
  int? id;
  String? materialName;
  int? categoryId;
  int? subcatId;
  int? subsubcatId;
  String? brandId;
  int? unitId;
  List<String>? image;
  int? status;
  int? isDeleted;
  int? featured;
  String? createdAt;
  String? updatedAt;
  String? gallery;
  List<Brand>? brand;

  Material(
      {this.id,
        this.materialName,
        this.categoryId,
        this.subcatId,
        this.subsubcatId,
        this.brandId,
        this.unitId,
        this.image,
        this.status,
        this.isDeleted,
        this.featured,
        this.createdAt,
        this.updatedAt,
        this.gallery,
        this.brand});

  Material.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    materialName = json['material_name'];
    categoryId = json['category_id'];
    subcatId = json['subcat_id'];
    subsubcatId = json['subsubcat_id'];
    brandId = json['brand_id'];
    unitId = json['unit_id'];
    image = json['image'].cast<String>();
    status = json['status'];
    isDeleted = json['is_deleted'];
    featured = json['featured'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    gallery = json['gallery'];
    if (json['brand'] != null) {
      brand = <Brand>[];
      json['brand'].forEach((v) {
        brand!.add(new Brand.fromJson(v));
      });
    }
  }
}

class Brand {
  int? id;
  String? name;
  String? logo;
  String? createdAt;
  String? updatedAt;

  Brand({this.id, this.name, this.logo, this.createdAt, this.updatedAt});

  Brand.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    logo = json['logo'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

}
