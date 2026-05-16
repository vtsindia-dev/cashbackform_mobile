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
  int? enStatus; // Added missing field

  EnCashMentModel({
    this.id,
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
    this.reuse,
    this.enStatus,
  });

  EnCashMentModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    couponId = json['coupon_id'];
    bank = json['bank'] != null ? Bank.fromJson(json['bank']) : null;
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
    enStatus = json['en_status']; // Added missing field
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['coupon_id'] = couponId;
    if (bank != null) {
      data['bank'] = bank!.toJson();
    }
    data['total_amount'] = totalAmount;
    data['amount'] = amount;
    data['gst'] = gst;
    data['payment_type'] = paymentType;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['status'] = status;
    data['name'] = name;
    data['user_scratch'] = userScratch;
    data['cancel_status'] = cancelStatus;
    data['grand_total'] = grandTotal;
    data['reuse'] = reuse;
    data['en_status'] = enStatus;
    return data;
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

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['bank_name'] = bankName;
    data['bank_account_number'] = bankAccountNumber;
    data['bank_ifsc_code'] = bankIfscCode;
    data['bank_beneficiary_name'] = bankBeneficiaryName;
    data['bank_phone_number'] = bankPhoneNumber;
    data['gpay_upi_id'] = gpayUpiId;
    data['gpay_phone_number'] = gpayPhoneNumber;
    return data;
  }
}

double? parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}