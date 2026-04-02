class CouponListModel {
  List<CouponList>? data;
  int? currentPage;
  int? lastPage;
  int? perPage;
  int? total;

  CouponListModel(
      {this.currentPage,
        this.data,
        this.lastPage,
        this.perPage,
        this.total});

  CouponListModel.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    if (json['data'] != null) {
      data = <CouponList>[];
      json['data'].forEach((v) {
        data!.add(CouponList.fromJson(v));
      });
    }
    lastPage = json['last_page'];
    perPage = json['per_page'];
    total = json['total'];
  }
}

class CouponList {
  int? id;
  String? name;
  String? amount;
  int? status;
  int? userId;
  int? gst;
  int? cancelStatus;
  int? reuse;
  String? createdAt;
  String? expiryDate;
  String? updatedAt;
  int? isDeleted;

  CouponList(
      {this.id,
        this.name,
        this.amount,
        this.status,
        this.userId,
        this.gst,
        this.cancelStatus,
        this.reuse,
        this.createdAt,
        this.expiryDate,
        this.updatedAt,
        this.isDeleted});

  CouponList.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    amount = json['amount'];
    status = json['status'];
    userId = json['user_id'];
    gst = json['gst'];
    cancelStatus = json['cancel_status'];
    reuse = json['reuse'];
    createdAt = json['created_at'];
    expiryDate = json['expiry_date'];
    updatedAt = json['updated_at'];
    isDeleted = json['is_deleted'];
  }

}

