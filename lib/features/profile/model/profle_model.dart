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
  final int? countryId;
  final int? stateId;
  final int? cityId;
  final bool isEmailVerifiedBool;
  final bool isPhoneVerifiedBool;
  final String? code;                    // Added: referral code
  final String walletBalance;            // Added: wallet balance (as String from API)
  final String cumulativeAmount;         // Added: cumulative amount
  final int? referenceId;                // Added: reference ID
  final ProfileRefer? refer;             // Added: refer object

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
    this.countryId,
    this.stateId,
    this.cityId,
    required this.isEmailVerifiedBool,
    required this.isPhoneVerifiedBool,
    this.code,
    required this.walletBalance,
    required this.cumulativeAmount,
    this.referenceId,
    this.refer,
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

  double get walletBalanceAsDouble => double.tryParse(walletBalance) ?? 0.0;
  double get cumulativeAmountAsDouble => double.tryParse(cumulativeAmount) ?? 0.0;

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    bool parseBool(dynamic v) {
      if (v == null) return false;
      if (v is bool) return v;
      if (v is int) return v == 1;
      final s = v.toString().toLowerCase();
      return s == '1' || s == 'true' || s == 'yes';
    }

    // Handle wallet_balance which might be int or double or string
    String parseBalance(dynamic balance) {
      if (balance == null) return '0';
      if (balance is String) return balance;
      if (balance is int) return balance.toString();
      if (balance is double) return balance.toString();
      return '0';
    }

    return ProfileModel(
      id: json['id'] ?? 0,
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      gender: json['gender'] ?? 0,
      dob: json['dob'],
      pinCode: json['pin']?.toString(),
      address: json['address'],
      profileImage: json['avatar'],
      countryId: json['country_id'],
      stateId: json['state_id'],
      cityId: json['city_id'],
      isEmailVerifiedBool: parseBool(json['email_verified_at']),
      isPhoneVerifiedBool: parseBool(json['phone_verified']),
      code: json['code'],
      walletBalance: parseBalance(json['wallet_balance']),
      cumulativeAmount: json['cumulative_amount']?.toString() ?? '0',
      referenceId: json['reference_id'],
      refer: json['refer'] != null ? ProfileRefer.fromJson(json['refer']) : null,
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
      'pin': pinCode,
      'address': address,
      'avatar': profileImage,
      'country_id': countryId,
      'state_id': stateId,
      'city_id': cityId,
      'code': code,
      'wallet_balance': walletBalance,
      'cumulative_amount': cumulativeAmount,
      'reference_id': referenceId,
    };
  }
}

// Add this class for the nested 'refer' object
class ProfileRefer {
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
  final String? code;
  final String walletBalance;
  final String cumulativeAmount;
  final int? referenceId;

  ProfileRefer({
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
    this.code,
    required this.walletBalance,
    required this.cumulativeAmount,
    this.referenceId,
  });

  String get fullName => '${firstName.trim()} ${lastName.trim()}'.trim();

  factory ProfileRefer.fromJson(Map<String, dynamic> json) {
    String parseBalance(dynamic balance) {
      if (balance == null) return '0';
      if (balance is String) return balance;
      if (balance is int) return balance.toString();
      if (balance is double) return balance.toString();
      return '0';
    }

    return ProfileRefer(
      id: json['id'] ?? 0,
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      gender: json['gender'] ?? 0,
      dob: json['dob'],
      pinCode: json['pin']?.toString(),
      address: json['address'],
      profileImage: json['avatar'],
      code: json['code'],
      walletBalance: parseBalance(json['wallet_balance']),
      cumulativeAmount: json['cumulative_amount']?.toString() ?? '0',
      referenceId: json['reference_id'],
    );
  }
}