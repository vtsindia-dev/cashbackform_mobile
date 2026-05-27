import 'dart:io';

class KYCDocument {
  final int id;
  final int? propertyId;
  final int userId;
  final String name;
  final String panNo;
  final String aadharNo;
  final String panDoc;
  final String aadharDoc;
  final String? signDoc;
  final String? type;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int isDeleted;
  final int? transactionId;

  KYCDocument({
    required this.id,
    this.propertyId,
    required this.userId,
    required this.name,
    required this.panNo,
    required this.aadharNo,
    required this.panDoc,
    required this.aadharDoc,
    this.signDoc,
    this.type,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    this.transactionId,
  });

  factory KYCDocument.fromJson(Map<String, dynamic> json) {
    return KYCDocument(
      id: json['id'] ?? 0,
      propertyId: json['property_id'],
      userId: json['user_id'] ?? 0,
      name: json['name'] ?? '',
      panNo: json['pan_no'] ?? '',
      aadharNo: json['aadhar_no'] ?? '',
      panDoc: json['pan_doc'] ?? '',
      aadharDoc: json['aadhar_doc'] ?? '',
      signDoc: json['sign_doc'],
      type: json['type'],
      createdAt: DateTime.parse(json['created_at'] ?? '1970-01-01'),
      updatedAt: DateTime.parse(json['updated_at'] ?? '1970-01-01'),
      isDeleted: json['is_deleted'] ?? 0,
      transactionId: json['transaction_id'],
    );
  }

  bool get isActive => isDeleted == 0;
  bool get hasSignDoc => signDoc != null && signDoc!.isNotEmpty;
  bool get hasPropertyLinked => propertyId != null;
}

class KYCDocumentInput {
  final String name;
  final String panNo;
  final String aadharNo;
  final File? panDoc;
  final File? aadharDoc;
  final File? signDoc;
  final int? propertyId;
  final String? type;

  KYCDocumentInput({
    required this.name,
    required this.panNo,
    required this.aadharNo,
    this.panDoc,
    this.aadharDoc,
    this.signDoc,
    this.propertyId,
    this.type,
  });
}