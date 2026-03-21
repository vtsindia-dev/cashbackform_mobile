
class MaterialHomeListModel {
  int? id;
  String? materialName;
  int? categoryId;
  String? brandId;
  int? unitId;
  List<String>? image;
  int? status;
  int? isDeleted;
  int? featured;
  String? createdAt;
  String? updatedAt;
  String? gallery;
  Category? category;

  MaterialHomeListModel(
      {this.id,
        this.materialName,
        this.categoryId,
        this.brandId,
        this.unitId,
        this.image,
        this.status,
        this.isDeleted,
        this.featured,
        this.createdAt,
        this.updatedAt,
        this.gallery,
        this.category});

  MaterialHomeListModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    materialName = json['material_name'];
    categoryId = json['category_id'];
    brandId = json['brand_id'];
    unitId = json['unit_id'];
    image = json['image'].cast<String>();
    status = json['status'];
    isDeleted = json['is_deleted'];
    featured = json['featured'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    gallery = json['gallery'];
    category = json['category'] != null
        ? new Category.fromJson(json['category'])
        : null;
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


class BrandList {
  int? id;
  String? name;
  String? logo;
  String? createdAt;
  String? updatedAt;

  BrandList({this.id, this.name, this.logo, this.createdAt, this.updatedAt});

  BrandList.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    logo = json['logo'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }
}


class SubCategoriesList {
  int? id;
  int? serviceCategoryId;
  String? name;
  int? status;
  String? createdAt;
  String? updatedAt;

  SubCategoriesList(
      {this.id,
        this.serviceCategoryId,
        this.name,
        this.status,
        this.createdAt,
        this.updatedAt,
      });

  SubCategoriesList.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    serviceCategoryId = json['service_category_id'];
    name = json['name'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }
}



class SubSubCategoriesList {
  int? id;
  int? serviceCategoryId;
  int? serviceSubcategoryId;
  String? name;
  String? createdAt;
  String? updatedAt;

  SubSubCategoriesList(
      {this.id,
        this.serviceCategoryId,
        this.serviceSubcategoryId,
        this.name,
        this.createdAt,
        this.updatedAt,
      });

  SubSubCategoriesList.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    serviceCategoryId = json['service_category_id'];
    serviceSubcategoryId = json['service_subcategory_id'];
    name = json['name'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }
}

