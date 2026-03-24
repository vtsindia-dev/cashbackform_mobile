
class HomeCategoryModelList {
  int? id;
  String? categoryName;
  String? image;
  int? status;
  int? featured;
  String? createdAt;
  String? updatedAt;

  HomeCategoryModelList(
      {this.id,
        this.categoryName,
        this.image,
        this.status,
        this.featured,
        this.createdAt,
        this.updatedAt});

  HomeCategoryModelList.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    categoryName = json['category_name'];
    image = json['image'];
    status = json['status'];
    featured = json['featured'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }
}
