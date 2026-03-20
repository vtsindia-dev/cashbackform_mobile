class CategoriesServiceModel {
  int? id;
  String? serviceName;
  int? categoryId;
  int? subcategoryId;
  int? subSubcategoryId;
  List<String>? image;
  int? status;
  int? featured;
  String? createdAt;
  String? updatedAt;
  String? gallery;
  Category? category;

  CategoriesServiceModel(
      {this.id,
        this.serviceName,
        this.categoryId,
        this.subcategoryId,
        this.subSubcategoryId,
        this.image,
        this.status,
        this.featured,
        this.createdAt,
        this.updatedAt,
        this.gallery,
        this.category});

  CategoriesServiceModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    serviceName = json['service_name'];
    categoryId = json['category_id'];
    subcategoryId = json['subcategory_id'];
    subSubcategoryId = json['sub_subcategory_id'];
    image = json['image'].cast<String>();
    status = json['status'];
    featured = json['featured'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    gallery = json['gallery'];
    category = json['category'] != null
        ? Category.fromJson(json['category'])
        : null;
  }

}

class Category {
  int? id;
  String? categoryName;
  int? status;
  int? featured;
  String? createdAt;
  String? updatedAt;

  Category(
      {this.id,
        this.categoryName,
        this.status,
        this.featured,
        this.createdAt,
        this.updatedAt});

  Category.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    categoryName = json['category_name'];
    status = json['status'];
    featured = json['featured'];
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
