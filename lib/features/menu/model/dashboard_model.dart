import 'package:flutter/material.dart';
import '../../../common/api_constant.dart';

class ProfileDashboardResponse {
  final Profile profile;
  final int myProperties;
  final int marketEnquiryCount;
  final int materialEnquiryCount;
  final int residentialEnquiry;
  final List<SyndicateBooked> syndicateBooked;
  final List<GiooBooked> giooBooked;
  final List<MarketEnquiry> marketEnquiry;
  final List<MaterialEnquiry> materialEnquiry;

  ProfileDashboardResponse({
    required this.profile,
    required this.myProperties,
    required this.marketEnquiryCount,
    required this.materialEnquiryCount,
    required this.residentialEnquiry,
    required this.syndicateBooked,
    required this.giooBooked,
    required this.marketEnquiry,
    required this.materialEnquiry,
  });

  factory ProfileDashboardResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];

    return ProfileDashboardResponse(
      profile: Profile.fromJson(data['profile']),
      myProperties: data['myproperties'] ?? 0,
      marketEnquiryCount: data['market_enquiry_count'] ?? 0,
      materialEnquiryCount: data['material_enquiry_count'] ?? 0,
      residentialEnquiry: data['residential_enquiry'] ?? 0,
      syndicateBooked: (data['syndicate_booked'] as List? ?? [])
          .map((e) => SyndicateBooked.fromJson(e))
          .toList(),
      giooBooked: (data['gioo_booked'] as List? ?? [])
          .map((e) => GiooBooked.fromJson(e))
          .toList(),
      marketEnquiry: (data['market_enquiry'] as List? ?? [])
          .map((e) => MarketEnquiry.fromJson(e))
          .toList(),
      materialEnquiry: (data['material_enquiry'] as List? ?? [])
          .map((e) => MaterialEnquiry.fromJson(e))
          .toList(),
    );
  }
}

class Profile {
  final int? id;
  final Role? role;
  final int? isVendor;
  final int? isAgent;
  final int? isServices;
  final String? name;
  final String? email;
  final String? emailVerifiedAt;
  final int? referenceId;
  final String? code;
  final String? dob;
  final String? avatar;
  final String? pin;
  final int? gender;
  final String? address;
  final String? phone;
  final int? status;
  final int? agentRequest;
  final int? vendorRequest;
  final int? serviceRequest;
  final String? firstName;
  final String? lastName;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? fcmToken;
  final int? isDeleted;
  final String? walletBalance;
  final int? countryId;
  final int? stateId;
  final int? cityId;
  final String? cumulativeAmount;

  Profile({
    this.id,
    this.role,
    this.isVendor,
    this.isAgent,
    this.isServices,
    this.name,
    this.email,
    this.emailVerifiedAt,
    this.referenceId,
    this.code,
    this.dob,
    this.avatar,
    this.pin,
    this.gender,
    this.address,
    this.phone,
    this.status,
    this.agentRequest,
    this.vendorRequest,
    this.serviceRequest,
    this.firstName,
    this.lastName,
    this.createdAt,
    this.updatedAt,
    this.fcmToken,
    this.isDeleted,
    this.walletBalance,
    this.countryId,
    this.stateId,
    this.cityId,
    this.cumulativeAmount,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'],
      role: json['role'] != null ? Role.fromJson(json['role']) : null,
      isVendor: json['is_vendor'],
      isAgent: json['is_agent'],
      isServices: json['is_services'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      emailVerifiedAt: json['email_verified_at'],
      referenceId: json['reference_id'],
      code: json['code'],
      dob: json['dob'] ?? '',
      avatar: json['avatar'] ?? '',
      pin: json['pin']?.toString() ?? '',
      gender: json['gender'] ?? 0,
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      status: json['status'] ?? 0,
      agentRequest: json['agent_request'] ?? 0,
      vendorRequest: json['vendor_request'] ?? 0,
      serviceRequest: json['service_request'] ?? 0,
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      fcmToken: json['fcm_token'],
      isDeleted: json['is_deleted'] ?? 0,
      walletBalance: json['wallet_balance']?.toString() ?? '0',
      countryId: json['country_id'] ?? 0,
      stateId: json['state_id'] ?? 0,
      cityId: json['city_id'] ?? 0,
      cumulativeAmount: json['cumulative_amount']?.toString() ?? '0',
    );
  }
}

class Role {
  final int id;
  final String role;
  final DateTime createdAt;
  final DateTime updatedAt;

  Role({
    required this.id,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'],
      role: json['role'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

class SyndicateBooked {
  final int id;
  final int propertyId;
  final int userId;
  final int transactionId;
  final String amount;
  final String units;
  final int status;
  final int cancelStatus;
  final String refundAmount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? dtdcId;
  final String? trackingId;
  final int dtdcCancelled;

  SyndicateBooked({
    required this.id,
    required this.propertyId,
    required this.userId,
    required this.transactionId,
    required this.amount,
    required this.units,
    required this.status,
    required this.cancelStatus,
    required this.refundAmount,
    required this.createdAt,
    required this.updatedAt,
    this.dtdcId,
    this.trackingId,
    required this.dtdcCancelled,
  });

  factory SyndicateBooked.fromJson(Map<String, dynamic> json) {
    return SyndicateBooked(
      id: json['id'],
      propertyId: json['property_id'],
      userId: json['user_id'],
      transactionId: json['transaction_id'],
      amount: json['amount']?.toString() ?? '0',
      units: json['units']?.toString() ?? '',
      status: json['status'] ?? 0,
      cancelStatus: json['cancel_status'] ?? 0,
      refundAmount: json['refund_amount']?.toString() ?? '0',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      dtdcId: json['dtdc_id'],
      trackingId: json['tracking_id'],
      dtdcCancelled: json['dtdc_cancelled'] ?? 0,
    );
  }
}

class GiooBooked {
  final int id;
  final int propertyId;
  final int userId;
  final String units;
  final String amount;
  final double walletAmount;  // Changed from int to double
  final double onlineAmount;  // Changed from int to double
  final int transactionId;
  final String? returnAmount;
  final String? returnDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? couponId;
  final String specialDiscount;

  GiooBooked({
    required this.id,
    required this.propertyId,
    required this.userId,
    required this.units,
    required this.amount,
    required this.walletAmount,
    required this.onlineAmount,
    required this.transactionId,
    this.returnAmount,
    this.returnDate,
    required this.createdAt,
    required this.updatedAt,
    this.couponId,
    required this.specialDiscount,
  });

  factory GiooBooked.fromJson(Map<String, dynamic> json) {
    return GiooBooked(
      id: json['id'],
      propertyId: json['property_id'],
      userId: json['user_id'],
      units: json['units']?.toString() ?? '',
      amount: json['amount']?.toString() ?? '0',
      walletAmount: (json['wallet_amount'] ?? 0).toDouble(), // Convert to double
      onlineAmount: (json['online_amount'] ?? 0).toDouble(), // Convert to double
      transactionId: json['transaction_id'],
      returnAmount: json['return_amount']?.toString(),
      returnDate: json['return_date'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      couponId: json['coupon_id'],
      specialDiscount: json['special_discount']?.toString() ?? '0',
    );
  }
}
class MarketEnquiry {
  final int id;
  final int userId;
  final int? propertyId;
  final int counts;  // If this is getting double from JSON, change to double
  final int sold;    // If this is getting double from JSON, change to double
  final DateTime createdAt;
  final DateTime updatedAt;
  final dynamic property;

  MarketEnquiry({
    required this.id,
    required this.userId,
    this.propertyId,
    required this.counts,
    required this.sold,
    required this.createdAt,
    required this.updatedAt,
    this.property,
  });

  factory MarketEnquiry.fromJson(Map<String, dynamic> json) {
    return MarketEnquiry(
      id: json['id'],
      userId: json['user_id'],
      propertyId: json['property_id'],
      counts: (json['counts'] ?? 0).toInt(), // Ensure int
      sold: (json['sold'] ?? 0).toInt(),     // Ensure int
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      property: json['property'],
    );
  }
}
class MaterialEnquiry {
  final int id;
  final int materialId;
  final int userId;
  final String? name;
  final String? email;
  final String? phone;
  final String? quote;
  final int? unitId;
  final int? quantity;
  final int? assignedVendor;
  final int accepted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Material material;
  final Profile user;

  MaterialEnquiry({
    required this.id,
    required this.materialId,
    required this.userId,
    this.name,
    this.email,
    this.phone,
    this.quote,
    this.unitId,
    this.quantity,
    this.assignedVendor,
    required this.accepted,
    required this.createdAt,
    required this.updatedAt,
    required this.material,
    required this.user,
  });

  factory MaterialEnquiry.fromJson(Map<String, dynamic> json) {
    return MaterialEnquiry(
      id: json['id'],
      materialId: json['material_id'],
      userId: json['user_id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      quote: json['quote'],
      unitId: json['unit_id'],
      quantity: json['quantity'],
      assignedVendor: json['assigned_vendor'],
      accepted: json['accepted'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      material: Material.fromJson(json['material']),
      user: Profile.fromJson(json['user']),
    );
  }
}

class Material {
  final int id;
  final String materialName;
  final int categoryId;
  final int? subcatId;
  final int? subsubcatId;
  final String? brandId;
  final int? unitId;
  final String? description;
  final String? image;
  final int status;
  final int isDeleted;
  final int featured;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? gallery;
  final int? countryId;
  final int? stateId;
  final int? cityId;

  Material({
    required this.id,
    required this.materialName,
    required this.categoryId,
    this.subcatId,
    this.subsubcatId,
    this.brandId,
    this.unitId,
    this.description,
    this.image,
    required this.status,
    required this.isDeleted,
    required this.featured,
    required this.createdAt,
    required this.updatedAt,
    this.gallery,
    this.countryId,
    this.stateId,
    this.cityId,
  });

  factory Material.fromJson(Map<String, dynamic> json) {
    return Material(
      id: json['id'],
      materialName: json['material_name'] ?? '',
      categoryId: json['category_id'] ?? 0,
      subcatId: json['subcat_id'],
      subsubcatId: json['subsubcat_id'],
      brandId: json['brand_id'],
      unitId: json['unit_id'],
      description: json['description'],
      image: json['image'],
      status: json['status'] ?? 0,
      isDeleted: json['is_deleted'] ?? 0,
      featured: json['featured'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      gallery: json['gallery'],
      countryId: json['country_id'],
      stateId: json['state_id'],
      cityId: json['city_id'],
    );
  }
}

class ContactRequest {
  final String name;
  final String email;
  final String message;

  ContactRequest({
    required this.name,
    required this.email,
    required this.message,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'message': message,
    };
  }
}

class ContactResponse {
  final bool status;
  final String message;

  ContactResponse({
    required this.status,
    required this.message,
  });

  factory ContactResponse.fromJson(Map<String, dynamic> json) {
    return ContactResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
    );
  }
}

class TermsPage {
  final int id;
  final String title;
  final String slug;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  TermsPage({
    required this.id,
    required this.title,
    required this.slug,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TermsPage.fromJson(Map<String, dynamic> json) {
    return TermsPage(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Terms & Conditions',
      slug: json['slug'] ?? '',
      content: json['content'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toString()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toString()),
    );
  }
}



class BusinessSettings {
  int? id;
  String? logo;
  String? businessName;
  String? businessPhone;
  String? businessEmail;
  String? businessAddress;
  double? giooAdminPercentage;
  double? vendorOnboardAmount;
  double? serviceOnboardAmount;
  double? plotBookingAmount;
  double? syndicateDocumentAmount;
  double? rentalDocumentAmount;
  double? residentialDocumentAmount;
  double? marketPlotVerifyAmount;
  double? marketPlotAmount;
  int? giooMaxDuration;
  double? giooMinProfit;
  double? tax;
  String? commonGst;
  String? mapKey;
  String? paymentApiKey;
  String? paymentSecretKey;
  String? smtpMailer;
  String? mailHost;
  int? mailPort;
  String? mailUsername;
  String? mailPassword;
  String? mailEncryption;
  String? mailFromName;
  String? mailFromAddress;
  String? firebaseServiceFile;
  String? firebaseApiKey;
  String? firebaseProjectId;
  String? firebaseAuthDomain;
  String? firebaseStorageBucket;
  String? firebaseSenderId;
  String? firebaseAppId;
  String? firebaseMeasureId;
  String? footerDescription;
  String? instagram;
  String? youtube;
  String? whatsapp;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? discountMaxCost;
  double? discountPercentage;
  String? cumulativeMaxCost;
  double? cumulativePercentage;
  double? encashmentGst;
  String? firstLevel;
  String? secondLevel;
  String? thirdLevel;
  String? otherFirstLevel;
  String? otherSecondLevel;
  String? otherThirdLevel;
  String? frontendUrl;
  String? landDescription;
  String? gioonanoDescription;
  String? syndicateDescription;
  String? gioorentalDescription;
  String? plotDescription;
  String? cumulativeDescription;
  String? encashmentDescription;
  String? giooTerms;
  String? syndicateTerms;
  String? marketplaceTerms;
  String? rentalTerms;
  String? residentialTerms;
  String? sealImage;
  String? signatureImage;
  double? refundAmount;
  double? couponServiceCharge;
  double? minCouponVal;
  double? maxCouponVal;
  String? howItWorkYoutubeLink;
  double? giooServiceCharge;
  double? giooIgst;
  double? syndicateServiceCharge;
  double? syndicateIgst;
  double? marketServiceCharge;
  double? marketIgst;
  double? rentalServiceCharge;
  double? rentalIgst;
  double? residentialServiceCharge;
  double? residentialIgst;

  BusinessSettings({
    this.id,
    this.logo,
    this.businessName,
    this.businessPhone,
    this.businessEmail,
    this.businessAddress,
    this.giooAdminPercentage,
    this.vendorOnboardAmount,
    this.serviceOnboardAmount,
    this.plotBookingAmount,
    this.syndicateDocumentAmount,
    this.rentalDocumentAmount,
    this.residentialDocumentAmount,
    this.marketPlotVerifyAmount,
    this.marketPlotAmount,
    this.giooMaxDuration,
    this.giooMinProfit,
    this.tax,
    this.commonGst,
    this.mapKey,
    this.paymentApiKey,
    this.paymentSecretKey,
    this.smtpMailer,
    this.mailHost,
    this.mailPort,
    this.mailUsername,
    this.mailPassword,
    this.mailEncryption,
    this.mailFromName,
    this.mailFromAddress,
    this.firebaseServiceFile,
    this.firebaseApiKey,
    this.firebaseProjectId,
    this.firebaseAuthDomain,
    this.firebaseStorageBucket,
    this.firebaseSenderId,
    this.firebaseAppId,
    this.firebaseMeasureId,
    this.footerDescription,
    this.instagram,
    this.youtube,
    this.whatsapp,
    this.createdAt,
    this.updatedAt,
    this.discountMaxCost,
    this.discountPercentage,
    this.cumulativeMaxCost,
    this.cumulativePercentage,
    this.encashmentGst,
    this.firstLevel,
    this.secondLevel,
    this.thirdLevel,
    this.otherFirstLevel,
    this.otherSecondLevel,
    this.otherThirdLevel,
    this.frontendUrl,
    this.landDescription,
    this.gioonanoDescription,
    this.syndicateDescription,
    this.gioorentalDescription,
    this.plotDescription,
    this.cumulativeDescription,
    this.encashmentDescription,
    this.giooTerms,
    this.syndicateTerms,
    this.marketplaceTerms,
    this.rentalTerms,
    this.residentialTerms,
    this.sealImage,
    this.signatureImage,
    this.refundAmount,
    this.couponServiceCharge,
    this.minCouponVal,
    this.maxCouponVal,
    this.howItWorkYoutubeLink,
    this.giooServiceCharge,
    this.giooIgst,
    this.marketIgst,
    this.marketServiceCharge,
    this.rentalIgst,
    this.rentalServiceCharge,
    this.residentialIgst,
    this.residentialServiceCharge,
    this.syndicateIgst,
    this.syndicateServiceCharge
  });

  factory BusinessSettings.fromJson(Map<String, dynamic> json) {
    return BusinessSettings(
      id: json['id'] as int?,
      logo: json['logo'] as String?,
      businessName: json['business_name'] as String?,
      businessPhone: json['business_phone'] as String?,
      businessEmail: json['business_email'] as String?,
      businessAddress: json['business_address'] as String?,
      giooAdminPercentage: json['gioo_admin_percentage'] != null
          ? double.tryParse(json['gioo_admin_percentage'].toString())
          : null,
      vendorOnboardAmount: json['vendor_onboard_amount'] != null
          ? double.tryParse(json['vendor_onboard_amount'].toString())
          : null,
      serviceOnboardAmount: json['service_onboard_amount'] != null
          ? double.tryParse(json['service_onboard_amount'].toString())
          : null,
      plotBookingAmount: json['plot_booking_amount'] != null
          ? double.tryParse(json['plot_booking_amount'].toString())
          : null,
      syndicateDocumentAmount: json['syndicate_document_amount'] != null
          ? double.tryParse(json['syndicate_document_amount'].toString())
          : null,
      rentalDocumentAmount: json['rental_document_amount'] != null
          ? double.tryParse(json['rental_document_amount'].toString())
          : null,
      residentialDocumentAmount: json['residential_document_amount'] != null
          ? double.tryParse(json['residential_document_amount'].toString())
          : null,
      marketPlotVerifyAmount: json['market_plot_verify_amount'] != null
          ? double.tryParse(json['market_plot_verify_amount'].toString())
          : null,
      marketPlotAmount: json['market_plot_amount'] != null
          ? double.tryParse(json['market_plot_amount'].toString())
          : null,
      giooMaxDuration: json['gioo_max_duration'] as int?,
      giooMinProfit: json['gioo_min_profit'] != null
          ? double.tryParse(json['gioo_min_profit'].toString())
          : null,
      tax: json['tax'] != null ? double.tryParse(json['tax'].toString()) : null,
      commonGst: json['common_gst'] as String?,
      mapKey: json['map_key'] as String?,
      paymentApiKey: json['payment_api_key'] as String?,
      paymentSecretKey: json['payment_secret_key'] as String?,
      smtpMailer: json['smtp_mailer'] as String?,
      mailHost: json['mail_host'] as String?,
      mailPort: json['mail_port'] as int?,
      mailUsername: json['mail_username'] as String?,
      mailPassword: json['mail_password'] as String?,
      mailEncryption: json['mail_encryption'] as String?,
      mailFromName: json['mail_from_name'] as String?,
      mailFromAddress: json['mail_from_address'] as String?,
      firebaseServiceFile: json['firebase_service_file'] as String?,
      firebaseApiKey: json['firebase_api_key'] as String?,
      firebaseProjectId: json['firebase_project_id'] as String?,
      firebaseAuthDomain: json['firebase_auth_domain'] as String?,
      firebaseStorageBucket: json['firebase_storage_bucket'] as String?,
      firebaseSenderId: json['firebase_sender_id'] as String?,
      firebaseAppId: json['firebase_app_id'] as String?,
      firebaseMeasureId: json['firebase_measure_id'] as String?,
      footerDescription: json['footer_description'] as String?,
      instagram: json['instagram'] as String?,
      youtube: json['youtube'] as String?,
      whatsapp: json['whatsapp'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      discountMaxCost: json['discount_max_cost'] as String?,
      discountPercentage: json['discount_percentage'] != null
          ? double.tryParse(json['discount_percentage'].toString())
          : null,
      cumulativeMaxCost: json['cumulative_max_cost'] as String?,
      cumulativePercentage: json['cumulative_percentage'] != null
          ? double.tryParse(json['cumulative_percentage'].toString())
          : null,
      encashmentGst: json['encashment_gst'] != null
          ? double.tryParse(json['encashment_gst'].toString())
          : null,
      firstLevel: json['first_level'] as String?,
      secondLevel: json['second_level'] as String?,
      thirdLevel: json['third_level'] as String?,
      otherFirstLevel: json['other_first_level'] as String?,
      otherSecondLevel: json['other_second_level'] as String?,
      otherThirdLevel: json['other_third_level'] as String?,
      frontendUrl: json['frontend_url'] as String?,
      landDescription: json['land_description'] as String?,
      gioonanoDescription: json['gioonano_description'] as String?,
      syndicateDescription: json['syndicate_description'] as String?,
      gioorentalDescription: json['gioorental_description'] as String?,
      plotDescription: json['plot_description'] as String?,
      cumulativeDescription: json['cumulative_description'] as String?,
      encashmentDescription: json['encashment_description'] as String?,
      giooTerms: json['gioo_terms'] as String?,
      syndicateTerms: json['syndicate_terms'] as String?,
      marketplaceTerms: json['marketplace_terms'] as String?,
      rentalTerms: json['rental_terms'] as String?,
      residentialTerms: json['residential_terms'] as String?,
      sealImage: json['seal_image'] as String?,
      signatureImage: json['signature_image'] as String?,
      howItWorkYoutubeLink: json['how_it_work_youtube_link'] as String?,
      giooServiceCharge: json['gioo_service_charge'] != null
          ? double.tryParse(json['gioo_service_charge'].toString())
          : null,
      giooIgst: json['gioo_igst'] != null
          ? double.tryParse(json['gioo_igst'].toString())
          : null,
      syndicateServiceCharge: json['syndicate_service_charge'] != null
          ? double.tryParse(json['syndicate_service_charge'].toString())
          : null,
      syndicateIgst: json['syndicate_igst'] != null
          ? double.tryParse(json['syndicate_igst'].toString())
          : null,
      marketServiceCharge: json['market_service_charge'] != null
          ? double.tryParse(json['market_service_charge'].toString())
          : null,
      marketIgst: json['market_igst'] != null
          ? double.tryParse(json['market_igst'].toString())
          : null,
      rentalServiceCharge: json['rental_service_charge'] != null
          ? double.tryParse(json['rental_service_charge'].toString())
          : null,
      rentalIgst: json['rental_igst'] != null
          ? double.tryParse(json['rental_igst'].toString())
          : null,
      residentialServiceCharge: json['residential_service_charge'] != null
          ? double.tryParse(json['residential_service_charge'].toString())
          : null,
      residentialIgst: json['residential_igst'] != null
          ? double.tryParse(json['residential_igst'].toString())
          : null,



      refundAmount: json['refund_amount'] != null
          ? double.tryParse(json['refund_amount'].toString())
          : null,
      couponServiceCharge: json['coupon_service_charge'] != null ? double.tryParse(json['coupon_service_charge'].toString()) : null,
      minCouponVal: json['min_coupon_val'] != null
          ? double.tryParse(json['min_coupon_val'].toString())
          : null,
      maxCouponVal: json['max_coupon_val'] != null
          ? double.tryParse(json['max_coupon_val'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'logo': logo,
      'business_name': businessName,
      'business_phone': businessPhone,
      'business_email': businessEmail,
      'business_address': businessAddress,
      'gioo_admin_percentage': giooAdminPercentage,
      'vendor_onboard_amount': vendorOnboardAmount,
      'service_onboard_amount': serviceOnboardAmount,
      'plot_booking_amount': plotBookingAmount,
      'syndicate_document_amount': syndicateDocumentAmount,
      'rental_document_amount': rentalDocumentAmount,
      ''
          ''
          '': residentialDocumentAmount,
      'market_plot_verify_amount': marketPlotVerifyAmount,
      'market_plot_amount': marketPlotAmount,
      'gioo_max_duration': giooMaxDuration,
      'gioo_min_profit': giooMinProfit,
      'tax': tax,
      'common_gst': commonGst,
      'map_key': mapKey,
      'payment_api_key': paymentApiKey,
      'payment_secret_key': paymentSecretKey,
      'smtp_mailer': smtpMailer,
      'mail_host': mailHost,
      'mail_port': mailPort,
      'mail_username': mailUsername,
      'mail_password': mailPassword,
      'mail_encryption': mailEncryption,
      'mail_from_name': mailFromName,
      'mail_from_address': mailFromAddress,
      'firebase_service_file': firebaseServiceFile,
      'firebase_api_key': firebaseApiKey,
      'firebase_project_id': firebaseProjectId,
      'firebase_auth_domain': firebaseAuthDomain,
      'firebase_storage_bucket': firebaseStorageBucket,
      'firebase_sender_id': firebaseSenderId,
      'firebase_app_id': firebaseAppId,
      'firebase_measure_id': firebaseMeasureId,
      'footer_description': footerDescription,
      'instagram': instagram,
      'youtube': youtube,
      'whatsapp': whatsapp,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'discount_max_cost': discountMaxCost,
      'discount_percentage': discountPercentage,
      'cumulative_max_cost': cumulativeMaxCost,
      'cumulative_percentage': cumulativePercentage,
      'encashment_gst': encashmentGst,
      'first_level': firstLevel,
      'second_level': secondLevel,
      'third_level': thirdLevel,
      'other_first_level': otherFirstLevel,
      'other_second_level': otherSecondLevel,
      'other_third_level': otherThirdLevel,
      'frontend_url': frontendUrl,
      'land_description': landDescription,
      'gioonano_description': gioonanoDescription,
      'syndicate_description': syndicateDescription,
      'gioorental_description': gioorentalDescription,
      'plot_description': plotDescription,
      'cumulative_description': cumulativeDescription,
      'encashment_description': encashmentDescription,
      'gioo_terms': giooTerms,
      'syndicate_terms': syndicateTerms,
      'marketplace_terms': marketplaceTerms,
      'rental_terms': rentalTerms,
      'residential_terms': residentialTerms,
      'seal_image': sealImage,
      'signature_image': signatureImage,
      'refund_amount': refundAmount,
      'coupon_service_charge': couponServiceCharge,
    };
  }

  String get fullLogoUrl {
    if (logo == null || logo!.isEmpty) return '';
    return '${ApiUrl.baseUrl}/storage/$logo';
  }

  String get fullSealImageUrl {
    if (sealImage == null || sealImage!.isEmpty) return '';
    return '${ApiUrl.baseUrl}/storage/$sealImage';
  }

  String get fullSignatureImageUrl {
    if (signatureImage == null || signatureImage!.isEmpty) return '';
    return '${ApiUrl.baseUrl}/storage/$signatureImage';
  }

  // Helper method to get cumulative description with formatted text
  String get formattedCumulativeDescription {
    if (cumulativeDescription == null || cumulativeDescription!.isEmpty) {
      return "Exclusion: The reward will not be applicable if the Gioo Nano plots is ₹5,000 or more.\n\n"
          "Wallet Credit: Each time your total Gioo Nano plots reaches ₹5,000, you will receive ₹500 credited to your wallet.\n\n"
          "Reward Eligibility: The reward is applicable only if the Gioo Nano plots is less than ₹5,000.";
    }
    return cumulativeDescription!;
  }

  // Helper method to get cumulative max cost as double
  double get cumulativeMaxCostValue {
    if (cumulativeMaxCost == null || cumulativeMaxCost!.isEmpty) return 5000.0;
    return double.tryParse(cumulativeMaxCost!) ?? 5000.0;
  }

  // Helper method to get wallet credit amount (10% of cumulative max cost)
  double get walletCreditAmount {
    return cumulativeMaxCostValue * (cumulativePercentage ?? 10) / 100;
  }

  // Helper method to get formatted wallet credit amount
  String get formattedWalletCreditAmount {
    return "₹${walletCreditAmount.toStringAsFixed(2)}";
  }

  // Helper method to get reward eligibility threshold
  String get rewardThreshold {
    return "₹${cumulativeMaxCostValue.toStringAsFixed(2)}";
  }

  // Helper method to check if cumulative amount is eligible for reward
  bool isEligibleForReward(double cumulativeAmount) {
    return cumulativeAmount < cumulativeMaxCostValue && cumulativeAmount > 0;
  }

  // Helper method to calculate next reward milestone
  double calculateNextRewardMilestone(double currentAmount) {
    if (currentAmount >= cumulativeMaxCostValue) {
      return ((currentAmount / cumulativeMaxCostValue).floor() + 1) * cumulativeMaxCostValue;
    }
    return cumulativeMaxCostValue;
  }

  // Helper method to calculate remaining amount for next reward
  double calculateRemainingForReward(double currentAmount) {
    double nextMilestone = calculateNextRewardMilestone(currentAmount);
    return nextMilestone - currentAmount;
  }

  // Helper method to calculate total reward amount earned
  int calculateTotalRewardsEarned(double currentAmount) {
    if (currentAmount < cumulativeMaxCostValue) return 0;
    return (currentAmount / cumulativeMaxCostValue).floor();
  }

  // Helper method to get total wallet credit earned
  double calculateTotalWalletCredit(double currentAmount) {
    return calculateTotalRewardsEarned(currentAmount) * walletCreditAmount;
  }
}