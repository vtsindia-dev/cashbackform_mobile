  import 'package:flutter/material.dart';

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
    final Role role;
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
      required this.role,
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
        role: Role.fromJson(json['role']),
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



  // lib/features/contact/model/contact_model.dart

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

