
class LegalAndPoliciesModel {
  int? id;
  String? title;
  String? slug;
  String? content;
  String? createdAt;
  String? updatedAt;

  LegalAndPoliciesModel(
      {this.id,
        this.title,
        this.slug,
        this.content,
        this.createdAt,
        this.updatedAt});

  LegalAndPoliciesModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    slug = json['slug'];
    content = json['content'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

}
