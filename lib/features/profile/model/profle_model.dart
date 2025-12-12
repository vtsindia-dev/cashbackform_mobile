class ProfileModel {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final int gender;
  final String? dob;
  final String? pinCode;
  final String? address;
  final String? profileImage;
  final bool isEmailVerifiedBool;
  final bool isPhoneVerifiedBool;

  ProfileModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.gender,
    this.dob,
    this.pinCode,
    this.address,
    this.profileImage,
    required this.isEmailVerifiedBool,
    required this.isPhoneVerifiedBool,
  });

  String get fullName => '${firstName.trim()} ${lastName.trim()}'.trim();

  String get formattedGender {
    switch (gender) {
      case 1:
        return 'Male';
      case 2:
        return 'Female';
      case 3:
        return 'Other';
      default:
        return 'Not set';
    }
  }

  /// Optional formatted DOB (you can adjust formatting if needed)
  String? get formattedDob {
    if (dob == null || dob!.isEmpty) return null;
    return dob;
  }

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    bool parseBool(dynamic v) {
      if (v == null) return false;
      if (v is bool) return v;
      if (v is int) return v == 1;
      final s = v.toString().toLowerCase();
      return s == '1' || s == 'true' || s == 'yes';
    }

    return ProfileModel(
      id: (json['id'] is int) ? json['id'] as int : int.tryParse('${json['id'] ?? 0}') ?? 0,
      firstName: json['first_name']?.toString() ?? json['firstName']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? json['lastName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      gender: (json['gender'] is int) ? json['gender'] as int : int.tryParse('${json['gender'] ?? 0}') ?? 0,
      dob: json['dob']?.toString(),
      pinCode: json['pin_code']?.toString() ?? json['pinCode']?.toString(),
      address: json['address']?.toString(),
      profileImage: json['profile_image']?.toString() ?? json['avatar']?.toString(),
      isEmailVerifiedBool: parseBool(json['is_email_verified'] ?? json['email_verified'] ?? 0),
      isPhoneVerifiedBool: parseBool(json['is_phone_verified'] ?? json['phone_verified'] ?? 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'gender': gender,
      'dob': dob,
      'pin_code': pinCode,
      'address': address,
      'profile_image': profileImage,
      'is_email_verified': isEmailVerifiedBool ? 1 : 0,
      'is_phone_verified': isPhoneVerifiedBool ? 1 : 0,
    };
  }
}
