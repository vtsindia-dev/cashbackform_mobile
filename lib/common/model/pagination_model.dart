class Pagination {
  int? currentPage;
  int? total;
  int? perPage;
  int? lastPage;

  Pagination({this.currentPage, this.total, this.perPage, this.lastPage});

  Pagination.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    total = json['total'];
    perPage = json['per_page'];
    lastPage = json['last_page'];
  }
}