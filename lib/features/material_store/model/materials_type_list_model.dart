
class MaterialsTypeListModel {
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
  Category? category;

  MaterialsTypeListModel(
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
        this.brand,
        this.category});

  MaterialsTypeListModel.fromJson(Map<String, dynamic> json) {
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
    category = json['category'] != null
        ? new Category.fromJson(json['category'])
        : null;
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

class Category {
  int? id;
  String? categoryName;
  String? image;
  int? status;
  String? createdAt;
  String? updatedAt;

  Category(
      {this.id,
        this.categoryName,
        this.image,
        this.status,
        this.createdAt,
        this.updatedAt});

  Category.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    categoryName = json['category_name'];
    image = json['image'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }
}
