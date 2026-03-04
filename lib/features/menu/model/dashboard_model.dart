  import 'package:flutter/material.dart';

import '../../../common/api_constant.dart';

  class ProfileDashboardResponse {
    final Profile profile;
    final int myProperties;
    final int marketEnquiryCount;
    final int materialEnquiryCount;
    final int residentialEnquiry;
    final List<dynamic> syndicateBooked;
    final List<GiooBooked> giooBooked;
    final List<MarketEnquiry> marketEnquiry;
    final List<dynamic> materialEnquiry;

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
        syndicateBooked: data['syndicate_booked'] ?? [],
        giooBooked: (data['gioo_booked'] as List? ?? [])
            .map((e) => GiooBooked.fromJson(e))
            .toList(),
        marketEnquiry: (data['market_enquiry'] as List? ?? [])
            .map((e) => MarketEnquiry.fromJson(e))
            .toList(),
        materialEnquiry: data['material_enquiry'] ?? [],
      );
    }
  }

  class Profile {
    final int id;
    final Role? role; // Make role nullable
    final int isVendor;
    final int isAgent;
    final int isServices;
    final String name;
    final String email;
    final String? emailVerifiedAt;
    final String dob;
    final String avatar;
    final String pin;
    final int gender;
    final String address;
    final String phone;
    final int status;
    final int agentRequest;
    final int vendorRequest;
    final int serviceRequest;
    final String firstName;
    final String lastName;
    final DateTime createdAt;
    final DateTime updatedAt;
    final String? fcmToken;

    Profile({
      required this.id,
      this.role, // Make nullable
      required this.isVendor,
      required this.isAgent,
      required this.isServices,
      required this.name,
      required this.email,
      this.emailVerifiedAt,
      required this.dob,
      required this.avatar,
      required this.pin,
      required this.gender,
      required this.address,
      required this.phone,
      required this.status,
      required this.agentRequest,
      required this.vendorRequest,
      required this.serviceRequest,
      required this.firstName,
      required this.lastName,
      required this.createdAt,
      required this.updatedAt,
      this.fcmToken,
    });

    factory Profile.fromJson(Map<String, dynamic> json) {
      return Profile(
        id: json['id'],
        role: json['role'] != null ? Role.fromJson(json['role']) : null, // Handle null role
        isVendor: json['is_vendor'],
        isAgent: json['is_agent'],
        isServices: json['is_services'],
        name: json['name'],
        email: json['email'],
        emailVerifiedAt: json['email_verified_at'],
        dob: json['dob'],
        avatar: json['avatar'],
        pin: json['pin'],
        gender: json['gender'],
        address: json['address'],
        phone: json['phone'],
        status: json['status'],
        agentRequest: json['agent_request'],
        vendorRequest: json['vendor_request'],
        serviceRequest: json['service_request'],
        firstName: json['first_name'],
        lastName: json['last_name'],
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: DateTime.parse(json['updated_at']),
        fcmToken: json['fcm_token'],
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
        role: json['role'],
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: DateTime.parse(json['updated_at']),
      );
    }
  }


  class GiooBooked {
    final int id;
    final int propertyId;
    final int userId;
    final String units;
    final String amount;
    final int transactionId;
    final String? returnAmount;
    final String? returnDate;
    final DateTime createdAt;
    final DateTime updatedAt;

    GiooBooked({
      required this.id,
      required this.propertyId,
      required this.userId,
      required this.units,
      required this.amount,
      required this.transactionId,
      this.returnAmount,
      this.returnDate,
      required this.createdAt,
      required this.updatedAt,
    });

    factory GiooBooked.fromJson(Map<String, dynamic> json) {
      return GiooBooked(
        id: json['id'],
        propertyId: json['property_id'],
        userId: json['user_id'],
        units: json['units'],
        amount: json['amount'],
        transactionId: json['transaction_id'],
        returnAmount: json['return_amount'],
        returnDate: json['return_date'],
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: DateTime.parse(json['updated_at']),
      );
    }
  }


  class MarketEnquiry {
    final int id;
    final int userId;
    final int? propertyId;
    final int counts;
    final DateTime createdAt;
    final DateTime updatedAt;
    final dynamic property;

    MarketEnquiry({
      required this.id,
      required this.userId,
      this.propertyId,
      required this.counts,
      required this.createdAt,
      required this.updatedAt,
      this.property,
    });

    factory MarketEnquiry.fromJson(Map<String, dynamic> json) {
      return MarketEnquiry(
        id: json['id'],
        userId: json['user_id'],
        propertyId: json['property_id'],
        counts: json['counts'],
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: DateTime.parse(json['updated_at']),
        property: json['property'],
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
        'residential_document_amount': residentialDocumentAmount,
        'market_plot_verify_amount': marketPlotVerifyAmount,
        'market_plot_amount': marketPlotAmount,
        'gioo_max_duration': giooMaxDuration,
        'gioo_min_profit': giooMinProfit,
        'tax': tax,
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
      };
    }

    String get fullLogoUrl {
      if (logo == null || logo!.isEmpty) return '';
      return '${ApiUrl.baseUrl}/storage/$logo';
    }
  }