class CommonFacilityModel {
  int? id;
  String? title;
  String? image;

  CommonFacilityModel({this.id, this.title, this.image});

  CommonFacilityModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    image = json['image'];
  }
}
