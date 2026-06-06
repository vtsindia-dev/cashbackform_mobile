
int _toSafeInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

int? _toSafeIntNullable(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

class ReceivedEnquiryResponse {
  final int status;
  final ReceivedEnquiryData data;

  ReceivedEnquiryResponse({required this.status, required this.data});

  factory ReceivedEnquiryResponse.fromJson(Map<String, dynamic> json) {
    return ReceivedEnquiryResponse(
      status: _toSafeInt(json['status'] ?? 200),
      data: ReceivedEnquiryData.fromJson(json['data'] ?? {}),
    );
  }
}

class ReceivedEnquiryData {
  final List<ReceivedEnquiry> enquiries;
  final ReceivedPagination pagination;

  ReceivedEnquiryData({required this.enquiries, required this.pagination});

  factory ReceivedEnquiryData.fromJson(Map<String, dynamic> json) {
    final list = json['material_enquiry'] as List<dynamic>? ?? [];
    return ReceivedEnquiryData(
      enquiries: list.map((e) => ReceivedEnquiry.fromJson(e)).toList(),
      pagination: ReceivedPagination.fromJson(json['pagination'] ?? {}),
    );
  }
}

class ReceivedEnquiry {
  final int id;
  final int? serviceId;
  final int? userId;
  final String? name;
  final String? email;
  final String? phone;
  final String? assignedVendor;
  final int accepted;
  final String quote;
  final int? quantity;
  final String? status;
  final String? datePreference;
  final String? timePreference;
  final DateTime createdAt;
  final DateTime updatedAt;
  final EnquiryUserInfo? user;
  final EnquiryServiceInfo? service;

  ReceivedEnquiry({
    required this.id,
    this.serviceId,
    this.userId,
    this.name,
    this.email,
    this.phone,
    this.assignedVendor,
    required this.accepted,
    required this.quote,
    this.quantity,
    this.status,
    this.datePreference,
    this.timePreference,
    required this.createdAt,
    required this.updatedAt,
    this.user,
    this.service,
  });

  factory ReceivedEnquiry.fromJson(Map<String, dynamic> json) {
    final serviceOrMaterial = json['service'] ?? json['material'];
    return ReceivedEnquiry(
      id: _toSafeInt(json['id']),
      serviceId: _toSafeIntNullable(json['service_id'] ?? json['material_id']),
      userId: _toSafeIntNullable(json['user_id']),
      name: json['name']?.toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      assignedVendor: json['assigned_vendor']?.toString(),
      accepted: _toSafeInt(json['accepted']),
      quote: json['quote']?.toString() ?? '',
      quantity: _toSafeIntNullable(json['quantity']),
      status: json['status']?.toString(),
      datePreference: json['date_preference']?.toString(),
      timePreference: json['time_preference']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at']).toLocal()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at']).toLocal()
          : DateTime.now(),
      user: json['user'] != null
          ? EnquiryUserInfo.fromJson(json['user'])
          : null,
      service: serviceOrMaterial != null
          ? EnquiryServiceInfo.fromJson(serviceOrMaterial)
          : null,
    );
  }

  String get enquiryStatusLabel {
    if (accepted == 1) return 'Accepted';
    return 'Pending';
  }
}

class EnquiryUserInfo {
  final int id;
  final String name;
  final String? email;
  final String? phone;
  final String? avatar;
  final String? firstName;
  final String? lastName;

  EnquiryUserInfo({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.avatar,
    this.firstName,
    this.lastName,
  });

  factory EnquiryUserInfo.fromJson(Map<String, dynamic> json) {
    return EnquiryUserInfo(
      id: _toSafeInt(json['id']),
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      avatar: json['avatar']?.toString(),
      firstName: json['first_name']?.toString(),
      lastName: json['last_name']?.toString(),
    );
  }

  String get displayName {
    if (firstName != null && firstName!.isNotEmpty) {
      return '$firstName ${lastName ?? ''}'.trim();
    }
    return name;
  }
}

class EnquiryServiceInfo {
  final int id;
  final String serviceName;
  final List<String> image;
  final String? gallery;

  EnquiryServiceInfo({
    required this.id,
    required this.serviceName,
    required this.image,
    this.gallery,
  });

  factory EnquiryServiceInfo.fromJson(Map<String, dynamic> json) {
    List<String> images = [];
    final raw = json['image'];
    if (raw is List) {
      images = raw.map((e) => e.toString()).toList();
    } else if (raw is String) {
      images = [raw];
    }
    return EnquiryServiceInfo(
      id: _toSafeInt(json['id']),
      serviceName: json['service_name']?.toString() ?? json['material_name']?.toString() ?? '',
      image: images,
      gallery: json['gallery']?.toString(),
    );
  }
}

class ReceivedPagination {
  final int currentPage;
  final int total;
  final int perPage;
  final int lastPage;

  ReceivedPagination({
    required this.currentPage,
    required this.total,
    required this.perPage,
    required this.lastPage,
  });

  factory ReceivedPagination.fromJson(Map<String, dynamic> json) {
    return ReceivedPagination(
      currentPage: _toSafeInt(json['current_page'] ?? 1),
      total: _toSafeInt(json['total']),
      perPage: _toSafeInt(json['per_page'] ?? 10),
      lastPage: _toSafeInt(json['last_page'] ?? 1),
    );
  }
}