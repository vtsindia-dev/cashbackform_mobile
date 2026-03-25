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
  final String signDoc;
  final String? type;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int isDeleted;

  KYCDocument({
    required this.id,
    this.propertyId,
    required this.userId,
    required this.name,
    required this.panNo,
    required this.aadharNo,
    required this.panDoc,
    required this.aadharDoc,
    required this.signDoc,
    this.type,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
  });

  factory KYCDocument.fromJson(Map<String, dynamic> json) {
    return KYCDocument(
      id: json['id'],
      propertyId: json['property_id'],
      userId: json['user_id'],
      name: json['name'],
      panNo: json['pan_no'],
      aadharNo: json['aadhar_no'],
      panDoc: json['pan_doc'],
      aadharDoc: json['aadhar_doc'],
      signDoc: json['sign_doc'],
      type: json['type'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      isDeleted: json['is_deleted'],
    );
  }
}

class KYCDocumentInput {
  final String name;
  final String panNo;
  final String aadharNo;
  final File? panDoc;
  final File? aadharDoc;
  final File? signDoc;

  KYCDocumentInput({
    required this.name,
    required this.panNo,
    required this.aadharNo,
    this.panDoc,
    this.aadharDoc,
    this.signDoc,
  });
}