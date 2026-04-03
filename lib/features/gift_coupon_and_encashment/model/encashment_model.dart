
class EnCashMentModel {
  int? id;
  int? userId;
  int? couponId;
  Bank? bank;
  double? totalAmount;
  double? amount;
  double? gst;
  String? paymentType;
  String? createdAt;
  String? updatedAt;
  int? status;
  String? name;
  int? userScratch;
  int? cancelStatus;
  double? grandTotal;
  int? reuse;

  EnCashMentModel(
      {this.id,
        this.userId,
        this.couponId,
        this.bank,
        this.totalAmount,
        this.amount,
        this.gst,
        this.paymentType,
        this.createdAt,
        this.updatedAt,
        this.status,
        this.name,
        this.userScratch,
        this.cancelStatus,
        this.grandTotal,
        this.reuse
      });

  EnCashMentModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    couponId = json['coupon_id'];
    bank = json['bank'] != null ? new Bank.fromJson(json['bank']) : null;
    totalAmount = parseDouble(json['total_amount']);
    amount = parseDouble(json['amount']);
    gst = parseDouble(json['gst']);
    paymentType = json['payment_type'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    status = json['status'];
    name = json['name'];
    userScratch = json['user_scratch'];
    cancelStatus = json['cancel_status'];
    grandTotal = parseDouble(json['grand_total']);
    reuse = json['reuse'];
  }
}

class Bank {
  String? bankName;
  String? bankAccountNumber;
  String? bankIfscCode;
  String? bankBeneficiaryName;
  String? bankPhoneNumber;
  String? gpayUpiId;
  String? gpayPhoneNumber;

  Bank({
    this.bankName,
    this.bankAccountNumber,
    this.bankIfscCode,
    this.bankBeneficiaryName,
    this.bankPhoneNumber,
    this.gpayUpiId,
    this.gpayPhoneNumber,
  });

  Bank.fromJson(Map<String, dynamic> json) {
    bankName = json['bank_name'];
    bankAccountNumber = json['bank_account_number'];
    bankIfscCode = json['bank_ifsc_code'];
    bankBeneficiaryName = json['bank_beneficiary_name'];
    bankPhoneNumber = json['bank_phone_number'];
    gpayUpiId = json['gpay_upi_id'];
    gpayPhoneNumber = json['gpay_phone_number'];
  }
}


double? parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}