// model/bank_details_model.dart

class BankDetails {
  final int id;
  final int userId;
  final String? upiId;
  final String? upiPhone;
  final String? phoneNumber;
  final String? bankAccountNumber;
  final String? ifscCode;
  final String? accountHolderName;
  final String? bankName;
  final String? branchName;
  final String status;
  final String? createdAt;
  final String? updatedAt;

  BankDetails({
    required this.id,
    required this.userId,
    this.upiId,
    this.upiPhone,
    this.phoneNumber,
    this.bankAccountNumber,
    this.ifscCode,
    this.accountHolderName,
    this.bankName,
    this.branchName,
    this.status = 'active',
    this.createdAt,
    this.updatedAt,
  });

  factory BankDetails.fromJson(Map<String, dynamic> json) {
    return BankDetails(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      upiId: json['upi_id'],
      upiPhone: json['upi_phone'],
      phoneNumber: json['phone_number'],
      bankAccountNumber: json['bank_account_number'],
      ifscCode: json['ifsc_code'],
      accountHolderName: json['account_holder_name'],
      bankName: json['bank_name'],
      branchName: json['branch_name'],
      status: json['status'] ?? 'active',
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() => {
    if (upiId != null && upiId!.isNotEmpty) 'upi_id': upiId,
    if (upiPhone != null && upiPhone!.isNotEmpty) 'upi_phone': upiPhone,
    if (phoneNumber != null && phoneNumber!.isNotEmpty)
      'phone_number': phoneNumber,
    if (bankAccountNumber != null && bankAccountNumber!.isNotEmpty)
      'bank_account_number': bankAccountNumber,
    if (ifscCode != null && ifscCode!.isNotEmpty) 'ifsc_code': ifscCode,
    if (accountHolderName != null && accountHolderName!.isNotEmpty)
      'account_holder_name': accountHolderName,
    if (bankName != null && bankName!.isNotEmpty) 'bank_name': bankName,
    if (branchName != null && branchName!.isNotEmpty)
      'branch_name': branchName,
    'status': status,
  };

  bool get isActive => status == 'active';

  /// Mask all but last 4 digits of account number.
  String get maskedAccount {
    final acc = bankAccountNumber ?? '';
    if (acc.length <= 4) return acc;
    return '${'• ' * ((acc.length - 4) ~/ 2 + 1)}${acc.substring(acc.length - 4)}';
  }
}