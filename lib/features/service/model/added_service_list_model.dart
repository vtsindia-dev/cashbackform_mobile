class AddedServiceListModel {
  int? id;
  int? userId;
  int? serviceId;
  String? createdAt;
  String? updatedAt;
  int? isDeleted;
  Service? service;

  AddedServiceListModel(
      {this.id,
        this.userId,
        this.serviceId,
        this.createdAt,
        this.updatedAt,
        this.isDeleted,
        this.service});

  AddedServiceListModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    serviceId = json['service_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    isDeleted = json['is_deleted'];
    service =
    json['service'] != null ? new Service.fromJson(json['service']) : null;
  }

}

class Service {
  int? id;
  String? serviceName;
  int? categoryId;
  int? subcategoryId;
  List<String>? image;
  int? status;
  int? featured;
  String? createdAt;
  String? updatedAt;
  String? gallery;

  Service(
      {this.id,
        this.serviceName,
        this.categoryId,
        this.subcategoryId,
        this.image,
        this.status,
        this.featured,
        this.createdAt,
        this.updatedAt,
        this.gallery});

  Service.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    serviceName = json['service_name'];
    categoryId = json['category_id'];
    subcategoryId = json['subcategory_id'];
    image = json['image'].cast<String>();
    status = json['status'];
    featured = json['featured'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    gallery = json['gallery'];
  }
}
